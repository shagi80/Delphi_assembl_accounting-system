unit DataUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DateUtils, FixCodeUnit;

const
  DefEmployCount=23;   //количество персонала в смене по умолчанию

type
  TTimeRecord = record
    StTm,EndTm : TDateTime;
    ModInd     : integer;
  end;

  TTimeRecList = array of TTimeRecord;

  TModRecord = record     //запись о единичной моделе
    ind   : byte;         //индекс согласно программы штрих-кодирования
    name  : string;       //наименование
    price : real;         //ставка за сборку
    norm  : real;         //норма
  end;

  TLogRecord = record    //запись о единичном коде в общем списке
    //получаемые из файла
    code   : string;     //код
    scnum  : integer;    //номер сканера
    DtTm   : TDateTime;  //время и дата записи кода
    //определяемые при обработке
    ModInd : integer;    //индекс модели
    Goods  : boolean;    //признак готовой продукции
  end;

  TLogList = class                    //Общий список кодов
    private
      FCount  : integer;
      Fitem   : array of TLogRecord;
      FUnic   : boolean;              //провека кода на уникаольность в теч дня
      FPaused : integer;              //пауза ввода с одного сканера
      function GetItem(ind:integer):TLogRecord;
    public
      property Count       : integer read FCount;
      property CodeUnic    : boolean read FUnic write FUnic;
      property InputPaused : integer read FPaused write FPaused;
      property Item[ind:integer] : TLogRecord read GetItem;
      function IndByCode(code:string):integer;
      constructor Create;
      procedure LoadFromFile(fname:string; DefModInd:integer);
      procedure LoadFromStatLog(fname: string; DefModInd:integer);
      procedure Clear;
    end;

  TModList = class                    //список моделей
    private
      FCount  : integer;
      Fitem   : array of TModRecord;
      function GetModelByInd(ind:integer):TModRecord;
    public
      property Count : integer read FCount;
      property Model[ind:integer]:TModRecord read GetModelByInd;
      constructor Create;
      function GetListInd(index:byte):integer;
      procedure LoadFromFile(fname: string);
  end;

  TDataModule1 = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1 : TDataModule1;
  Logs        : TLogList;            //список штрих-кодов
  FixCodeList : TCodeList;           //список фиксированных кодов
  ModelList   : TModList;            //список моделей
  DayTime     : TTimeRecord;         //начало и окончание рабочего дня
  BreakTime   : TTimeRecList;        //начало и окончание перерывов
  PrdList     : TTimeRecList;        //временные интервалы учета производства
  AlingHour   : boolean;             //округление временных интервалов диаграммы до часа
  BasePlan    : array [0..3] of
        integer = (90,95,100,100);   //кривая роста плановой производительности
  MainPlan    : array of real;       //плановая производительность по периодам
  EmployCount : integer=0;           //количество персонала в смене
  Bonus       : integer=0;           //размер премии за выполнение плана за час
  TotBonus    : real=0;              //общий размер премии за вып плана на 1 человека
  CurDate     : TDate;


//Универсальная процедура рисования текста в заданном прямоугольнике
procedure DrawTextToRect(cnv:TCanvas;Text:string;rct:trect;align:byte=0);
//Формирование списка индексов собранных моделей
function AsemblModelList(var IndList:TStringList):integer;
//Количество готовой продукции по модели
function TotalGoods(ModInd: integer=-1; StTm : TDateTime = 0;EndTm : TDateTime = 0):integer;
//Количество фиксированных кодов для модели за период
function FixCodeBetween(group:integer; ModInd:integer=-1; StTm : TDateTime = 0;EndTm : TDateTime = 0):integer;
//Общий заработок на текущий момент
function TotalPay:real;
//Расчет почасвого плана
procedure SetPlanCnt;
//Расчет количества, которое можно произвестидо конца дня
function PlanEndOfTheDay(tm:TdateTime):integer;
//подсчте количества определенного кода
function CodeBetween(code:string; ModInd:integer=-1;StTm : TDateTime = 0;EndTm : TDateTime = 0):integer;
//Расчет временных интервалов учета рез производства
procedure SetPrdList;
//Заработок одного сотрудника
function OneEmployPay:real;
//Изменение текущей даты в настройках периода
procedure ChangeDate(d,m,y:word);


implementation

{$R *.dfm}

//------------------ Работа с общим списком кодов ------------------------------

