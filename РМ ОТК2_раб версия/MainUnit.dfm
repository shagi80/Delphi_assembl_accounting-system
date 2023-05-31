object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'MainForm'
  ClientHeight = 562
  ClientWidth = 896
  Color = clAppWorkSpace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 543
    Width = 896
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object MainPN: TPanel
    Left = 0
    Top = 41
    Width = 664
    Height = 502
    Align = alClient
    BevelOuter = bvNone
    Color = clAppWorkSpace
    TabOrder = 1
    object TopPN: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 644
      Height = 73
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alTop
      Caption = #1044#1086#1073#1088#1086' '#1087#1086#1078#1072#1083#1086#1074#1072#1090#1100' !'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -37
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
    end
    object MiddlePN: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 103
      Width = 644
      Height = 170
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alTop
      TabOrder = 1
      object Label3: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 636
        Height = 28
        Align = alTop
        AutoSize = False
        Caption = '  '#1054#1073#1097#1080#1077' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1087#1088#1086#1080#1079#1074#1086#1076#1089#1090#1074#1072
        Color = clActiveCaption
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Layout = tlCenter
        ExplicitTop = 7
        ExplicitWidth = 612
      end
      object ProdSG: TStringGrid
        AlignWithMargins = True
        Left = 4
        Top = 38
        Width = 445
        Height = 121
        Margins.Bottom = 10
        Align = alClient
        ColCount = 3
        Ctl3D = False
        DefaultRowHeight = 40
        Enabled = False
        FixedCols = 0
        RowCount = 3
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -29
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        OnDrawCell = ProdSGDrawCell
        ColWidths = (
          198
          103
          90)
      end
      object GroupBox1: TGroupBox
        AlignWithMargins = True
        Left = 455
        Top = 38
        Width = 185
        Height = 121
        Margins.Bottom = 10
        Align = alRight
        Caption = #1042#1089#1077#1075#1086' '#1087#1088#1086#1080#1079#1074#1077#1076#1077#1085#1086':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        object TotProdLB: TLabel
          AlignWithMargins = True
          Left = 5
          Top = 28
          Width = 175
          Height = 81
          Margins.Top = 10
          Margins.Bottom = 10
          Align = alClient
          Alignment = taCenter
          Caption = '000'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -64
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          ExplicitWidth = 123
          ExplicitHeight = 77
        end
      end
    end
    object FaultPN: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 293
      Width = 644
      Height = 112
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 20
      Align = alTop
      AutoSize = True
      BevelKind = bkFlat
      BevelOuter = bvNone
      TabOrder = 2
      object Label2: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 634
        Height = 28
        Align = alTop
        AutoSize = False
        Caption = '  '#1057#1087#1080#1089#1086#1082' '#1085#1072#1080#1073#1086#1083#1077#1077' '#1095#1072#1089#1090#1099#1093' '#1085#1077#1080#1089#1087#1088#1072#1074#1085#1086#1089#1090#1077#1081
        Color = clActiveCaption
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = 5
        ExplicitTop = -5
        ExplicitWidth = 460
      end
      object FaultSG: TStringGrid
        AlignWithMargins = True
        Left = 3
        Top = 37
        Width = 634
        Height = 61
        Margins.Bottom = 10
        Align = alTop
        ColCount = 4
        Enabled = False
        FixedCols = 0
        FixedRows = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        ParentFont = False
        TabOrder = 0
        ColWidths = (
          243
          62
          105
          64)
      end
    end
    object EmPn: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 441
      Width = 644
      Height = 41
      Margins.Left = 10
      Margins.Right = 10
      Margins.Bottom = 20
      Align = alBottom
      TabOrder = 3
      Visible = False
      object Label4: TLabel
        Left = 9
        Top = 13
        Width = 125
        Height = 13
        Caption = #1069#1084#1091#1083#1103#1090#1086#1088' '#1074#1074#1086#1076#1072' '#1082#1086#1076#1072': : '
      end
      object ProvCB: TComboBox
        Left = 140
        Top = 10
        Width = 286
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ItemHeight = 13
        ParentFont = False
        TabOrder = 0
        Text = 'ProvCB'
      end
      object EmBtn: TButton
        Left = 432
        Top = 8
        Width = 75
        Height = 25
        Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = EmBtnClick
      end
      object EmPnCloseBtn: TBitBtn
        Left = 533
        Top = 8
        Width = 75
        Height = 25
        Caption = #1042#1099#1093#1086#1076
        TabOrder = 2
        OnClick = EmPnCloseBtnClick
        Kind = bkCancel
      end
    end
  end
  object RightPn: TPanel
    AlignWithMargins = True
    Left = 664
    Top = 51
    Width = 222
    Height = 472
    Margins.Left = 0
    Margins.Top = 10
    Margins.Right = 10
    Margins.Bottom = 20
    Align = alRight
    TabOrder = 2
    object Label1: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 214
      Height = 28
      Align = alTop
      AutoSize = False
      Caption = '  '#1057#1087#1080#1089#1086#1082' '#1079#1072#1087#1080#1089#1072#1085#1085#1099#1093' '#1082#1086#1076#1086#1074
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 3
      ExplicitTop = 3
      ExplicitWidth = 498
    end
    object LogLB: TListBox
      AlignWithMargins = True
      Left = 4
      Top = 38
      Width = 214
      Height = 267
      Align = alClient
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 19
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      ExplicitLeft = 6
      ExplicitHeight = 315
    end
    object ChangeModelBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 411
      Width = 214
      Height = 50
      Margins.Bottom = 10
      Align = alBottom
      Caption = #1057#1052#1045#1053#1048#1058#1068' '#1052#1054#1044#1045#1051#1068
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Visible = False
      OnClick = ChangeModelBtnClick
    end
    object Button1: TButton
      AlignWithMargins = True
      Left = 4
      Top = 318
      Width = 214
      Height = 80
      Margins.Top = 10
      Margins.Bottom = 10
      Align = alBottom
      Caption = #1057#1051#1045#1044#1059#1070#1065#1048#1049' '#1050#1054#1044
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      Visible = False
    end
  end
  object CapPN: TPanel
    Left = 0
    Top = 0
    Width = 896
    Height = 41
    Align = alTop
    BevelInner = bvLowered
    Color = clGradientInactiveCaption
    TabOrder = 3
    object CapLB: TLabel
      AlignWithMargins = True
      Left = 12
      Top = 5
      Width = 836
      Height = 29
      Margins.Left = 10
      Margins.Right = 10
      Margins.Bottom = 5
      Align = alClient
      Caption = #1056#1072#1073#1086#1095#1077#1077' '#1084#1077#1089#1090#1086' '#1082#1086#1085#1090#1088#1086#1083#1077#1088#1072' '#1054#1058#1050'2. '#1042#1077#1088#1080#1089#1103' 1.1.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      ExplicitWidth = 447
      ExplicitHeight = 23
    end
    object SpeedButton1: TSpeedButton
      AlignWithMargins = True
      Left = 861
      Top = 5
      Width = 30
      Height = 24
      Margins.Bottom = 10
      Align = alRight
      Caption = 'x'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = SpeedButton1Click
      ExplicitLeft = 664
      ExplicitHeight = 29
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 8
    Top = 8
  end
  object MainTimer: TTimer
    Enabled = False
    OnTimer = MainTimerTimer
    Left = 16
    Top = 56
  end
end
