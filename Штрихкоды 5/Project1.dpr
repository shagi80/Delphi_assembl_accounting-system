program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  PrModeUnit in 'PrModeUnit.pas' {PrModeForm},
  HelpUnit in 'HelpUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.HelpFile := 'C:\Users\������� ������\������� ���������\Borland Studio Projects\������� ��\���������3\Help.chm';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TPrModeForm, PrModeForm);
  Application.Run;
end.
