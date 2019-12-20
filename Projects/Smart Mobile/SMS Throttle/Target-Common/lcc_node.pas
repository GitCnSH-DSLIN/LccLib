unit lcc_node;

interface

uses
{$IFDEF DWSCRIPT}
  System.Types,
  System.Types.Convert,
  System.Time,
  System.Streams,
  System.Reader,
  System.Writer,
  System.Lists,
  System.Device.Storage,
  SmartCL.Device.Storage,
  SmartCL.Application,
  SmartCL.Components,
  SmartCL.System,
{$ELSE}
  Classes,
  SysUtils,
  ExtCtrls,
{$ENDIF}
  lcc_defines,
  lcc_node_messages,
  lcc_utilities,
//  lcc_protocol_traction,
//  lcc_protocol_traction_simpletrainnodeinfo,
//  lcc_protocol_traction_configuruation_functiondefinitioninfo,
//  lcc_protocol_traction_configuration_functions,
  lcc_protocol_memory_configuration,
  lcc_protocol_memory_configurationdefinitioninfo,
  lcc_protocol_memory_options,
  lcc_protocol_memory_information,
  lcc_protocol_simplenodeinfo,
  lcc_protocol_acdi,
  lcc_protocol_events,
  lcc_protocol_supportedprotocols,
  lcc_protocol_datagram,
  lcc_protocol_base;

const
  ERROR_CONFIGMEM_ADDRESS_SPACE_MISMATCH = $0001;

type

{ TLccNode }

TLccNode = class(TNodeProtocolBase)
private
  FDatagramWorkerMessage: TLccMessage;
  FInitialized: Boolean;
  FTProtocolMemoryConfigurationDefinitionInfo: TProtocolMemoryConfigurationDefinitionInfo;
  FProtocolMemoryOptions: TProtocolMemoryOptions;
  FMemoryConfiguration: TProtocolMemoryConfiguration;
  FProtocolEventConsumed: TProtocolEvents;
  FProtocolEventsProduced: TProtocolEvents;
  FProtocolSupportedProtocols: TProtocolSupportedProtocols;
  FProtocolSimpleNodeInfo: TProtocolSimpleNodeInfo;
  FProtocolMemoryInfo: TProtocolMemoryInfo;
  FACDIMfg: TACDIMfg;
  FACDIUser: TACDIUser;
  FDatagramQueue: TDatagramQueue;
  {$IFDEF DWSCRIPT}
    F_800msTimer: TW3Timer;
  {$ELSE}
    {$IFNDEF FPC_CONSOLE_APP}
    F_800msTimer: TTimer;
    {$ELSE}
    F_800msTimer: TFPTimer;
    {$ENDIF}
  {$ENDIF}

  function GetNodeIDStr: String;
protected
  FNodeID: TNodeID;

  property DatagramWorkerMessage: TLccMessage read FDatagramWorkerMessage write FDatagramWorkerMessage;
  {$IFDEF DWSCRIPT}
    property _800msTimer: TW3Timer read F_800msTimer write F_800msTimer;
  {$ELSE}
    {$IFNDEF FPC_CONSOLE_APP}
    property _800msTimer: TTimer read F_800msTimer write F_800msTimer;
    {$ELSE}
    property _800msTimer: TFPTimer read F_800msTimer write F_800msTimer;
    {$ENDIF}
  {$ENDIF}

  function GetAlias: Word; virtual;
  function IsDestinationEqual(LccMessage: TLccMessage): Boolean; virtual;
  procedure AutoGenerateEvents;
  procedure SendDatagramAckReply(SourceLccMessage: TLccMessage; ReplyPending: Boolean; TimeOutValueN: Byte);
  procedure SendDatagramRejectedReply(SourceLccMessage: TLccMessage);
  procedure SendDatagramRequiredReply(SourceLccMessage, ReplyLccMessage: TLccMessage);
  procedure On_800msTimer(Sender: TObject);  virtual;
