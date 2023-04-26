unit CharServer;

interface

uses
  Struct, Defines,
  ClassConnection;

procedure cmd_SMSG_AUTH_CHALLENGE(var sender: TWorldUser);
procedure cmd_CMSG_AUTH_SESSION(var sender: TWorldUser);
procedure cmd_CMSG_CHAR_ENUM(var sender: TWorldUser);
procedure cmd_CMSG_CHAR_CREATE(var sender: TWorldUser);
procedure cmd_CMSG_CHAR_DELETE(var sender: TWorldUser);
procedure cmd_CMSG_PING(var sender: TWorldUser);
procedure cmd_CMSG_ITEM_QUERY_SINGLE(var sender: TWorldUser);
procedure cmd_CMSG_CREATURE_QUERY(var sender: TWorldUser);
procedure cmd_CMSG_GAMEOBJECT_QUERY(var sender: TWorldUser);
procedure cmd_CMSG_NPC_TEXT_QUERY(var sender: TWorldUser);
procedure cmd_CMSG_JOIN_CHANNEL(var sender: TWorldUser);
procedure cmd_CMSG_MESSAGECHAT(var sender: TWorldUser);
procedure cmd_CMSG_LOGOUT_REQUEST(var sender: TWorldUser);
procedure cmd_CMSG_DESTROYITEM(var sender: TWorldUser);
procedure cmd_CMSG_ZONEUPDATE(var sender: TWorldUser);
procedure cmd_CMSG_UI_TIME_REQUEST(var sender: TWorldUser);

implementation

uses
  Logs, Convert,
  wowZLib,
  LbCipher, LbClass,
  TMSGStruct, TMSGBuilder, TMSGParser, TMSGBufGets,
  NetMessages, NetMessagesStr,
  UpdateFields,
  DB,
  ClassCharList,
  ClassWorld,
  OpCodesProcTable,
  Commands,
  Responses,
  SysUtils, DateUtils, Windows;

procedure cmd_SMSG_AUTH_CHALLENGE(var sender: TWorldUser);
var
  msg: T_SMSG_AUTH_CHALLENGE;
begin
  Randomize;
  sender.ServerSeed:= random(65535) * 65535 + random(65535);

  msg.unk:= 1; // 1..31
  msg.ServerSeed:= sender.ServerSeed;
  msg.Random1:= random(65535) * 65535 + random(65535);
  msg.Random2:= random(65535) * 65535 + random(65535);
  msg.Random3:= random(65535) * 65535 + random(65535);
  msg.Random4:= random(65535) * 65535 + random(65535);
  msg.Random5:= random(65535) * 65535 + random(65535);
  msg.Random6:= random(65535) * 65535 + random(65535);
  msg.Random7:= random(65535) * 65535 + random(65535);
  msg.Random8:= random(65535) * 65535 + random(65535);
  sender.SockSend(msgBuild(sender.SBuf, msg));
end;
procedure cmd_CMSG_AUTH_SESSION(var sender: TWorldUser);
var
  DBlist, char_file: textfile;
  i, scale, speed, spawnmap, mount, morph, lvl, item0, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13, item14, item15, item16, item17, item18, item19, item20, item21, item22, item23, item24, item25, item26, item27, item28, item29, item30, item31, item32, item33, item34, item35, item36, item37, item38, login_len: longint;
  L: AnsiString;
  spawnx, spawny, spawnz: single;
  s, spell, savepath, accname: string;
  server_digest: TSHA1Digest;
  Hasher: TLbSHA1;
  Temp: array of Byte;
  imsg: T_CMSG_AUTH_SESSION;
  imsg2: T_CLIENT_ADDON_INFO;
  omsg: T_SMSG_AUTH_RESPONSE;
  imsg3: T_CMSG_CHAR_CREATE;
  omsg2: T_SMSG_ADDON_INFO;
  c: TCharData;
  z_err, unzipped: longint;
