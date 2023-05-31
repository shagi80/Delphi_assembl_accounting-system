unit DateUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls;

type
  TDateForm = class(TForm)
    MonthCalendar1: TMonthCalendar;
    OkBtn: TBitBtn;
    BitBtn2: TBitBtn;
    procedure MonthCalendar1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DateForm: TDateForm;

implementation

{$R *.dfm}

procedure TDateForm.MonthCalendar1DblClick(Sender: TObject);
begin
  self.ModalResult:=mrOK;
end;

end.
