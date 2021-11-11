{ ********************************************************************** }
{  DxUtils - Dises Game Engine Copyright (C) 2008 Danyz                  }
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
{  DxGame Utility Library                                                }
{  Biblioteca de Fisica e Multimedia da DxGame                           }
{  Versão: 1.0                                                           }
{  Criada por: Dany Fernandes                                            }
{  Data: 03/01/2008                                                      }
{  Modificado em: 03/01/2008                                             }
{ ********************************************************************** }

unit DxUtils;

interface
uses Windows, Classes, SysUtils, Math, Graphics, MMSystem, Dialogs, Forms;

type

  TDxVectorMode = (vmRect, vmPol);

  TDxAngleType = (atRad, atDeg);

  TDxImageFilter = 0..9;

{ TDxVector Class }

  TDxVector = class (TPersistent)
  private
    Fx, Fy: Real;
    FMode: TDxVectorMode;
    FAngleType: TDxAngleType;
    function GetAngle: Real;
    function GetModulus: Real;
    function GetValueX: Real;
    function GetValueY: Real;
    function GetRadAngle: Real;
    procedure SetAngle(const Value: Real);
    procedure SetValueX(const Value: Real);
    procedure SetValueY(const Value: Real);
    procedure SetModulus(const Value: Real);
    procedure SetRadAngle(const Value: Real);
    procedure SetMode(const Value: TDxVectorMode);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create; virtual;
    procedure Reset; virtual;
    function IsPolVector: Boolean;
    function IsRectVector: Boolean;
    property RadAngle: Real read GetRadAngle write SetRadAngle;
  published
    property ValueX: Real read GetValueX write SetValueX stored IsRectVector;
    property ValueY: Real read GetValueY write SetValueY stored IsRectVector;
    property Angle: Real read GetAngle write SetAngle stored IsPolVector;
    property Modulus: Real read GetModulus write SetModulus stored IsPolVector;
    property Mode: TDxVectorMode read FMode write SetMode default vmRect;
    property AngleType: TDxAngleType read FAngleType write FAngleType default atRad;
  end;

{ TDxRotation Class }

  TDxCustomRotation = class (TPersistent)
  private
    FRPM: Real;
    FAccTg: Real;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create; virtual;
    procedure Reset; virtual;
    procedure CalcRPM (const t: Cardinal);
    function  CalcAngle (const t: Cardinal; const Angle: Real): Real;
  published
    property RPM: Real read FRPM write FRPM;
    property AccTg: Real read FAccTg write FAccTg;
  end;

{ TDxVectorEx Class }

  TDxVectorEx = class (TDxVector)
  private
    FRotation: TDxCustomRotation;
    function GetRPM: Real;
    function GetAccTg: Real;
    procedure SetRPM(const Value: Real);
    procedure SetAccTg(const Value: Real);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Execute (const t: Cardinal);
  published
    property RPM: Real read GetRPM write SetRPM;
    property AccTg: Real read GetAccTg write SetAccTg;
  end;

{ TDxRotation Class }

  TDxRotation = class (TDxCustomRotation)
  private
    FAngle: Real;
    FAngleType: TDxAngleType;
    function GetAngle: Real;
    procedure SetAngle(const Value: Real);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    procedure Execute (t: Cardinal);
    property  RadAngle: Real read FAngle write FAngle;
  published
    property Angle: Real read GetAngle write SetAngle;
    property AngleType: TDxAngleType read FAngleType write FAngleType default atRad;
  end;

{ TDxRect Class }

  TDxRect = class (TPersistent)
  private
    FRect: TRect;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  published
    property Rect: TRect read FRect write FRect stored False;
    property Left: Integer read FRect.Left write FRect.Left default 0;
    property Top: Integer read FRect.Top write FRect.Top default 0;
    property Right: Integer read FRect.Right write FRect.Right default 0;
    property Bottom: Integer read FRect.Bottom write FRect.Bottom default 0;
  end;

