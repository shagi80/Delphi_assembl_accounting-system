program OTK2;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  DataUnit in 'DataUnit.pas',
  ProcUnit in 'ProcUnit.pas' {DataMod: TDataModule},
  ProdMsgUnit in 'ProdMsgUnit.pas' {ProdMsgForm},
  WarningUnit in 'WarningUnit.pas' {WarningForm},
  ShadowForm in 'ShadowForm.pas' {Shadow},
  ModelSelectUnit in 'ModelSelectUnit.pas' {ModelSelectForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDataMod, DataMod);
  Application.Run;
end.
