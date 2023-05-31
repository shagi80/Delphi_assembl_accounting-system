unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles,DateUtils, Grids, ExtCtrls, Buttons, Mask, ShellAPI, ShlObj,
  ExtDlgs;

type
  TForm1 = class(TForm)
    OpenDlg: TOpenDialog;
    SGPanel: TPanel;
    SG: TStringGrid;
    TopPn: TPanel;
    AddBtn: TButton;
    GroupBox1: TGroupBox;
    EndDateED: TMaskEdit;
    EndDateBtn: TSpeedButton;
    StDateED: TMaskEdit;
    StDateBtn: TSpeedButton;
    PrdAddBtn: TBitBtn;
    StatLogDirED: TEdit;
    StatLogDirBtn: TSpeedButton;
    SortBtn: TButton;
    DelBtn: TButton;
    Splitter1: TSplitter;
    BtmPn: TPanel;
    PB: TPaintBox;
    ExportBtn: TBitBtn;
    SaveDlg: TSaveTextFileDialog;
    procedure AddBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpdateMainData(LogFileName:string);
    procedure UpdateSG;
    procedure ResizeSG;
    procedure FormResize(Sender: TObject);
    procedure StDateBtnClick(Sender: TObject);
    procedure PrdAddBtnClick(Sender: TObject);
    function  OpenDirDlg(var DirPath:string):boolean;
    procedure StatLogDirBtnClick(Sender: TObject);
    procedure SortBtnClick(Sender: TObject);
    procedure DelBtnClick(Sender: TObject);
    procedure DrawGrap(w,h : integer; cnv : TCanvas);
    procedure PBPaint(Sender: TObject);
    procedure EndDateBtnClick(Sender: TObject);
    procedure ExportBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TOneRec  = record
    recdate : Tdate;
    empcnt  : word;
    result  : array of TPoint;
    frtst, last : TDateTime;
    durat   : integer;
  end;
  TRecList = array of TOneRec;


var
  Form1: TForm1;

implementation

{$R *.dfm}

uses DataUnit, FixCodeUnit, DateUnit;

var
  FixCodeFileName : string;         //имя файла фиксированных кодов
  ModFileName     : string;         //имя файла описания моделей
  RecList         : TRecList;
  StatLogDir      : string;

//Чтение записей из файлов и обновление основных данных
procedure TForm1.UpdateMainData(LogFileName:string);
var
  i        : integer;
  pl,res   : integer;
  TotBonus : integer;
begin
  FixCodeList.LoadFromFile(FixCodeFileName);
  ModelList.LoadFromFile(ModFileName);
  Logs.Clear;
  if FileExists(LogFileName) then Logs.LoadFromStatLog(LogFileName,0);
  SetLength(RecList,high(RecList)+2);
  SetLength(RecList[high(RecList)].result,high(PrdList)+3);
  //Общие итоги
  SetPlanCnt;
  RecList[high(RecList)].recdate:=CurDate;
  RecList[high(RecList)].empcnt:=EmployCount;
  RecList[high(RecList)].result[0].X:=PlanEndOfTheDay(Logs.Item[0].DtTm);
  RecList[high(RecList)].result[0].y:=TotalGoods;
  RecList[high(RecList)].frtst:=Logs.Item[0].DtTm;
  RecList[high(RecList)].last:=Logs.Item[Logs.Count-1].DtTm;
  RecList[high(RecList)].durat:=DateUtils.MinutesBetween
    (RecList[high(RecList)].frtst,RecList[high(RecList)].last);
  for I := 0 to high(BreakTime) do
    RecList[high(RecList)].durat:=RecList[high(RecList)].durat-
      DateUtils.MinutesBetween(BreakTime[i].StTm,BreakTime[i].EndTm);
  //Итоги по часам
  TotBonus:=0;
  for i := 1 to high(RecList[high(RecList)].result)-1 do begin
    pl:=round(MainPlan[i-1]);
    res:=TotalGoods(-1,PrdList[i-1].sttm,PrdList[i-1].endtm);
    RecList[high(RecList)].result[i].X:=pl;
    RecList[high(RecList)].result[i].Y:=res;
    if (pl>0)and(pl<=res) then  inc(TotBonus);
  end;
  RecList[high(RecList)].result[high(RecList[high(RecList)].result)].X:=totbonus;
  RecList[high(RecList)].result[high(RecList[high(RecList)].result)].Y:=high(PrdList);
end;

procedure TForm1.ResizeSG;
var
  i,m : integer;
