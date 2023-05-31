unit EmpCntForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TEmpCountForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    BtmPn: TPanel;
    Panel2: TPanel;
    DecBtn: TSpeedButton;
    IncBtn: TSpeedButton;
    CntLB: TLabel;
    OkBtn: TSpeedButton;
    CancelBtn: TSpeedButton;
    InfoLb: TLabel;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CancelBtnClick(Sender: TObject);
    procedure IncBtnClick(Sender: TObject);
    procedure DecBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function  MyGetCount(text:string;curcnt:integer; HideButtons:boolean):integer;

var
  EmpCountForm: TEmpCountForm=nil;

implementation

{$R *.dfm}

procedure TEmpCountForm.CancelBtnClick(Sender: TObject);
begin
  self.ModalResult:=mrCancel;
end;

procedure TEmpCountForm.IncBtnClick(Sender: TObject);
var
  cnt: word;
begin
  cnt:=StrToInt(CntLB.Caption);
  if cnt<50 then inc(cnt);
  CntLB.Caption:=IntToStr(cnt);
end;

procedure TEmpCountForm.OkBtnClick(Sender: TObject);
begin
  self.ModalResult:=mrOK;
end;

procedure TEmpCountForm.DecBtnClick(Sender: TObject);
var
  cnt: word;
begin
  cnt:=StrToInt(CntLB.Caption);
  if cnt>1 then dec(cnt);
  CntLB.Caption:=IntToStr(cnt);
end;

procedure TEmpCountForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  cnt: word;
begin
  cnt:=StrToInt(CntLB.Caption);
  case key of
    38 : if cnt<50 then inc(cnt);
    40 : if cnt>1 then dec(cnt);
    13 : self.ModalResult:=mrOK;
    27 : self.ModalResult:=mrCancel;
  end;
  CntLB.Caption:=IntToStr(cnt);
end;

function  MyGetCount(text:string; curcnt:integer; HideButtons:boolean):integer;
begin
    EmpCountForm:= TEmpCountForm.Create(application);
    EmpCountForm.Label1.Caption:=text;
    with EmpCountForm do begin
      CntLB.Caption:=IntToStr(curcnt);
      DecBtn.Visible:=not HideButtons;
      IncBtn.Visible:=not HideButtons;
      OkBtn.Visible:=not HideButtons;
      CancelBtn.Visible:=not HideButtons;
      InfoLb.Visible:=HideButtons;
    end;
    if EmpCountForm.ShowModal=mrOK then result:=StrToInt(EmpCountForm.CntLB.Caption)
      else result:=curcnt;
    EmpCountForm.Free;
    EmpCountForm:=nil;
end;

end.
