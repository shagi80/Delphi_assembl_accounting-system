unit ProdMsgUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TProdMsgForm = class(TForm)
    MainTimer: TTimer;
    TimeLb: TLabel;
    CloseBtn: TBitBtn;
    Label1: TLabel;
    ModelLB: TLabel;
    NumberLb: TLabel;
    Image1: TImage;
    procedure MainTimerTimer(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowProdMsg(time,model,number:string;showsecond:integer;showbtn:boolean);

implementation

{$R *.dfm}


var
  showtime : integer;

procedure ShowProdMsg(time,model,number:string;showsecond:integer;showbtn:boolean);
var
  MsgForm : TProdMsgForm;
begin
  MsgForm:=TProdMsgForm.Create(application);
  with MsgForm do begin
    Caption:=time;
    if showsecond>0 then begin
      ShowTime:=showsecond;
      MainTimer.Enabled:=true;
      TimeLb.Caption:='��� ���� ������������� ��������� ����� '+IntToStr(showtime)+' ������';
    end else begin
      MainTimer.Enabled:=false;
      TimeLb.Caption:='��� �������� ����� ���� ������� ������ "��"';
    end;
    CloseBtn.Visible:=showbtn;
    ModelLb.Caption:=model;
    NumberLB.Caption:='�����-��� � '+Number;
    beep;
    ShowModal;
  end;
  MsgForm.Free;
end;

procedure TProdMsgForm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TProdMsgForm.MainTimerTimer(Sender: TObject);
begin
  dec(ShowTime);
  TimeLb.Caption:='��� ���� ������������� ��������� ����� '+IntToStr(showtime)+' ������';
  if showtime<=0 then Self.Close;
end;

end.