begin
  m:=0;
  for I := 0 to SG.ColCount - 1 do m:=m+SG.ColWidths[i];
  if m<SGPanel.ClientWidth then begin
    SG.Margins.Left:=round((SGPanel.ClientWidth-m)/2);
    SG.Margins.Right:=round(((SGPanel.ClientWidth-m)/2)*0.8);
  end else begin
    SG.Margins.Left:=3;
    SG.Margins.Right:=3;
  end;
end;

procedure TForm1.EndDateBtnClick(Sender: TObject);
begin
  if DateForm.ShowModal=mrOK then EndDateED.Text:=DateToStr(DateForm.MonthCalendar1.Date);
  if StrToDate(EndDateED.text)<StrToDate(StDateED.Text) then StDateED.text:=EndDateED.Text;
end;

procedure TForm1.ExportBtnClick(Sender: TObject);
var
  Strs : TstringList;
  r,c  : integer;
  str  : string;
begin
  if (SG.Visible and SaveDlg.Execute) then begin
    Strs:=TStringList.Create;
    for r := 0 to SG.RowCount - 1 do begin
      Str:='';
      for c := 0 to SG.ColCount - 1 do
        if c=SG.ColCount-1 then str:=str+'"'+SG.Cells[c,r]+'"'
          else str:=str+'"'+SG.Cells[c,r]+'",';
      Strs.Add(str);
    end;
    Strs.SaveToFile(SaveDlg.FileName);
    Strs.Free;
  end;
end;

procedure TForm1.StDateBtnClick(Sender: TObject);
begin
  if DateForm.ShowModal=mrOK then StDateED.Text:=DateToStr(DateForm.MonthCalendar1.Date);
  if StrToDate(EndDateED.text)<StrToDate(StDateED.Text) then EndDateED.text:=StDateED.Text;
end;

procedure TForm1.StatLogDirBtnClick(Sender: TObject);
var
  path    : string;
begin
  if self.OpenDirDlg(path) then StatLogDirED.Text:=path;
end;

procedure TForm1.UpdateSG;
var
  i,m : integer;
begin
  if high(RecList)<0 then begin
    SG.Visible:=false;
    Abort;
  end else SG.Visible:=true;
  SG.RowCount:=high(RecList)+2;
  m:=0;
  for I := 0 to high(RecList) do
    if high(RecList[i].result)>m then m:=high(RecList[i].result);
  SG.ColCount:=m+4;
  SG.Cells[0,0]:=' Дата';
  SG.Cells[1,0]:=' Персон';
  SG.Cells[2,0]:=' За день';
  SG.Cells[3,0]:='Длит';
  SG.Cells[SG.ColCount-1,0]:=' Рез-т';
  for I := 4 to SG.ColCount - 2 do SG.Cells[i,0]:=' Час '+IntToStr(i-2);
  for I := 0 to high(RecList) do begin
    SG.Cells[0,i+1]:=DateToStr(RecList[i].recdate);
    SG.Cells[1,i+1]:=IntToStr(RecList[i].empcnt);
    SG.Cells[2,i+1]:=IntToStr(RecList[i].result[0].X)+'/'+
      IntToStr(RecList[i].result[0].Y);
    SG.Cells[3,i+1]:=IntToStr(RecList[i].durat);
    for m := 1 to high(RecList[i].result) do begin
      SG.Cells[3+m,i+1]:=IntToStr(RecList[i].result[m].X)+'/'+
        IntToStr(RecList[i].result[m].Y);
    end;
  end;
  self.ResizeSG;
  PB.Visible:=SG.Visible;
  PB.Repaint;
end;

procedure TForm1.AddBtnClick(Sender: TObject);
var
  str,fname : string;
  d,m,y,i   : word;
begin
  if OpenDlg.Execute then begin
    str:=OpenDlg.FileName;
    if (FileExists(str)) then begin
      FName:=str;
      str:=ExtractFileName(str);
      d:=StrToIntDef(copy(str,1,2),1);
      m:=StrToIntDef(copy(str,3,2),1);
      str:=copy(str,5,pos('.txt',str)-5);
      if Length(str)=2 then y:=2000+StrToIntDef(str,16)
        else y:=StrToIntDef(str,2016);
      i:=0;
      while((i<=high(RecList))and(EncodeDate(y,m,d)<>RecList[i].recdate))do inc(i);
      if((i<=high(RecList))and(EncodeDate(y,m,d)=RecList[i].recdate))then begin
        MessageDLG('Запись за дату '+FormatDateTime('dd.mm.yyyy',EncodeDate(y,m,d))
          +' уже существует!',mtWarning,[mbOK],0);
      end else begin
        changedate(d,m,y);
        self.UpdateMainData(fname);
        self.UpdateSG;
      end;
    end;
  end;
