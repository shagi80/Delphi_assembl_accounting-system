object OTKPayForm: TOTKPayForm
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = #1047#1072#1088#1072#1073#1086#1090#1086#1082' '#1082#1086#1085#1090#1088#1086#1083#1077#1088#1072
  ClientHeight = 366
  ClientWidth = 580
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object OTK1Total: TLabel
    Left = 56
    Top = 48
    Width = 76
    Height = 19
    Caption = 'OTK1Total'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object OTK1Fault: TLabel
    Left = 56
    Top = 73
    Width = 74
    Height = 19
    Caption = 'OTK1Fault'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object OTK2Total: TLabel
    Left = 56
    Top = 174
    Width = 76
    Height = 19
    Caption = 'OTK2Total'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object OTK2Fault: TLabel
    Left = 56
    Top = 199
    Width = 74
    Height = 19
    Caption = 'OTK2Fault'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 24
    Top = 16
    Width = 353
    Height = 23
    Caption = #1047#1072#1088#1072#1073#1086#1090#1086#1082' '#1082#1086#1085#1090#1088#1086#1083#1077#1088#1072' '#1085#1072' '#1056#1052' '#1054#1058#1050'1:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 24
    Top = 136
    Width = 353
    Height = 23
    Caption = #1047#1072#1088#1072#1073#1086#1090#1086#1082' '#1082#1086#1085#1090#1088#1086#1083#1077#1088#1072' '#1085#1072' '#1056#1052' '#1054#1058#1050'2:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object OTK1Sum: TLabel
    Left = 56
    Top = 98
    Width = 72
    Height = 19
    Caption = 'OTK1Sum'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object OTK2Sum: TLabel
    Left = 56
    Top = 224
    Width = 72
    Height = 19
    Caption = 'OTK2Sum'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 24
    Top = 272
    Width = 351
    Height = 23
    Caption = 'ESC - '#1079#1072#1082#1088#1099#1090#1100' '#1086#1082#1085#1086' '#1073#1077#1079' '#1089#1086#1093#1088#1072#1085#1077#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 24
    Top = 304
    Width = 486
    Height = 23
    Caption = 'ENTER - '#1079#1072#1087#1080#1089#1072#1090#1100' '#1076#1072#1085#1085#1099#1077' '#1074' '#1092#1072#1081#1083' '#1080' '#1079#1072#1082#1088#1099#1090#1100' '#1086#1082#1085#1086
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
end
