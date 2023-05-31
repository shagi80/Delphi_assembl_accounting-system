object DateForm: TDateForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1044#1072#1090#1072
  ClientHeight = 216
  ClientWidth = 195
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
  object MonthCalendar1: TMonthCalendar
    Left = 0
    Top = 8
    Width = 191
    Height = 154
    Date = 42623.800412418980000000
    TabOrder = 0
    OnDblClick = MonthCalendar1DblClick
  end
  object OkBtn: TBitBtn
    Left = 21
    Top = 176
    Width = 75
    Height = 25
    TabOrder = 1
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 96
    Top = 176
    Width = 75
    Height = 25
    TabOrder = 2
    Kind = bkCancel
  end
end
