unit dualcontroller_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, Buttons, lcc_node_manager, lcc_ethernet_client, lcc_node,
  lcc_node_controller, lcc_node_messages, lcc_defines, lcc_node_train;

type

  TControllerState = record
    QueryingSpeed,
    QueryingFunctions: Boolean;
    FunctionQueryIndex: Integer;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    ButtonConnect1: TButton;
    ButtonConnect2: TButton;
    CheckBoxThrottleLongAddress1: TCheckBox;
    CheckBoxThrottleLongAddress2: TCheckBox;
    EditThrottleAddress1: TEdit;
    EditCommandStationIPAddress: TEdit;
    EditThrottleAddress2: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    LabelSetSpeedThrottle1: TLabel;
    LabelActualSpeedThrottle1: TLabel;
    LabelSetSpeedStatusThrottle1: TLabel;
    LabelCommandedSpeedThrottle1: TLabel;
    LabelCommandedSpeedThrottle2: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    LabelActualSpeedThrottle2: TLabel;
    Label103: TLabel;
    Label101: TLabel;
    Label100: TLabel;
    LabelAlias2: TLabel;
    LabelNodeID2: TLabel;
    LabelNodeID1: TLabel;
    LabelAlias1: TLabel;
    Label104: TLabel;
    LabelSetSpeedStatusThrottle2: TLabel;
    LabelSetSpeedThrottle2: TLabel;
    LabelThrottleSpeed1: TLabel;
    LabelThrottleSpeed2: TLabel;
    Panel7: TPanel;
    PanelThrottle1: TPanel;
    PanelMain: TPanel;
    PanelThrottle2: TPanel;
    PanelThrottleEthernet: TPanel;
    Panel6: TPanel;
    PanelThrottleEthernet1: TPanel;
    PanelThrottleFace1: TPanel;
    PanelThrottleFace2: TPanel;
    PanelThrottleKeypad1: TPanel;
    PanelThrottleKeypad2: TPanel;
    RadioGroupThrottleSpeedSteps1: TRadioGroup;
    RadioGroupThrottleSpeedSteps2: TRadioGroup;
    SpeedButtonQuerySpeedThrottle2: TSpeedButton;
    SpeedButtonQuerySpeedThrottle1: TSpeedButton;
    SpeedButtonForward1: TSpeedButton;
    SpeedButtonForward2: TSpeedButton;
    SpeedButtonFunction0: TSpeedButton;
    SpeedButtonFunction1: TSpeedButton;
    SpeedButtonFunction10: TSpeedButton;
    SpeedButtonFunction11: TSpeedButton;
    SpeedButtonFunction12: TSpeedButton;
    SpeedButtonFunction13: TSpeedButton;
    SpeedButtonFunction14: TSpeedButton;
    SpeedButtonFunction15: TSpeedButton;
    SpeedButtonFunction16: TSpeedButton;
    SpeedButtonFunction17: TSpeedButton;
    SpeedButtonFunction18: TSpeedButton;
    SpeedButtonFunction19: TSpeedButton;
    SpeedButtonFunction2: TSpeedButton;
    SpeedButtonFunction20: TSpeedButton;
    SpeedButtonFunction21: TSpeedButton;
    SpeedButtonFunction22: TSpeedButton;
    SpeedButtonFunction23: TSpeedButton;
    SpeedButtonFunction3: TSpeedButton;
    SpeedButtonFunction4: TSpeedButton;
    SpeedButtonFunction5: TSpeedButton;
    SpeedButtonFunction6: TSpeedButton;
    SpeedButtonFunction7: TSpeedButton;
    SpeedButtonFunction8: TSpeedButton;
    SpeedButtonFunction9: TSpeedButton;
    SpeedButtonReverse1: TSpeedButton;
    SpeedButtonReverse2: TSpeedButton;
    SpeedButtonThrottleAssign1: TSpeedButton;
    SpeedButtonThrottleAssign2: TSpeedButton;
    StatusBarThrottle1: TStatusBar;
    StatusBarThrottle2: TStatusBar;
    TrackBarThrottle1: TTrackBar;
    TrackBarThrottle2: TTrackBar;
    procedure ButtonConnect1Click(Sender: TObject);
    procedure ButtonConnect2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButtonForward1Click(Sender: TObject);
    procedure SpeedButtonForward2Click(Sender: TObject);
    procedure SpeedButtonQuerySpeedThrottle1Click(Sender: TObject);
    procedure SpeedButtonQuerySpeedThrottle2Click(Sender: TObject);
    procedure SpeedButtonReverse1Click(Sender: TObject);
    procedure SpeedButtonReverse2Click(Sender: TObject);
    procedure SpeedButtonThrottle2FunctionClick(Sender: TObject);
    procedure SpeedButtonThrottle1FunctionClick(Sender: TObject);
    procedure SpeedButtonThrottleAssign1Click(Sender: TObject);
    procedure SpeedButtonThrottleAssign2Click(Sender: TObject);
    procedure TrackBarThrottle1Change(Sender: TObject);
    procedure TrackBarThrottle2Change(Sender: TObject);
  private

  protected
    procedure OnNodeManager1IDChange(Sender: TObject; LccSourceNode: TLccNode);
    procedure OnNodeManager1AliasChange(Sender: TObject; LccSourceNode: TLccNode);
    procedure OnNodeManager1SendMessage(Sender: TObject; LccMessage: TLccMessage);

    procedure OnNodeManager2IDChange(Sender: TObject; LccSourceNode: TLccNode);
    procedure OnNodeManager2AliasChange(Sender: TObject; LccSourceNode: TLccNode);
    procedure OnNodeManager2SendMessage(Sender: TObject; LccMessage: TLccMessage);

    procedure OnClientServer1ConnectionChange(Sender: TObject; EthernetRec: TLccEthernetRec);
    procedure OnClientServer1ErrorMessage(Sender: TObject; EthernetRec: TLccEthernetRec);

    procedure OnClientServer2ConnectionChange(Sender: TObject; EthernetRec: TLccEthernetRec);
    procedure OnClientServer2ErrorMessage(Sender: TObject; EthernetRec: TLccEthernetRec);

    procedure Controller1Callback(Sender: TLccNode; Reason: TControllerCallBackMessages);
    procedure Controller2Callback(Sender: TLccNode; Reason: TControllerCallBackMessages);

    procedure OnControllerQuerySpeed1(Sender: TLccNode; SetSpeed, CommandSpeed, ActualSpeed: single; Status: Byte);
    procedure OnControllerQueryFunction1(Sender: TLccNode; Address: DWORD; Value: Word);

    procedure OnControllerQuerySpeed2(Sender: TLccNode; SetSpeed, CommandSpeed, ActualSpeed: single; Status: Byte);
    procedure OnControllerQueryFunction2(Sender: TLccNode; Address: DWORD; Value: Word);

    procedure ReleaseTrain1;
    procedure ReleaseTrain2;

  public
    NodeManager1: TLccCanNodeManager;
    ClientServer1: TLccEthernetClient;
    NodeManager2: TLccCanNodeManager;
    ClientServer2: TLccEthernetClient;

    ControllerNode1: TLccTrainController;
    ControllerNode2: TLccTrainController;

    AssignedTrain: TLccTrainCanNode;

    Controller1State: TControllerState;
    Controller2State: TControllerState;

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ButtonConnect1Click(Sender: TObject);
var
  EthernetRec: TLccEthernetRec;
