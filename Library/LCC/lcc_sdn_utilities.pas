unit lcc_sdn_utilities;

{$IFDEF FPC}
{$mode delphi}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, lcc_xmlutilities,
  {$IFDEF FPC}
  Generics.Collections,
  {$ELSE}
  System.Generics.Collections,
  {$ENDIF}
  lcc_defines, lcc_utilities;

const
  VALID_DICTIONARY: array[0..5] of string = ('occupied', 'straight', 'hi', 'on', 'valid', 'true');
  INVALID_DICTIONARY: array[0..5] of string = ('unoccupied', 'diverging', 'lo', 'off', 'invalid', 'false');

type

  TSupportsEventType = (set_None, set_LoEventID, set_HiEventID);
  TPCMap = array of TEventID;
  TLogicalActionType = (lat_Undefined, lat_Input, lat_Output);

  TLccBinaryAction = class;  //forwared

  { TLccLogicAction }

  TLccLogicAction = class
  private
    FEventIDHiLinked: TEventID;
    FEventIDLoLinked: TEventID;
    FEventStateLinked: TEventState;
    FInverted: Boolean;
    FLogicTrueStateName: string;
    FLinkedName: string;
    FLogicTrueState: TEventState;
  public
    property LinkedName: string read FLinkedName write FLinkedName;
    property EventIDLoLinked: TEventID read FEventIDLoLinked write FEventIDLoLinked;
    property EventIDHiLinked: TEventID read FEventIDHiLinked write FEventIDHiLinked;
    property EventStateLinked: TEventState read FEventStateLinked write FEventStateLinked;
    property LogicTrueStateName: string read FLogicTrueStateName write FLogicTrueStateName;
    property LogicTrueState: TEventState read FLogicTrueState write FLogicTrueState;
    property Inverted: Boolean read FInverted write FInverted;

    function EqualAction(AnAction: TLccBinaryAction): Boolean;
  end;

  { TLccLogic }

  TLccLogic = class
  private
    FActions: TObjectList<TLccLogicAction>;
    FOwner: TLccBinaryAction;
  public
    constructor Create(AnOwnerAction: TLccBinaryAction);
    destructor Destroy; override;
    function Calculate: Boolean;
    property Actions: TObjectList<TLccLogicAction> read FActions write FActions;
    property Owner: TLccBinaryAction read FOwner;
  end;

  { TLccBinaryAction }

  TLccBinaryAction = class
  private
    FActionType: TLogicalActionType;
    FConsumer: Boolean;
    FDescription: string;
    FEventState: TEventState;
    FIoPin: Integer;
    FIsDirty: Boolean;
    FLccClass: string;
    FLogic: TLccLogic;
    FName: string;
    FProducer: Boolean;
  public
    FEventIDHi: TEventID;
    FEventIDLo: TEventID;
    constructor Create(AnActionType: TLogicalActionType);
    destructor Destroy; override;

    property ActionType: TLogicalActionType read FActionType;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property LccClass: string read FLccClass write FLccClass;
    property EventIDLo: TEventID read FEventIDLo write FEventIDLo;
    property EventIDHi: TEventID read FEventIDHi write FEventIDHi;
    property EventState: TEventState read FEventState write FEventState;
    property Producer: Boolean read FProducer write FProducer;
    property Consumer: Boolean read FConsumer write FConsumer;
    property IoPin: Integer read FIoPin write FIoPin;
    property Logic: TLccLogic read FLogic write FLogic;
    property IsDirty: Boolean read FIsDirty write FIsDirty;
  end;

  { TLccActionGroup }

  TLccActionGroup = class
  private
    FActions: TObjectList<TLccBinaryAction>;
    FLccClass: string;
  public
    constructor Create;
    destructor Destroy; override;
    property Actions: TObjectList<TLccBinaryAction> read FActions write FActions;
    property LccClass: string read FLccClass write FLccClass;
  end;

  { TLccObject }

  TLccObject = class
  private
    FLccClass: string;
    FDescription: string;
    FInputActionGroups: TObjectList<TLccActionGroup>;
    FName: string;
    FOutputActionGroups: TObjectList<TLccActionGroup>;
  public
    constructor Create;
    destructor Destroy; override;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property LccClass: string read FLccClass write FLccClass;
    property InputActionGroups: TObjectList<TLccActionGroup> read FInputActionGroups write FInputActionGroups;
    property OutputActionGroups: TObjectList<TLccActionGroup>read FOutputActionGroups write FOutputActionGroups;
  end;

  { TLccDistrict }

  TLccDistrict = class
  private
    FDescription: string;
    FLccClass: string;
    FLccObjects: TObjectList<TLccObject>;
    FName: string;
  public
    constructor Create;
    destructor Destroy; override;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property LccClass: string read FLccClass write FLccClass;
    property LccObjects: TObjectList<TLccObject> read FLccObjects write FLccObjects;
  end;

  { TLccSdnController }

  TLccSdnController = class(TComponent)
  private
    FConsumerMap: TPCMap;
    FExternals: TStringList;
    FAvailableIoInput: Integer;
    FAvailableIoOutput: Integer;
    FActions: TObjectList<TLccBinaryAction>;
    FLccDistricts: TObjectList<TLccDistrict>;
    FNodeID: TNodeID;
    FProducerIdMap: TPCMap;
    FVersion: string;
    FXmlDocument: LccXmlDocument;
    function GetInputActionCount: Integer;
    function GetOuptputActionCount: Integer;
  protected
    procedure AppendToPCMap(var PCMap: TPCMap; Event: TEventID);
    procedure InternalParse;
    procedure InternalExport(XmlDoc: LccXmlDocument);
    function EventStateToAttribString(EventState: TEventState): string;
    function AttribStringToEventState(EventState: string): TEventState;
    function InValidDictionary(Value: string): Boolean;
    function InInvalidDictionary(Value: string): Boolean;

    function FindActionByName(ActionName: string): TLccBinaryAction;
    function FindActionByIoPin(IoPin: Integer): TLccBinaryAction;

    procedure LogicActionsUpdate(AnAction: TLccBinaryAction);

  public
    property AvailableIoInputs: Integer read FAvailableIoInput;
    property AvailableIoOutput: Integer read FAvailableIoOutput;
    property ConsumerIdMap: TPCMap read FConsumerMap;
    property Externals: TStringList read FExternals write FExternals;
    property Actions: TObjectList<TLccBinaryAction> read FActions write FActions;
    property LccDistricts: TObjectList<TLccDistrict> read FLccDistricts write FLccDistricts;
    property InputActionCount: Integer read GetInputActionCount;
    property OutputActionCount: Integer read GetOuptputActionCount;
    property NodeID: TNodeID read FNodeID write FNodeID;
    property ProducerIdMap: TPCMap read FProducerIdMap;
    property Version: string read FVersion;
    property XmlDocument: LccXmlDocument read FXmlDocument;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AutoAssignEventIDs;
    procedure AutoAssignLogicEvents;
    procedure Clear;
    function FindDistrict(AName: string): TLccDistrict;
    function PinUpdate(IoPin: Integer; IoPinState: Boolean): TLccBinaryAction;
    function SupportsProduced(var Event: TEventID; var Action: TLccBinaryAction): TSupportsEventType;
    function SupportsConsumed(var Event: TEventID; var Action: TLccBinaryAction): TSupportsEventType;
    function XMLParse(AFilePath: string): Boolean;
    procedure XMLExport(ExportFilePath: string);
  end;

