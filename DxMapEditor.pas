{ ********************************************************************** }
{  DxMapEditor - Dises Game Engine Copyright (C) 2008 Danyz              }
{                                                                        }
{  This program is free software: you can redistribute it and/or modify  }
{  it under the terms of the GNU General Public License as published by  }
{  the Free Software Foundation, either version 3 of the License, or     }
{  any later version.                                                    }
{                                                                        }
{  This program is distributed in the hope that it will be useful,       }
{  but WITHOUT ANY WARRANTY; without even the implied warranty of        }
{  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          }
{   GNU General Public License for more details. (www.gnu.org)           }
{                                                                        }
{ ********************************************************************** }

unit DxMapEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, ExtCtrls, TypInfo, DesignIntf,
  DesignEditors, Dises, Spin, ComCtrls, ImgList, Menus, DxMapSize, ExtDlgs;

type

  TMapEditor = class(TForm)
    Panel1: TPanel;
    btnOk: TBitBtn;
    BitBtn2: TBitBtn;
    Label2: TLabel;
    lbInfo: TLabel;
    MainMenu1: TMainMenu;
    Options1: TMenuItem;
    mnuTLZoom: TMenuItem;
    Map1: TMenuItem;
    SetColumns1: TMenuItem;
    imgList: TDrawGrid;
    splitter: TSplitter;
    Grid: TDrawGrid;
    Zoom: TMenuItem;
    Out4x1: TMenuItem;
    Out2x1: TMenuItem;
    Normal1: TMenuItem;
    In2X1: TMenuItem;
    In4X1: TMenuItem;
    Locate1: TMenuItem;
    picDialog: TOpenPictureDialog;
    mnuHideInfo: TMenuItem;
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure imgListDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure imgListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure splitterMoved(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure mnuTLZoomClick(Sender: TObject);
    procedure SetColumns1Click(Sender: TObject);
    procedure Out4x1Click(Sender: TObject);
    procedure Out2x1Click(Sender: TObject);
    procedure Normal1Click(Sender: TObject);
    procedure In2X1Click(Sender: TObject);
    procedure In4X1Click(Sender: TObject);
    procedure Locate1Click(Sender: TObject);
    procedure mnuHideInfoClick(Sender: TObject);
  private
    FMap: TDxMap;
    FMapZoom: Single;
    FData: TDxMapData;
    FSpriteList: TDxSpriteList;
    procedure MapZoomChange;
    procedure SaveData;
    procedure ResizeImgList;
    procedure ResizeGrid (const ACols, ARows: Integer; ARepaint: Boolean);
    procedure DataLoad (AIndex: Integer; ARepaint: Boolean);
  public
    procedure Load (AMap: TDxMap);
  end;

implementation
uses Types, DxUtils;

{$R *.dfm}

{ TfrmMapEditor }

procedure TMapEditor.FormCreate(Sender: TObject);
begin
  FMapZoom:= 1;
  FSpriteList:= TDxSpriteList.Create(Self);
end;

procedure TMapEditor.FormDestroy(Sender: TObject);
begin
  FSpriteList.Free;
  if Assigned (FMap.Tiles) and FMap.Tiles.TileLoaded then
    FMap.Tiles.Unload;
end;

procedure TMapEditor.Load(AMap: TDxMap);
begin
  FMap:= AMap;
  if Assigned (FMap.Tiles) then
    FMap.Tiles.Load;
  imgList.DefaultColWidth := FMap.TileWidth;
  imgList.DefaultRowHeight:= FMap.TileHeight;
  MapZoomChange;
  ResizeImgList;
  DataLoad (0, True);
  imgList.Col:= 0;
  imgList.Row:= 0;
end;

procedure TMapEditor.DataLoad (AIndex: Integer; ARepaint: Boolean);
begin
  LoadMapData (FData, FMap.Data);
  ResizeGrid (MapDataWidth (FData), MapDataHeight (FData), True);
end;

procedure TMapEditor.ResizeGrid (const ACols, ARows: Integer; ARepaint: Boolean);
begin
  Grid.ColCount:= ACols;
  Grid.RowCount:= ARows;
  SetMapSize(FData, ACols, ARows);
  if ARepaint then Grid.Repaint;
end;

procedure TMapEditor.imgListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  Idx: Integer;
  Bmp: TBitmap;
  Item: TDxTileItem;
begin
  Idx:= imgList.ColCount * ARow + ACol;
  if Idx >= FMap.Tiles.Count then
    GetCrossImg (imgList.Canvas, Rect)
  else if FMap.Tiles.TileLoaded then
  begin
    Bmp:= TBitmap.Create;
    Item:= FMap.Tiles.Items [Idx];
    if Item.ImageIndex >= 0 then
      Bmp.Assign(Item.TileImg)
    else
      GetInfoBmp (Item, Bmp, True);
    imgList.Canvas.StretchDraw (Rect, Bmp);
    Bmp.Free;
  end;
end;

procedure TMapEditor.imgListClick(Sender: TObject);
var
  v, x, y: Integer;
begin
  v:= imgList.Row * imgList.ColCount + imgList.Col;
  if v < FMap.Tiles.Count then
  begin
    with Grid do
      for x:= Selection.Left to Selection.Right do
        for y:= Selection.Top to Selection.Bottom do
          FData[x][y]:= v;
    Grid.Repaint;
  end;
end;

procedure TMapEditor.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  Bmp: TBitmap;
  Tile: TDxTileItem;
begin
  if FMap.Tiles.TileLoaded then
    with Sender as TDrawGrid do
    begin
      Bmp:= TBitmap.Create;
      Tile:= FMap.GetTileFromData (FData, ACol, ARow, []);
      if Tile.ImageIndex >= 0 then
      begin
        Bmp.Assign(Tile.TileImg);
        if not mnuHideInfo.Checked then
          GetInfoBmp(Tile, Bmp, False);
      end else
         GetInfoBmp(Tile, Bmp, True);
      if Focused and (State = [gdSelected]) then
        Canvas.CopyMode:= cmNotSrcCopy
      else
        Canvas.CopyMode:= cmSrcCopy;
      Canvas.StretchDraw (Rect, Bmp);
      Bmp.Free;
    end;
end;

procedure TMapEditor.SaveData;
var
  s: String;
  i, j: Integer;
begin
  FMap.Data.Clear;
  for j:= 0 to MapDataHeight(FData) - 1 do
  begin
    s:= '';
    for i:= 0 to MapDataWidth (FData) - 1 do
      s:= s + IntToHex (FData[i, j], 2);
    FMap.Data.Add(s);
  end;
end;

procedure TMapEditor.GridDblClick(Sender: TObject);
var
  i: Integer;
begin
  i:= FData[Grid.Col][Grid.Row];
  i:= (i + 1) mod FMap.Tiles.Count;
  FData[Grid.Col][Grid.Row]:= i;
  Grid.Repaint;
end;

procedure TMapEditor.btnOkClick(Sender: TObject);
begin
  SaveData;
end;

procedure TMapEditor.ResizeImgList;
var
  NCol, NRow: Integer;
begin
  splitter.MinSize:= imgList.DefaultRowHeight + 30;
  NCol:= imgList.ClientWidth div (imgList.DefaultColWidth + 1);
  if NCol >= FMap.Tiles.Count then
  begin
    NCol:= FMap.Tiles.Count;
    NRow:= 1;
  end else
  begin
    NRow:= FMap.Tiles.Count div NCol;
    if FMap.Tiles.Count mod NCol > 0 then
      Inc (NRow);
  end;
  imgList.ColCount:= NCol;
  imgList.RowCount:= NRow;
  imgList.Repaint;
end;

procedure TMapEditor.splitterMoved(Sender: TObject);
begin
  ResizeImgList;
end;

procedure TMapEditor.FormResize(Sender: TObject);
begin
  ResizeImgList;
end;

procedure TMapEditor.GridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  item: TDxTileItem;
begin
  item:= FMap.GetTileFromData (FData, ACol, ARow, []);
  if Assigned (Item) then
    lbInfo.Caption:= IntToStr (Item.Index) + ' - ' + Item.Name
  else
    lbInfo.Caption:= 'None';
end;

procedure TMapEditor.mnuTLZoomClick(Sender: TObject);
begin
  with mnuTLZoom do
  begin
    Checked:= not Checked;
    if Checked then
    begin
      imgList.DefaultColWidth := 2 * FMap.TileWidth;
      imgList.DefaultRowHeight:= 2 * FMap.TileHeight;
    end else
    begin
      imgList.DefaultColWidth := FMap.TileWidth;
      imgList.DefaultRowHeight:= FMap.TileHeight;
    end;
    ResizeImgList;
  end;
end;

procedure TMapEditor.SetColumns1Click(Sender: TObject);
var
  frm: TFrmMapSize;
begin
  frm:= TFrmMapSize.Create (Self);
  try
    frm.Cols:= MapDataWidth (FData);
    frm.Rows:= MapDataHeight (FData);
    if frm.ShowModal = mrOK then
      ResizeGrid (frm.Cols, frm.Rows, True);
  finally
    frm.Free;
  end;
end;

procedure TMapEditor.Out4x1Click(Sender: TObject);
begin
  FMapZoom:= 0.25;
  MapZoomChange;
end;

procedure TMapEditor.Out2x1Click(Sender: TObject);
begin
  FMapZoom:= 0.5;
  MapZoomChange;
end;

procedure TMapEditor.Normal1Click(Sender: TObject);
begin
  FMapZoom:= 1;
  MapZoomChange;
end;

procedure TMapEditor.In2X1Click(Sender: TObject);
begin
  FMapZoom:= 2;
  MapZoomChange;
end;

procedure TMapEditor.In4X1Click(Sender: TObject);
begin
  FMapZoom:= 4;
  MapZoomChange;
end;

procedure TMapEditor.MapZoomChange;
begin
  Grid.DefaultColWidth := Round (FMapZoom * FMap.TileWidth);
  Grid.DefaultRowHeight:= Round (FMapZoom * FMap.TileHeight);
  Grid.Repaint;
end;

procedure TMapEditor.Locate1Click(Sender: TObject);
begin
  if picDialog.Execute then
    with FMap.Tiles do
    begin
      if TileLoaded then Unload;
      Load (picDialog.FileName);
      imgList.Repaint;
      Grid.Repaint;
    end;
end;

procedure TMapEditor.mnuHideInfoClick(Sender: TObject);
begin
  mnuHideInfo.Checked:= not mnuHideInfo.Checked;
  Grid.Repaint;
end;

end.
