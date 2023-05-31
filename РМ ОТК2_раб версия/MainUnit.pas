unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AppEvnts, ComCtrls, ExtCtrls, Grids, Buttons, DateUtils;

type
  TMainForm = class(TForm)
    ApplicationEvents1: TApplicationEvents;
    StatusBar: TStatusBar;
    MainPN: TPanel;
    TopPN: TPanel;
    MiddlePN: TPanel;
    RightPn: TPanel;
    FaultPN: TPanel;
    Label1: TLabel;
    LogLB: TListBox;
    FaultSG: TStringGrid;
    Label2: TLabel;
    CapPN: TPanel;
    CapLB: TLabel;
    SpeedButton1: TSpeedButton;
    Label3: TLabel;
    MainTimer: TTimer;
    EmPn: TPanel;
    ProvCB: TComboBox;
    EmBtn: TButton;
    Label4: TLabel;
    EmPnCloseBtn: TBitBtn;
    ProdSG: TStringGrid;
    GroupBox1: TGroupBox;
    TotProdLB: TLabel;
    ChangeModelBtn: TButton;
    Button1: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EmBtnClick(Sender: TObject);
    procedure UpdateFaultList(sort:boolean);
    function  ReadScan(key: Word;var scnum:integer):string;
    function  CodeProcessing(mycode:string; scnum:integer):boolean;
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure UpdateLogMemo;
    procedure SpeedButton1Click(Sender: TObject);
    procedure UpdateResultLabel;
    procedure MainTimerTimer(Sender: TObject);
    procedure EmPnCloseBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ProdSGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure ChangeModelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;


implementation

{$R *.dfm}

uses ProcUnit, DataUnit, ModelSelectUnit, IniFiles;

const
  rmNone=0;      //����� ������ ����� - ��� ������
  rmPref=1;      //����� ������ ����� - ������ ��������
  rmCode=2;      //����� ������ ����� - ������ ����
  CodeLen=13;    //����� ����


type
  TTabRec = record
    code : string;
    cnt  : integer;
    last : TTime;
    mind : integer;
  end;
var
  InputStr    : string  = '';       //����� �������� ��������
  ScanNumLen  : integer = 1;        //����� ������ �������
  PrefWord    : string  = 'SCAN';   //������� �������
  ReadMode    : byte    = 0;        //����� ������ �����
  FaultTable  : array of TTabRec;   //������� ���������� �����
  Today       : word;               //������� ����

procedure TMainForm.ChangeModelBtnClick(Sender: TObject);
var
  i : integer;
begin
  ShowMessage(inttostr(LastModInd));
  i:=GetNewModel;
  if i>0 then LastModInd:=i;
  ShowMessage(inttostr(i));
end;

function TMainForm.CodeProcessing(mycode: string; scnum:integer):boolean;
var
  ind  : integer;
begin
  //��������� ����
  //����� � ������ ������������� ����� (������, ���� ����������)
  ind:=FixCode.IndByCode(MyCode);
  if ind>-1 then begin
    case FixCode.Item[ind].group of
      0 : DataMod.FaultCode(ind,scnum); //���� ������
      1 : ; //���� ����������
    end;
    result:=true;
  end else begin
    //������� ���������� ��� ��� ������� ���������
    result:=DataMod.ProductCode(MyCode,scnum);
  end;
end;

function TMainForm.ReadScan(key: Word;var scnum:integer):string;
var
  //ScanNum : integer; // ����� �������
  MyCode  : string;
