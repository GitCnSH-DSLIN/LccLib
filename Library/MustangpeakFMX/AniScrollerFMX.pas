unit AniScrollerFMX;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Generics.Collections,
  System.Generics.Defaults, System.UITypes, System.UIConsts, System.Types, FMX.Graphics,
  FMX.Ani, FMX.InertialMovement, System.Math;

type
  TAniTargets = array of TAniCalculations.TTarget;

type
  TAniScroller = class
  private
    FAniCalc: TAniCalculations;
    FAniTargets: TAniTargets;
    FPreviousScrollPos: TPointF;
    FScrolling: Boolean;
    FOwnerControl: TControl;
    FWorldRect: TRectF;
    FLineScroll: real;
    function GetScrollOffsetMaxX: single;
    function GetScrollOffsetMaxY: single;
    function GetScrollOffsetX: single;
    function GetScrollOffsetY: single;
    procedure SetScrollOffsetX(const Value: single);
    procedure SetScrollOffsetY(const Value: single);
  protected
    property AniCalc: TAniCalculations read FAniCalc write FAniCalc;
    property AniTargets: TAniTargets read FAniTargets write FAniTargets;
    property ClientRect: TRectF read FWorldRect write FWorldRect;
    property PreviousScrollPos: TPointF read FPreviousScrollPos write FPreviousScrollPos;

    procedure AniCalcStart(Sender: TObject);
    procedure AniCalcChange(Sender: TObject);
    procedure AniCalcStop(Sender: TObject);
  public
    property OwnerControl: TControl read FOwnerControl;
    property Scrolling: Boolean read FScrolling write FScrolling;
    property ScrollOffsetX: single read GetScrollOffsetX write SetScrollOffsetX;
    property ScrollOffsetMaxX: single read GetScrollOffsetMaxX;
    property ScrollOffsetY: single read GetScrollOffsetY write SetScrollOffsetY;
    property ScrollOffsetMaxY: single read GetScrollOffsetMaxY;
    property LineScroll: real read FLineScroll write FLineScroll;

    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    procedure GetWindowRect(var ARect: TRectF);
    procedure GetViewportRect(var ARect: TRectF);
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure MouseLeave;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure MouseMove(Shift: TShiftState; X, Y: Single);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure SetWorldRect(ARect: TRectF);
  end;

implementation

type
  TControlHack = class(TControl)

  end;

{ TAniScroller }

procedure TAniScroller.AniCalcChange(Sender: TObject);
begin
  if (PreviousScrollPos.X <> AniCalc.ViewportPositionF.X) or (PreviousScrollPos.Y <> AniCalc.ViewportPositionF.Y) then
  begin
    OwnerControl.InvalidateRect(OwnerControl.LocalRect);
    PreviousScrollPos := AniCalc.ViewportPositionF;
  end;
end;

procedure TAniScroller.AniCalcStart(Sender: TObject);
begin
  if OwnerControl.Scene <> nil then
    OwnerControl.Scene.ChangeScrollingState(OwnerControl, True);

  FScrolling := True;
end;

procedure TAniScroller.AniCalcStop(Sender: TObject);
begin
  FScrolling := False;
 // FSwipeDirection := ksSwipeUnknown;

  if OwnerControl.Scene <> nil then
    OwnerControl.Scene.ChangeScrollingState(nil, False);
end;

constructor TAniScroller.Create(AOwner: TComponent);
begin
  FOwnerControl := AOwner as TControl;
  SetLength(FAniTargets, 2);
  FAniCalc := TAniCalculations.Create(OwnerControl);
  AniCalc.Animation := True;
  AniCalc.Averaging := True;
  AniCalc.OnChanged := AniCalcChange;
  AniCalc.Interval := 8;
  AniCalc.OnStart := AniCalcStart;
  AniCalc.OnStop := AniCalcStop;
  AniCalc.BoundsAnimation := True;     //FPullToRefresh.Enabled;
  AniCalc.TouchTracking := [ttVertical];
  FLineScroll := 44;
end;

destructor TAniScroller.Destroy;
begin
  FreeAndNil(FAniCalc);
  inherited;