public
  property DatagramQueue: TDatagramQueue read FDatagramQueue;
  property NodeID: TNodeID read FNodeID;
  property NodeIDStr: String read GetNodeIDStr;
  property Initialized: Boolean read FInitialized;

  property ACDIMfg: TACDIMfg read FACDIMfg write FACDIMfg;
  property ACDIUser: TACDIUser read FACDIUser write FACDIUser;
  property ProtocolMemoryConfiguration: TProtocolMemoryConfiguration read FMemoryConfiguration write FMemoryConfiguration;
  property ProtocolConfigurationDefinitionInfo: TProtocolMemoryConfigurationDefinitionInfo read FTProtocolMemoryConfigurationDefinitionInfo write FTProtocolMemoryConfigurationDefinitionInfo;
  property ProtocolMemoryOptions: TProtocolMemoryOptions read FProtocolMemoryOptions write FProtocolMemoryOptions;
  property ProtocolMemoryInfo: TProtocolMemoryInfo read FProtocolMemoryInfo write FProtocolMemoryInfo;
  property ProtocolEventConsumed: TProtocolEvents read FProtocolEventConsumed write FProtocolEventConsumed;
  property ProtocolEventsProduced: TProtocolEvents read FProtocolEventsProduced write FProtocolEventsProduced;
  property ProtocolSupportedProtocols: TProtocolSupportedProtocols read FProtocolSupportedProtocols write FProtocolSupportedProtocols;
  property ProtocolSimpleNodeInfo: TProtocolSimpleNodeInfo read FProtocolSimpleNodeInfo write FProtocolSimpleNodeInfo;

  constructor Create(ASendMessageFunc: TLccSendMessageFunc); override;
  destructor Destroy; override;

  function IsNode(ALccMessage: TLccMessage; TestType: TIsNodeTestType): Boolean; virtual;
  procedure Login(ANodeID: TNodeID); virtual;
  procedure Logout; virtual;
  function ProcessMessage(SourceLccMessage: TLccMessage): Boolean; override;
  procedure SendEvents;
  procedure SendConsumedEvents;
  procedure SendConsumerIdentify(var Event: TEventID);
  procedure SendProducedEvents;
  procedure SendProducerIdentify(var Event: TEventID);
  procedure SendInitializeComplete;
end;

{ TLccCanNode }

TLccCanNode = class(TLccNode)
private
  FAliasID: Word;
  FDuplicateAliasDetected: Boolean;
  FSeedNodeID: TNodeID;
  FPermitted: Boolean;

  function GetAliasIDStr: String;
protected
  property DuplicateAliasDetected: Boolean read FDuplicateAliasDetected write FDuplicateAliasDetected;
  property SeedNodeID: TNodeID read FSeedNodeID write FSeedNodeID;

  procedure CreateNodeID(var Seed: TNodeID);
  function GetAlias: Word; override;
  function GenerateID_Alias_From_Seed(var Seed: TNodeID): Word;
  procedure GenerateNewSeed(var Seed: TNodeID);
  function IsDestinationEqual(LccMessage: TLccMessage): Boolean; override;
  procedure On_800msTimer(Sender: TObject); override;
  procedure Relogin;
  procedure SendAMD;
  procedure SendAMR;
public
   property AliasID: Word read FAliasID;
   property AliasIDStr: String read GetAliasIDStr;
   property Permitted: Boolean read FPermitted;

   constructor Create(ASendMessageFunc: TLccSendMessageFunc); override;
   destructor Destroy; override;
   function IsNode(ALccMessage: TLccMessage; TestType: TIsNodeTestType): Boolean; override;
   procedure Login(ANodeID: TNodeID); override;
   procedure Logout; override;
   function ProcessMessage(SourceLccMessage: TLccMessage): Boolean; override;
end;

implementation

const
  STR_SENDMESSAGENIL = 'SendMessage Function is nil';

{ TLccCanNode }

constructor TLccCanNode.Create(ASendMessageFunc: TLccSendMessageFunc);
begin
  inherited Create(ASendMessageFunc);
end;

destructor TLccCanNode.Destroy;
begin
  if Permitted then
  begin
    WorkerMessage.LoadAMR(NodeID, AliasID);
    SendMessageFunc(WorkerMessage);
  end;
  inherited Destroy;
end;

function TLccCanNode.GetAliasIDStr: String;
begin
   Result := '0x' + IntToHex(FAliasID, 4);
end;

function TLccCanNode.IsDestinationEqual(LccMessage: TLccMessage): Boolean;
begin
  Result := AliasID = LccMessage.CAN.DestAlias;
end;

function TLccCanNode.IsNode(ALccMessage: TLccMessage; TestType: TIsNodeTestType): Boolean;
begin
  Result := False;
  if TestType = ntt_Dest then
  begin
    if (AliasID <> 0) and (ALccMessage.CAN.DestAlias <> 0) then
      Result := AliasID = ALccMessage.CAN.DestAlias
  end else
  if TestType = ntt_Source then
  begin
    if (AliasID <> 0) and (ALccMessage.CAN.SourceAlias <> 0) then
      Result := AliasID = ALccMessage.CAN.SourceAlias
  end;
end;

procedure TLccCanNode.Login(ANodeID: TNodeID);
var
  Temp: TNodeID;
begin
  if NullNodeID(ANodeID) then
    CreateNodeID(ANodeID);
  SeedNodeID := ANodeID;
  Temp := FSeedNodeID;
  FAliasID := GenerateID_Alias_From_Seed(Temp);
  FNodeID := ANodeID;

