unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DateUtils, StdCtrls, AppEvnts, IniFiles, mmsystem, Grids, ComCtrls,
  MPlayer, Gauges, Math, Buttons;

const
  //звуки
  sndBreakStart='PauseBgn.wav';
  sndBreakStartAfter='PauseBgnTm.wav';
  sndBreakEnd='PauseEnd.wav';
  sndBreakEndAfter='PauseEndTm.wav';
  sndDayEnd='DayEnd.wav';
  sndDayEndAfter='DayEndTm.wav';
  snd5min='5min.wav';
  snd10min='10min.wav';
  snd15min='15min.wav';
  sndDayStart='StartSound.wav';
  sndAssembl='asembl.wav';
  sndDing='ding.wav';
  sndFault='Fault0.wav';
  sndLongStop='LongStop.wav';
  sndMaxFault='ManyFault.wav';
  sndBeep='pip.wav';
  sndWarning='fafa.wav';
  sndBonus='bonus.wav';
  //виды отображения
  vwDiagram    = 'Page2'; // - почасовая диаграмма + столбец заработка
  vwTable      = 'Page3'; // - данные в ввиде таблицы
  vwFaultTable = 'Page1'; // - таблица неисправностей
  //особые сообщения
  msgLongStop = 'ВНИМАНИЕ! ДЛИТЕЛЬНЫЙ ПРОСТОЙ!';
  msgMaxFault = 'ВНИМАНИЕ! МАССОВЫЙ БРАК!';
  msgSpeedVeryBad = 'Скорость работы очень низкая!';
  msgSpeedBad = 'Скорость работы низкая!';