function TotalGoods(ModInd: integer=-1; StTm : TDateTime = 0;EndTm : TDateTime = 0):integer;
var
  i,res : integer;
begin
  res:=0;
  if StTm=0 then StTm:=StartOfTheDay(CurDate);
  if EndTm=0 then EndTm:=EndOfTheDay(CurDate);
  for I := 0 to Logs.Count - 1 do begin
    if (logs.item[i].Goods)
      and ((Logs.Item[i].ModInd=ModInd)or(ModInd=-1))
      and (CompareDateTime(Logs.Item[i].DtTm,StTm)>=0)
      and (CompareDateTime(Logs.Item[i].DtTm,EndTm)<=0) then inc(res);
  end;
  result:=res;
end;

function AsemblModelList(var IndList:TStringList):integer;
var
  i,j : integer;
begin
  for I := 0 to Logs.Count - 1 do begin
    j:=0;
    while (j<IndList.Count)and(Logs.Item[i].ModInd<>StrToInt(IndList[j])) do inc(j);
    if(j=IndList.Count)then IndList.Add(IntToStr(Logs.Item[i].ModInd));;
  end;
  result:=IndList.count;
end;

function FixCodeBetween(group:integer;ModInd:integer=-1;StTm : TDateTime = 0;EndTm : TDateTime = 0):integer;
var
  i,ind,cnt : integer;
begin
  cnt:=0;
  if StTm=0 then StTm:=StartOfTheDay(CurDate);
  if EndTm=0 then EndTm:=EndOfTheDay(CurDate);
  for I := 0 to Logs.Count - 1 do
    if (not(Logs.Item[i].Goods))
      and ((Logs.Item[i].ModInd=ModInd)or(ModInd=-1))
      and (CompareDateTime(Logs.Item[i].DtTm,StTm)>=0)
      and (CompareDateTime(Logs.Item[i].DtTm,EndTm)<=0) then begin
        ind:=FixCodeList.IndByCode(Logs.Item[i].code);
        if (ind>=0)and(FixCodeList.Item[ind].group=group) then inc(cnt);
      end;
  result:=cnt;
end;

function CodeBetween(code:string; ModInd:integer=-1;StTm : TDateTime = 0;EndTm : TDateTime = 0):integer;
var
  i,cnt : integer;
begin
  cnt:=0;
  if StTm=0 then StTm:=StartOfTheDay(CurDate);
  if EndTm=0 then EndTm:=EndOfTheDay(CurDate);
  for I := 0 to Logs.Count - 1 do
    if ((Logs.Item[i].code=code)or(length(code)=0))
      and ((Logs.Item[i].ModInd=ModInd)or(ModInd=-1))
      and (CompareDateTime(Logs.Item[i].DtTm,StTm)>=0)
      and (CompareDateTime(Logs.Item[i].DtTm,EndTm)<=0) then inc(cnt);
  result:=cnt;
end;

function TotalPay:real;
var
  Models  : TStringList;
  i       : integer;
  sum     : real;
begin
  Models:=TStringList.Create;
  AsemblModelList(Models);
  sum:=0;
  for i := 0 to Models.Count - 1 do
    sum:=sum+TotalGoods(StrToInt(Models[i]))*ModelList.Model[StrToInt(Models[i])].price;
  Models.Free;
  sum:=sum+TotBonus*EmployCount;
  result:=sum;
end;

procedure SetPlanCnt;
var
  i,j,k      : integer;
  StTm, EndTm: TDateTime;
  BaseCnt    : real;
  ModIndList : array of TPoint;
  TotTime    : real;
