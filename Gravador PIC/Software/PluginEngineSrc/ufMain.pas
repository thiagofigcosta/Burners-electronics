unit ufMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmMain = class(TForm)
    btnEnumProg: TButton;
    ListBox1: TListBox;
    btnLoadProgDll: TButton;
    btnSetupProg: TButton;
    procedure btnEnumProgClick(Sender: TObject);
    procedure btnLoadProgDllClick(Sender: TObject);
    procedure btnSetupProgClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmMain: TfrmMain;

implementation

uses unProgDlls;

{$R *.dfm}

procedure TfrmMain.btnEnumProgClick(Sender: TObject);
var   i : integer;
begin
 ListBox1.Clear;
 FindProgDlls(ExtractFilePath(Application.ExeName));
 for i := 0 to ICProgrammers.ProgsList.Count-1 do
   ListBox1.Items.Add(ICProgrammers[i].ProgDll + '   : ' +  ICProgrammers[i].ProgName );
end;

procedure TfrmMain.btnLoadProgDllClick(Sender: TObject);
var ndx : integer;
begin
//  LoadProgDll('JDMProg.dll');
  ndx := ListBox1.ItemIndex;
  if ndx >-1 then begin
    if assigned(DoneDLL) then DoneDll; // first time there is no DLL loaded so we
                                       // must check if the DonneDLL is assigned
    LoadProgDll(ICProgrammers[ndx].ProgDll);
    // After loading a progDLL we MUST CALL
    InitDLL();
  end
  else
    ShowMessage('You Must Select a programmer');
end;

procedure TfrmMain.btnSetupProgClick(Sender: TObject);
begin
  SetupProgrammer(application.Handle);
end;

end.