procedure Register;

implementation

procedure Register;
begin
  {$IFNDEF FPC_CONSOLE_APP}
  {$IFDEF FPC}
  //{$I TLccSdnController.lrs}
  {$ENDIF}
  RegisterComponents('LCC',[TLccSdnController]);
  {$ENDIF}
end;

function BooleanToString(Bool: Boolean): string;
begin
  if Bool then Result := 'true' else Result := 'false'
end;

function StringToBoolean(BoolStr: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  i := 0;
  while (i < Length(VALID_DICTIONARY)) and not Result do
  begin
    Result := LowerCase(BoolStr) = LowerCase(VALID_DICTIONARY[i]);
    Inc(i);
  end;
end;

{ TLccDistrict }

constructor TLccDistrict.Create;
begin
  inherited;
  FLccObjects := TObjectList<TLccObject>.Create;
end;

destructor TLccDistrict.Destroy;
begin
  FreeAndNil(FLccObjects);
  inherited Destroy;
end;

{ TLccLogicAction }

function TLccLogicAction.EqualAction(AnAction: TLccBinaryAction): Boolean;
begin
  Result := EqualEventID(AnAction.EventIDLo, EventIDLoLinked) and EqualEventID(AnAction.EventIDHi, EventIDHiLinked)
end;

{ TLccLogic }

constructor TLccLogic.Create(AnOwnerAction: TLccBinaryAction);
begin
  inherited Create;
  FOwner := AnOwnerAction;
  FActions := TObjectList<TLccLogicAction>.Create;
end;

destructor TLccLogic.Destroy;
begin
  {$IFDEF FPC}
  FreeAndNil(FActions);
  {$ELSE}
  FActions.DisposeOf;
  FActions := nil;
  {$ENDIF}
  inherited Destroy;
end;

function TLccLogic.Calculate: Boolean;
var
  i: Integer;
  LogicAction: TLccLogicAction;
  EvaluatedResult: Boolean;
begin
  Result := False;
  EvaluatedResult := True;
  i := 0;
  while EvaluatedResult and (i < Actions.Count) do
  begin
    LogicAction := Actions[i];
    if LogicAction.Inverted then
    begin
      if LogicAction.LogicTrueState = evs_Valid then
        EvaluatedResult := evs_Invalid = LogicAction.EventStateLinked
      else
      if LogicAction.LogicTrueState = evs_Invalid then
        EvaluatedResult := evs_Valid = LogicAction.EventStateLinked;
    end else
      EvaluatedResult := LogicAction.LogicTrueState = LogicAction.EventStateLinked;
    Inc(i);
  end;

  if EvaluatedResult and (Owner.EventState <> evs_Valid) then
  begin
    Owner.EventState  := evs_Valid;
    Owner.IsDirty := True;
    Result := True
  end else
  if not EvaluatedResult and (Owner.EventState <> evs_InValid) then
  begin
    Owner.EventState  := evs_InValid;
    Owner.IsDirty := True;
    Result := True
  end
end;

{ TLccBinaryAction }

constructor TLccBinaryAction.Create(AnActionType: TLogicalActionType);
begin
  inherited Create;
  FActionType := AnActionType;
  FLogic := TLccLogic.Create(Self);
end;

destructor TLccBinaryAction.Destroy;
begin
   {$IFDEF FPC}
  FreeAndNil(FLogic);
  {$ELSE}
  FLogic.DisposeOf;
  FLogic := nil;
  {$ENDIF}
  inherited Destroy;
end;

{ TLccActionGroup }

constructor TLccActionGroup.Create;
begin
  inherited;
  FActions := TObjectList<TLccBinaryAction>.Create;
end;

destructor TLccActionGroup.Destroy;
begin
  {$IFDEF FPC}
  FreeAndNil(FActions);
  {$ELSE}
  FActions.DisposeOf;
  FActions := nil;
  {$ENDIF}
  inherited Destroy;
end;

{ TLccObject }

constructor TLccObject.Create;
begin
  inherited;
  FInputActionGroups := TObjectList<TLccActionGroup>.Create;
  FOutputActionGroups := TObjectList<TLccActionGroup>.Create;
end;

destructor TLccObject.Destroy;
begin
  {$IFDEF FPC}
  FreeAndNil(FInputActionGroups);
  FreeAndNil(FOutputActionGroups);
  {$ELSE}
  FInputActionGroups.DisposeOf;
  FOutputActionGroups.DisposeOf;
  FInputActionGroups := nil;
  FOutputActionGroups := nil;
  {$ENDIF}
  inherited Destroy;
end;

{ TLccSdnController }

procedure TLccSdnController.AppendToPCMap(var PCMap: TPCMap; Event: TEventID);
begin
  SetLength(PCMap, Length(PCMap) + 1);
  PCMap[Length(PCMap)-1] := Event;
end;

procedure TLccSdnController.AutoAssignEventIDs;
var
  ActionGroup: TLccActionGroup;
  Action: TLccBinaryAction;
  LccObject: TLccObject;
  ALccDistrict: TLccDistrict;
  iObject, iActionGroup, iAction, iIoPin, EventOffset, iDistrict: Integer;
begin
  iIoPin := 0;
  EventOffset := 0;
  SetLength(FProducerIdMap, 0);
  SetLength(FConsumerMap, 0);

  for iDistrict := 0 to LccDistricts.Count - 1 do
  begin
    for iObject:= 0 to LccDistricts[iDistrict].LccObjects.Count - 1 do
    begin
      LccObject := LccDistricts[iDistrict].LccObjects[iObject] {$IFDEF FPC}as TLccObject{$ENDIF};

      // SDN expects the auto generated number to sart with inputs then move to outputs
      for iActionGroup := 0 to LccObject.InputActionGroups.Count - 1 do
      begin
        ActionGroup := LccObject.InputActionGroups[iActionGroup] {$IFDEF FPC}as TLccActionGroup{$ENDIF};
        for iAction := 0 to ActionGroup.Actions.Count - 1 do
        begin
          if iIoPin < AvailableIoInputs then
          begin
            Action := ActionGroup.Actions[iAction] {$IFDEF FPC}as TLccBinaryAction{$ENDIF};
            NodeIDToEventID(NodeID, EventOffset, Action.FEventIDLo);
            NodeIDToEventID(NodeID, EventOffset+1, Action.FEventIDHi);
            Action.EventState := evs_Unknown;
            Action.IoPin := iIoPin;
            Action.Producer := True;
            AppendToPCMap(FProducerIdMap, Action.FEventIDLo);
            AppendToPCMap(FProducerIdMap, Action.FEventIDHi);
            Inc(iIoPin);
            Inc(EventOffset, 2);
          end else
            raise exception.Create('Not enough I/O Pins to implement this xml file');
        end;
      end;

      for iActionGroup := 0 to LccObject.OutputActionGroups.Count - 1 do
      begin
        ActionGroup := LccObject.OutputActionGroups[iActionGroup] {$IFDEF FPC}as TLccActionGroup{$ENDIF};
        for iAction := 0 to ActionGroup.Actions.Count - 1 do
        begin
          if iIoPin < AvailableIoInputs + AvailableIoOutput then
          begin
            Action := ActionGroup.Actions[iAction] {$IFDEF FPC}as TLccBinaryAction{$ENDIF};
            NodeIDToEventID(NodeID, EventOffset, Action.FEventIDLo);
            NodeIDToEventID(NodeID, EventOffset+1, Action.FEventIDHi);
            Action.EventState := evs_Unknown;
            Action.IoPin := iIoPin;
            Action.Consumer := True;
            AppendToPCMap(FConsumerMap, Action.FEventIDLo);
            AppendToPCMap(FConsumerMap, Action.FEventIDHi);
            Inc(iIoPin);
            Inc(EventOffset, 2);
          end else
            raise exception.Create('Not enough I/O Pins to implement this xml file');
        end;
      end;
    end;
  end;
end;

procedure TLccSdnController.AutoAssignLogicEvents;
var
  iAction, iLogic: Integer;
  LogicAction: TLccLogicAction;
  ActionLink: TLccBinaryAction;
begin
  for iAction := 0 to Actions.Count - 1 do
    for iLogic := 0 to Actions[iAction].Logic.Actions.Count - 1 do
    begin
      LogicAction := Actions[iAction].Logic.Actions[iLogic];
      ActionLink := FindActionByName(LogicAction.LinkedName);
      if Assigned(ActionLink) then
      begin
        LogicAction.FEventIDLoLinked := ActionLink.EventIDLo;
        LogicAction.FEventIDHiLinked := ActionLink.EventIDHi;
      end
    end;
   // TODO: Deal with External Assignments
end;

procedure TLccSdnController.Clear;
begin
  XmlFreeDocument(FXmlDocument);
end;

constructor TLccSdnController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExternals := TStringList.Create;
  FLccDistricts := TObjectList<TLccDistrict>.Create;
  FActions := TObjectList<TLccBinaryAction>.Create;
  Actions.OwnsObjects := False;
end;

destructor TLccSdnController.Destroy;
begin
  FreeAndNil(FExternals);
  {$IFDEF FPC}
  FreeAndNil(FLccDistricts);
  FreeAndNil(FActions);
  {$ELSE}
  LccDistricts.DisposeOf;
  LccDistricts := nil;
  Actions.DisposeOf;
  Actions := nil;
  {$ENDIF}
  inherited Destroy;
end;

function TLccSdnController.EventStateToAttribString(EventState: TEventState): string;
begin
  case EventState of
    evs_Valid : Result := 'valid';
    evs_InValid : Result := 'invalid';
    evs_Unknown : Result := 'unknown'
  end;
end;

procedure TLccSdnController.XMLExport(ExportFilePath: string);
var
  XmlDoc: LccXmlDocument;
begin
  XmlDoc := XmlCreateEmptyDocument;
  InternalExport(XmlDoc);
  XmlWriteToFile(ExportFilePath, XmlDoc);
  XmlFreeDocument(XmlDoc);
end;

function TLccSdnController.FindActionByName(ActionName: string): TLccBinaryAction;
var
  iAction: Integer;
begin
  Result := nil;
  for iAction := 0 to Actions.Count - 1 do
  begin
    if Actions[iAction].Name = ActionName then
    begin
      Result := Actions[iAction];
      Break;
    end;
  end;
end;

function TLccSdnController.FindDistrict(AName: string): TLccDistrict;
var
  i: Integer;
begin
  Result := nil;
  i := 0;
  while (i < LccDistricts.Count) and not Assigned(Result) do
  begin
    if LccDistricts[i].Name = AName then
      Result := LccDistricts[i];
    Inc(i);
  end;
end;

function TLccSdnController.FindActionByIoPin(IoPin: Integer): TLccBinaryAction;
var
  iAction: Integer;
begin
  Result := nil;
  for iAction := 0 to Actions.Count - 1 do
  begin
    if Actions[iAction].IoPin = IoPin then
    begin
      Result := Actions[iAction];
      Break;
    end;
  end;
end;

procedure TLccSdnController.LogicActionsUpdate(AnAction: TLccBinaryAction);
var
  i, j: Integer;
  LocalAction: TLccBinaryAction;
  LogicAction: TLccLogicAction;
begin
  for i := 0 to Actions.Count - 1 do
  begin
    LocalAction := Actions[i];
    if LocalAction.Consumer then
    begin
      for j := 0 to LocalAction.Logic.Actions.Count - 1 do
      begin
        LogicAction := LocalAction.Logic.Actions[j];
        if LogicAction.EqualAction(AnAction) then
        begin
          if AnAction.EventState <> LocalAction.EventState then
          begin
            LogicAction.EventStateLinked := AnAction.EventState;
            LocalAction.FIsDirty := True;
          end;
        end;
      end;
    end;
  end;
end;

function TLccSdnController.GetInputActionCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Actions.Count - 1 do
  begin
    if Actions[i].ActionType = lat_Input then
      Inc(Result);
  end;
end;

function TLccSdnController.GetOuptputActionCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Actions.Count - 1 do
  begin
    if Actions[i].ActionType = lat_Output then
      Inc(Result);
  end;
end;

function TLccSdnController.InInvalidDictionary(Value: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  i := 0;
  Value := LowerCase(Value);
  while (i < Length(INVALID_DICTIONARY)) and not Result do
  begin
    Result := Value = INVALID_DICTIONARY[i];
    Inc(i);
  end;
end;

function TLccSdnController.PinUpdate(IoPin: Integer; IoPinState: Boolean): TLccBinaryAction;
var
  Action: TLccBinaryAction;
begin
  Result := FindActionByIoPin(IoPin);
  if Assigned(Result) then
  begin
    if Result.ActionType = lat_Input then
    begin
      case Result.EventState of
        evs_InValid :
          begin
            if IoPinState then
            begin
              Result.FIsDirty := True;
              Result.EventState := evs_Valid;
              LogicActionsUpdate(Result);
            end;
          end;
        evs_Valid :
          begin
            if not IoPinState then
            begin
              Result.FIsDirty := True;
              Result.EventState := evs_InValid;
              LogicActionsUpdate(Result);
            end;
          end;
        evs_Unknown :
          begin
            Result.FIsDirty := True;
            if IoPinState then
              Result.EventState := evs_Valid
            else
              Result.EventState := evs_InValid;
            LogicActionsUpdate(Result);
          end;
      end;
    end
  end;
end;

procedure TLccSdnController.InternalExport(XmlDoc: LccXmlDocument);
var
  RootNode, ChildNode, ExternalsNode, ObjectNode, ActionGroupNode, InputsNode, ActionNode, OutputsNode, LogicNode, DistrictNode: LccXmlNode;
  i, iObjects, iActionGroups, iActions, iLogicActions, iDistrict: Integer;
begin
  RootNode := XmlCreateRootNode(XmlDoc, 'sdn', '');

  ChildNode := XmlCreateChildNode(XmlDoc, RootNode, 'ioboard', '');
  XmlAttributeForce(XmlDoc, ChildNode, 'inputs', IntToStr(AvailableIoInputs));
  XmlAttributeForce(XmlDoc, ChildNode, 'outputs', IntToStr(AvailableIoOutput));

  ExternalsNode := XmlCreateChildNode(XmlDoc, RootNode, 'externals', '');
  for i := 0 to Externals.Count - 1 do
    XmlCreateChildNode(XmlDoc, ExternalsNode, 'name', Externals[i]);

  for iDistrict := 0 to LccDistricts.Count - 1 do
  begin
    DistrictNode := XmlCreateChildNode(XmlDoc, RootNode, 'district', '');
    if LccDistricts[iDistrict].Name <> '' then
      ChildNode := XmlCreateChildNode(XmlDoc, DistrictNode, 'name', LccDistricts[iDistrict].Name);
    if LccDistricts[iDistrict].Description <> '' then
      ChildNode := XmlCreateChildNode(XmlDoc, DistrictNode, 'description', LccDistricts[iDistrict].Description);

    for iObjects := 0 to LccDistricts[iDistrict].LccObjects.Count - 1 do
    begin
      ObjectNode := XmlCreateChildNode(XmlDoc, DistrictNode, 'object', '');
      if LccDistricts[iDistrict].LccObjects[iObjects].LccClass <> '' then
        XmlAttributeForce(XmlDoc, ObjectNode, 'class', (LccDistricts[iDistrict].LccObjects[iObjects].LccClass));
      if LccDistricts[iDistrict].LccObjects[iObjects].Name <> '' then
        ChildNode := XmlCreateChildNode(XmlDoc, ObjectNode, 'name', LccDistricts[iDistrict].LccObjects[iObjects].Name);
      if LccDistricts[iDistrict].LccObjects[iObjects].Description <> '' then
        ChildNode := XmlCreateChildNode(XmlDoc, ObjectNode, 'description', LccDistricts[iDistrict].LccObjects[iObjects].Description);

      InputsNode := XmlCreateChildNode(XmlDoc, ObjectNode, 'inputs', '');
      for iActionGroups := 0 to LccDistricts[iDistrict].LccObjects[iObjects].InputActionGroups.Count - 1 do
      begin
        ActionGroupNode := XmlCreateChildNode(XmlDoc, InputsNode, 'actiongroup', '');
        XmlAttributeForce(XmlDoc, ActionGroupNode, 'class', (LccDistricts[iDistrict].LccObjects[iObjects].InputActionGroups[iActionGroups].LccClass));
        for iActions := 0 to LccDistricts[iDistrict].LccObjects[iObjects].InputActionGroups[iActionGroups].Actions.Count - 1 do
        begin
          ActionNode := XmlCreateChildNode(XmlDoc, ActionGroupNode, 'actions', '');
          XmlAttributeForce(XmlDoc, ActionNode, 'eventidlo', StringReplace( EventIDToString(LccDistricts[iDistrict].LccObjects[iObjects].InputActionGroups[iActionGroups].Actions[iActions].EventIDLo, True), NodeIDToString(NodeID, True), '{$NODEID}', [rfReplaceAll, rfIgnoreCase]));
          XmlAttributeForce(XmlDoc, ActionNode, 'eventidhi', StringReplace( EventIDToString(LccDistricts[iDistrict].LccObjects[iObjects].InputActionGroups[iActionGroups].Actions[iActions].EventIDHi, True), NodeIDToString(NodeID, True), '{$NODEID}', [rfReplaceAll, rfIgnoreCase]));
          XmlAttributeForce(XmlDoc, ActionNode, 'eventstate', EventStateToAttribString(LccDistricts[iDistrict].LccObjects[iObjects].InputActionGroups[iActionGroups].Actions[iActions].EventState));
          XmlAttributeForce(XmlDoc, ActionNode, 'iopin', IntToStr(LccDistricts[iDistrict].LccObjects[iObjects].InputActionGroups[iActionGroups].Actions[iActions].IoPin));
          XmlCreateChildNode(XmlDoc, ActionNode, 'name', LccDistricts[iDistrict].LccObjects[iObjects].InputActionGroups[iActionGroups].Actions[iActions].Name);
          XmlCreateChildNode(XmlDoc, ActionNode, 'description', LccDistricts[iDistrict].LccObjects[iObjects].InputActionGroups[iActionGroups].Actions[iActions].Description);
        end;
      end;

      OutputsNode := XmlCreateChildNode(XmlDoc, ObjectNode, 'outputs', '');
      for iActionGroups := 0 to LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups.Count - 1 do
      begin
        ActionGroupNode := XmlCreateChildNode(XmlDoc, OutputsNode, 'actiongroup', '');
        XmlAttributeForce(XmlDoc, ActionGroupNode, 'class', (LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].LccClass));
        for iActions := 0 to LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions.Count - 1 do
        begin
          ActionNode := XmlCreateChildNode(XmlDoc, ActionGroupNode, 'actions', '');
          XmlAttributeForce(XmlDoc, ActionNode, 'eventidlo', StringReplace( EventIDToString(LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].EventIDLo, True), NodeIDToString(NodeID, True), '{$NODEID}', [rfReplaceAll, rfIgnoreCase]));
          XmlAttributeForce(XmlDoc, ActionNode, 'eventidhi', StringReplace( EventIDToString(LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].EventIDHi, True), NodeIDToString(NodeID, True), '{$NODEID}', [rfReplaceAll, rfIgnoreCase]));
          XmlAttributeForce(XmlDoc, ActionNode, 'eventstate', EventStateToAttribString(LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].EventState));
          XmlAttributeForce(XmlDoc, ActionNode, 'iopin', IntToStr(LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].IoPin));
          ChildNode := XmlCreateChildNode(XmlDoc, ActionNode, 'name', LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].Name);
          LogicNode := XmlCreateChildNode(XmlDoc, ActionNode, 'logic', '');
          for iLogicActions := 0 to LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].Logic.Actions.Count - 1 do
          begin
            ChildNode := XmlCreateChildNode(XmlDoc, LogicNode, 'actions', '');
            // Don't save the state of the linked event as we don't know what it will be on reboot
            XmlAttributeForce(XmlDoc, ChildNode, 'eventidlo', StringReplace( EventIDToString(LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].Logic.Actions[iLogicActions].EventIDLoLinked, True), NodeIDToString(NodeID, True), '{$NODEID}', [rfReplaceAll, rfIgnoreCase]));
            XmlAttributeForce(XmlDoc, ChildNode, 'eventidhi', StringReplace( EventIDToString(LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].Logic.Actions[iLogicActions].EventIDHiLinked, True), NodeIDToString(NodeID, True), '{$NODEID}', [rfReplaceAll, rfIgnoreCase]));
            XmlAttributeForce(XmlDoc, ChildNode, 'truestate', LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].Logic.Actions[iLogicActions].LogicTrueStateName);
            if LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].Logic.Actions[iLogicActions].Inverted then
              XmlAttributeForce(XmlDoc, ChildNode, 'inverted', BooleanToString( LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].Logic.Actions[iLogicActions].Inverted));
            XmlCreateChildNode(XmlDoc, ChildNode, 'name', LccDistricts[iDistrict].LccObjects[iObjects].OutputActionGroups[iActionGroups].Actions[iActions].Logic.Actions[iLogicActions].LinkedName);
          end;
        end;
      end;
    end;
  end;