begin
  //Определям относительную производительность
  SetLength(MainPlan,high(PrdList)+1);
  k:=0;       //счетчик по массиву роста базовой производительности
  BaseCnt:=0; //общая сумма единиц относительной производительности
  for I := 0 to high(PrdList) do begin
    MainPlan[i]:=100; //предполагаем, что производительность за период 100%
    //Если в период попадает перерыв вычитаем из заданной базовой производительности
    //потерю производительности на время перерыва
    for j := 0 to high(BreakTime) do begin
      if (i>0)and(BreakTime[j].StTm<=PrdList[i-1].EndTm)and(BreakTime[j].StTm>=PrdList[i-1].StTm) then k:=0;
      if((BreakTime[j].StTm>=PrdList[i].StTm)and(BreakTime[j].StTm<PrdList[i].EndTm))
      or((BreakTime[j].EndTm>PrdList[i].StTm)and(BreakTime[j].EndTm<=PrdList[i].EndTm))
      then begin
        if BreakTime[j].StTm<PrdList[i].StTm then StTm:=PrdList[i].StTm else StTm:=BreakTime[j].StTm;
        if BreakTime[j].EndTm>PrdList[i].EndTm then EndTm:=PrdList[i].EndTm else EndTm:=BreakTime[j].EndTm;
        MainPlan[i]:= MainPlan[i]-MinutesBetween(EndTm,StTm)*100/60;
      end;
    end;
    //  Вычисляемв в %
    MainPlan[i]:=round(BasePlan[k]*MainPlan[i]/100);
    //снижение плана за последний час
    if i=high(PrdList) then MainPlan[i]:=round(MainPlan[i]*0.85);

    BaseCnt:=BaseCnt+MainPlan[i];
    if(MainPlan[i]>25)then inc(k);
    if k>high(baseplan) then k:=high(baseplan);
  end;
  //вычисляем производитлеьность в штуках
  SetLength(ModIndList,0);
  for i := 0 to  high(PrdList) do begin
    SetLength(ModIndList,0);
    //подсчитываем количество каждой модели за период
    for k := 0 to Logs.Count - 1 do
      if (Logs.Item[k].DtTm>=PrdList[i].StTm)and(Logs.Item[k].DtTm<PrdList[i].EndTm) then begin
        j:=0;
        while(j<=high(ModIndList))and(Logs.Item[k].ModInd<>ModIndList[j].x)do inc(j);
        if(j>high(ModIndList))then begin
          SetLength(ModIndList,high(ModIndList)+2);
          ModIndList[high(ModIndList)].x:=Logs.Item[k].ModInd;
          ModIndList[high(ModIndList)].y:=1;
        end else ModIndList[high(ModIndList)].y:=ModIndList[high(ModIndList)].y+1;
      end;
    //находим модель, которую  в этом периоде делали больше всего
    if high(ModIndList)>-1  then begin
      PrdList[i].ModInd:=0;
      for k := 1 to high(ModIndList) do
        if ModIndList[k].y>ModIndList[PrdList[i].ModInd].y then PrdList[i].ModInd:=k;
      PrdList[i].ModInd:=ModIndList[PrdList[i].ModInd].X;
    end else
      //если за период не делали ничего - используем данные
      //из предыдущего периода. Если это первый период - берем данные
      //для 0-модели
      if(i>0)then PrdList[i].ModInd:=PrdList[i-1].ModInd else PrdList[i].ModInd:=0;
    //по наимболее массовой модели считаем план
    MainPlan[i]:=MainPlan[i]*100/BaseCnt;
    if MainPlan[i]<5 then MainPlan[i]:=0;
    if EmployCount=0 then k:=DefEmployCount else k:=EmployCount;
    //вычисляем длительность раб дня с учетом перерывов
    TotTime:=MinuteSpan(DayTime.EndTm,DayTime.StTm);
    for j := 0 to high(BreakTime) do
      TotTime:=TotTime-MinuteSpan(BreakTime[j].EndTm,BreakTime[j].StTm);
    if TotTime<0 then TotTime:=0;
    TotTime:=TotTime/60;
    MainPlan[i]:=(MainPlan[i]/100*
      (ModelList.Model[PrdList[i].ModInd].norm/10.5*TotTime*k));
  end;
end;

function PlanEndOfTheDay(tm:TdateTime):integer;
var
  prd,i,cnt : integer;
begin
  cnt:=0;
  prd:=0;
  while(prd<=high(Prdlist))and(not((tm>=PrdList[prd].StTm)and(PrdList[prd].EndTm>tm)))do inc(prd);
  if tm<DayTime.StTm then prd:=0;
  if prd<=high(PrdList) then begin
    cnt:=round(MinutesBetWeen(PrdList[prd].EndTm,tm)/60*MainPlan[prd]);
    for I := prd+1 to high(MainPlan) do cnt:=cnt+round(MainPlan[i]);
  end;
  result:=cnt;
end;

procedure SetPrdList;
var
  cnt,i : integer;
