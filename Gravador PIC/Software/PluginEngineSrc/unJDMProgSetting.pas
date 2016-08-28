unit unJDMProgSetting;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons;

type
  TfrmJDMProgSetting = class(TForm)
    GroupBox4: TGroupBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    TrackBar1: TTrackBar;
    Label1: TLabel;
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmJDMProgSetting: TfrmJDMProgSetting;

implementation

{$R *.dfm}

end.
