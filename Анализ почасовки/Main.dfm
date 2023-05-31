object Form1: TForm1
  Left = 0
  Top = 0
  Caption = #1040#1085#1072#1083#1080#1079' '#1089#1090#1072#1090#1080#1089#1090#1082#1080' '#1087#1077#1088#1077#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103' '#1087#1083#1072#1085#1072' '#1079#1072' '#1095#1072#1089
  ClientHeight = 399
  ClientWidth = 1113
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 189
    Width = 1113
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
    ExplicitLeft = 1
    ExplicitTop = 156
    ExplicitWidth = 108
  end
  object SGPanel: TPanel
    Left = 0
    Top = 50
    Width = 1113
    Height = 139
    Align = alClient
    BevelOuter = bvLowered
    Color = clWhite
    TabOrder = 0
    object SG: TStringGrid
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 1105
      Height = 131
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Ctl3D = False
      FixedCols = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
      ParentCtl3D = False
      TabOrder = 0
    end
  end
  object TopPn: TPanel
    Left = 0
    Top = 0
    Width = 1113
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object AddBtn: TButton
      AlignWithMargins = True
      Left = 719
      Top = 13
      Width = 75
      Height = 28
      Margins.Top = 13
      Margins.Bottom = 9
      Align = alLeft
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 0
      OnClick = AddBtnClick
    end
    object GroupBox1: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 710
      Height = 44
      Align = alLeft
      Caption = #1042#1099#1073#1086#1088#1082#1072' '#1079#1072' '#1087#1077#1088#1080#1086#1076': '
      TabOrder = 1
      object EndDateBtn: TSpeedButton
        AlignWithMargins = True
        Left = 166
        Top = 18
        Width = 23
        Height = 21
        Align = alLeft
        Caption = '...'
        OnClick = EndDateBtnClick
        ExplicitLeft = 96
        ExplicitTop = -24
        ExplicitHeight = 22
      end
      object StDateBtn: TSpeedButton
        AlignWithMargins = True
        Left = 71
        Top = 18
        Width = 23
        Height = 21
        Align = alLeft
        Caption = '...'
        OnClick = StDateBtnClick
        ExplicitLeft = 96
        ExplicitTop = -24
        ExplicitHeight = 22
      end
      object StatLogDirBtn: TSpeedButton
        AlignWithMargins = True
        Left = 589
        Top = 18
        Width = 23
        Height = 21
        Align = alRight
        Caption = '...'
        OnClick = StatLogDirBtnClick
        ExplicitLeft = 427
        ExplicitTop = 20
      end
      object EndDateED: TMaskEdit
        AlignWithMargins = True
        Left = 100
        Top = 18
        Width = 60
        Height = 21
        Align = alLeft
        Ctl3D = False
        EditMask = '!99/99/00;1;_'
        MaxLength = 8
        ParentCtl3D = False
        TabOrder = 0
        Text = '  .  .  '
        ExplicitHeight = 19
      end
      object StDateED: TMaskEdit
        AlignWithMargins = True
        Left = 5
        Top = 18
        Width = 60
        Height = 21
        Align = alLeft
        Ctl3D = False
        EditMask = '!99/99/00;1;_'
        MaxLength = 8
        ParentCtl3D = False
        TabOrder = 1
        Text = '  .  .  '
        ExplicitHeight = 19
      end
      object PrdAddBtn: TBitBtn
        AlignWithMargins = True
        Left = 618
        Top = 18
        Width = 87
        Height = 21
        Align = alRight
        Caption = #1057#1092#1086#1088#1084#1080#1088#1086#1074#1072#1090#1100
        TabOrder = 2
        OnClick = PrdAddBtnClick
        ExplicitTop = 20
      end
      object StatLogDirED: TEdit
        AlignWithMargins = True
        Left = 202
        Top = 18
        Width = 381
        Height = 21
        Margins.Left = 10
        Align = alClient
        TabOrder = 3
        Text = 'StatLogDirED'
      end
    end
    object SortBtn: TButton
      AlignWithMargins = True
      Left = 881
      Top = 13
      Width = 75
      Height = 28
      Margins.Top = 13
      Margins.Bottom = 9
      Align = alLeft
      Caption = #1057#1086#1088#1090#1080#1088#1086#1074#1072#1090#1100
      TabOrder = 2
      OnClick = SortBtnClick
    end
    object DelBtn: TButton
      AlignWithMargins = True
      Left = 800
      Top = 13
      Width = 75
      Height = 28
      Margins.Top = 13
      Margins.Bottom = 9
      Align = alLeft
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 3
      OnClick = DelBtnClick
    end
    object ExportBtn: TBitBtn
      AlignWithMargins = True
      Left = 962
      Top = 13
      Width = 75
      Height = 28
      Margins.Top = 13
      Margins.Bottom = 9
      Align = alLeft
      Caption = #1069#1082#1089#1087#1086#1088#1090' TXT'
      TabOrder = 4
      OnClick = ExportBtnClick
    end
  end
  object BtmPn: TPanel
    Left = 0
    Top = 192
    Width = 1113
    Height = 207
    Align = alBottom
    BevelOuter = bvLowered
    Color = clWhite
    TabOrder = 2
    object PB: TPaintBox
      AlignWithMargins = True
      Left = 4
      Top = 6
      Width = 1105
      Height = 190
      Margins.Top = 5
      Margins.Bottom = 10
      Align = alClient
      Color = clWhite
      ParentColor = False
      Visible = False
      OnPaint = PBPaint
      ExplicitLeft = 0
      ExplicitTop = 262
      ExplicitWidth = 865
      ExplicitHeight = 143
    end
  end
  object OpenDlg: TOpenDialog
    Left = 832
    Top = 56
  end
  object SaveDlg: TSaveTextFileDialog
    DefaultExt = '*.txt'
    Filter = #1058#1077#1082#1089#1090#1086#1074#1099#1077' '#1092#1072#1081#1083#1099'|*.tzt'
    Title = #1069#1082#1089#1087#1086#1088#1090' '#1074' TXT'
    Left = 864
    Top = 56
  end
end