//  Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
  WorkerMessage.LoadCID(NodeID, AliasID, 0);
  SendMessageFunc(WorkerMessage);
  WorkerMessage.LoadCID(NodeID, AliasID, 1);
  SendMessageFunc(WorkerMessage);
  WorkerMessage.LoadCID(NodeID, AliasID, 2);
  SendMessageFunc(WorkerMessage);
  WorkerMessage.LoadCID(NodeID, AliasID, 3);
  SendMessageFunc(WorkerMessage);

  _800msTimer.Enabled := True;  //  Next state is in the event handler to see if anyone objects tor our Alias
end;

procedure TLccCanNode.Logout;
begin
  SendAMR;
  FPermitted := False;
  inherited Logout;
end;

procedure TLccCanNode.On_800msTimer(Sender: TObject);
var
  Temp: TNodeID;
begin
 // Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);

  if not Permitted then
  begin
     // Did any node object to this Alias through ProcessMessage?
    if DuplicateAliasDetected then
    begin
      Temp := FSeedNodeID;
      GenerateNewSeed(Temp);     // DWSCRIPT Forced
      FSeedNodeID := Temp;
      FAliasID := GenerateID_Alias_From_Seed(Temp);
      WorkerMessage.LoadCID(NodeID, AliasID, 0);
      SendMessageFunc(WorkerMessage);
      WorkerMessage.LoadCID(NodeID, AliasID, 1);
      SendMessageFunc(WorkerMessage);
      WorkerMessage.LoadCID(NodeID, AliasID, 2);
      SendMessageFunc(WorkerMessage);
      WorkerMessage.LoadCID(NodeID, AliasID, 3);
      SendMessageFunc(WorkerMessage);
    end else
    begin
      FPermitted := True;
      WorkerMessage.LoadRID(AliasID);
      SendMessageFunc(WorkerMessage);
      WorkerMessage.LoadAMD(NodeID, AliasID);
      SendMessageFunc(WorkerMessage);
      inherited Login(NodeID);
    end
  end;
  if Permitted then
    inherited On_800msTimer(Sender);
end;

function TLccCanNode.ProcessMessage(SourceLccMessage: TLccMessage): Boolean;
var
  TestNodeID: TNodeID;
begin
  Result := False;

//  Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);

  if (AliasID <> 0) and (SourceLccMessage.CAN.SourceAlias = AliasID) then
  begin
    if ((SourceLccMessage.CAN.MTI and $0F000000) >= MTI_CAN_CID6) and ((SourceLccMessage.CAN.MTI and $0F000000) <= MTI_CAN_CID0) then
    begin
      WorkerMessage.LoadRID(AliasID);                   // sorry charlie this is mine
      SendMessageFunc(WorkerMessage);
      Result := True;
    end else
    if Permitted then
    begin
      Logout;
      Relogin;
      Result := True;   // Logout covers any LccNode logoffs, so don't call ancester Process Message
    end
  end;

  if not Permitted then
  begin
    if SourceLccMessage.CAN.SourceAlias = AliasID then
      DuplicateAliasDetected := True;
  end else
  begin
    TestNodeID[0] := 0;
    TestNodeID[1] := 0;
    if SourceLccMessage.IsCAN then
    begin
      case SourceLccMessage.CAN.MTI of
        MTI_CAN_AME :          // Alias Map Enquiry
          begin
            if SourceLccMessage.DataCount = 6 then
            begin
              SourceLccMessage.ExtractDataBytesAsNodeID(0, TestNodeID);
              if EqualNodeID(TestNodeID, NodeID, False) then
              begin
                WorkerMessage.LoadAMD(NodeID, AliasID);
                SendMessageFunc(WorkerMessage);
              end
            end else
            begin
              WorkerMessage.LoadAMD(NodeID, AliasID);
              SendMessageFunc(WorkerMessage);
            end;
            Result := True;
          end;
      end
    end;
    if not Result then
      Result := inherited ProcessMessage(SourceLccMessage);
  end;
end;

procedure TLccCanNode.Relogin;
var
  Temp: TNodeID;
begin
  // Typically due to an alias conflict to create a new one
  Temp := FSeedNodeID;
  GenerateNewSeed(Temp);   // DWSCRIPT forced
  FSeedNodeID := Temp;
  FAliasID := GenerateID_Alias_From_Seed(Temp);

 // Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
  WorkerMessage.LoadCID(NodeID, AliasID, 0);
  SendMessageFunc(WorkerMessage);
  WorkerMessage.LoadCID(NodeID, AliasID, 1);
  SendMessageFunc(WorkerMessage);
  WorkerMessage.LoadCID(NodeID, AliasID, 2);
  SendMessageFunc(WorkerMessage);
  WorkerMessage.LoadCID(NodeID, AliasID, 3);
  SendMessageFunc(WorkerMessage);

  _800msTimer.Enabled := True;  //  Next state is in the event handler to see if anyone objects tor our Alias
