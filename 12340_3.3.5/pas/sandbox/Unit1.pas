unit Unit1;

interface

uses
  ShellApi,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  Sockets, SRP6_LockBox,
  Menus;

type
  TMainForm = class(TForm)
    PageControl: TPageControl;
    Sheet1: TTabSheet;
    Log: TMemo;
    TabSheet1: TTabSheet;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    MainMenu1: TMainMenu;
    Input1: TMenuItem;
    SaveWorld1: TMenuItem;
    WipeWorld1: TMenuItem;
    RestartServer1: TMenuItem;
    LoadWorld: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SaveWorld1Click(Sender: TObject);
    procedure RestartServer1Click(Sender: TObject);
    procedure WipeWorld1Click(Sender: TObject);
    procedure LoadWorldClick(Sender: TObject);
  private
    procedure NetworkMessageRS(var Msg:TMessage); message WM_ASYNC_RS;
    procedure NetworkMessageWS(var Msg:TMessage); message WM_ASYNC_WS;
    procedure StartServer(Sender: TObject; var Done:Boolean);
  protected
  end;

var
  MainForm: TMainForm;

implementation

uses
  Logs, Convert,
  Struct,
  DB,
  ClassCharList,
  ClassConnection,
  ClassWorld,
  Responses, Defines,
  UpdateFields, PacketBuilding, NetMessages, OpCodesProcTable,
  AuthServer,
  WinSock;

{$R *.dfm}

procedure TMainForm.NetworkMessageRS(var Msg:TMessage);
var
  incoming_sock: longint;
  LoginUser: TLoginUser;
begin
  Case msg.lParam of
    FD_ACCEPT:
      begin
        ux:=SizeOf(LocalAddress);
        incoming_sock:= Accept(RS, @LocalAddress, @ux);

        LoginUser:= TLoginUser.Create;
        LoginUser.Sock:= incoming_sock;
        LoginUser.Addr:= String(inet_ntoa(LocalAddress.sin_addr));
        LoginUser.Port:= LocalAddress.sin_port;

        ListLoginUsers.Add(incoming_sock, LoginUser);
        MainLog('RS: '+strr(LoginUser.Sock)+': '+LoginUser.Addr+':'+strr(LoginUser.Port)+': Incoming connection. Active Connections: '+strr(ListLoginUsers.Count), 1,1,0);
      end;
    FD_CLOSE:
      begin
        incoming_sock:= msg.WParam;

        // check nil

        MainLog('RS: '+strr(ListLoginUsers[incoming_sock].Sock)+': '+ListLoginUsers[incoming_sock].Addr+':'+strr(ListLoginUsers[incoming_sock].Port)+': Disconnected.', 1,0,0);
        ListLoginUsers[incoming_sock].Free;
        ListLoginUsers.Del(incoming_sock);

        Shutdown(incoming_sock, 1);
        CloseSocket(incoming_sock);
      end;
    FD_READ:
      begin
        incoming_sock:=msg.WParam;

        // check nil

        ListLoginUsers[incoming_sock].SockRecv;
      end;
  End;
end;
procedure TMainForm.NetworkMessageWS(var Msg:TMessage);
var
  incoming_sock: longint;
  WorldUser: TWorldUser;
