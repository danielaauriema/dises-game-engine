{ ********************************************************************** }
{  Dises Game Engine Copyright (C) 2008 Danyz                            }
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
{  Dises Game Engine / RunTime Library                                   }
{  Biblioteca para a Emulação de Jogos 2D e RPG                          }
{  Versão: 1.0                                                           }
{  Criada por: Dany Fernandes                                            }
{  Data: 09/12/2007 (DxGames)                                            }
{  Modificado em: 12/12/2007                                             }
{                 24/01/2008 - Modificado p/ Dises                       }
{ ********************************************************************** }

unit Dises;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, MMSystem, StdCtrls, DxUtils, Math, CommCtrl;

type


{ Keyboard Controls }

  TDxKey = (kLeft, kRight, kUp, kDown, kBtnA, kBtnB, kBtnC, kBtnD,
    kBtnL, kBtnR, kStart, kSelect, kNone);

  TDxKeySet = set of TDxKey;

  TDxKeyConfig = Array [TDxKey] of Word;

{ Joy Controls }

  TDxJoy = (jXUp, jXDown, jYUp, jYDown, jZup, jZDown, jRUp, jRDown,
    jUUp, jUDown, jVUp, jVDown, jBtn1, jBtn2, jBtn3, jBtn4, jBtn5, jBtn6,
    jBtn7, jBtn8, jNone);

  TDxJoySet = set of TDxJoy;

  TDxJoyConfig = array [TDxKey] of TDxJoy;

  TDxJoyPos = record
    X: DWORD;
    Y: DWORD;
    Z: DWORD;
    R: DWORD;
    U: DWORD;
    V: DWORD;
  end;

const

  DefKeyConfig: TDxKeyConfig = (VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN,
    ORD ('A'), ORD ('S'), ORD ('D'), ORD ('Z'),
    ORD ('X'), ORD ('C'), VK_RETURN, VK_TAB, 0);

  DefJoyConfig: TDxJoyConfig = (jXDown, jXUp, jYDown, jYUp,
    jBtn1, jBtn2, jBtn3, jBtn4, jZUp, jZDown, jRUp, jRDown, jNone);

  MaskBk = clWhite;

var
  AppDir: String;

type

  TDxGameState = (gsUnload, gsLoading, gsStopping, gsStopped, gsRunning);

  TDxStopAction = (saNone, saReload, saLoadNextStage, saStartNextStage);

  TDxSide = (bsLeft, bsTop, bsRight, bsBottom);
  TDxSides = set of TDxSide;

  TDxSideRect = Array [TDxSide] of TRect;

  TDxClipMode = (cmNone, cmMap, cmFrame, cmMargin);

  TDxSkinOptions = (soMirrorX, soMirrorY, soMirrorXY);
  TDxSkinOptionsSet = set of TDxSkinOptions;

  TDxPoints = Array of TPoint;

  TDxMapLine = Array of Byte;
  TDxMapData = Array of TDxMapLine;

  TDxMapRotate = (mrVert, mrHorz);
  TDxMapRotateSet = set of TDxMapRotate;

  TDxActionOptions = (amFrameReset, amCountReset, amReverse);
  TDxActionOptionsSet = set of TDxActionOptions;

  TDxColisionResult = (crNextSide, crSkip);

  TDxColisionData = Record
    Rect: TRect;
    Area: TRect;
    Side: TDxSide;
  end;

  TDxTileMode = (tmNone, tmSolid, tmMargin);

  TDxMapColision = (mcNone, mcDefault, mcKill, mcUser);

  TDxSpriteColision = (scNone, scKillSender, scKillSprite,
    scKillBoth, scFixSender, scFixSprite);

  TDxRotateSteps = 1..36;
  TDxScroll = 0..10000;

  TDxRectMode = (rmNormal, rmFine, rmCircle);

  TDxVideoMode = (vmDefault,
                  vm800x600, vm800x600x16,
                  vm640x480, vm640x480x16,
                  vm320x240, vm320x240x16);

const
  VideoInfo: Array [TDxVideoMode] of String =
    ('Default',
     '800x600', '800x600x16',
     '640x480', '640x480x16',
     '320x240', '320x240x16');
Type

{ Forward Declarations }

  TDxStage = class;
  TDxSprite = class;
  TDxMachine = class;
  TDxTileItem = class;
  TDxCustomSprite = class;
  TDxSpriteManager = class;

{ Procedure Types }

  TDxCustomSpriteEvent = procedure (Sender: TDxCustomSprite) of object;

  TDxDrawingEvent = procedure (Sender: TDxCustomSprite; Canvas: TCanvas; const FrameRc: TRect) of object;

  TDxSpriteEvent = procedure (Sender: TDxSprite) of object;

  TDxKeyEvent = procedure (Sender: TDxSprite; const Key: TDxKey; const KeySet: TDxKeySet) of object;

  TDxSpriteColisionEvent = procedure (Sender, Sprite: TDxSprite; const R: TRect) of object;

  TDxAutoColisionEvent = procedure (Sprite1, Sprite2: TDxSprite; const R: TRect) of object;

  TDxAutoFreezeEvent = procedure (Sender: TDxSprite; Value: Boolean) of object;

  TDxColisionEvent = procedure (out ColisionResult: TDxColisionResult;
    Sender: TDxSprite; const Info: TDxColisionData) of object;

  TDxTileEvent = procedure (out ProcColision: Boolean; Sender: TDxSprite;
    Tile: TDxTileItem; const p: TPoint) of object;

  TDxDrawScreenEvent = procedure (Sender: TDxStage; AScreen, AFrame: TBitmap) of object;

{ TDxPlayer }

  TDxPlayer = class (TPersistent)
  private
    { Joy Controls }
    FJoyId: Integer;
    FDelay: Cardinal;
    FJoyPos: TDxJoyPos;
    FJoyCaps: TJoyCaps;
    FJoyConfig: TDxJoyConfig;
    { Key Controls }
    FKeyConfig: TDxKeyConfig;
    { Sprite Controls }
    FSprite: TDxSprite;
    { Joy Controls }
    function  JoyDecode (const Joy: TDxJoySet): TDxKeySet;
    procedure SetJoyId(const Value: Integer);
    procedure JoyCapture (const t: Cardinal);
    { Keyboard Controls }
    function  KeyDecode (const Key: Word): TDxKey;
    procedure KeyUp (const Key: TDxKey); overload;
    procedure KeyDown (const Key: TDxKey); overload;
    procedure KeyUp (const Key: Word); overload;
    procedure KeyDown (const Key: Word); overload;
  public
    constructor Create;
    property JoyPos: TDxJoyPos read FJoyPos;
    property JoyCaps: TJoyCaps read FJoyCaps;
    property JoyConfig: TDxJoyConfig read FJoyConfig write FJoyConfig;
    property KeyConfig: TDxKeyConfig read FKeyConfig write FKeyConfig;
  published
    property JoyId: Integer read FJoyId write SetJoyId default -1;
    property Sprite: TDxSprite read FSprite write FSprite;
  end;

{ IDxDisplay }

  IDxDisplay = Interface
    procedure DrawFrame;
  end;

{ TDxThread }

  TDxThread = class (TThread)
  private
    FCount: Word;
    FDelay: Cardinal;
    FTimer: Cardinal;
    FMachine: TDxMachine;
    FState: TDxGameState;
    procedure TimerReload;
    procedure AcFPS;
    procedure UpdateState;
    procedure StopMachine;
  protected
    procedure Execute; override;
  public
    constructor Create(Machine: TDxMachine);
  end;

{ TDxMachine Class }

  TDxMachine = class (TComponent)
  private
    { Graphic Controls }
    OldMode: TDevMode;
    FDisplay: IDxDisplay;
    FFrameWidth: Integer;
    FFrameHeight: Integer;
    FVideoLoaded: Boolean;
    FVideoMode: TDxVideoMode;
    { Player Controls }
    FOldCenter: TPoint;
    FPlayer1: TDxPlayer;
    FPlayer2: TDxPlayer;
    FPlayerYOffSet: Integer;
    FPlayerXOffSet: Integer;
    { Frame Controls }
    FFrame: TBitmap;
    FScreen: TBitmap;
    FYOffSet: Integer;
    FXOffSet: Integer;
    { FPS Controls }
    FInterval: Cardinal;
    FAcDelay: Word;   //Real FPS
    FFrameSkip: Byte;
    FFrameCount: Byte;
    { Controle de Execução }
    FStage: TDxStage;
    FState: TDxGameState;
    FAction: TDxStopAction;
    FThread: TDxThread;
    FShowCursor: Boolean;
    { Controle do Teclado }
    FOnKeyUp: TKeyEvent;
    FOnKeyDown: TKeyEvent;
    FOnStart: TNotifyEvent;
    FOnStop: TNotifyEvent;
    { Player Controls }
    function GetPlayer1: TDxSprite;
    function GetPlayer2: TDxSprite;
    function GetPlayersCenter: TPoint;
    procedure SetPlayer1(const Value: TDxSprite);
    procedure SetPlayer2(const Value: TDxSprite);
    { Frame Controls }
    function GetFrameRect: TRect;
    { Controle de Execução }
    procedure Execute;
    procedure DoExecute;
    procedure SetStage(const Value: TDxStage);
    { Graphic Controls }
    procedure DrawFrame;
    function GetAppDir: string;
    procedure SetAppDir(const Value: string);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    xh, xw: integer;
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load;
    procedure Unload;
    procedure LoadBuffers;
    { Controle de Execução }
    procedure Start;
    procedure Stop;
    procedure LoadStage; overload;
    procedure LoadStage (const Value: TDxStage); overload;
    procedure ReloadStage;
    procedure LoadNextStage (AStart: Boolean);
    { Graphic Controls }
    property Screen: TBitmap read FScreen;
    property Display: IDxDisplay read FDisplay write FDisplay;
    { Player Controls }
    property PlayersCenter: TPoint read GetPlayersCenter;
    property MngPlayer1: TDxPlayer read FPlayer1;
    property MngPlayer2: TDxPlayer read FPlayer2;
    { Frame Controls }
    property XOffSet: Integer read FXOffSet;
    property YOffSet: Integer read FYOffSet;
    property FrameRect: TRect read GetFrameRect;
    { FPS Controls }
    property AcDelay: Word read FAcDelay;
    property Interval: Cardinal read FInterval;
    { Controle de Execução }
    property State: TDxGameState read FState;
  published
    property ShowCursor: Boolean read FShowCursor write FShowCursor default false;
    property AppDir: string read GetAppDir write SetAppDir;
    { Player Properties }
    property Player1: TDxSprite read GetPlayer1 write SetPlayer1;
    property Player2: TDxSprite read GetPlayer2 write SetPlayer2;
    property PlayerXOffSet: Integer read FPlayerXOffSet write FPlayerXOffSet default 0;
    property PlayerYOffSet: Integer read FPlayerYOffSet write FPlayerYOffSet default 0;
    { Frame Controls }
    property FrameSkip: Byte read FFrameSkip write FFrameSkip default 0;
    property FrameWidth: Integer read FFrameWidth write FFrameWidth default 0;
    property FrameHeight: Integer read FFrameHeight write FFrameHeight default 0;
    property VideoMode: TDxVideoMode read FVideoMode write FVideoMode default vm640x480x16;
    { Stage Controls }
    property Stage: TDxStage read FStage write SetStage;
    { Controle do Teclado }
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property OnStop: TNotifyEvent read FOnStop write FOnStop;
  end;

{ TDxForm Class }

  TDxForm = class (TForm, IDxDisplay)
  private
    cX, cY: Integer;
    FMachine: TDxMachine;
    procedure SetMachine (const Value: TDxMachine);
    { IDxDisplay }
    procedure DrawFrame;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
  public
    property Machine: TDxMachine read FMachine write SetMachine;
    procedure Recenter (AResize: Boolean);
  end;

{ TDxImage }

  TDxImage = class (TComponent)
  private
    FBitmap: TBitmap;
    FLoaded: Boolean;
    FHeight: Integer;
    FWidth: Integer;
    FAutoOpen: Boolean;
    FFileName: TFileName;
    procedure SetFileName(const Value: TFileName);
  protected
    procedure Loaded; override;
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load;
    procedure Unload;
    property Bitmap: TBitmap read FBitmap;
    property ImgLoaded: Boolean read FLoaded;
  published
    property FileName: TFileName read FFileName write SetFileName;
    property BmpWidth: Integer read FWidth write FWidth default 0;
    property BmpHeight: Integer read FHeight write FHeight default 0;
    property AutoOpen: Boolean read FAutoOpen write FAutoOpen default True;
  end;

{ TDxImageItem Class }

  TDxImageItem = class
  private
    FRect: TRect;
    FMask: TBitmap;
    FFrame: TBitmap;
    procedure LoadFineRect;
  public
    constructor Create; overload;
    constructor Create (const AWidth, AHeight: Integer); overload;
    destructor Destroy; override;
    procedure LoadMask (TranspColor: TColor);
    procedure LoadRect (const Mode: TDxRectMode);
    property Rect: TRect read FRect write FRect;
    property Mask: TBitmap read FMask write FMask;
    property Frame: TBitmap read FFrame write FFrame;
  end;

{ TDxImages Class }

  TDxImages = class (TComponent)
  private
    FItems: TList;
    FFileName: TFileName;
    function GetItem(const Index: Integer): TDxImageItem;
    procedure SetFileName(const Value: TFileName);
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure AddItem (AItem: TDxImageItem);
    property Item [const Index: Integer]: TDxImageItem read GetItem;
    procedure LoadFromFile (AFileName: TFileName; AWidth, AHeight: Integer;
      AMode: TDxRectMode; TranspColor: TColor);
    procedure LoadMasks (TranspColor: TColor);
    procedure Draw (const Index, x, y: Integer; dest: TCanvas);
    procedure DrawMasked (const Index, x, y: Integer; dest: TCanvas);
  published
    property FileName: TFileName read FFileName write SetFileName;
  end;

{ TDxTileItem Class}

  TDxTileItem = class (TCollectionItem)
  private
    FName: String;
    FBkColor: TColor;
    FMargin: TDxRect;
    FTileMsk: TBitmap;
    FTileImg: TBitmap;
    FMode: TDxTileMode;
    FImageIndex: Integer;
    FTransparent: Boolean;
    FTileEvent: Boolean;
    FOnTileEvent: TDxTileEvent;
    procedure SetName(const Value: String);
    procedure SetMargin(const Value: TDxRect);
    procedure SetImageIndex(const Value: Integer);
    procedure SetTransparent(const Value: Boolean);
  protected
    function GetDisplayName: String; override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure LoadImage (const AWidth, AHeight: Integer);
    procedure LoadMask;
    procedure Unload;
    function TileRect (const x, y: Integer): TRect; overload;
    function TileRect (const p: TPoint): TRect; overload;
    function FineRect (const x, y: Integer): TRect; overload;
    function FineRect (const p: TPoint): TRect; overload;
    property TileImg: TBitmap read FTileImg;
    property TileMsk: TBitmap read FTileMsk;
  published
    property Name: String read FName write SetName;
    property Mode: TDxTileMode read FMode write FMode;
    property Margin: TDxRect read FMargin write SetMargin;
    property BkColor: TColor read FBkColor write FBkColor default clDefault;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
    property TileEvent: Boolean read FTileEvent write FTileEvent default False;
    property OnTileEvent: TDxTileEvent read FOnTileEvent write FOnTileEvent;
  end;