end;

function TAniScroller.GetScrollOffsetMaxX: single;
begin
  Result := Max(0 - OwnerControl.Width, 0);
end;

function TAniScroller.GetScrollOffsetMaxY: single;
begin
  Result := Max( ClientRect.Height - OwnerControl.Height, 0);
end;

function TAniScroller.GetScrollOffsetX: single;
begin
  Result := AniCalc.ViewportPositionF.X
end;

function TAniScroller.GetScrollOffsetY: single;
begin
  Result := AniCalc.ViewportPositionF.Y
end;

procedure TAniScroller.GetViewportRect(var ARect: TRectF);
begin
  GetWindowRect(ARect);
  ARect.Offset(ScrollOffsetX, ScrollOffsetY);
end;

procedure TAniScroller.GetWindowRect(var ARect: TRectF);
begin
  ARect.Create(0, 0, OwnerControl.Width, OwnerControl.Height);
end;

procedure TAniScroller.KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  case Key of
    vkDown  : ScrollOffsetY := ScrollOffsetY + LineScroll;
    vkUp    : ScrollOffsetY := ScrollOffsetY - LineScroll;
    vkRight : ScrollOffsetX := ScrollOffsetX - LineScroll;
    vkLeft  : ScrollOffsetX := ScrollOffsetX - LineScroll;
    vkNext  : ScrollOffsetY := ScrollOffsetY + OwnerControl.Height;
    vkPrior : ScrollOffsetY := ScrollOffsetY - OwnerControl.Height;
    vkHome  : begin
                ScrollOffsetY := 0;
                ScrollOffsetX := 0;
              end;
    vkEnd :   begin
                ScrollOffsetY := ScrollOffsetMaxY;
                ScrollOffsetX := ScrollOffsetMaxY;
              end;
  end;
end;

procedure TAniScroller.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TControlHack( FOwnerControl).Capture;
 // AniCalc.BoundsAnimation := FPullToRefresh.Enabled;
  AniCalc.MouseDown(x, y);
  FScrolling := True;
end;

procedure TAniScroller.MouseLeave;
begin
  AniCalc.MouseLeave;
end;

procedure TAniScroller.MouseMove(Shift: TShiftState; X, Y: Single);
begin
 if Scrolling then
   AniCalc.MouseMove(X, Y);
end;

procedure TAniScroller.MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: Single);
begin
 if Scrolling then
    AniCalc.MouseUp(X, Y);
  FScrolling := False;
  AniCalc.BoundsAnimation := True;
end;

procedure TAniScroller.SetWorldRect(ARect: TRectF);
begin
  FWorldRect := ARect;
  FAniTargets[0].TargetType := TAniCalculations.TTargetType.Min;
  FAniTargets[0].Point := TPointD.Create(0, 0);
  FAniTargets[1].TargetType := TAniCalculations.TTargetType.Max;
  FAniTargets[1].Point := TPointD.Create(ScrollOffsetMaxX, ScrollOffsetMaxY);
  AniCalc.SetTargets(FAniTargets);
end;

procedure TAniScroller.SetScrollOffsetX(const Value: single);
var
  Temp: single;
begin
  Temp := Max(Value, -OwnerControl.Width);
  Temp := Min(Temp, ScrollOffsetMaxX + OwnerControl.Width);
  if AniCalc.ViewportPositionF.X <> Temp then
  begin
    AniCalc.ViewportPositionF := TPointF.Create(Temp, ScrollOffsetY);
    OwnerControl.InvalidateRect(OwnerControl.LocalRect);
  end;
end;

procedure TAniScroller.SetScrollOffsetY(const Value: single);
var
  Temp: single;
begin
  Temp := Max(Value, -OwnerControl.Height);
  Temp := Min(Temp, ScrollOffsetMaxY + OwnerControl.Height);
  if AniCalc.ViewportPositionF.Y <> Temp then
  begin
    AniCalc.ViewportPositionF := TPointF.Create(ScrollOffsetX, Temp);
    OwnerControl.InvalidateRect(OwnerControl.LocalRect);
  end;
end;

end.