end;

function TLccCanNode.GenerateID_Alias_From_Seed(var Seed: TNodeID): Word;
begin
  Result := (Seed[0] xor Seed[1] xor (Seed[0] shr 12) xor (Seed[1] shr 12)) and $00000FFF;
end;

procedure TLccCanNode.CreateNodeID(var Seed: TNodeID);
begin
  Randomize;
  Seed[1] := StrToInt('0x020112');
  {$IFDEF DWSCRIPT}
  Seed[0] := RandomInt($FFFFFF);
  {$ELSE}
  Seed[0] := Random($FFFFFF);
  {$ENDIF}
end;

procedure TLccCanNode.GenerateNewSeed(var Seed: TNodeID);
var
  temp1,              // Upper 24 Bits of temp 48 bit number
  temp2: DWORD;       // Lower 24 Bits of temp 48 Bit number
begin
  temp1 := ((Seed[1] shl 9) or ((Seed[0] shr 15) and $000001FF)) and $00FFFFFF;   // x(i+1)(2^9 + 1)*x(i) + C  = 2^9 * x(i) + x(i) + C
  temp2 := (Seed[0] shl 9) and $00FFFFFF;                                                                  // Calculate 2^9 * x

  Seed[0] := Seed[0] + temp2 + $7A4BA9;   // Now y = 2^9 * x so all we have left is x(i+1) = y + x + c
  Seed[1] := Seed[1] + temp1 + $1B0CA3;

  Seed[1] := (Seed[1] and $00FFFFFF) or (Seed[0] and $FF000000) shr 24;   // Handle the carries of the lower 24 bits into the upper
  Seed[0] := Seed[0] and $00FFFFFF;
end;

function TLccCanNode.GetAlias: Word;
begin
  Result := AliasID;
end;

procedure TLccCanNode.SendAMD;
begin
  if Permitted then
  begin
    WorkerMessage.LoadAMD(NodeID, AliasID);
 //   Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
    SendMessageFunc(WorkerMessage);
  end;
end;

procedure TLccCanNode.SendAMR;
begin
  if Permitted then
  begin
    FPermitted := False;
    WorkerMessage.LoadAMR(NodeID, AliasID);
 //   Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
    SendMessageFunc(WorkerMessage);
  end;
end;



{TLccNode }

function TLccNode.GetNodeIDStr: String;
begin
 Result := IntToHex(NodeID[1], 6);
 Result := Result + IntToHex(NodeID[0], 6);
 Result := '0x' + Result
end;

function TLccNode.IsDestinationEqual(LccMessage: TLccMessage): Boolean;
begin
  Result := EqualNodeID(NodeID, LccMessage.DestID, False);
end;

function TLccNode.IsNode(ALccMessage: TLccMessage; TestType: TIsNodeTestType): Boolean;
begin
  Result := False;
  if TestType = ntt_Dest then
  begin
    if ALccMessage.HasDestNodeID and not NullNodeID(NodeID) then
      Result := ((NodeID[0] = ALccMessage.DestID[0]) and (NodeID[1] = ALccMessage.DestID[1]))
  end else
  if TestType = ntt_Source then
  begin
    if ALccMessage.HasSourceNodeID and not NullNodeID(NodeID) then
      Result := ((NodeID[0] = ALccMessage.SourceID[0]) and (NodeID[1] = ALccMessage.SourceID[1]))
  end;
end;

