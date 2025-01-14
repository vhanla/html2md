object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Paste with Ctrl+V HTML content copied from your WebBrowser'
  ClientHeight = 578
  ClientWidth = 796
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 393
    Top = 0
    Height = 553
    ExplicitLeft = 408
    ExplicitTop = 256
    ExplicitHeight = 100
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 393
    Height = 553
    Align = alLeft
    Lines.Strings = (
      '<strong>Test</strong>')
    TabOrder = 0
    ExplicitTop = 8
    ExplicitHeight = 409
  end
  object btnConvert: TButton
    Left = 0
    Top = 553
    Width = 796
    Height = 25
    Align = alBottom
    Caption = 'HTML2MarkDown'
    TabOrder = 1
    OnClick = btnConvertClick
    ExplicitLeft = 336
    ExplicitTop = 472
    ExplicitWidth = 75
  end
  object Memo2: TMemo
    Left = 396
    Top = 0
    Width = 400
    Height = 553
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 399
    ExplicitTop = 8
    ExplicitWidth = 389
    ExplicitHeight = 409
  end
end