type
  TMainForm = class(TForm)
    TopPn: TGridPanel;
    ClockPB: TPaintBox;
    MainTimer: TTimer;
    BtmPn: TPanel;
    DayResPn: TPanel;
    RedgPB: TPaintBox;
    MsgPB: TPaintBox;
    Pages: TNotebook;
    MainDgrPn: TPanel;
    MyDiagramCaptionPB: TPaintBox;
    PayDgrPn: TPanel;
    TablePn: TPanel;
    TablePB: TPaintBox;
    TotalPayPB: TPaintBox;
    FaultTablePN: TPanel;
    FaultCaptionPB: TPaintBox;
    TotalFaultPB: TPaintBox;
    SG: TStringGrid;
    ModelPN: TPanel;
    TempPB: TPaintBox;
    OpenDlg: TOpenDialog;
    ExitBtn: TSpeedButton;
    PersonCntBtn: TSpeedButton;
    procedure ClockPBPaint(Sender: TObject);
    procedure SelectDateBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RedgPBPaint(Sender: TObject);
    procedure UpdateMainData(viewname:string='');
    procedure MainTimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MsgPBPaint(Sender: TObject);
    procedure AddInSoundList(soundname:string);
    procedure SetEmployCount(cnt:integer=-1);
    procedure MyDiagramCaptionPBPaint(Sender: TObject);
    procedure TablePBPaint(Sender: TObject);
    procedure TotalPayPBPaint(Sender: TObject);
    procedure FaultCaptionPBPaint(Sender: TObject);
    procedure TotalFaultPBPaint(Sender: TObject);
    procedure SGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure FaultTableUpdate;
    procedure SaveStatLog;
    procedure LoadMainIni;
    procedure TempPBPaint(Sender: TObject);
    procedure TablePnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure PersonCntBtnClick(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    procedure WMCopyData(var MessageData: TWMCopyData); message WM_COPYDATA;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  DiagramClass, DataUnit, FixCodeUnit, MsgUnit, EmpCntForm, OTKPayUnit;

var
  DayResDrg  : ThorDiagram;  //Диаграмма итоговой произиовдтилеьности за день
  MainDgr    : TDiagram=nil; //Диаграмма производства по часам
  PayDgr     : TDiagram=nil; //Диаграмма заработка смены

  LogFileName     : string = '';    //имя файла принятых кодов
  FixCodeFileName : string;         //имя файла фиксированных кодов
  ModFileName     : string;         //имя файла описания моделей
  StatLogDir      : string;         //дирректория записи статистики
  //настройки смены "экранов"
  ViewCurInd      : byte;           //индекс текущего "экрана" из списка чередования;
  ViewList        : array of string;//список чередования экранов
  ViewCngTime     : integer;        //частота смены экранов
  ViewLastCng     : TdateTime;      //время последней смены экранов
  //оповещения
  LastCodeTime    : TDateTime;    //время последнего "озвученного" кода
  BreakMsgTime    : array [0..3] of integer
               = (15,10,5,0);     //оповещение о перерывах и конце рабочего дня
  MsgStr          : string;       //нижняя строка текстового сообщения
  PlaySound       : boolean=true; //включение звуковых сообщений
  SoundsList      : TStringList;  //список звуковых сообщений
  //переменные индикатора времени работы контролера
  TempMax         : integer = DefTempMax; //макс время работы контролера
  TempPos         : integer = -1;         //текущее время работы контролера
  HideButtons     : boolean = false;  //скрыть кнопки управления
  FastStart       : boolean = true;   //не замедлять запуск


//------------------------- Работа с TCP ---------------------------------------

//Уст-ка класса окна что бы программа работы со сканером могла нас найти
procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WinClassName:='MyAsmblDisplayFormClass';
end;

//Прием сообщения от программы работы со сканером
procedure TMainForm.WMCopyData(var MessageData: TWMCopyData);
const
  CMD_SETLABELTEXT=1;
var
  str     : string;
  inifile : TIniFile;
  i       : integer;
  pl      : real;
  BonusFL : word;
begin
  //Устанавливаем свойства метки, если заданная команда совпадает
  if MessageData.CopyDataStruct.dwData = CMD_SETLABELTEXT then
  begin
    //Устанавливаем текст из полученных данных
    str := PAnsiChar((MessageData.CopyDataStruct.lpData));
    if (FileExists(str)) then begin
      if (str<>LogFileName) then begin
        //Запись имени файла ЛОГов в INI-файл
        LogFileName:=str;
        IniFile:=TIniFile.Create(ExtractFilePath(application.exename)+'\mainset.ini');
        inifile.WriteString('MAIN','LOGFILENAME',LogFileName);
        IniFile.Free;
      end;
      //перерисовка экрана
      self.UpdateMainData;
      //если количество персонала не заданно - запрашиваем
      if EmployCount=0 then begin
        SoundsList.Add(sndWarning);
        self.SetEmployCount;
      end;
      //запускаем индикатор темпа работы
      TempPos:=0;
      //сообщение о последнем введнном коде если время его записи позднее
      //предыдущего записанного времени
      if (Logs.Count>0)and(DateOf(Logs.Item[Logs.Count-1].DtTm)=DateOf(now))and
       (Logs.Item[Logs.Count-1].DtTm>LastCodeTime) then begin
          //сброс сообщения о простое, если оно висит
          if MsgStr=msgLongStop then begin
            MsgStr:='';
            MsgPB.Repaint;
          end;
          //если код - готовая продукция
          if Logs.Item[Logs.Count-1].Goods then begin
            //оповещение о готовой продукции
            BonusFl:=0;
            //оповещение о премии за час
            i:=0;
            while(i<=high(PrdList))and(not((now>=PrdList[i].StTm)and(now<PrdList[i].EndTm)))do inc(i);
            if(i<=high(PrdList))and((now>=PrdList[i].StTm)and(now<PrdList[i].EndTm))then begin
              pl:=round(MainPlan[i]);
              if (pl>0)and(pl=TotalGoods(-1,PrdList[i].sttm,PrdList[i].endtm)) then BonusFL:=1;
            end;
            //оповещение о выполенении плана за день
            pl:=0;
            for I := 0 to high(prdlist) do pl:=pl+round(MainPlan[i]);
            if TotalGoods>=pl then BonusFL:=1;
            //добавление звука в список
            case BonusFL of
              0 : self.AddInSoundList(sndAssembl);
              1 : begin
                  self.AddInSoundList(sndWarning);
                  self.AddInSoundList(sndBonus);
                  end;
            end;
          end;
          //если код - брак
          i:=FixCodeList.IndByCode(Logs.Item[Logs.Count-1].code);
          if (i>=0)and(FixCodeList.Item[i].group=0) then begin
            self.AddInSoundList(sndDing);
            self.AddInSoundList(sndFault);
            if length(FixCodeList.Item[i].sound)>0 then self.AddInSoundList(FixCodeList.Item[i].sound);
            if screen.ActiveForm=self then
              MessageFormShow(mtWarn,'ИЗГОТОВЛЕН БРАК',FixCodeList.Item[i].name,10);
            //проверка на предмет массового брака
            if (FixCodeBetween(0,-1,IncHour(now,-1),now)>FaultToHour)or
               (FixCodeBetween(0,-1,IncMinute(now,-15),now)>FaultToFifteenMin) then begin
              self.AddInSoundList(sndMaxFault);
              MsgStr:=msgMaxFault;
              self.MsgPB.Repaint;
            end;
          end;
          LastCodeTime:=Logs.Item[Logs.Count-1].DtTm;
          //запись файла статистики
          self.SaveStatLog;
      end;
    end;
    MessageData.Result := 1;
  end else MessageData.Result := 0;
end;

//------------------------------------------------------------------------------

procedure TMainForm.ExitBtnClick(Sender: TObject);
begin
  Halt(10);
end;

procedure TMainForm.PersonCntBtnClick(Sender: TObject);
begin
  self.SetEmployCount;
end;

//Добавление звука в список
procedure TMainForm.AddInSoundList(soundname:string);
begin
  if PlaySound then
    if (SoundsList.Count=0)or((SoundsList.Count>0)and
      (SoundsList[SoundsList.Count-1]<>soundname)) then
        SoundsList.Add(soundname);
end;

//получение и сохранение количества персонала в смене
procedure TMainForm.SetEmployCount(cnt:integer=-1);
var
  IniFile:TIniFile;
begin
  if cnt>-1 then EmployCount:=cnt
    else if EmpCountForm=nil then
      EmployCount:=MyGetCount('Укажите количества персоналана в смене:',EmployCount,HideButtons);
  IniFile:=TIniFile.Create(ExtractFilePath(application.exename)+'\mainset.ini');
  Inifile.WriteInteger('MAIN','EMPLOYCOUNT',EmployCount);
  IniFile.Free;
end;

procedure TMainForm.FormActivate(Sender: TObject);
var
  i:integer;
begin
  DayResDrg.Repaint;
  self.WindowState:=wsMaximized;
  self.TopPn.DoubleBuffered:=true;
  self.DayResPn.DoubleBuffered:=true;
  self.Repaint;
  if FastStart then self.AlphaBlendValue:=255
    else for I := 0 to 255 do begin
      sleep(1);
      self.AlphaBlendValue:=i;
    end;
  //если количество персонала не заданно - запрашиваем
  if EmployCount=0 then self.SetEmployCount;
end;

//загрузка инициализации
procedure TMainForm.LoadMainIni;
var
  inifile : TIniFile;
  cnt,i   : integer;
  str     : string;
begin
  IniFile:=TIniFile.Create(ExtractFilePath(application.ExeName)+'\mainset.ini');
  LogFileName:=IniFile.ReadString('MAIN','LOGFILENAME','');
  //подбор имени файла Логов (если дата не соответствует текущей)
  if Length(LogFileName)>0 then begin
    str:=ExtractFileName(LogFileName);
    str:=copy(str,1,6);
    if str<>FormatDateTime('ddmmyy',now) then str:=FormatDateTime('ddmmyy',now);
    str:=ExtractFilePath(LogFileName)+str+'.txt';
    if FileExists(str) then LogFileName:=str;
  end;
  FixCodeFileName:=IniFile.ReadString('MAIN','FIXCODEFILENAME',ExtractFilePath(application.ExeName)+'\fixcode.cdl');
  ModFileName:=IniFile.ReadString('MAIN','MODFILENAME',ExtractFilePath(application.ExeName)+'\modlist.txt');
  StatLogDir:=IniFile.ReadString('MAIN','STATLOGDIR','');
  Logs.CodeUnic:=IniFile.ReadBool('MAIN','CODEUNIC',true);
  Logs.InputPaused:=IniFile.ReadInteger('MAIN','INPUTPAUSED',0);
  PlaySound:=IniFile.ReadBool('MAIN','PLAYSOUND',true);
  StopTimeMax:=IniFile.ReadInteger('MAIN','STOPTIMEMAX',10);
  EmployCount:=IniFile.ReadInteger('MAIN','EMPLOYCOUNT',0);
  HideButtons:=IniFile.ReadBool('MAIN','HIDEBUTTONS',false);
  fastStart:=IniFile.ReadBool('MAIN','FASTSTART',true);
  ViewCngTime:=IniFile.ReadInteger('VIEWCNG','VIEWCNGTIME',0);
  if ViewCngTime>0 then begin
    cnt:=inifile.ReadInteger('VIEWCNG','VIEWCNT',1);
    SetLength(ViewList,cnt);
    for I := 0 to cnt - 1 do
      ViewList[i]:=inifile.ReadString('VIEWCNG','VIEW'+IntToStr(i+1),vwDiagram);
  end else begin
    SetLength(ViewList,1);
    ViewList[0]:=vwDiagram;
  end;
  DayTime.StTm:=IniFile.ReadTime('TIME','DAYSTART',StrToTime('08:00'));
  DayTime.StTm:=IncMinute(StartOfTheDay(now),MinuteOfTheDay(DayTime.StTm));
  DayTime.EndTm:=IniFile.ReadTime('TIME','DAYEND',StrToTime('20:00'));
  DayTime.EndTm:=IncMinute(StartOfTheDay(now),MinuteOfTheDay(DayTime.EndTm));;
  AlingHour:=IniFile.ReadBool('TIME','DIAGRAMALINGHOUR',false);
  cnt:=IniFile.ReadInteger('TIME','BREAKCNT',0);
  SetLength(BreakTime,cnt);
  for I := 0 to cnt - 1 do begin
    BreakTime[i].StTm:=IniFile.ReadTime('TIME','BREAKSTART'+IntToStr(i+1),StrToTime('12:00'));
    BreakTime[i].StTm:=IncMinute(StartOfTheDay(now),MinuteOfTheDay(BreakTime[i].StTm));
    BreakTime[i].EndTm:=IniFile.ReadTime('TIME','BREAKEND'+IntToStr(i+1),StrToTime('13:00'));
    BreakTime[i].EndTm:=IncMinute(StartOfTheDay(now),MinuteOfTheDay(BreakTime[i].EndTm));;
  end;
  RedgProcBad:=IniFile.ReadFloat('FAULT','PROCBAD',5);
  RedgProcNorm:=IniFile.ReadFloat('FAULT','PROCNORM',3);
  OTK1cntPay:=IniFile.ReadFloat('PAY','OTK1CNTPAY',0);
  OTK2cntPay:=IniFile.ReadFloat('PAY','OTK2CNTPAY',0);
  OTK1faultPay:=IniFile.ReadFloat('PAY','OTK1FAULTPAY',0);
  OTK2faultPay:=IniFile.ReadFloat('PAY','OTK2FAULTPAY',0);
  FaultBonus:=IniFile.ReadInteger('PAY','FAULTBONUS',0);
  DayBonus:=IniFile.ReadInteger('PAY','DAYBONUS',0);
  SetLength(HourBonus,0);
  str:=IniFile.ReadString('PAY','HOURBONUS','');
  while length(str)>0 do begin
    SetLength(HourBonus,high(HourBonus)+2);
    if pos(';',str)>0 then begin
      HourBonus[high(HourBonus)]:=StrToIntDef(copy(str,1,pos(';',str)-1),0);
      delete(str,1,pos(';',str));
    end else begin
      HourBonus[high(HourBonus)]:=StrToIntDef(copy(str,1,maxint),0);
      delete(str,1,maxint);
    end;
  end;
  IniFile.Free;
end;

//Инициализация переменных
procedure TMainForm.FormCreate(Sender: TObject);
var
  i   : integer;
begin
  inherited;
  //Установка текущей даты
  CurDate:=now;
  //создание структур хранения данных
  FixCodeList:=TCodeList.Create;
  ModelList:=TModList.Create;
  Logs:=TlogList.Create;
  SoundsList:=TStringList.Create;
  //созадание контролов отображения
  DayResDrg:=THorDiagram.Create(DayResPn);
  PayDgr:=TDiagram.Create(self.PayDgrPn);
  self.PayDgrPn.InsertControl(PayDgr);
  self.PayDgrPn.DoubleBuffered:=true;
  MainDgr:=TDiagram.Create(self.MainDgrPn);
  self.MainDgrPn.InsertControl(maindgr);
  self.MainDgrPn.DoubleBuffered:=true;
  //инициализация перемеменных
  self.LoadMainIni;
  //настройка видимости кнопок
  ExitBtn.Visible:=not HideButtons;
  PersonCntBtn.Visible:=not HideButtons;
  //Расчет временных интервалов учета рез производства
  SetPrdList;
  //время последнего озвученного кода устанавливаем в начало дня
  LastCodeTime:=StartOfTheDay(now);
  //Начальные параметры даиграммы произоводит за смену
  DayResDrg.Align:=alClient;
  DayResDrg.BadSpeed:=SpeedBad;
  DayResDrg.MdlSpeed:=SpeedNormal;
  DayResDrg.NrmSpeed:=SpeedGood;
  DayResPn.InsertControl(DayResDrg);
  //начальные параметры диаграмы почасовой производстильности
  MainDgr.Align:=alClient;
  MainDgr.Bevel:=0.3;
  MainDgr.Val1Color:=clGray;
  MainDgr.Val2Color:=clGreen;
  MainDgr.Val3Color:=clRed;
  MainDgr.BadSpeed:=SpeedBad;
  MainDgr.MdlSpeed:=SpeedNormal;
  MainDgr.NrmSpeed:=SpeedGood;
  for I := 0 to high(PrdList) do
    MainDgr.AddColumn(FormatDateTime('hh:mm',PrdList[i].StTm),
      FormatDateTime('hh:mm',PrdList[i].EndTm),0,0,0);
  //начальные параметры диаграммы заработка
  PayDgr.Font.Size:=6;
  PayDgr.Align:=alRight;
  PayDgr.Bevel:=0.3;
  PayDgr.Val1Color:=clGray;
  PayDgr.Val2Color:=clGreen;
  PayDgr.Val3Color:=clRed;
  PayDgr.BadSpeed:=SpeedBad;
  PayDgr.MdlSpeed:=SpeedNormal;
  PayDgr.NrmSpeed:=SpeedGood;
  PayDgr.AddColumn('Заработок','смены',0,0,0);
  //
  FaultTablePn.DoubleBuffered:=true;
  TablePn.DoubleBuffered:=true;
  SG.DoubleBuffered:=true;
  ModelPn.DoubleBuffered:=true;
  //включение первого экрана из списка
  ViewCurInd:=0;
  self.UpdateMainData(ViewList[ViewCurInd]);
  Pages.PageIndex:=1;
  self.MainTimer.Enabled:=true;
  //выключение курсора
  if true then begin
    i := ShowCursor(True);
    while i >= 0 do i := ShowCursor(False);
  end;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    112 : self.UpdateMainData(vwDiagram);
    113 : self.UpdateMainData(vwTable);
    114 : self.UpdateMainData(vwFaultTable);
    119 : OTKPayForm.ShowModal;
    120 : self.SetEmployCount;
    121 : Halt(10);
  end;
end;

//Чтение записей из файлов и обновление основных данных
procedure TMainForm.UpdateMainData(viewname:string);
var
  i,tm   : integer;
  pl,res : integer;
begin
  LockWindowUpdate(self.Handle);
  FixCodeList.LoadFromFile(FixCodeFileName);
  ModelList.LoadFromFile(ModFileName);
  Logs.Clear;
  if FileExists(LogFileName) then Logs.LoadFromFile(LogFileName,0);
  //расчет процента брака
  FaultProc:=TotalGoods+FixCodeBetween(0);
  if FaultProc>0 then FaultProc:=FixCodeBetween(0)/FaultProc*100;
  //Обновление верхней панели
  SetPlanCnt;
  //вычисление дневгого плана
  pl:=0;
  for I := 0 to high(prdlist) do pl:=pl+round(MainPlan[i]);
  //Обновление диаграммы производительности за день
  if Logs.Count>0 then
    DayResDrg.SetValue(pl,TotalGoods,0) else DayResDrg.SetValue(0,0,0);
  if (DayBonus>0)and(TotalGoods>=pl) then DayBonusSum:=DayBonus else DayBonusSum:=0;
  DayResDrg.Bonus:=round(DayBonusSum);
  DayResDrg.Refresh;
  self.TopPn.Repaint;
  //инидикатор времени на операцию. Расчет макс времени
  tm:=SecondsBetween(DayTime.EndTm,now);
  for I := 0 to high(BreakTime) do
    if BreakTime[i].StTm>now then tm:=tm-SecondsBetween(BreakTime[i].EndTm,BreakTime[i].StTm)
      else if BreakTime[i].EndTm>now then tm:=tm-SecondsBetween(BreakTime[i].EndTm,now);
  if (PlanEndOfTheDay(now))>0 then tm:=round(tm/PlanEndOfTheDay(now))else tm:=DefTempMax;
  TempMax:=tm;
  //Обновление диаграммы почасовой произоводительности
  //подсчет премии за выполенение плана за час
  HourBonusSum:=0;
  for i := 0 to high(prdlist) do begin
    //вычисялем планову цифру и фактич производство
    pl:=round(MainPlan[i]);
    res:=TotalGoods(-1,PrdList[i].sttm,PrdList[i].endtm);
    MainDgr.ChangeValue(i,1,pl);
    MainDgr.ChangeValue(i,2,res);
    MainDgr.ChangeValue(i,3,FixCodeBetween(0,-1,PrdList[i].sttm,PrdList[i].endtm));
    //Если план за час больше нуля и произведелно больше плана добавляем бонус
    if (pl>0)and(pl<=res)and(i<=high(HourBonus)) then begin
      MainDgr.ChangeBonus(i,HourBonus[i]);
      HourBonusSum:=HourBonusSum+HourBonus[i];
    end else MainDgr.ChangeBonus(i,0);
  end;
  //расчет премии за процент брака
  FaultBonusSum:=FaultBonus/(RedgProcBad-RedgProcNorm)*(RedgProcBad-FaultProc);
  if FaultBonusSum<0 then FaultBonusSum:=0;
  RedgPB.Refresh;
  //выделение текущего часа
  i:=0;
  while(i<=high(PrdList))and(not((now>=PrdList[i].StTm)and(now<PrdList[i].EndTm)))do inc(i);
  if(i<=high(PrdList))and((now>=PrdList[i].StTm)and(now<PrdList[i].EndTm))then
    MainDgr.CurColInd:=i else MainDgr.CurColInd:=-1;
  //определение тек скор производства за последние SpeedInterval минут
  tm:=0;
  i:=0;
  while(i<=high(BreakTime))and(tm=0)do
    if (now>=BreakTime[i].StTm)and(now<=IncMinute(BreakTime[i].EndTm,SpeedInterval)) then tm:=1
      else inc(i);
  if tm=0 then begin
    MainDgr.CurSpeed:=CodeBetween('',-1,IncMinute(now,-SpeedInterval),now)/(SpeedInterval*60/TempMax);
    if MainDgr.CurSpeed<=SpeedBad then MsgStr:=msgSpeedVeryBad;
    if (MainDgr.CurSpeed<=SpeedNormal)and(MainDgr.CurSpeed>SpeedBad) then MsgStr:= msgSpeedBad;
    if (MainDgr.CurSpeed>SpeedNormal)and((MsgStr=msgSpeedVeryBad)or(MsgStr=msgSpeedBad)) then MsgStr:='';
  end else MsgStr:='';
  //обновление диаграммы заработка смены
  //вычисляем сколько денег еще можно заработать
  if now<DayTime.EndTm then begin
    if Logs.Count>0 then
      i:=round(ModelList.Model[Logs.Item[Logs.Count-1].ModInd].price*PlanEndOfTheDay(now))
    else i:=round(ModelList.Model[0].price*PlanEndOfTheDay(now));
    i:=i+round(TotalPay);
  end else i:=round(TotalPay);
  //складываем с уже заработанной суммой
  PayDgr.ChangeValue(0,1,i);
  PayDgr.ChangeValue(0,2,round(ToTalPay));
  //Обновление панели неисправностей
  self.FaultTableUpdate;
  self.TotalFaultPB.Repaint;
  //Таблица результатов производства
  self.TablePB.Repaint;
  self.TotalPayPB.Repaint;
  //если задано имя вида - меняем вид
  if length(viewname)>0 then begin
    if (viewname=vwDiagram)and(Pages.ActivePage<>vwDiagram) then begin
        Pages.PageIndex:=1;
        ViewLastCng:=now;
       end;
    if (viewname=vwTable)and(Pages.ActivePage<>vwTable) then begin
        Pages.PageIndex:=2;
        ViewLastCng:=now;
       end;
    if (viewname=vwFaultTable)and(Pages.ActivePage<>vwFaultTable)
      and(FixCodeBetween(0)>0) then begin
        Pages.PageIndex:=0;
        ViewLastCng:=now;
       end;
  end;
  LockWindowUpdate(0);
end;

//Запись файла статистики
procedure TMainForm.SaveStatLog;
var
  str   : string;
  Strs  : TstringList;
  i,cnt : integer;
  FName : string;
  Last  : TDateTime;
begin
  if Length(StatLogDir)>0 then begin
    FName:=StatLogDir+FormatDateTime('ddmmyy',now)+'.txt';
    Strs:=TStringList.Create;
    //Cчитаем что файл не существует и перезаписываем его от начала до конца
    Last:=StartOfTheDay(now);
    if EmployCount=0 then cnt:=DefEmployCount else cnt:= EmployCount;
    for i := 0 to Logs.Count - 1 do
      if (Logs.Item[i].DtTm>Last) then begin
       if Logs.Item[i].Goods then
        str:=DateTimeTostr(Logs.Item[i].DtTm)+chr(9)+'100'+chr(9)+
          ModelList.Model[Logs.Item[i].ModInd].name+
          chr(9)+chr(9)+IntToStr(cnt)
       else if (FixCodeList.IndByCode(Logs.Item[i].code)>=0)and
        (FixCodeList.Item[FixCodeList.IndByCode(Logs.Item[i].code)].group=0) then
        str:=DateTimeTostr(Logs.Item[i].DtTm)+chr(9)+
          FixCodeList.Item[FixCodeList.IndByCode(Logs.Item[i].code)].note+chr(9)+
          ModelList.Model[Logs.Item[i].ModInd].name+
          chr(9)+chr(9)+IntToStr(cnt);
      //вывод премий    
      str:=str+chr(9)+FormatFloat('####0.00',HourBonusSum+DayBonusSum+FaultBonusSum)+
        chr(9)+FormatFloat('####0.00',HourBonusSum)+
        chr(9)+FormatFloat('####0.00',DayBonusSum)+
        chr(9)+FormatFloat('####0.00',FaultBonusSum);
      if Length(str)>0 then Strs.Add(str);
    end;
    //сохраняем файл
    if Strs.Count>0 then Strs.SaveToFile(fname);
  end;
end;

//Таймер одна секунда
procedure TMainForm.MainTimerTimer(Sender: TObject);
var
  i,j,tm : integer;
  str    : string;
begin
  //Сигнализатор скорости работы
  if TempPos>-1 then begin
    if (TempPos<TempMax) then begin
      inc(TempPos);
      if (((TempMax-TempPos)=3))and(SoundsList.Count=0) then
        SoundsList.Add(sndBeep);
    end;
    TempPb.Repaint;
  end;
  //Перерисовка часов ежесекундно
  ClockPB.Repaint;
  //Перерисовка в полночь
  if SecondsBetween(now,StartOfTheDay(now))=1 then begin
    self.LoadMainIni;
    self.SetEmployCount(0);
    LogFileName:='';
    SetPrdList;
    self.UpdateMainData;
  end;
  //Смена экранов через ViewCngTime секунд
  if (ViewCngTime>0)and(SecondsBetween(now,ViewLastCng)>=ViewCngTime) then begin
    inc(ViewCurInd);
    if ViewCurInd>high(ViewList) then ViewCurInd:=0;
    self.UpdateMainData(ViewList[ViewCurInd]);
  end;
  //оповещения один раз в минуту
  if trunc(SecondOfTheDay(now)/60)=(SecondOfTheDay(now)/60) then begin
    //MsgStr :='';
    //о перерывах --------------------------------------------------------------
    for I := 0 to high(BreakMsgTime) do
      for j := 0 to high(BreakTime) do begin
        //о начале перерывов
        tm:=(MinuteOfTheDay(BreakTime[j].StTm)-MinuteOfTheDay(now));
        //звуковое оповещение ровно за N-минут
        if tm=BreakMsgTime[i] then
          case BreakMsgTime[i] of
            15 : begin
                 self.AddInSoundList(sndBreakStartAfter);
                 self.AddInSoundList(snd15min);
                 end;
            10 : begin
                 self.AddInSoundList(sndBreakStartAfter);
                 self.AddInSoundList(snd10min);
                 end;
             5 : begin
                 self.AddInSoundList(sndBreakStartAfter);
                 self.AddInSoundList(snd5min);
                 end;
             0 : self.AddInSoundList(sndBreakStart);
          end;
        //текстовое оповещение
        if (tm>0)and(tm<=BreakMsgTime[i])then MsgStr:='До начала перерыва менее '+
          intToStr(BreakMsgTime[i])+' минут';
        if (tm=0)then MsgStr:='НАЧАЛО ПЕРЕРЫВА';
        //о конце перерыва
        if tm<0 then begin
          tm:=(MinuteOfTheDay(BreakTime[j].EndTm)-MinuteOfTheDay(now));
          //звуковое оповещение ровно за N-минут
          if tm=BreakMsgTime[i] then
          case BreakMsgTime[i] of
            15 : begin
                 self.AddInSoundList(sndBreakEndAfter);
                 self.AddInSoundList(snd15min);
                 end;
            10 : begin
                 self.AddInSoundList(sndBreakEndAfter);
                 self.AddInSoundList(snd10min);
                 end;
             5 : begin
                 self.AddInSoundList(sndBreakEndAfter);
                 self.AddInSoundList(snd5min);
                 end;
             0 : self.AddInSoundList(sndBreakEnd);
          end;
          //текстовое оповещение
          if (tm>0)and(tm<=BreakMsgTime[i])then MsgStr:='До конца перерыва менее '+
            intToStr(BreakMsgTime[i])+' минут';
          if (tm=0)then MsgStr:='КОНЕЦ ПЕРЕРЫВА';
        end;
      end;
    //о начале рабочего дня ----------------------------------------------------
    tm:=(MinuteOfTheDay(DayTime.StTm)-MinuteOfTheDay(now));
    if tm=0 then begin
      self.AddInSoundList(sndDayStart);
      MsgStr:='НАЧАЛО РАБОЧЕГО ДНЯ';
      if EmployCount=0 then self.SetEmployCount;
    end;
    //о конце рабочего дня -----------------------------------------------------
    for I := 0 to high(BreakMsgTime) do begin
      tm:=(MinuteOfTheDay(DayTime.EndTm)-MinuteOfTheDay(now));
      //звуковое оповещение ровно за N-минут
      if tm=BreakMsgTime[i] then
          case BreakMsgTime[i] of
            15 : begin
                 self.AddInSoundList(sndDayEndAfter);
                 self.AddInSoundList(snd15min);
                 end;
            10 : begin
                 self.AddInSoundList(sndDayEndAfter);
                 self.AddInSoundList(snd10min);
                 end;
             5 : begin
                 self.AddInSoundList(sndDayEndAfter);
                 self.AddInSoundList(snd5min);
                 end;
             0 : self.AddInSoundList(sndDayEnd);
          end;
      //текстовое оповещение
      if (tm>0)and(tm<=BreakMsgTime[i])then MsgStr:='До конца рабочего дня менее '+
        intToStr(BreakMsgTime[i])+' минут';
      if (tm=0)then MsgStr:='КОНЕЦ РАБОЧЕГО ДНЯ';
    end;
    //о длительном простое -----------------------------------------------------
    i:=0;
    while (i<=high(BreakTime))and
      (not((now>=BreakTime[i].StTm)
        and(now<=incMinute(BreakTime[i].EndTm,StopTimeMax)))) do inc(i);
    if (i>high(BreakTime))
      and(now>DayTime.StTm)and(now<DayTime.EndTm)
      and(Logs.Count>0)and(MsgStr<>msgLongStop)
      and(now>Logs.Item[Logs.Count-1].DtTm)
      and(MinutesBetween(now,Logs.Item[Logs.Count-1].DtTm)>StopTimeMax)
      and(MsgStr<>msgLongStop) then begin
        self.AddInSoundList(sndDing);
        self.AddInSoundList(sndLongStop);
        MsgStr:=msgLongStop;
      end;
    //
    MsgPB.Repaint;
  end;
  //звуки
  if(SoundsList.Count>0)and(sndPlaySound(nil,SND_NOSTOP)) then begin
      str:=ExtractFilePath(application.ExeName)+'sounds\'+SoundsList[0];
      if FileExists(str) then sndPlaySound(PChar(str),SND_ASYNC);
      SoundsList.Delete(0);
    end;
end;

//-------------------- отрисовка элементов формы -------------------------------

//Рисуем время
procedure TMainForm.ClockPBPaint(Sender: TObject);
const
  rctsep=0.7;
var
  Tm    : string;
  rct   : trect;
begin
  with (sender as TPaintBox) do begin
    rct:=ClientRect;
    rct.Bottom:=round(rct.Bottom*RctSep);
    if Trunc(CurDate)=Trunc(now) then tm:=FormatDateTime('hh:mm:ss',now)
      else tm:='---';
    canvas.Font.Style:=[fsBold];
    DrawTextToRect(canvas,tm,rct);
    rct:=ClientRect;
    rct.Top:=round(rct.Bottom*RctSep);
    tm:=FormatDateTime('dd mmmm (ddd)',CurDate);
    canvas.Font.Style:=[];
    DrawTextToRect(canvas,tm,rct);
    end;
end;

//Рисуем текстовое сообщение на нижней панели
procedure TMainForm.MsgPBPaint(Sender: TObject);
var
  hg:integer;
  rct : Trect;
begin
  with (sender as TPaintBox) do begin
    canvas.Font.Style:=[fsBold];
    hg:=round(ClientHeight/2);
    rct:=ClientRect;
    rct.Top:=rct.Top+round(hg/2);
    rct.Bottom:=rct.Top+hg;
    DrawTextToRect(Canvas,msgstr,rct);
  end;
end;

//Рисуем брак
procedure TMainForm.RedgPBPaint(Sender: TObject);
const
  rctsep=0.3;
var
  str   : string;
  rct   : trect;
  sz    : integer;
begin
  with (sender as TPaintBox) do begin
    rct:=ClientRect;
    rct.Bottom:=round(rct.Bottom*RctSep);
    str:='Премия: '+FormatFloat('##0.00',FaultBonusSum)+' руб';
    canvas.Font.Style:=[fsBold];
    canvas.Font.Color:=clFuchsia;
    DrawTextToRect(canvas,str,rct);
    rct:=ClientRect;
    rct.Top:=round(rct.Bottom*RctSep);
    //придание зоне отображения круглой формы
    {if (rct.Right-rct.Left)>(rct.Bottom-rct.Top) then begin
      rct.Left:=rct.Left+round((rct.Right-rct.Left-rct.Bottom+rct.Top)/2);
      rct.Right:=rct.Left+(rct.Bottom-rct.Top);
      end; }
    str:=FormatFloat('##0.00',FaultProc)+' %';
    canvas.Pen.Width:=2;
    canvas.Brush.Style:=bsSolid;
    if FaultProc<=RedgProcNorm then begin
      canvas.Font.Color:=clYellow;
      canvas.Pen.Color:=clYellow;
      canvas.Brush.Color:=clGreen;
    end;
    if (FaultProc>RedgProcNorm)and(FaultProc<RedgProcBad) then begin
      canvas.Font.Color:=clBlack;
      canvas.Pen.Color:=clRed;
      canvas.Brush.Color:=clYellow;
    end;
    if (FaultProc>=RedgProcBad) then begin
      canvas.Font.Color:=clBlack;
      canvas.Pen.Color:=clGreen;
      canvas.Brush.Color:=clRed;
    end;
    sz:=round((rct.Right-rct.Left)*0.1);
    inc(rct.Left,sz);
    dec(rct.Right,sz);
    canvas.ellipse(rct);
    canvas.Font.Style:=[fsBold];
    sz:=round((rct.Bottom-rct.Top)*0.2);
    inc(rct.Top,sz);
    dec(rct.Bottom,sz);
    DrawTextToRect(canvas,str,rct);
    end;
end;

procedure TMainForm.SelectDateBtnClick(Sender: TObject);
var
  str     : string;
  IniFile : TIniFile;
  d,m,y,i : word;
begin
  if OpenDlg.Execute then begin
    str:=OpenDlg.FileName;
    if (FileExists(str)) then begin
      //fl:=true;
      LogFileName:=str;
      IniFile:=TIniFile.Create(ExtractFilePath(application.exename)+'\mainset.ini');
      inifile.WriteString('MAIN','LOGFILENAME',LogFileName);
      IniFile.Free;
      str:=ExtractFileName(str);
      d:=StrToIntDef(copy(str,1,2),1);
      m:=StrToIntDef(copy(str,3,2),1);
      str:=copy(str,5,pos('.txt',str)-5);
      if Length(str)=2 then y:=2000+StrToIntDef(str,16)
        else y:=StrToIntDef(str,2016);
      changedate(d,m,y);
      for i := 0 to high(prdlist) do MainDgr.ChangeBonus(i,0);
      self.UpdateMainData;
    end;
  end;
end;

//Заголовок панели почасовой производительности
procedure TMainForm.MyDiagramCaptionPBPaint(Sender: TObject);
begin
  with (sender as TPaintBox) do begin
    canvas.Font.Style:=[fsBold];
    canvas.Font.Color:=clWhite;
    DrawTextToRect(Canvas,'Производство по часам:',ClientRect,1);
    end;
end;

//Таблица производства
procedure TMainForm.TablePBPaint(Sender: TObject);
const
  MaxRowCnt=9;
  FrstColW=2;
var
  c,r,colcnt,rowcnt : integer;
  ColW,RowH,Marg,lt,tp  : integer;
  rct,txtrct : Trect;
  txt        : WideString;
  AsmModels  : TStringList;
begin
  //Определение общих параметров
  ColCnt:=5;   //количество строк
  AsmModels:=TstringList.Create;
  RowCnt:=AsemblModelList(AsmModels)+1;   //кол-во строк (мин 1)
  with (sender as TPaintBox) do begin
  Marg:=90;    //процент ширины таблицы от общей ширины экрана
  RowH:=round(ClientHeight/RowCnt); //высота строки
  Marg:=round((ClientWidth-ClientWidth*Marg/100)/2); //отсупы справа и слева
  ColW:=round((ClientWidth-Marg*2)/(ColCnt+FrstColW-1)); //ширина стобца
  if RowH>ColW then RowH:=round(ColW*0.75);
  //Рисование таблицы
  tp:=0;
  for r := 0 to RowCnt - 1 do
    begin
      rct.Top:=tp;
      if r=0 then tp:=tp+round(ClientHeight/MaxRowCnt) else tp:=tp+RowH-Canvas.Pen.Width;
      rct.Bottom:=tp;
      lt:=Marg;
      for c := 0 to ColCnt - 1 do
        begin
          Canvas.Pen.Width:=2;
          Canvas.Pen.Color:=clWhite;
          Canvas.Font.Style:=[];
          Canvas.Font.Color:=clSilver;
          rct.Left:=lt;
          //первый столбец - модель - более широкий, выравнивание по левому краю
          if c=0 then lt:=lt+FrstColW*ColW else lt:=lt+ColW;
          lt:=lt-Canvas.Pen.Width;
          // нулевая строка - заголовок - заполняем
          if r=0 then
              case c of
                0: txt:='Модель';
                3: txt:='Еще возмож';
                1: txt:='Произв-во';
                2: txt:='Брак';
                4: txt:='Сумма, руб';
              end;
          // нулевая строка - заголовок - заполняем
          if (r>0) then
              begin
                case c of
                  0: txt:=ModelList.Model[StrToInt(AsmModels[r-1])].name;
                  3: if StrToInt(AsmModels[r-1])=Logs.Item[Logs.Count-1].ModInd then
                    txt:=FormatFloat('00000',PlanEndOfTheDay(now)) else txt:=' ';
                  1: txt:=FormatFloat('00000',TotalGoods(StrToInt(AsmModels[r-1])));
                  2: txt:=FormatFloat('00000',FixCodeBetween(0,StrToInt(AsmModels[r-1])));
                  4: txt:=FormatFloat('00000',TotalGoods(StrToInt(AsmModels[r-1]))*
                    ModelList.Model[StrToInt(AsmModels[r-1])].price);  
                end;
                Canvas.Font.Style:=[fsBold];
                if StrToInt(AsmModels[r-1])=Logs.Item[Logs.Count-1].ModInd then Canvas.Font.Color:=clRed;
              end;
          // рисование ячеек
          rct.Right:=lt;
          Canvas.Rectangle(rct);
          rct.Left:=rct.Left+Canvas.Pen.Width*3;
          rct.Right:=rct.Right-Canvas.Pen.Width*3;
          txtrct:=rct;
          txtrct.Top:=txtrct.Top+Canvas.Pen.Width;
          txtrct.Bottom:=txtrct.Bottom-Canvas.Pen.Width;
          if (r=0)or((r>0)and(c>0)) then DrawTextToRect(Canvas,txt,txtrct,0)
            else DrawTextToRect(Canvas,txt,txtrct,1);
        end;
    end;
  end;
end;

procedure TMainForm.TablePnClick(Sender: TObject);
begin

end;

//Индикатор скорости работы
procedure TMainForm.TempPBPaint(Sender: TObject);
var
  rct,rct1     : Trect;
  X3Pnt, X4Pnt : TPoint;
  R, ang       : Integer;
  modname      : string;
begin
  if TempPos>-1 then with (sender as TPaintBox) do begin
    //внешний круг
    Canvas.Brush.Style:=bsSolid;
    rct1:=ClientRect;
    rct1.Top:=round(rct1.Bottom*0.25);
    dec(rct1.Bottom,10);
    rct:=rct1;
    rct.Left:=round((rct.Right-rct.Left-rct.Bottom+rct.Top)/2);
    rct.Right:=rct.Right-rct.Left;
    Canvas.Pen.Width:=2;
    Canvas.Pen.Color:=clWhite;
    Canvas.Ellipse(rct);
    //сектор
    if (TempMax>0)then begin
      inc(rct.Top,4);
      inc(rct.Left,4);
      dec(rct.Right,4);
      dec(rct.Bottom,4);
      Canvas.Pen.Width:=1;
      ang:=round(TempPos*360/TempMax);
      if ang<360 then begin
          Canvas.Brush.Color:=clGreen;
          R:=round((rct.Right-rct.Left)/2);
          X4Pnt.X:=round((rct.Right-rct.Left)/2+rct.Left);
          X4Pnt.Y:=round((rct.Bottom-rct.Top)/2-r*cos(DegToRad(0)));
          X3Pnt.X:=round((rct.Right-rct.Left)/2+rct.Left+r*sin(DegToRad(ang)));
          X3Pnt.Y:=round((rct.Bottom-rct.Top)/2+rct.Top-r*cos(DegToRad(ang)));
          Canvas.Pie(rct.Left,rct.Top,rct.Right,rct.Bottom,
            X3Pnt.X,X3Pnt.Y,X4Pnt.X,X4Pnt.Y);
        end else begin
          if (SecondOfTheDay(now) and 1)=0 then Canvas.Brush.Color:=clRed
           else Canvas.Brush.Color:=clYellow;
          Canvas.Ellipse(rct);
        end;
      //цифры оставшегося времени
      Canvas.Brush.Style:=bsClear;
      rct:=rct1;
      r:=round((rct.Bottom-rct.Top)*0.25);
      inc(rct.Top,r);
      inc(rct.Left,r);
      dec(rct.Right,r);
      dec(rct.Bottom,r);
      if (TempMax-TempPos)>0 then
        DrawTextToRect(Canvas,IntToStr(TempMax-TempPos),rct,0)
        else DrawTextToRect(Canvas,'!',rct,0);
    end;
    //наименование модели
    rct:=ClientRect;
    Canvas.Brush.Style:=bsClear;
    if Logs.Count>0 then modname:= ModelList.Model[Logs.Item[Logs.Count-1].ModInd].name
        else modname:='';
    rct.Bottom:=round(Rct.Bottom*0.4);
    if Length(modname)>0 then DrawTextToRect(Canvas,modname,rct);
  end;
end;

//Текстовое сообщение о заработке сборщика
procedure TMainForm.TotalPayPBPaint(Sender: TObject);
var
  txt:string;
begin
  txt:='Примерный заработок сборщика: '+FormatFloat('####0.00',OneEmployPay)+' руб';
  with (sender as TPaintBox)do begin
    DrawTextToRect(Canvas,txt,ClientRect,0);
  end;
end;

//Заголовок таблицы неисправностей
procedure TMainForm.FaultCaptionPBPaint(Sender: TObject);
begin
  DrawTextToRect(FaultCaptionPB.Canvas,
    'Количество брака по часам:',
    FaultCaptionPB.ClientRect,1);
end;

//Текстовое сообщение об общем количистве брака
procedure TMainForm.TotalFaultPBPaint(Sender: TObject);
var
  str : string;
begin
    str:='Общий процент брака: ';
    str:=str+FormatFloat('##0.00',FaultProc)+ ' %';
    if FaultProc<=RedgProcNorm then TotalFaultPB.canvas.Font.Color:=clSilver;
    if (FaultProc>RedgProcNorm)and(FaultProc<=RedgProcBad) then TotalFaultPB.canvas.Font.Color:=clYellow;
    if (FaultProc>RedgProcBad) then TotalFaultPB.canvas.Font.Color:=clRed;
    DrawTextToRect(TotalFaultPB.Canvas,str,TotalFaultPB.ClientRect);
end;

//заполнение таблицы неисправностей
procedure TMainForm.FaultTableUpdate;
const
  FirstColWdth=10;
  LastColWdth=8;
var
  CodeList : TStringList;
  i,j,cnt  : integer;
  str      : string;
begin
  //Подготовка данных для таблицы
  CodeList:=TStringList.Create;
  //подсчитываем количество фиксированных кодов группы
  for I := 0 to Logs.Count - 1 do
    if (Logs.Item[i].Goods=false)and((FixCodeList.IndByCode(Logs.Item[i].code)>=0)
       and(FixCodeList.Item[FixCodeList.IndByCode(Logs.Item[i].code)].group=0))
       then begin
        j:=0;
        while(j<CodeList.Count)and(CodeList.Names[j]<>Logs.Item[i].code)do inc(j);
        if(j<CodeList.Count)and(CodeList.Names[j]=Logs.Item[i].code)then begin
          cnt:=StrToIntDef(CodeList.Values[CodeList.Names[j]],1);
          inc(cnt);
          CodeList.Values[CodeList.Names[j]]:=IntToStr(cnt);
        end else
          CodeList.Add(Logs.Item[i].code+'=1');
       end;
  //сортировка по убыванию
  for i:=1 to CodeList.Count do
    for j:=0 to CodeList.Count-1-i do
      if StrToInt(CodeList.Values[CodeList.Names[j]])<
        StrToInt(CodeList.Values[CodeList.Names[j+1]]) then begin {Обмен элементов}
        str:=CodeList[j];
        CodeList[j]:=CodeList[j+1];
        CodeList[j+1]:=str;
      end;
  //Заполнение таблицы
  if CodeList.Count>0 then begin
    SG.Visible:=true;
    //Шапка
    SG.RowCount:=CodeList.Count+1;
    SG.ColCount:=high(PrdList)+4;
    SG.Cells[0,0]:='Неисправность';
    SG.Cells[1,0]:='Всего';
    for I := 0 to high(PrdList) do
      SG.Cells[i+2,0]:=FormatDateTime('hh:mm',PrdList[i].StTm)+' '+
      FormatDateTime('hh:mm',PrdList[i].EndTm);
    SG.Cells[SG.ColCount-1,0]:='Примечание';
    //Определение ширины столбцов
    j:=round(SG.ClientWidth/(SG.ColCount-2+FirstColWdth+LastColWdth));
    cnt:=0;
    for i := 0 to SG.ColCount - 2 do begin
      SG.ColWidths[i]:=j;
      if i=0 then SG.ColWidths[i]:=SG.ColWidths[i]*FirstColWdth;
      cnt:=cnt+SG.ColWidths[i];
    end;
    SG.ColWidths[SG.ColCount-1]:=SG.ClientWidth-cnt-SG.ColCount;
    //Орпделение высоты строк
    //j:=round(SG.ClientHeight/6)-2;
    j:=round(SG.ClientHeight/SG.RowCount)-2;
    // if CodeList.Count<5 then SG.RowCount:=CodeList.Count+1 else SG.RowCount:=6;
    for I := 0 to SG.RowCount - 1 do SG.RowHeights[i]:=j;
    //Заполение строк
    for I := 0 to SG.RowCount - 2 do
      if i<CodeList.Count then begin
        SG.Cells[0,i+1]:=FixCodeList.Item[FixCodeList.IndByCode(CodeList.Names[i])].name;
        SG.Cells[1,i+1]:=CodeList.Values[CodeList.Names[i]];
        for j := 0 to high(PrdList) do begin
          cnt:=CodeBetween(CodeList.Names[i],-1,PrdList[j].StTm,PrdList[j].EndTm);
          if cnt>0 then SG.Cells[j+2,i+1]:=IntToStr(cnt) else SG.Cells[j+2,i+1]:='';
        end;
      end else SG.Rows[i+1].Clear;
    TotalFaultPB.Repaint;
  end else begin
    SG.Visible:=false;
    FaultTablePN.Caption:='Данных о браке нет !';
    DrawTextToRect(TotalFaultPB.Canvas,' ',TotalFaultPB.ClientRect);
  end;
end;

//ячейки таблицы неисправностей
procedure TMainForm.SGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  txt,str : string;
  rct:TRect;
  i       : integer;
begin
  txt:=SG.Cells[ACol,Arow];
  SG.Canvas.Rectangle(rect);
  if ARow=0 then
    if pos(' ',txt)<>0 then begin
      str:=copy(txt,1,pos(' ',txt)-1);
      rct:=rect;
      rct.Bottom:=round(rct.Top+(rct.Bottom-rct.Top)/2);
      inc(rct.Left,2);
      dec(rct.Right,2);
      DrawTextToRect(SG.Canvas,str,rct);
      str:=copy(txt,pos(' ',txt)+1,MaxInt);
      rct:=rect;
      rct.top:=round(rct.Top+(rct.Bottom-rct.Top)/2);
      inc(rct.Left,2);
      dec(rct.Right,2);
      DrawTextToRect(SG.Canvas,str,rct);
    end else begin
      rct:=rect;
      i:=(rct.Bottom-rct.Top);
      rct.Top:=round(rct.Top+i*0.3);
      rct.Bottom:=round(rct.Bottom-i*0.3);
      inc(rct.Left,2);
      dec(rct.Right,2);
      DrawTextToRect(SG.Canvas,txt,rct);
    end else begin
      if Length(txt)=0 then txt:=' ';
      rct:=rect;
      i:=(rct.Bottom-rct.Top);
      rct.Top:=round(rct.Top+i*0.3);
      rct.Bottom:=round(rct.Bottom-i*0.3);
      inc(rct.Left,2);
      dec(rct.Right,2);
      if (ACol=0)or(ACol=SG.ColCount-1) then DrawTextToRect(SG.Canvas,txt,rct,1)
        else DrawTextToRect(SG.Canvas,txt,rct)
    end;
end;

end.
