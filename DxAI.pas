{ ********************************************************************** }
{  DxAI - Dises Game Engine Copyright (C) 2008 Danyz                     }
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

unit DxAI;

interface
uses Windows, Classes, Dises, DxUtils, Math;

{ ************************************************************ }
{   Processamento de Colisões                                  }
{ ************************************************************ }

{ Verifica Lado de Colisao entre Rects }
function GetColisionSide (const Sender, Rc: TRect): TDxSide; overload;
function GetColisionSide (const Sender, Rc: TRealRect): TDxSide; overload;

{ Altera a posição do Sprite em relação ao Rect }
procedure SetSpritePos (ASprite: TDxSprite; const Rc, Area: TRect;
  const Side: TDxSide; const AltVeloc: Boolean); overload;
procedure SetSpritePos(Sender, Sprite: TDxSprite;
  const Area: TRect; const AltVeloc: Boolean); overload;

{ Verifica se ocorreu colisão entre os Sprites }
function SpriteColision (out R: TRect; Sender, Sprite: TDxSprite): Boolean;

{ ************************************************************ }
{   Utilitarios para gerenciamento de Sprites                  }
{ ************************************************************ }

procedure AddRectSprite (Sender, Sprite: TDxSprite; MargX, MargY: Integer);

{ ************************************************************ }
{   Utilitarios de Inteligencia para Enemies                   }
{ ************************************************************ }

procedure WatchMirrors (Sender, Sprite: TDxSprite; const MirrorX, MirrorY: Boolean);

implementation
uses Types;

{ ************************************************************ }
{   Processamento de Colisões                                  }
{ ************************************************************ }

function GetColisionSide (const Sender, Rc: TRect): TDxSide;
var
  C1, C2: TPoint;
begin
  C1:= CenterPoint(Sender);
  C2:= CenterPoint (Rc);
  if IntersectWidth (Sender, Rc) > IntersectHeight (Sender, Rc) then
  begin
    if C1.Y > C2.Y then
      Result:= bsTop
    else
      Result:= bsBottom;
  end else
  begin
    if C1.X > C2.X then
      Result:= bsLeft
    else
      Result:= bsRight;
  end;
end;

function GetColisionSide (const Sender, Rc: TRealRect): TDxSide; overload;
var
  C1, C2: TRealPoint;
begin
  C1:= RealCenter(Sender);
  C2:= RealCenter (Rc);
  if IntersectWidth (Sender, Rc) > IntersectHeight (Sender, Rc) then
  begin
    if C1.Y > C2.Y then
      Result:= bsTop
    else
      Result:= bsBottom;
  end else
  begin
    if C1.X > C2.X then
      Result:= bsLeft
    else
      Result:= bsRight;
  end;
end;

procedure SetSpritePos (ASprite: TDxSprite; const Rc, Area: TRect;
  const Side: TDxSide; const AltVeloc: Boolean);
begin
  { Correção da Posição }
  case Side of
    bsLeft:
      ASprite.X:= Area.Right - Rc.Left + 1;
    bsTop:
      ASprite.Y:= Area.Bottom - Rc.Top + 1;
    bsRight:
      ASprite.X:= Area.Left - Rc.Right - 1;
    bsBottom:
      ASprite.Y:= Area.Top - Rc.Bottom - 1;
  end;
  if AltVeloc then
  begin
    { Correção da Velocidade }
    if Side in [bsLeft, bsRight] then
      ASprite.Veloc.ValueX:= 0
    else if Side in [bsTop, bsBottom] then
      ASprite.Veloc.ValueY:= 0;
  end;
end;

procedure SetSpritePos(Sender, Sprite: TDxSprite;
  const Area: TRect; const AltVeloc: Boolean);
var
  Rc: TRect;
  Side: TDxSide;
begin
  { Verifica Lado da Colisao }
  Rc:= Sender.Rect;
  Side:= GetColisionSide(Rc, Sprite.Rect);
  { Executa Colisao }
  OffsetRect(Rc, -Sender.X, -Sender.Y);
  SetSpritePos(Sender, Rc, Area, Side, AltVeloc);
  Sender.AddColision(Side);
end;

function SpriteColision (out R: TRect; Sender, Sprite: TDxSprite): Boolean;
begin
  R:= Rect (0, 0, 0, 0);
  if not Sprite.Enabled then
    Result:= False
  else if (Sender.RectMode = rmCircle) and
          (Sender.RectMode = rmCircle)
  then
    Result:= Dist (Sender.Center, Sprite.Center) < Sender.Ray + Sprite.Ray
  else
    Result:= IntersectRect (R, Sender.Rect, Sprite.Rect);
end;

{ ************************************************************ }
{   Utilitarios para gerenciamento de Sprites                  }
{ ************************************************************ }

procedure AddRectSprite (Sender, Sprite: TDxSprite; MargX, MargY: Integer);
var
  p: TPoint;
begin
  with Sender do
  begin
    { Adiciona o Sprite }
    Stage.AddSprite (Sprite);
    { Corrige Eixo X }
    if MirrorX then
    begin
      MargX:= -MargX;
      Sprite.Veloc.ValueX:= -Sprite.Veloc.ValueX
    end;
    { Corrige Eixo Y }
    if MirrorY then
    begin
      MargY:= - MargY;
      Sprite.Veloc.ValueY:= -Sprite.Veloc.ValueY
    end;
    { Seta Posição do Sprite }
    P:= Sender.Center;
    P.X:= P.X + MargX;
    P.Y:= P.Y + MargY;
    Sprite.Center:= P;
    Sprite.ResetInitPos;
  end;
end;

{ ************************************************************ }
{   Utilitarios de Inteligencia para Enemies                   }
{ ************************************************************ }

procedure WatchMirrors (Sender, Sprite: TDxSprite; const MirrorX, MirrorY: Boolean);
var
  c1, c2: TPoint;
begin
  c1:= Sender.Center;
  c2:= Sprite.Center;
  if MirrorX then
    Sender.MirrorX:= c1.X > c2.X;
  if MirrorY then
    Sender.MirrorY:= c1.Y < c2.Y;
end;

end.