end;

procedure TLccSdnController.InternalParse;
var
  RootNode, ObjectChildNode, ExternalsNode, ActionGroupNode, ActionNode, LogicNode, LogicActionNode, ChildNode, DistrictNode, DistrictChildNode: LccXmlNode;
  Attrib: string;
  LccObject: TLccObject;
  LccAction: TLccBinaryAction;
  LccActionGroup: TLccActionGroup;
  LccLogicAction: TLccLogicAction;
  LccDistrictObject: TLccDistrict;
begin
  Externals.Clear;
  FAvailableIoInput := 0;
  FAvailableIoOutput := 0;
  LccDistricts.Clear;

  RootNode := XmlFindRootNode(XmlDocument, 'sdn');
  if Assigned(RootNode) then
  begin
    FVersion := XmlAttributeRead(RootNode, 'version');

    // Load information about the IO board
    ObjectChildNode := XmlFindChildNode(RootNode, 'ioboard');
    if Assigned(ObjectChildNode) then
    begin
       FAvailableIoInput := StrToInt(XmlAttributeRead(ObjectChildNode, 'inputs'));
       FAvailableIoOutput := StrToInt(XmlAttributeRead(ObjectChildNode, 'outputs'));
    end;

    // Load the External Event Names we need for this SDN
    ExternalsNode := XmlFindChildNode(RootNode, 'externals');
    if Assigned(ExternalsNode) then
    begin
      ObjectChildNode := XmlFirstChild(ExternalsNode);
      while Assigned(ObjectChildNode) do
      begin
        if XmlNodeName(ObjectChildNode) = 'name' then
          Externals.Add(XmlNodeTextContent(ObjectChildNode));
        ObjectChildNode := XmlNextSiblingNode(ObjectChildNode);
      end;
    end;

    // Load the input action information
    DistrictNode := XmlFindChildNode(RootNode, 'district');
    while Assigned(DistrictNode) do
    begin
      LccDistrictObject := TLccDistrict.Create;
      LccDistrictObject.LccClass := XmlAttributeRead(DistrictNode, 'class');
      LccDistricts.Add(LccDistrictObject);
      DistrictChildNode := XmlFirstChild(DistrictNode);
      while Assigned(DistrictChildNode) do
      begin
        if XmlNodeName(DistrictChildNode) = 'name' then
          LccDistrictObject.Name := XmlNodeTextContent(DistrictChildNode)
        else
        if XmlNodeName(DistrictChildNode) = 'description' then
          LccDistrictObject.Description := XmlNodeTextContent(DistrictChildNode)
        else
        if XmlNodeName(DistrictChildNode) = 'object' then
        begin
          LccObject := TLccObject.Create;
          LccDistrictObject.LccObjects.Add(LccObject);
          LccObject.LccClass := XmlAttributeRead(DistrictChildNode, 'class');
          ObjectChildNode := XmlFirstChild(DistrictChildNode);
          while Assigned(ObjectChildNode) do
          begin
            if XmlNodeName(ObjectChildNode) = 'name' then
              LccObject.Name := XmlNodeTextContent(ObjectChildNode)
            else
            if XmlNodeName(ObjectChildNode) = 'description' then
              LccObject.Description := XmlNodeTextContent(ObjectChildNode)
            else
            if XmlNodeName(ObjectChildNode) = 'inputs' then
            begin
              ActionGroupNode := XmlFirstChild(ObjectChildNode);
              while Assigned(ActionGroupNode) do
              begin
                LccActionGroup := TLccActionGroup.Create;
                LccActionGroup.LccClass := XmlAttributeRead(ActionGroupNode, 'class');
                LccObject.InputActionGroups.Add(LccActionGroup);
                ActionNode := XmlFirstChild(ActionGroupNode);
                while Assigned(ActionNode) do
                begin
                  LccAction := TLccBinaryAction.Create(lat_Input);
                  LccActionGroup.Actions.Add(LccAction);
                  Actions.Add(LccAction);
                  LccAction.Producer := True;
                  Attrib := XmlAttributeRead(ActionNode, 'eventidlo');
                  if Attrib <> '' then
                    LccAction.EventIDLo := StrToEventID(StringReplace(Attrib, '{$NODEID}', NodeIDToString(NodeID, True), [rfReplaceAll, rfIgnoreCase]));
                  Attrib := XmlAttributeRead(ActionNode, 'eventidhi');
                  if Attrib <> '' then
                    LccAction.EventIDHi := StrToEventID(StringReplace(Attrib, '{$NODEID}', NodeIDToString(NodeID, True), [rfReplaceAll, rfIgnoreCase]));
                  Attrib := XmlAttributeRead(ActionNode, 'eventstate');
                  LccAction.EventState := AttribStringToEventState(Attrib);
                  Attrib := XmlAttributeRead(ActionNode, 'iopin');
                  if Attrib <> '' then
                    LccAction.IoPin := StrToInt(Attrib);
                  ChildNode := XmlFindChildNode(ActionNode, 'name');
                  if Assigned(ChildNode) then
                    LccAction.Name := XmlNodeTextContent(ChildNode);
                  ChildNode := XmlFindChildNode(ActionNode, 'description');
                  if Assigned(ChildNode) then
                    LccAction.Description := XmlNodeTextContent(ChildNode);
                  ActionNode := XmlNextSiblingNode(ActionNode);
                end;
                ActionGroupNode := XmlNextSiblingNode(ActionGroupNode);
              end;
            end else
            if XmlNodeName(ObjectChildNode) = 'outputs' then
            begin
              ActionGroupNode := XmlFirstChild(ObjectChildNode);
              while Assigned(ActionGroupNode) do
              begin
                LccActionGroup := TLccActionGroup.Create;
                LccActionGroup.LccClass := XmlAttributeRead(ActionGroupNode, 'class');
                LccObject.OutputActionGroups.Add(LccActionGroup);
                ActionNode := XmlFirstChild(ActionGroupNode);
                while Assigned(ActionNode) do
                begin
                  LccAction := TLccBinaryAction.Create(lat_Output);
                  LccActionGroup.Actions.Add(LccAction);
                  Actions.Add(LccAction);
                  LccAction.Consumer := True;
                  Attrib := XmlAttributeRead(ActionNode, 'eventidlo');
                  if Attrib <> '' then
                    LccAction.EventIDLo := StrToEventID(StringReplace(Attrib, '{$NODEID}', NodeIDToString(NodeID, True), [rfReplaceAll, rfIgnoreCase]));
                  Attrib := XmlAttributeRead(ActionNode, 'eventidhi');
                  if Attrib <> '' then
                    LccAction.EventIDHi := StrToEventID(StringReplace(Attrib, '{$NODEID}', NodeIDToString(NodeID, True), [rfReplaceAll, rfIgnoreCase]));
                  Attrib := XmlAttributeRead(ActionNode, 'state');
                  LccAction.EventState := AttribStringToEventState(Attrib);
                  Attrib := XmlAttributeRead(ActionNode, 'iopin');
                  if Attrib <> '' then
                    LccAction.IoPin := StrToInt(Attrib);

                  ChildNode := XmlFindChildNode(ActionNode, 'name');
                  if Assigned(ChildNode) then
                    LccAction.Name := XmlNodeTextContent(ChildNode);
                  LogicNode := XmlFindChildNode(ActionNode, 'logic');
                  if Assigned(LogicNode) then
                  begin
                    LogicActionNode := XmlFindChildNode(LogicNode, 'action');
                    while Assigned(LogicActionNode) do
                    begin
                      LccLogicAction := TLccLogicAction.Create;
                      LccAction.Logic.Actions.Add(LccLogicAction);
                      ChildNode := XmlFindChildNode(LogicActionNode, 'name');
                      if Assigned(ChildNode) then
                        LccLogicAction.LinkedName := XmlNodeTextContent(ChildNode);
                      // Don't save or restore the state of the linked action, don't know what it will be
                      Attrib := XmlAttributeRead(LogicActionNode, 'eventidlo');
                      if Attrib <> '' then
                        LccLogicAction.EventIDLoLinked := StrToEventID(StringReplace(Attrib, '{$NODEID}', NodeIDToString(NodeID, True), [rfReplaceAll, rfIgnoreCase]));
                      Attrib := XmlAttributeRead(LogicActionNode, 'eventidhi');
                      if Attrib <> '' then
                        LccLogicAction.EventIDHiLinked := StrToEventID(StringReplace(Attrib, '{$NODEID}', NodeIDToString(NodeID, True), [rfReplaceAll, rfIgnoreCase]));
                      Attrib := XmlAttributeRead(LogicActionNode, 'truestate');
                      LccLogicAction.LogicTrueStateName := Attrib;
                      LccLogicAction.LogicTrueState := AttribStringToEventState(Attrib);
                      Attrib := XmlAttributeRead(LogicActionNode, 'inverted');
                      if Attrib <> '' then
                        LccLogicAction.Inverted := InValidDictionary(Attrib);
                      LogicActionNode := XmlNextSiblingNode(LogicActionNode);
                    end;
                  end;
                  ActionNode := XmlNextSiblingNode(ActionNode);
                end;
                ActionGroupNode := XmlNextSiblingNode(ActionGroupNode);
              end;
            end;
            ObjectChildNode := XmlNextSiblingNode(ObjectChildNode);
          end;
        end;
         DistrictChildNode := XmlNextSiblingNode(DistrictChildNode);
      end;
      DistrictNode := XmlNextSiblingNode(DistrictNode);
    end;
  end;
