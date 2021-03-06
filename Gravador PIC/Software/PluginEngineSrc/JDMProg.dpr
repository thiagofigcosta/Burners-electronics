//------------------------------------------------------------------------------
// JDMProg.DLL
// JDM Programmer DLL for ICProg
//
// Written by    : Ahmed Lazreg  ahmedlazreg@free.fr
// Last Revision : April 25, 2005
//
// Friendly given to Bonny Gijzen to be implemented in IC-Prog
//
// -----------------------------------------------------------------------------

library JDMProg;

uses
  SysUtils,
  Classes,
  Forms,
  Controls,
  Dialogs,
  Windows,
  unJDMProgSetting in 'unJDMProgSetting.pas' {frmJDMProgSetting};

{$R *.res}

const

  PROG_NAME  = 'JDM Programmer'; // The programmer name (will appear in ICProg
                                 // hadrware Menu

  REQ_ICPROG_VER = '105';        // required min ICProg version


function IsICProgAddon() : boolean; stdcall;
begin
  result := True;
end;

function GetProgrammerName() : Pchar; stdcall;
begin
  result := Pchar(PROG_NAME);
end;

function InitDll() : boolean; stdcall;
begin
  // do init stuff (global vars can be initialised/allocated here)
  ShowMessage(PROG_NAME + ' has been initialized !');
  result := True;
end;

function DoneDll() : boolean; stdcall;
begin
  // do prepare to quit DLL (Global vars can be Freed here)
  ShowMessage(PROG_NAME + ' has been ShutDown !');
  result := True;
end;

function SetupProgrammer(AppHandle : THandle) : integer; stdcall;
var FrmProgSetup : TfrmJDMProgSetting;
    oldAppHnd    : THandle;
begin
  //PS.  we must pass the calling application Handle because the DLL and the Main
  //Program does not share the same TApplication object, so to make the ProgSetting
  //Form MODAL we must pass it the Main Application Handle as Owner
  oldAppHnd := Application.Handle;
  Application.Handle := AppHandle;
  FrmProgSetup := TfrmJDMProgSetting.Create(Application);
  try
    if FrmProgSetup.ShowModal = mrOK then begin
      ShowMessage('Config accepted and Saved');
      result := 0;
    end
    else begin
      ShowMessage('You cancelled the Config Box');
      result := -1;
    end;
  finally
    FrmProgSetup.Free;
    Application.Handle := oldAppHnd;
  end;
end;

// Called by ICProg each time the user selects a new chip (and at startup)
Procedure SetActualChip( aChipName : PChar );stdcall; // 0 = Low, 1 = High
begin
end;

procedure SetMCLR( aState : Integer); stdcall; // 0 = Low, 1 = High
begin
end;

procedure SetDataOut( aState : Integer); stdcall; // 0 = Low, 1 = High
begin
end;

procedure SetClock( aState : Integer); stdcall; // 0 = Low, 1 = High
begin
end;

function GetData() : integer; stdcall;
begin
  result := 1; //get data pin
end;

procedure PowerOn(); stdcall;
begin
end;

procedure PowerOff(); stdcall;
begin
end;

exports
// EVERY Programmer DLL MUST exports these functions/Procedures
// PS. No function should return or have a STRING parameters
// All String MUST be passed as PChar to avoid the use of Borland ShareMem.dll
// and to permit the creation of prog dll usin other languages such as VisualC++
  IsICProgAddon,
  GetProgrammerName,
  InitDll,
  DoneDll,
  SetupProgrammer,
  SetActualChip,
  SetMCLR,
  SetDataOut,
  SetClock,
  GetData,
  PowerOn,
  PowerOff;

begin
end.