begin
  cnt:=trunc(MinutesBetween(DayTime.EndTm,DayTime.StTm)/60);
  if cnt<(MinutesBetween(DayTime.EndTm,DayTime.StTm)/60) then inc(cnt,integer(AlingHour)+1);
  SetLength(PrdList,cnt);
  for I := 0 to cnt - 1 do begin
    //расчет временного интервала
    PrdList[i].sttm:=IncMinute(DayTime.StTm,i*60);
    if (AlingHour) then PrdList[i].sttm:=IncHour(StartOfTheDay(CurDate),HourOf(PrdList[i].sttm));
    PrdList[i].EndTm:=IncMinute(PrdList[i].sttm,60);
    if (i=0) then PrdList[i].sttm:=DayTime.StTm;
    if (i=(cnt-1)) then PrdList[i].endtm:=DayTime.EndTm;
  end;
end;

function OneEmployPay: real;
var
  i,cnt : integer;
  bsum  : real;
  OtherEmpl : array [0..1,0..1] of real;
begin
  //КТУ других работников
  //3 человека с КТУ 1.15 (два распреда и упаковщик)
  //1 бригадир с КТУ 1.4
  OtherEmpl[0,0]:=3; OtherEmpl[0,1]:=1.15;
  OtherEmpl[1,0]:=1; OtherEmpl[1,1]:=1.4;
  //подсчет суммы балов КТУ
  bsum:=0;
  cnt:=0;
  for i := 0 to high(OtherEmpl) do begin
    bsum:=bsum+OtherEmpl[i,0]*OtherEmpl[i,1];
    cnt:=cnt+round(OtherEmpl[i,0]);
  end;
  bsum:=bsum+(EmployCount-cnt+1);
  //
  result:=(TotalPay/bsum)+TotBonus;
end;

procedure ChangeDate(d,m,y:word);
var
  i : integer;
begin
  DayTime.StTm:=RecodeDate(DayTime.StTm,y,m,d);
  DayTime.EndTm:=RecodeDate(DayTime.EndTm,y,m,d);
  for I := 0 to high(BreakTime) do begin
    BreakTime[i].StTm:=RecodeDate(BreakTime[i].StTm,y,m,d);
    BreakTime[i].EndTm:=RecodeDate(BreakTime[i].EndTm,y,m,d);
  end;
  CurDate:=EncodeDate(y,m,d);
  SetPrdList;
end;

//------------- Унивесальные процедуры и функции -------------------------------

//Универсальная процедура рисования текста в заданном прямоугольнике
procedure DrawTextToRect(cnv:TCanvas;Text:string;rct:trect;align:byte=0);
var
  fnt,w,h : integer;
begin
  if length(text)=0 then begin
    cnv.Rectangle(rct);
    exit;
  end;
  fnt:=1;
  Cnv.Font.Size:=fnt;
  w:=rct.Right-rct.Left;
  h:=rct.Bottom-rct.Top;
  while(Cnv.TextWidth(text)<w)and(cnv.TextHeight(text)<h)do begin
    inc(fnt);
    Cnv.Font.Size:=fnt;
  end;
  cnv.Font.Size:=fnt-1;
  while(length(text)>0)and(text[1]='0') do delete(text,1,1);
  if align=0 then begin
    w:=rct.Left+round((w-cnv.TextWidth(text))/2);
    h:=rct.Top+round((h-cnv.TextHeight(text))/2);
  end;
  if align=1 then begin
    w:=rct.Left;
    h:=rct.Top+round((h-cnv.TextHeight(text))/2);
  end;
  cnv.TextOut(w,h,text);
end;

//------------- Процедуры и функции класса списка кодов ------------------------

constructor TLogList.Create;
begin
  inherited;
  self.FCount:=0;
  SetLength(self.Fitem,self.FCount);
  self.FUnic:=true;
  self.FPaused:=0;
end;

function TLogList.GetItem(ind:integer):TLogRecord;
begin
  result:=self.FItem[ind];
end;

function TLogList.IndByCode(code: string):integer;
var
  i : integer;
begin
  i:=0;
  while(i<self.FCount)and(self.Fitem[i].code<>code)do inc(i);
  if(i<self.FCount)and(self.Fitem[i].code=code)then result:=i else result:=-1;
end;

procedure TLogList.LoadFromStatLog(fname: string; DefModInd:integer);
var
  StrBuf     : TStringList;
  str,substr : string;
  i,j        : integer;
  new        : TLogRecord;
  FText      : TFileStream;
