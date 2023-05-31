object MainForm: TMainForm
  Left = 0
  Top = 0
  AlphaBlend = True
  AlphaBlendValue = 0
  BorderStyle = bsNone
  Caption = 'MainForm'
  ClientHeight = 501
  ClientWidth = 638
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Visible = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object TopPn: TGridPanel
    Left = 0
    Top = 0
    Width = 638
    Height = 120
    Align = alTop
    BevelOuter = bvNone
    Color = clBlack
    ColumnCollection = <
      item
        Value = 18.105797447457100000
      end
      item
        Value = 18.105790478335990000
      end
      item
        Value = 46.065060612501810000
      end
      item
        Value = 17.723351461705110000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = ClockPB
        Row = 0
      end
      item
        Column = 2
        Control = DayResPn
        Row = 0
      end
      item
        Column = 3
        Control = RedgPB
        Row = 0
      end
      item
        Column = 1
        Control = ModelPN
        Row = 0
      end>
    RowCollection = <
      item
        Value = 100.000000000000000000
      end
      item
        SizeStyle = ssAuto
      end>
    TabOrder = 0
    object ClockPB: TPaintBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 109
      Height = 107
      Margins.Bottom = 10
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnPaint = ClockPBPaint
      ExplicitLeft = 11
      ExplicitTop = 4
      ExplicitWidth = 119
      ExplicitHeight = 81
    end
    object DayResPn: TPanel
      AlignWithMargins = True
      Left = 233
      Top = 3
      Width = 287
      Height = 107
      Margins.Bottom = 10
      Align = alClient
      BevelOuter = bvNone
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object RedgPB: TPaintBox
      AlignWithMargins = True
      Left = 526
      Top = 3
      Width = 109
      Height = 107
      Margins.Bottom = 10
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnPaint = RedgPBPaint
      ExplicitLeft = 200
      ExplicitTop = 48
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
    object ModelPN: TPanel
      AlignWithMargins = True
      Left = 135
      Top = 3
      Width = 95
      Height = 114
      Margins.Left = 20
      Margins.Right = 0
      Align = alClient
      BevelOuter = bvNone
      Caption = 'ModelPN'
      Color = clBlack
      TabOrder = 1
      object TempPB: TPaintBox
        Left = 0
        Top = 0
        Width = 95
        Height = 114
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        OnPaint = TempPBPaint
        ExplicitLeft = -3
        ExplicitTop = 41
        ExplicitWidth = 94
        ExplicitHeight = 73
      end
    end
  end
  object BtmPn: TPanel
    Left = 0
    Top = 431
    Width = 638
    Height = 70
    Align = alBottom
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 1
    object MsgPB: TPaintBox
      AlignWithMargins = True
      Left = 173
      Top = 3
      Width = 292
      Height = 64
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnPaint = MsgPBPaint
      ExplicitLeft = 0
      ExplicitTop = 6
      ExplicitWidth = 630
      ExplicitHeight = 70
    end
    object ExitBtn: TSpeedButton
      AlignWithMargins = True
      Left = 478
      Top = 10
      Width = 150
      Height = 50
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alRight
      Caption = #1042#1067#1061#1054#1044
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = ExitBtnClick
      ExplicitLeft = 578
    end
    object PersonCntBtn: TSpeedButton
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 150
      Height = 50
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alLeft
      Caption = #1055#1045#1056#1057#1054#1053#1040#1051
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clLime
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = PersonCntBtnClick
    end
  end
  object Pages: TNotebook
    Left = 0
    Top = 120
    Width = 638
    Height = 311
    Align = alClient
    PageIndex = 2
    TabOrder = 2
    object TPage
      Left = 0
      Top = 0
      Caption = 'Page1'
      object FaultTablePN: TPanel
        Left = 0
        Top = 0
        Width = 638
        Height = 311
        Align = alClient
        BevelOuter = bvNone
        Color = clBlack
        TabOrder = 0
        object FaultCaptionPB: TPaintBox
          AlignWithMargins = True
          Left = 10
          Top = 20
          Width = 618
          Height = 31
          Margins.Left = 10
          Margins.Top = 20
          Margins.Right = 10
          Align = alTop
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          OnPaint = FaultCaptionPBPaint
          ExplicitLeft = 11
          ExplicitTop = 10
          ExplicitWidth = 163
        end
        object TotalFaultPB: TPaintBox
          AlignWithMargins = True
          Left = 10
          Top = 234
          Width = 618
          Height = 57
          Margins.Left = 10
          Margins.Right = 10
          Margins.Bottom = 20
          Align = alBottom
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          OnPaint = TotalFaultPBPaint
          ExplicitTop = 216
          ExplicitWidth = 385
        end
        object SG: TStringGrid
          AlignWithMargins = True
          Left = 10
          Top = 57
          Width = 618
          Height = 171
          Margins.Left = 10
          Margins.Right = 10
          Align = alClient
          BevelOuter = bvNone
          BorderStyle = bsNone
          Color = clBlack
          Ctl3D = False
          Enabled = False
          FixedColor = clBlack
          FixedCols = 0
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 0
          OnDrawCell = SGDrawCell
        end
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'Page2'
      object MainDgrPn: TPanel
        Left = 0
        Top = 0
        Width = 526
        Height = 311
        Margins.Left = 20
        Margins.Top = 10
        Margins.Bottom = 10
        Align = alClient
        Caption = 'MainDgrPn'
        Color = clBlack
        TabOrder = 0
        object MyDiagramCaptionPB: TPaintBox
          AlignWithMargins = True
          Left = 11
          Top = 11
          Width = 504
          Height = 22
          Margins.Left = 10
          Margins.Top = 10
          Margins.Right = 10
          Margins.Bottom = 0
          Align = alTop
          OnPaint = MyDiagramCaptionPBPaint
          ExplicitWidth = 186
        end
      end
      object PayDgrPn: TPanel
        Left = 526
        Top = 0
        Width = 112
        Height = 311
        Margins.Top = 10
        Margins.Right = 20
        Margins.Bottom = 10
        Align = alRight
        Color = clBlack
        TabOrder = 1
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'Page3'
      object TablePn: TPanel
        Left = 0
        Top = 0
        Width = 638
        Height = 311
        Align = alClient
        BevelOuter = bvNone
        Color = clBlack
        TabOrder = 0
        OnClick = TablePnClick
        object TablePB: TPaintBox
          AlignWithMargins = True
          Left = 10
          Top = 20
          Width = 618
          Height = 208
          Margins.Left = 10
          Margins.Top = 20
          Margins.Right = 10
          Align = alClient
          OnPaint = TablePBPaint
          ExplicitLeft = -150
          ExplicitTop = 0
        end
        object TotalPayPB: TPaintBox
          AlignWithMargins = True
          Left = 10
          Top = 234
          Width = 618
          Height = 57
          Margins.Left = 10
          Margins.Right = 10
          Margins.Bottom = 20
          Align = alBottom
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          OnPaint = TotalPayPBPaint
          ExplicitTop = 216
          ExplicitWidth = 385
        end
      end
    end
  end
  object MainTimer: TTimer
    Enabled = False
    OnTimer = MainTimerTimer
    Left = 16
    Top = 16
  end
  object OpenDlg: TOpenDialog
    Left = 48
    Top = 16
  end
end
