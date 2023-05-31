unit OTKPayUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TOTKPayForm = class(TForm)
    OTK1Total: TLabel;
    OTK1Fault: TLabel;
    OTK2Total: TLabel;
    OTK2Fault: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    OTK1Sum: TLabel;
    OTK2Sum: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OTKPayForm: TOTKPayForm;

implementation

{$R *.dfm}

uses Dataunit, MsgUnit;

var
  t1, t2, f1, f2 : integer;
  sum1, sum2     : real;
  PayFileName    : string = 'OTKpay.txt';


procedure TOTKPayForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  f : TextFile;
begin
  if key=27 then self.Close;
  if key=13 then begin
    AssignFile(f,ExtractFilePath(application.ExeName)+'\'+PayFileName);
    if FileExists(ExtractFilePath(application.ExeName)+'\'+PayFileName) then
      Append(f) else rewrite(f);
    writeln(f,'"'+DateToStr(date)+'","'+TimeToStr(now)+'","'+IntToStr(t1)+'","'+IntToStr(f1)+'","'+
      FormatFloat('####0.00',sum1)+'","'+IntToStr(t2)+'","'+IntToStr(f2)+'","'+
      FormatFloat('####0.00',sum2)+'"');
    closefile(f);
    MessageFormShow(0,'','������ �������� � ����.',2);
    self.Close;
  end;
end;

procedure TOTKPayForm.FormShow(Sender: TObject);
var
  i,ind : integer;
begin
  //������ ���������
  t1:=Logs.Count;
  OTK1Total.Caption:='����� ���������: '+inttostr(t1)+' �� ('+FormatFloat('###0.00',OTK1cntPay)+
    ' ��� � '+inttostr(t1)+' �� = '+FormatFloat('###0.00',t1*OTK1cntPay)+' ��� )';
  f1:=0;
  for I := 0 to Logs.Count - 1 do begin
     if logs.Item[i].scnum=1 then begin
      ind:=FixCodeList.IndByCode(logs.Item[i].code);
      if ind>-1 then inc(f1);
     end;
  end;
  OTK1Fault.Caption:='������� ��������������: '+inttostr(f1)+' �� ('+FormatFloat('###0.00',OTK1faultPay)+
    ' ��� � '+inttostr(f1)+' �� = '+FormatFloat('###0.00',f1*OTK1faultPay)+' ��� )';
  sum1:=t1*OTK1cntPay+f1*OTK1faultPay;
  OTK1Sum.Caption:='����� ��������� �� ����� �� ��������� ������: '+FormatFloat('###0.00',sum1)+' ���';
  // ������ ���������
  t2:= t1-f1;
  OTK2Total.Caption:='����� ���������: '+inttostr(t2)+' �� ('+FormatFloat('###0.00',OTK2cntPay)+
    ' ��� � '+inttostr(t2)+' �� = '+FormatFloat('###0.00',t2*OTK2cntPay)+' ��� )';
  f2:=0;
  for I := 0 to Logs.Count - 1 do begin
     if logs.Item[i].scnum=2 then begin
      ind:=FixCodeList.IndByCode(logs.Item[i].code);
      if ind>-1 then inc(f2);
     end;
  end;
  OTK2Fault.Caption:='������� ��������������: '+inttostr(f2)+' �� ('+FormatFloat('###0.00',OTK2faultPay)+
    ' ��� � '+inttostr(f2)+' �� = '+FormatFloat('###0.00',f2*OTK2faultPay)+' ��� )';
  sum2:=t2*OTK2cntPay+f2*OTK2faultPay;
  OTK2Sum.Caption:='����� ��������� �� ����� �� ��������� ������: '+FormatFloat('###0.00',sum2)+' ���';
end;

end.
