program codeeditor;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {Editor},
  DataUnit in 'DataUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TEditor, Editor);
  Application.Run;
end.