{ TDxAudio }

  TDxAudioMode = (amStop, amNoStop, amLoop);

  TDxAudio = class (TComponent)
  private
    FErr: Cardinal;
    FDeviceID: Word;
    FEnabled: Boolean;
    FLength: Cardinal;
    FAutoOpen: Boolean;
    FMode: TDxAudioMode;
    FTimer: Cardinal;
    FPosition: Cardinal;
    FFileName: TFileName;
    procedure SetFileName(const Value: TFileName);
  protected
    procedure Loaded; override;
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    function Play (ARewind: Boolean = False): Boolean;
    function Stop: Boolean;
    function Pause: Boolean;
    function Open: Boolean;
    function Close: Boolean;
    function Rewind: Boolean;
    function Execute: Boolean;
    property Error: Cardinal read FErr;
    property DeviceID: Word read FDeviceID;
  published
    property Mode: TDxAudioMode read FMode write FMode;
    property FileName: TFileName read FFileName write SetFileName;
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property AutoOpen: Boolean read FAutoOpen write FAutoOpen default True;
  end;

{ TDxRealRect }

  TRealRect = record
    Left, Top, Right, Bottom: Real;
  end;

  TRealPoint = record
    X, Y: Real;
  end;

{ ************************************************************ }
{   Funções de Cinemática                                      }
{ ************************************************************ }

{ Função Movimento Uniforme
  s0 - Posição Inicial em Pixels,
  v0 - Velocidade em Pixels/Segundo
  t  - Tempo em milisegundos
  Retorna a nova posição do objeto em Pixels }
function MU (const s0, v0: Real; const t: cardinal): Real;

{ Função da Velocidade
  v0 - Velocidade Inicial em Pixels/Segundo
  a  - Aceleração Escalar em Pixels/Segundo^2
  t  - Tempo em milisegundos
  Retorna a nova velocidade em Pixles/Segundo }
function Velocidade (const v0, a: Real; const t: cardinal): Real;

{ Movimento Circular
  Angle - Angulo Inical em Graus
  RPM   - Velocidade de Rotação em Rotação/Minuto
  t     - Tempo dem milisegundos
  Retorna o novo Angulo em Graus }
function MC (const Angle, RPM: Real; const t: cardinal): Real;

{ Aceleração do Movimento Circular
  RPM  - Velocidade de Rotação em Rotação/Minuto
  a    - Aceleração Tangencial em Pixels/Segundo^2
  t    - Tempo em milisegundos
  Retorna  a nova velocidade de rotação em Rotação/Minuto }
function AcMC (const RPM, a: Real; const t: cardinal): Real;

{ ************************************************************ }
{   Funções de Geometria                                       }
{ ************************************************************ }

//Modulo de um vetor retangular
function  PolMod (const Vx, Vy: Real): Real;

//Angulo de um vetor retangular em Radianos
function  PolAngle (const Vx, Vy: Real): Real;

function RectX (const Modulus, Angle: Real): Real;
function RectY (const Modulus, Angle: Real): Real;
procedure RectXY (const Modulus, Angle: Real; var X: Real; var Y: Real);

//Valida o anglo entre 0 <= Value < 2pi
function ValidAngle (const Value: Real): Real;

//Calcula a Distancia entre dois pontos
function Dist (const P1, P2: TPoint): Real;

{ ************************************************************ }
{   Real Rect Functions                                        }
{ ************************************************************ }

//Conversao de Rects
function Rect2Real (const Rc: TRect): TRealRect;
function Real2Rect (const Rc: TRealRect): TRect;

//Cria um Real Rect
function RealBounds (const Left, Top, Width, Height: Real): TRealRect;

//Offset do Real Rect
procedure RealOffsetRect (out Rc: TRealRect; X, Y: Real);

//Centro do RealRect
function RealCenter (const R: TRealRect): TRealPoint;

//Verifica a Altura/Largura da Interseção de R1 e R2
function IntersectWidth (R1, R2: TRect): Integer; overload;
function IntersectWidth (R1, R2: TRealRect): Real; overload;

function IntersectHeight (R1, R2: TRect): Integer; overload;
function IntersectHeight (R1, R2: TRealRect): Real; overload;

{ ************************************************************ }
{   Processamento de Imagens                                   }
{ ************************************************************ }

function DefaultTranspColor (Bmp: TBitmap): TColor;

{ Rotaciona a Imagem pelo valor de "Angle" em Radianos }
procedure ImageRotate (Src, Dest: TBitmap; const Angle: Real;
  const BkColor: TColor);

{ Espelhamento da Imagem nos eixos X/Y/XY }
procedure ImageMirror (Src, Dest: TBitmap; const x, y: Boolean);

{ Cria Mascara de Transparencia }
procedure ImageMask (Src, Dest: TBitmap; TranspColor: TColor);