begin
  Case msg.lParam of
    FD_ACCEPT:
      begin
        ux:= SizeOf(LocalAddress);
        incoming_sock:= Accept(WS, @LocalAddress, @ux);

        WorldUser:= TWorldUser.Create;
        WorldUser.Sock:= incoming_sock;
        WorldUser.Addr:= String(inet_ntoa(LocalAddress.sin_addr));
        WorldUser.Port:= LocalAddress.sin_port;

        ListWorldUsers.Add(incoming_sock, WorldUser);
        MainLog('WS: '+strr(WorldUser.Sock)+': '+WorldUser.Addr+':'+strr(WorldUser.Port)+': Incoming connection. Active Connections: '+strr(ListWorldUsers.Count), 1,1,0);

        OpCodeProc[SMSG_AUTH_CHALLENGE](WorldUser);
      end;
    FD_CLOSE:
      begin
        incoming_sock:= msg.WParam;

        // check nil

        MainLog('WS: '+strr(ListWorldUsers[incoming_sock].Sock)+': '+ListWorldUsers[incoming_sock].Addr+':'+strr(ListWorldUsers[incoming_sock].Port)+': Disconnected.', 1,0,0);
        ListWorldUsers[incoming_sock].Free;
        ListWorldUsers.Del(incoming_sock);

        Shutdown(incoming_sock, 1);
        CloseSocket(incoming_sock);
      end;
    FD_READ:
      begin
        incoming_sock:= msg.WParam;

        // check nil

        ListWorldUsers[incoming_sock].SockRecv;
      end;
  End;
end;

procedure TMainForm.StartServer(Sender: TObject; var Done:Boolean);
var
  f: textfile;
  s: string;
  i: longint;
begin
  Application.OnIdle:= nil;

  MainForm.Caption:= 'WoWCore: SandBox. ';
  Application.Title:= 'SandBox';
  MainForm.PageControl.ActivePage.PageControl.TabIndex:= 0;
  MainLog('Starting SandBox '+UPDATEFIELDS_VERSION+'.'+UPDATEFIELDS_BUILD+'.'+APP_BUILD+' ...', 1,0,1);

  {$I-}
  AssignFile(f, 'SandBox.wtf');
  Reset(f);
  ReadLn(f, REALM_ADDR);
  ReadLn(f, s);
  i:= vall(s);
  if i<>0 then RS_PORT:= i;
  ReadLn(f, s);
  i:= vall(s);
  if i<>0 then WS_PORT:= i;
  CloseFile(f);
  {$I+}

  if IOResult<>0 then
  begin
    REALM_ADDR:= 'localhost';
    RS_PORT:= 3724;
    WS_PORT:= 7000;
  end;
  REALM_ADDR:= trim(REALM_ADDR);

  SRP6_init();

  // DB Chars
  ListChars:= TListChars.Create;

  // Worlds
  World:= TWorld.Create;

  // Active Connections
  ListLoginUsers:= TListLoginUsers.Create;
  ListWorldUsers:= TListWorldUsers.Create;

  LoadAllResponses;

  if not BuildSocketsRS then
  begin
    MainLog('RS: Can''t build port ', 1,0,0);
    exit;
  end;

  if not BuildSocketsWS then
  begin
    MainLog('WS: Can''t build port ', 1,0,0);
    exit;
  end;

  MainLog('SandBox started at ['+REALM_ADDR+']. Use any same Login and Password to logon.', 1,1,1);
end;
procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.OnIdle:= StartServer;
  if FileExists('memo.txt')
  then Memo1.Lines.LoadFromFile('memo.txt')
  else exit;
end;
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ListLoginUsers.Free;
  ListWorldUsers.Free;

  SRP6_free();

  ListChars.Free;
  World.Free;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
if FileExists('memo.txt')
then Memo1.Lines.LoadFromFile('memo.txt')
else exit;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
Memo1.Lines.SaveToFile('memo.txt');
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
Memo1.Lines.Clear;
end;

procedure TMainForm.SaveWorld1Click(Sender: TObject);
var
  OBJ: TWorldRecord;
  i, map, x, y, z, u, m, facing: longint;
  worldfile: textfile;
  s: string;
begin
  {$IOChecks off}
  {$I-}
  AssignFile(worldfile, 'world.dat');
  ReWrite(worldfile);

