unit unProgDlls;

interface
uses Windows, SysUtils, Classes;

const DLL_EXT = '.DLL';
type

  TPinSetProc   = procedure (aState : Integer); stdcall; // 0 = Low, 1 = High
  TPinGetFunc   = function () : integer; stdcall;
  TPowerProc    = procedure(); stdcall;
  TInitFunc     = function () : boolean; stdcall;
  TBoolFunc     = function () : boolean; stdcall;
  TProgNameFunc = function ()  : Pchar; stdcall;
  TSetupProgFunc= function (AppHandle : THandle) : integer; stdcall;
  TSetActualChip= procedure( aChipName : PChar );stdcall;

  TProgrammer = class
  private
    FProgName : string;
    FProgDll  : string;
  public
    constructor Create(aProgName, aProgDLL : string); reintroduce;
    property ProgName : string read FProgName write FProgName;
    property ProgDll  : string read FProgDll write  FProgDll;
  end;

  TICProgrammers = class
  private
    FProgsList : TList;
    function  GetProgrammer(index : integer): TProgrammer;
    procedure SetProgrammer(index : integer; const aProgrammer : TProgrammer);

  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;

    property ProgsList                    : TList       read FProgsList    write FProgsList;
    property Items[ index : integer] : TProgrammer read GetProgrammer write SetProgrammer; default;
  end;


function LoadProgDll(const aDllName : string) : boolean;
function IsProgDll(const aDllName : string; var aProgName : string) : boolean;
procedure FindProgDlls(const aPath : string);



var ICProgrammers : TICProgrammers;
    ProgLibHandle : THandle = 0; // handle of the currently loaded DLL

// ICProgs Procedures

  InitDll        : TInitFunc   = nil;
  DoneDll        : TInitFunc   = nil;
  SetupProgrammer: TSetupProgFunc = nil;
  SetActualChip  : TSetActualChip = nil;
  SetMCLR        : TPinSetProc = nil;
  SetDataOut     : TPinSetProc = nil;
  SetClock       : TPinSetProc = nil;
  GetData        : TPinGetFunc = nil;
  Power_On       : TPowerProc  = nil;
  Power_Off      : TPowerProc  = nil;
  IsICProgAddon  : TBoolFunc   = nil;
  GetProgrammerName : TProgNameFunc = nil;


implementation

uses Dialogs;


procedure UnloadProgDll();
begin
  if ProgLibHandle <> 0 then begin // a DLL is already Loaded we must unload it before.
    DoneDll(); // call DoneDll  **************** CALL DoneDLL
    FreeLibrary(ProgLibHandle);
    ProgLibHandle := 0;
  end;
end;


function IsProgDll(const aDllName : string; var aProgName : string) : boolean;
var LibHandle : THandle;
    Loc_IsICProgAddon     : TBoolFunc;
    Loc_GetProgrammerName : TProgNameFunc;
begin
  LibHandle := 0;
  aProgName := '';
  result := False;
  if FileExists(aDllName) then begin
    try
      try
        LibHandle := LoadLibrary(PChar(aDllName));
        if LibHandle = 0 then raise Exception.Create('');

        @Loc_IsICProgAddon := GetProcAddress(LibHandle, 'IsICProgAddon');
        if @Loc_IsICProgAddon = nil then raise Exception.Create('');

        @Loc_GetProgrammerName := GetProcAddress(LibHandle, 'GetProgrammerName');
        if @Loc_GetProgrammerName = nil then raise Exception.Create('');

        if Loc_IsICProgAddon then begin
          result := True;
          aProgName := String(Loc_GetProgrammerName() );
        end;
      except
        on e : exception do begin
          result := False;
          aProgName := '';
        end;
      end;
    finally
      FreeLibrary(LibHandle);
    end;
  end;
end;





