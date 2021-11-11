object MapEditor: TMapEditor
  Left = 201
  Top = 176
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Map Editor'
  ClientHeight = 411
  ClientWidth = 584
  Color = clBtnFace
  Constraints.MinHeight = 470
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object splitter: TSplitter
    Left = 0
    Top = 96
    Width = 584
    Height = 9
    Cursor = crVSplit
    Align = alTop
    OnMoved = splitterMoved
    ExplicitWidth = 614
  end
  object Panel1: TPanel
    Left = 0
    Top = 358
    Width = 584
    Height = 53
    Align = alBottom
    TabOrder = 0
    object Label2: TLabel
      Left = 200
      Top = 15
      Width = 26
      Height = 13
      Caption = 'Tile:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbInfo: TLabel
      Left = 232
      Top = 15
      Width = 26
      Height = 13
      Caption = 'None'
    end
    object btnOk: TBitBtn
      Left = 16
      Top = 8
      Width = 75
      Height = 25
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
      OnClick = btnOkClick
    end
    object BitBtn2: TBitBtn
      Left = 104
      Top = 8
      Width = 75
      Height = 25
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 1
    end
  end
  object imgList: TDrawGrid
    Left = 0
    Top = 0
    Width = 584
    Height = 96
    Align = alTop
    ColCount = 1
    DefaultColWidth = 75
    DefaultRowHeight = 75
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected]
    TabOrder = 1
    OnClick = imgListClick
    OnDrawCell = imgListDrawCell
    ColWidths = (
      75)
    RowHeights = (
      75)
  end
  object Grid: TDrawGrid
    Left = 0
    Top = 105
    Width = 584
    Height = 253
    Align = alClient
    Color = 14540253
    ColCount = 1
    DefaultColWidth = 25
    DefaultRowHeight = 25
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 2
    OnDblClick = GridDblClick
    OnDrawCell = GridDrawCell
    OnSelectCell = GridSelectCell
    ColWidths = (
      25)
    RowHeights = (
      25)
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 8
    object Options1: TMenuItem
      Caption = 'Tiles'
      object Locate1: TMenuItem
        Caption = 'Locate...'
        OnClick = Locate1Click
      end
      object mnuTLZoom: TMenuItem
        Caption = 'Zoom'
        OnClick = mnuTLZoomClick
      end
    end
    object Map1: TMenuItem
      Caption = 'Map'
      object SetColumns1: TMenuItem
        Caption = 'Set Size'
        OnClick = SetColumns1Click
      end
      object mnuHideInfo: TMenuItem
        Caption = 'Hide Info'
        Checked = True
        OnClick = mnuHideInfoClick
      end
      object Zoom: TMenuItem
        Caption = 'Zoom'
        object Out4x1: TMenuItem
          Caption = 'Out 4x'
          GroupIndex = 1
          RadioItem = True
          OnClick = Out4x1Click
        end
        object Out2x1: TMenuItem
          Caption = 'Out 2x'
          GroupIndex = 1
          RadioItem = True
          OnClick = Out2x1Click
        end
        object Normal1: TMenuItem
          Caption = 'Normal'
          Checked = True
          GroupIndex = 1
          RadioItem = True
          OnClick = Normal1Click
        end
        object In2X1: TMenuItem
          Caption = 'In 2X'
          GroupIndex = 1
          RadioItem = True
          OnClick = In2X1Click
        end
        object In4X1: TMenuItem
          Caption = 'In 4X'
          GroupIndex = 1
          RadioItem = True
          OnClick = In4X1Click
        end
      end
    end
  end
  object picDialog: TOpenPictureDialog
    Options = [ofEnableSizing]
    Left = 48
    Top = 8
  end
end
