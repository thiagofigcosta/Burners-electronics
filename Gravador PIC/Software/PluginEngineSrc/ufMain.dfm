object frmMain: TfrmMain
  Left = 460
  Top = 332
  Width = 466
  Height = 295
  Caption = 'IC-Prog'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnEnumProg: TButton
    Left = 8
    Top = 216
    Width = 137
    Height = 33
    Caption = '(1) Enum Programmers'
    TabOrder = 0
    OnClick = btnEnumProgClick
  end
  object ListBox1: TListBox
    Left = 8
    Top = 24
    Width = 441
    Height = 185
    ItemHeight = 13
    TabOrder = 1
    TabWidth = 8
  end
  object btnLoadProgDll: TButton
    Left = 160
    Top = 216
    Width = 137
    Height = 33
    Caption = '(2) Load Programmer DLL'
    TabOrder = 2
    OnClick = btnLoadProgDllClick
  end
  object btnSetupProg: TButton
    Left = 312
    Top = 216
    Width = 137
    Height = 33
    Caption = '(3) Load Config Box '
    TabOrder = 3
    OnClick = btnSetupProgClick
  end
end
