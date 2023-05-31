unit ProcUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, StdCtrls, IniFiles, DateUtils, ExtCtrls, frxClass, Sockets, DataUnit;

const
  WM_SENDTCP = WM_USER+101;
  tcpOK      = 101;
  tcpConnect = 102;
  tcpError   = 103;
  tcpError1  = 104;

type
  TLogRecord = record
    time : TDateTime;
    scnum: integer;
    code : string[16];
    name : string[255];
    mind : integer;
  end;

  //данные о моделях (аналлогично прог-ме штрикодирования)
  TModRecord = record
    name,pwr,net,code : string;
  end;

  TDataMod = class(TDataModule)
    TcpClnt: TTcpClient;
    Report: TfrxReport;
    procedure AddLog(code,name:string;mind, scnum:integer);
    procedure FaultCode(ind, scnum:integer);          //обработка кода из группы ОШИБКИ
    procedure SaveLogsToFile(fname:string);
    function  CodeInLogs(code: string):boolean;
    function  LoadLogsFromFile(fname:string):boolean;
    function  ProductCode(code:string;scnum: integer):boolean;
    function  ProductCount(Tm1:TTime=0;Tm2:TTime=0;mind:integer=-1):integer;
    function  FixCodeCount(code: string=''; group:integer=-1; Tm1:TTime=0;Tm2:TTime=0;mind:integer=-1):integer;
    procedure DataInit;
    procedure SendTcpMsg(code:string);
    function GetIPAddress(name: string): string;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataMod     : TDataMod;
  FixCode     : TCodeList;          //список фикс кодов (ошибки, коды управления)
  Logs        : TList;              //ЛОГи
  LastModInd  : integer=-1;         //код модели последней ед гот продукции
  ModRecLst   : array of TModRecord;//список кодов моделей
  LastPoductCode    : string;             //последний введенный код


implementation

{$R *.dfm}

uses  ProdMsgUnit, WarningUnit, ShadowForm, Winsock;

type
  //отдлеьный поток для процедуры отправки TCP сообщения
  TTCPMsg = class(tthread)
    host,code   : string;
    rm          : byte;
  protected
    procedure execute; override;
  end;

var
  UniqueCode  : boolean = false;    //флаг проверкм на уникальный код
  LogFile     : string;             //имя файла ЛОГов
  LogDir      : string = 'LOG';     //папка ЛОГов
  FixCodeFile : string;             //имя файла фиксированных кодов
  ModIndFile  : string;             //имя файла кодов моделей
  HostIP      : string;


function TDataMod.GetIPAddress(name: string): string;
const
  WINSOCK_VERSION = $0101;
var
  WSAData: TWSAData;
  p: PHostEnt;
begin
  WSAStartup(WINSOCK_VERSION, WSAData);
  p := GetHostByName(PChar(name));
  if p<>nil then Result := inet_ntoa(PInAddr(p.h_addr_list^)^)
    else result:='';
  WSACleanup;
end;

