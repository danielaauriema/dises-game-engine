{ ********************************************************************** }
{  DxStageEditor - Dises Game Engine Copyright (C) 2008 Danyz            }
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

unit DxStageEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, ExtCtrls, TypInfo, DesignIntf,
  DesignEditors, Dises, Spin, ComCtrls, ImgList, Menus, ExtDlgs,
  System.ImageList;

type

  TStageEditor = class(TForm)
    Panel1: TPanel;
    btnOk: TBitBtn;
    BitBtn2: TBitBtn;
    cbAlign: TCheckBox;
    images: TImageList;
    Panel3: TPanel;
    lbSprites: TListBox;
    Panel4: TPanel;
    cbMirrorX: TCheckBox;
    cbMirrorY: TCheckBox;
    Grid: TDrawGrid;
    MainMenu1: TMainMenu;
    Map1: TMenuItem;
    Zoom1: TMenuItem;
    Out4x1: TMenuItem;
    Out2x1: TMenuItem;
    Normal1: TMenuItem;
    In2x1: TMenuItem;
    In4x1: TMenuItem;
    Load1: TMenuItem;
    picDialog: TOpenPictureDialog;
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure SpriteClick (Sender: TObject);
    procedure lbSpritesClick(Sender: TObject);
    procedure GridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GridTopLeftChanged(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbMirrorXClick(Sender: TObject);
    procedure cbMirrorYClick(Sender: TObject);
    procedure Out4x1Click(Sender: TObject);
    procedure Out2x1Click(Sender: TObject);
    procedure Normal1Click(Sender: TObject);
    procedure In2x1Click(Sender: TObject);
    procedure In4x1Click(Sender: TObject);
    procedure Load1Click(Sender: TObject);
  private
    function GetSpriteItem: TDxSpriteItem;
  private
    FMap: TDxMap;
    FStage: TDxStage;
    FMapZoom: Single;
    FData: TDxMapData;
    FSpriteList: TDxSpriteList;
    procedure GridRepaint;
    procedure DrawSprites;
    procedure ClearObjects;
    procedure MapZoomChange;
    procedure UpdateSpriteInfo;
    procedure LoadSpriteList (ADrawSprites: Boolean);
    procedure DataLoad (ARepaint: Boolean);
    property SpriteItem: TDxSpriteItem read GetSpriteItem;
  public
    procedure Load (AStage: TDxStage);
    property SpriteList: TDxSpriteList read FSpriteList;
  end;

implementation
uses Types, DxUtils;

{$R *.dfm}

{ TfrmMapEditor }

procedure TStageEditor.FormCreate(Sender: TObject);
begin
  FMapZoom:= 1;
  FSpriteList:= TDxSpriteList.Create(Self);
end;

procedure TStageEditor.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  ClearObjects;
  FSpriteList.Free;
  //Descarrega o TileMap
  with FMap do
  if Assigned (Tiles) and Tiles.TileLoaded then
    Tiles.Unload;
  //Descarrega Skins
  with FSpriteList do
    for i:= 0 to Count - 1 do
      if Assigned (Items[i].Skin) then
        Items[i].Skin.Unload;
end;

procedure TStageEditor.ClearObjects;
var
  i: Integer;
begin
  for i:= 0 to lbSprites.Count - 1 do
    lbSprites.Items.Objects [i].Free;
  lbSprites.Clear;
end;

procedure TStageEditor.Load(AStage: TDxStage);
begin
  { Inicializa Variaveis }
  FStage:= AStage;
  FMap:= AStage.Map;
  with FMap do
    if Assigned (Tiles) then
      Tiles.Load; 
  FSpriteList.Assign(FStage.Sprites);
  Caption:= FStage.Name;
  MapZoomChange;
  { Carrega Mapa e Sprites }
  DataLoad (False);
  LoadSpriteList (False);
end;

procedure TStageEditor.DataLoad (ARepaint: Boolean);
begin
  LoadMapData (FData, FMap.Data);
  Grid.ColCount:= MapDataWidth (FData);
  Grid.RowCount:= MapDataHeight(FData);
end;

procedure TStageEditor.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  Bmp: TBitmap;
  Tile: TDxTileItem;
begin
  with Sender as TDrawGrid do
  begin
    Tile:= FMap.GetTileFromData (FData, ACol, ARow, []);
    if Tile.ImageIndex >= 0 then
    begin
      Bmp:= Tile.TileImg;
      if Focused and (State = [gdSelected]) then
        Canvas.CopyMode:= cmNotSrcCopy
      else
        Canvas.CopyMode:= cmSrcCopy;
      Canvas.StretchDraw (Rect, Bmp);
    end else
    begin
      Canvas.Brush.Color:= clBtnFace;
      Canvas.FillRect (Rect);
    end;
  end;
end;

procedure TStageEditor.LoadSpriteList (ADrawSprites: Boolean);
var
  i: Integer;
  Img: TImage;
  sName: String;
begin
  ClearObjects;
  { Carrega Layers }
  for i:= 0 to FSpriteList.Count - 1 do
  begin
    sName:= FSpriteList.Items [i].Name;
    img:= TImage.Create (Self);
    img.Parent:= Grid;
    img.OnClick:= SpriteClick;
    lbSprites.Items.AddObject (sName, img);
  end;
  if ADrawSprites then
    DrawSprites;
end;

procedure TStageEditor.GridRepaint;
begin
  Grid.Repaint;
  DrawSprites;
end;

procedure TStageEditor.SpriteClick(Sender: TObject);
begin
  lbSprites.ItemIndex:= lbSprites.Items.IndexOfObject (Sender);
  DrawSprites;
  UpdateSpriteInfo;
end;

procedure TStageEditor.lbSpritesClick(Sender: TObject);
begin
  DrawSprites;
  UpdateSpriteInfo;
end;

procedure TStageEditor.GridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  img: TImage;
  gc: TGridCoord;
  i, pX, pY: Integer;
begin
  if Button = mbRight then
    lbSprites.ItemIndex:= -1
  else begin
    gc:= Grid.MouseCoord (X, Y);
    if (gc.X >= 0) and (gc.Y >= 0) then
    begin
      i:= lbSprites.ItemIndex;
      if i >= 0 then
      begin
        img:= lbSprites.Items.Objects [i] as TImage;
        if cbAlign.Checked then
        begin
          pX:= gc.X * Grid.DefaultColWidth;
          pY:= gc.Y * Grid.DefaultRowHeight;
          X:= (gc.X - Grid.LeftCol) * Grid.DefaultColWidth;
          Y:= (gc.Y - Grid.TopRow)  * Grid.DefaultRowHeight;
        end else
        begin
          pX:= Grid.LeftCol * Grid.DefaultColWidth + X;
          pY:= Grid.TopRow  * Grid.DefaultRowHeight + Y;
        end;
        pX:= Round (pX * 1 / FMapZoom);
        pY:= Round (pY * 1 / FMapZoom);
        FSpriteList.Items [i].x:= pX;
        FSpriteList.Items [i].y:= pY;
        img.Left:= X;
        img.Top:= Y;
      end;
    end;
  end;
end;

procedure TStageEditor.DrawSprites;
var
  idx: Integer;
  img: TImage;
  skn: TDxCustomSkin;
  tmp, bmp: TBitmap;
  pX, pY, i: Integer;
  item: TDxSpriteItem;
begin
  Bmp:= TBitmap.Create;
  Tmp:= TBitmap.Create;
  for i:= 0 to lbSprites.Count - 1 do
  begin
    Item:= FSpriteList.Items [i];
    img:= lbSprites.Items.Objects [i] as TImage;
    skn:= nil;
    if Assigned (Item.Sprite) then
      skn:= Item.Sprite.Skin;
    if skn = nil then
      skn:= Item.Skin;
    if Assigned (skn) then
    begin
      skn.QuickLoad;
      if Assigned (Item.Sprite) and Assigned (Item.Sprite.Action) then
        idx:= Item.Sprite.Action.FirstFrame
      else
        idx:= 0;
      Bmp.Assign (skn.GetDxImages.Item[idx].Frame);
    end else
      images.GetBitmap (0, Bmp);
    if Item.MirrorX or Item.MirrorY then
    begin
      Tmp.Width:= Bmp.Width;
      Tmp.Height:= Bmp.Height;
      ImageMirror (Bmp, Tmp, Item.MirrorX, Item.MirrorY)
    end else
      Tmp.Assign(Bmp);
    pX:= Item.x;
    pY:= Item.y;
    Bmp.Width:= Round (Tmp.Width * FMapZoom);
    Bmp.Height:= Round (Tmp.Height * FMapZoom);
    Bmp.Canvas.StretchDraw (Bmp.Canvas.ClipRect, Tmp);
    if i = lbSprites.ItemIndex then
      Bmp.Canvas.DrawFocusRect (Bmp.Canvas.ClipRect);
    img.Width:= Bmp.Width;
    img.Height:= Bmp.Height;
    img.Picture.Assign (Bmp);
    pX:= pX - Grid.LeftCol * FMap.TileWidth;
    pY:= pY - Grid.TopRow * FMap.TileHeight;
    img.Top:= Round (pY * FMapZoom);
    img.Left:= Round (pX * FMapZoom);
  end;
  Bmp.Free;
  Tmp.Free;
end;

procedure TStageEditor.GridTopLeftChanged(Sender: TObject);
begin
  GridRepaint;
end;

procedure TStageEditor.cbMirrorXClick(Sender: TObject);
begin
  SpriteItem.MirrorX:= cbMirrorX.Checked;
  DrawSprites;
end;

procedure TStageEditor.cbMirrorYClick(Sender: TObject);
begin
  SpriteItem.MirrorY:= cbMirrorY.Checked;
  DrawSprites;
end;

function TStageEditor.GetSpriteItem: TDxSpriteItem;
begin
  Result:= FSpriteList.Items [lbSprites.ItemIndex];
end;

procedure TStageEditor.UpdateSpriteInfo;
begin
  cbMirrorX.Checked:= SpriteItem.MirrorX;
  cbMirrorY.Checked:= SpriteItem.MirrorY;
end;

procedure TStageEditor.Out4x1Click(Sender: TObject);
begin
  FMapZoom:= 0.25;
  MapZoomChange;
end;

procedure TStageEditor.Out2x1Click(Sender: TObject);
begin
  FMapZoom:= 0.5;
  MapZoomChange;
end;

procedure TStageEditor.Normal1Click(Sender: TObject);
begin
  FMapZoom:= 1;
  MapZoomChange;
end;

procedure TStageEditor.In2x1Click(Sender: TObject);
begin
  FMapZoom:= 2;
  MapZoomChange;
end;

procedure TStageEditor.In4x1Click(Sender: TObject);
begin
  FMapZoom:= 4;
  MapZoomChange;
end;

procedure TStageEditor.MapZoomChange;
begin
  Grid.DefaultColWidth := Round (FMapZoom * FMap.TileWidth);
  Grid.DefaultRowHeight:= Round (FMapZoom * FMap.TileHeight);
  GridRepaint;
end;

procedure TStageEditor.Load1Click(Sender: TObject);
begin
  if picDialog.Execute then
  begin
    FMap.Tiles.Load (picDialog.FileName);
    GridRepaint; 
  end;
end;

end.