{ Filtro de Nitidez
  Melhora a Nitidez de áreas contíguas após o ImageRotate
  mas tem alto tempo de processamento }
procedure ImageFilter (Img: TBitmap; const BkColor: TColor;
  const Prec: TDxImageFilter);

//Preenche Img com Src
procedure FillImage (Img, Src: TBitmap); overload;
procedure FillImage (Dest: TCanvas; const dx, dy, dw, dh: Integer;
  Src: TCanvas; const sx, sy: Integer); overload;

//Desenha um X nos vertices do Rect Rc
procedure GetCrossImg (Canvas: TCanvas; const Rc: TRect);


{ ************************************************************ }
{   Miscelania                                                 }
{ ************************************************************ }

procedure ShowMCIError (const Err: Cardinal);

procedure SoundConfig (const Music, Fx: Boolean);

function ChangeDisplay (Width, Height, BitsPerPixel: Integer; CurrentMode: PDevMode): Boolean;

function RestoreDisplay(const DevMode: TDevMode): Boolean;

function RelativePath (FileName: String): string;

function MouseShowCursor(const Show: boolean): boolean;

const
  pi2 = 2 * pi;

var
  SoundMusic: Boolean = True;
  SoundFx: Boolean = True;

implementation
uses Dises, Types;

function MU (const s0, v0: Real; const t: cardinal): Real;
begin
  Result:= s0 + v0 / 1000 * t;
end;

function Velocidade (const v0, a: Real; const t: cardinal): Real;
begin
  Result:= v0 + a * t / 1000;
end;

function MC (const Angle, RPM: Real; const t: cardinal): Real;
begin
  Result:= Angle + pi2 * RPM * t / 60000;
end;

function AcMC (const RPM, a: Real; const t: cardinal): Real;
begin
  Result:= RPM + a / 1000 * t;
end;

function  PolMod (const Vx, Vy: Real): Real;
begin
  Result:= Sqrt (Sqr (Vx) + Sqr (Vy))
end;

function  PolAngle (const Vx, Vy: Real): Real;
begin
  if (Vx = 0) or (Vy = 0) then
    Result:= 0
  else
    Result:= ArcCos ((Vx + Vy) / (Vx * Vy));
end;

function RectX (const Modulus, Angle: Real): Real;
begin
  Result:= cos (Angle) * Modulus;
end;

function RectY (const Modulus, Angle: Real): Real;
begin
  Result:= -sin (Angle) * Modulus;
end;

procedure RectXY (const Modulus, Angle: Real; var X: Real; var Y: Real);
var
  s, c: Extended;
begin
  SinCos(Angle, s, c);
  X:=  c * Modulus;
  Y:= -s * Modulus;
end;

function ValidAngle (const Value: Real): Real;
var
  r: Integer;
begin
  r:= Trunc (Value / pi2);
  if Value < 0 then
    Result:= (r + 1) * pi2 + Value
  else if Value > pi2 then
    Result:= value - r * pi2
  else
    Result:= Value;
end;

function Dist (const P1, P2: TPoint): Real;
begin
  Result:= Sqrt (Sqr (P1.X - P2.X) + Sqr (P1.Y - P2.Y));
end;

{ ************************************************************ }
{   Real Rect Functions                                        }
{ ************************************************************ }

function Rect2Real (const Rc: TRect): TRealRect;
begin
  Result.Left:= Rc.Left;
  Result.Top:= Rc.Top;
  Result.Right:= Rc.Right;
  Result.Bottom:= Rc.Bottom;
end;

function Real2Rect (const Rc: TRealRect): TRect;
begin
  Result.Left:= Round (Rc.Left);
  Result.Top:= Round (Rc.Top);
  Result.Right:= Round (Rc.Right);
  Result.Bottom:= Round (Rc.Bottom);
end;

function RealBounds (const Left, Top, Width, Height: Real): TRealRect;
begin
  Result.Left:= Left;
  Result.Top:= Top;
  Result.Right:= Left + Width;
  Result.Bottom:= Top + Height;
end;

procedure RealOffSetRect (out Rc: TRealRect; X, Y: Real);
begin
  Rc.Left:= Rc.Left + X;
  Rc.Top:= Rc.Top + Y;
  Rc.Right:= Rc.Right + X;
  Rc.Bottom:= Rc.Bottom + Y;
end;