function LoadProgDll(const aDllName : string) : boolean;
const ERR_LOAD_DLL_MSG = 'Error Loading %s module';
begin

  UnloadProgDll();

  try
    ProgLibHandle := LoadLibrary(PChar(aDllName));
    if ProgLibHandle = 0 then raise Exception.Create('');

    @InitDll       := GetProcAddress(ProgLibHandle, 'InitDll');
    if @InitDll = nil then raise Exception.Create('');

    @DoneDll       := GetProcAddress(ProgLibHandle, 'DoneDll');
    if @DoneDll = nil then raise Exception.Create('');

    @SetupProgrammer := GetProcAddress(ProgLibHandle, 'SetupProgrammer');
    if @SetupProgrammer = nil then raise Exception.Create('');

    @SetActualChip := GetProcAddress(ProgLibHandle, 'SetActualChip');
    if @SetActualChip = nil then raise Exception.Create('');

    @SetMCLR       := GetProcAddress(ProgLibHandle, 'SetMCLR');
    if @SetMCLR = nil then raise Exception.Create('');

    @SetDataOut    := GetProcAddress(ProgLibHandle, 'SetDataOut');
    if @SetDataOut = nil then raise Exception.Create('');

    @SetClock      := GetProcAddress(ProgLibHandle, 'SetClock');
    if @SetClock = nil then raise Exception.Create('');

    @GetData       := GetProcAddress(ProgLibHandle, 'GetData');
    if @GetData = nil then raise Exception.Create('');

    @Power_On      := GetProcAddress(ProgLibHandle, 'PowerOn');
    if @Power_On = nil then raise Exception.Create('');

    @Power_Off     := GetProcAddress(ProgLibHandle, 'PowerOff');
    if @Power_Off = nil then raise Exception.Create('');

    @IsICProgAddon := GetProcAddress(ProgLibHandle, 'IsICProgAddon');
    if @IsICProgAddon = nil then raise Exception.Create('');

    @GetProgrammerName := GetProcAddress(ProgLibHandle, 'GetProgrammerName');
    if @GetProgrammerName = nil then raise Exception.Create('');

    result := True;
    InitDll();

    
  except
    on e : exception do begin
      result := False;
      MessageDlg( Format(ERR_LOAD_DLL_MSG, [aDllName]), mtError, [mbOk],0);
      InitDll       := nil;
      DoneDll       := nil;
      SetMCLR       := nil;
      SetDataOut    := nil;
      SetClock      := nil;
      GetData       := nil;
      Power_On      := nil;
      Power_Off     := nil;
      IsICProgAddon := nil;
      GetProgrammerName := nil;
      SetupProgrammer := nil;
      SetActualChip   := nil;
      FreeLibrary(ProgLibHandle);
      ProgLibHandle := 0;
    end;
  end;

end;


procedure FindProgDlls(const aPath : string);
var sRec       : TSearchRec;
    sProgName  : string;
    FoundProg  : TProgrammer;
begin
  if Assigned(ICProgrammers) then ICProgrammers.Clear
                             else ICProgrammers := TICProgrammers.Create; // this should never occur
  if FindFirst(aPath + '\*.dll', faAnyFile, sRec) = 0 then begin
    repeat
      if UpperCase(ExtractFileExt(sRec.Name)) = DLL_EXT then begin // if it's .DLL
        if IsProgDll(aPath + '\'+sRec.Name, sProgName) then begin
          FoundProg := TProgrammer.Create(sProgName, aPath + '\'+sRec.Name);
          ICProgrammers.ProgsList.Add(FoundProg);

        end;
      end;
    until FindNext(sRec) <> 0;
    FindClose(sRec);
  end;
end;

{ TICProgrammers }
procedure TICProgrammers.Clear;
var i : integer;
begin
  for i := 0 to FProgsList.Count-1 do TProgrammer(FProgsList[i]).Free;
  FProgsList.Clear;
end;

constructor TICProgrammers.Create;
begin
  inherited;
  FProgsList := TList.Create;
end;

destructor TICProgrammers.Destroy;
var i : integer;
begin
  for i := 0 to FProgsList.Count-1 do TProgrammer(FProgsList[i]).Free;
  FProgsList.Free;
  inherited;
end;

function TICProgrammers.GetProgrammer(index : integer): TProgrammer;
begin
  if (index>=0) and (index<FProgsList.Count) then
    result := TProgrammer(FProgsList[index])
  else
    raise ERangeError.Create('Index '+ IntToStr(index)+
                             'out of range in function TProgsList.GetProgrammer' );
end;

procedure TICProgrammers.SetProgrammer(index : integer; const aProgrammer : TProgrammer);
begin
  if (index>=0) and (index<FProgsList.Count) then
    FProgsList[index] := aProgrammer
  else
    raise ERangeError.Create('Index '+ IntToStr(index)+
                             'out of range in function TProgsList.SetProgrammer' );
end;

{ TProgrammer }

constructor TProgrammer.Create(aProgName, aProgDLL: string);
begin
  inherited Create;
  FProgName := aProgName;
  FProgDll  := aProgDLL;
end;

initialization
  ICProgrammers := TICProgrammers.Create;

  
finalization
  ICProgrammers.Free;
  UnloadProgDll();

end.
