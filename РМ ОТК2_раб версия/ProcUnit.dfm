object DataMod: TDataMod
  OldCreateOrder = False
  Height = 150
  Width = 215
  object TcpClnt: TTcpClient
    RemoteHost = '127.0.0.1'
    RemotePort = '8888'
    Left = 8
  end
  object Report: TfrxReport
    Version = '4.15'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    PrintOptions.ShowDialog = False
    ReportOptions.CreateDate = 42137.671855636600000000
    ReportOptions.LastChange = 43958.704451655100000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 48
    Datasets = <>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      Orientation = poLandscape
      PaperWidth = 210.000000000000000000
      PaperHeight = 148.000000000000000000
      PaperSize = 11
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 5.000000000000000000
      object Memo1: TfrxMemoView
        Left = 377.953000000000000000
        Top = 64.252010000000000000
        Width = 226.771800000000000000
        Height = 18.897650000000000000
        ShowHint = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsItalic]
        HAlign = haCenter
        Memo.UTF8 = (
          '[model]')
        ParentFont = False
      end
      object Memo2: TfrxMemoView
        Left = 215.433210000000000000
        Top = 105.826840000000000000
        Width = 302.362400000000000000
        Height = 26.456710000000000000
        ShowHint = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -21
        Font.Name = 'Arial'
        Font.Style = [fsItalic]
        HAlign = haCenter
        Memo.UTF8 = (
          '[serial]')
        ParentFont = False
      end
      object Memo3: TfrxMemoView
        Left = 544.252320000000000000
        Top = 211.653680000000000000
        Width = 154.960730000000000000
        Height = 18.897650000000000000
        ShowHint = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -19
        Font.Name = 'Arial'
        Font.Style = [fsItalic]
        HAlign = haCenter
        Memo.UTF8 = (
          '[mydate]')
        ParentFont = False
      end
      object Memo4: TfrxMemoView
        Left = 26.456710000000000000
        Top = 461.102660000000000000
        Width = 691.653990000000000000
        Height = 41.574830000000000000
        ShowHint = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        Memo.UTF8 = (
          
            #1056#1038' 22.04.20 '#1057#1027#1056#181#1057#1026#1057#8218#1056#1105#1057#8222#1056#1105#1056#1108#1056#176#1057#8218' '#1057#1027#1056#1109#1056#1109#1057#8218#1056#1030#1056#181#1057#8218#1057#1027#1057#8218#1056#1030#1056#1105#1057#1039' '#1074#8222#8211#1056#8226#1056 +
            #1106#1056#173#1056#1038' RU C-RU.AM02.'#1056#8217'.00335/20,'#1056#1169#1056#181#1056#8470#1057#1027#1057#8218#1056#1030#1056#181#1057#8218' '#1056#1169#1056#1109' 21.04.25. '#1056 +
            #8217#1057#8249#1056#1169#1056#176#1056#1029' '#1056#1115#1056#1038' '#1056#1115#1056#1115#1056#1115' "'#1056#8216#1057#1026#1057#1039#1056#1029#1057#1027#1056#1108#1056#1105#1056#8470' '#1056#1109#1057#1026#1056#1110#1056#176#1056#1029' '#1056#1111#1056#1109' '#1057#1027#1056#181#1057#1026#1057#8218 +
            #1056#1105#1057#8222#1056#1105#1056#1108#1056#176#1057#8224#1056#1105#1056#1105'", '#1056#1110'. '#1056#8216#1057#1026#1057#1039#1056#1029#1057#1027#1056#1108', '#1057#1107#1056#187' '#1056#8250#1056#1105#1057#8218#1056#181#1056#8470#1056#1029#1056#176#1057#1039', 36'#1056#1106 +
            ', '#1056#1109#1057#8222' 702..  '#1056#8221#1056#181#1056#1108#1056#187#1056#176#1057#1026#1056#176#1057#8224#1056#1105#1057#1039' '#1057#1027#1056#1109#1056#1109#1057#8218#1056#1030#1056#181#1057#8218#1057#1027#1057#8218#1056#1030#1056#1105#1057#1039' '#1056#1118#1056#160 +
            ' '#1056#8226#1056#1106#1056#173#1056#1038' 037/2016 '#1074#8222#8211' RU '#1056#8221'-RU.'#1056#1114#1056#174'62.'#1056#8217'.00637/20, '#1056#1169#1056#181#1056#8470#1057#1027#1057#8218#1056#1030 +
            #1057#1107#1056#181#1057#8218' '#1056#1169#1056#1109' 20.02.25.')
        ParentFont = False
      end
      object Memo5: TfrxMemoView
        Left = 3.779530000000000000
        Top = 461.102660000000000000
        Width = 15.118120000000000000
        Height = 37.795300000000000000
        ShowHint = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -35
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        Memo.UTF8 = (
          '!')
        ParentFont = False
      end
    end
  end
end