function RealCenter (const R: TRealRect): TRealPoint;
begin
  Result.X:= R.Left + (R.Right - R.Left) / 2;
  Result.Y:= R.Top + (R.Bottom - R.Top) / 2;
end;

function IntersectWidth (R1, R2: TRect): Integer;
begin
  if R2.Left > R1.Left then R1.Left:= R2.Left;
  if R2.Right < R1.Right then R1.Right:= R2.Right;
  if R1.Right > R1.Left then
    Result:= R1.Right - R1.Left
  else
    Result:= 0;
end;

function IntersectWidth (R1, R2: TRealRect): Real;
begin
  if R2.Left > R1.Left then R1.Left:= R2.Left;
  if R2.Right < R1.Right then R1.Right:= R2.Right;
  if R1.Right > R1.Left then
    Result:= R1.Right - R1.Left
  else
    Result:= 0;
end;

function IntersectHeight (R1, R2: TRect): Integer;
begin
  if R2.Top > R1.Top then R1.Top:= R2.Top;
  if R2.Bottom < R1.Bottom then R1.Bottom:= R2.Bottom;
  if R1.Bottom > R1.Top then
    Result:= R1.Bottom - R1.Top
  else
    Result:= 0;
end;

function IntersectHeight (R1, R2: TRealRect): Real;
begin
  if R2.Top > R1.Top then R1.Top:= R2.Top;
  if R2.Bottom < R1.Bottom then R1.Bottom:= R2.Bottom;
  if R1.Bottom > R1.Top then
    Result:= R1.Bottom - R1.Top
  else
    Result:= 0;
end;

function DefaultTranspColor (Bmp: TBitmap): TColor;
begin
  Result:= Bmp.Canvas.Pixels [0, Bmp.Height - 1];
end;

procedure ImageRotate (Src, Dest: TBitmap; const Angle: Real;
  const BkColor: TColor);
var
  VSin, VCos: Extended;
  iX, iY, pX, pY, mX, mY: integer;
begin
  { Cria a Imagem Principal }
  Dest.Assign (Src);
  Dest.Canvas.Brush.Color:= BkColor;
  Dest.Canvas.FillRect(Dest.Canvas.ClipRect);

  mX:= Src.Width div 2;
  mY:= Src.Height div 2;

  for iX:= 0 to Src.Width - 1 do
    for iY:= 0 to Src.Height - 1 do
    begin
      if Angle <> 0 then
      begin
        SinCos(Angle, VSin, VCos);
        pX:= Round (VCos * (iX - mX) + VSin * (iY - mY)) + mX;
        pY:= -Round (VCos * (- iY + mY) + VSin * (iX - mX)) + mY;
      end else
      begin
        pX:= iX;
        pY:= iY;
      end;
      SetPixelV(Dest.Canvas.Handle, pX, pY, GetPixel (Src.Canvas.Handle, iX, iY));
    end;
end;

procedure ImageMirror (Src, Dest: TBitmap; const x, y: Boolean);
var
  sX, sY, sW, sH: Integer;
begin
  //Ajuste Horizontal
  if x then
  begin
    sX:=  Src.Width - 1;
    sW:= -Src.Width;
  end else
  begin
    sX:= 0;
    sW:= Src.Width;
  end;
  //Ajuste Vertical
  if y then
  begin
    sY:=  Src.Height - 1;
    sH:= -Src.Height;
  end else
  begin
    sY:= 0;
    sH:= Src.Height - 1;
  end;
  //Copia Imagem
  StretchBlt(Dest.Canvas.Handle, 0, 0, Dest.Width, Dest.Height,
             Src.Canvas.Handle, sX, sY, sW, sH, SRCCOPY);
end;

procedure ImageMask (Src, Dest: TBitmap; TranspColor: TColor);
var
  i, j: Integer;
begin
  if TranspColor = clDefault then
    TranspColor:= DefaultTranspColor(Src);
  for i:= 0 to Src.Width - 1 do
    for j:= 0 to Src.Height - 1 do
    begin
      if GetPixel(Src.Canvas.Handle, i, j) = COLORREF( TranspColor) then
      begin
        SetPixelV(Src.Canvas.Handle, i, j, clBlack);
        SetPixelV(Dest.Canvas.Handle, i, j, clWhite);
      end else
        SetPixelV(Dest.Canvas.Handle, i, j, clBlack);
    end;

end;

