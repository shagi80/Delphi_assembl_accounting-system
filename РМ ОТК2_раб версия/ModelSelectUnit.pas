unit ModelSelectUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls;

type
  TModelSelectForm = class(TForm)
    ScrBox: TScrollBox;
    DownBtn: TSpeedButton;
    UpBtn: TSpeedButton;
    CancelBtn: TSpeedButton;
    Shape1: TShape;
    procedure DownBtnClick(Sender: TObject);
    procedure UpBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure BtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function GetNewModel:integer;

implementation

{$R *.dfm}



uses ProcUnit;

const
  ScrStep = 80;

var
  resId : integer=-1;

function GetNewModel:integer;
var
  Form: TModelSelectForm;
  i   : integer;
  Btn : TButton;
begin
  Form:=TModelSelectForm.Create(application);
  for I := 0 to high(ModRecLst) do begin
    Btn := TButton.Create(form);
    Btn.Name:='btn'+inttostr(i);
    Btn.Font.Size:=16;
    Btn.Font.Style:=[fsBold];
    Btn.Caption:=ModRecLst[i].name;
    Btn.Align:=alTop;
    Btn.AlignWithMargins:=true;
    Btn.Margins.Bottom:=20;
    Btn.Height:=ScrStep-Btn.Margins.Bottom;
    Btn.OnClick:=Form.BtnClick;
    Form.ScrBox.InsertControl(Btn);
  end;
  Form.ScrBox.VertScrollBar.Position:=0;
  if (form.ShowModal=mrOk)and(resID>=0) then result:=resID else result:=-1;
  Form.Free;
end;

procedure TModelSelectForm.BtnClick(Sender: TObject);
var
  str: string;
begin
  str:=(sender as TButton).Name;
  resID:=StrToIntDef(copy(str,4,MaxInt),-1);
  self.ModalResult:=mrOk;
end;

procedure TModelSelectForm.CancelBtnClick(Sender: TObject);
begin
  self.ModalResult:=mrcancel;
end;

procedure TModelSelectForm.DownBtnClick(Sender: TObject);
begin
  ScrBox.VertScrollBar.Position:=ScrBox.VertScrollBar.Position+ScrStep;
end;

procedure TModelSelectForm.UpBtnClick(Sender: TObject);
begin
  if ScrBox.VertScrollBar.Position>0 then
    ScrBox.VertScrollBar.Position:=ScrBox.VertScrollBar.Position-ScrStep;
  if ScrBox.VertScrollBar.Position<0 then ScrBox.VertScrollBar.Position:=0;
end;

end.