begin
  if ClientServer1.Connected then
  begin
    ReleaseTrain1;
    ClientServer1.CloseConnection(nil);
  end else
  begin
    FillChar(EthernetRec, SizeOf(EthernetRec), #0);
    EthernetRec.ListenerIP := EditCommandStationIPAddress.Text;
    EthernetRec.AutoResolveIP := True;
    EthernetRec.ListenerPort := 12021;
    ClientServer1.Gridconnect := True;
    ClientServer1.NodeManager := NodeManager1;
    ClientServer1.OpenConnection(EthernetRec);
  end;
end;

procedure TForm1.ButtonConnect2Click(Sender: TObject);
var
  EthernetRec: TLccEthernetRec;
begin
  if ClientServer2.Connected then
  begin
    ReleaseTrain2;
    ClientServer2.CloseConnection(nil);
  end else
  begin
    FillChar(EthernetRec, SizeOf(EthernetRec), #0);
    EthernetRec.ListenerIP := EditCommandStationIPAddress.Text;
    EthernetRec.AutoResolveIP := True;
    EthernetRec.ListenerPort := 12021;
    ClientServer2.Gridconnect := True;
    ClientServer2.NodeManager := NodeManager2;
    ClientServer2.OpenConnection(EthernetRec);
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  NodeManager1.Clear;
  ClientServer1.CloseConnection(nil);
  ClientServer1.NodeManager := nil;
  FreeAndNil(NodeManager1);

  NodeManager2.Clear;
  ClientServer2.CloseConnection(nil);
  ClientServer2.NodeManager := nil;
  FreeAndNil(NodeManager2);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  NodeManager1 := TLccCanNodeManager.Create(nil);
  ClientServer1 := TLccEthernetClient.Create(nil);

  NodeManager1.OnLccNodeAliasIDChanged := @OnNodeManager1AliasChange;
  NodeManager1.OnLccNodeIDChanged := @OnNodeManager1IDChange;
  NodeManager1.OnLccMessageSend := @OnNodeManager1SendMessage;

  ClientServer1.OnConnectionStateChange := @OnClientServer1ConnectionChange;
  ClientServer1.OnErrorMessage := @OnClientServer1ErrorMessage;

  NodeManager2 := TLccCanNodeManager.Create(nil);
  ClientServer2 := TLccEthernetClient.Create(nil);

  NodeManager2.OnLccNodeAliasIDChanged := @OnNodeManager2AliasChange;
  NodeManager2.OnLccNodeIDChanged := @OnNodeManager2IDChange;
  NodeManager2.OnLccMessageSend := @OnNodeManager2SendMessage;

  ClientServer2.OnConnectionStateChange := @OnClientServer2ConnectionChange;
  ClientServer2.OnErrorMessage := @OnClientServer2ErrorMessage;

  PanelThrottleFace1.Enabled := False;
  PanelThrottleFace2.Enabled := False;
  PanelThrottleKeypad1.Enabled := False;
  PanelThrottleKeypad2.Enabled := False;
end;

procedure TForm1.SpeedButtonForward1Click(Sender: TObject);
begin
  if Assigned(ControllerNode1) then
  begin
    ControllerNode1.Direction := tdForward;
  end;
end;

procedure TForm1.SpeedButtonForward2Click(Sender: TObject);
begin
  if Assigned(ControllerNode2) then
  begin
    ControllerNode2.Direction := tdForward;
  end;
end;

procedure TForm1.SpeedButtonQuerySpeedThrottle1Click(Sender: TObject);
begin
  ControllerNode1.QuerySpeed;
end;

procedure TForm1.SpeedButtonQuerySpeedThrottle2Click(Sender: TObject);
begin
  ControllerNode2.QuerySpeed;
end;

procedure TForm1.SpeedButtonReverse1Click(Sender: TObject);
begin
  if Assigned(ControllerNode1) then
  begin
    ControllerNode1.Direction := tdReverse;
  end;
end;

procedure TForm1.SpeedButtonReverse2Click(Sender: TObject);
begin
  if Assigned(ControllerNode2) then
  begin
    ControllerNode2.Direction := tdReverse;
  end;
end;

procedure TForm1.SpeedButtonThrottle2FunctionClick(Sender: TObject);
begin
 if Assigned(ControllerNode2) then
  begin
    ControllerNode2.Functions[(Sender as TSpeedButton).Tag] := not ControllerNode1.Functions[(Sender as TSpeedButton).Tag];
  end;
end;

procedure TForm1.SpeedButtonThrottle1FunctionClick(Sender: TObject);
begin
  if Assigned(ControllerNode1) then
  begin
    ControllerNode1.Functions[(Sender as TSpeedButton).Tag] := not ControllerNode1.Functions[(Sender as TSpeedButton).Tag];
  end;
end;

procedure TForm1.SpeedButtonThrottleAssign1Click(Sender: TObject);
var
  SpeedStep: TLccDccSpeedStep;
  DccAddress: LongInt;
begin
  if Assigned(ControllerNode1) then
  begin
    ReleaseTrain1;

    case RadioGroupThrottleSpeedSteps1.ItemIndex of
      0 : SpeedStep := ldss14;
      1 : SpeedStep := ldss28;
      2 : SpeedStep := ldss128;
    end;
    if TryStrToInt(EditThrottleAddress1.Text, DccAddress) then
      ControllerNode1.AssignTrainByDccAddress(DccAddress, CheckBoxThrottleLongAddress1.Checked, SpeedStep)
    else
      ShowMessage('Invalid Address');
  end;
end;

procedure TForm1.SpeedButtonThrottleAssign2Click(Sender: TObject);
var
  SpeedStep: TLccDccSpeedStep;
  DccAddress: LongInt;
begin
  if Assigned(ControllerNode2) then
  begin
    ReleaseTrain2;

    case RadioGroupThrottleSpeedSteps2.ItemIndex of
      0 : SpeedStep := ldss14;
      1 : SpeedStep := ldss28;
      2 : SpeedStep := ldss128;
    end;
    if TryStrToInt(EditThrottleAddress2.Text, DccAddress) then
      ControllerNode2.AssignTrainByDccAddress(DccAddress, CheckBoxThrottleLongAddress2.Checked, SpeedStep)
    else
      ShowMessage('Invalid Address');
  end;
end;

procedure TForm1.TrackBarThrottle1Change(Sender: TObject);
begin
  if Assigned(ControllerNode1) then
  begin
    ControllerNode1.Speed := TrackBarThrottle1.Position;
    LabelThrottleSpeed1.Caption := IntToStr(TrackBarThrottle1.Position);
  end;
end;

procedure TForm1.TrackBarThrottle2Change(Sender: TObject);
begin
  if Assigned(ControllerNode2) then
  begin
    ControllerNode2.Speed := TrackBarThrottle2.Position;
    LabelThrottleSpeed2.Caption := IntToStr(TrackBarThrottle2.Position);
  end;
end;

procedure TForm1.OnClientServer1ConnectionChange(Sender: TObject; EthernetRec: TLccEthernetRec);
begin
  case EthernetRec.ConnectionState of
    ccsClientConnecting : StatusBarThrottle1.Panels[0].Text    := 'Connecting';
    ccsClientConnected  :
      begin
        ButtonConnect1.Caption := 'Disconnect';
        StatusBarThrottle1.Panels[0].Text := 'IP Address: ' + EthernetRec.ClientIP + ':' + IntToStr(EthernetRec.ClientPort);
        ControllerNode1 := NodeManager1.AddNodeByClass('', TLccTrainController, True) as TLccTrainController;
        ControllerNode1.OnMessageCallback := @Controller1Callback;
        ControllerNode1.OnQuerySpeed := @OnControllerQuerySpeed1;
        ControllerNode1.OnQueryFunction := @OnControllerQueryFunction1;
        PanelThrottleFace1.Enabled := True;
      end;
    ccsClientDisconnecting :
      begin
        NodeManager1.Clear;   // Logout
        ControllerNode1 := nil;
        StatusBarThrottle1.Panels[0].Text := 'Disconnecting';
      end;
    ccsClientDisconnected :
      begin
        StatusBarThrottle1.Panels[0].Text := 'Disconnected';
        ButtonConnect1.Caption := 'Connect';
        LabelAlias1.Caption := 'None';
        LabelNodeID1.Caption := 'None';
        PanelThrottleFace1.Enabled := False;
      end;
  end;
end;

procedure TForm1.OnClientServer1ErrorMessage(Sender: TObject; EthernetRec: TLccEthernetRec);
begin
  ShowMessage(EthernetRec.MessageStr);
  NodeManager1.Clear;
  StatusBarThrottle1.Panels[0].Text := 'Disconnected';
  ButtonConnect1.Caption := 'Connect';
end;

procedure TForm1.OnClientServer2ConnectionChange(Sender: TObject; EthernetRec: TLccEthernetRec);
begin
  case EthernetRec.ConnectionState of
    ccsClientConnecting : StatusBarThrottle2.Panels[0].Text    := 'Connecting';
    ccsClientConnected  :
      begin
        ButtonConnect2.Caption := 'Disconnect';
        StatusBarThrottle2.Panels[0].Text := 'IP Address: ' + EthernetRec.ClientIP + ':' + IntToStr(EthernetRec.ClientPort);
        ControllerNode2 := NodeManager2.AddNodeByClass('', TLccTrainController, True) as TLccTrainController;
        ControllerNode2.OnMessageCallback := @Controller2Callback;
        ControllerNode2.OnQuerySpeed := @OnControllerQuerySpeed2;
        ControllerNode2.OnQueryFunction := @OnControllerQueryFunction2;
        PanelThrottleFace2.Enabled := True;
      end;
    ccsClientDisconnecting :
      begin
        NodeManager2.Clear;   // Logout
        ControllerNode2 := nil;
        StatusBarThrottle2.Panels[0].Text := 'Disconnecting';
      end;
    ccsClientDisconnected :
      begin
        StatusBarThrottle2.Panels[0].Text := 'Disconnected';
        ButtonConnect2.Caption := 'Connect';
        LabelAlias2.Caption := 'None';
        LabelNodeID2.Caption := 'None';
        PanelThrottleFace2.Enabled := False;
      end;
  end;
end;

procedure TForm1.OnClientServer2ErrorMessage(Sender: TObject; EthernetRec: TLccEthernetRec);
begin
  ShowMessage(EthernetRec.MessageStr);
  NodeManager2.Clear;
  StatusBarThrottle2.Panels[0].Text := 'Disconnected';
  ButtonConnect2.Caption := 'Connect';
end;

procedure TForm1.OnControllerQueryFunction1(Sender: TLccNode; Address: DWORD; Value: Word);
begin
 case Controller1State.FunctionQueryIndex of
   0 : begin if Value = 0 then SpeedButtonFunction0.Color := clGreen else SpeedButtonFunction0.Color := clYellow; end;
   1 : begin if Value = 0 then SpeedButtonFunction1.Color := clGreen else SpeedButtonFunction1.Color := clYellow; end;
   2 : begin if Value = 0 then SpeedButtonFunction2.Color := clGreen else SpeedButtonFunction2.Color := clYellow; end;
   3 : begin if Value = 0 then SpeedButtonFunction3.Color := clGreen else SpeedButtonFunction3.Color := clYellow; end;
   4 : begin if Value = 0 then SpeedButtonFunction4.Color := clGreen else SpeedButtonFunction4.Color := clYellow; end;
   5 : begin if Value = 0 then SpeedButtonFunction5.Color := clGreen else SpeedButtonFunction5.Color := clYellow; end;
   end;
  Controller1State.FunctionQueryIndex := Controller1State.FunctionQueryIndex + 1;
  if Controller1State.FunctionQueryIndex < 12 then
    ControllerNode1.QueryFunction(Controller1State.FunctionQueryIndex)
  else begin
    Controller1State.QueryingFunctions := False;
    if not Controller1State.QueryingSpeed then
      PanelThrottleKeypad1.Enabled := True;
  end;
end;

procedure TForm1.OnControllerQueryFunction2(Sender: TLccNode; Address: DWORD; Value: Word);
begin

end;

procedure TForm1.OnControllerQuerySpeed1(Sender: TLccNode; SetSpeed,
  CommandSpeed, ActualSpeed: single; Status: Byte);
begin
  LabelSetSpeedThrottle1.Caption := IntToStr( Round(SetSpeed));
  LabelCommandedSpeedThrottle1.Caption := IntToStr( Round(CommandSpeed));
  LabelActualSpeedThrottle1.Caption := IntToStr( Round(ActualSpeed));
  LabelSetSpeedStatusThrottle1.Caption := '0x' + IntToHex(Status, 2);

  Controller1State.QueryingSpeed := False;

  if not Controller1State.QueryingFunctions then
     PanelThrottleKeypad1.Enabled := True;
end;

procedure TForm1.OnControllerQuerySpeed2(Sender: TLccNode; SetSpeed,
  CommandSpeed, ActualSpeed: single; Status: Byte);
begin
  LabelSetSpeedThrottle2.Caption := IntToStr( Round(SetSpeed));
  LabelCommandedSpeedThrottle2.Caption := IntToStr( Round(CommandSpeed));
  LabelActualSpeedThrottle2.Caption := IntToStr( Round(ActualSpeed));
  LabelSetSpeedStatusThrottle2.Caption := '0x' + IntToHex(Status, 2);
end;

procedure TForm1.Controller1Callback(Sender: TLccNode; Reason: TControllerCallBackMessages);
begin
  case Reason of
    ccbReservedFail :
      begin
        ShowMessage('Throttle 1: Reserve Failed');
      end;
    ccbAssignFailTrainRefused :
      begin
        ShowMessage('Throttle 1: Assign Failed: Train Refused');
      end;
    ccbAssignFailControllerRefused :
      begin
        ShowMessage('Throttle 1: Assign Failed: Currently Assigned Controller Refused');
      end;
    ccbControllerAssigned :
      begin
   //     ShowMessage('Throttle 1: Assigned!');
        Controller1State.QueryingSpeed := True;
        Controller1State.QueryingFunctions := True;
        Controller1State.FunctionQueryIndex := 0;
        ControllerNode1.QuerySpeed;
        ControllerNode1.QueryFunction(Controller1State.FunctionQueryIndex);
    //    PanelThrottleKeypad1.Enabled := True;
      end;
    ccbControllerUnassigned :
      begin
  //      ShowMessage('Throttle 1: Unassigned!');
        PanelThrottleKeypad1.Enabled := False;
      end;
  end;
end;

procedure TForm1.Controller2Callback(Sender: TLccNode; Reason: TControllerCallBackMessages);
begin
  case Reason of
    ccbReservedFail :
      begin
        ShowMessage('Throttle 2: Reserve Failed');
      end;
    ccbAssignFailTrainRefused :
      begin
        ShowMessage('Throttle 2: Assign Failed: Train Refused');
      end;
    ccbAssignFailControllerRefused :
      begin
        ShowMessage('Throttle 2: Assign Failed: Currently Assigned Controller Refused');
      end;
    ccbControllerAssigned :
      begin
 //       ShowMessage('Throttle 2: Assigned!');
        PanelThrottleKeypad2.Enabled := True;
      end;
    ccbControllerUnassigned :
      begin
 //       ShowMessage('Throttle 2: Unassigned!');
        PanelThrottleKeypad2.Enabled := False;
      end;
  end;
end;

procedure TForm1.ReleaseTrain1;
var
  TickCount: QWord;
begin
  if ControllerNode1.AssignedTrain.AttachedState = tasAssigned then
  begin
    ControllerNode1.ReleaseTrain;
    TickCount := GetTickCount64;     // ~10ms resolution
    // Hate this but don't know what else to do... need to get through this handshake
    while ControllerNode1.AssignedTrain.AttachedState <> tasNotAssigned do
    begin
      Application.ProcessMessages;
      if GetTickCount64 > (TickCount + 5000) then
        Break;
    end;
  end;
end;

procedure TForm1.ReleaseTrain2;
var
  TickCount: QWord;
begin
  if ControllerNode2.AssignedTrain.AttachedState = tasAssigned then
  begin
    ControllerNode2.ReleaseTrain;
    TickCount := GetTickCount64;     // ~10ms resolution
    // Hate this but don't know what else to do... need to get through this handshake
    while ControllerNode2.AssignedTrain.AttachedState <> tasNotAssigned do
    begin
      Application.ProcessMessages;
      if GetTickCount64 > (TickCount + 5000) then
        Break;
    end;
  end;
end;

procedure TForm1.OnNodeManager1AliasChange(Sender: TObject; LccSourceNode: TLccNode);
begin
  LabelAlias1.Caption := 'NodeID: ' + (LccSourceNode as TLccCanNode).AliasIDStr;
end;

procedure TForm1.OnNodeManager1IDChange(Sender: TObject; LccSourceNode: TLccNode);
begin
  LabelNodeID1.Caption := 'NodeID: ' + LccSourceNode.NodeIDStr;
end;

procedure TForm1.OnNodeManager1SendMessage(Sender: TObject; LccMessage: TLccMessage);
begin
  ClientServer1.SendMessage(LccMessage);
end;

procedure TForm1.OnNodeManager2AliasChange(Sender: TObject; LccSourceNode: TLccNode);
begin
  LabelAlias2.Caption := 'NodeID: ' + (LccSourceNode as TLccCanNode).AliasIDStr;
end;

procedure TForm1.OnNodeManager2IDChange(Sender: TObject; LccSourceNode: TLccNode);
begin
  LabelNodeID2.Caption := 'NodeID: ' + LccSourceNode.NodeIDStr;
end;

procedure TForm1.OnNodeManager2SendMessage(Sender: TObject; LccMessage: TLccMessage);
begin
  ClientServer2.SendMessage(LccMessage);
end;

end.