begin
  result:='';
  //���� �������� ������ ������� �������� � �� �� � ������ ������
  //�������� � ����� ������ ��������
  if Length(PrefWord)>0 then begin
    if(chr(key)=PrefWord[1])and(ReadMode=rmNone) then ReadMode:=rmPref;
  end else ReadMode:=rmCode;
  //����� ������ ��������
  if(ReadMode=rmPref) then begin
    InputStr:=InputStr+chr(key);
    //���� ������������������ �������� �� ������������� ��������
    //������� �� ������ ������
    if(copy(PrefWord,1,Length(InputStr))<>InputStr)then begin
      ReadMode := rmNone;
      InputStr := '';
    end;
    //���� ������� ������ ����� ������ � ����� ������ ����
    if(InputStr=PrefWord)then begin
      ReadMode:=rmCode;
      InputStr:='';
    end;
  end else
    //����� ������ ����
    if ReadMode=rmCode then begin
      InputStr:=InputStr+chr(key);
      //��� ���������� ����� ������ ������������������ ������� ���
      if Length(InputStr)=(CodeLen+ScanNumLen) then begin
        if ScanNumLen>0 then begin
          ScNum:=StrToInt(InputStr[1]);
          MyCode:=copy(InputStr,2,MaxInt);
        end else begin
          ScNum:=1;
          MyCode:=InputStr;
        end;
        ReadMode:=rmNone;
        InputStr:='';
        //�������� ����������� ����� � ����� �������� ���������
        //CheckSum(MyCode);
        MyCode:=copy(MyCode,1,12);
        result:=mycode;
      end;
    end;
end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
begin
  self.Close;
end;

procedure TMainForm.UpdateFaultList(sort:boolean);
var
  recbuf     : TTabRec;
  i,j,ind    : integer;
  plog       : ^TLogRecord;
begin
  //����������� ������
  SetLength(FaultTable,0);
  i:=0;
  while(i<Logs.Count)do begin
    plog:=Logs.Items[i];
    ind:=FixCode.IndByCode(plog^.code);
    if(ind>=0)and(FixCode.Item[ind].group=0)then begin
      j:=0;
      while(j<=high(FaultTable))and(FaultTable[j].code<>FixCode.Item[ind].code)do inc(j);
      if(j<=high(FaultTable))and(FaultTable[j].code=FixCode.Item[ind].code)then begin
          inc(FaultTable[j].cnt);
          FaultTable[j].last:=plog^.time;
          FaultTable[j].mind:=plog^.mind;
          end
        else begin
          SetLength(FaultTable,high(FaultTable)+2);
          FaultTable[high(FaultTable)].code:=FixCode.Item[ind].code;
          FaultTable[high(FaultTable)].cnt:=1;
          FaultTable[high(FaultTable)].last:=plog^.time;;
          FaultTable[high(FaultTable)].mind:=plog^.mind;
        end;
    end;
    inc(i);
  end;
  //����������
  if Sort then
    for i := 0 to high(FaultTable) do
      for j := 0 to high(FaultTable)-1 do
        if FaultTable[j].cnt < FaultTable[j+1].cnt then begin
          recbuf := FaultTable[j];
          FaultTable[j] := FaultTable[j+1];
          FaultTable[j+1] := recbuf;
        end;
  //����� ����������
  for I := 0 to FaultSG.RowCount-1 do
    if i<=high(FaultTable)then begin
      ind:=FixCode.IndByCode(FaultTable[i].code);
      FaultSG.Cells[0,i]:=FixCode.Item[ind].name;
      FaultSG.Cells[1,i]:=IntToStr(FaultTable[i].cnt);
      FaultSG.Cells[2,i]:='���������: '+TimeToStr(FaultTable[i].last);
      if FaultTable[i].mind>=0 then FaultSG.Cells[3,i]:=ModRecLst[FaultTable[i].mind].name
        else FaultSG.Cells[3,i]:='';
    end else FaultSG.Rows[i].Clear;
  FaultSG.Selection:=TGridRect(rect(-1,-1,-1,-1));
end;

procedure TMainForm.UpdateResultLabel;
var
  i,h,cnt : integer;
