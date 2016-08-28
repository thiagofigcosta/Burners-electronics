program icprog;

uses
  Forms,
  ufMain in 'ufMain.pas' {frmMain},
  unProgDlls in 'unProgDlls.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