{ TDxTileList Class }

  TDxTileList = class (TCollection)
  private
    FOwner: TComponent;
    function  GetItem(const Index: Integer): TDxTileItem;
    procedure SetItem(const Index: Integer; Value: TDxTileItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create (AOwner: TComponent);
    property Items[const Index: Integer]: TDxTileItem read GetItem write SetItem; default;
  end;

{ TDxTiles Class }

  TDxTiles = class (TComponent)
  private
    FLoaded: Boolean;
    FTileWidth: Word;
    FTileHeight: Word;
    FItems: TDxTileList;
    FFileName: TFileName;
    procedure SetItems(const Value: TDxTileList);
    function GetCount: Integer;
    procedure SetFileName(const Value: TFileName);
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load; overload;
    procedure Load (AFileName: TFileName); overload;
    procedure Unload;
    property Count: Integer read GetCount;
    property TileLoaded: Boolean read FLoaded;
  published
    property Items: TDxTileList read FItems write SetItems;
    property FileName: TFileName read FFileName write SetFileName;
    property TileWidth: Word read FTileWidth write FTileWidth default 32;
    property TileHeight: Word read FTileHeight write FTileHeight default 32;
  end;

{ TDxMap Class }

  TDxMap = class (TComponent)
  private
    FData: TStrings;
    FTiles: TDxTiles;
    FFillColor: TColor;
    FScrollX: TDxScroll;
    FScrollY: TDxScroll;
    FBackground: TDxImage;
    FRotate: TDxMapRotateSet;
    function GetTileWidth: Word;
    function GetTileHeight: Word;
    function GetTileRect (const x, y: Integer): TRect;
    function GetFineRect (const x, y: Integer; ATile: TDxTileItem): TRect;
    procedure SetData(const Value: TStrings);
    procedure SetTiles(const Value: TDxTiles);
    procedure SetBackground(const Value: TDxImage);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    //Converte uma coordenada do mapa de Pixels para Tiles
    function Map2Tile (const P: TPoint): TPoint; overload;
    function Map2Tile (const R: TRect): TRect; overload;
    function Tile2Map (const P: TPoint): TPoint; overload;
    function Tile2Map (const R: TRect): TRect; overload;
    { Retorna a Telha de um mapa especifico }
    function GetTileFromData(AData: TDxMapData;
      x, y: Integer; const ARotate: TDxMapRotateSet): TDxTileItem;
    property TileWidth: Word read GetTileWidth;
    property TileHeight: Word read GetTileHeight;
  published
    property Data: TStrings read FData write SetData;
    property Tiles: TDxTiles read FTiles write SetTiles;
    property Rotate: TDxMapRotateSet read FRotate write FRotate;
    property FillColor: TColor read FFillColor write FFillColor;
    property Background: TDxImage read FBackground write SetBackground;
    property ScrollX: TDxScroll read FScrollX write FScrollX default 1000;
    property ScrollY: TDxScroll read FScrollY write FScrollY default 1000;
  end;

{ TDxCustomSkin }

  TDxCustomSkin = class (TComponent)
  private
    FRay: Word;
    FWidth: Integer;
    FHeight: Integer;
    FLoaded: Boolean;
    FMode: TDxRectMode;
    FTransparent: Boolean;
  protected
    property Ray: Word read FRay write FRay default 0;
    property Mode: TDxRectMode read FMode write FMode default rmNormal;
    property Transparent: Boolean read FTransparent write FTransparent default False;
  public
    constructor Create (AOwner: TComponent); override;
    procedure Load; virtual;
    procedure QuickLoad; virtual;
    procedure Unload; virtual;
    function GetDxImages: TDxImages; overload; virtual; abstract;
    function GetDxImages (Sprite: TDxSprite): TDxImages; overload; virtual; abstract;
    property SkinLoaded: Boolean read FLoaded;
    property Width: Integer read FWidth write FWidth default 32;
    property Height: Integer read FHeight write FHeight default 32;
  end;

{ TDxSkin }

  TDxSkin = class (TDxCustomSkin)
  private
    FImages: TDxImages;
    FMirrorX: TDxImages;
    FMirrorY: TDxImages;
    FMirrorXY: TDxImages;
    FnImages: TFileName;
    FnMirrorX: TFileName;
    FnMirrorY: TFileName;
    FnMirrorXY: TFileName;
    FOptions: TDxSkinOptionsSet;
    procedure SetnImages(const Value: TFileName);
    procedure SetnMirrorX(const Value: TFileName);
    procedure SetnMirrorXY(const Value: TFileName);
    procedure SetnMirrorY(const Value: TFileName);
  public
    constructor Create (AOwner: TComponent); override;
    procedure Load; override;
    procedure Unload; override;
    procedure QuickLoad; override;
    function GetDxImages: TDxImages; override;
    function GetDxImages (Sprite: TDxSprite): TDxImages; override;
    property DxImage: TDxImages read FImages;
    property DxMirrorX : TDxImages read FMirrorX;
    property DxMirrorY : TDxImages read FMirrorY;
    property DxMirrorXY: TDxImages read FMirrorXY;
  published
    property Options: TDxSkinOptionsSet read FOptions write FOptions default [];
    property Images  : TFileName read FnImages write SetnImages;
    property MirrorX : TFileName read FnMirrorX write SetnMirrorX;
    property MirrorY : TFileName read FnMirrorY write SetnMirrorY;
    property MirrorXY: TFileName read FnMirrorXY write SetnMirrorXY;
    property Ray;
    property Mode;
    property Width;
    property Height;
    property Transparent;
  end;

{ TDxRotateSkin }

  TDxRotateSkin = class (TDxCustomSkin)
  private
    FItems: TList;
    FFileName: TFileName;
    FSteps: TDxRotateSteps;
    FFilter: TDxImageFilter;
    function GetItems(Index: Integer): TDxImages;
    procedure SetFileName(const Value: TFileName);
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load; override;
    procedure QuickLoad; override;
    procedure Clear;
    function GetDxImages: TDxImages; override;
    function GetDxImages (Sprite: TDxSprite): TDxImages; override;
    function RotateStep (const RadAngle: Real): Integer;
    property Items [Index: Integer]: TDxImages read GetItems;
  published
    property FileName: TFileName read FFileName write SetFileName;
    property Steps: TDxRotateSteps read FSteps write FSteps default 8;
    property Filter: TDxImageFilter read FFilter write FFilter default 0;
    property Ray;
    property Mode;
    property Width;
    property Height;
    property Transparent;
  end;

{ TDxActionItem Class}

  TDxActionItem = class (TCollectionItem)
  private
    FName: String;
    FAudio: TDxAudio;
    FOptions: TDxActionOptionsSet;
    { Frame Controls }
    FFrameCount: Word;
    FFrameSize: Integer;
    FFirstFrame: Integer;
    FFrameDelay: Cardinal;
    { Eventos }
    FOnKeyUp: TDxKeyEvent;
    FOnKeyDown: TDxKeyEvent;
    FOnTileEvent: TDxTileEvent;
    FOnStart: TDxCustomSpriteEvent;
    FOnColision: TDxColisionEvent;
    FOnExecute: TDxCustomSpriteEvent;
    FOnTerminate: TDxCustomSpriteEvent;
    procedure SetName(const Value: string);
    procedure SetAudio(const Value: TDxAudio);
    procedure SetFrameCount(const Value: Word);
    procedure SetFrameSize(const Value: Integer);
    procedure SetFirstFrame(const Value: Integer);
    procedure SetFrameDelay(const Value: Cardinal);
    { Local Procedures }
    function GetRoot: TComponent;
  protected
    function GetDisplayName: String; override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create (Collection: TCollection); override;
    function GetNamePath: string; override;
    property Root: TComponent read GetRoot;
  published
    property Audio: TDxAudio read FAudio write SetAudio;
    property Options: TDxActionOptionsSet read FOptions write FOptions
        default [amFrameReset, amCountReset];
    property Name: string read FName write SetName;
    { Geraciador Gráfico }
    property FirstFrame: Integer read FFirstFrame write SetFirstFrame default 0;
    property FrameDelay: Cardinal read FFrameDelay write SetFrameDelay default 100;
    property FrameSize : Integer read FFrameSize write SetFrameSize default 1;
    property FrameCount: Word read FFrameCount write SetFrameCount default 0;
    { Controle do Teclado }
    property OnKeyUp: TDxKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnKeyDown: TDxKeyEvent read FOnKeyDown write FOnKeyDown;
    { Eventos }
    property OnStart: TDxCustomSpriteEvent read FOnStart write FOnStart;
    property OnTerminate: TDxCustomSpriteEvent read FOnTerminate write FOnTerminate;
    property OnColision: TDxColisionEvent read FOnColision write FOnColision;
    property OnTileEvent: TDxTileEvent read FOnTileEvent write FOnTileEvent;
    property OnExecute: TDxCustomSpriteEvent read FOnExecute write FOnExecute;
  end;

{ TDxActionList Class }

  TDxActionList = class (TCollection)
  private
    FOwner: TComponent;
    function  GetItem(const Index: Integer): TDxActionItem;
    procedure SetItem(const Index: Integer; Value: TDxActionItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create (AOwner: TComponent);
    property Items[const Index: Integer]: TDxActionItem read GetItem write SetItem; default;
  end;

{ TDxCustomSprite Class }

  TDxCustomSprite = class (TComponent)
  private
    FStage: TDxStage;
    FUserObj: TObject;
    FSharedObj: Boolean;
    { Controle de Posicao do Sprite }
    Fx: Real;
    Fy: Real;
    FOldX: Real;
    FOldY: Real;
    FInitPos: TPoint;
    { Estado do Sprite }
    FVisible: Boolean;
    FEnabled: Boolean;
    FTickCount: Cardinal;
    FFrameEnabled: Boolean;
    { Controle Grafico do Sprite }
    FFrameIndex: Integer;
    FFrameChange: Boolean;
    { Methods }
    function  GetCenter: TPoint;
    procedure SetRx(const Value: Real);
    procedure SetRy(const Value: Real);
    procedure SetCenter(const Value: TPoint);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    { Position Controls }
    function  GetX: Integer; virtual;
    function  GetY: Integer; virtual;
    procedure SetX(const Value: Integer); virtual;
    procedure SetY(const Value: Integer); virtual;
    { Size Controls }
    function GetRect: TRect; virtual;
    function GetWidth: Integer; virtual; abstract;
    function GetHeight: Integer; virtual; abstract;
    { Frame Controls }
    function GetFrameSize: Integer; virtual; abstract;
    function GetFirstFrame: Integer; virtual; abstract;
    function GetFrameDelay: Cardinal; virtual; abstract;
    function GetCurrentFrame: Integer; virtual;
    { Miscelania }
    procedure Execute (const t: Cardinal); virtual; abstract;
    procedure Draw (Canvas: TCanvas; const FrameRc: TRect); virtual; abstract;
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    { Sprite Control }
    procedure NextFrame (const t: Cardinal); virtual;
    procedure FrameReset; virtual;
    procedure Reset; virtual;
    procedure ResetInitPos;
    { Miscelania }
    property Stage: TDxStage read FStage;
    property UserObj: TObject read FUserObj write FUserObj;
    property SharedObj: Boolean read FSharedObj write FSharedObj default True;
    { Grafico }
    property Rect: TRect read GetRect;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property Center: TPoint read GetCenter write SetCenter;
    { Controle do Frame }
    property FrameIndex: Integer read FFrameIndex;
    property FrameChange: Boolean read FFrameChange;
    property CurrentFrame: Integer read GetCurrentFrame;
    property FrameSize: Integer read GetFrameSize;
    property FirstFrame: Integer read GetFirstFrame;
    property FrameDelay: Cardinal read GetFrameDelay;
    { Controle de Posicionamento }
    property OldX: Real read FOldX;
    property OldY: Real read FOldY;
    property Rx: Real read Fx write SetRx;
    property Ry: Real read Fy write SetRy;
    property InitPos: TPoint read FInitPos;
    property X: Integer read GetX write SetX;
    property Y: Integer read GetY write SetY;
  published
    property Visible: Boolean read FVisible write FVisible default True;
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property FrameEnabled: Boolean read FFrameEnabled write FFrameEnabled default True;
  end;

{ TDxSprite Class }

  TDxSprite = class (TDxCustomSprite)
  private
    FJoin: TList;
    FJoinFix: Integer;
    FSkin: TDxCustomSkin;
    { Teclado }
    FKeys: TDxKeySet;
    FUserKeys: TDxKeySet;
    FKeysDown: TDxKeySet;
    { Cinematica }
    FVeloc: TDxVectorEx;
    FAccel: TDxVectorEx;
    FRotation: TDxRotation;
    { Variaveis de Estado }
    FKilled: Boolean;
    FShared: Boolean;
    FMirrorX: Boolean;
    FMirrorY: Boolean;
    FReverse: Boolean;
    FFrameCount: Word;
    FClipSides: TDxSides;
    FColisions: TDxSides;
    { Gerenciador de ações do sprite }
    FAction: TDxActionItem;
    FManager: TDxSpriteManager;
    function GetRay: Real;
    function GetVeloX: Real;
    function GetVeloY: Real;
    function GetAngle: Real;
    function GetFineRect: TRect;
    function GetPosition: TPoint;
    function GetImages: TDxImages;
    function GetRectMode: TDxRectMode;
    procedure SetVeloc(const Value: TDxVectorEx);
    procedure SetAccel(const Value: TDxVectorEx);
    procedure SetSkin(const Value: TDxCustomSkin);
    procedure SetRotation(const Value: TDxRotation);
    procedure SetManager(const Value: TDxSpriteManager);
    { Local Procedures }
    procedure TileEvent (out ProcColision: Boolean;
      TileItem: TDxTileItem; const p: TPoint);
    procedure SetVeloX(const Value: Real);
    procedure SetVeloY(const Value: Real);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetRect: TRect; override;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    function GetCurrentFrame: Integer; override;
    function GetFrameSize: Integer; override;
    function GetFirstFrame: Integer; override;
    function GetFrameDelay: Cardinal; override;
    procedure Execute (const t: Cardinal); override;
    procedure Draw (Canvas: TCanvas; const FrameRc: TRect); override;
  public
    constructor Create (AOwner: TComponent); overload; override;
    constructor Create (AOwner: TComponent; Mng: TDxSpriteManager;
      Skn: TDxCustomSkin; Act: TDxActionItem); reintroduce; overload;
    constructor Create (AOwner: TComponent; Mng: TDxSpriteManager;
      Skn: TDxCustomSkin); reintroduce; overload;
    destructor  Destroy; override;
    { Controle de Junção }
    procedure AddJoin (ASprite: TDxSprite; const AFixed: Integer);
    procedure RemoveJoin (ASprite: TDxSprite);
    { Controle de Frames }
    procedure NextFrame (const t: Cardinal); override;
    { Controle do Sprite }
    procedure Kill;
    procedure Restore;
    procedure Reset; override;
    { Controle do Teclado }
    procedure KeyUp (const Key: TDxKey);
    procedure KeyDown (const Key: TDxKey);
    procedure AddKey (const Key: TDxKey);
    procedure RemoveKey (const Key: TDxKey);
    { Controle dos Actions }
    procedure LoadAction; overload;
    procedure LoadAction (Value: TDxActionItem); overload;
    procedure LoadAction (Value: TDxActionItem; Options: TDxActionOptionsSet); overload;
    procedure LoadAction (Value: Integer); overload;
    procedure LoadAction (Value: Integer; Options: TDxActionOptionsSet); overload;
    procedure LoadAction (Value: String); overload;
    procedure LoadAction (Value: String; Options: TDxActionOptionsSet); overload;
    { Controle de Colisao com Mapa}
    procedure AddColision (const Side: TDxSide);
    procedure RemoveColision (const Side: TDxSide);
    procedure Colision (const Info: TDxColisionData; var ColisionResult: TDxColisionResult);
    { Estado do Sprite }
    property VeloX: Real read GetVeloX write SetVeloX;
    property VeloY: Real read GetVeloY write SetVeloY;
    property Angle: Real read GetAngle;
    property Killed: Boolean read FKilled;
    property Position: TPoint read GetPosition;
    property ClipSides: TDxSides read FClipSides;
    { Controle de Colisao }
    property Ray: Real read GetRay;
    property Colisions: TDxSides read FColisions;
    property RectMode: TDxRectMode read GetRectMode;
    { Estado do Teclado }
    property Keys: TDxKeySet read FKeys;
    property UserKeys: TDxKeySet read FUserKeys write FUserKeys;
    { Miscelania }
    property Images: TDxImages read GetImages;
    property FrameCount: Word read FFrameCount;
    property FineRect: TRect read GetFineRect;
    { Dinamica }
    property Action: TDxActionItem read FAction write FAction;
    property Veloc: TDxVectorEx read FVeloc write SetVeloc;
    property Accel: TDxVectorEx read FAccel write SetAccel;
    property Rotation: TDxRotation read FRotation write SetRotation;
  published
    property Skin: TDxCustomSkin read FSkin write SetSkin;
    property Shared: Boolean read FShared write FShared default False;
    property Manager: TDxSpriteManager read FManager write SetManager;
    property MirrorX: Boolean read FMirrorX write FMirrorX default False;
    property MirrorY: Boolean read FMirrorY write FMirrorY default False;
    property Reverse: Boolean read FReverse write FReverse default False;
  end;

{ TDxColisionItem Class}

  TDxColisionItem = class (TCollectionItem)
  private
    FName: string;
    FMode: TDxSpriteColision;
    FColision: TDxSpriteManager;
    FOnColision: TDxSpriteColisionEvent;
    function GetRoot: TComponent;
    procedure SetName(const Value: string);
    procedure SetColision(const Value: TDxSpriteManager);
  protected
    function GetDisplayName: String; override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    destructor Destroy; override;
    constructor Create (Collection: TCollection); override;
    function GetNamePath: string; override;
    property Root: TComponent read GetRoot;
    procedure SpriteColision (Sender, Sprite: TDxSprite; const Area: TRect);
  published
    property Name: string read FName write SetName;
    property Colision: TDxSpriteManager read FColision write SetColision;
    property Mode: TDxSpriteColision read FMode write FMode default scNone;
    property OnColision: TDxSpriteColisionEvent read FOnColision write FOnColision;
  end;

{ TDxColisionList Class }

  TDxColisionList = class (TCollection)
  private
    FOwner: TComponent;
    function  GetItem(const Index: Integer): TDxColisionItem;
    procedure SetItem(const Index: Integer; Value: TDxColisionItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create (AOwner: TComponent);
    property Items[const Index: Integer]: TDxColisionItem read GetItem write SetItem; default;
  end;

{ TDxClipParams Class }

  TDxClipParams = class (TPersistent)
  private
    FKill: Boolean;
    FMode: TDxClipMode;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
  published
    property Kill: Boolean read FKill write FKill default False;
    property Mode: TDxClipMode read FMode write FMode default cmNone;
  end;

{ TDxSpriteManager Class }

  TDxSpriteManager = class (TComponent)
  private
    FLoaded: Boolean;
    FAutoFreeze: Boolean;
    FActions: TDxActionList;
    { Clip Controls }
    FMarginY: Integer;
    FMarginX: Integer;
    FClipOut: TDxSides;
    FClip: TDxClipParams;
    { Controle de Colisao }
    FOptimize: Boolean;
    FAutoColision: Boolean;
    FColisions: TDxColisionList;
    FMapColision: TDxMapColision;
    { Eventos }
    FOnKeyUp: TDxKeyEvent;
    FOnKeyDown: TDxKeyEvent;
    FOnDraw: TDxDrawingEvent;
    FOnExecute: TDxSpriteEvent;
    FOnTileEvent: TDxTileEvent;
    FOnLoad: TDxCustomSpriteEvent;
    FOnSpriteClip: TDxSpriteEvent;
    FOnColision: TDxColisionEvent;
    FOnAutoFreeze: TDxAutoFreezeEvent;
    FOnAutoColision: TDxAutoColisionEvent;
    procedure SetClip(const Value: TDxClipParams);
    procedure SetColisions(const Value: TDxColisionList);
    { Local Procedures }
    procedure SetActions(const Value: TDxActionList);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Actions: TDxActionList read FActions write SetActions;
    property AutoFreeze: Boolean read FAutoFreeze write FAutoFreeze default False;
    { Clip Controls }
    property Clip: TDxClipParams read FClip write SetClip;
    property ClipOut: TDxSides read FClipOut write FClipOut default [];
    property MarginX: Integer read FMarginX write FMarginX default 0;
    property MarginY: Integer read FMarginY write FMarginY default 0;
    { Controle de Colisao }
    property Optimize: Boolean read FOptimize write FOptimize default True;
    property Colisions: TDxColisionList read FColisions write SetColisions;
    property AutoColision: Boolean read FAutoColision write FAutoColision default False;
    property MapColision: TDxMapColision read FMapColision write FMapColision default mcNone;
    { Methods }
    property OnDraw: TDxDrawingEvent read FOnDraw write FOnDraw;
    property OnKeyUp: TDxKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnKeyDown: TDxKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnLoad: TDxCustomSpriteEvent read FOnLoad write FOnLoad;
    property OnExecute: TDxSpriteEvent read FOnExecute write FOnExecute;
    property OnTileEvent: TDxTileEvent read FOnTileEvent write FOnTileEvent;
    property OnSpriteClip: TDxSpriteEvent read FOnSpriteClip write FOnSpriteClip;
    property OnColision: TDxColisionEvent read FOnColision write FOnColision;
    property OnAutoFreeze: TDxAutoFreezeEvent read FOnAutoFreeze write FOnAutoFreeze;
    property OnAutoColision: TDxAutoColisionEvent read FOnAutoColision write FOnAutoColision;
  end;

{ TDxSpriteItem Class}

  TDxSpriteItem = class (TCollectionItem)
  private
    FName: String;
    Fy: Integer;
    Fx: Integer;
    FMirrorY: Boolean;
    FMirrorX: Boolean;
    FRestore: Boolean;
    FVisible: Boolean;
    FSprite: TDxSprite;
    FSkin: TDxCustomSkin;
    FManager: TDxSpriteManager;
    FOnLoad: TDxSpriteEvent;
    function GetName: String;
    function GetRoot: TComponent;
    procedure SetName(const Value: String);
    procedure SetSprite(const Value: TDxSprite);
    procedure SetManager(const Value: TDxSpriteManager);
    procedure SetSkin(const Value: TDxCustomSkin);
    { Local Procedures }
    procedure Load (ASprite: TDxSprite);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    function GetDisplayName: String; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    function GetNamePath: string; override;
    property Root: TComponent read GetRoot;
  published
    property x: Integer read Fx write Fx;
    property y: Integer read Fy write Fy;
    property Name: String read GetName write SetName;
    property Skin: TDxCustomSkin read FSkin write SetSkin;
    property Sprite: TDxSprite read FSprite write SetSprite;
    property Manager: TDxSpriteManager read FManager write SetManager;
    property Restore: Boolean read FRestore write FRestore default True;
    property Visible: Boolean read FVisible write FVisible default True;
    property MirrorX: Boolean read FMirrorX write FMirrorX default False;
    property MirrorY: Boolean read FMirrorY write FMirrorY default False;
    property OnLoad: TDxSpriteEvent read FOnLoad write FOnLoad;
  end;

{ TDxSpriteList Class }

  TDxSpriteList = class (TCollection)
  private
    FOwner: TComponent;
    function  GetItem(const Index: Integer): TDxSpriteItem;
    procedure SetItem(const Index: Integer; Value: TDxSpriteItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create (AOwner: TComponent);
    function Add: TDxSpriteItem;
    property Items[const Index: Integer]: TDxSpriteItem read GetItem write SetItem;
  end;

{ TDxStageManager Class }

  TDxStageManager = class (TComponent)
  private
    FSprites: TList;
    FManager: TDxSpriteManager;
    function GetCount: Integer;
    function GetSprite(const Index: Integer): TDxSprite;
    function GetMapColision: TDxMapColision;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create (AOwner: TComponent); reintroduce; overload;
    constructor Create (AOwner: TComponent; ASprite: TDxSprite); reintroduce; overload;
    constructor Create (AOwner: TComponent; AManager: TDxSpriteManager); reintroduce; overload;
    destructor Destroy; override;
    { Sprite Controls }
    function  AddSprite (ASprite: TDxSprite): Boolean;
    procedure ClearSprites;
    procedure CheckAutoColision;
    procedure CheckColisions (const Stage: TDxStage);
    procedure RemoveSprite (const Index: Integer); overload;
    procedure RemoveSprite (ASprite: TDxSprite); overload;
    property Sprite [const Index: Integer]: TDxSprite read GetSprite;
    { Miscelania }
    property Count: Integer read GetCount;
    property Manager: TDxSpriteManager read FManager;
    property MapColision: TDxMapColision read GetMapColision;
  end;

{ TDxSplash Class }

  TDxSplash = class (TComponent)
  private
    FDelay: Cardinal;
    FAudio: TDxAudio;
    FImage: TDxImage;
    FBkColor: TColor;
    FFrameDelay: Cardinal;
    procedure SetAudio(const Value: TDxAudio);
    procedure SetImage(const Value: TDxImage);
   protected
     procedure Notification(AComponent: TComponent; Operation: TOperation); override;
   public
     constructor Create (AOwner: TComponent); override;
     procedure Execute;
     procedure MakeFrame (Canvas: TCanvas);
   published
     property Audio: TDxAudio read FAudio write SetAudio;
     property Image: TDxImage read FImage write SetImage;
     property Delay: Cardinal read FDelay write FDelay default 3000;
     property BkColor: TColor read FBkColor write FBkColor default clBlack;
     property FrameDelay: Cardinal read FFrameDelay write FFrameDelay default 200;
   end;

{ TDxStage Class }

  TDxStage = class (TComponent)
  private
    FLoaded: Boolean;
    { Map Controls }
    FMap: TDxMap;
    FMapPt: TPoint;
    FMapBk: TBitmap;
    FMapData: TDxMapData;
    { Audio Controls }
    FAudio: TDxAudio;
    { Stage Controls }
    FSplash: TDxSplash;
    FNextStage: TDxStage;
    FSprites: TDxSpriteList;
    FManager: TList;
    FSpriteCount: Integer;
    FAfterLoad: TNotifyEvent;
    FBeforeLoad: TNotifyEvent;
    FOnLoad: TNotifyEvent;
    FOnUnload: TNotifyEvent;
    FOnExecute: TNotifyEvent;
    FOnDrawScreen: TDxDrawScreenEvent;
    function GetMapRect: TRect;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetMapHeight: Integer;
    function GetMapWidth: Integer;
    function GetManagerCount: Integer;
    function GetSprite(i, j: Integer): TDxSprite;
    function GetTile(x, y: Integer): TDxTileItem;
    function GetStageManager(Index: Integer): TDxStageManager;
    procedure SetMap(const Value: TDxMap);
    procedure SetAudio(const Value: TDxAudio);
    procedure SetNextStage(const Value: TDxStage);
    procedure SetSprites(const Value: TDxSpriteList);
    { Local Procedures }
    procedure KillClear;
    procedure RotateSprites (const Center: TPoint);
    procedure CheckMapColision (ASprite: TDxSprite);
    procedure MakeFrame (const FrameRc: TRect; Canvas: TCanvas;
       Machine: TDxMachine);
    procedure SetSplash(const Value: TDxSplash);
    procedure DrawScreen (AScreen, AFrame: TBitmap);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    { Controle de Carga }
    procedure LoadItem (AItem: TDxSpriteItem);
    procedure Load (AMachine: TDxMachine);
    procedure Unload;
    { Controle do Audio }
    procedure Audio_Stop;
    procedure Audio_Pause;
    { Controle dos Sprites }
    procedure ClearSprites;
    procedure AddSprite (ASprite: TDxSprite);
    { Gerencia do Mapa }
    procedure MapLoad (Machine: TDxMachine);
    { Controle do Manager }
    function GetManager (out StageMng: TDxStageManager; ASprite: TDxSprite): Boolean; overload;
    function GetManager (out StageMng: TDxStageManager; Mng: TDxSpriteManager): Boolean; overload;
    { Properties do Mapa}
    property Width: Integer read GetWidth;   //Tamanho do Mapa em Blocos
    property Height: Integer read GetHeight; //Tamanho do Mapa em Blocos
    property MapRect: TRect read GetMapRect;
    property MapWidth: Integer read GetMapWidth;  //Tamanho do Mapa em Pixels
    property MapHeight: Integer read GetMapHeight;//Tamanho do Mapa em Pixels
    property Tile [x, y: Integer]: TDxTileItem read GetTile;
    { Gerencia de Sprites }
    property SpriteCount: Integer read FSpriteCount;
    property ManagerCount: Integer read GetManagerCount;
    property Sprite [i, j: Integer]: TDxSprite read GetSprite;
    property Manager[Index: Integer]: TDxStageManager read GetStageManager;
  published
    { Properties do Mapa }
    property Map: TDxMap read FMap write SetMap;
    { Config. do Stage }
    property Audio: TDxAudio read FAudio write SetAudio;
    property Splash: TDxSplash read FSplash write SetSplash;
    property NextStage: TDxStage read FNextStage write SetNextStage;
    property Sprites: TDxSpriteList read FSprites write SetSprites;
    property BeforeLoad: TNotifyEvent read FBeforeLoad write FBeforeLoad;
    property AfterLoad: TNotifyEvent read FAfterLoad write FAfterLoad;
    property OnLoad: TNotifyEvent read FOnLoad write FOnLoad;
    property OnUnload: TNotifyEvent read FOnUnload write FOnUnload;
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
    property OnDrawScreen: TDxDrawScreenEvent read FOnDrawScreen write FOnDrawScreen;
  end;

{ ************************************************************ }
{   Gerenciamento da Matriz de Mapa                            }
{ ************************************************************ }

{ Le o Tamanho do Mapa }
function MapDataWidth (const Map: TDxMapData): Integer;
function MapDataHeight (const Map: TDxMapData): Integer;

{ Altera o Tamanho do Mapa }
procedure SetMapSize (var Map: TDxMapData; const Width, Height: Integer);

{ Adiciona um linha ao Mapa - de cima para baixo }
procedure AddMapLine (var Map: TDxMapData; const Value: TDxMapLine); overload;
procedure AddMapLine (var Map: TDxMapData; const Value: array of Byte); overload;

{ Carrega o Mapa de uma String List }
procedure LoadMapData(var Map: TDxMapData; const AData: TStrings);

{ Reposiciona o Sprite caso haja rotação no mapa }
procedure StageRotate (Stage: TDxStage; Sprite: TDxCustomSprite; const Center: TPoint);

{ Cria um Tile de Informação }
procedure GetInfoBmp (Item: TDxTileItem; Bmp: TBitmap; const Fill: Boolean);

implementation
uses Types, DxAI, ImgList;

{$R *.dfm}

function MapDataWidth (const Map: TDxMapData): Integer;
begin
  Result:= Length (Map);
end;

function MapDataHeight (const Map: TDxMapData): Integer;
begin
  if MapDataWidth (Map) > 0 then
    Result:= Length (Map[0])
  else
    Result:= 0;
end;

procedure SetMapSize (var Map: TDxMapData; const Width, Height: Integer);
var
  x: Integer;
begin
  SetLength (Map, Width);
  for x:= 0 to Length (Map) - 1 do
    SetLength (Map[x], Height);
end;

procedure AddMapLine (var Map: TDxMapData; const Value: TDxMapLine); overload;
var
  i, w, h: Integer;
begin
  { Verifica a Largura Maxima do Mapa }
  w:= Length (Value);
  if Length (Map) > w then
    w:= Length (Map);
  { Incrementa a Altura do Mapa }
  if Length (map) > 0 then
    h:= Length (map[0]) + 1
  else
    h:= 1;
  { Altera o tamanho do mapa }
  SetMapSize(Map, w, h);
  { Adiciona nova linha ao mapa }
  for i:= 0 to Length (Value) - 1 do
    map[i, h - 1]:= Value [i];
end;

procedure AddMapLine (var Map: TDxMapData; const Value: array of Byte); overload;
var
  i, w: Integer;
  tmp: TDxMapLine;
begin
  w:= Length (Value);
  SetLength (tmp, w);
  for i:= 0 to w - 1 do
    tmp[i]:= Value [i];
  AddMapLine(Map, tmp);
end;

procedure LoadMapData(var Map: TDxMapData; const AData: TStrings);
var
  s, v: string;
  i, x: Integer;
  L: TDxMapLine;
begin
  SetMapSize (Map, 0, 0);
  for i:= 0 to AData.Count - 1 do
  begin
    x:= 0;
    s:= Trim (AData[i]);
    SetLength (L, Length (s) div 2);
    while s <> '' do
    begin
      v:= '$' + Copy (s, 1, 2);
      Delete (s, 1, 2);
      try
        L[x]:= StrToInt(v);
      except
        L[x]:= 0;
      end;
      inc (x);
    end;
    AddMapLine(Map, L);
  end;
end;

procedure StageRotate (Stage: TDxStage; Sprite: TDxCustomSprite; const Center: TPoint);
var
  vMax, vMin: Integer;
begin
  { Ajuste Horizontal }
  if mrHorz in Stage.Map.Rotate then
  begin
    vMin:= 0;
    vMax:= Stage.MapWidth;
    if (Center.X > vMax) and (Sprite.X > vMax) then
      Sprite.Rx:= Sprite.Rx - Stage.MapWidth
    else if (Center.X < vMin) and (Sprite.X < vMin) then
      Sprite.Rx:= Sprite.Rx + Stage.MapWidth
    else if (Center.X > Stage.MapWidth) and (Sprite.X < vMin) then
      Sprite.Rx:= Sprite.Rx + Stage.MapWidth
    else if (Center.X < vMin) and (Sprite.X > Stage.MapWidth) then
      Sprite.Rx:= Sprite.Rx - Stage.MapWidth;
  end;
  { Ajuste Vertical }
  if mrVert in Stage.Map.Rotate then
  begin
    vMin:= 0;
    vMax:= Stage.MapHeight;
    if (Center.Y > vMax) and (Sprite.Y > vMax) then
      Sprite.Ry:= Sprite.Ry - Stage.MapHeight
    else if (Center.Y < vMin) and (Sprite.Y < vMin) then
      Sprite.Ry:= Sprite.Ry + Stage.MapHeight
    else if (Center.Y > Stage.MapHeight) and (Sprite.Y < vMin) then
      Sprite.Ry:= Sprite.Ry + Stage.MapHeight
    else if (Center.Y < vMin) and (Sprite.Y > Stage.MapHeight) then
      Sprite.Ry:= Sprite.Ry - Stage.MapHeight;
  end;
end;

procedure GetInfoBmp (Item: TDxTileItem; Bmp: TBitmap; const Fill: Boolean);
var
  s: String;
  w, h: Integer;
  tmp: TDxTiles;
begin
  tmp:= Item.Collection.Owner as TDxTiles;
  with Bmp do
  begin
    s:= IntToStr (Item.Index);
    if Fill then
    begin
      Bmp.Width:= tmp.TileWidth;
      Bmp.Height:= tmp.TileHeight;
      Canvas.Brush.Color:= clBtnFace;
      Canvas.FillRect (Canvas.ClipRect);
    end else
    begin
      Canvas.Brush.Color:= clWhite;
      w:= Canvas.TextWidth(s);
      h:= Canvas.TextHeight (s);
      Canvas.FillRect(Rect (0, 0, w + 10, h + 10));
    end;
    Canvas.TextOut (5, 5, s);
  end;
end;

{ TDxPlayer }

constructor TDxPlayer.Create;
begin
  FJoyId:= -1;
  FDelay:= 0;
  FKeyConfig:= DefKeyConfig;
  FJoyConfig:= DefJoyConfig;
  inherited;
end;

procedure TDxPlayer.JoyCapture (const t: Cardinal);
var
  JSet: TDxJoySet;

  function ReadAxis (const CMin, CMax, Value: DWord;
    const ADown, AUp: TDxJoy): UINT;
  var
    tmp, cf: DWORD;
  begin
    if CMax > CMin then
    begin
      cf:= (CMax - CMin) div 3;
      tmp:= (Value - CMin) div cf;
      if tmp < 1 then
        Include (JSet, ADown)
      else if tmp > 1 then
        Include (JSet, AUp);
    end;
    Result:= Value;
  end;

  procedure ReadButton (const Value, BtnCode: DWord; const ABtn: TDxJoy);
  begin
    if Value and BtnCode = BtnCode then
      Include (JSet, ABtn);
  end;

var
  i: TDxKey;
  KJSet: TDxKeySet;
  Joy: TJoyInfo;
  JoyEx: TJoyInfoEx;
begin
  Inc (FDelay, t);
  if Assigned (Sprite) and (FJoyId >= 0) and
    (FDelay > FJoyCaps.wPeriodMin) then
  begin
    FDelay:= 0;
    JSet:= [];
    { Le Controle Padrao }
    if joyGetPos (FJoyId, @Joy) = 0 then
      with Joy do
      begin
        FJoyPos.X:= ReadAxis (FJoyCaps.wXMin, FJoyCaps.wXMax, wXPos, jXDown, jXUp);
        FJoyPos.Y:= ReadAxis (FJoyCaps.wYMin, FJoyCaps.wYMax, wYPos, jYDown, jYUp);
        FJoyPos.Z:= ReadAxis (FJoyCaps.wZMin, FJoyCaps.wZMax, wZPos, jZDown, jZUp);
        ReadButton (wButtons, Joy_Button1, jBtn1);
        ReadButton (wButtons, Joy_Button2, jBtn2);
        ReadButton (wButtons, Joy_Button3, jBtn3);
        ReadButton (wButtons, Joy_Button4, jBtn4);
      end;
    { Le Controle Extendido }
    if ((FJoyCaps.wNumAxes > 3) or (FJoyCaps.wNumButtons > 4)) and
      (joyGetPosEx (FJoyId, @JoyEx) = 0) then
    with JoyEx do
    begin
      if FJoyCaps.wNumAxes > 3 then
      begin
        FJoyPos.R:= ReadAxis (FJoyCaps.wRMin, FJoyCaps.wRMax, dwRPos, jRDown, jRUp);
        FJoyPos.U:= ReadAxis (FJoyCaps.wUMin, FJoyCaps.wUMax, dwUPos, jUDown, jUUp);
        FJoyPos.V:= ReadAxis (FJoyCaps.wVMin, FJoyCaps.wVMax, dwVPos, jVDown, jVUp);
      end;
      if FJoyCaps.wNumButtons > 4 then
      begin
        ReadButton (wButtons, Joy_Button5, jBtn5);
        ReadButton (wButtons, Joy_Button6, jBtn6);
        ReadButton (wButtons, Joy_Button7, jBtn7);
        ReadButton (wButtons, Joy_Button8, jBtn8);
      end;
    end;
    { Processa Comandos }
    KJSet:= JoyDecode (JSet);
    for i:= kLeft to kSelect do
      if (i in KJSet) and not (i in Sprite.Keys) then
        KeyDown (i)
      else if (i in Sprite.Keys) and not (i in KJSet) then
        KeyUp (i)
  end;
end;

function TDxPlayer.JoyDecode(const Joy: TDxJoySet): TDxKeySet;
var
  i: TDxKey;
begin
  Result:= [];
  for i:= kLeft to kSelect do
    if FJoyConfig [i] in Joy then
      Include (Result, i);
end;

function TDxPlayer.KeyDecode(const Key: Word): TDxKey;
var
  i: TDxKey;
begin
  Result:= kNone;
  for i:= kLeft to kSelect do
    if FKeyConfig [i] = Key then
    begin
      Result:= i;
      Break;
    end;
end;

procedure TDxPlayer.KeyDown(const Key: TDxKey);
begin
  if Assigned (FSprite) then
    FSprite.KeyDown (Key);
end;

procedure TDxPlayer.KeyDown(const Key: Word);
begin
  KeyDown(KeyDecode (Key));
end;

procedure TDxPlayer.KeyUp(const Key: TDxKey);
begin
  if Assigned (FSprite) then
    FSprite.KeyUp(Key);
end;

procedure TDxPlayer.KeyUp(const Key: Word);
begin
  KeyUp(KeyDecode (Key));
end;

procedure TDxPlayer.SetJoyId(const Value: Integer);
var
  nDevs: Integer;
begin
  nDevs:= joyGetNumDevs;
  { Altera a Entrada }
  if Value >= nDevs then
    FJoyId := -1
  else
    FJoyId := Value;
  { Calibra o Joystick }
  if FJoyId >= 0 then
  begin
    if joyGetDevCaps (FJoyId, @FJoyCaps, SizeOf (FJoyCaps)) <> 0 then
    begin
      FJoyId:= -1;
      MessageDlg ('Erro ao carregar o Joystick.', mtError, [mbOK], 0);
    end;
  end;
end;

{ TDxThread }

procedure TDxThread.AcFPS;
begin
  Inc (FDelay, FMachine.FInterval);
  Inc (FCount);
  if FDelay >= 1000 then
  begin
    FMachine.FAcDelay:= FDelay div FCount;
    FDelay:= 0;
    FCount:= 0;
  end;
end;

constructor TDxThread.Create(Machine: TDxMachine);
begin
  FMachine:= Machine;
  inherited Create (False);
  FreeOnTerminate:= True;
  //Priority:= tpHigher;
  Priority:= tpNormal;
end;

procedure TDxThread.Execute;
begin
  FCount:= 0;
  FDelay:= 0;
  FTimer:= GetTickCount;
  Synchronize(UpdateState);
  while FState = gsRunning do
    if GetTickCount - FTimer > 10 then
    begin
      { Recarrega o Timer }
      Synchronize(TimerReload);
      { Executa Comandos }
      Synchronize (FMachine.DoExecute);
      { Processa Mensagens }
      Application.ProcessMessages;
      { Apura o FPS }
      Synchronize (AcFPS);
      { Atualiza Estado Interno }
      Synchronize(UpdateState);
    end;
  Synchronize(StopMachine);
end;

procedure TDxThread.StopMachine;
begin
  with FMachine do
  begin
    FState:= gsStopped;
    case FAction of
      saReload: ReloadStage;
      saLoadNextStage: LoadNextStage (False);
      saStartNextStage: LoadNextStage (True);
    end;
    FAction:= saNone;
  end;
end;

procedure TDxThread.TimerReload;
begin
  FMachine.FInterval:= GetTickCount - FTimer;
  FTimer:= GetTickCount;
  if FMachine.FInterval > 20 then
    FMachine.FInterval:= 20;
end;

procedure TDxThread.UpdateState;
begin
  FState:= FMachine.State;
end;

{ TDxMachine }

constructor TDxMachine.Create(AOwner: TComponent);
begin
  inherited;
  { Player Controls }
  FPlayer1:= TDxPlayer.Create;
  FPlayer2:= TDxPlayer.Create;
  { Controle de Execução }
  FFrameSkip:= 0;
  FState:= gsUnload;
  FVideoLoaded:= False;
  FFrameWidth:= 0;
  FFrameHeight:= 0;
  FVideoMode:= vm640x480x16;
  FShowCursor:= False;
  { Cria Back Frames }
  LoadBuffers;
end;

destructor TDxMachine.Destroy;
begin
  { Player Controls }
  FPlayer1.Free;
  FPlayer2.Free;
  { Frame Controls }
  if Assigned (FFrame) then
    FFrame.Free;
  if Assigned (FScreen) then
    FScreen.Free;
  inherited;
end;

procedure TDxMachine.DoExecute;
{
var
  i: Integer;
  c: cardinal;
}
begin
  { Le entradas do Joystick }
  FPlayer1.JoyCapture (FInterval);
  FPlayer2.JoyCapture (FInterval);
  //c:= GetTickCount;
  //for i:= 1 to 1000 do
  begin
    //Check Frame Skip
    if FFrameSkip > 0 then
      FFrameCount:= (FFrameCount + 1) mod (FFrameSkip + 1);
    //Executa Iteração
    Execute;
  end;
  //c:= GetTickCount - c;
  //ShowMessage (IntToStr (c));
  //04.250 para 320x240x8
end;

procedure TDxMachine.DrawFrame;
begin
  FDisplay.DrawFrame;
end;

procedure TDxMachine.Execute;
var
  s: TDxSprite;
  i, j: Integer;
  Mng: TDxStageManager;
  FrameRect, R, tR: TRect;
  c, d, FrameCenter: TPoint;

  function ClipLimit (const Value, Size: Integer; const SpriteOut: Boolean): Integer;
  begin
    if SpriteOut then
      Result:= Value + Size
    else
      Result:= Value;
  end;

  function RectLimit (Sp: TDxCustomSprite; const AOut: TDxSides; const ARect: TRect): TRect;
  begin
    Result.Left  := ClipLimit (ARect.Left,  -sp.Width , bsLeft in AOut);
    Result.Top   := ClipLimit (ARect.Top,   -sp.Height, bsTop  in AOut);
    Result.Right := ClipLimit (ARect.Right,  sp.Width , bsRight in AOut);
    Result.Bottom:= ClipLimit (ARect.Bottom, sp.Height, bsBottom in AOut);
  end;

  function CheckLimit (ASprite: TDxSprite; const Limit: TRect): TDxSides;
  begin
    Result:= [];
    { Verifica Limites em X }
    if ASprite.X <= Limit.Left then
    begin
      ASprite.X:= Limit.Left;
      Result:= Result + [bsLeft];
    end else if ASprite.X + ASprite.Width >= Limit.Right then
    begin
      ASprite.X:= Limit.Right - ASprite.Width;
      Result:= Result + [bsRight];
    end;
    { Verifica Limites em Y }
    if ASprite.Y <= Limit.Top then
    begin
      ASprite.Y:= Limit.Top;
      Result:= Result + [bsTop]
    end else if ASprite.Y + ASprite.Height >= Limit.Bottom then
    begin
      ASprite.Y:= Limit.Bottom - ASprite.Height;
      Result:= Result + [bsBottom];
    end;
  end;

  procedure CheckAutoFreeze (ASprite: TDxSprite; Value: Boolean);
  begin
    if ASprite.Enabled <> Value then
    begin
      ASprite.Enabled:= Value;
      ASprite.FrameEnabled:= Value;
    end;
  end;

begin
  { Calcula centro dos Players }
  c:= PlayersCenter;
  FOldCenter:= c;
  { Reposiciona os Sprites para Mapa Circular }
  if Stage.Map.Rotate <> [] then
  begin
    Stage.RotateSprites (c);
    d:= PlayersCenter;
    if (c.X <> d.X) or (c.Y <> d.Y) then
    begin
      c:= GetPlayersCenter;
      FOldCenter:= c;
    end;
  end;
  { Calcula o OffSet do Mapa }
  FrameRect:= GetFrameRect;
  FrameCenter:= CenterPoint (FrameRect);
  { Calculo do XOffSet }
  if mrHorz in Stage.Map.Rotate then
    FXOffSet:= FrameCenter.X - c.X + FPlayerXOffSet
  else if c.X < FrameCenter.X + FPlayerXOffSet then
    FXOffSet:= 0
  else if c.X > Stage.MapWidth - FrameCenter.X + FPlayerXOffSet then
    FXOffSet:= FFrame.Width - Stage.MapWidth
  else
    FXOffSet:= FrameCenter.X - c.X + FPlayerXOffSet;
  { Calculo do YOffSet }
  if mrVert in Stage.Map.Rotate then
    FYOffSet:= FrameCenter.Y - c.Y + FPlayerYOffSet
  else if c.Y < FrameCenter.Y + FPlayerYOffSet then
    FYOffSet:= 0
  else if c.Y > Stage.MapHeight - FrameCenter.Y + FPlayerYOffSet then
    FYOffSet:= FrameHeight - Stage.MapHeight
  else
    FYOffSet:= FrameCenter.Y - c.Y + FPlayerYOffSet;
  { Calcula Bordas do Mapa }
  OffSetRect(FrameRect, -FXOffSet, -FYOffSet);
  { Executa Iteração do Stage }
  with FStage do
  begin
    if Assigned (FAudio) then
      FAudio.Execute;
    FSpriteCount:= 0;
    for i:= 0 to FManager.Count - 1 do
    begin
      Mng:= FManager [i];
      { Inicializa Auto Freeze }
      with Mng.Manager do
        if AutoFreeze then
        begin
          R:= FrameRect;
          InflateRect (R, MarginX, MarginY);
        end;
      { Executa Iteração dos Sprites }
      for j:= 0 to Mng.Count - 1 do
        with Mng.Sprite [j] do
        begin
          inc (FSpriteCount);
          { Avança o Frame }
          if FrameEnabled then
            NextFrame (FInterval);
          { Inicia Verificação de Colisao }
          FColisions:= [];
          { Verifica Auto Freeze }
          if Manager.AutoFreeze then
          begin
            if Assigned (Manager.OnAutoFreeze) then
              Manager.OnAutoFreeze (Mng.Sprite [j], IntersectRect(tR, R, Rect))
            else
              CheckAutoFreeze (Mng.Sprite [j], IntersectRect(tR, R, Rect));
          end;
          { Executa Comandos do Usuario }
          if Enabled then
            Execute(FInterval);
        end;
      with Mng do
      begin
        { Verifica Auto-Colisao }
        if Manager.AutoColision then
          CheckAutoColision;
        { Verifica Demais Colisões }
        CheckColisions (FStage);
        { Verifica Colisoes com o Mapa }
        if MapColision <> mcNone then
          for j:= 0 to Count - 1 do
            if Sprite[j].Enabled then
              CheckMapColision (Sprite[j]);
        { Valida o Sprite Clip }
        if Manager.Clip.Mode <> cmNone then
          for j:= 0 to Count - 1 do
          begin
            s:= Sprite [j];
            { Inicia o Rect do Clip }
            with Manager do
              case Clip.Mode of
                cmFrame:
                  R:= RectLimit (s, ClipOut, FrameRect);
                cmMap:
                  R:= RectLimit (s, ClipOut, MapRect);
                cmMargin:
                  begin
                    R:= FrameRect;
                    InflateRect(R, s.FManager.FMarginX, s.FManager.FMarginY);
                  end;
              else
                R:= Rect (0, 0, 0, 0);
              end;
            if not IsRectEmpty (R) then
            begin
              { Verifica Limites }
              s.FClipSides:= CheckLimit (s, R);
              { Executa Ações }
              if (s.ClipSides <> []) then
              begin
                if Manager.Clip.Kill then
                  s.Kill;
                if Assigned (Manager.OnSpriteClip) then
                  Manager.OnSpriteClip (s);
              end;
            end;
          end;
      end;
    end;
    { Elimina Sprites }
    KillClear;
    { Executa comandos do usuário }
    if Assigned (FOnExecute) then
      FOnExecute (Stage);
    { Desenha o Frame }
    if FFrameCount = 0 then
    begin
      MakeFrame (FrameRect, FFrame.Canvas, Self);
      DrawScreen (FScreen, FFrame);
      DrawFrame;
    end;
  end;
end;

function TDxMachine.GetAppDir: string;
begin
  Result:= Dises.AppDir;
end;

function TDxMachine.GetFrameRect: TRect;
begin
  Result:= FFrame.Canvas.ClipRect;
end;

function TDxMachine.GetPlayer1: TDxSprite;
begin
  Result:= FPlayer1.Sprite;
end;

function TDxMachine.GetPlayer2: TDxSprite;
begin
  Result:= FPlayer2.Sprite;
end;

function TDxMachine.GetPlayersCenter: TPoint;
var
  c1, c2: TPoint;
begin
  if Assigned (Player1) and Assigned (Player2) then
  begin
    c1:= Player1.GetCenter;
    c2:= Player2.GetCenter;
    Result.X:= (c1.X + c2.X) div 2;
    Result.Y:= (c1.Y + c2.Y) div 2;
    if Abs (c1.X - c2.X) + (Player1.Width + Player2.Width) div 2 > FFrame.Width then
      Result.X:= FOldCenter.X;
    if Abs (c1.Y - c2.Y) + (Player1.Height + Player2.Height) div 2 > FFrame.Height then
      Result.Y:= FOldCenter.Y;
  end else if Assigned (Player1) then
    Result:= Player1.GetCenter
  else if Assigned (Player2) then
    Result:= Player2.GetCenter
  else
    Result:= FOldCenter;
end;

procedure TDxMachine.Load;
var
  w, h, c: Integer;
begin
  if not FVideoLoaded then
  begin
    //Verifica Tamanho da Janela
    case FVideoMode of
      vm800x600, vm800x600x16:
        begin
          w:= 800;
          h:= 600;
        end;
      vm640x480, vm640x480x16:
        begin
          w:= 640;
          h:= 480;
        end;
      vm320x240, vm320x240x16:
        begin
          w:= 320;
          h:= 240;
        end;
    else
      w:= 0;
      h:= 0;
    end;
    //Verifica Numero de Cores
    case FVideoMode of
      vm800x600x16, vm640x480x16, vm320x240x16: c:= 16;
    else
      c:= 0;
    end;
    if FVideoMode <> vmDefault then
    begin
      FVideoLoaded:= ChangeDisplay(w, h, c, @OldMode);
      if not FVideoLoaded then
        raise Exception.Create ('Can''t set Video to ' + VideoInfo[FVideoMode])
    end;
  end;
  MouseShowCursor (FShowCursor);
  xh:= h;
  xw:= w;
  LoadBuffers;
end;

procedure TDxMachine.LoadBuffers;
begin
  { Screen Settings }
  if Assigned (FScreen) then
    FScreen.Free;
  FScreen:= TBitmap.Create;
  FScreen.Width:=  xw; // Forms.Screen.Width;
  FScreen.Height:= xh; //Forms.Screen.Height;
  { Back Frame }
  if Assigned (FFrame) then
    FFrame.Free;
  FFrame:= TBitmap.Create;
  if FFrameWidth > 0 then
    FFrame.Width:= FFrameWidth
  else
    FFrame.Width:= xw; //Forms.Screen.Width;
  if FFrameHeight > 0 then
    FFrame.Height:= FFrameHeight
  else
    FFrame.Height:= xh; //Forms.Screen.Height;
end;

procedure TDxMachine.LoadNextStage (AStart: Boolean);
begin
  if FAction in [saLoadNextStage, saStartNextStage] then
  begin
    Stage.Unload;
    LoadStage (Stage.NextStage);
    if AStart then Start;
  end else
  begin
    if AStart then
      FAction:= saStartNextStage
    else
      FAction:= saLoadNextStage;
    FState:= gsStopping;
  end;
end;

procedure TDxMachine.LoadStage;
begin
  FState:= gsLoading;
  Stage.Load (Self);
  if FState = gsLoading then
    FState:= gsStopped;
end;

procedure TDxMachine.LoadStage(const Value: TDxStage);
begin
  SetStage(Value);
  LoadStage;
end;

procedure TDxMachine.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification (AComponent, Operation);
  if Operation = OpRemove then
  begin
    if AComponent = FPlayer1.Sprite then
      FPlayer1.Sprite:= nil
    else if AComponent = FPlayer2.Sprite then
      FPlayer2.Sprite:= nil
    else if AComponent = FStage then
      FStage:= nil;
  end;
end;

procedure TDxMachine.ReloadStage;
begin
  if FAction = saReload then
  begin
    Stage.Unload;
    LoadStage;
    Start;
 end else
 begin
   FAction:= saReload;
   FState:= gsStopping;
 end;
end;

procedure TDxMachine.SetAppDir(const Value: string);
begin
  Dises.AppDir:= Value;
end;

procedure TDxMachine.SetPlayer1(const Value: TDxSprite);
begin
  if FPlayer1.Sprite <> Value then
  begin
    if Assigned (FPlayer1.Sprite) then
      FPlayer1.Sprite.RemoveFreeNotification (Self);
    FPlayer1.Sprite:= Value;
    if Assigned (Value) then
      Value.FreeNotification(Self);
  end;
end;

procedure TDxMachine.SetPlayer2(const Value: TDxSprite);
begin
  if FPlayer2.Sprite <> Value then
  begin
    if Assigned (FPlayer2.Sprite) then
      FPlayer2.Sprite.RemoveFreeNotification (Self);
    FPlayer2.Sprite:= Value;
    if Assigned (Value) then
      Value.FreeNotification(Self);
  end;
end;

procedure TDxMachine.SetStage(const Value: TDxStage);
begin
  if FStage <> Value then
  begin
    if Assigned (FStage) then
      FStage.RemoveFreeNotification(Self);
    FStage := Value;
    if Assigned (Value) then
      Value.FreeNotification(Self);
  end;
end;

procedure TDxMachine.Start;
begin
  if FState = gsRunning then Exit;
  if Assigned (FOnStart) then
    FOnStart (Self);
  FState:= gsRunning;
  FFrameCount:= 0;
  FThread:= TDxThread.Create (Self);
end;

procedure TDxMachine.Stop;
begin
  if FState <> gsRunning then Exit;
  FState:= gsStopping;
  while FState <> gsStopped do
    Application.ProcessMessages;
  if Assigned (FOnStop) then
    FOnStop (Self);
end;

procedure TDxMachine.Unload;
begin
  Stage.Unload;
  if FVideoLoaded then
    RestoreDisplay (OldMode);
  MouseShowCursor (True); 
end;

{ TDxForm }

procedure TDxForm.DrawFrame;
begin
  Canvas.Lock;
  BitBlt(Canvas.Handle, cX, cY, {Forms.Screen.Width, Forms.Screen.Height,}
    FMachine.xw, FMachine.xh,
    FMachine.FScreen.Canvas.Handle, 0, 0, SRCCOPY);
  Canvas.Unlock;
end;

procedure TDxForm.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Assigned (FMachine) then
    with FMachine do
    begin
      if Assigned (Machine.FOnKeyDown) then
        Machine.FOnKeyDown (Self, Key, Shift);
      if FPlayer1.JoyId < 0 then
        FPlayer1.KeyDown (Key);
      if FPlayer2.JoyId < 0 then
        FPlayer2.KeyDown (Key);
    end;
end;

procedure TDxForm.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if Assigned (FMachine) then
    with FMachine do
    begin
      if Assigned (Machine.FOnKeyUp) then
        Machine.FOnKeyUp (Self, Key, Shift);
      if FPlayer1.JoyId < 0 then
        FPlayer1.KeyUp (Key);
      if FPlayer2.JoyId < 0 then
        FPlayer2.KeyUp (Key);
    end;
end;

procedure TDxForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FMachine then
      FMachine:= nil;
  end;
end;

procedure TDxForm.Paint;
begin
  inherited;
  if Assigned (FMachine) then
  begin
    Recenter (False);
    DrawFrame;
  end;
end;

procedure TDxForm.Recenter (AResize: Boolean);
begin
  if AResize then
  begin
    ClientWidth:= FMachine.xw; // Forms.Screen.Width;
    ClientHeight:= FMachine.xh; //.Screen.Height;
  end;
  with FMachine.FScreen do
  begin
    cX:= (ClientWidth - Width) div 2;
    cY:= (ClientHeight - Height) div 2;
  end;
end;

procedure TDxForm.Resize;
begin
  inherited;
  Repaint;
end;

procedure TDxForm.SetMachine(const Value: TDxMachine);
begin
  if FMachine <> Value then
  begin
    if Assigned (FMachine) then
    begin
      FMachine.RemoveFreeNotification (Self);
      FMachine.Display:= nil;
    end;
    FMachine := Value;
    if Assigned (Value) then
    begin
      Value.FreeNotification (Self);
      FMachine.Display:= Self;
    end;
  end;
end;

{ TDxImage }

constructor TDxImage.Create(AOwner: TComponent);
begin
  inherited;
  FWidth:= 0;
  FHeight:= 0;
  FLoaded:= False;
  FAutoOpen:= True;
end;

destructor TDxImage.Destroy;
begin
  if Assigned (FBitmap) then
    FBitmap.Free;
  inherited;
end;

procedure TDxImage.Load;
var
  tmp: TPicture;
begin
  if not FLoaded and (FFileName <> '') then
  begin
    tmp:= TPicture.Create;
    try
      tmp.LoadFromFile (AppDir + FFileName);
    except
      tmp.Free;
      exit;
    end;
    FBitmap:= TBitmap.Create;
    if (FWidth = 0) and (FHeight = 0) then
    begin
      FBitmap.Width:= tmp.Width;
      FBitmap.Height:= tmp.Height;
    end
    else if FWidth = 0 then
    begin
      FBitmap.Height:= FHeight;
      FBitmap.Width:= Round ((FHeight / tmp.Height) * tmp.Width);
    end
    else if FHeight = 0 then
    begin
      FBitmap.Width:= FWidth;
      FBitmap.Height:= Round ((FWidth / tmp.Width) * tmp.Height);
    end else
    begin
      FBitmap.Width:= FWidth;
      FBitmap.Height:= FHeight;
    end;
    with FBitmap.Canvas do
      StretchDraw(ClipRect, tmp.Graphic);
    tmp.Free;
    FLoaded:= True;
  end;
end;

procedure TDxImage.Loaded;
begin
  inherited;
  if FAutoOpen then Load;
end;

procedure TDxImage.SetFileName(const Value: TFileName);
begin
  FFileName := RelativePath (Value);
end;

procedure TDxImage.Unload;
begin
  if FLoaded then
  begin
    FreeAndNil (FBitmap);
    FLoaded:= False;
  end;
end;

{ TDxImageItem }

constructor TDxImageItem.Create;
begin
  inherited Create;
  FMask:= nil;
  FFrame:= nil;
end;

constructor TDxImageItem.Create(const AWidth, AHeight: Integer);
begin
  Create;
  FFrame:= TBitmap.Create;
  with FFrame do
  begin
    Width:= AWidth;
    Height:= AHeight;
  end;
end;

destructor TDxImageItem.Destroy;
begin
  if Assigned (FMask) then
    FMask.Free;
  if Assigned (FFrame) then
    FFrame.Free;
  inherited;
end;

procedure TDxImageItem.LoadFineRect;
var
  x, y: Integer;
begin
  FRect:= Types.Rect (-1, -1, -1, -1);
  { Carrega FTop  }
  for y:= 0 to FMask.Height - 1 do
  begin
    for x:= 0 to FMask.Width - 1 do
     if GetPixel (FMask.Canvas.Handle, x, y) <> COLORREF (MaskBk) then
     begin
       FRect.Top:= y;
       Break;
     end;
     if FRect.Top > -1 then Break;
  end;
  { Carrega FRight }
  for x:= FMask.Width - 1 downto 0 do
  begin
    for y:= 0 to FMask.Height - 1 do
     if GetPixel (FMask.Canvas.Handle, x, y) <> COLORREF (MaskBk) then
     begin
       FRect.Right:= x;
       Break;
     end;
     if FRect.Right > -1 then Break;
  end;
  { Carrega FBottom }
  for y:= FMask.Height - 1 downto 0 do
  begin
    for x:= FMask.Width - 1 downto 0 do
     if GetPixel (FMask.Canvas.Handle, x, y) <> COLORREF (MaskBk) then
     begin
       FRect.Bottom:= y;
       Break;
     end;
     if FRect.Bottom > -1 then Break;
  end;
  { Carrega FLeft }
  for x:= 0 to FMask.Width - 1 do
  begin
    for y:= FMask.Height - 1 downto 0 do
     if GetPixel (FMask.Canvas.Handle, x, y) <> COLORREF (MaskBk) then
     begin
       FRect.Left:= x;
       Break;
     end;
     if FRect.Left > -1 then Break;
  end;
end;

procedure TDxImageItem.LoadMask (TranspColor: TColor);
begin
  if Assigned (FMask) then
    FMask.Free;
  FMask:= TBitmap.Create;
  FMask.Width:= FFrame.Width;
  FMask.Height:= FFrame.Height;
  FMask.PixelFormat:= pf1Bit;
  if TranspColor <> clNone then
    ImageMask(FFrame, FMask, TranspColor);
end;

procedure TDxImageItem.LoadRect(const Mode: TDxRectMode);
begin
  { Carrega o Rect }
  if Assigned (FMask) and (Mode in [rmFine, rmCircle]) then
    LoadFineRect
  else
    FRect:= Types.Rect (0, 0, FFrame.Width, FFrame.Height);
end;

{ TDxImages }

procedure TDxImages.AddItem(AItem: TDxImageItem);
begin
  FItems.Add(AItem);
end;

procedure TDxImages.Clear;
begin
  while FItems.Count > 0 do
  begin
    Item [0].Free;
    FItems.Delete (0);
  end;
end;

constructor TDxImages.Create (AOwner: TComponent);
begin
  FItems:= TList.Create;
  inherited Create (AOwner);
end;

destructor TDxImages.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

procedure TDxImages.Draw(const Index, x, y: Integer; dest: TCanvas);
begin
  with Item [Index] do
    BitBlt(Dest.Handle, x, y, FFrame.Width, FFrame.Height,
      FFrame.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TDxImages.DrawMasked(const Index, x, y: Integer; dest: TCanvas);
begin
  with Item [Index] do
  begin
    BitBlt(Dest.Handle, x, y, FFrame.Width, FFrame.Height,
      FMask.Canvas.Handle, 0, 0, SRCAND);
    BitBlt(Dest.Handle, x, y, FFrame.Width, FFrame.Height,
      FFrame.Canvas.Handle, 0, 0, SRCPAINT);
  end;
end;

function TDxImages.GetItem(const Index: Integer): TDxImageItem;
begin
  Result:= TDxImageItem (FItems [Index]);
end;

procedure TDxImages.LoadFromFile(AFileName: TFileName; AWidth,
  AHeight: Integer; AMode: TDxRectMode; TranspColor: TColor );
var
  bmp: TBitmap;
  pic: TPicture;
  x, y: Integer;
  tmp: TDxImageItem;
begin
  y:= 0;
  pic:= TPicture.Create;
  pic.LoadFromFile (AppDir + AFileName);
  bmp:= TBitmap.Create;
  bmp.Width:= pic.Width;
  bmp.Height:= pic.Height;
  bmp.Canvas.Draw (0, 0, pic.Graphic);
  pic.Free;
  while y < bmp.Height do
  begin
    x:= 0;
    while x < bmp.Width do
    begin
      tmp:= TDxImageItem.Create (AWidth, AHeight);
      with tmp.FFrame.Canvas do
        BitBlt(Handle, 0, 0, AWidth, AHeight, bmp.Canvas.Handle,
          x, y, SRCCOPY);
      if TranspColor <> clNone then
        tmp.LoadMask (TranspColor);
      tmp.LoadRect(AMode);
      FItems.Add (tmp);
      inc (x, AWidth);
    end;
    inc (y, AHeight);
  end;
  bmp.Free;
end;

procedure TDxImages.LoadMasks(TranspColor: TColor);
var
  i: Integer;
begin
  for i:= 0 to FItems.Count - 1 do
    Item[i].LoadMask (TranspColor);
end;

procedure TDxImages.SetFileName(const Value: TFileName);
begin
  FFileName := RelativePath (Value);
end;

{ TDxTileItem }

procedure TDxTileItem.AssignTo(Dest: TPersistent);
var
  d: TDxTileItem;
begin
  d:= Dest as TDxTileItem;
  d.FName:= FName;
  d.FMode:= FMode;
  d.FBkColor:= FBkColor;
  d.FMargin.Assign(FMargin);
  d.FImageIndex:= FImageIndex;
  d.FTransparent:= FTransparent;
end;

constructor TDxTileItem.Create(Collection: TCollection);
begin
  inherited Create (Collection);
  FName:= 'Tile_' + IntToStr (Index);
  FTileEvent:= False;
  FMode:= tmNone;
  FImageIndex:= -1;
  FBkColor:= clDefault;
  FTransparent:= False;
  FMargin:= TDxRect.Create;
  FTileImg:= nil;
  FTileMsk:= nil;
end;

destructor TDxTileItem.Destroy;
begin
  FMargin.Free;
  Unload;
  inherited;
end;

function TDxTileItem.FineRect(const x, y: Integer): TRect;
begin
  Result:= TileRect(x, y);
  Inc (Result.Left, FMargin.Left);
  Inc (Result.Top, FMargin.Top);
  Dec (Result.Right, FMargin.Right);
  Dec (Result.Bottom, FMargin.Bottom);
end;

function TDxTileItem.FineRect(const p: TPoint): TRect;
begin
  Result:= FineRect(p.X, p.Y);
end;

function TDxTileItem.GetDisplayName: String;
begin
  Result:= FName;
end;

procedure TDxTileItem.LoadImage(const AWidth, AHeight: Integer);
begin
  if not Assigned (FTileImg) then
    FTileImg:= TBitmap.Create;
  with FTileImg do
  begin
    Width:= AWidth;
    Height:= AHeight;
  end;
end;

procedure TDxTileItem.LoadMask;
begin
  if not Assigned (FTileMsk) then
    FTileMsk:= TBitmap.Create;
  with FTileMsk do
  begin
    Width:= FTileImg.Width;
    Height:= FTileImg.Height;
    PixelFormat:= pf1bit;
  end;
  ImageMask(FTileImg, FTileMsk, BkColor);
end;

procedure TDxTileItem.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
end;

procedure TDxTileItem.SetMargin(const Value: TDxRect);
begin
  FMargin.Assign (Value);
end;

procedure TDxTileItem.SetName(const Value: String);
begin
  FName:= Value;
  SetDisplayName (Value);
end;

procedure TDxTileItem.SetTransparent(const Value: Boolean);
begin
  FTransparent := Value;
end;

function TDxTileItem.TileRect(const x, y: Integer): TRect;
var
  root: TDxTiles;
begin
  root:= Collection.Owner as TDxTiles;
  Result:= Bounds (x * root.TileWidth, y *  root.TileHeight,
    root.TileWidth, root.TileHeight);
end;

function TDxTileItem.TileRect(const p: TPoint): TRect;
begin
  Result:= TileRect(p.X , p.Y);
end;

procedure TDxTileItem.Unload;
begin
  if Assigned (FTileImg) then
    FreeAndNil (FTileImg);
  if Assigned (FTileMsk) then
    FreeAndNil (FTileMsk);
end;

{ TDxTileList }

constructor TDxTileList.Create (AOwner: TComponent);
begin
  inherited Create (TDxTileItem);
  FOwner:= AOwner as TDxTiles;
end;

function TDxTileList.GetItem(const Index: Integer): TDxTileItem;
begin
  Result := TDxTileItem (inherited GetItem(Index));
end;

function TDxTileList.GetOwner: TPersistent;
begin
  Result:= FOwner;
end;

procedure TDxTileList.SetItem(const Index: Integer; Value: TDxTileItem);
begin
  inherited SetItem(Index, Value);
end;

{ TDxTiles }

constructor TDxTiles.Create(AOwner: TComponent);
begin
  inherited;
  FTileWidth:= 32;
  FTileHeight:= 32;
  FItems:= TDxTileList.Create (Self);
end;

destructor TDxTiles.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TDxTiles.GetCount: Integer;
begin
  Result:= FItems.Count;
end;

procedure TDxTiles.Load;
begin
  Load (FFilename);
end;

procedure TDxTiles.Load(AFileName: TFileName);
var
  i: Integer;
  bmp: TBitmap;
  pic: TPicture;
  w, x, y: Word;
begin
  if not FLoaded then
  begin
    //Carrega Mapa
    pic:= TPicture.Create;
    pic.LoadFromFile (AppDir + AFileName);
    bmp:= TBitmap.Create;
    bmp.Width:= pic.Width;
    bmp.Height:= pic.Height;
    bmp.Canvas.Draw (0, 0, pic.Graphic);
    pic.Free;
    //Carrega Tiles
    w:= Bmp.Width div TileWidth;
    for i:= 0 to FItems.Count - 1 do
      with FItems [i] do
        if FImageIndex >= 0 then
        begin
          DivMod(FImageIndex, w, y, x);
          LoadImage (FTileWidth, FTileHeight);
          BitBlt(FTileImg.Canvas.Handle, 0, 0, FTileWidth, FTileHeight,
            bmp.Canvas.Handle, x * FTileWidth, y * FTileHeight, SRCCOPY);
          if FTransparent then
            LoadMask;
        end;
    bmp.Free;
    FLoaded:= True;
  end;
end;

procedure TDxTiles.SetFileName(const Value: TFileName);
begin
  FFileName := RelativePath (Value);
end;

procedure TDxTiles.SetItems(const Value: TDxTileList);
begin
  FItems.Assign (Value);
end;

procedure TDxTiles.Unload;
var
  i: Integer;
begin
  for i:= 0 to Count - 1 do
    Items [i].Unload;
  FLoaded:= False;
end;

{ TDxMap }

constructor TDxMap.Create(AOwner: TComponent);
begin
  inherited;
  FScrollX:= 1000;
  FScrollY:= 1000;
  FData:= TStringList.Create;
end;

destructor TDxMap.Destroy;
begin
  FData.Free;
  inherited;
end;

function TDxMap.GetFineRect(const x, y: Integer; ATile: TDxTileItem): TRect;
begin
  Result:= GetTileRect(x, y);
  Result.Left:= Result.Left + ATile.Margin.Left;
  Result.Top:= Result.Top + ATile.Margin.Top;
  Result.Right:= Result.Right - ATile.Margin.Right;
  Result.Bottom:= Result.Bottom - ATile.Margin.Bottom;
end;

function TDxMap.GetTileFromData(AData: TDxMapData;
  x, y: Integer; const ARotate: TDxMapRotateSet): TDxTileItem;
var
  i: Integer;
begin
  { Corrige Eixo X }
  i:= MapDataWidth (AData);
  if mrHorz in ARotate then
  begin
   if x >= i then
     x:= x mod i
   else if x < 0 then
     x:= i + x;
  end else
  begin
    if x >= i then
      x:= i - 1
    else if x < 0 then
      x:= 0;
  end;
  { Corrige Eixo Y }
  i:= MapDataHeight(AData);
  if mrVert in ARotate then
  begin
    if y >= i then
      y:= y mod i
    else if y < 0 then
      y:= i + y;
  end else
  begin
    if y >= i then
      y:= i - 1
    else if y < 0 then
      y:= 0;
  end;
  { Recupera o TileItem }
  i:= AData [x][y];
  if i > Tiles.Items.Count - 1 then
    i:= 0;
  Result:= FTiles.Items [i];
end;

function TDxMap.GetTileRect(const x, y: Integer): TRect;
begin
  Result:= Bounds (x * TileWidth, y * TileHeight,
    TileWidth, TileHeight);
end;

function TDxMap.Map2Tile(const P: TPoint): TPoint;
var
  Rs, Rm: Word;
begin
  if P.X >= 0 then
    Result.X:= P.X div TileWidth
  else
  begin
    DivMod(-P.X, TileWidth, Rs, Rm);
    if Rm > 0 then
      Result.X:= -Rs - 1
    else
      Result.X:= -Rs;
  end;
  if P.Y >= 0 then
    Result.Y:= P.Y div TileHeight
  else
  begin
    DivMod(-P.Y, TileHeight, Rs, Rm);
    if Rm > 0 then
      Result.Y:= -Rs - 1
    else
      Result.Y:= -Rs;
  end;
end;

function TDxMap.Map2Tile(const R: TRect): TRect;
begin
  Result.TopLeft:= Map2Tile(R.TopLeft);
  Result.BottomRight:= Map2Tile (R.BottomRight);
end;

procedure TDxMap.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if FTiles = AComponent then
      FTiles:= nil
    else if FBackground = AComponent then
      FBackground:= nil
  end;
end;

procedure TDxMap.SetTiles(const Value: TDxTiles);
begin
  if FTiles <> Value then
  begin
    if Assigned (FTiles) then
      FTiles.RemoveFreeNotification (Self);
    FTiles:= Value;
    if Assigned (Value) then
      Value.FreeNotification (Self);
  end;
end;

function TDxMap.Tile2Map(const P: TPoint): TPoint;
begin
  Result.X:= p.X * TileWidth;
  Result.Y:= p.Y * TileHeight;
end;

function TDxMap.Tile2Map(const R: TRect): TRect;
begin
  Result.TopLeft:= Tile2Map(R.TopLeft);
  Result.BottomRight:= Tile2Map(R.BottomRight);
end;

procedure TDxMap.SetBackground(const Value: TDxImage);
begin
  if FBackground <> Value then
  begin
    if Assigned (FBackground) then
      FBackground.RemoveFreeNotification (Self);
    FBackground:= Value;
    if Assigned (Value) then
      Value.FreeNotification(Self);
  end;
end;

procedure TDxMap.SetData(const Value: TStrings);
begin
  FData.Assign(Value);
end;

function TDxMap.GetTileHeight: Word;
begin
  Result:= FTiles.TileHeight;
end;

function TDxMap.GetTileWidth: Word;
begin
  Result:= FTiles.TileWidth;
end;

{ TDxCustomSkin }

constructor TDxCustomSkin.Create(AOwner: TComponent);
begin
  inherited;
  FRay:= 0;
  FLoaded:= False;
  FMode:= rmNormal;
  FTransparent:= False;
  FWidth:= 32;
  FHeight:= 32;
end;

procedure TDxCustomSkin.Load;
begin
  FLoaded:= True;
end;

procedure TDxCustomSkin.QuickLoad;
begin
  FLoaded:= True;
end;

procedure TDxCustomSkin.Unload;
begin
  FLoaded:= False;
end;

{ TDxSkin }

constructor TDxSkin.Create(AOwner: TComponent);
begin
  inherited;
  FOptions:= [];
  FImages  := TDxImages.Create (Self);
  FMirrorX := TDxImages.Create (Self);
  FMirrorY := TDxImages.Create (Self);
  FMirrorXY:= TDxImages.Create (Self);
end;

function TDxSkin.GetDxImages(Sprite: TDxSprite): TDxImages;
begin
  with Sprite do
    if MirrorX and MirrorY then
      Result:= Self.FMirrorXY
    else if MirrorX then
      Result:= Self.FMirrorX
    else if MirrorY then
      Result:= Self.FMirrorY
    else
      Result:= Self.FImages;
end;

function TDxSkin.GetDxImages: TDxImages;
begin
  Result:= DxImage;
end;

procedure TDxSkin.Load;

  procedure AddImages (Imgs: TDxImages; const AFileName: TFileName;
    const Mx, My: Boolean);
  var
    i: Integer;
    tmp: TDxImageItem;
  begin
    if AFileName <> '' then
      Imgs.LoadFromFile (AFileName, FWidth, FHeight, FMode, clDefault)
    else
      for i:= 0 to FImages.FItems.Count - 1 do
      begin
        tmp:= TDxImageItem.Create (FWidth, FHeight);
        ImageMirror(FImages.Item [i].FFrame, tmp.FFrame, Mx, My);
        if Transparent then
        begin
          tmp.LoadMask(clNone);
          ImageMirror(FImages.Item [i].FMask, tmp.FMask, Mx, My);
        end;
        tmp.LoadRect (FMode);
        Imgs.AddItem(tmp);
      end;
  end;

begin
  if not FLoaded then
  begin
    inherited;
    //Carrega Imagens Padrao
    FImages.LoadFromFile (FnImages, FWidth, FHeight, FMode, clDefault);
    //Espelhamento em x
    if soMirrorX in FOptions then
      AddImages (FMirrorX, FnMirrorX, True, False);
    //Espelhamento em y
    if soMirrorY in FOptions then
      AddImages (FMirrorY, FnMirrorY, False, True);
    //Espelhamento em X e Y
    if soMirrorXY in FOptions then
      AddImages (FMirrorXY, FnMirrorXY, True, True);
  end;
end;

procedure TDxSkin.QuickLoad;
begin
  //Carrega Imagens Padrao
  if not FLoaded then
  begin
    inherited;
    FImages.LoadFromFile (FnImages, FWidth, FHeight, FMode, clDefault);
  end;
end;

procedure TDxSkin.SetnImages(const Value: TFileName);
begin
  FnImages := RelativePath (Value);
end;

procedure TDxSkin.SetnMirrorX(const Value: TFileName);
begin
  FnMirrorX := RelativePath (Value);
end;

procedure TDxSkin.SetnMirrorXY(const Value: TFileName);
begin
  FnMirrorXY := RelativePath (Value);
end;

procedure TDxSkin.SetnMirrorY(const Value: TFileName);
begin
  FnMirrorY := RelativePath (Value);
end;

procedure TDxSkin.Unload;
begin
  inherited;
  FImages.Clear;
  FMirrorX.Clear;
  FMirrorY.Clear;
  FMirrorXY.Clear;
end;

{ TDxRotateSkin }

procedure TDxRotateSkin.Clear;
var
  i: Integer;
begin
  for i:= 0 to FItems.Count - 1 do
    Items[i].Free;
  FItems.Clear;
end;

constructor TDxRotateSkin.Create(AOwner: TComponent);
begin
  inherited;
  FSteps:= 8;
  FFilter:= 0;
  FItems:= TList.Create;
end;

destructor TDxRotateSkin.Destroy;
begin
  FItems.Clear;
  FItems.Free;
  inherited;
end;

function TDxRotateSkin.GetDxImages(Sprite: TDxSprite): TDxImages;
var
  i: Integer;
begin
  i:= RotateStep (Sprite.Rotation.RadAngle);
  Result:= Items [i];
end;

function TDxRotateSkin.GetDxImages: TDxImages;
begin
  Result:= GetItems (0); 
end;

function TDxRotateSkin.GetItems(Index: Integer): TDxImages;
begin
  Result:= TDxImages (FItems[Index]);
end;

procedure TDxRotateSkin.Load;
var
  i, r: Integer;
  src, tmp: TDxImages;
  img: TDxImageItem;
  Teta, RadStep: Real;
begin
  if FLoaded then Exit;
  inherited;
  //Carrega Imagens Originais
  src:= TDxImages.Create (Self);
  src.LoadFromFile (FFilename, FWidth, FHeight, FMode, clDefault);
  //Inicia a Lista de Rotação
  FItems.Clear;
  Teta:= 0;
  RadStep:= pi2 / FSteps;
  //Adiciona Imagens de Rotacao
  tmp:= TDxImages.Create (Self);
  for r:= 0 to FSteps - 1 do
  begin
    for i:= 0 to src.FItems.Count - 1 do
    begin
      img:= TDxImageItem.Create (FWidth, FHeight);
      ImageRotate (src.Item [i].FFrame, img.FFrame, Teta, clDefault);
      if FFilter > 0 then
        ImageFilter(Img.FFrame, clDefault, FFilter);
      img.LoadMask(clDefault);
      img.LoadRect(FMode);
      tmp.AddItem(img);
    end;
    FItems.Add (tmp);
    Teta:= Teta + RadStep;
  end;
  src.Free;
end;

procedure TDxRotateSkin.QuickLoad;
var
  src: TDxImages;
begin
  //Carga Rápida
  if not FLoaded then
  begin
    inherited;
    FItems.Clear;
    src:= TDxImages.Create (Self);
    src.LoadFromFile (FFilename, FWidth, FHeight, FMode, clDefault);
    FItems.Add (src);
  end;
end;

function TDxRotateSkin.RotateStep(const RadAngle: Real): Integer;
begin
  Result:= Trunc ((FItems.Count - 1) * RadAngle / pi2);
end;

procedure TDxRotateSkin.SetFileName(const Value: TFileName);
begin
  FFileName := RelativePath (Value);
end;

{ TDxActionItem }

procedure TDxActionItem.AssignTo(Dest: TPersistent);
begin
  inherited;
  with TDxActionItem (Dest) do
  begin
    FFrameSize:= Self.FFrameSize;
    FFirstFrame:= Self.FFirstFrame;
    FFrameDelay:= Self.FFrameDelay;
    FFrameCount:= Self.FFrameCount;
    FOptions:= Self.FOptions;
  end;
end;

constructor TDxActionItem.Create(Collection: TCollection);
begin
  FFrameSize:= 1;
  FFirstFrame:= 0;
  FFrameDelay:= 100;
  FFrameCount:= 0;
  FOptions:= [amFrameReset, amCountReset];
  FName:= 'Action' + IntToStr (Collection.Count);
  inherited;
end;

function TDxActionItem.GetDisplayName: String;
begin
  Result:= FName;
end;

function TDxActionItem.GetNamePath: string;
var
  S: string;
begin
  Result := Collection.ClassName;
  if Collection.Owner = nil then Exit;
  S := Collection.Owner.GetNamePath;
  if S = '' then Exit;
  Result := S + '.' + FName;
end;

function TDxActionItem.GetRoot: TComponent;
begin
  Result:= TDxActionList (Collection).FOwner;
end;

procedure TDxActionItem.SetAudio(const Value: TDxAudio);
begin
  if FAudio <> Value then
  begin
    if Assigned (FAudio) then
      FAudio.RemoveFreeNotification (Root);
    FAudio := Value;
    if Assigned (Value) then
      Value.FreeNotification (Root);
  end;
end;

procedure TDxActionItem.SetFirstFrame(const Value: Integer);
begin
  if FFirstFrame <> Value then
    FFirstFrame:= Value;
end;

procedure TDxActionItem.SetFrameCount(const Value: Word);
begin
  FFrameCount := Value;
  Include (FOptions, amCountReset);
end;

procedure TDxActionItem.SetFrameDelay(const Value: Cardinal);
begin
  if FFrameDelay <> Value then
    FFrameDelay := Value;
end;

procedure TDxActionItem.SetFrameSize(const Value: Integer);
var
  tmp: integer;
begin
  { Valida Entrada }
  if Value <= 0 then
    tmp:= 1
  else
    tmp:= Value;
  { Atualiza Campo }
  if FFrameSize <> tmp then
    FFrameSize := tmp;
end;

procedure TDxActionItem.SetName(const Value: string);
begin
  if Value <> '' then
  begin
    FName := Value;
    SetDisplayName (Value);
  end;
end;

{ TDxActionList }

constructor TDxActionList.Create(AOwner: TComponent);
begin
  inherited Create (TDxActionItem);
  FOwner:= AOwner;// as TDxActionList;
end;

function TDxActionList.GetItem(const Index: Integer): TDxActionItem;
begin
  Result := TDxActionItem (inherited GetItem(Index));
end;

function TDxActionList.GetOwner: TPersistent;
begin
   Result:= FOwner;
end;

procedure TDxActionList.SetItem(const Index: Integer;
  Value: TDxActionItem);
begin
  inherited SetItem(Index, Value);
end;

{ TDxCustomSprite }

procedure TDxCustomSprite.AssignTo(Dest: TPersistent);
var
  d: TDxCustomSprite;
begin
  d:= Dest as TDxCustomSprite;
  d.Fx:= Fx;
  d.Fy:= Fy;
  d.FOldX:= FOldX;
  d.FOldY:= FOldY;
end;

constructor TDxCustomSprite.Create(AOwner: TComponent);
begin
  FVisible:= True;
  FEnabled:= True;
  FFrameEnabled:= True;
  FFrameChange:= False;
  FUserObj:= nil;
  inherited;
end;

destructor TDxCustomSprite.Destroy;
begin
  if Assigned (FUserObj) and not FSharedObj then
    FUserObj.Free;
  inherited;
end;

procedure TDxCustomSprite.FrameReset;
begin
  FFrameIndex:= 0;
end;

function TDxCustomSprite.GetCenter: TPoint;
begin
  Result:= CenterPoint (GetRect);
end;

function TDxCustomSprite.GetCurrentFrame: Integer;
begin
  Result:= FirstFrame + FrameIndex;
end;

function TDxCustomSprite.GetRect: TRect;
begin
  Result:= Bounds (X, Y, GetWidth, GetHeight);
end;

function TDxCustomSprite.GetX: Integer;
begin
  Result:= Round (Fx);
end;

function TDxCustomSprite.GetY: Integer;
begin
  Result:= Round (Fy);
end;

procedure TDxCustomSprite.NextFrame (const t: Cardinal);
begin
  inc (FTickCount, t);
  if FTickCount >= FrameDelay then
  begin
    FFrameChange:= True;
    if (Self is TDxSprite) and (TDxSprite(Self).Action.Name = 'acRun') and
      (FrameSize <= 1)then
      FFrameIndex:= (FFrameIndex + 1) mod FrameSize
    else if FrameSize <= 1 then
      FFrameIndex:= 0
    else
      FFrameIndex:= (FFrameIndex + 1) mod FrameSize;


    FTickCount:= 0;
  end else
    FFrameChange:= False;
end;

procedure TDxCustomSprite.Reset;
begin
  //
end;

procedure TDxCustomSprite.ResetInitPos;
begin
  FOldX:= Fx;
  FOldY:= Fy;
  FInitPos:= Point(X, Y);
end;

procedure TDxCustomSprite.SetCenter(const Value: TPoint);
begin
  X:= Value.X - (Width div 2);
  Y:= Value.Y - (Height div 2);
end;

procedure TDxCustomSprite.SetRx(const Value: Real);
begin
  if Fx <> Value then
  begin
    FOldX:= Fx;
    Fx := Value;
  end;
end;

procedure TDxCustomSprite.SetRy(const Value: Real);
begin
  if Fy <> Value then
  begin
    FOldY:= Fy;
    Fy := Value;
  end;
end;

procedure TDxCustomSprite.SetX(const Value: Integer);
begin
  SetRx (Value);
end;

procedure TDxCustomSprite.SetY(const Value: Integer);
begin
  SetRy (Value);
end;

{ TDxSprite }

procedure TDxSprite.AddColision(const Side: TDxSide);
begin
  Include (FColisions, Side);
end;

procedure TDxSprite.AddJoin(ASprite: TDxSprite; const AFixed: Integer);
begin
  if FJoin.IndexOf (ASprite) < 0 then
    FJoin.Add (ASprite);
  ASprite.FJoinFix:= AFixed;
end;

procedure TDxSprite.AddKey(const Key: TDxKey);
begin
  Include (FUserKeys, Key);
end;

constructor TDxSprite.Create(AOwner: TComponent);
begin
  inherited;
  FReverse:= False;
  FMirrorX:= False;
  FMirrorY:= False;
  FJoin:= TList.Create;
  FVeloc:= TDxVectorEx.Create;
  FAccel:= TDxVectorEx.Create;
  FRotation:= TDxRotation.Create;
end;

constructor TDxSprite.Create(AOwner: TComponent; Mng: TDxSpriteManager;
  Skn: TDxCustomSkin; Act: TDxActionItem);
begin
  Create (AOwner);
  Action:= Act;
  SetSkin (Skn);
  SetManager (Mng);
end;

procedure TDxSprite.Colision(const Info: TDxColisionData;
  var ColisionResult: TDxColisionResult);
begin
  AddColision (Info.Side);
  case Manager.MapColision of
    mcDefault:
      SetSpritePos (Self, Info.Rect, Info.Area, Info.Side, True);
    mcKill:
      begin
        Kill;
        ColisionResult:= crSkip;
      end;
  end;
  if Assigned (FAction.FOnColision) then
    FAction.FOnColision (ColisionResult, Self, Info)
  else if Assigned (Manager.OnColision) then
    Manager.OnColision (ColisionResult, Self, Info);
end;

constructor TDxSprite.Create(AOwner: TComponent; Mng: TDxSpriteManager;
  Skn: TDxCustomSkin);
begin
  Create (AOwner, Mng, Skn, Mng.Actions [0]);
end;

destructor TDxSprite.Destroy;
begin
  FJoin.Free;
  FVeloc.Free;
  FAccel.Free;
  FRotation.Free;
  inherited;
end;

procedure TDxSprite.Draw(Canvas: TCanvas; const FrameRc: TRect);
begin
  if Assigned (FManager.FOnDraw) then
    FManager.FOnDraw (Self, Canvas, FrameRc)
  else if Skin.Transparent then
    Images.DrawMasked (CurrentFrame, X - FrameRc.Left, Y - FrameRc.Top, Canvas)
  else
    Images.Draw (CurrentFrame, X - FrameRc.Left, Y - FrameRc.Top, Canvas)
end;

procedure TDxSprite.Execute(const t: Cardinal);
var
  i: Integer;
  vX, vY: Real;
begin
  { Processamento }
  Veloc.Execute(t);
  Accel.Execute (t);
  Rotation.Execute (t);
  { deslocamento em X }
  if Accel.ValueX <> 0 then
    Veloc.ValueX:= Velocidade (VeloX, Accel.ValueX, t);
  if VeloX <> 0 then
    Rx:= MU (Fx, VeloX, t);
  { deslocamento em Y }
  if Accel.ValueY <> 0 then
    Veloc.ValueY:= Velocidade (VeloY, Accel.ValueY, t);
  if VeloY <> 0 then
    Ry:= MU (Fy, VeloY, t);
  //Executa Controle de Junção
  if FJoin.Count > 0 then
  begin
    vX:= Rx - OldX;
    vY:= Ry - OldY;
    i:= 0;
    while i < FJoin.Count do
      with TDxSprite (FJoin[i]) do
      begin
        Rx:= Rx + Vx;
        Ry:= Ry + Vy;
        if FJoinFix > 0 then
          Dec (FJoinFix);
        if FJoinFix = 0 then
          Self.FJoin.Delete (i)
        else
          Inc (i);
      end;
  end;
  { Executa comandos do usuario }
  if Assigned (FAction.FOnExecute) then
    FAction.FOnExecute (Self)
  else if Assigned (FManager.FOnExecute) then
    FManager.FOnExecute(Self);
end;

function TDxSprite.GetAngle: Real;
begin
  Result:= FRotation.Angle;
end;

function TDxSprite.GetCurrentFrame: Integer;
begin
  if FReverse then
    Result:= FirstFrame + FrameSize - FFrameIndex - 1
  else
    Result:= inherited GetCurrentFrame;
end;

function TDxSprite.GetFineRect: TRect;
begin
  Result:= Images.Item[GetCurrentFrame].Rect;
end;

function TDxSprite.GetFirstFrame: Integer;
begin
  Result:= FAction.FirstFrame;
end;

function TDxSprite.GetFrameDelay: Cardinal;
begin
  Result:= FAction.FrameDelay;
end;

function TDxSprite.GetFrameSize: Integer;
begin
  Result:= FAction.FrameSize;
end;

function TDxSprite.GetHeight: Integer;
begin
  Result:= Skin.Height;
end;

function TDxSprite.GetImages: TDxImages;
begin
  Result:= FSkin.GetDxImages(Self);
end;

function TDxSprite.GetPosition: TPoint;
begin
  Result.X:= X;
  Result.Y:= Y;
end;

function TDxSprite.GetRay: Real;
begin
  Result:= FSkin.FRay;
end;

function TDxSprite.GetRect: TRect;
begin
  if RectMode = rmNormal then
    Result:= inherited GetRect
  else begin
    Result:= Images.Item [CurrentFrame].Rect;
    OffsetRect(Result, X, Y);
  end;
end;

function TDxSprite.GetRectMode: TDxRectMode;
begin
  Result:= FSkin.FMode;
end;

function TDxSprite.GetVeloX: Real;
begin
  Result:= FVeloc.ValueX;
end;

function TDxSprite.GetVeloY: Real;
begin
  Result:= FVeloc.ValueY;
end;

function TDxSprite.GetWidth: Integer;
begin
  Result:= Skin.Width;
end;

procedure TDxSprite.KeyDown(const Key: TDxKey);
var
  kHold: TDxKeySet;
begin
  Include (FKeysDown, Key);
  if not (Key in FKeys) then
  begin
    if Assigned (FAction.FOnKeyDown) then
      FAction.FOnKeyDown (Self, Key, FKeys)
    else if Assigned (FManager.FOnKeyDown) then
      FManager.FOnKeyDown (Self, Key, FKeys);
  end;
  kHold:= [];
  case Key of
    kUp: kHold:= [kDown];
    kDown: kHold:= [kUp];
    kLeft: kHold:= [kRight];
    kRight: kHold:= [kLeft];
    kBtnR: kHold:= [kBtnL];
    kBtnL: kHold:= [kBtnR];
  end;
  Include (FKeys, Key);
  FKeys:= FKeys - kHold;
end;

procedure TDxSprite.KeyUp(const Key: TDxKey);
begin
  Exclude (FKeys, Key);
  if Assigned (FAction.FOnKeyUp) then
    FAction.FOnKeyUp (Self, Key, FKeys)
  else if Assigned (FManager.FOnKeyUp) then
    FManager.FOnKeyUp (Self, Key, FKeys);
end;

procedure TDxSprite.Kill;
begin
  Enabled:= False;
  FKilled:= True;
end;

procedure TDxSprite.LoadAction(Value: TDxActionItem; Options: TDxActionOptionsSet);
begin
  FTickCount:= 0;
  if amFrameReset in Options then
    FrameReset;
  if amCountReset in Options then
    FFrameCount:= 0;
  FReverse := amReverse in Options;
  with Value do
  begin
    if Assigned (OnStart) then
      OnStart (Self);
    if Assigned (Audio) then
      Audio.Execute;
  end;
  FAction:= Value;
end;

procedure TDxSprite.LoadAction(Value: TDxActionItem);
begin
  LoadAction (Value, Value.Options);
end;

procedure TDxSprite.LoadAction;
begin
  LoadAction(FManager.Actions [0]);
end;

procedure TDxSprite.LoadAction(Value: Integer;
  Options: TDxActionOptionsSet);
begin
  LoadAction (Manager.Actions [Value], Options);
end;

procedure TDxSprite.LoadAction(Value: Integer);
var
  act: TDxActionItem;
begin
  act:= Manager.Actions [Value];
  LoadAction (act, act.Options);
end;

procedure TDxSprite.LoadAction(Value: String;
  Options: TDxActionOptionsSet);
var
  i: Integer;
  act: TDxActionItem;
begin
  act:= nil;
  for i:= 0 to Manager.Actions.Count - 1 do
    if Manager.Actions [i].Name = Value then
    begin
      act:= Manager.Actions [i];
      Break;
    end;
  if Assigned (act) then
    LoadAction(act, Options)
  else
    raise Exception.Create(Manager.Name + #13 + 'Não foi possível carregar a ação ' + Value)
end;

procedure TDxSprite.LoadAction(Value: String);
var
  i: Integer;
  act: TDxActionItem;
begin
  act:= nil;
  for i:= 0 to Manager.Actions.Count - 1 do
    if Manager.Actions [i].Name = Value then
    begin
      act:= Manager.Actions [i];
      Break;
    end;
  if Assigned (act) then
    LoadAction(act, act.Options)
  else
    raise Exception.Create(Manager.Name + #13 + 'Não foi possível carregar a ação ' + Value)
end;

procedure TDxSprite.NextFrame (const t: Cardinal);
begin
  inherited;
  if FFrameChange and (FAction.FrameCount > 0) then
  begin
    Inc (FFrameCount);
    if FFrameCount >= FAction.FrameCount - 1 then
    begin
     if Assigned (FAction.OnTerminate) then
       FAction.OnTerminate (Self);
      FFrameCount:= 0;
    end;
  end;
end;

procedure TDxSprite.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification (AComponent, Operation);
  if Operation = OpRemove then
  begin
    if AComponent = FManager then
      FManager:= nil
    else if AComponent = FSkin then
      FSkin:= nil;
  end;
end;

procedure TDxSprite.RemoveColision(const Side: TDxSide);
begin
  Exclude (FColisions, Side);
end;

procedure TDxSprite.RemoveJoin(ASprite: TDxSprite);
begin
  FJoin.Remove (ASprite);
end;

procedure TDxSprite.RemoveKey(const Key: TDxKey);
begin
  Exclude (FUserKeys, Key);
end;

procedure TDxSprite.Reset;
begin
  inherited;
  FKeys:= [];
  FUserKeys:= [];
  FColisions:= [];
  FVeloc.Reset;
  FAccel.Reset;
  FRotation.Reset;
end;

procedure TDxSprite.Restore;
begin
  FKilled:= False;
end;

procedure TDxSprite.SetAccel(const Value: TDxVectorEx);
begin
  FAccel.Assign (Value);
end;

procedure TDxSprite.SetManager(const Value: TDxSpriteManager);
begin
  if FManager <> Value then
  begin
    if Assigned (FManager) then
      FManager.RemoveFreeNotification (Self);
    FManager:= Value;
    if Assigned (Value) then
      Value.FreeNotification(Self);
  end;
end;

procedure TDxSprite.SetRotation(const Value: TDxRotation);
begin
  FRotation.Assign (Value);
end;

procedure TDxSprite.SetSkin(const Value: TDxCustomSkin);
begin
  if FSkin <> Value then
  begin
    if Assigned (FSkin) then
      FSkin.RemoveFreeNotification (Self);
    FSkin := Value;
    if Assigned (Value) then
      Value.FreeNotification (Self);
  end;
end;

procedure TDxSprite.SetVeloc(const Value: TDxVectorEx);
begin
  FVeloc.Assign(Value);
end;

procedure TDxSprite.SetVeloX(const Value: Real);
begin
  Veloc.ValueX:= Value;
end;

procedure TDxSprite.SetVeloY(const Value: Real);
begin
  Veloc.ValueY:= Value;
end;

procedure TDxSprite.TileEvent(out ProcColision: Boolean;
  TileItem: TDxTileItem; const p: TPoint);
begin
  if Assigned (FAction.FOnTileEvent) then
    FAction.FOnTileEvent (ProcColision, Self, TileItem, p)
  else if Assigned (Manager.FOnTileEvent) then
    Manager.FOnTileEvent(ProcColision, Self, TileItem, p)
  else if Assigned (TileItem.FOnTileEvent) then
    TileItem.FOnTileEvent(ProcColision, Self, TileItem, p);
end;

{ TDxColisionItem }

procedure TDxColisionItem.AssignTo(Dest: TPersistent);
var
  d: TDxColisionItem;
begin
  d:= Dest as TDxColisionItem;
  d.Colision:= FColision;
  d.FOnColision:= FOnColision;
end;

constructor TDxColisionItem.Create(Collection: TCollection);
begin
  inherited;
  FName:= 'Colision' + IntToStr (Collection.Count);
end;

destructor TDxColisionItem.Destroy;
begin
  if Assigned (FColision) then
    FColision.RemoveFreeNotification (Root);
  inherited;
end;

function TDxColisionItem.GetDisplayName: String;
begin
  Result:= FName;
end;

function TDxColisionItem.GetNamePath: string;
var
  S: string;
begin
  Result := Collection.ClassName;
  if Collection.Owner = nil then Exit;
  S := Collection.Owner.GetNamePath;
  if S = '' then Exit;
  Result := S + '.' + FName;
end;

function TDxColisionItem.GetRoot: TComponent;
begin
  Result:= TDxColisionList (Collection).FOwner;
end;

procedure TDxColisionItem.SetColision(const Value: TDxSpriteManager);
begin
  if Value <> FColision then
  begin
    if Assigned (FColision) then
      FColision.RemoveFreeNotification(Root);
    FColision := Value;
    if Assigned (Value) then
      Value.FreeNotification(Root);
  end;
end;

procedure TDxColisionItem.SetName(const Value: string);
begin
  if Value <> '' then
  begin
    FName := Value;
    SetDisplayName (Value);
  end;
end;

procedure TDxColisionItem.SpriteColision(Sender, Sprite: TDxSprite;
  const Area: TRect);
begin
  case FMode of
    scKillSender: Sender.Kill;
    scKillSprite: Sprite.Kill;
    scKillBoth:
      begin
        Sender.Kill;
        Sprite.Kill;
      end;
    scFixSender:
      SetSpritePos (Sprite, Sender, Area, True);
    scFixSprite:
      SetSpritePos (Sender, Sprite, Area, True);
  end;
  if Assigned (FOnColision) then
    FOnColision (Sender, Sprite, Area);
end;

{ TDxColisionList }

constructor TDxColisionList.Create(AOwner: TComponent);
begin
  inherited Create (TDxColisionItem);
  FOwner:= AOwner;
end;

function TDxColisionList.GetItem(const Index: Integer): TDxColisionItem;
begin
  Result := TDxColisionItem (inherited GetItem(Index));
end;

function TDxColisionList.GetOwner: TPersistent;
begin
  Result:= FOwner;
end;

procedure TDxColisionList.SetItem(const Index: Integer; Value: TDxColisionItem);
begin
  inherited SetItem(Index, Value);
end;

{ TDxClipParams }

procedure TDxClipParams.AssignTo(Dest: TPersistent);
var
  d: TDxClipParams;
begin
  d:= Dest as TDxClipParams;
  d.FKill:= FKill;
  d.FMode:= FMode;
end;

constructor TDxClipParams.Create;
begin
  inherited Create;
  FKill:= False;
  FMode:= cmNone;
end;

{ TDxSpriteManager }

constructor TDxSpriteManager.Create(AOwner: TComponent);
begin
  FMarginX:= 0;
  FMarginY:= 0;
  FLoaded:= False;
  FOptimize:= True;
  FActions:= TDxActionList.Create (Self);
  { Controle de Colisao }
  FMapColision:= mcNone;
  FAutoColision:= False;
  FColisions:= TDxColisionList.Create (Self);
  { Clip Controls }
  FClip:= TDxClipParams.Create;
  FClipOut:= [];
  inherited;
end;

destructor TDxSpriteManager.Destroy;
begin
  inherited;
  FClip.Free;
  FActions.Free;
  FColisions.Free;
end;

procedure TDxSpriteManager.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  i: Integer;
begin
  inherited;
  if Operation = OpRemove then
  begin
    if AComponent is TDxAudio then
    begin
      for i:= 0 to Actions.Count - 1 do
        with Actions[i] do
          if FAudio = AComponent then
            FAudio:= nil
    end
    else if AComponent is TDxSpriteManager then
    begin
      for i:= 0 to Colisions.Count - 1 do
        with Colisions[i] do
          if FColision = AComponent then
            FColision:= nil;
    end;
  end;
end;

procedure TDxSpriteManager.SetActions(const Value: TDxActionList);
begin
  FActions.Assign (Value);
end;

procedure TDxSpriteManager.SetClip(const Value: TDxClipParams);
begin
  FClip.Assign (Value);
end;

procedure TDxSpriteManager.SetColisions(const Value: TDxColisionList);
begin
  FColisions.Assign (Value);
end;

{ TDxSpriteItem }

procedure TDxSpriteItem.AssignTo(Dest: TPersistent);
var
  d: TDxSpriteItem;
begin
  d:= Dest as TDxSpriteItem;
  d.FName:= FName;
  d.Fy:= Fy;
  d.Fx:= Fx;
  d.FRestore:= FRestore;
  d.FMirrorX:= FMirrorX;
  d.FMirrorY:= FMirrorY;
  d.FVisible:= FVisible;
  d.Skin:= Skin;
  d.Sprite:= Sprite;
  d.Manager:= Manager;
  d.FOnLoad:= FOnLoad;
end;

constructor TDxSpriteItem.Create(Collection: TCollection);
begin
  inherited Create (Collection);
  FName:= '';
  FRestore:= True;
  FVisible:= True;
end;

destructor TDxSpriteItem.Destroy;
begin
  if Assigned (FSkin) then
    FSkin.RemoveFreeNotification(Root);
  if Assigned (FSprite) then
    FSprite.RemoveFreeNotification(Root);
  if Assigned (FManager) then
    FManager.RemoveFreeNotification(Root);
  inherited;
end;

function TDxSpriteItem.GetDisplayName: String;
begin
  Result:= GetName;
end;

function TDxSpriteItem.GetName: String;
begin
  Result:= FName;
  if Result = '' then
    Result:= 'Sprite_' + IntToStr (Index);
end;

function TDxSpriteItem.GetNamePath: string;
var
  S: string;
begin
  Result := Collection.ClassName;
  if Collection.Owner = nil then Exit;
  S := Collection.Owner.GetNamePath;
  if S = '' then Exit;
  Result := S + '.' + FName;
end;

function TDxSpriteItem.GetRoot: TComponent;
begin
  Result:= TDxSpriteList (Collection).FOwner;
end;

procedure TDxSpriteItem.Load(ASprite: TDxSprite);
begin
  if Assigned (FOnLoad) then
    FOnLoad (ASprite)
  else
    with ASprite.Manager do
      if Assigned (OnLoad) then
        OnLoad (ASprite);
end;

procedure TDxSpriteItem.SetManager(const Value: TDxSpriteManager);
begin
  if FManager <> Value then
  begin
    if Assigned (FManager) then
      FManager.RemoveFreeNotification (Root);
    FManager := Value;
    if Assigned (Value) then
      Value.FreeNotification(Root);
  end;
end;

procedure TDxSpriteItem.SetName(const Value: String);
begin
  if FName <> Value then
    FName:= Value;
end;

procedure TDxSpriteItem.SetSkin(const Value: TDxCustomSkin);
begin
  if FSkin <> Value then
  begin
    if Assigned (FSkin) then
      FSkin.RemoveFreeNotification (Root);
    FSkin := Value;
    if Assigned (Value) then
      Value.FreeNotification(Root);
  end;
end;

procedure TDxSpriteItem.SetSprite(const Value: TDxSprite);
begin
  if FSprite <> Value then
  begin
    if Assigned (FSprite) then
      FSprite.RemoveFreeNotification (Root);
    FSprite := Value;
    if Assigned (Value) then
      Value.FreeNotification(Root);
  end;
end;

{ TDxSpriteList }

function TDxSpriteList.Add: TDxSpriteItem;
begin
  Result:= TDxSpriteItem (inherited Add);
end;

constructor TDxSpriteList.Create(AOwner: TComponent);
begin
  FOwner:= AOwner;
  inherited Create (TDxSpriteItem);
end;

function TDxSpriteList.GetItem(const Index: Integer): TDxSpriteItem;
begin
  Result := TDxSpriteItem (inherited GetItem(Index));
end;

function TDxSpriteList.GetOwner: TPersistent;
begin
  Result:= FOwner;
end;

procedure TDxSpriteList.SetItem(const Index: Integer; Value: TDxSpriteItem);
begin
  inherited SetItem(Index, Value);
end;

{ TDxStageManager }

function TDxStageManager.AddSprite(ASprite: TDxSprite): Boolean;
begin
  Result:= (ASprite.Manager = FManager) and
           (FSprites.IndexOf(ASprite) < 0);
  if Result then
  begin
    FSprites.Add(ASprite);
    ASprite.FreeNotification(Self);
  end;
end;

procedure TDxStageManager.CheckAutoColision;
var
  R: TRect;
  i, j: integer;
  s1, s2: TDxSprite;
begin
  for i:= 0 to Count - 2  do
  begin
    s1:= Sprite[i];
    if s1.Enabled then
      for j:= i + 1 to Count - 1 do
      begin
        s2:= Sprite [j];
        if SpriteColision(R, s1, s2) and
          Assigned (Manager.OnAutoColision) then
          Manager.OnAutoColision (s1, s2, R);
      end;
  end;
end;

procedure TDxStageManager.CheckColisions(const Stage: TDxStage);
var
  R: TRect;
  i, j, k: Integer;
  s1, s2: TDxSprite;
  ColMng: TDxStageManager;
begin
  with Manager  do
    for k:= 0 to Colisions.Count - 1 do
    begin
      if Stage.GetManager (ColMng, Colisions [k].Colision) then
        for i:= 0 to Count - 1 do
        begin
          s1:= Sprite[i];
          if s1.Enabled then
            for j:= 0 to ColMng.Count - 1 do
            begin
              s2:= ColMng.Sprite [j];
              if SpriteColision(R, s1, s2) then
                Colisions[k].SpriteColision (s1, s2, R);
            end;
        end;
    end;
end;

procedure TDxStageManager.ClearSprites;
begin
  while FSprites.Count > 0 do
    RemoveSprite(0);
end;

constructor TDxStageManager.Create(AOwner: TComponent);
begin
  FSprites:= TList.Create;
  inherited Create (AOwner);
end;

constructor TDxStageManager.Create(AOwner: TComponent; ASprite: TDxSprite);
begin
  Create (AOwner, ASprite.Manager);
  AddSprite (ASprite);
end;

constructor TDxStageManager.Create(AOwner: TComponent;
  AManager: TDxSpriteManager);
begin
  Create (AOwner);
  FManager:= AManager;
end;

destructor TDxStageManager.Destroy;
begin
  FSprites.Free;
  inherited;
end;

function TDxStageManager.GetCount: Integer;
begin
  Result:= FSprites.Count;
end;

function TDxStageManager.GetMapColision: TDxMapColision;
begin
  Result:= Manager.MapColision;
end;

function TDxStageManager.GetSprite(const Index: Integer): TDxSprite;
begin
  Result:=  TDxSprite (FSprites [Index]);
end;

procedure TDxStageManager.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent is TDxSprite then
      FSprites.Remove (AComponent);
  end;
end;

procedure TDxStageManager.RemoveSprite(ASprite: TDxSprite);
begin
  FSprites.Remove (ASprite);
  if not ASprite.Shared then
    ASprite.Free
end;

procedure TDxStageManager.RemoveSprite(const Index: Integer);
var
  ASprite: TDxSprite;
begin
  ASprite:= Sprite [Index];
  FSprites.Delete (Index);
  if not ASprite.Shared then
    ASprite.Free;
end;

{ TDxSplash }

constructor TDxSplash.Create(AOwner: TComponent);
begin
  inherited;
  FDelay:= 3000;
  FFrameDelay:= 200;
  FBkColor:= clBlack;
end;

procedure TDxSplash.Execute;
begin
  if Assigned (FAudio) then
    FAudio.Execute;
end;

procedure TDxSplash.MakeFrame(Canvas: TCanvas);
var
  Rc: TRect;
  x, y: Integer;
begin
  Canvas.Lock;
  try
    Canvas.Brush.Color:= BkColor;
    Canvas.FillRect (Canvas.ClipRect);
    Rc:= Canvas.ClipRect;
    x:= (Rc.Right - Rc.Left - Image.Bitmap.Width) div 2;
    y:= (Rc.Bottom - Rc.Top - Image.Bitmap.Height) div 2;
    Canvas.Draw(x, y, Image.Bitmap)
  finally
    Canvas.Unlock;
  end;
end;

procedure TDxSplash.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FAudio then
      FAudio:= nil
    else if AComponent = FImage then
      FImage:= nil;
  end;
end;

procedure TDxSplash.SetAudio(const Value: TDxAudio);
begin
  if FAudio <> Value then
  begin
    if Assigned (FAudio) then
      FAudio.RemoveFreeNotification(Self);
    FAudio:= Value;
    if Assigned (Value) then
      Value.FreeNotification(Self);
  end;
end;

procedure TDxSplash.SetImage(const Value: TDxImage);
begin
  if FImage <> Value then
  begin
    if Assigned (FImage) then
      FImage.RemoveFreeNotification(Self);
    FImage:= Value;
    if Assigned (Value) then
      Value.FreeNotification(Self);
  end;
end;

{ TDxStage }

procedure TDxStage.AddSprite(ASprite: TDxSprite);
var
  Mng: TDxStageManager;
begin
  ASprite.FStage:= Self;
  if GetManager(Mng, ASprite.Manager) then
    Mng.AddSprite(ASprite)
  else
  begin
    Mng:= TDxStageManager.Create (Self, ASprite);
    FManager.Add (Mng);
  end;
  //Carrega o Sprite
  if not Assigned (ASprite.Action) then
    ASprite.LoadAction;
end;

procedure TDxStage.Audio_Pause;
begin
  if Assigned (Audio) then
    Audio.Pause;
end;

procedure TDxStage.Audio_Stop;
begin
  if Assigned (Audio) then
    Audio.Stop;
end;

procedure TDxStage.CheckMapColision(ASprite: TDxSprite);
var
  Rcs: TDxSideRect;
  Rc, FineRc: TRect;
  RealRc: TRealRect;
  ColisionResult: TDxColisionResult;

  { Verifica colisao com mapa entre os Pontos x1, y1 e x2, y2 }

  function RectColision (out ColRect: TRect; const x1, y1, x2, y2: Integer): Boolean;
  var
    mR: TRect;
    x, y: Integer;
    m1, m2: TPoint;
    item: TDxTileItem;
    ProcColision: Boolean;
  begin
    Result:= False;
    ColRect:= Rect (0, 0, 0, 0);
    m1:= Map.Map2Tile(Point (x1, y1));
    m2:= Map.Map2Tile(Point (x2, y2));
    for x:= m1.X to m2.X do
      for y:= m1.Y to m2.Y do
      begin
        item:= Tile [x, y];
        case item.Mode of
          tmSolid:
            mR:= Map.GetTileRect(x, y);
          tmMargin:
            mR:= Map.GetFineRect (x, y, item);
        else
          mR:= Rect (0, 0, 0, 0);
        end;
        if item.TileEvent then
          ASprite.TileEvent(ProcColision, item, Point (x, y))
        else
          ProcColision:= True;
        if ProcColision and not IsRectEmpty(mR) then
        begin
          Result:= True;
          if IsRectEmpty(ColRect) then
            ColRect:= Mr
          else
            UnionRect(ColRect, ColRect, Mr);
        end;
      end;
  end;

  procedure SideColision(const Side: TDxSide);
  var
    info: TDxColisionData;
  begin
    if ColisionResult <> crSkip then
    begin
      info.Side:= Side;
      info.Rect:= FineRc;
      info.Area:= Rcs [Side];
      ASprite.Colision(Info, ColisionResult);
    end;
  end;

  procedure Colision2 (const Sides: TDxSides);
  var
    s, sX, sY: TDxSide;
    Area, R, RX, RY: TRect;
  begin
    { Valida Eixo X }
    if bsLeft in Sides then
      sX:= bsLeft
    else
      sX:= bsRight;
    { Valida Eixo Y }
    if bsTop in Sides then
      sY:= bsTop
    else
      sY:= bsBottom;
    { Executa Colisoes }
    if IntersectRect (R, Rcs[sX], Rcs [sY]) then
    begin
      { Verifica Intersecções }
      if IntersectRect(RX, Rc, Rcs [sX]) and
         IntersectRect(RY, Rc, Rcs [sY]) and
         IntersectRect(Area, RX, RY) then
      begin
        { Analisa dados }
        s:= GetColisionSide(RealRc, Rect2Real (R));
        { Executa Colisao }
        SideColision(s);
      end;//else wait for a defined state
    end else
    begin
      SideColision(sX);
      SideColision(sY);
    end;
  end;

  procedure Colision3 (const Sides: TDxSides);
  begin
    if not (bsLeft in Sides) then
      SideColision(bsRight)
    else if not (bsTop in Sides) then
      SideColision(bsBottom)
    else if not (bsRight in Sides) then
      SideColision(bsLeft)
    else if not (bsBottom in Sides) then
      SideColision(bsTop);
  end;

  procedure Colision4;
  var
    s1, s2: Real;
    sX, sY: TDxSide;
    execX, execY: Boolean;
  begin
    sY:= bsTop;
    sX:= bsLeft;
    execX:= True;
    execY:= True;
    { Valida Eixo X }
    s1:= IntersectHeight (RealRc, Rect2Real (Rcs[bsLeft]));
    s2:= IntersectHeight (RealRc, Rect2Real (Rcs[bsRight]));
    if s1 > s2 then
      sX:= bsLeft
    else if s1 < s2 then
      sX:= bsRight
    else if ASprite.OldX > ASprite.Rx then
      sX:= bsLeft
    else if ASprite.OldX < ASprite.Rx then
      sX:= bsRight
    else
      execX:= False;
    { Valida Eixo Y }
    s1:= IntersectWidth (RealRc, Rect2Real (Rcs[bsTop]));
    s2:= IntersectWidth (RealRc, Rect2Real (Rcs[bsBottom]));
    if s1 > s2 then
      sY:= bsTop
    else if s1 < s2 then
      sY:= bsBottom
    else if ASprite.OldY > ASprite.Ry then
      sY:= bsTop
    else if ASprite.OldY < ASprite.Ry then
      sY:= bsBottom
    else
      execY:= False;
    { Executa Colisao }
    if execX then
      SideColision(sX);
    if execY then
      SideColision(sY);
  end;

var
  LastSide: TDxSide;
  SideCount: Integer;
  ColSides: TDxSides;

  procedure AddSide (const Side: TDxSide);
  begin
    Include (ColSides, Side);
    Inc (SideCount);
    LastSide:= Side;
  end;

  procedure CheckLeft;
  begin
    if RectColision(Rcs[bsLeft], Rc.Left, Rc.Top, Rc.Left, Rc.Bottom) then
      AddSide (bsLeft);
  end;

  procedure CheckTop;
  begin
    if RectColision(Rcs[bsTop], Rc.Left, Rc.Top, Rc.Right, Rc.Top) then
      AddSide (bsTop);
  end;

  procedure CheckRight;
  begin
    if RectColision(Rcs[bsRight], Rc.Right, Rc.Top, Rc.Right, Rc.Bottom) then
      AddSide (bsRight);
  end;

  procedure CheckBottom;
  begin
    if RectColision(Rcs[bsBottom], Rc.Left, Rc.Bottom, Rc.Right, RC.Bottom) then
      AddSide (bsBottom);
  end;

var
  Optimize: Boolean;
begin
  SideCount:= 0;
  colSides:= [];
  ColisionResult:= crNextSide;
  Optimize:= ASprite.Manager.Optimize;
  { Carrega o Rect }
  with ASprite do
    FineRc:= FineRect;
  //Fine Rect
  Rc:= FineRc;
  OffsetRect(Rc, ASprite.X, ASprite.Y);
  //Real Rect
  RealRc:= Rect2Real (FineRc);
  RealOffsetRect(RealRc, ASprite.RX, ASprite.RY);
  //Pre Verificação
  if Optimize then
  begin
    if ASprite.VeloX < 0 then
      CheckLeft
    else if ASprite.VeloX > 0 then
      CheckRight;
    if ASprite.VeloY < 0 then
      CheckTop
    else if ASprite.VeloY > 0 then
      CheckBottom;
  end else
  begin
    CheckLeft;
    CheckTop;
    CheckRight;
    CheckBottom;
  end;
  { Executa Colisoes }
  case SideCount of
    1: SideColision(LastSide);
    2: Colision2 (colSides);
    3: Colision3 (colSides);
    4: Colision4;
  end;
end;

procedure TDxStage.ClearSprites;
var
  i: Integer;
begin
  for i:= 0 to FManager.Count - 1 do
    Manager[i].ClearSprites;
  while FManager.Count > 0 do
  begin
    Manager[0].Free;
    FManager.Delete (0);
  end;
end;

constructor TDxStage.Create(AOwner: TComponent);
begin
  inherited;
  FSprites:= TDxSpriteList.Create (Self);
  FLoaded:= False;
end;

destructor TDxStage.Destroy;
begin
  Unload;
  FSprites.Free;
  inherited;
end;

procedure TDxStage.DrawScreen(AScreen, AFrame: TBitmap);
begin
  if Assigned (FOnDrawScreen) then
    FOnDrawScreen (Self, AScreen, AFrame)
  else
    BitBlt(AScreen.Canvas.Handle, 0, 0, AFrame.Width, AFrame.Height,
      AFrame.Handle, 0, 0, SRCCOPY);
end;

function TDxStage.GetHeight: Integer;
begin
  Result:= MapDataHeight(FMapData);
end;

function TDxStage.GetManager(out StageMng: TDxStageManager; Mng: TDxSpriteManager): Boolean;
var
  i: Integer;
begin
  Result:= False;
  StageMng:= nil;
  for i:= 0 to FManager.Count - 1 do
    if Manager [i].Manager = Mng then
    begin
      StageMng:= Manager [i];
      Result:= True;
      Break;
    end;
end;

function TDxStage.GetManager(out StageMng: TDxStageManager; ASprite: TDxSprite): Boolean;
begin
  Result:= GetManager(StageMng, ASprite.Manager);
end;

function TDxStage.GetManagerCount: Integer;
begin
  Result:= FManager.Count;
end;

function TDxStage.GetMapHeight: Integer;
begin
  Result:= Height * Map.TileHeight;
end;

function TDxStage.GetMapRect: TRect;
begin
  Result:= Bounds(0, 0, MapWidth, MapHeight);
end;

function TDxStage.GetMapWidth: Integer;
begin
  Result:= Width * Map.TileWidth;
end;

function TDxStage.GetSprite(i, j: Integer): TDxSprite;
begin
  Result:= Manager [i].Sprite [j];
end;

function TDxStage.GetStageManager(Index: Integer): TDxStageManager;
begin
  Result:= TDxStageManager (FManager [Index]);
end;

function TDxStage.GetTile(x, y: Integer): TDxTileItem;
begin
  Result:= Map.GetTileFromData (FMapData, x, y, FMap.Rotate);
end;

function TDxStage.GetWidth: Integer;
begin
  Result:= MapDataWidth (FMapData);
end;

procedure TDxStage.KillClear;
var
  i, j: Integer;
begin
  i:= 0;
  while i < ManagerCount do
  begin
    j:= 0;
    { Remove os Sprites }
    while j < Manager [i].Count do
      if Sprite [i, j].FKilled then
        Manager [i].RemoveSprite (j)
      else
        inc (j);
    { Remove Managers Vazios }
    if Manager [i].Count = 0 then
    begin
      Manager [i].Free;
      FManager.Delete (i);
    end else
      inc (i);
  end;
end;

procedure TDxStage.Load (AMachine: TDxMachine);
var
  i: Integer;
  Inicio, Interval: Cardinal;
begin
  if FLoaded then Exit;
  FMapPt:= Point (0, 0);
  { Pre-Load }
  if Assigned (FBeforeLoad) then
    FBeforeLoad (Self);
  { Carrega o Splash }
  Interval:= GetTickCount;
  Inicio:= Interval;
  if Assigned (Splash) then
    with Splash do
    begin
      if Assigned (Audio) then
        Audio.Play (True);
      if Assigned (Image) then
        Image.Load;
      MakeFrame(AMachine.Screen.Canvas);
      AMachine.DrawFrame;
    end;
  { Carrega o Mapa }
  FManager:= TList.Create;
  MapLoad (AMachine);
  { Carrega os Sprites }
  for i:= 0 to Sprites.Count - 1 do
  begin
    LoadItem (Sprites.Items[i]);
    if Assigned (Splash) and (GetTickCount - Interval > Splash.FrameDelay) then
    begin
      Interval:= GetTickCount;
      Splash.MakeFrame(AMachine.Screen.Canvas);
      AMachine.DrawFrame;
    end;
    Application.ProcessMessages;
  end;
  { Executa Comandos do Usuario }
  if Assigned (FOnLoad) then
    FOnLoad (Self);
  { Mantem tempo de Exibição Minima }
  while GetTickCount - Inicio < Splash.FDelay do
  begin
    if Assigned (Splash) and (GetTickCount - Interval > Splash.FrameDelay) then
    begin
      Interval:= GetTickCount;
      Splash.MakeFrame(AMachine.Screen.Canvas);
      AMachine.DrawFrame;
    end;
    Application.ProcessMessages;
  end;
  { Finaliza o Splash }
  if Assigned (Splash) then
    with Splash do
      if Assigned (Image) then
        Image.Unload;
  FLoaded:= True;
  { Pos-Load }
  if Assigned (FAfterLoad) then
    FAfterLoad (Self);
end;

procedure TDxStage.LoadItem(AItem: TDxSpriteItem);
var
  s: TDxSprite;
begin
  if Assigned (AItem.Sprite) then
  begin
    s:= AItem.Sprite;
    if AItem.Restore then
      s.Restore;
  end else
    s:= TDxSprite.Create (Self, AItem.Manager, AItem.Skin);
  { Inicializa o Sprite }
  s.X:= AItem.Fx;
  s.Y:= AItem.Fy;
  s.ResetInitPos;
  s.MirrorX:= AItem.MirrorX;
  s.MirrorY:= AItem.MirrorY;
  s.Visible:= AItem.Visible;
  s.Skin.Load;
  AItem.Load(s);
  AddSprite(s);
end;

procedure TDxStage.MakeFrame(const FrameRc: TRect; Canvas: TCanvas;
  Machine: TDxMachine);

  procedure DrawMap;
  var
    c: TPoint;
    RMap: TRect;
    i, j, x, y: Integer;
  begin
    c:= CenterPoint(FrameRc);
    if (FMapPt.X <> c.X) or (FMapPt.Y <> c.Y) then
    begin
      FMapBk.Canvas.Lock;
      FMapPt:= c;
      if Assigned (Map.Background) then
        FillImage(FMapBk.Canvas, 0, 0, FMapBk.Width, FMapBk.Height,
          Map.Background.Bitmap.Canvas, FMapPt.X * Map.ScrollX div 1000,
          FMapPt.Y * Map.ScrollY div 1000)
      else
        with FMapBk.Canvas do
        begin
          Brush.Color:= FMap.FFillColor;
          FillRect(ClipRect);
        end;
      RMap:= FMap.Map2Tile(FrameRc);
      for i:= RMap.Left to RMap.Right do
      begin
        x:= i * FMap.TileWidth + Machine.XOffSet;
        for j:= RMap.Top to RMap.Bottom do
          with Tile [i, j] do
          begin
            y:= j * FMap.TileHeight + Machine.YOffSet;
            if FImageIndex >= 0 then
            begin
              if Transparent then
              begin
                BitBlt(FMapBk.Canvas.Handle, x, y, FMap.TileWidth,
                  FMap.TileHeight, FTileImg.Canvas.Handle, 0, 0, SRCAND);
                BitBlt(FMapBk.Canvas.Handle, x, y, FMap.TileWidth,
                  FMap.TileHeight, FTileImg.Canvas.Handle, 0, 0, SRCPAINT);
              end else
                BitBlt(FMapBk.Canvas.Handle, x, y, FMap.TileWidth,
                  FMap.TileHeight, FTileImg.Canvas.Handle, 0, 0, SRCCOPY);
            end;
          end;
      end;
      FMapBk.Canvas.Unlock;
    end;
    BitBlt(Canvas.Handle, 0, 0, FMapBk.Width, FMapBk.Height,
      FMapBk.Canvas.Handle, 0, 0, SRCCOPY);
  end;

var
  Rc: TRect;
  i, j: Integer;
begin
  try
    Canvas.Lock;
    { Desenha o Map }
    DrawMap;
    { Desenha os Sprites }
    for i:= 0 to FManager.Count - 1 do
      for j:= 0 to Manager [i].Count - 1 do
        with Sprite[i, j] do
          if FVisible and IntersectRect(Rc, GetRect, FrameRc) then
            Draw (Canvas, FrameRc);
  finally
    Canvas.Unlock;
  end;
end;

procedure TDxStage.MapLoad (Machine: TDxMachine);
begin
  FMap.Tiles.Load;
  { Carrega dados do mapa }
  LoadMapData (FMapData, FMap.Data);
  if Assigned (FMapBk) then
    FMapBk.Free;
  FMapBk:= TBitmap.Create;
  FMapBk.Width:= Machine.FFrame.Width;
  FMapBk.Height:= Machine.FFrame.Height;
end;

procedure TDxStage.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  i: Integer;
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FMap then
      FMap:= nil
    else if AComponent = FAudio then
      FAudio:= nil
    else if AComponent = FNextStage then
      FNextStage:= nil
    else if AComponent = FSplash then
      FSplash:= nil
    else
      for i:= 0 to FSprites.Count - 1 do
        with FSprites.Items [i] do
          if FSprite = AComponent then
            FSprite:= nil
          else if FManager = AComponent then
            FManager:= nil
          else if FSkin = AComponent then
            FSkin:= nil;
  end;
end;

procedure TDxStage.RotateSprites (const Center: TPoint);
var
  i, j: Integer;
begin
  for i:= 0 to FManager.Count - 1 do
    for j:= 0 to Manager [i].Count - 1 do
      StageRotate (Self, Sprite[i, j], Center);
end;

procedure TDxStage.SetAudio(const Value: TDxAudio);
begin
  if FAudio <> Value then
  begin
    if Assigned (FAudio) then
      FAudio.RemoveFreeNotification(Self);
    FAudio:= Value;
    if Assigned (Value) then
      Value.FreeNotification(Self);
  end;
end;

procedure TDxStage.SetMap(const Value: TDxMap);
begin
  if FMap <> Value then
  begin
    if Assigned (FMap) then
      FMap.RemoveFreeNotification(Self);
    FMap:= Value;
    if Assigned (Value) then
      Value.FreeNotification(Self);
  end;
end;

procedure TDxStage.SetNextStage(const Value: TDxStage);
begin
  if Value = Self then
    ShowMessage ('Não pode atribuir a si mesmo.')
  else if FNextStage <> Value then
  begin
    if Assigned (FNextStage) then
      FNextStage.RemoveFreeNotification (Self);
    FNextStage := Value;
    if Assigned (Value) then
      Value.FreeNotification(Self);
  end;
end;

procedure TDxStage.SetSplash(const Value: TDxSplash);
begin
  if FSplash <> Value then
  begin
    if Assigned (FSplash) then
      FSplash.RemoveFreeNotification (Self);
    FSplash := Value;
    if Assigned (Value) then
      Value.FreeNotification (Self);
  end;
end;

procedure TDxStage.SetSprites(const Value: TDxSpriteList);
begin
  FSprites.Assign (Value);
end;

procedure TDxStage.Unload;
begin
  if not FLoaded then Exit;
  ClearSprites;
  if Assigned (FOnUnload) then
    FOnUnload (Self);
  //Libera Memoria
  FreeAndNil (FMapBk);
  FreeAndNil (FManager);
  FLoaded:= False;
end;

end.