constructor TLccNode.Create(ASendMessageFunc: TLccSendMessageFunc);
begin
  inherited Create(ASendMessageFunc);
  FProtocolSupportedProtocols := TProtocolSupportedProtocols.Create(ASendMessageFunc);
  FProtocolSimpleNodeInfo := TProtocolSimpleNodeInfo.Create(ASendMessageFunc);
  FTProtocolMemoryConfigurationDefinitionInfo := TProtocolMemoryConfigurationDefinitionInfo.Create(ASendMessageFunc, MSI_CDI, True);
  FProtocolMemoryOptions := TProtocolMemoryOptions.Create(ASendMessageFunc);
  FMemoryConfiguration := TProtocolMemoryConfiguration.Create(SendMessageFunc, MSI_CONFIG, False);
  FProtocolMemoryInfo := TProtocolMemoryInfo.Create(ASendMessageFunc);
 //JDK FConfigurationMem := TConfigurationMemory.Create(ASendMessageFunc);
  FProtocolEventConsumed := TProtocolEvents.Create(ASendMessageFunc);
  FProtocolEventsProduced := TProtocolEvents.Create(ASendMessageFunc);
  FACDIMfg := TACDIMfg.Create(nil, MSI_ACDI_MFG, True);
  FACDIUser := TACDIUser.Create(SendMessageFunc, MSI_ACDI_USER, True);

  FDatagramQueue := TDatagramQueue.Create(SendMessageFunc);
  FDatagramWorkerMessage := TLccMessage.Create;

  {$IFDEF DWSCRIPT}
  _800msTimer := TW3Timer.Create(nil);
  _800msTimer.Enabled := False;
  _800msTimer.OnTime := @On_800msTimer;
  _800msTimer.Delay := 800;
  {$ELSE}
    {$IFNDEF FPC_CONSOLE_APP}
    _800msTimer := TTimer.Create(nil);
    {$ELSE}
    _800msTimer := TFPTimer.Create(nil);
    {$ENDIF}
    _800msTimer.Enabled := False;
    _800msTimer.OnTimer := @On_800msTimer;
    _800msTimer.Interval := 800;
  {$ENDIF}
end;

procedure TLccNode.AutoGenerateEvents;
var
  i: Integer;
  TempEventID: TEventID;
begin
  TempEventID := NULL_EVENT_ID;
  if ProtocolEventConsumed.AutoGenerate.Count > 0 then
  begin
    for i := 0 to ProtocolEventConsumed.AutoGenerate.Count - 1 do
    begin
      NodeIDToEventID(NodeID, ProtocolEventConsumed.AutoGenerate.StartIndex + i, TempEventID);
      ProtocolEventConsumed.Add(TempEventID, ProtocolEventConsumed.AutoGenerate.DefaultState);
    end;
    ProtocolEventConsumed.Valid := True;
  end;

  if ProtocolEventsProduced.AutoGenerate.Count > 0 then
  begin
    for i := 0 to ProtocolEventsProduced.AutoGenerate.Count - 1 do
    begin
      NodeIDToEventID(NodeID, ProtocolEventsProduced.AutoGenerate.StartIndex + i, TempEventID);
      ProtocolEventsProduced.Add(TempEventID, ProtocolEventsProduced.AutoGenerate.DefaultState);
    end;
    ProtocolEventsProduced.Valid := True;
  end;
end;

destructor TLccNode.Destroy;
begin
  _800msTimer.Enabled := False;
  _800msTimer.Free;
  FProtocolSupportedProtocols.Free;
  FProtocolSimpleNodeInfo.Free;
  FTProtocolMemoryConfigurationDefinitionInfo.Free;
 //JDK FConfigurationMem.Free;
  FProtocolEventConsumed.Free;
  FProtocolEventsProduced.Free;
  FProtocolMemoryOptions.Free;
  FProtocolMemoryInfo.Free;
  FACDIMfg.Free;
  FACDIUser.Free;
  FMemoryConfiguration.Free;
  FDatagramQueue.Free;
  FDatagramWorkerMessage.Free;
  inherited;
end;

function TLccNode.GetAlias: Word;
begin
  Result := 0;
end;

procedure TLccNode.Login(ANodeID: TNodeID);
begin
  FInitialized := True;
  SendInitializeComplete;
  AutoGenerateEvents;
  SendEvents;
end;

procedure TLccNode.Logout;
begin
 FInitialized := False;
  _800msTimer.Enabled := False;
  DatagramQueue.Clear;
end;

procedure TLccNode.On_800msTimer(Sender: TObject);
begin
  DatagramQueue.TickTimeout;
end;

function TLccNode.ProcessMessage(SourceLccMessage: TLccMessage): Boolean;
var
  TestNodeID: TNodeID;
  Temp: TEventID;
