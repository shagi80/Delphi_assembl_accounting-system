program PMOTK1;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  DataUnit in 'DataUnit.pas' {DataModule1: TDataModule},
  FixCodeUnit in 'FixCodeUnit.pas',
  DiagramClass in 'DiagramClass.pas',
  MsgUnit in 'MsgUnit.pas' {MsgForm},
  EmpCntForm in 'EmpCntForm.pas' {EmpCountForm},
  OTKPayUnit in 'OTKPayUnit.pas' {OTKPayForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TOTKPayForm, OTKPayForm);
  Application.Run;
end.