Type
  TColorFilter = record
    Color: TColor;
    Count: Byte;
  end;

procedure ImageFilter (Img: TBitmap; const BkColor: TColor;
  const Prec: TDxImageFilter);
var
  c: Array of TColorFilter;

  procedure AddColor (Color: TColor);
  var
    i: Integer;
    Found: Boolean;
  begin
    if Color <> BkColor then
    begin
      Found:= False;
      for i:= 0 to Length (c) - 1 do
        if c[i].Color = Color then
        begin
          Inc (c[i].Count);
          Found:= True;
        end;
      if not Found then
      begin
        i:= Length (c) + 1;
        SetLength (c, i);
        c[i - 1].Color:= Color;
        c[i - 1].Count:= 1;
      end;
    end;
  end;

  function MaxColor: TColor;
  var
    i, max: Integer;
  begin
    if Length (c) = 0 then
      Result:= BkColor
    else
    begin
      max:= 0;
      for i:= 1 to Length (c) - 1 do
        if c[i].Count > c[max].Count then
          max:= i;
      if c[max].Count >= Prec then
        Result:= c[max].Color
      else
        Result:= BkColor;
    end;
  end;

var
  Bmp: TBitmap;
  i, j, x, y: Integer;
begin
  Bmp:= TBitmap.Create;
  Bmp.Assign(Img);
  for x:= 1 to Img.Width - 2 do
    for y:= 1 to Img.Height - 2 do
      if Bmp.Canvas.Pixels [x, y] = BkColor then
      begin
        SetLength (c, 0);
        for i:= -1 to 1 do
          for j:= -1 to 1 do
            AddColor (Bmp.Canvas.Pixels [x + i, y + j]);
        Img.Canvas.Pixels [x, y]:= MaxColor;
      end;
  Bmp.Free;
end;

procedure FillImage (Dest: TCanvas; const dx, dy, dw, dh: Integer;
  Src: TCanvas; const sx, sy: Integer);
var
  xS, yS, hS, wS, xD, yD, h, w: Integer;
begin
  wS:= Src.ClipRect.Right;
  hS:= Src.ClipRect.Bottom;
  yD:= dy;
  if sy >= 0 then
    yS:= sy mod hS
  else
    yS:= hs + sy mod hS;
  while yD < dy + dh do
  begin
    if hs - yS > dh then
      h:= dh
    else
      h:= hS - yS;
    xD:= dx;
    if sx >= 0 then
      xS:= sx mod wS
    else
      xS:= ws + sx mod wS;
    while xD < dx + dw do
    begin
      if wS - xS > dw then
        w:= dw
      else
        w:= wS - xS;
      BitBlt(Dest.Handle, xD, yD, w, h, Src.Handle, xS, yS, SRCCOPY);
      Inc (xD, w);
      xS:= 0;
    end;
    Inc (yD, h);
    yS:= 0;
  end;
end;

procedure FillImage (Img, Src: TBitmap);
begin
  FillImage (Img.Canvas, 0, 0, Img.Width, Img.Height, Src.Canvas, 0, 0);
end;

procedure GetCrossImg (Canvas: TCanvas; const Rc: TRect);
begin
  Canvas.Pen.Color:= clBlack;
  Canvas.Pen.Style:= psSolid;
  Canvas.PenPos:= Rc.TopLeft;
  Canvas.LineTo (Rc.Right, Rc.Bottom);
  Canvas.PenPos:= Point (Rc.Left, Rc.Bottom);
  Canvas.LineTo (Rc.Right, Rc.Top);
end;

procedure ShowMCIError (const Err: Cardinal);
var
  s: Array [0..$FF] of char;
begin
  mciGetErrorString (Err, @S, Length (s));
  ShowMessage (s);
end;

procedure SoundConfig (const Music, Fx: Boolean);
begin
  SoundMusic:= Music;
  SoundFx:= Fx;
end;

function ChangeDisplay (Width, Height, BitsPerPixel: Integer; CurrentMode: PDevMode): Boolean;
const
  ENUM_CURRENT_SETTINGS = Cardinal(-1);
  ENUM_REGISTRY_SETTINGS = Cardinal(-2);
var
  Dev: TDevMode;