end;

procedure TForm1.SortBtnClick(Sender: TObject);
var
  n,i,j :integer;
  s: TStringList;
  dt1,dt2 : TDate;
begin
  n:=SG.RowCount;
  if (n<3)or (SG.Visible=false) then abort;
  S:=TStringList.Create;
  for i:=SG.FixedRows to n-2 do //нет фиксированных строки и столбца
  for j:=i+1 to n-1 do begin
    dt1:=DateOf(StrToDate(SG.Cells[0,i]));
    dt2:=DateOf(StrToDate(SG.Cells[0,j]));
  if dt1>dt2 then begin
      s.Assign(SG.Rows[i]);
      SG.Rows[i]:=SG.Rows[j];
      SG.Rows[j].Assign(s);
  end;
  end;
  PB.Repaint;
end;

procedure TForm1.DelBtnClick(Sender: TObject);
var
  dt  : TDate;
  i,j : integer;
begin
  if (SG.Visible)and(SG.Selection.Top>0) then begin
    dt:=DateOf(StrToDate(SG.Cells[0,SG.Selection.top]));
    i:=0;
    while((i<=high(RecList))and(DaysBetWeen(dt,RecList[i].recdate)<>0))do inc(i);
    if((i<=high(RecList))and(DaysBetWeen(dt,RecList[i].recdate)=0))then begin
      for j := i to high(RecList)-1 do RecList[j]:=RecList[j+1];
      SetLength(RecList,high(Reclist));
    end;
    self.UpdateSG;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  inifile : TIniFile;
  cnt,i   : integer;
begin
  inherited;
  //установка текущей даты
  CurDate:=CurDate;
  StDateED.Text:=DateToStr(StartOfTheMonth(now));
  EndDateED.Text:=DateToStr(EndOfTheMonth(now));
  //создание структур хранения данных
  FixCodeList:=TCodeList.Create;
  ModelList:=TModList.Create;
  Logs:=TlogList.Create;
  //инициализация перемеменных
  IniFile:=TIniFile.Create(ExtractFilePath(application.ExeName)+'\mainset.ini');
  FixCodeFileName:=IniFile.ReadString('MAIN','FIXCODEFILENAME',ExtractFilePath(application.ExeName)+'\fixcode.cdl');
  ModFileName:=IniFile.ReadString('MAIN','MODFILENAME',ExtractFilePath(application.ExeName)+'\modlist.txt');
  StatLogDir:=IniFile.ReadString('MAIN','STATLOGDIR',ExtractFilePath(application.ExeName));
  StatLogDirED.Text:=StatLogDir;
  Logs.CodeUnic:=IniFile.ReadBool('MAIN','CODEUNIC',true);
  Logs.InputPaused:=IniFile.ReadInteger('MAIN','INPUTPAUSED',0);
  DayTime.StTm:=IniFile.ReadTime('TIME','DAYSTART',StrToTime('08:00'));
  DayTime.StTm:=IncMinute(StartOfTheDay(CurDate),MinuteOfTheDay(DayTime.StTm));
  DayTime.EndTm:=IniFile.ReadTime('TIME','DAYEND',StrToTime('20:00'));
  DayTime.EndTm:=IncMinute(StartOfTheDay(CurDate),MinuteOfTheDay(DayTime.EndTm));;
  cnt:=IniFile.ReadInteger('TIME','BREAKCNT',0);
  SetLength(BreakTime,cnt);
  for I := 0 to cnt - 1 do begin
    BreakTime[i].StTm:=IniFile.ReadTime('TIME','BREAKSTART'+IntToStr(i+1),StrToTime('12:00'));
    BreakTime[i].StTm:=IncMinute(StartOfTheDay(CurDate),MinuteOfTheDay(BreakTime[i].StTm));
    BreakTime[i].EndTm:=IniFile.ReadTime('TIME','BREAKEND'+IntToStr(i+1),StrToTime('13:00'));
    BreakTime[i].EndTm:=IncMinute(StartOfTheDay(CurDate),MinuteOfTheDay(BreakTime[i].EndTm));;
  end;
  IniFile.Free;
  //Расчет временных интервалов учета рез производства
  SetPrdList;
  //
  SetLength(RecList,0);
  //
  self.UpdateSG;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  self.ResizeSG;
end;

procedure TForm1.PBPaint(Sender: TObject);
begin
  self.DrawGrap(PB.ClientWidth,PB.ClientHeight,PB.Canvas);
