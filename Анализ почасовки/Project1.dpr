program Project1;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  DataUnit in 'DataUnit.pas' {DataModule1: TDataModule},
  FixCodeUnit in 'FixCodeUnit.pas',
  DateUnit in 'DateUnit.pas' {DateForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TDateForm, DateForm);
  Application.Run;
end.