begin
  //загрузка файла в буфер через поток
  StrBuf:=TStringList.Create;
  //открываем в режиме полного доступа для др приложений
  FText:=TFileStream.Create(FName,fmShareDenyNone);
  StrBuf.LoadFromStream(FText);
  FText.Free;
  //очищаем структуру лога
  self.FCount:=0;
  SetLength(self.Fitem,0);
  //обрабатываем звгруженный массив строк
  for I := 0 to StrBuf.Count - 1 do begin
    str:=strbuf[i];
    //выделяем время и пытаемся преобразовать
    if pos(chr(VK_TAB),str)=0 then continue;
    substr:=copy(str,1,pos(chr(VK_TAB),str)-1);
    DateSeparator := '.';
    TimeSeparator := ':';
    try
      new.DtTm :=StrToDateTime(substr);
    except
      continue;
    end;
    //Загружаем коды только за сегодня
    if DateOf(CurDate)<>DateOf(new.DtTm) then continue;
    str:=copy(str,pos(chr(VK_TAB),str)+1,MaxInt);
    //выделяем код результата, проверяем что это цифры
    if pos(chr(VK_TAB),str)=0 then continue;
    substr:=copy(str,1,pos(chr(VK_TAB),str)-1);
    if Length(substr)=0 then continue;
    j:=1;
    while(j<=Length(substr))and(substr[j] in ['0'..'9'])do inc(j);
    if (j<=Length(substr))and(not(substr[j] in ['0'..'9'])) then continue;
    new.Goods:=(StrToInt(substr)=100);
    //Отделяем имя модели
    str:=copy(str,pos(chr(VK_TAB),str)+1,MaxInt);
    substr:=copy(str,1,pos(chr(VK_TAB),str)-1);
    j := 0;
    while((j<ModelList.Count)and(ModelList.Model[j].name<>substr))do inc(j);
    if ((j<ModelList.Count)and(ModelList.Model[j].name=substr)) then begin
      new.ModInd:=ModelList.Model[j].ind;
    end;
    //Отделяем Пустой таб
    str:=copy(str,pos(chr(VK_TAB),str)+1,MaxInt);
    //Выделяем количество персолана
    str:=copy(str,pos(chr(VK_TAB),str)+1,MaxInt);
    if pos(chr(VK_TAB),str)>0 then str:=copy(str,1,pos(chr(VK_TAB),str)-1);
    EmployCount:=StrToInt(str);
    //ДОБАВЛЯЕМ ЗАПИСЬ
    inc(self.FCount);
    SetLength(self.Fitem,self.FCount);
    self.Fitem[self.FCount-1]:=new;
  end;
end;

procedure TLogList.LoadFromFile(fname: string; DefModInd:integer);
var
  StrBuf     : TStringList;
  str,substr : string;
  i,j        : integer;
  new        : TLogRecord;
  FText      : TFileStream;