begin
  FillChar(CurrentMode^, SizeOf(TDevMode), 0);
  CurrentMode.dmSize := SizeOf(TDevMode);
  Result:= EnumDisplaySettings(nil, ENUM_CURRENT_SETTINGS, CurrentMode^);
  if Result then begin
    FillChar(Dev, SizeOf(TDevMode), 0);
    with Dev do
    begin
      dmSize := SizeOf(TDevMode);
      dmPelsWidth := Width;
      dmPelsHeight := Height;
      dmBitsPerPel := BitsPerPixel;
      dmFields := DM_PELSWIDTH or DM_PELSHEIGHT;
      if BitsPerPixel > 0 then
        dmFields:= dmFields or DM_BITSPERPEL;
    end;
    Result:= True;
    //Result := ChangeDisplaySettings(Dev, CDS_FULLSCREEN) = DISP_CHANGE_SUCCESSFUL;

  end;
end;

function RestoreDisplay(const DevMode: TDevMode): Boolean;
var
  tmp: TDevMode;
begin
  tmp := DevMode;
  tmp.dmFields := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT;
  Result := ChangeDisplaySettings(tmp, CDS_FULLSCREEN) = DISP_CHANGE_SUCCESSFUL;
end;

function RelativePath (FileName: String): string;
var
  i: integer;
begin
  Result:= FileName;
  if (AppDir <> '') and (pos (AppDir, FileName) > 0) then
  begin
    i:= length (AppDir);
    Result:= copy (FileName, i + 1, length (FileName) - i)
  end else

end;

function MouseShowCursor(const Show: boolean): boolean;
var
  i: integer;
begin
  i := ShowCursor(LongBool(true));
  if Show then
  begin
    Result := i >= 0;
    while i < 0 do
    begin
      Result := ShowCursor(LongBool(true)) >= 0;
      Inc(i);
    end;
  end else
  begin
    Result := i < 0;
    while i >= 0 do
    begin
      Result := ShowCursor(LongBool(false)) < 0;
      Dec(i);
    end;
  end;
end;




{ TDxVector }

procedure TDxVector.AssignTo(Dest: TPersistent);
var
  d: TDxVector;
begin
  d:= Dest as TDxVector;
  d.Fx:= Fx;
  d.Fy:= Fy;
  d.FMode:= FMode;
  d.FAngleType:=  FAngleType;
end;

constructor TDxVector.Create;
begin 
  inherited;
  FMode:= vmRect;
end;

function TDxVector.GetAngle: Real;
begin
  Result:= GetRadAngle;
  if FAngleType = atDeg then
    Result:= RadToDeg(Result);
end;

function TDxVector.GetModulus: Real;
begin
  if FMode = vmRect then
    Result:= PolMod(Fx, Fy)
  else
    Result:= Fx;
end;

function TDxVector.GetRadAngle: Real;
begin
  if FMode = vmRect then
    Result:= PolAngle(Fx, Fy)
  else
    Result:= Fy;
end;

function TDxVector.GetValueX: Real;
begin
  if FMode = vmRect then
    Result:= Fx
  else
    Result:= RectX(Fx, Fy);
end;

function TDxVector.GetValueY: Real;
begin
  if FMode = vmRect then
    Result:= Fy
  else
    Result:= RectY(Fx, Fy);
end;

function TDxVector.IsPolVector: Boolean;
begin
  Result:= FMode = vmPol;
end;

function TDxVector.IsRectVector: Boolean;
begin
  Result:= FMode = vmRect;
end;

procedure TDxVector.Reset;
begin
  Fx:= 0;
  Fy:= 0;
end;

procedure TDxVector.SetAngle(const Value: Real);
var
  v: Real;
begin
  { Converte o Angulo }
  if FAngleType = atDeg then
    v:= DegToRad(Value)
  else
    v:= Value;
  { Valida Modo }
  if FMode = vmPol then
    Fy:= ValidAngle (v)
  else
    RectXY(GetModulus, ValidAngle (v), Fx, Fy);
end;

procedure TDxVector.SetMode(const Value: TDxVectorMode);
var
  Bx, By: Real;
begin
  if FMode <> Value then
  begin
    Bx:= Fx;
    By:= Fy;
    case Value of
      vmRect:
        RectXY(Bx, By, Fx, Fy);
      vmPol:
        begin
          Fx:= PolMod(Bx, By);
          Fy:= PolAngle (Bx, By);
        end;
    end;
    FMode := Value;
  end;
end;

