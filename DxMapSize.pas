{ ********************************************************************** }
{  DxMapSize - Dises Game Engine Copyright (C) 2008 Danyz                }
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

unit DxMapSize;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Spin;

type
  TFrmMapSize = class(TForm)
    Label_seX: TLabel;
    seCols: TSpinEdit;
    Label_seY: TLabel;
    seRows: TSpinEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private
    function GetCols: Integer;
    function GetRows: Integer;
    procedure SetCols(const Value: Integer);
    procedure SetRows(const Value: Integer);
  public
    property Cols: Integer read GetCols write SetCols;
    property Rows: Integer read GetRows write SetRows;
  end;

var
  FrmMapSize: TFrmMapSize;

implementation

{$R *.dfm}

{ TFrmMapSize }

function TFrmMapSize.GetCols: Integer;
begin
  Result:= seCols.Value;
end;

function TFrmMapSize.GetRows: Integer;
begin
  Result:= seRows.Value;
end;

procedure TFrmMapSize.SetCols(const Value: Integer);
begin
  seCols.Value:= Value;
end;

procedure TFrmMapSize.SetRows(const Value: Integer);
begin
  seRows.Value:= Value;
end;

end.