end;

function TLccSdnController.InValidDictionary(Value: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  i := 0;
  Value := LowerCase(Value);
  while (i < Length(VALID_DICTIONARY)) and not Result do
  begin
    Result := Value = VALID_DICTIONARY[i];
    Inc(i);
  end;
end;

function TLccSdnController.XMLParse(AFilePath: string): Boolean;
begin
  Result := False;
  try
    if FileExists(AFilePath) then
    begin
      FXmlDocument := XmlLoadFromFile(AFilePath);
      if Assigned(XmlDocument) then
        InternalParse;
    end;
  except
    Result := False
  end;
end;

function TLccSdnController.SupportsConsumed(var Event: TEventID; var Action: TLccBinaryAction): TSupportsEventType;
var
  i: Integer;
  LocalAction: TLccBinaryAction;
begin
  Result := set_None;
  Action := nil;
  for i := 0 to Actions.Count - 1 do
  begin
    LocalAction := Actions[i];
    if LocalAction.ActionType = lat_Output then
    begin
      if EqualEventID(LocalAction.FEventIDLo, Event) then
      begin
        Action := LocalAction;
        Result := set_LoEventID;
        Exit;
      end;
      if EqualEventID(LocalAction.FEventIDHi, Event) then
      begin
        Action := LocalAction;
        Result := set_HiEventID;
        Exit;
      end;
    end;
  end;
end;

function TLccSdnController.SupportsProduced(var Event: TEventID; var Action: TLccBinaryAction): TSupportsEventType;
var
  i: Integer;
  LocalAction: TLccBinaryAction;
begin
  Result := set_None;
  Action := nil;
  for i := 0 to Actions.Count - 1 do
  begin
    LocalAction := Actions[i];
    if LocalAction.ActionType = lat_Input then
    begin
      if EqualEventID(LocalAction.FEventIDLo, Event) then
      begin
        Action := LocalAction;
        Result := set_LoEventID;
        Exit;
      end;
      if EqualEventID(LocalAction.FEventIDHi, Event) then
      begin
        Action := LocalAction;
        Result := set_HiEventID;
        Exit;
      end;
    end;
  end;
end;

function TLccSdnController.AttribStringToEventState(EventState: string): TEventState;
begin
  if InValidDictionary(EventState) then
    Result := evs_Valid
  else
   if InInValidDictionary(EventState) then
    Result := evs_InValid
  else
    Result := evs_Unknown;
end;

end.