procedure TDxVector.SetModulus(const Value: Real);
begin
  if FMode = vmRect then
    RectXY(GetModulus, GetAngle, Fx, Fy)
  else
    Fx:= Value;
end;

procedure TDxVector.SetRadAngle(const Value: Real);
var
  vA: Real;
begin
  vA:= ValidAngle(Value);
  if FMode = vmRect then
    RectXY(GetModulus, vA, Fx, Fy)
  else
    Fy:= vA;
end;

procedure TDxVector.SetValueX(const Value: Real);
var
  tmp: Real;
begin
  if FMode = vmRect then
    Fx:= Value
  else begin
    tmp:= RectY(Fx, Fy);
    Fx:= PolMod (Value, tmp);
    Fy:= PolAngle(Value, tmp);
  end;
end;

procedure TDxVector.SetValueY(const Value: Real);
var
  tmp: Real;
begin
  if FMode = vmRect then
    Fy:= Value
  else begin
    tmp:= RectX(Fx, Fy);
    Fx:= PolMod (tmp, Value);
    Fy:= PolAngle(tmp, Value);
  end;
end;

{ TDxCustomRotation }

procedure TDxCustomRotation.AssignTo(Dest: TPersistent);
var
  d: TDxCustomRotation;
begin
  d:= Dest as TDxCustomRotation;
  d.FRPM:= FRPM;
  d.FAccTg:= FAccTg;
end;

function TDxCustomRotation.CalcAngle(const t: Cardinal; const Angle: Real): Real;
begin
  Result:=  MC (Angle, FRPM, t);
  Result:= ValidAngle(Result); 
end;

procedure TDxCustomRotation.CalcRPM(const t: Cardinal);
begin
  if FAccTg <> 0 then
    FRPM:= AcMC (FRPM, FAccTg, t);
end;

constructor TDxCustomRotation.Create;
begin
  inherited Create;
  //
end;

procedure TDxCustomRotation.Reset;
begin
  FRPM:= 0;
  FAccTg:= 0;
end;

{ TDxVectorEx }

procedure TDxVectorEx.AssignTo(Dest: TPersistent);
var
  d: TDxVectorEx;
begin
  inherited;
  d:= Dest as TDxVectorEx;
  d.FRotation.Assign (FRotation);
end;

constructor TDxVectorEx.Create;
begin
  inherited Create;
  FRotation:= TDxCustomRotation.Create;
end;

destructor TDxVectorEx.Destroy;
begin
  FRotation.Free;
  inherited;
end;

procedure TDxVectorEx.Execute(const t: Cardinal);
begin
  FRotation.CalcRPM(t);
  if FRotation.FRPM <> 0 then
    RadAngle:= FRotation.CalcAngle (t, RadAngle);
end;

function TDxVectorEx.GetAccTg: Real;
begin
  Result:= FRotation.AccTg;
end;

function TDxVectorEx.GetRPM: Real;
begin
  Result:= FRotation.RPM;
end;

procedure TDxVectorEx.SetAccTg(const Value: Real);
begin
  FRotation.AccTg:= Value;
end;

procedure TDxVectorEx.SetRPM(const Value: Real);
begin
  FRotation.RPM:=  Value;
end;

{ TDxRotation }

procedure TDxRotation.AssignTo(Dest: TPersistent);
var
  d: TDxRotation;
begin
  inherited;
  d:= TDxRotation (Dest);
  d.FAngle:= FAngle;
  d.FAngleType:= FAngleType;
end;

procedure TDxRotation.Execute(t: Cardinal);
begin
  CalcRPM(t);
  if FRPM <> 0 then
    FAngle:= CalcAngle (t, FAngle);
end;

function TDxRotation.GetAngle: Real;
begin
  if FAngleType = atDeg then
    Result:= RadToDeg(FAngle)
  else
    Result:= FAngle;
end;

procedure TDxRotation.SetAngle(const Value: Real);
var
  v: Real;
begin
  if FAngleType = atDeg then
    v:= DegToRad(Value)
  else
    v:= Value;
  FAngle:= ValidAngle (v);
end;

{ TDxRect }

procedure TDxRect.AssignTo(Dest: TPersistent);
var
  d: TDxRect;
begin
  d:= Dest as TDxRect;
  d.FRect:= FRect;
end;

{ TDxAudio }

function TDxAudio.Close: Boolean;
var
  GenParm: TMCI_Generic_Parms;
