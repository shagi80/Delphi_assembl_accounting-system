unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls, Buttons, ComCtrls, DB,
  DBClient, DBCtrls, AppEvnts, frxClass, frxBarcode;

type
  TForm1 = class(TForm)
    BackPn: TPanel;
    Img: TImage;
    BtnPn: TPanel;
    PrBtn: TBitBtn;
    ModPn: TPanel;
    ModCapPn: TPanel;
    ModLB: TListBox;
    SpeedButton1: TSpeedButton;
    Label1: TLabel;
    DatePn: TPanel;
    Panel2: TPanel;
    SpeedButton2: TSpeedButton;
    Label2: TLabel;
    Clnd: TMonthCalendar;
    SnPn: TPanel;
    Panel3: TPanel;
    SpeedButton3: TSpeedButton;
    Label3: TLabel;
    Label4: TLabel;
    StNumED: TEdit;
    NumCountED: TEdit;
    Label5: TLabel;
    SpeedButton4: TSpeedButton;
    Label6: TLabel;
    SmCB: TComboBox;
    ApplicationEvents1: TApplicationEvents;
    frxRep: TfrxReport;
    frxUDS: TfrxUserDataSet;
    frxBarCodeObject1: TfrxBarCodeObject;
    procedure RvSystem1AfterPreviewPrint(Sender: TObject);
    procedure PrBtnClick(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure ClndClick(Sender: TObject);
    procedure ModLBDblClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ImgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function  InActiveAr(X,Y : integer):integer;
    procedure PaintArea(i:integer ; act:boolean);
    procedure frxRepGetValue(const VarName: string; var Value: Variant);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses PrModeUnit, HelpUnit;

type
  TModRec = record                       //��� ������ � ������
    Name,Pwr,Net,Code : string[16];      //���, �� ����, ���, ��� � �����
  end;

var
  BaseImgHeight,
  BaseImgWidth   : integer;              //������ �������� �������
  ArLstCount     : integer;              //���-�� �������� ��������
  BaseActArLst   : array of TRect;       //������ ��������� ��������
  ActArNameLst   : array of string[32];  //������ ���� ��������
  ActArFntSzLst  : array of byte;        //������ �������� �������
  ActArFntAlLst  : array of byte;        //������ �������� Aling
  ActArActFlLst  : array of boolean;     //������ ���� ������� �� ���� ����
  M              : real;                 //������� �������� �������
  ActArInd       : byte;                 //������ �������� �������

  ModCount       : integer;              //���-�� �������
  ModRecLst      : array of TModRec;     //������ ������� � �������
  MnfInd         : string;               //������ ������-�������������

  ModInd,SmInd   : byte;                 //������� ��� ���� �������
  Date           : TDate;                //����
  StNum,NumCount : word;                 //�������� ��� �������


procedure TForm1.frxRepGetValue(const VarName: string; var Value: Variant);
var
  i   : integer;
  str : string;
  bar : string;
begin
  value:='error';
  if CompareText(VarName,'model')=0 then value:=ModRecLst[ModInd].Name;
  if CompareText(VarName,'power')=0 then value:=ModRecLst[ModInd].Pwr ;
  if CompareText(VarName,'net')=0 then value:=ModRecLst[ModInd].Net;
  if CompareText(VarName,'mydate')=0 then value:=DateTostr(Date);
  i:=frxUDS.RecNo;
  str:=MnfInd+ModRecLst[ModInd].Code;
  bar:=FormatFloat('00',ModInd+10);
  str:=str+FormatDateTime('ddmmyy',Date);
  bar:=bar+FormatDateTime('ddmmyy',Date);
  str:=str+SmCb.Items[SmInd];
  bar:=bar+inttostr(SmInd+1); // ����� ����� � �����: �=1, B=2 � �.�.
  //��������� � ������ ��� ������ �� ������
  if PrModeForm.RadioGroup1.ItemIndex=0 then
    begin
      str:=str+FormatFloat('000',StNum+i);
      bar:=bar+FormatFloat('000',StNum+i);
    end;
  //��������� � ����� ��� ������ �� �������
  if (PrModeForm.RadioGroup1.ItemIndex>0) then
    begin
      str:=str+FormatFloat('000',StNum+NumCount-1-i);
      bar:=bar+FormatFloat('000',StNum+NumCount-1-i);
    end;

  if CompareText(VarName,'sn')=0 then value:=str;
  if CompareText(VarName,'CODE')=0 then value:=bar;
end;

procedure TForm1.PrBtnClick(Sender: TObject);
begin
  // ���� ������ ������� ��������
  if PrModeForm.ShowModal=mrCancel then Abort;
  // ����� ������ � ����������� �� ������� ��������
  if PrModeForm.RadioGroup1.ItemIndex=0 then
      frxRep.LoadFromFile(ExtractFilePath(Application.ExeName)+'Print1.fr3');
  if PrModeForm.RadioGroup1.ItemIndex=1 then
    frxRep.LoadFromFile(ExtractFilePath(Application.ExeName)+'Print2.fr3');
  frxUDS.RangeEndCount:=NumCount;
  frxUDS.First;
  frxRep.PrepareReport(true);
  //frxRep.ShowReport(true);
  frxREp.Print;
end;

procedure TForm1.RvSystem1AfterPreviewPrint(Sender: TObject);
begin

end;

//����� �������� � ���������
procedure TForm1.ClndClick(Sender: TObject);
begin
  Date:=Clnd.Date;
  DatePn.Visible:=false;
  ActArNamelst[1]:=DateToStr(Date);
  self.PaintArea(1,false);
  ActArInd:=100;
end;
//�������� �����, ������������� ����������
procedure TForm1.FormCreate(Sender: TObject);
var
  strs : TStringList;
  i : integer;
  str : string;
begin
  Application.HelpFile:=GetCurrentDir+'\Help.chm';
  Strs:=TStringList.Create;
  Strs.LoadFromFile(GetCurrentDir+'\ModData.txt');
  MnfInd:=Strs[0];
  ModCount:=Strs.Count-1;
  SetLength(ModRecLst,ModCount);
  for i := 1 to Strs.Count - 1 do
    begin
      str:=copy(strs[i],1,pos('|',strs[i])-1);
      ModRecLst[i-1].Name:=str;
      strs[i]:=copy(strs[i],pos('|',strs[i])+1,MaxInt);
      str:=copy(strs[i],1,pos('|',strs[i])-1);
      ModRecLst[i-1].Pwr:=str;
      strs[i]:=copy(strs[i],pos('|',strs[i])+1,MaxInt);
      str:=copy(strs[i],1,pos('|',strs[i])-1);
      ModRecLst[i-1].Net:=str;
      strs[i]:=copy(strs[i],pos('|',strs[i])+1,MaxInt);
      str:=copy(strs[i],1,MaxInt);
      ModRecLst[i-1].Code:=str;
    end;
  //
  Date:=Now;
  StNum:=1;
  NumCount:=10;
  ModInd:=0;
  SmInd:=0;
  //
  SmCB.ItemIndex:=SmInd;
  ArLstCount:=6;
  SetLength(BaseActArLst,ArLstCount);
  SetLength(ActArNameLst,ArLstCount);
  SetLength(ActArFntSzLst,ArLstCount);
  SetLength(ActArFntAlLst,ArLstCount);
  SetLength(ActArActFlLst,ArLstCount);
  BaseImgHeight :=480;
  BaseImgWidth  :=480;
  ActArNameLst[0]:=ModRecLst[ModInd].Name;
  BaseActArLst[0].Left   :=100;
  BaseActArLst[0].Top    :=50;
  BaseActArLst[0].Right  :=365;
  BaseActArLst[0].Bottom :=80;
  ActArFntSzLst[0]:=18;
  ActArFntAlLst[0]:=2;
  ActArActFlLst[0]:=true;
  ActArNameLst[1]:=DateToStr(date);
  BaseActArLst[1].Left   :=300;
  BaseActArLst[1].Top    :=162;
  BaseActArLst[1].Right  :=455;
  BaseActArLst[1].Bottom :=182;
  ActArFntSzLst[1]:=14;
  ActArFntAlLst[1]:=3;
  ActArActFlLst[1]:=true;
  ActArNameLst[2]:='';//OTKNameLst[OTKInd];
  BaseActArLst[2].Left   :=0;
  BaseActArLst[2].Top    :=0;
  BaseActArLst[2].Right  :=0;
  BaseActArLst[2].Bottom :=0;
  ActArFntSzLst[2]:=14;
  ActArFntAlLst[2]:=3;
  ActArActFlLst[2]:=false;
  ActArNameLst[3]:=IntToStr(NumCount)+' ��� � '+FormatFloat('000',StNum)+', ����� '+SmCB.Items[SmInd];
  BaseActArLst[3].Left   :=220;
  BaseActArLst[3].Top    :=190;
  BaseActArLst[3].Right  :=455;
  BaseActArLst[3].Bottom :=210;
  ActArFntSzLst[3]:=14;
  ActArFntAlLst[3]:=3;
  ActArActFlLst[3]:=true;
  ActArNameLst[4]:=ModRecLst[ModInd].Net;
  BaseActArLst[4].Left   :=350;
  BaseActArLst[4].Top    :=137;
  BaseActArLst[4].Right  :=455;
  BaseActArLst[4].Bottom :=157;
  ActArFntSzLst[4]:=14;
  ActArFntAlLst[4]:=3;
  ActArActFlLst[4]:=false;
  ActArNameLst[5]:=ModRecLst[ModInd].Pwr;
  BaseActArLst[5].Left   :=350;
  BaseActArLst[5].Top    :=115;
  BaseActArLst[5].Right  :=455;
  BaseActArLst[5].Bottom :=135;
  ActArFntSzLst[5]:=14;
  ActArFntAlLst[5]:=3;
  ActArActFlLst[5]:=false;
  ActArInd:=100;
end;
//����������� �������� ��������
procedure TForm1.PaintArea(i: Integer; act: Boolean);
var
  str : string;
  x   : integer;
begin
  if act then Img.Canvas.Font.Color:=clRed else Img.Canvas.Font.Color:=clBlue;
  Img.Canvas.Font.Size:=ActArFntSzLst[i];
  Img.Canvas.Font.Style:=[fsBold];
  str:=ActArNameLst[i];
  x:=0;
  case ActArFntAlLst[i] of
    1 : x:=0;
    2 : x:=round((BaseActArLst[i].Right-BaseActArLst[i].Left-Img.Canvas.TextWidth(str))/2);
    3 : x:=BaseActArLst[i].Right-BaseActArLst[i].Left-Img.Canvas.TextWidth(str);
  end;
  Img.Canvas.Pen.Color:=clWhite;
  Img.Canvas.Rectangle(BaseActArLst[i]);
  Img.Canvas.TextOut(BaseActArLst[i].Left+x,BaseActArLst[i].Top+1,str);
end;
//�� �������� "����" �����
procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  ModPn.Visible  :=false;
  DatePn.Visible :=false;
  SnPn.Visible   :=false;
  ActArInd:=100;
end;
//�� "���������" � ���� ����� ��������� �������
procedure TForm1.SpeedButton4Click(Sender: TObject);
var
  i : integer;
  str : string;
  fl:boolean;
begin
  SmInd:=SmCB.ItemIndex;
  str:=StNumEd.Text+NumCountED.Text;
  i:=1;
  fl:=false;
  while(i<=Length(str))and(not fl)do
    if(str[i] in ['0'..'9'])then inc(i) else fl:=true;
  if fl then MessageDlg('������ ����� ������ !',mtError,[mbOk],0) else
    begin
      StNum:=StrToInt(StNumEd.Text);
      NumCount:=StrToInt(NumCountED.Text);
      ActArInd:=100;
      SnPn.Visible:=false;
      ActArNameLst[3]:=IntToStr(NumCount)+' ��� � '+FormatFloat('000',StNum)+', ����� '+SmCB.Items[SmInd];
      self.PaintArea(3,false);
    end;
end;
//��������� ������� ���� �� �������
procedure TForm1.ImgMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i : integer;
begin
  ActArInd:=100;
  if self.InActiveAr(X,Y)=0 then
    begin
      ActArInd:=0;
      SnPn.Visible:=false;
      DatePn.Visible :=false;
      ModPn.Visible:=true;
      ModPn.Left:=round((self.ClientWidth-ModPn.Width)/2);
      ModPn.Top:=round((self.ClientHeight-ModPn.Height)/2);
      ModLB.Items.Clear;
      for I := 0 to ModCount - 1 do ModLB.Items.Add(ModRecLst[i].Name);
    end;
  if self.InActiveAr(X,Y)=1 then
    begin
      ActArInd:=1;
      SnPn.Visible:=false;
      ModPn.Visible:=false;
      DatePn.Visible:=true;
      DatePn.Left:=round((self.ClientWidth-DatePn.Width)/2);
      DatePn.Top:=round((self.ClientHeight-DatePn.Height)/2);
      Clnd.Date:=Now;
    end;
  if self.InActiveAr(X,Y)=2 then
    begin
      ActArInd:=2;
      SnPn.Visible:=false;
      DatePn.Visible :=false;
      ModPn.Visible:=true;
      ModPn.Left:=round((self.ClientWidth-ModPn.Width)/2);
      ModPn.Top:=round((self.ClientHeight-ModPn.Height)/2);
      ModLB.Items.Clear;
      //for I := 0 to OTKNameCount - 1 do ModLB.Items.Add(OTKNameLst[i]);
    end;
  if self.InActiveAr(X,Y)=3 then
    begin
      ActArInd:=3;
      DatePn.Visible :=false;
      ModPn.Visible:=false;
      SnPn.Visible:=true;
      SnPn.Left:=round((self.ClientWidth-SnPn.Width)/2);
      SnPn.Top:=round((self.ClientHeight-SnPn.Height)/2);
      StNumED.Text:=IntToStr(StNum);
      NumCountED.Text:=IntToStr(NumCount);
      SmCB.ItemIndex:=SmInd;
    end;
end;
//��������� �������� ���� �� �������
procedure TForm1.ImgMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i : integer;
begin
  for I := 0 to ArLstCount - 1 do self.PaintArea(i,false);
  i:=self.InActiveAr(x,y);
  if i>=0 then
    begin
     self.PaintArea(i,true);
      if i=0 then
        begin
          self.PaintArea(4,true);
          self.PaintArea(5,true);
        end;
    end;
end;
//����������� ���������� ���� ��� �������� ��������
function TForm1.InActiveAr(X: Integer; Y: Integer): integer;
var
  i,res : integer;
begin
  res:=-1;
  I := 0;
  while((i<ArLstCount)and(res<0))do
    if (X>BaseActArLst[i].Left*M)and(X<BaseActArLst[i].Right*M)
      and(Y>BaseActArLst[i].Top*M)and(Y<BaseActArLst[i].Bottom*M)
      and(ActArActFlLst[i]) then res:=i
    else inc(i);
  result:=res;
end;
//���� � "����" ������ ������/����� ���������� ���
procedure TForm1.ModLBDblClick(Sender: TObject);
begin
  if (ModLB.ItemIndex>=0)and(ActArInd=0) then
    begin
      ModPn.Visible:=false;
      ActArNameLst[0]:=ModRecLst[ModLB.ItemIndex].Name;
      ActArNameLst[4]:=ModRecLst[ModLB.ItemIndex].Net;
      ActArNameLst[5]:=ModRecLst[ModLB.ItemIndex].Pwr;
      ModInd:=ModLB.ItemIndex;
      self.PaintArea(0,false);
      self.PaintArea(4,false);
      self.PaintArea(5,false);
    end;
  if (ModLB.ItemIndex>=0)and(ActArInd=2) then
    begin
      ModPn.Visible:=false;
      //ActArNameLst[2]:=OTKNameLst[ModLB.ItemIndex];
      //OTKInd:=ModLB.ItemIndex;
      self.PaintArea(2,false);
    end;
  ActArInd:=100;
end;
//����� ����, ������� �������� ���� ������ �� ����������� ������ �������
procedure TForm1.FormShow(Sender: TObject);
var
  i : integer;
begin
  //self.Height:=round(screen.Height-(screen.Height/4));
  //self.Width:=round(self.Width+Img.Height*BaseImgWidth/BaseImgHeight-Img.Width);
  PrBtn.Left:=round((self.ClientWidth-PrBtn.Width)/2);
  M:=img.Height/BaseImgHeight;
  for i := 0 to ArLstCount - 1 do self.PaintArea(i,false);
end;

end.