procedure TTCPMsg.Execute;
begin
  {DataMod.TcpClnt.Active:=false;
  PostMessage(application.MainForm.Handle,WM_SENDTCP,tcpConnect,0);
  DataMod.TcpClnt.RemoteHost:=self.host;
  DataMod.TcpClnt.Active:=true;
  if DataMod.TcpClnt.Connect then
    begin
      DataMod.TcpClnt.Sendln(self.code);
      DataMod.TcpClnt.Active:=false;
      DataMod.TcpClnt.Disconnect;
      PostMessage(application.MainForm.Handle,WM_SENDTCP,tcpOK,0);
    end else PostMessage(application.MainForm.Handle,WM_SENDTCP,tcpError,0); }
  DataMod.TcpClnt.Active:=false;
  PostMessage(application.MainForm.Handle,WM_SENDTCP,tcpConnect,0);
  DataMod.TcpClnt.RemoteHost:=datamod.GetIPAddress('OTK1');
  //showmessage('IP addres for OTK1: '+chr(13)+datamod.GetIPAddress('OTK1'));
  DataMod.TcpClnt.Active:=true;
  if DataMod.TcpClnt.Connect then
    begin
      DataMod.TcpClnt.Sendln('FNAME'+'\\otk2\Users\Public\NetFolder\MainProgram\LOG\'+ExtractFileName(LogFile));
      DataMod.TcpClnt.Active:=false;
      DataMod.TcpClnt.Disconnect;
      PostMessage(application.MainForm.Handle,WM_SENDTCP,tcpOK,0);
   end else PostMessage(application.MainForm.Handle,WM_SENDTCP,tcpError1,0);
  //
  DataMod.TcpClnt.Active:=false;
  PostMessage(application.MainForm.Handle,WM_SENDTCP,tcpConnect,0);
  DataMod.TcpClnt.RemoteHost:=datamod.GetIPAddress('SERGEYSHAGINYAN');
  DataMod.TcpClnt.Active:=true;
  if DataMod.TcpClnt.Connect then
    begin
      DataMod.TcpClnt.Sendln('FNAME'+'\\otk2\Users\Public\NetFolder\MainProgram\LOG\'+ExtractFileName(LogFile));
      DataMod.TcpClnt.Active:=false;
      DataMod.TcpClnt.Disconnect;
      PostMessage(application.MainForm.Handle,WM_SENDTCP,tcpOK,0);
   end else PostMessage(application.MainForm.Handle,WM_SENDTCP,tcpError1,0);
end;

procedure TDataMod.SendTcpMsg(code:string);
var
  NewMsg  : TTCPMsg;
  IP      : string;
begin
  IP:=self.GetIPAddress('OTK1');
  if Length(IP)>0 then begin
      newmsg := TTCPMsg.create(true);
      newmsg.host:=IP;
      newmsg.freeonterminate := true;
      newmsg.rm:=1;
      newmsg.code := code;
      newmsg.priority := tpnormal;
      newmsg.resume;
    end;
end;

procedure TDataMod.DataInit;
var
  strs       : TStringList;
  str        : string;
  i          : integer;
  IniFile    : TIniFile;
  MainPath   : string;
begin
  Logs:=TList.Create;
  FixCode:=TCodeList.Create;
  MainPath:=ExtractFilePath(application.ExeName);
  //Загрузка списка фиксированных кодов
  FixCodeFile:=MainPath+'fixcode.cdl';
  if FileExists(FixCodeFile) then begin
    if not FixCode.LoadFromFile(FixCodeFile)then begin
      MessageDLG('Ошибка чтерия файла фиксированных кодов !',mtError,[mbOK],0);
      FixCode.Clear;
    end;
  end else MessageDLG('Не найден список фиксированных кодов !',mtError,[mbOK],0);
  //Загруэка ЛОГов
  //Если дирректории не существует - создаем ее
  if not DirectoryExists(MainPath+LogDir) then CreateDir(pchar(MainPath+LogDir));
  //нач значение текущего кода модели неизвестно
  LastModInd:=-1;
  //пытаемся найти и загрузить файл
  LogFile:=DateToStr(now);
  while pos(DateSeparator,LogFile)>0 do delete(LogFile,pos(DateSeparator,LogFile),1);
  LogFile:=MainPath+LogDir+'\'+LogFile+'.txt';
  if FileExists(LogFile) then
    if not self.LoadLogsFromFile(LogFile) then begin
      MessageDLG('Ошибка при загрузке файла ЛОГов !',mtError,[mbOk],0);
      Logs.Clear;
    end;
  //Загрузка списка кодов моделей
  ModIndFile:=MainPath+'moddata.txt';
  if FileExists(ModIndFile) then begin
    strs:=TStringList.Create;
    strs.LoadFromFile(ModIndFile);
    SetLength(ModRecLst,strs.Count);
    for i := 0 to Strs.Count - 1 do
      begin
        str:=copy(strs[i],1,pos('|',strs[i])-1);
        ModRecLst[i].Name:=str;
        strs[i]:=copy(strs[i],pos('|',strs[i])+1,MaxInt);
        str:=copy(strs[i],1,pos('|',strs[i])-1);
        ModRecLst[i].Pwr:=str;
        strs[i]:=copy(strs[i],pos('|',strs[i])+1,MaxInt);
        str:=copy(strs[i],1,pos('|',strs[i])-1);
        ModRecLst[i].Net:=str;
        strs[i]:=copy(strs[i],pos('|',strs[i])+1,MaxInt);
        str:=copy(strs[i],1,MaxInt);
        ModRecLst[i].Code:=str;
      end;
  end else MessageDLG('Не найден список кодов моделей !',mtError,[mbOK],0);
  //Загружка файла настроек
  IniFile:=TIniFile.Create(MainPath+'mainini.ini');
  Hostip:=IniFile.ReadString('SIGNAL','SERVERHOST','127.0.0.1');
  TcpClnt.RemotePort:=IniFile.ReadString('SIGNAL','SERVERPORT','8888');
  UniqueCode:=IniFile.ReadBool('SET','UNIQUECODE',true);
  IniFile.Destroy;
end;

//----------------------- Обработка кодов --------------------------------------

function GetUNCName(PathStr: string): string;
var 
  bufSize: DWord; 
  buf: ^TUniversalNameInfo; 
  msg: string; 
begin 
  bufSize := SizeOf(TUniversalNameInfo); 
  if (WNetGetUniversalName(PChar(PathStr), UNIVERSAL_NAME_INFO_LEVEL,buf, bufSize) > 0) then
    case GetLastError of 
      ERROR_BAD_DEVICE: msg := 'ERROR_BAD_DEVICE'; 
      ERROR_CONNECTION_UNAVAIL: msg := 'ERROR_CONNECTION_UNAVAIL'; 
      ERROR_EXTENDED_ERROR: msg := 'ERROR_EXTENDED_ERROR'; 
      ERROR_MORE_DATA: msg := 'ERROR_MORE_DATA'; 
      ERROR_NOT_SUPPORTED: msg := 'ERROR_NOT_SUPPORTED'; 
      ERROR_NO_NET_OR_BAD_PATH: msg := 'ERROR_NO_NET_OR_BAD_PATH'; 
      ERROR_NO_NETWORK: msg := 'ERROR_NO_NETWORK'; 
      ERROR_NOT_CONNECTED: msg := 'ERROR_NOT_CONNECTED'; 
    end 
  else 
    msg := buf.lpUniversalName; 
  Result := msg; 
end;

function TDataMod.ProductCode(code: string;scnum: integer):boolean;
const
  BrCode='АBC';
var
  str,SN       : string;
  ModInd,ind   : integer;
  Date         : TDateTime;
begin
  result:=false;
  //проверяем что код содержит только цифры
  ind:=1;
  while(ind<Length(code))and(code[ind] in ['0'..'9'])do inc(ind);
  if (ind<Length(code))and(not(code[ind] in ['0'..'9'])) then Exit;
  //проверям что первые две цифры входя в список кодов моделей
  str:=copy(code,1,2);
  if Length(str)= 0 then Exit;
  ind:=StrToInt(str)-10;
  //есил индекс кода модели вне списка - выходим из процедуры
  if ind>high(ModRecLst) then Exit;
  ModInd:=ind;
  //Если известен код модели последней единицы и введенный код модели
  //отличается от него - запрашиваем разрешение на смену модели
  //если смена модели не подтверждена - выходим из процедуры
  if (LastModInd>-1)and(ModInd<>LastModInd)then begin
      ShadowShow(application.MainForm);
      if (ShowWarningMsg('СМЕНА МОДЕЛИ','Модель '+ModRecLst[lastmodind].name+' изменяется на '+
        ModRecLst[modind].name+chr(13)+'Подтвердите смену модели!')=false) then begin
          ShadowHide(application.MainForm);
          Exit;
        end;
      //ShadowHide(application.MainForm);
    end;
  LastModInd:=ModInd;
  //проферяем формат даты
  str:=copy(code,3,6);
  ind:=StrTOInt(copy(str,1,2)); if (ind<1)or(ind>31) then Exit; //день
  ind:=StrTOInt(copy(str,3,2)); if (ind<1)or(ind>12) then Exit; //месяц
  str:=copy(str,1,2)+DateSeparator+copy(str,3,2)+DateSeparator+copy(str,5,2);
  Date:=StrToDate(str);
  //Формируем серийный номре
  SN:='K'+ModRecLst[modind].code+copy(code,3,6)+
    BrCode[StrToInt(copy(code,9,1))]+copy(code,10,MaxInt);
  //вывод на экран сообщения об учете кода
  ShadowShow(application.MainForm);
  ShowProdMsg(TimeToStr(now),ModRecLst[modind].name,copy(code,10,MaxInt),3,false);
  ShadowHide(application.MainForm);
  //печатаем свидетельство о приемке
  //if copy(ModRecLst[modind].code,1,2)='EE' then Report.LoadFromFile('docsvd_kz.fr3',False)
  //   else Report.LoadFromFile('docsvd.fr3',False);
  Report.LoadFromFile('docsvd_kz.fr3',False);
  Report.PrintOptions.ShowDialog:=false;
  Report.Variables['model']:=''''+ModRecLst[modind].name+'''';
  Report.Variables['serial']:=''''+sn+'''';
  Report.Variables['mydate']:=''''+FormatDateTime('dd mmm yyyy',date)+'''';
  Report.PrepareReport(true);
  Report.Print;
  //Проверка кода на повоторение если надо
  if UniqueCode and CodeInLogs(code) then Exit;
  //запись в ЛОГ, сохранение ЛОГов в файле
  self.AddLog(code,ModRecLst[modind].name,LastModInd,scnum);
  self.SaveLogsToFile(LogFile);
  //отправка сообщения на РМ ОТК1
  self.SendTcpMsg(IntToStr(ModInd+100));
  //
  LastPoductCode:=Code;

  result:=true;
end;

procedure TDataMod.FaultCode(ind, scnum: integer);
begin
  //запись в ЛОГ, сохранение ЛОГов в файле
  self.AddLog(FixCode.Item[ind].code,FixCode.Item[ind].name,LastModInd,scnum);
  self.SaveLogsToFile(LogFile);
  //отправлка сообщенияя на РМ ОТК1
  if Length(FixCode.Item[ind].note)>0 then begin
    self.SendTcpMsg(FixCode.Item[ind].note);
  end;
end;

//-------------------- Подсчет результатов в ЛОГ-файлах ------------------------

function TDataMod.ProductCount(Tm1:TTime=0;Tm2:TTime=0;mind:integer=-1):integer;
var
  cnt,i : integer;
  prec  : ^TLogRecord;
begin
  //подсчет кол-ва готовой продукции по принципу
  //елси код не входи в список фиксированных - значит считаем
  if Tm1=0 then Tm1:=StartOfADay(YearOf(Now),DayOf(now));
  if Tm2=0 then Tm2:=EndOfADay(YearOf(Now),DayOf(now));
  i:=0;
  cnt:=0;
  if Logs.Count>0 then begin
    while(i<Logs.Count)do begin
      prec:=Logs.Items[i];
      if (FixCode.IndByCode(prec^.code)=-1)and(CompareTime(prec^.time,tm1)>=0)and
        (CompareTime(Tm2,prec^.time)>0)and
        ((mind<0)or((mind>=0)and(prec^.mind=mind))) then inc(cnt);
      inc(i);
    end;
    result:=cnt;
  end else result:=0;
end;

function TDataMod.FixCodeCount(code: string=''; group:integer=-1 ; Tm1:TTime=0;Tm2:TTime=0;mind:integer=-1):integer;
var
  cnt,i : integer;
  prec  : ^TLogRecord;
begin
  //подсчет кол-ва фиксированных кодов по принципу
  if Tm1=0 then Tm1:=StartOfADay(YearOf(Now),DayOf(now));
  if Tm2=0 then Tm2:=EndOfADay(YearOf(Now),DayOf(now));
  i:=0;
  cnt:=0;
  while(i<Logs.Count)do begin
    prec:=Logs.Items[i];
    if (FixCode.IndByCode(prec^.code)>-1) then begin
      if ((prec^.code=code)or(Length(code)=0))and
        ((group=-1)or((group>-1)and(FixCode.Item[FixCode.IndByCode(prec^.code)].group=group)))and
        (CompareTime(prec^.time,tm1)>=0)and(CompareTime(Tm2,prec^.time)>0)and
        ((mind=-1)or((mind>-1)and(mind=prec^.mind)))
        then inc(cnt);
    end;
    inc(i);
  end;
  result:=cnt;
end;

//-------------------- Процедуры работы с ЛОГами -------------------------------

function TDataMod.CodeInLogs(code: string):boolean;
var
  i    : integer;
  prec : ^TLogRecord;
begin
  result:=false;
  if Logs.Count>0 then begin
    i:=0;
    prec:=Logs.Items[i];
    while (i<Logs.Count)and(prec^.code<>code) do begin
      inc(i);
      if i<Logs.Count then prec:=Logs.Items[i];
    end;
    if (i<Logs.Count)and(prec^.code=code) then result:=true;
  end;
end;

procedure TDataMod.AddLog(code,name:string;mind,scnum:integer);
var
  newlog : ^TLogRecord;
begin
  new(newlog);
  newlog^.time:=now;
  newlog^.code:=code;
  newlog^.name:=name;
  newlog^.mind:=mind;
  newlog^.scnum:=scnum;
  Logs.Add(newlog);
end;

procedure TDataMod.SaveLogsToFile(fname: string);
var
  myfile : TextFile;
  str    : string;
  i      : integer;
  plog   : ^TLogRecord;
begin
  assignfile(myfile,fname);
  try
  rewrite(myfile);
  for I := 0 to Logs.Count - 1 do begin
    plog:=Logs.Items[i];
    str:=DateTimeToStr(plog^.time);
    str:=str+chr(9)+IntToStr(plog^.scnum);
    str:=str+chr(9)+plog^.code;
    str:=str+chr(9)+plog^.name;
    str:=str+chr(9)+IntToStr(plog^.mind);
    writeln(myfile,str);
  end;
  finally
  closefile(myfile);
  end;
end;

function TDataMod.LoadLogsFromFile(fname: string):boolean;
var
  myfile : TextFile;
  str    : string;
  prec   : ^TLogRecord;
begin
  result:=false;
  if FileExists(fname) then begin
    assignfile(myfile,fname);
    try
    reset(myfile);
    Logs.Clear;
    while not EoF(myfile) do begin
      new(prec);
      readln(myfile,str);
      prec^.time:=StrToDateTime(copy(str,1,pos(chr(9),str)-1));
      str:=copy(str,pos(chr(9),str)+1,MaxInt);
      prec^.scnum:=StrToInt(copy(str,1,pos(chr(9),str)-1));
      str:=copy(str,pos(chr(9),str)+1,MaxInt);
      prec^.code:=copy(str,1,pos(chr(9),str)-1);
      str:=copy(str,pos(chr(9),str)+1,MaxInt);
      prec^.name:=copy(str,1,pos(chr(9),str)-1);
      str:=copy(str,pos(chr(9),str)+1,MaxInt);
      if pos(chr(9),str)>0 then begin
        prec^.mind:=StrToInt(str);
        LastModInd:=prec^.mind;
      end else begin
        if (FixCode.IndByCode(prec^.code)<0) then
         LastModInd:=StrToInt(copy(prec^.code,1,2))-10;
        prec^.mind:=LastModInd;
      end;
      Logs.Add(prec);
    end;
    result:=true;
    finally
    closefile(myfile);
    end;
  end;
end;

end.