begin
  if FDeviceID <> 0 then
    FErr:= mciSendCommand(FDeviceID, MCI_CLOSE, MCI_WAIT, Longint (@GenParm));
  Result:= FErr = 0;
  if Result then
    FDeviceID:= 0;
end;

constructor TDxAudio.Create(AOwner: TComponent);
begin
  FErr:= 0;
  FDeviceID:= 0;
  FEnabled:= True;
  FAutoOpen:= True;
  inherited;
end;

destructor TDxAudio.Destroy;
begin
  if FDeviceID <> 0 then
    Close;
  inherited;
end;

function TDxAudio.Execute: Boolean;
begin
  Result:= False;
  if Enabled and (FDeviceID <> 0) then
  begin
    Inc (FPosition, GetTickCount - FTimer);
    FTimer:= GetTickCount;
    case FMode of
      amStop:
        Result:= Play (True);
      amLoop:
        if FPosition >= FLength then
          Result:= Play (True);
    end;
  end;
end;

procedure TDxAudio.Loaded;
begin
  inherited;
  if FAutoOpen then Open;
end;

function TDxAudio.Open: Boolean;
var
  Flags: Longint;
  SetParm: TMCI_Set_Parms;
  OpenParm: TMCI_Open_Parms;
  StatusParm: TMCI_Status_Parms;
begin
  Result:= False;
  if FDeviceID <> 0 then Exit;
  FPosition:= 0;
  { Abre o Arquivo de Media }
  FillChar(OpenParm, SizeOf(TMCI_Open_Parms), 0);
  OpenParm.lpstrElementName := PChar (AppDir + FFileName);
  Flags:= MCI_OPEN_ELEMENT or MCI_WAIT;
  FErr:= mciSendCommand(0, MCI_OPEN, Flags, Longint(@OpenParm));
  if FErr = 0 then
    FDeviceID:= OpenParm.wDeviceID
  else
    FDeviceID:= 0;
  Result:= FErr = 0;
  if Result then
  begin
    { Altera o Time Format }
    SetParm.dwTimeFormat:= MCI_FORMAT_MILLISECONDS;
    Flags:= MCI_WAIT or MCI_SET_TIME_FORMAT;
    FErr:= mciSendCommand(FDeviceID, MCI_SET, Flags, Longint (@SetParm));
    { Carrega Tamanho da Trilha }
    Flags:= MCI_WAIT or MCI_STATUS_ITEM;
    StatusParm.dwItem:= MCI_STATUS_LENGTH;
    FErr:= mciSendCommand(FDeviceID, MCI_STATUS, Flags, Longint (@StatusParm));
    FLength:= StatusParm.dwReturn;
  end else
    FEnabled:= False;
end;

function TDxAudio.Pause: Boolean;
var
  GenParm: TMCI_Generic_Parms;
begin
  if FDeviceID <> 0 then
    FErr:= mciSendCommand(FDeviceID, MCI_PAUSE, MCI_WAIT, Longint (@GenParm));
  Result:= FErr = 0;
end;

function TDxAudio.Play (ARewind: Boolean = False): Boolean;
var
  Parm: Cardinal;
  PlayParm: TMCI_Play_Parms;
begin
  Parm:= 0;
  FillChar (PlayParm, SizeOf (TMCI_Play_Parms), 0);
  if ARewind then
  begin
    PlayParm.dwFrom:= 0;
    Parm:= MCI_FROM;
    FPosition:= 0;
  end;
  FErr:= mciSendCommand(FDeviceID, MCI_PLAY, Parm, Longint (@PlayParm));
  Result:= FErr = 0;
  if Result then
    FTimer:= GetTickCount;
end;

function TDxAudio.Rewind: Boolean;
var
  GenParm: TMCI_Generic_Parms;
begin
  FErr:= mciSendCommand(FDeviceID, MCI_SEEK, MCI_SEEK_TO_START or MCI_WAIT, Longint (@GenParm));
  Result:= FErr = 0;
  if Result then
    FPosition:= 0;
end;

procedure TDxAudio.SetFileName(const Value: TFileName);
begin
  FFileName:= RelativePath (Value);
end;

function TDxAudio.Stop: Boolean;
var
  GenParm: TMCI_Generic_Parms;
begin
  FErr:= mciSendCommand(FDeviceID, MCI_STOP, MCI_WAIT, Longint (@GenParm));
  Result:= FErr = 0;
end;

end.
