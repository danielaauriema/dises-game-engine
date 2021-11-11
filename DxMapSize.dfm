object FrmMapSize: TFrmMapSize
  Left = 281
  Top = 393
  BorderStyle = bsSingle
  Caption = 'Map Size'
  ClientHeight = 124
  ClientWidth = 217
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label_seX: TLabel
    Left = 16
    Top = 17
    Width = 29
    Height = 13
    Caption = 'Cols:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label_seY: TLabel
    Left = 112
    Top = 16
    Width = 36
    Height = 13
    Caption = 'Rows:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object seCols: TSpinEdit
    Left = 16
    Top = 33
    Width = 77
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 0
    Value = 1
  end
  object seRows: TSpinEdit
    Left = 112
    Top = 32
    Width = 77
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 1
  end
  object BitBtn1: TBitBtn
    Left = 16
    Top = 80
    Width = 77
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
  end
  object BitBtn2: TBitBtn
    Left = 112
    Top = 80
    Width = 77
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 3
  end
end
