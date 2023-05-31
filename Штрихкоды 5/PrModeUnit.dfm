object PrModeForm: TPrModeForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1056#1077#1078#1080#1084' '#1087#1077#1095#1072#1090#1080
  ClientHeight = 121
  ClientWidth = 218
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 218
    Height = 81
    Align = alTop
    TabOrder = 0
    object RadioGroup1: TRadioGroup
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 210
      Height = 73
      Align = alClient
      Caption = #1042#1099#1073#1086#1088' '#1088#1077#1078#1080#1084#1072' '#1087#1077#1095#1072#1090#1080': '
      ItemIndex = 1
      Items.Strings = (
        '10 '#1085#1072' '#1083#1080#1089#1090#1077
        #1085#1072' '#1101#1090#1080#1082#1077#1090'-'#1083#1077#1085#1090#1077' 8'#1093'8 '#1089#1084)
      TabOrder = 0
    end
  end
  object BitBtn1: TBitBtn
    Left = 32
    Top = 87
    Width = 75
    Height = 25
    TabOrder = 1
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 108
    Top = 87
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    Kind = bkCancel
  end
end