end;

procedure TForm1.PrdAddBtnClick(Sender: TObject);
var
  str,fname   : string;
  dt          : TDate;
  d,m,y,i,cnt : word;
  IniFile     : TIniFile;
begin
  cnt:=DaysBetWeen(StrToDate(EndDateED.Text),StrToDate(StDateED.Text));
  if DirectoryExists(StatLogDirED.Text) then begin
    StatLogDir:=StatLogDirED.Text;
    IniFile:=TIniFile.Create(ExtractFilePath(application.ExeName)+'\mainset.ini');
    IniFile.WriteString('MAIN','STATLOGDIR',StatLogDir);
    IniFile.Free;
    SetLength(RecList,0);
    for i:=0 to cnt do begin
      dt:=IncDay(StrToDate(StDateED.Text),i);
      if StatLogDir[Length(StatLogDir)]<>'\' then StatLogDir:=StatLogDir+'\';
      str:=StatLogDir+FormatDateTime('ddmmyy',dt)+'.txt';
      if (FileExists(str)) then begin
        FName:=str;
        DecodeDate(dt,y,m,d);
        changedate(d,m,y);
        //for i := 0 to high(prdlist) do MainDgr.ChangeBonus(i,0);
        self.UpdateMainData(fname);
      end;
    end;
    self.UpdateSG;
  end else begin
    MessageDLG('Нет доступа к папке "'+StatLogDirED.Text+'"',mtError,[mbOK],0);
  end;
  self.UpdateSG;
end;

function TForm1.OpenDirDlg(var DirPath:string):boolean;
var
  TitleName : string;
  lpItemID : PItemIDList;
  BrowseInfo : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of char;
  TempPath : array[0..MAX_PATH] of char;
begin
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  BrowseInfo.hwndOwner := Form1.Handle;
  BrowseInfo.pszDisplayName := @DisplayName;
  TitleName := 'Выбирете папку';
  BrowseInfo.lpszTitle := PChar(TitleName);
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    DirPath:=TempPath;
    GlobalFreePtr(lpItemID);
    result:=true;
  end else result:=false;
end;

procedure TForm1.DrawGrap(w,h : integer; cnv : TCanvas);
var
  i,j       : integer;
  str       : string;
  ZPnt      : TPoint;
  SctX,SctY : real;
  rct       : TRect;
begin
  with cnv do
  begin
  h:=h-10;
  SctX:=(w/(high(RecList)+3));
  ZPnt.X:=round(SctX/2);
  ZPnt.Y:=h-ABS(Font.Height)*2;
  SctY:=((Zpnt.Y*2-h)/100);
  Pen.Color:=clBlack;
  Pen.Width:=2;
  MoveTo(ZPnt.X,ZPnt.Y);
  LineTo(ZPnt.X+round(SctX*(high(RecList)+2)),ZPnt.Y);
  MoveTo(ZPnt.X,ZPnt.Y);
  LineTo(ZPnt.X,0);
  //
  Pen.Color:=clGray;
  Pen.Width:=1;
  for I := 0 to 11 do
    begin
      str:=inttostr(i);
      TextOut(ZPnt.X-TextWidth(str)-5,ZPnt.Y-round(i*sctY*10)-
        round(TextHeight(str)/2),str);
      MoveTo(ZPnt.X,ZPnt.Y-round(i*sctY*10));
      LineTo(ZPnt.X+round(SctX*(high(RecList)+2)),ZPnt.Y-round(i*sctY*10));
    end;
  //Вывод готовой продукции
  Pen.Color:=clBlack;
  Pen.Width:=1;
  for j := 0 to high(RecList) do
    begin
      rct.Bottom:=Zpnt.Y;
      rct.Left:=round(ZPnt.X+SctX*(j+1)-SctX/4);
      rct.Right:=rct.Left+round(SctX/2);
      str:=SG.Cells[SG.ColCount-1,j+1];
      str:=copy(str,1,pos('/',str)-1);
      i:=StrToIntDef(str,0);
      rct.Top:=round(ZPnt.Y-i*sctY*10);
      Brush.Color:=clMoneyGreen;
      Rectangle(rct);
      Brush.Color:=clWhite;
      TextOut(round(Zpnt.X+SctX*(j+1)-TextWidth(str)/2),round(ZPnt.Y-i*sctY*10-
        TextHeight(str)-2),str);
      str:=SG.Cells[0,j+1];
      TextOut(round(Zpnt.X+SctX*(j+1)-TextWidth(str)/2),(Zpnt.Y+2),str);
    end;
  end;
end;


end.