for i:=0 to World.Count-1 do
    begin
    if World.ObjectByIndex[i].woType = WO_UNIT then
    begin
        OBJ := World.ObjectByIndex[i];
        map:=TWorldUnit(OBJ.woAddr).woLoc.Map;
        x:= Smallint(round(TWorldUnit(OBJ.woAddr).woLoc.x));
        y:= Smallint(round(TWorldUnit(OBJ.woAddr).woLoc.y));
        z:= Smallint(round(TWorldUnit(OBJ.woAddr).woLoc.z));
        u:= TWorldUnit(OBJ.woAddr).woEntry;
        if TWorldUnit(OBJ.woAddr).unDisplayID = CreatureTPL[TWorldUnit(OBJ.woAddr).woEntry].DisplayID[0] then
          m:= 0
        else
          m:= TWorldUnit(OBJ.woAddr).unDisplayID;
        facing:=Smallint(round(TWorldUnit(OBJ.woAddr).woLoc.facing));
        s:=''+strr(map)+' '+single2str(x)+' '+single2str(y)+' '+single2str(z)+' '+strr(u)+' '+strr(m)+' '+single2str(facing);
        WriteLn(worldfile, s);
        end;
    end;

  CloseFile(worldfile);
  {$I+}


end;

procedure TMainForm.RestartServer1Click(Sender: TObject);
begin
//Application.Terminate;
WSACleanUp;
while WSACleanUp > 0 do
begin
  sleep(10);
  end;
  MainForm.Close;
  MainForm.Free;
  WinExec(PChar(Application.ExeName), SW_SHOW);
end;

procedure TMainForm.WipeWorld1Click(Sender: TObject);
var
  OBJ: TWorldRecord;
  i: longint;
begin
for i:=0 to World.Count+10 do
    begin
    while World.ObjectByIndex[i].woType = WO_UNIT do
//    if World.ObjectByIndex[i].woType = WO_UNIT then
    begin
        OBJ := World.ObjectByIndex[i];
        ListWorldUsers.Send_Destroy(OBJ.woGUID);
        TWorldUnit(OBJ.woAddr).Free;
        World.Del(OBJ);
        sleep(1);
        end;
    end;
end;

procedure TMainForm.LoadWorldClick(Sender: TObject);
var
  OBJ: TWorldRecord;
  map, x, y, z, facing, u, m: longint;
  worldfile: textfile;
  woUnit: TWorldUnit;
begin

if FileExists('world.dat') then
  begin
  {$IOChecks off}
  {$I-}
  AssignFile(worldfile, 'world.dat');
  Reset(worldfile);
  while not Eof(worldfile) do
  begin
  ReadLn(worldfile, map, x, y, z, u, m, facing);
  MainLog('loaded an entry: ' +strr(u)+', map:'+strr(map)+', x:'+strr(x)+', y:'+strr(y)+', z:'+strr(z)+', morph:'+strr(m)+', facing:'+strr(facing));

  if CreatureTPL[u].Name[0] = '' then
  begin
    MainLog('CMSG_CREATURE_QUERY: Creature ID='+strr(u)+' is not present',1,0,0);
    continue;
  end;

  woUnit:= TWorldUnit.Create(u);
  woUnit.woLoc.x:=      x;
  woUnit.woLoc.y:=      y;
  woUnit.woLoc.z:=      z;
  woUnit.woLoc.Map:=    map;

  if(facing > 0) then begin
    woUnit.woLoc.facing:= facing;
  end;

  woUnit.unDisplayID:=CreatureTPL[u].DisplayID[0];
  woUnit.unNativeDisplayID:=CreatureTPL[u].DisplayID[0];

  OBJ.woType:= WO_UNIT;
  OBJ.woGUID:= woUnit.woGUID;
  OBJ.woMap:= woUnit.woLoc.Map;
  OBJ.woAddr:= woUnit;
  World.Add(OBJ);
//  ListWorldUsers.Send_CreateFromUnit(OBJ);

  if(m > 0) then begin
    TWorldUnit(OBJ.woAddr).unDisplayID:= m;
    TWorldUnit(OBJ.woAddr).unNativeDisplayID:= m;
  end;

//  sleep(1);
  
  end;
  end;
  CloseFile(worldfile);
  {$I+}
  {$IOChecks on}
end;

initialization

end.