begin
  // default that's ok
  omsg.ResponseCode:= AUTH_OK;

  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  MainLog('CMSG_AUTH_SESSION: AccountName ['+imsg.Login+'], Build ['+strr(imsg.Build)+']');
  sender.AccountName:= imsg.Login;

  // Find session KEY from ListLoginUsers
  for i:=0 to ListLoginUsers.Count-1 do
    if ListLoginUsers.UserByIndex[i].AccountName = imsg.Login then
      move(ListLoginUsers.UserByIndex[i].Data.Session[0], sender.SessionKey[0], 40);

  // Calculate Server Digest
  login_len:= Length(imsg.Login);

  Hasher:= TLbSHA1.Create(nil);
  SetLength(Temp, login_len + 4 + 4 + 4 + 40); // login + (zero) + CLIseed + SRVseed + key

  L:= AnsiString(imsg.Login);
  Move((@L[1])^, Temp[0], login_len);
  i:= 0;
  Move(i, Temp[login_len], 4);
  Move(imsg.ClientSeed, Temp[login_len + 4], 4);
  Move(sender.ServerSeed, Temp[login_len + 4 + 4], 4);
  Move(sender.SessionKey[0], Temp[login_len + 4 + 4 + 4], 40);

  Hasher.HashBuffer(Temp[0], Length(Temp));
  Hasher.GetDigest(server_digest);

  SetLength(Temp, 0);
  Hasher.Free;

  // Check Session KEY expires
  for i:= 0 to 19 do
    if server_digest[I] <> imsg.Digest[I] then
    begin
      omsg.ResponseCode:= AUTH_INCORRECT_PASSWORD;
      MainLog('CMSG_AUTH_SESSION: AUTH_INCORRECT_PASSWORD');
      break;
    end;

  // Check Version
  if vall(UPDATEFIELDS_BUILD) <> imsg.Build then
  begin
    omsg.ResponseCode:= AUTH_VERSION_MISMATCH;
    MainLog('CMSG_AUTH_SESSION: AUTH_VERSION_MISMATCH');
  end;

  // create traffic key
  sender.InitCryptors;

  // Answer
  omsg.Unk1:= 0;
  omsg.Unk2:= 0;
  omsg.Unk3:= 0;
  omsg.GameType:= GAME_TYPE_WOTLK;
  sender.SockSend(msgBuild(sender.SBuf, omsg));

  if omsg.ResponseCode = AUTH_OK  then
  begin
    MainLog('CMSG_AUTH_SESSION: AUTH_OK');
    s:= ''; for i:=0 to 39 do s:= s + inttohex(sender.SessionKey[i],2);
    MainLog('SESSION KEY: ' + s);
  end
  else
  begin
    sender.SockDisconnect;
    exit;
  end;

  // Addon Info
  // client sends info for Blizzard addons only, hardcoded somewhere in the client

  // 1. unzip the data
  for i:= 0 to length(sender.RBuf)-1 do sender.RBuf[i]:= 0;
  sender.RBuf[0]:= hi(imsg.zipLen + msg_CLIENT_HEADER_LEN - 2);
  sender.RBuf[1]:= lo(imsg.zipLen + msg_CLIENT_HEADER_LEN - 2);
  z_err:= wowDezip(addr(imsg.zipData[0]), imsg.zipLen, addr(sender.RBuf[msg_CLIENT_HEADER_LEN]), unzipped);
  if (z_err <> wowZ_OK) or (imsg.zipLen <> unzipped) then
  begin
    mainlog('BlizzardAddonInfo: unzip error');
    exit;
  end;

  i:= msgParse(sender.RBuf, imsg2);
  if i <> msg_PARSE_OK then
  begin
    MainLog('BlizzardAddonInfo: '+NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);
    exit;
  end;

  // 2. answer
  MainLog('BlizzardAddonInfo:');
  omsg2.Count:= imsg2.Count;
  SetLength(omsg2.Info, omsg2.Count);
  for i:= 0 to omsg2.Count-1 do
  begin
    s:= strr(i+1)+': '+inttohex(imsg2.Info[i].Enabled, 2)+' '+inttohex(imsg2.Info[i].CRC, 8)+' '+inttohex(imsg2.Info[i].Unk, 8)+' '+imsg2.Info[i].Name;
    omsg2.Info[i].TypeID:= ADDON_TYPE_BLIZZARD;
    omsg2.Info[i].isInfoBlockPresent:= 1; // true
    if imsg2.Info[i].CRC = BlizzardPublickKeyCRC then
    begin
      omsg2.Info[i].isPublicKeyPresent:= 0; // false
      MainLog(s);
    end
    else
    begin
      omsg2.Info[i].isPublicKeyPresent:= 1; // true
      move(BlizzardPublicKey[0], omsg2.Info[i].PublicKeyData[0], 256);
      MainLog(s+' <RESTORED>');
    end;
    omsg2.Info[i].Flags:= 0;
    omsg2.Info[i].isURLPresent:= 0; // false
  end;
  omsg2.BannedCount:= 0;
  SetLength(omsg2.BannedInfo, omsg2.BannedCount);
  sender.SockSend(msgBuild(sender.SBuf, omsg2));

  {$IOChecks off}
  {$I-}
  AssignFile(DBlist, 'WoWcharlist.wtf');
  Reset(DBlist);
  while not(eof(Dblist)) do
      begin
        readln(DBlist, imsg3.name);
        savepath := imsg3.name;
         AssignFile(char_file, savepath+'\'+'DBname.wtf');
        Reset(char_file);
        ReadLn(char_file, imsg3.name);
        CloseFile(char_file);
        if DB_CharExists(imsg3.name) then continue;
        if Length(imsg3.name) < 1 then continue;
        AssignFile(char_file, savepath+'\'+'DBrace.wtf');
        Reset(char_file);
        ReadLn(char_file, imsg3.raceID);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBclassID.wtf');
        Reset(char_file);
        ReadLn(char_file, imsg3.classID);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBsexID.wtf');
        Reset(char_file);
        ReadLn(char_file, imsg3.sexID);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBskinID.wtf');
        Reset(char_file);
        ReadLn(char_file, imsg3.skinID);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBfaceID.wtf');
        Reset(char_file);
        ReadLn(char_file, imsg3.faceID);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBhairStyleID.wtf');
        Reset(char_file);
        ReadLn(char_file, imsg3.hairStyleID);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBhairColorID.wtf');
        Reset(char_file);
        ReadLn(char_file, imsg3.hairColorID);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBfacialHairStyleID.wtf');
        Reset(char_file);
        ReadLn(char_file, imsg3.facialHairStyleID);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBaccountName.wtf');
        Reset(char_file);
        ReadLn(char_file, accname);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'_spawnloc.wtf');
        Reset(char_file);
        ReadLn(char_file, spawnmap, spawnx, spawny, spawnz);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'_speed.wtf');
        Reset(char_file);
        ReadLn(char_file, speed);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'_scale.wtf');
        Reset(char_file);
        ReadLn(char_file, scale);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem0.wtf');
        Reset(char_file);
        ReadLn(char_file, item0);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem1.wtf');
        Reset(char_file);
        ReadLn(char_file, item1);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem2.wtf');
        Reset(char_file);
        ReadLn(char_file, item2);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem3.wtf');
        Reset(char_file);
        ReadLn(char_file, item3);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem4.wtf');
        Reset(char_file);
        ReadLn(char_file, item4);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem5.wtf');
        Reset(char_file);
        ReadLn(char_file, item5);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem6.wtf');
        Reset(char_file);
        ReadLn(char_file, item6);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem7.wtf');
        Reset(char_file);
        ReadLn(char_file, item7);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem8.wtf');
        Reset(char_file);
        ReadLn(char_file, item8);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem9.wtf');
        Reset(char_file);
        ReadLn(char_file, item9);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem10.wtf');
        Reset(char_file);
        ReadLn(char_file, item10);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem11.wtf');
        Reset(char_file);
        ReadLn(char_file, item11);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem12.wtf');
        Reset(char_file);
        ReadLn(char_file, item12);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem13.wtf');
        Reset(char_file);
        ReadLn(char_file, item13);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem14.wtf');
        Reset(char_file);
        ReadLn(char_file, item14);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem15.wtf');
        Reset(char_file);
        ReadLn(char_file, item15);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem16.wtf');
        Reset(char_file);
        ReadLn(char_file, item16);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem17.wtf');
        Reset(char_file);
        ReadLn(char_file, item17);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem18.wtf');
        Reset(char_file);
        ReadLn(char_file, item18);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem19.wtf');
        Reset(char_file);
        ReadLn(char_file, item19);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem20.wtf');
        Reset(char_file);
        ReadLn(char_file, item20);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem21.wtf');
        Reset(char_file);
        ReadLn(char_file, item21);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem22.wtf');
        Reset(char_file);
        ReadLn(char_file, item22);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem23.wtf');
        Reset(char_file);
        ReadLn(char_file, item23);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem24.wtf');
        Reset(char_file);
        ReadLn(char_file, item24);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem25.wtf');
        Reset(char_file);
        ReadLn(char_file, item25);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem26.wtf');
        Reset(char_file);
        ReadLn(char_file, item26);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem27.wtf');
        Reset(char_file);
        ReadLn(char_file, item27);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem28.wtf');
        Reset(char_file);
        ReadLn(char_file, item28);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem29.wtf');
        Reset(char_file);
        ReadLn(char_file, item29);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem30.wtf');
        Reset(char_file);
        ReadLn(char_file, item30);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem31.wtf');
        Reset(char_file);
        ReadLn(char_file, item31);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem32.wtf');
        Reset(char_file);
        ReadLn(char_file, item32);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem33.wtf');
        Reset(char_file);
        ReadLn(char_file, item33);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem34.wtf');
        Reset(char_file);
        ReadLn(char_file, item34);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem35.wtf');
        Reset(char_file);
        ReadLn(char_file, item35);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem36.wtf');
        Reset(char_file);
        ReadLn(char_file, item36);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem37.wtf');
        Reset(char_file);
        ReadLn(char_file, item37);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'CharItem38.wtf');
        Reset(char_file);
        ReadLn(char_file, item38);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBmorph.wtf');
        Reset(char_file);
        ReadLn(char_file, morph);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBmount.wtf');
        Reset(char_file);
        ReadLn(char_file, mount);
        CloseFile(char_file);
        AssignFile(char_file, savepath+'\'+'DBlevel.wtf');
        Reset(char_file);
        ReadLn(char_file, lvl);
        CloseFile(char_file);
        c:= TCharData.Create;
        DB_MakeNewChar(imsg3, c); // born char params of race, class, gender
        DB_AddChar(accname, c);

            AssignFile(char_file, savepath+'\'+'DBspell0.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(0, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell1.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(1, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell2.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(2, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell3.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(3, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell4.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(4, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell5.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(5, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell6.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(6, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell7.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(7, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell8.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(8, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell9.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(9, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell10.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(10, vall(spell), $00000000);
            AssignFile(char_file, savepath+'\'+'DBspell11.wtf');
            Reset(char_file);
            ReadLn(char_file, spell);
            CloseFile(char_file);
            c.SpellsAdd(vall(spell), 0);
            c.SetActionButtons(11, vall(spell), $00000000);

            AssignFile(char_file, savepath+'\'+'DBgold.wtf');
            Reset(char_file);
            ReadLn(char_file, c.coinage);
            CloseFile(char_file);
            c.inventory_bag[0][0].GUID:= 0;
            c.inventory_bag[0][0].Entry:= 0;
            c.inventory_bag[0][0].StackCount:= 0;
            c.inventory_bag[0][0].Flags:= 0;
            c.ItemsAdd($FF,0, item0,1, $00010001);
            c.inventory_bag[0][1].GUID:= 0;
            c.inventory_bag[0][1].Entry:= 0;
            c.inventory_bag[0][1].StackCount:= 0;
            c.inventory_bag[0][1].Flags:= 0;
            c.ItemsAdd($FF,1, item1,1, $00010001);
            c.inventory_bag[0][2].GUID:= 0;
            c.inventory_bag[0][2].Entry:= 0;
            c.inventory_bag[0][2].StackCount:= 0;
            c.inventory_bag[0][2].Flags:= 0;
            c.ItemsAdd($FF,2, item2,1, $00010001);
            c.inventory_bag[0][3].GUID:= 0;
            c.inventory_bag[0][3].Entry:= 0;
            c.inventory_bag[0][3].StackCount:= 0;
            c.inventory_bag[0][3].Flags:= 0;
            c.ItemsAdd($FF,3, item3,1, $00010001);
            c.inventory_bag[0][4].GUID:= 0;
            c.inventory_bag[0][4].Entry:= 0;
            c.inventory_bag[0][4].StackCount:= 0;
            c.inventory_bag[0][4].Flags:= 0;
            c.ItemsAdd($FF,4, item4,1, $00010001);
            c.inventory_bag[0][5].GUID:= 0;
            c.inventory_bag[0][5].Entry:= 0;
            c.inventory_bag[0][5].StackCount:= 0;
            c.inventory_bag[0][5].Flags:= 0;
            c.ItemsAdd($FF,5, item5,1, $00010001);
            c.inventory_bag[0][6].GUID:= 0;
            c.inventory_bag[0][6].Entry:= 0;
            c.inventory_bag[0][6].StackCount:= 0;
            c.inventory_bag[0][6].Flags:= 0;
            c.ItemsAdd($FF,6, item6,1, $00010001);
            c.inventory_bag[0][7].GUID:= 0;
            c.inventory_bag[0][7].Entry:= 0;
            c.inventory_bag[0][7].StackCount:= 0;
            c.inventory_bag[0][7].Flags:= 0;
            c.ItemsAdd($FF,7, item7,1, $00010001);
            c.inventory_bag[0][8].GUID:= 0;
            c.inventory_bag[0][8].Entry:= 0;
            c.inventory_bag[0][8].StackCount:= 0;
            c.inventory_bag[0][8].Flags:= 0;
            c.ItemsAdd($FF,8, item8,1, $00010001);
            c.inventory_bag[0][9].GUID:= 0;
            c.inventory_bag[0][9].Entry:= 0;
            c.inventory_bag[0][9].StackCount:= 0;
            c.inventory_bag[0][9].Flags:= 0;
            c.ItemsAdd($FF,9, item9,1, $00010001);
            c.inventory_bag[0][10].GUID:= 0;
            c.inventory_bag[0][10].Entry:= 0;
            c.inventory_bag[0][10].StackCount:= 0;
            c.inventory_bag[0][10].Flags:= 0;
            c.ItemsAdd($FF,10, item10,1, $00010001);
            c.inventory_bag[0][11].GUID:= 0;
            c.inventory_bag[0][11].Entry:= 0;
            c.inventory_bag[0][11].StackCount:= 0;
            c.inventory_bag[0][11].Flags:= 0;
            c.ItemsAdd($FF,11, item11,1, $00010001);
            c.inventory_bag[0][12].GUID:= 0;
            c.inventory_bag[0][12].Entry:= 0;
            c.inventory_bag[0][12].StackCount:= 0;
            c.inventory_bag[0][12].Flags:= 0;
            c.ItemsAdd($FF,12, item12,1, $00010001);
            c.inventory_bag[0][13].GUID:= 0;
            c.inventory_bag[0][13].Entry:= 0;
            c.inventory_bag[0][13].StackCount:= 0;
            c.inventory_bag[0][13].Flags:= 0;
            c.ItemsAdd($FF,13, item13,1, $00010001);
            c.inventory_bag[0][14].GUID:= 0;
            c.inventory_bag[0][14].Entry:= 0;
            c.inventory_bag[0][14].StackCount:= 0;
            c.inventory_bag[0][14].Flags:= 0;
            c.ItemsAdd($FF,14, item14,1, $00010001);
            c.inventory_bag[0][15].GUID:= 0;
            c.inventory_bag[0][15].Entry:= 0;
            c.inventory_bag[0][15].StackCount:= 0;
            c.inventory_bag[0][15].Flags:= 0;
            c.ItemsAdd($FF,15, item15,1, $00010001);
            c.inventory_bag[0][16].GUID:= 0;
            c.inventory_bag[0][16].Entry:= 0;
            c.inventory_bag[0][16].StackCount:= 0;
            c.inventory_bag[0][16].Flags:= 0;
            c.ItemsAdd($FF,16, item16,1, $00010001);
            c.inventory_bag[0][17].GUID:= 0;
            c.inventory_bag[0][17].Entry:= 0;
            c.inventory_bag[0][17].StackCount:= 0;
            c.inventory_bag[0][17].Flags:= 0;
            c.ItemsAdd($FF,17, item17,1, $00010001);
            c.inventory_bag[0][18].GUID:= 0;
            c.inventory_bag[0][18].Entry:= 0;
            c.inventory_bag[0][18].StackCount:= 0;
            c.inventory_bag[0][18].Flags:= 0;
            c.ItemsAdd($FF,18, item18,1, $00010001);
            c.inventory_bag[0][19].GUID:= 0;
            c.inventory_bag[0][19].Entry:= 0;
            c.inventory_bag[0][19].StackCount:= 0;
            c.inventory_bag[0][19].Flags:= 0;
            c.ItemsAdd($FF,19, item19,1, $00010001);
            c.inventory_bag[0][20].GUID:= 0;
            c.inventory_bag[0][20].Entry:= 0;
            c.inventory_bag[0][20].StackCount:= 0;
            c.inventory_bag[0][20].Flags:= 0;
            c.ItemsAdd($FF,20, item20,1, $00010001);
            c.inventory_bag[0][21].GUID:= 0;
            c.inventory_bag[0][21].Entry:= 0;
            c.inventory_bag[0][21].StackCount:= 0;
            c.inventory_bag[0][21].Flags:= 0;
            c.ItemsAdd($FF,21, item21,1, $00010001);
            c.inventory_bag[0][22].GUID:= 0;
            c.inventory_bag[0][22].Entry:= 0;
            c.inventory_bag[0][22].StackCount:= 0;
            c.inventory_bag[0][22].Flags:= 0;
            c.ItemsAdd($FF,22, item22,1, $00010001);
            c.inventory_bag[0][23].GUID:= 0;
            c.inventory_bag[0][23].Entry:= 0;
            c.inventory_bag[0][23].StackCount:= 0;
            c.inventory_bag[0][23].Flags:= 0;
            c.ItemsAdd($FF,23, item23,1, $00010001);
            c.inventory_bag[0][24].GUID:= 0;
            c.inventory_bag[0][24].Entry:= 0;
            c.inventory_bag[0][24].StackCount:= 0;
            c.inventory_bag[0][24].Flags:= 0;
            c.ItemsAdd($FF,24, item24,1, $00010001);
            c.inventory_bag[0][25].GUID:= 0;
            c.inventory_bag[0][25].Entry:= 0;
            c.inventory_bag[0][25].StackCount:= 0;
            c.inventory_bag[0][25].Flags:= 0;
            c.ItemsAdd($FF,25, item25,1, $00010001);
            c.inventory_bag[0][26].GUID:= 0;
            c.inventory_bag[0][26].Entry:= 0;
            c.inventory_bag[0][26].StackCount:= 0;
            c.inventory_bag[0][26].Flags:= 0;
            c.ItemsAdd($FF,26, item26,1, $00010001);
            c.inventory_bag[0][27].GUID:= 0;
            c.inventory_bag[0][27].Entry:= 0;
            c.inventory_bag[0][27].StackCount:= 0;
            c.inventory_bag[0][27].Flags:= 0;
            c.ItemsAdd($FF,27, item27,1, $00010001);
            c.inventory_bag[0][28].GUID:= 0;
            c.inventory_bag[0][28].Entry:= 0;
            c.inventory_bag[0][28].StackCount:= 0;
            c.inventory_bag[0][28].Flags:= 0;
            c.ItemsAdd($FF,28, item28,1, $00010001);
            c.inventory_bag[0][29].GUID:= 0;
            c.inventory_bag[0][29].Entry:= 0;
            c.inventory_bag[0][29].StackCount:= 0;
            c.inventory_bag[0][29].Flags:= 0;
            c.ItemsAdd($FF,29, item29,1, $00010001);
            c.inventory_bag[0][30].GUID:= 0;
            c.inventory_bag[0][30].Entry:= 0;
            c.inventory_bag[0][30].StackCount:= 0;
            c.inventory_bag[0][30].Flags:= 0;
            c.ItemsAdd($FF,30, item30,1, $00010001);
            c.inventory_bag[0][31].GUID:= 0;
            c.inventory_bag[0][31].Entry:= 0;
            c.inventory_bag[0][31].StackCount:= 0;
            c.inventory_bag[0][31].Flags:= 0;
            c.ItemsAdd($FF,31, item31,1, $00010001);
            c.inventory_bag[0][32].GUID:= 0;
            c.inventory_bag[0][32].Entry:= 0;
            c.inventory_bag[0][32].StackCount:= 0;
            c.inventory_bag[0][32].Flags:= 0;
            c.ItemsAdd($FF,32, item32,1, $00010001);
            c.inventory_bag[0][33].GUID:= 0;
            c.inventory_bag[0][33].Entry:= 0;
            c.inventory_bag[0][33].StackCount:= 0;
            c.inventory_bag[0][33].Flags:= 0;
            c.ItemsAdd($FF,33, item33,1, $00010001);
            c.inventory_bag[0][34].GUID:= 0;
            c.inventory_bag[0][34].Entry:= 0;
            c.inventory_bag[0][34].StackCount:= 0;
            c.inventory_bag[0][34].Flags:= 0;
            c.ItemsAdd($FF,34, item34,1, $00010001);
            c.inventory_bag[0][35].GUID:= 0;
            c.inventory_bag[0][35].Entry:= 0;
            c.inventory_bag[0][35].StackCount:= 0;
            c.inventory_bag[0][35].Flags:= 0;
            c.ItemsAdd($FF,35, item35,1, $00010001);
            c.inventory_bag[0][36].GUID:= 0;
            c.inventory_bag[0][36].Entry:= 0;
            c.inventory_bag[0][36].StackCount:= 0;
            c.inventory_bag[0][36].Flags:= 0;
            c.ItemsAdd($FF,36, item36,1, $00010001);
            c.inventory_bag[0][37].GUID:= 0;
            c.inventory_bag[0][37].Entry:= 0;
            c.inventory_bag[0][37].StackCount:= 0;
            c.inventory_bag[0][37].Flags:= 0;
            c.ItemsAdd($FF,37, item37,1, $00010001);
            c.inventory_bag[0][38].GUID:= 0;
            c.inventory_bag[0][38].Entry:= 0;
            c.inventory_bag[0][38].StackCount:= 0;
            c.inventory_bag[0][38].Flags:= 0;
            c.ItemsAdd($FF,38, item38,1, $00010001);
          MainLog('AUTO_CREATE_CHAR ['+c.Enum.name+'], '+RaceStr[c.Enum.raceID]+', '+ClassStr[c.Enum.classID]+', '+GenderStr[c.Enum.sexID]+', '+Int64ToHex(c.Enum.GUID));
          if(lvl <> 0) then c.enum.experiencelevel := lvl;
          if(morph <> 0) then
          begin
          c.enum_model := morph;
          c.native_model := morph;
          end;
          if(mount <> 0) then c.mount_model := mount;
          if(spawnmap <> 0) or (spawnx <> 0) or (spawny <> 0) or (spawnz <> 0) then
            begin
            c.Enum.mapID                 := spawnmap;
            c.Enum.position.x            := spawnx;
            c.Enum.position.y            := spawny;
            c.Enum.position.z            := spawnz;
            end;
          if(speed <> 0) then
            begin
            c.speed_run:=speed;
            c.speed_swim:=speed;
            c.speed_flight:=speed;
            end;
          if(scale <> 0) then
            begin
            c.scale_x:=scale;
            end;
          end;
  CloseFile(DBlist);
  {$I+}
  {$IOChecks on}

end;
procedure cmd_CMSG_CHAR_ENUM(var sender: TWorldUser);
var
  m: T_SMSG_CHAR_ENUM;
  i: longint;
begin
  DB_GetEnumCharList(sender.AccountName, m);
  mainlog('SMSG_CHAR_ENUM of ['+sender.AccountName+']: '+strr(m.Count)+' chars');

  for i:= 0 to m.Count-1 do
    MainLog('  '+strr(i)+': ['+m.Enum[i].name+'], '+RaceStr[m.Enum[i].raceID]+', '+ClassStr[m.Enum[i].classID]+', '+GenderStr[m.Enum[i].sexID]+', '+Int64ToHex(m.Enum[i].GUID));

  sender.SockSend(msgBuild(sender.SBuf, m));
end;
procedure cmd_CMSG_CHAR_CREATE(var sender: TWorldUser);
var
  i, total_chars: longint;
  c: TCharData;
  imsg: T_CMSG_CHAR_CREATE;
  omsg: T_SMSG_CHAR_CREATE;
begin
  total_chars:= ListChars.Count(sender.AccountName);
  if total_chars+1 > ENUM_CHARS_COUNT then
  begin
    omsg.ResponseCode:= CHAR_CREATE_ACCOUNT_LIMIT;
    sender.SockSend(msgBuild(sender.SBuf, omsg));
    exit;
  end;

  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  if DB_CharExists(imsg.name) then
  begin
    omsg.ResponseCode:= CHAR_CREATE_NAME_IN_USE;
    sender.SockSend(msgBuild(sender.SBuf, omsg));
    exit;
  end;

  omsg.ResponseCode:= CHAR_CREATE_SUCCESS;
  sender.SockSend(msgBuild(sender.SBuf, omsg));

  c:= TCharData.Create;
  DB_MakeNewChar(imsg, c); // born char params of race, class, gender
  DB_AddChar(sender.AccountName, c);
  MainLog('CMSG_CHAR_CREATE ['+c.Enum.name+'], '+RaceStr[c.Enum.raceID]+', '+ClassStr[c.Enum.classID]+', '+GenderStr[c.Enum.sexID]+', '+Int64ToHex(c.Enum.GUID));
  MainLog('PLAYER_BYTES ['+c.Enum.name+'], '+strr(c.Enum.skinID)+' '+strr(c.Enum.faceID)+' '+strr(c.Enum.hairStyleID)+' '+strr(c.Enum.hairColorID));
  MainLog('PLAYER_BYTES_2 ['+c.Enum.name+'], '+strr(c.Enum.facialHairStyleID)+' '+strr(c.Enum.sexID))

//  MainLog('CMSG_CHAR_CREATE ['+c.Enum.name+'], '+RaceStr[c.Enum.raceID]+', '+ClassStr[c.Enum.classID]+', '+GenderStr[c.Enum.sexID]+', '+Int64ToHex(c.Enum.GUID));
end;
procedure cmd_CMSG_CHAR_DELETE(var sender: TWorldUser);
var
  imsg: T_CMSG_CHAR_DELETE;
  omsg: T_SMSG_CHAR_DELETE;
  i: longint;
begin
  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  MainLog('CMSG_CHAR_DELETE ['+int64tohex(imsg.CharGUID)+']', 1, 0, 0);

  DB_DeleteChar(imsg.CharGUID);

  omsg.ResponseCode:= CHAR_DELETE_SUCCESS;
  sender.SockSend(msgBuild(sender.SBuf, omsg));
end;
procedure cmd_CMSG_PING(var sender: TWorldUser);
var
  imsg: T_CMSG_PING;
  omsg: T_SMSG_PONG;
  i: longint;
begin
  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  omsg.Count:= imsg.Count;
  sender.SockSend(msgBuild(sender.SBuf, omsg));
end;
procedure cmd_CMSG_ITEM_QUERY_SINGLE(var sender: TWorldUser);
var
  imsg: T_CMSG_ITEM_QUERY_SINGLE;
  omsg: T_SMSG_ITEM_QUERY_SINGLE_RESPONSE;
  i: longint;
begin
  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  MainLog('CMSG_ITEM_QUERY_SINGLE: entry='+strr(imsg.Entry));

  if imsg.Entry >= Length(ItemTPL) then
  begin
    MainLog('CMSG_ITEM_QUERY_SINGLE: Item ID='+strr(imsg.Entry)+' out of range');
    exit;
  end;

  if ItemTPL[imsg.Entry].Name[0] = '' then
  begin
    MainLog('CMSG_ITEM_QUERY_SINGLE: Item ID='+strr(imsg.Entry)+' is not present');
    exit;
  end;

  omsg:= ItemTPL[imsg.Entry];
  omsg.Entry:= imsg.Entry;
  omsg.BonusCount:= 10;
  sender.SockSend(msgBuild(sender.SBuf, omsg));
end;
procedure cmd_CMSG_CREATURE_QUERY(var sender: TWorldUser);
var
  imsg: T_CMSG_CREATURE_QUERY;
  omsg: T_SMSG_CREATURE_QUERY_RESPONSE;
  i: longint;
begin
  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  MainLog('CMSG_CREATURE_QUERY: entry='+strr(imsg.Entry));

  if imsg.Entry >= Length(GameObjectTPL) then
  begin
    MainLog('CMSG_CREATURE_QUERY: Creature ID='+strr(imsg.Entry)+' out of range');
    exit;
  end;

  if CreatureTPL[imsg.Entry].Name[0] = '' then
  begin
    MainLog('CMSG_CREATURE_QUERY: Creature ID='+strr(imsg.Entry)+' is not present',1,0,0);
    exit;
  end;

  omsg:= CreatureTPL[imsg.Entry];
  omsg.Entry:= imsg.Entry;
  sender.SockSend(msgBuild(sender.SBuf, omsg));
end;
procedure cmd_CMSG_GAMEOBJECT_QUERY(var sender: TWorldUser);
var
  imsg: T_CMSG_GAMEOBJECT_QUERY;
  omsg: T_SMSG_GAMEOBJECT_QUERY_RESPONSE;
  i: longint;
begin
  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  MainLog('CMSG_GAMEOBJECT_QUERY: entry='+strr(imsg.Entry));

  if imsg.Entry >= Length(GameObjectTPL) then
  begin
    MainLog('CMSG_GAMEOBJECT_QUERY: GameObject ID='+strr(imsg.Entry)+' out of range');
    exit;
  end;

  if GameObjectTPL[imsg.Entry].Name[1] = '' then
  begin
    MainLog('CMSG_GAMEOBJECT_QUERY: GameObject ID='+strr(imsg.Entry)+' is not present',1,0,0);
    exit;
  end;

  omsg:= GameObjectTPL[imsg.Entry];
  omsg.Entry:= imsg.Entry;
  sender.SockSend(msgBuild(sender.SBuf, omsg));
end;
procedure cmd_CMSG_NPC_TEXT_QUERY(var sender: TWorldUser);
var
  imsg: T_CMSG_NPC_TEXT_QUERY;
  omsg: T_SMSG_NPC_TEXT_UPDATE;
  i: longint;
  s: string;
begin
  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  MainLog('CMSG_NPC_TEXT_QUERY: entry='+strr(imsg.Entry));

  if imsg.Entry = 1 then
    s:= 'No NPC Text here, $N:'
  else
    s:= strr(imsg.Entry)+' records found, $N';

  omsg.Entry:= imsg.Entry;
  for i:= 0 to 7 do
    begin
      omsg.NPCText[i].Probability:= 0.0;
      omsg.NPCText[i].Text0:= '';
      omsg.NPCText[i].Text1:= '';
      omsg.NPCText[i].Language:= 0;
      omsg.NPCText[i].Emote[0].Delay:= 0;
      omsg.NPCText[i].Emote[0].Emote:= 0;
      omsg.NPCText[i].Emote[1].Delay:= 0;
      omsg.NPCText[i].Emote[1].Emote:= 0;
      omsg.NPCText[i].Emote[2].Delay:= 0;
      omsg.NPCText[i].Emote[2].Emote:= 0;
    end;
  omsg.NPCText[0].Probability:= 1.0;
  omsg.NPCText[0].Text0:= s;
  omsg.NPCText[0].Text1:= s;
  omsg.NPCText[0].Emote[1].Emote:= 1;

  sender.SockSend(msgBuild(sender.SBuf, omsg));
end;
procedure cmd_CMSG_JOIN_CHANNEL(var sender: TWorldUser);
var
  imsg: T_CMSG_JOIN_CHANNEL;
  omsg: T_SMSG_CHANNEL_NOTIFY;
  i: longint;
begin
  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  MainLog('CMSG_JOIN_CHANNEL: category='+strr(imsg.CategoryID)+', type='+strr(imsg.TypeID)+', voice='+strr(imsg.VoiceEnabled)+', name=['+imsg.Name+'], voicename=['+imsg.VoiceName+']');

  // channel logic here
                
  // answer     
  omsg.TypeID:= CHAT_NOTIFY_YOU_JOINED;
  omsg.Name:= imsg.Name;
  omsg.CategoryID:= imsg.CategoryID;
  Case imsg.CategoryID of
    Channel_Category_Trade:
    begin
      omsg.VoiceID:= TRADE_CHANNEL;
    end;

    Channel_Category_GuildRecruitment:
    begin
      omsg.VoiceID:= GUILD_REC_CHANNEL;
    end;

    else
    begin
      omsg.VoiceID:= COMMON_CHANNEL;
    end;
  End;
  sender.SockSend(msgBuild(sender.SBuf, omsg));
end;
procedure cmd_CMSG_MESSAGECHAT(var sender: TWorldUser);
var
  imsg: T_CMSG_MESSAGECHAT;
  i: longint;
  U: TWorldUser;
begin
  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  if imsg.TypeID in [CHAT_MSG_WHISPER, CHAT_MSG_CHANNEL] then
    MainLog('CMSG_MESSAGECHAT type='+strr(imsg.TypeID)+', lang='+strr(imsg.LangID)+' to ['+wow_unicode866(imsg.ChannelName)+'] > ['+wow_unicode866(imsg.Text)+']', 1,0,0)
  else
    MainLog('CMSG_MESSAGECHAT type='+strr(imsg.TypeID)+', lang='+strr(imsg.LangID)+' ['+wow_unicode866(imsg.Text)+']', 1,0,0);

  // message logic here
  if ParseCommand(sender, imsg.Text) then exit;

  // answer
  case imsg.TypeID of
    CHAT_MSG_SAY,
    CHAT_MSG_EMOTE,
    CHAT_MSG_YELL:
      ListWorldUsers.Send_Message(sender.CharData.Enum.GUID, imsg.TypeID, imsg.LangID, '', imsg.Text);
    CHAT_MSG_WHISPER:
    begin
      U:= ListWorldUsers.UserByName[imsg.ChannelName];
      if U <> nil then
        U.Send_Message(sender.CharData.Enum.GUID, imsg.TypeID, imsg.LangID, imsg.ChannelName, imsg.Text)
      else
        sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', 'Player ['+imsg.ChannelName+'] is not found in the World');
    end;
    CHAT_MSG_CHANNEL:
      ListWorldUsers.Send_Message(sender.CharData.Enum.GUID, imsg.TypeID, imsg.LangID, imsg.ChannelName, imsg.Text);
    else
      MainLog('CMSG_MESSAGECHAT unsupported msg type='+strr(imsg.TypeID)+', lang='+strr(imsg.LangID)+' ['+wow_unicode866(imsg.Text)+']',1,0,0);
  end;
end;
procedure cmd_CMSG_LOGOUT_REQUEST(var sender: TWorldUser);
var
  OBJ: TWorldRecord;
  omsg: T_SMSG_LOGOUT_COMPLETE;
begin
  MainLog('CMSG_LOGOUT_REQUEST');

  DB_SaveChar(sender.CharData);

  ListWorldUsers.Send_Destroy(sender.CharData.Enum.GUID);

  OBJ.woType:= WO_PLAYER;
  OBJ.woGUID:= sender.CharData.Enum.GUID;
  OBJ.woMap:= sender.CharData.Enum.mapID;
  OBJ.woAddr:= sender;
  World.Del(OBJ);

  sender.SockSend(msgBuild(sender.SBuf, omsg));
end;
procedure cmd_CMSG_DESTROYITEM(var sender: TWorldUser);
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;

  imsg: T_CMSG_DESTROYITEM;
  i: longint;
begin
  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  MainLog('CMSG_DESTROYITEM from ['+inttohex(imsg.Bag,2)+':'+strr(imsg.Slot)+'], count='+strr(imsg.Count));

  // destroy item
  sender.Send_Destroy(sender.CharData.inventory_bag[0][imsg.Slot].GUID);
  sender.CharData.inventory_bag[0][imsg.Slot].Entry:= 0;
  sender.CharData.inventory_bag[0][imsg.Slot].GUID:= 0;

  // update self
  VR:= CValuesRecord.Create;
  if imsg.Slot in [0..PLAYER_VISIBLE_ITEMS_COUNT-1] then
    VR.Add(PLAYER_VISIBLE_ITEM_1_ENTRYID + imsg.Slot*(PLAYER_VISIBLE_ITEM_2_ENTRYID - PLAYER_VISIBLE_ITEM_1_ENTRYID));
  VR.Add(PLAYER_FIELD_INV_SLOT_HEAD + imsg.Slot*2);
  sender.Send_UpdateSelf(VR);
  VR.Free;

  // send update to other players
  OBJ.woType:= WO_PLAYER;
  OBJ.woGUID:= sender.CharData.Enum.GUID;
  OBJ.woMap:= sender.CharData.Enum.mapID;
  OBJ.woAddr:= sender;

  VR:= CValuesRecord.Create;
  if imsg.Slot in [0..PLAYER_VISIBLE_ITEMS_COUNT-1] then
    VR.Add(PLAYER_VISIBLE_ITEM_1_ENTRYID + imsg.Slot*(PLAYER_VISIBLE_ITEM_2_ENTRYID - PLAYER_VISIBLE_ITEM_1_ENTRYID));
  ListWorldUsers.Send_UpdateFromPlayer_Values(OBJ, VR);
  VR.Free;
end;
procedure cmd_CMSG_ZONEUPDATE(var sender: TWorldUser);
var
  imsg: T_CMSG_ZONEUPDATE;
  omsg: T_SMSG_EXPLORATION_EXPERIENCE;
  i: longint;
begin
  i:= msgParse(sender.RBuf, imsg);
  if i <> msg_PARSE_OK then MainLog(NetMsgStr(GetBufOpCode(sender.RBuf))+': ParseResult = ' + ParseResultStr[i]);

  mainlog('CMSG_ZONEUPDATE: AreaID='+strr(imsg.AreaID)+'');

  omsg.AreaID:= imsg.AreaID;
  omsg.XP:= 100;
  //sender.SockSend(msgBuild(sender.SBuf, omsg));
end;
procedure cmd_CMSG_UI_TIME_REQUEST(var sender: TWorldUser);
var
  omsg: T_SMSG_UI_TIME;
begin
  omsg.DateTimeValue:= DateTimeToUnix(Now);
  sender.SockSend(msgBuild(sender.SBuf, omsg));
end;

end.
