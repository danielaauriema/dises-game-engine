{ ********************************************************************** }
{  DisesReg Game Engine Copyright (C) 2008 Danyz                         }
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

unit DisesReg;

interface
uses Windows, Forms, SysUtils, Variants, Classes, TypInfo, DesignIntf,
  DesignEditors, Controls, Dialogs, Dises, DxUtils;

type

  TMapEdit = class(TDefaultEditor)
  public
    procedure Edit; override;
  end;

  TStageEdit = class(TDefaultEditor)
  public
    procedure Edit; override;
  end;

procedure Register;

implementation
uses DxMapEditor, DxStageEditor;

procedure Register;
begin
  RegisterComponents('Dises', [TDxMachine, TDxTiles, TDxMap, TDxStage,
    TDxImage, TDxSplash, TDxSpriteManager, TDxSprite, TDxSkin,
    TDxRotateSkin, TDxAudio]);

  RegisterComponentEditor (TDxMap, TMapEdit);
  RegisterComponentEditor (TDxStage, TStageEdit);

end;

{ TMapEdit }

procedure TMapEdit.Edit;
var
  frm: TMapEditor;
  FInstance: TDxMap;
begin
  frm:= TMapEditor.Create (Application);
  try
    FInstance:= Component as TDxMap;
    frm.Load (FInstance);
    if frm.ShowModal = mrOk then
    begin
      //FInstance.Maps:= frm.MapList;
      Designer.Modified;
    end;
  except
    frm.Free;
    raise;
  end;
end;

{ TStageEdit }

procedure TStageEdit.Edit;
var
  frm: TStageEditor;
  FInstance: TDxStage;
begin
  frm:= TStageEditor.Create (Application);
  try
    FInstance:= Component as TDxStage;
    frm.Load (FInstance);
    if frm.ShowModal = mrOk then
    begin
      FInstance.Sprites:= frm.SpriteList;
      Designer.Modified;
    end;
  except
    frm.Free;
    Raise;
  end;
end;

end.