begin
  ProdSG.RowCount:=2;
  ProdSG.Cells[0,0]:='  ������';
  ProdSG.Cells[1,0]:='  ��� ����';
  ProdSG.Cells[2,0]:='  ����';
  ProdSG.Rows[1].Clear;
  cnt:=DataMod.ProductCount(0,0,LastModInd) ;
  if Logs.Count>0 then begin
    ProdSG.Cells[0,1]:=ModReclst[LastModInd].name;
    ProdSG.Cells[1,1]:=IntToStr(cnt);
    cnt:=(DataMod.FixCodeCount('',0,0,0,LastModind));
    if cnt>0 then ProdSG.Cells[2,1]:=inttostr(cnt) else ProdSG.Cells[2,1]:='';
    for i := 0 to high(ModRecLst) do
      if i<>LastModInd then begin
        cnt:=DataMod.ProductCount(0,0,i) ;
        if cnt>0 then begin
          ProdSg.RowCount:=ProdSg.RowCount+1;
          ProdSG.Cells[0,ProdSG.RowCount-1]:=ModReclst[i].name;
          ProdSG.Cells[1,ProdSG.RowCount-1]:=IntToStr(cnt);
          cnt:=(DataMod.FixCodeCount('',0,0,0,i));
          if cnt>0 then ProdSG.Cells[2,ProdSG.RowCount-1]:=inttostr(cnt)
            else ProdSG.Cells[2,ProdSG.RowCount-1]:='';
        end;
      end;
  end;
  //��������� ������� ������� ������� ���������
  ProdSG.ColWidths[0]:=ProdSG.Width-ProdSG.ColWidths[1]-
    ProdSG.ColWidths[2]-5;
  h:=0;
  ProdSG.RowHeights[0]:=24;
  for I := 0 to ProdSG.RowCount-1 do h:=h+ProdSG.RowHeights[i];
  h:=round(h*1.1)+ProdSG.Top+ProdSG.Margins.Bottom;
  if h>170 then MiddlePN.Height:=170;
  ProdSG.Selection:=TGridRect(rect(-1,-1,-1,-1));
  //����� ���������� ������������� ���������
  TotProdLB.Caption:=IntToStr(DataMod.ProductCount(0,0));
end;

procedure TMainForm.UpdateLogMemo;
var
  i   : integer;
  str : string;
  prec: ^TLogRecord;
begin
  LogLB.Items.Clear;
  for I := 0 to Logs.Count - 1 do begin
    prec:=Logs.Items[i];
    str:=TimeToStr(prec^.time)+'  '+prec^.code+'   '+prec^.name;
    LogLB.Items.Add(str);
  end;
  LogLB.ItemIndex:=LogLB.Items.Count-1;
end;

//---------------- ��������� ������ TForm ------------------------------------

procedure TMainForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  str : string;
begin
  //��������� ��������� �� ������������ ������ TCP-�������
  if Msg.message=WM_SENDTCP then begin
    case Msg.wParam of
      tcpOK      : str:=' - c�������� ������� ������������ !';
      tcpConnect : str:=' - ������� ������������ ����� ..';
      tcpError   : str:=' - ������ ��� ������������ ����� c �� ���1!';
      tcpError1  : str:=' - ������ ��� ������������ ����� � SERGEYSHAGINYAN!';
    end;
    StatusBar.Panels[1].Text:='��������� �����: '+TimeToStr(now)+str;
  end;
end;

procedure TMainForm.EmPnCloseBtnClick(Sender: TObject);
begin
  ShowCursor(false);
  EmPn.Visible:=false;
end;

procedure TMainForm.EmBtnClick(Sender: TObject);
var
  i,scnum          : integer;
  str,code,scannum : string;
begin
  i:=0;
  ScanNum:='';
  while(i<ScanNumLen)do begin
    ScanNum:=ScanNum+'2';
    inc(i);
  end;
  if ProvCB.ItemIndex=0 then str:=PrefWord+ScanNum+'1001051833219' else
    if ProvCB.ItemIndex=1 then str:=PrefWord+ScanNum+'2905071521239' else
      str:=PrefWord+ScanNum+FixCode.Item[ProvCB.itemindex-2].code+'9';
  for i := 1 to Length(str) do
    begin
      code:=ReadScan(ord(str[i]),scnum);
      if (Length(code)>0)and(CodeProcessing(code,scnum))then
        begin
          self.UpdateLogMemo;
          self.UpdateFaultList(true);
          self.UpdateResultLabel;
        end;
    end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  inifile : TIniFile;
