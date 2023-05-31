unit WarningUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls;

type
  TWarningForm = class(TForm)
    Image1: TImage;
    CaptionLB: TLabel;
    TextLb: TLabel;
    OkBtn: TSpeedButton;
    CancelBtn: TSpeedButton;
    procedure OkBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ShowWarningMsg(Capt,txt:string):boolean;

implementation

{$R *.dfm}

var
  showresult:boolean;

function ShowWarningMsg(Capt,txt:string):boolean;
var
  WarForm: TWarningForm;
begin
  result:=false;
  WarForm:= TWarningForm.Create(application);
  with WarForm do begin
    CaptionLb.Caption:=capt;
    TextLb.Caption:=txt;
    ShowResult:=false;
    beep;
    ShowModal;
    result:=ShowResult;
  end;
  WarForm.Free;
end;

procedure TWarningForm.CancelBtnClick(Sender: TObject);
begin
  self.Close;
end;

procedure TWarningForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    32 : self.OkBtnClick(self);
    27 : self.CancelBtnClick(self);
  end;
end;

procedure TWarningForm.OkBtnClick(Sender: TObject);
begin
  ShowResult:=true;
  Close;
end;

end.