begin
  //загрузка файла в буфер через поток
  StrBuf:=TStringList.Create;
  //открываем в режиме полного доступа для др приложений
  FText:=TFileStream.Create(FName,fmShareDenyNone);
  StrBuf.LoadFromStream(FText);
  FText.Free;
  //очищаем структуру лога
  self.FCount:=0;
  SetLength(self.Fitem,0);
  //обрабатываем звгруженный массив строк
  for I := 0 to StrBuf.Count - 1 do begin
    str:=strbuf[i];
    //выделяем время и пытаемся преобразовать
    if pos(chr(VK_TAB),str)=0 then continue;
    substr:=copy(str,1,pos(chr(VK_TAB),str)-1);
    DateSeparator := '.';
    TimeSeparator := ':';
    try
      new.DtTm :=StrToDateTime(substr);
    except
      continue;
    end;
    //Загружаем коды только за сегодня
    if DateOf(CurDate)<>DateOf(new.DtTm) then continue;
    str:=copy(str,pos(chr(VK_TAB),str)+1,MaxInt);
    //выделяем код сканера проверяем что это цифры
    if pos(chr(VK_TAB),str)=0 then continue;
    substr:=copy(str,1,pos(chr(VK_TAB),str)-1);
    if Length(substr)=0 then continue;
    j:=1;
    while(j<=Length(substr))and(substr[j] in ['0'..'9'])do inc(j);
    if (j<=Length(substr))and(not(substr[j] in ['0'..'9'])) then continue;
    new.scnum:=StrToInt(substr);
    str:=copy(str,pos(chr(VK_TAB),str)+1,12);
    //выделяем код
    if Length(str)=0 then continue;
    //определяем что в коде только цифры
    j:=1;
    while(j<=Length(str))and(str[j] in ['0'..'9'])do inc(j);
    if(j<=Length(str))and(not(str[j] in ['0'..'9']))then continue;
    new.code:=str;
    //защита от частого ввода с одного и того же сканера
    //длительность паузы определяется знач FPaused (при FPaused>0)
    //разрешается частый ввод со сканера №0
    if (new.scnum>0)and(self.FPaused>0) then begin
        j:=self.FCount-1;
        while(j>=0)and(self.fItem[j].scnum<>new.scnum)do dec(j);
        if(j>=0)and(self.fItem[j].scnum=new.scnum)and
          (SecondsBetween(new.DtTm,self.fItem[j].DtTm)<=self.FPaused)then continue;
      end;
    //определям относится ли код к готовой продукции
    //или входит в список фиксированных
    new.Goods:=not(FixCodeList.IndByCode(new.code)>=0);
    //определяем код модели
    if not(new.Goods) then begin
      //для записи об ошибке код модели определяем по предыдущему
      if self.FCount=0 then new.ModInd:=DefModInd else
        new.ModInd:=self.fItem[self.FCount-1].ModInd;
    end else begin
      if (new.code[1] in ['1'..'9'])and(new.code[2] in ['0'..'9']) then
        new.ModInd:=ModelList.GetListInd(StrToInt(copy(new.code,1,2))-10)
        else new.ModInd:=-1;
    end;
    if new.ModInd<0 then continue;
    //проверка кода готовой продукции на уникальность
    //разрешатеся ввод одинковых кодов со сканера №0
    if (new.Goods)and(new.scnum>0)and(self.FUnic)and(self.IndByCode(new.code)>=0) then continue;
    //ДОБАВЛЯЕМ ЗАПИСЬ
    inc(self.FCount);
    SetLength(self.Fitem,self.FCount);
    self.Fitem[self.FCount-1]:=new;
  end;
end;

procedure TLogList.Clear;
begin
  self.FCount:=0;
  SetLength(self.FItem,0);
end;

//------------- Работа со списком моделей --------------------------------------

constructor TModList.Create;
begin
  self.FCount:=0;
  SetLength(self.Fitem,self.FCount);
end;

procedure TModList.LoadFromFile(fname: string);
var
  StrBuf     : TStringList;
  str,substr : string;
  i          : integer;
  new        : TModRecord;
begin
  StrBuf:=TStringList.Create;
  try
  StrBuf.LoadFromFile(fname);
  //очищаем структуру лога
  self.FCount:=0;
  SetLength(self.Fitem,0);
  //обрабатываем звгруженный массив строк
  for I := 0 to StrBuf.Count - 1 do begin
    str:=strbuf[i];
    //выделяем индекс
    if pos(chr(VK_TAB),str)=0 then continue;
    substr:=copy(str,1,pos(chr(VK_TAB),str)-1);
    new.ind:=StrToIntDef(substr,0);
    str:=copy(str,pos(chr(VK_TAB),str)+1,MaxInt);
    //выделяем наименование
    if pos(chr(VK_TAB),str)=0 then continue;
    substr:=copy(str,1,pos(chr(VK_TAB),str)-1);
    new.name:=substr;
    str:=copy(str,pos(chr(VK_TAB),str)+1,maxInt);
    //выделяем ставку
    if pos(chr(VK_TAB),str)=0 then continue;
    substr:=copy(str,1,pos(chr(VK_TAB),str)-1);
    new.price:=StrToFloatDef(substr,0);
    str:=copy(str,pos(chr(VK_TAB),str)+1,maxInt);
    //выделяем норму
    new.norm:=StrToFloatDef(str,14);
    //добавляем элемент в список
    if Length(new.name)>0 then begin
      inc(self.FCount);
      SetLength(self.Fitem,Self.FCount);
      self.Fitem[self.FCount-1]:=new;
    end;
  end;
  finally
  StrBuf.Free;
  end;
end;

function TModList.GetListInd(index:byte):integer;
var
  i : integer;
begin
  i:=0;
  while(i<self.FCount)and(self.Fitem[i].ind<>index)do inc(i);
  if(i<self.FCount)and(self.Fitem[i].ind=index)then result:=i
    else result:=-1;
end;

function TModList.GetModelByInd(ind: Integer):TModRecord;
begin
  result:=self.Fitem[ind];
end;


end.