begin
  MainTimer.Enabled:=true;
  IniFile:=TIniFile.Create(ExtractFilePath(application.ExeName)+'mainini.ini');
  PrefWord:=IniFile.ReadString('SET','SCANPREF','SCAN');
  ScanNumLen:=IniFile.ReadInteger('SET','SCANNUMLEN',1);
  IniFile.Free;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  code : string;
  scnum: integer;
begin
  //������ ��������� �������� ������ (���� ����)
  case Key of
      121 : self.Close;
      69  : begin
             //����� ������ ��������� �����
             ShowCursor(true);
             EmPn.Visible:=true;
            end;
  end;
  //�������� ���� ������� � �������� ������������� ������ �������
  code:=ReadScan(key,scnum);
  if (Length(code)>0)and(CodeProcessing(code,scnum))then
    begin
      self.UpdateLogMemo;
      self.UpdateFaultList(true);
      self.UpdateResultLabel;
    end;
end;

procedure TMainForm.FormResize(Sender: TObject);
var
  i,h : integer;
begin
  StatusBar.Panels[0].Width:=round(self.ClientWidth*0.3);
  RightPN.Width:=round(self.ClientWidth*0.3);
  //��������� �������� ������� �����
  FaultSG.ColWidths[0]:=round(FaultSG.ClientWidth*0.35);
  FaultSG.ColWidths[1]:=round(FaultSG.ClientWidth*0.05);
  FaultSG.ColWidths[2]:=round(FaultSG.ClientWidth*0.2);
  FaultSG.ColWidths[3]:=FaultSG.ClientWidth-FaultSG.ColWidths[0]-
    FaultSG.ColWidths[1]-FaultSG.ColWidths[2]-5;
  h:=0;
  for I := 0 to FaultSG.RowCount-1 do h:=h+FaultSG.RowHeights[i];
  FaultSG.Height:=round(h*1.1);
  //��������� ������� ������� ������� ���������
  ProdSG.ColWidths[0]:=ProdSG.Width-ProdSG.ColWidths[1]-
    ProdSG.ColWidths[2]-5;
  h:=0;
  for I := 0 to ProdSG.RowCount-1 do h:=h+ProdSG.RowHeights[i];
  h:=round(h*1.1)+ProdSG.Top+ProdSG.Margins.Bottom;
  if h>170 then MiddlePN.Height:=170;
end;

procedure TMainForm.MainTimerTimer(Sender: TObject);
var
  i : Integer;
begin
  TopPn.Caption:=FormatDateTime('dd mmm yyyy   hh:mm:ss',now);
  //�������������� ������������ � �������
  if Today<>DayOfTheYear(now) then begin
    Today:=DayOfTheYear(now);
    DataMod.DataInit;
    //����������� ������ ������ ������ �������� ����� �� �������
    ProvCb.Clear;
    ProvCB.Items.Add('������� ��������� 1');
    ProvCB.Items.Add('������� ��������� 2');
     for I := 0 to FixCode.Count - 1 do ProvCB.Items.Add(FixCode.Item[i].name);
    ProvCB.ItemIndex:=0;
    //���������� ���������� �����������
    EmPn.Visible:=false;
    ShowCursor(false);
    self.UpdateLogMemo;
    self.UpdateFaultList(true);
    self.UpdateResultLabel;
    self.FormResize(self);
  end;
end;

procedure TMainForm.ProdSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  Flag : Cardinal;
  str  : widestring;
  Rct  : TRect;
begin
  if arow<=1 then begin
  with (Sender as TStringGrid) do begin    Canvas.FillRect(Rect);
    str:=(Sender as TStringGrid).Cells[Acol,ARow];
    Rct:=Rect;
    Flag := DT_LEFT;
    Inc(Rct.Left,2);
    Inc(Rct.Top,2);
    if ARow=1 then begin
      Canvas.Font.Color:=clRED;
      Canvas.Font.Size:=24;
    end else begin
      Canvas.Font.Color:=clBlack;
      Canvas.Font.Size:=12;
    end;
    DrawTextW((Sender as TStringGrid).Canvas.Handle,PWideChar(str),length(str),Rct,Flag);
    end;
  end;
end;

end.