begin
  Result := False;

 // Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);

  TestNodeID[0] := 0;
  TestNodeID[1] := 0;

 // if Initialized then;
  begin
    // First look for a duplicate NodeID
    if EqualNodeID(NodeID, SourceLccMessage.SourceID, False) then
    begin
      Logout;
      Exit;
    end;


    // Next look to see if it is an addressed message and if not for use just exit


    if SourceLccMessage.HasDestination then
    begin
      if not IsDestinationEqual(SourceLccMessage) then
        Exit;
    end;

    case SourceLccMessage.MTI of
      MTI_OPTIONAL_INTERACTION_REJECTED :
          begin
            // TODO need a call back handler
          end;
      MTI_VERIFY_NODE_ID_NUMBER      :
          begin
            if SourceLccMessage.DataCount = 6 then
            begin
              SourceLccMessage.ExtractDataBytesAsNodeID(0, TestNodeID);
              if EqualNodeID(TestNodeID, NodeID, False) then
              begin
                WorkerMessage.LoadVerifiedNodeID(NodeID, GetAlias);
                SendMessageFunc(WorkerMessage);
              end
            end else
            begin
              WorkerMessage.LoadVerifiedNodeID(NodeID, GetAlias);
              SendMessageFunc(WorkerMessage);
            end;
            Result := True;
          end;
      MTI_VERIFY_NODE_ID_NUMBER_DEST :
          begin
            WorkerMessage.LoadVerifiedNodeID(NodeID, GetAlias);
            SendMessageFunc(WorkerMessage);
            Result := True;
          end;
      MTI_VERIFIED_NODE_ID_NUMBER :
          begin
             // TODO need a call back handler
          end;
      MTI_SIMPLE_NODE_INFO_REQUEST :
          begin
            WorkerMessage.LoadSimpleNodeIdentInfoReply(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias, ProtocolSimpleNodeInfo.PackedFormat);
            SendMessageFunc(WorkerMessage);
            Result := True;
          end;
      MTI_SIMPLE_NODE_INFO_REPLY :
          begin  // Called if I send a SNIP and loads the ProtocolSupportedProtocols with the data
            // TODO need a call back handler
            Result := True;
          end;
      MTI_PROTOCOL_SUPPORT_INQUIRY :
          begin
            WorkerMessage.LoadProtocolIdentifyReply(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias, ProtocolSupportedProtocols.EncodeFlags);
            SendMessageFunc(WorkerMessage);
            Result := True;
          end;
      MTI_PROTOCOL_SUPPORT_REPLY :
          begin   // Called if I send a Protocol Support and loads the ProtocolSupportedProtocols with the data
            // TODO need a call back handler
            Result := True;
          end;
      MTI_EVENTS_IDENTIFY :
          begin
            SendConsumedEvents;
            SendProducedEvents;
            Result := True;
          end;
      MTI_EVENTS_IDENTIFY_DEST :
          begin
            SendConsumedEvents;  // already known the destination is us
            SendProducedEvents;
            Result := True;
          end;
      MTI_PRODUCER_IDENDIFY :
          begin
            Temp := SourceLccMessage.ExtractDataBytesAsEventID(0);
            SendProducerIdentify(Temp);         // Compatible with Smart Pascal
            Result := True;
          end;
      MTI_CONSUMER_IDENTIFY :
          begin
            Temp := SourceLccMessage.ExtractDataBytesAsEventID(0);
            SendConsumerIdentify(Temp);        // Compatible with Smart Pascal
            Result := True;
          end;
       MTI_CONSUMER_IDENTIFIED_CLEAR :
          begin
            // TODO need a call back handler
          end;
       MTI_CONSUMER_IDENTIFIED_SET :
          begin
           // TODO need a call back handler
          end;
       MTI_CONSUMER_IDENTIFIED_UNKNOWN :
          begin
            // TODO need a call back handler
          end;
       MTI_PRODUCER_IDENTIFIED_CLEAR :
          begin
            // TODO need a call back handler
          end;
       MTI_PRODUCER_IDENTIFIED_SET :
          begin
            // TODO need a call back handler
          end;
       MTI_PRODUCER_IDENTIFIED_UNKNOWN :
          begin
            // TODO need a call back handler
          end;
       MTI_DATAGRAM_REJECTED_REPLY :
         begin
           DatagramQueue.Resend(SourceLccMessage);
         end;
       MTI_DATAGRAM_OK_REPLY :
         begin
           DatagramQueue.Remove(SourceLccMessage);
         end;
       MTI_DATAGRAM :
         begin
           case SourceLccMessage.DataArrayIndexer[0] of
             DATAGRAM_PROTOCOL_CONFIGURATION :
               begin
                 case SourceLccMessage.DataArrayIndexer[1] and $F0 of
                   MCP_WRITE :
                     begin
                       case SourceLccMessage.DataArrayIndexer[1] and $03 of
                         MCP_NONE :
                             begin
                               case SourceLccMessage.DataArrayIndexer[6] of
                                 MSI_CDI             :
                                     begin
                                     end;  // Not writeable
                                 MSI_ALL             :
                                     begin
                                     end;  // Not writeable
                                 MSI_CONFIG          :
                                     begin
                                       SendDatagramAckReply(SourceLccMessage, False, 0);     // We will be sending a Write Reply
                                       ProtocolMemoryConfiguration.WriteRequest(SourceLccMessage);
                                       Result := True;
                                     end;
                                 MSI_ACDI_MFG        :
                                     begin
                                     end;  // Not writeable
                                 MSI_ACDI_USER       :
                                     begin
                                       SendDatagramAckReply(SourceLccMessage, False, 0);     // We will be sending a Write Reply
                                       ACDIUser.WriteRequest(SourceLccMessage);
                                       Result := True;
                                     end;
                                 MSI_FDI             :
                                     begin
                                     end;  // Not writeable
                                 MSI_FUNCTION_CONFIG :
                                     begin
                                     end;
                               end
                             end;
                         MCP_CONFIGURATION :
                             begin
                               SendDatagramAckReply(SourceLccMessage, False, 0);             // We will be sending a Write Reply
                               ProtocolMemoryConfiguration.WriteRequest(SourceLccMessage);
                               Result := True;
                             end;
                         MCP_ALL           :
                             begin
                             end; // Not writeable
                         MCP_CDI           :
                             begin
                             end; // Not writeable
                       end;
                     end;
                   MCP_WRITE_STREAM :
                       begin
                       end;
                   MCP_READ :
                       begin
                         case SourceLccMessage.DataArrayIndexer[1] and $03 of
                           MCP_NONE :
                               begin
                                 case SourceLccMessage.DataArrayIndexer[6] of
                                   MSI_CDI             :
                                       begin
                                         WorkerMessage.LoadDatagram(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias);
                                         ProtocolConfigurationDefinitionInfo.LoadReply(SourceLccMessage, WorkerMessage);
                                         SendDatagramRequiredReply(SourceLccMessage, WorkerMessage);
                                         Result := True;
                                       end;
                                   MSI_ALL             :
                                       begin
                                         SendDatagramAckReply(SourceLccMessage, False, 0);   // We won't be sending a Read Reply
                                       end;
                                   MSI_CONFIG          :
                                       begin
                                         WorkerMessage.LoadDatagram(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias);
                                         ProtocolMemoryConfiguration.LoadReply(SourceLccMessage, WorkerMessage);
                                         SendDatagramRequiredReply(SourceLccMessage, WorkerMessage);
                                         Result := True;
                                       end;
                                   MSI_ACDI_MFG        :
                                       begin
                                         WorkerMessage.LoadDatagram(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias);
                                         ACDIMfg.LoadReply(SourceLccMessage, WorkerMessage);
                                         SendDatagramRequiredReply(SourceLccMessage, WorkerMessage);
                                         Result := True;
                                       end;
                                   MSI_ACDI_USER       :
                                       begin
                                         WorkerMessage.LoadDatagram(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias);
                                         ACDIUser.LoadReply(SourceLccMessage, WorkerMessage);
                                         SendDatagramRequiredReply(SourceLccMessage, WorkerMessage);
                                         Result := True;
                                       end;
                                   MSI_FDI             :
                                        begin
                                        end;
                                   MSI_FUNCTION_CONFIG :
                                        begin
                                        end;
                                 end
                               end;
                           MCP_CONFIGURATION : begin
                                                 WorkerMessage.LoadDatagram(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias);
                                                 ProtocolMemoryConfiguration.LoadReply(SourceLccMessage, WorkerMessage);
                                                 SendDatagramRequiredReply(SourceLccMessage, WorkerMessage);
                                                 Result := True;
                                               end;
                           MCP_ALL           : begin  end;
                           MCP_CDI           : begin
                                                 WorkerMessage.LoadDatagram(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias);
                                                 ProtocolConfigurationDefinitionInfo.LoadReply(SourceLccMessage, WorkerMessage);
                                                 SendDatagramRequiredReply(SourceLccMessage, WorkerMessage);
                                                 Result := True;
                                               end;
                         end;
                       end;
                   MCP_READ_STREAM :
                       begin
                       end;
                   MCP_OPERATION :
                       begin
                         case SourceLccMessage.DataArrayIndexer[1] of
                           MCP_OP_GET_CONFIG :
                               begin
                                 WorkerMessage.LoadDatagram(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias);
                                 ProtocolMemoryOptions.LoadReply(WorkerMessage);
                                 SendDatagramRequiredReply(SourceLccMessage, WorkerMessage);
                                 Result := True;
                               end;
                           MCP_OP_GET_ADD_SPACE_INFO :
                               begin
                                 WorkerMessage.LoadDatagram(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias);
                                 ProtocolMemoryInfo.LoadReply(SourceLccMessage, WorkerMessage);
                                 SendDatagramRequiredReply(SourceLccMessage, WorkerMessage);
                                 Result := True;
                               end;
                           MCP_OP_LOCK :
                               begin
                               end;
                           MCP_OP_GET_UNIQUEID :
                               begin
                               end;
                           MCP_OP_FREEZE :
                               begin
                               end;
                           MCP_OP_INDICATE :
                               begin
                               end;
                           MCP_OP_RESETS :
                               begin
                               end;
                         end // case
                       end
                 end; // case
               end
           else begin
               // Unknown Datagram Type
               WorkerMessage.LoadDatagramRejected(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias, REJECTED_DATAGRAMS_NOT_ACCEPTED);
               SendMessageFunc(WorkerMessage);
               Result := True;
             end;
           end;  // case
         end;
    else begin
        if SourceLccMessage.HasDestination then
        begin
          WorkerMessage.LoadOptionalInteractionRejected(NodeID, GetAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias, REJECTED_BUFFER_FULL, SourceLccMessage.MTI);
          SendMessageFunc(WorkerMessage);
          Result := True;
        end;
      end;
    end; // case
  end;
end;

procedure TLccNode.SendDatagramAckReply(SourceLccMessage: TLccMessage; ReplyPending: Boolean; TimeOutValueN: Byte);
begin
  // Only Ack if we accept the datagram
//  Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
  DatagramWorkerMessage.LoadDatagramAck(SourceLccMessage.DestID, SourceLccMessage.CAN.DestAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias, True, ReplyPending, TimeOutValueN);
  SendMessageFunc(DatagramWorkerMessage);
end;

procedure TLccNode.SendConsumedEvents;
var
  i: Integer;
  Temp: TEventID;
begin
//  Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
  for i := 0 to ProtocolEventConsumed.Count - 1 do
  begin
    Temp := ProtocolEventConsumed.Event[i].ID;
    WorkerMessage.LoadConsumerIdentified(NodeID, GetAlias, Temp, ProtocolEventConsumed.Event[i].State);
//    Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
    SendMessageFunc(WorkerMessage);
  end;
end;

procedure TLccNode.SendConsumerIdentify(var Event: TEventID);
var
  EventObj: TLccEvent;
  Temp: TEventID;
begin
//  Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
  EventObj := ProtocolEventConsumed.Supports(Event);
  if Assigned(EventObj) then
  begin
    Temp := EventObj.ID;
    WorkerMessage.LoadConsumerIdentified(NodeID, GetAlias, Temp, EventObj.State);
    SendMessageFunc(WorkerMessage);
  end;
end;

procedure TLccNode.SendDatagramRejectedReply(SourceLccMessage: TLccMessage);
begin
//  Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
  DatagramWorkerMessage.LoadDatagramRejected(SourceLccMessage.DestID, SourceLccMessage.CAN.DestAlias, SourceLccMessage.SourceID, SourceLccMessage.CAN.SourceAlias, REJECTED_BUFFER_FULL);
  SendMessageFunc(DatagramWorkerMessage);
end;

procedure TLccNode.SendDatagramRequiredReply(SourceLccMessage, ReplyLccMessage: TLccMessage);
begin
 if ReplyLccMessage.UserValid then
  begin
    if DatagramQueue.Add(ReplyLccMessage.Clone) then     // Waiting for an ACK
    begin
      SendDatagramAckReply(SourceLccMessage, False, 0);   // We will be sending a Read Reply
      SendMessageFunc(ReplyLccMessage);
    end else
      SendDatagramRejectedReply(SourceLccMessage)
   end;
end;

procedure TLccNode.SendEvents;
begin
  SendConsumedEvents;
  SendProducedEvents;
end;

procedure TLccNode.SendInitializeComplete;
begin
//  Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
  WorkerMessage.LoadInitializationComplete(NodeID, GetAlias);
  SendMessageFunc(WorkerMessage);
end;

procedure TLccNode.SendProducedEvents;
var
  i: Integer;
  Temp: TEventID;
begin
 // Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
  for i := 0 to ProtocolEventsProduced.Count - 1 do
  begin
    Temp := ProtocolEventsProduced.Event[i].ID;
    WorkerMessage.LoadProducerIdentified(NodeID, GetAlias, Temp, ProtocolEventsProduced.Event[i].State);
    SendMessageFunc(WorkerMessage);
  end;
end;

procedure TLccNode.SendProducerIdentify(var Event: TEventID);
var
  EventObj: TLccEvent;
  Temp: TEventID;
begin
//  Assert(SendMessageFunc = nil, STR_SENDMESSAGENIL);
  EventObj := ProtocolEventsProduced.Supports(Event);
  if Assigned(EventObj) then
  begin
    Temp := EventObj.ID;
    WorkerMessage.LoadProducerIdentified(NodeID, GetAlias, Temp, EventObj.State);
    SendMessageFunc(WorkerMessage);
  end;
end;


initialization

finalization

end.

