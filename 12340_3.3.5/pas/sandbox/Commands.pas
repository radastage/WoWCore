unit Commands;

interface

uses
  ClassConnection, Forms, Math, Unit1;

function  ParseCommand(var sender: TWorldUser; msg: String): boolean;

implementation

uses
  Logs, Convert,
  Struct, Defines,
  TMSGStruct, TMSGBuilder,
  UpdateFields,
  NetMessages,
  Responses,
  UpdatePacket,
  ClassWorld,
  PacketBuilding,
  DB, dateutils,
  SysUtils, Classes;

function GetWord(ST: String; RT: String; NT: byte): string;
var
  sw, s: string;
  wordList: TStringList;
begin
  Result:= '';
  if st = '' then exit;

  wordList:= TStringList.Create;
  if Length(st) < Length(RT) then
    s:= st + rt
  else
    if copy(st,Length(St)-length(RT)+1,Length(RT)) <> RT then
      s:= st + rt
    else
      s:= st;

  while pos(RT, s) > 0 do
    begin
      sw:= Copy(s, 1, pos(rt, s)-1);
      Delete(s, 1, pos(rt, s)+Length(RT)-1);
      WordList.Add(sw);
    end;

  if nt <= WordList.Count
    then result:= WordList.Strings[nt-1];

  WordList.Free;
end;

function cmd_Help(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  s: string;
begin
  result:= true;

  s:= '';
  s:= s + '[.memo]    - Show Server Memo'#13;
  s:= s + '[.w]       - Where Am I?'#13;
  s:= s + '[.f]       - Toggle Flight Mode'#13;
  s:= s + '[.s N]     - Set Speed to N'#13;
  s:= s + '[.z N]     - Set Size of Unit to N'#13;
  s:= s + '[.zb]      - Set Size to 1.0f'#13;
  s:= s + '[.m N]     - Morph to model N'#13;
  s:= s + '[.mb]      - Morph back'#13;
  s:= s + '------------'#13;
  s:= s + '[.i N]     - Create Item entry N'#13;
  s:= s + '[.in NAME] - Create Item from list'#13;
  s:= s + '[.ih NAME] - Misc Item Commands'#13;
  s:= s + '[.u N]     - Create NPC entry N'#13;
  s:= s + '[.un NAME] - Create NPC from list'#13;
  s:= s + '[.unt NAME] - Create NPC from list (search by title)'#13;
  s:= s + '[.unr NAME] - Create Random NPC by name'#13;
  s:= s + '[.d]       - Destroy selected NPC'#13;
  s:= s + '[.sp]       - Learn Spell (ID, slot)'#13;
  s:= s + '[.cb]       - Cast Spell Back'#13;
  s:= s + '[.cs]       - Change Stand State'#13;
  s:= s + '[.cast]       - Cast Spell'#13;
  s:= s + '[.roll]      - Roll (1 to N)'#13;
  s:= s + '[.lvl]      - Set Level'#13;
  s:= s + '[.gold]     - Set Gold'#13;
  s:= s + '[.get]       - Get NPC'#13;
  s:= s + '[.goto]      - Go To NPC'#13;
  s:= s + '[.pb]      - Set Player Bytes (skin, face, hair, color)'#13;
  s:= s + '[.pb2]     - Set Player Bytes 2 (beard, gender)'#13;
  s:= s + '[.byte]      - Set Unit Bytes'#13;
  s:= s + '[.upd]       - Update Player'#13;
  s:= s + '------------'#13;
  s:= s + '[.moe N]   - Mount NPC by entry N'#13;
  s:= s + '[.mom N]   - Mount NPC by model N'#13;
  s:= s + '[.mon NAME] - Mount NPC from list'#13;
  s:= s + '[.dmo]     - Dismount'#13;
  s:= s + '------------'#13;
  s:= s + '[.ho]      - Set selected NPC to Hostile'#13;
  s:= s + '[.fr]      - Set selected NPC to Friend'#13;
  s:= s + '[.go map x y z] - Teleport to (map,x,y,z)'#13;
  s:= s + '[.setspawn] - Set Initial Coordinates'#13;
  s:= s + '[.hgo]     - List of Quick Teleports'#13;

  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
end;

function cmd_ItemHelp(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  s: string;
begin
  result:= true;

  s:= s + '[.i N]     - Create Item entry N'#13;
  s:= s + '[.in NAME] - Create Item from list'#13;
  s:= s + '[.inr NAME] - Create Random Item from list'#13;
  s:= s + '[.ish] - Show Inventory Slot Help'#13;
  s:= s + '[.ins] - Create Item from list by Specific Slot (use .ish for more info)'#13;
  s:= s + '[.isr] - Create Random Item by Specific Slot'#13;
  s:= s + '[.isq] - Create Item by Specific Slot and Quality'#13;
  s:= s + '------------'#13;
  s:= s + '[.iqr] - Create Random Item by Quality'#13;
  s:= s + '[.isqr] - Create Random Item by Specific Slot and Quality'#13;
  s:= s + '------------'#13;
  s:= s + '[Quality IDs:]'#13;
  s:= s + '[0] - Poor'#13;
  s:= s + '[1] - Common'#13;
  s:= s + '[2] - Uncommon'#13;
  s:= s + '[3] - Rare'#13;
  s:= s + '[4] - Superior'#13;
  s:= s + '[5] - Legendary'#13;
  s:= s + '[6] - Heirloom'#13;
  s:= s + '------------'#13;
  s:= s + '[.im] - Create Item by Material'#13;
  s:= s + '[.imn] - Create Item by Material and Name'#13;
  s:= s + '[.imq] - Create Item by Material and Quality'#13;
  s:= s + '[.imqr] - Create Random Item by Material and Quality'#13;
  s:= s + '[.imr] - Create Random Item by Material'#13;
  s:= s + '------------'#13;
  s:= s + '[Material IDs:]'#13;
  s:= s + '[-1] - Misc'#13;
  s:= s + '[0] - Unknown'#13;
  s:= s + '[1] - Unknown - Metal'#13;
  s:= s + '[2] - Unknown - Wooden'#13;
  s:= s + '[3] - Potion'#13;
  s:= s + '[4] - Unknown'#13;
  s:= s + '[5] - Mail'#13;
  s:= s + '[6] - Plate'#13;
  s:= s + '[7] - Cloth'#13;
  s:= s + '[8] - Leather'#13;
  s:= s + '[9] - Misc'#13;
  s:= s + '------------'#13;
  s:= s + '[.ilvl] - Create Item by Level'#13;
  s:= s + '[.ilvln] - Create Item by Level and Name'#13;
  s:= s + '[.ilvlr] - Create Random Item by Level'#13;

  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
end;
function cmd_Memo(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i: integer;
  TSL: TStringList;
begin
  result:= true;
  if (Length(p1) < 1) then p1:='';
  if FileExists('memo'+p1+'.txt')
  then
  begin
  TSL := TStringList.Create;
  TSL.LoadFromFile('memo'+p1+'.txt');
  for i := 0 to TSL.Count-1 do
  begin
    sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', TSL.Strings[i])
  end;
  end
  else sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', 'error: no memo');
end;
function cmd_HelpGo(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  s: string;
begin
  result:= true;

  s:='';
  s:= s + '[.human]   - Human Start'#13;
  s:= s + '[.dwarf]   - Dwarf Start'#13;
  s:= s + '[.elf]     - Night Elf Start'#13;
  s:= s + '[.orc]     - Orc Start'#13;
  s:= s + '[.undead]  - Undead Start'#13;
  s:= s + '[.tauren]  - Tauren Start'#13;
  s:= s + '[.dra]     - Draenei Start'#0;
  s:= s + '[.belf]    - Blood Elf Start'#0;
  s:= s + '------------'#13;
  s:= s + '[.gols]    - Goldshire'#13;
  s:= s + '[.storm]   - Stormwind'#13;
  s:= s + '[.iron]    - IronForge'#13;

  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
end;
function cmd_WhereIam(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  s: string;
begin
  result:= true;

  s:= ''+sender.CharData.Enum.name+' location: m='+strr(sender.CharData.Enum.mapID)+', x='+single2str(sender.CharData.Enum.position.x, 2)+', y='+single2str(sender.CharData.Enum.position.y, 2)+', z='+single2str(sender.CharData.Enum.position.z, 2)+'';
  //sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
  //sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
  MainLog('.go '+strr(sender.CharData.Enum.mapID)+' '+single2str(sender.CharData.Enum.position.x,2 )+' '+single2str(sender.CharData.Enum.position.y, 2)+' '+single2str(sender.CharData.Enum.position.z, 2)+' '+single2str(sender.CharData.facing, 2)+'');
end;
function cmd_SetFlightMode(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
begin
  result:= true;

  if sender.CharData.flight_mode then
  begin
    ListWorldUsers.Send_UpdateFromPlayer_UnsetCanFly(sender.CharData.Enum.GUID);
    sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', 'Flight Mode is OFF');
    sender.CharData.flight_mode:= false;
  end
  else
  begin
    ListWorldUsers.Send_UpdateFromPlayer_SetCanFly(sender.CharData.Enum.GUID);
    sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', 'Flight Mode is ON');
    sender.CharData.flight_mode:= true;
  end;
end;
function cmd_SetSpeed(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
speedfile: textfile;
begin
  result:= true;

  sender.CharData.speed_run:= str2single(p1);
  sender.CharData.speed_swim:= str2single(p1);
  sender.CharData.speed_flight:= str2single(p1);

  ListWorldUsers.Send_UpdateFromPlayer_ForceRunSpeed(sender.CharData.Enum.GUID, sender.CharData.speed_run);
  ListWorldUsers.Send_UpdateFromPlayer_ForceSwimSpeed(sender.CharData.Enum.GUID, sender.CharData.speed_swim);
  ListWorldUsers.Send_UpdateFromPlayer_ForceFlightSpeed(sender.CharData.Enum.GUID, sender.CharData.speed_flight);

  sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', 'Speed sets to '+single2str(str2single(p1), 2));
  
  {$IOChecks off}
  {$I-}
  AssignFile(speedfile, sender.CharData.Enum.name+'\'+'_speed.wtf');
  ReWrite(speedfile);
  WriteLn(speedfile, p1);
  CloseFile(speedfile);
  {$I+}



end;
function cmd_SetScale(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
  scalefile: textfile;
begin
  result:= true;

  if (sender.CharData.Selection <> 0) and (World[sender.CharData.Selection].woType = WO_UNIT) then
  begin
    // selected unit
    OBJ:= World[sender.CharData.Selection];

    TWorldUnit(OBJ.woAddr).woScaleX:= str2single(p1);

    VR:= CValuesRecord.Create;
    VR.Add(OBJECT_FIELD_SCALE_X);
    ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);
    VR.Free;
  end
  else
  begin
    // self
    OBJ:= World[sender.CharData.Enum.GUID];

    TWorldUser(OBJ.woAddr).CharData.scale_x:=str2single(p1);

    VR:= CValuesRecord.Create;
    VR.Add(OBJECT_FIELD_SCALE_X);
    sender.Send_UpdateSelf(VR);
    ListWorldUsers.Send_UpdateFromPlayer_Values(OBJ, VR);
    {$IOChecks off}
    {$I-}
    AssignFile(scalefile, sender.CharData.Enum.name+'\'+'_scale.wtf');
    ReWrite(scalefile);
    WriteLn(scalefile, p1);
    CloseFile(scalefile);
    {$I+}
    VR.Free;
  end;

end;
function cmd_SetScaleBack(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;

  if (sender.CharData.Selection <> 0) and (World[sender.CharData.Selection].woType = WO_UNIT) then
  begin
    OBJ:= World[sender.CharData.Selection];

    TWorldUnit(OBJ.woAddr).woScaleX:= 1.0;

    VR:= CValuesRecord.Create;
    VR.Add(OBJECT_FIELD_SCALE_X);
    ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);
    VR.Free;
  end
  else
  begin
    OBJ:= World[sender.CharData.Enum.GUID];

    TWorldUser(OBJ.woAddr).CharData.scale_x:= 1.0;

    VR:= CValuesRecord.Create;
    VR.Add(OBJECT_FIELD_SCALE_X);
    sender.Send_UpdateSelf(VR);
    ListWorldUsers.Send_UpdateFromPlayer_Values(OBJ, VR);
    VR.Free;
  end;
end;
function cmd_SetModel(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;

  if (sender.CharData.Selection <> 0) and (World[sender.CharData.Selection].woType = WO_UNIT) then
  begin
    OBJ:= World[sender.CharData.Selection];

    TWorldUnit(OBJ.woAddr).unDisplayID:= vall(p1);
    TWorldUnit(OBJ.woAddr).unNativeDisplayID:= vall(p1);

    VR:= CValuesRecord.Create;
    VR.Add(UNIT_FIELD_DISPLAYID);
    VR.Add(UNIT_FIELD_NATIVEDISPLAYID);
    ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);
    VR.Free;
  end
  else
  begin
    OBJ:= World[sender.CharData.Enum.GUID];

    TWorldUser(OBJ.woAddr).CharData.enum_model:= vall(p1);
    TWorldUser(OBJ.woAddr).CharData.native_model:= vall(p1);

    VR:= CValuesRecord.Create;
    VR.Add(UNIT_FIELD_DISPLAYID);
    VR.Add(UNIT_FIELD_NATIVEDISPLAYID);
    sender.Send_UpdateSelf(VR);
    ListWorldUsers.Send_UpdateFromPlayer_Values(OBJ, VR);
    VR.Free;
  end;
end;
function cmd_SetModelBack(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;

  OBJ:= World[sender.CharData.Enum.GUID];

  TWorldUser(OBJ.woAddr).CharData.enum_model:= TWorldUser(OBJ.woAddr).CharData.enum_model_backup;
  TWorldUser(OBJ.woAddr).CharData.native_model:= TWorldUser(OBJ.woAddr).CharData.enum_model_backup;

  VR:= CValuesRecord.Create;
  VR.Add(UNIT_FIELD_DISPLAYID);
  VR.Add(UNIT_FIELD_NATIVEDISPLAYID);
  sender.Send_UpdateSelf(VR);
  ListWorldUsers.Send_UpdateFromPlayer_Values(OBJ, VR);
  VR.Free;
end;
function cmd_AddSpell(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  spellfile: textfile;
begin
  result:= true;
  {$IOChecks off}
  {$I-}
  AssignFile(spellfile, sender.CharData.Enum.name+'\'+'DBspell'+p2+'.wtf');
  ReWrite(spellfile);
  WriteLn(spellfile, p1);
  CloseFile(spellfile);
  {$I+}
  sender.CharData.SpellsAdd(vall(p1), 0);
  sender.CharData.SetActionButtons(vall(p2), vall(p1), $00000000);
  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', '|cffffffff|Hspell:'+p1+':0:0:0:0:0:0:0:24|h[Spell]|h|r added to slot '+p2);
  sender.Send_CreateSelf;

end;
function cmd_CastBack(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  SR: TSpellRecord;
begin
  result:= true;
  SR.caster_guid:= sender.CharData.Selection;

  SR.spell_cast_duration:= 1000;
  SR.spell_id:= vall(p1);
  SR.target_guid:= sender.CharData.Enum.GUID;
  SR.target_x:= sender.CharData.Enum.position.x;
  SR.target_y:= sender.CharData.Enum.position.y;
  SR.target_z:= sender.CharData.Enum.position.z;
  ListWorldUsers.Send_UpdateFromPlayer_SpellStart(SR);
  sleep(Random(1500));
  //sleep(SR.spell_cast_duration); // for actual animation
  ListWorldUsers.Send_UpdateFromPlayer_SpellGo(SR);
end;
function cmd_PVP(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;
  OBJ:= World[sender.CharData.Enum.GUID];
  TWorldUnit(OBJ.woAddr).unFactionTemplate:= 21;
  VR:= CValuesRecord.Create;
  VR.Init;
  VR.Add(UNIT_FIELD_FACTIONTEMPLATE);
  ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);
  VR.Free;
  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', 'Your PVP is toggled on.');
end;
function cmd_Who(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  s: string;
  i: integer;
begin
  result:= true;
  s:='';
  for i:=0 to ListWorldUsers.Count-1 do
    begin
    s:=ListWorldUsers.UserByIndex[i].CharData.Enum.name + ', ' + s;
    end;
    if Length(s) < 4 then  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', 'No players found!');
    sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
end;
function cmd_Roll(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  roll: longint;
  s: string;
begin
  result:= true;
  if (vall(p2) <> 0) then
  begin
  roll:=RandomRange(vall(p1), vall(p2)+1);
  end
  else
  begin
  p2:=p1;
  p1:=inttostr(1);
  roll:=Random(vall(p2))+1;
  end;
  s:= sender.CharData.Enum.name+' '+'rolled '+strr(roll)+' ('+p1+'-'+p2+')';

  ListWorldUsers.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
  MainLog('.roll'+' '+(p1)+', name'+' '+sender.CharData.Enum.name+', result'+' '+strr(roll));

end;
function cmd_LevelUp(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  VR: CValuesRecord;
  OBJ: TWorldRecord;
begin
  result:= true;
  if (vall(p1) > 255) then p1:=inttostr(255);
  if (vall(p1) < 0) then p1:=inttostr(0);
  sender.CharData.Enum.experiencelevel := vall(p1);
  OBJ:= World[sender.CharData.Enum.GUID];
  VR:= CValuesRecord.Create;
  VR.Add(UNIT_FIELD_LEVEL);
  ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);
  sender.Send_UpdateSelf(VR);
  VR.Free;
  sender.Send_CreateSelf;
end;
function cmd_SetGold(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  VR: CValuesRecord;
  OBJ: TWorldRecord;
begin
  result:= true;
  sender.CharData.coinage := sender.CharData.coinage + vall(p1);
  OBJ:= World[sender.CharData.Enum.GUID];
  VR:= CValuesRecord.Create;
  VR.Init;
  VR.Add(PLAYER_FIELD_COINAGE);
  ListWorldUsers.Send_UpdateFromPlayer_Values(OBJ, VR);
  sender.Send_UpdateSelf(VR);
  VR.Free;
  sender.Send_CreateSelf;
  end;
function cmd_SetBytes(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;

  OBJ:= World[sender.CharData.Selection];

  TWorldUnit(OBJ.woAddr).unFieldBytes1:= vall(p1);
  TWorldUnit(OBJ.woAddr).unFieldBytes2:= vall(p2);

  VR:= CValuesRecord.Create;
  VR.Add(UNIT_FIELD_BYTES_1);
  VR.Add(UNIT_FIELD_BYTES_2);
  ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);
  VR.Free;
end;
function cmd_SetBytesPlayer(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
begin
  result:= true;

  sender.CharData.Enum.skinID:= vall(p1);
  sender.CharData.Enum.faceID:= vall(p2);
  sender.CharData.Enum.hairStyleID:= vall(p3);
  sender.CharData.Enum.hairColorID:= vall(p4);
  sender.Send_CreateSelf;

end;
function cmd_SetBytesPlayer2(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
begin
  result:= true;

  sender.CharData.Enum.facialHairStyleID:= vall(p1);
  sender.CharData.Enum.sexID:= vall(p2);
  sender.Send_CreateSelf;

end;
function cmd_Update(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  NewMap, NewZone: Word; NewPosX, NewPosY, NewPosZ, NewPosF: Single;
begin
  result:=true;

  NewMap:= sender.CharData.Enum.mapID;
  NewZone:= sender.CharData.Enum.zoneID;
  NewPosX:= sender.CharData.Enum.position.x;
  NewPosY:= sender.CharData.Enum.position.y;
  NewPosZ:= sender.CharData.Enum.position.z;
  NewPosF:= sender.CharData.facing;

  sender.Teleport(571, 0, 0, 0, 0, 0.0);
  sleep(1);
  sender.Teleport(530, 0, 0, 0, 0, 0.0);
  sleep(1);
  sender.Teleport(0, 0, 0, 0, 0, 0.0);
  sleep(1);
  sender.Teleport(1, 0, 0, 0, 0, 0.0);
  sleep(1);

  sender.Teleport(NewMap, NewZone, NewPosX, NewPosY, NewPosZ, NewPosF);
end;

function cmd_Get(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
begin
  result:=true;

  OBJ:= World[sender.CharData.Selection];
  if (OBJ.woType = WO_UNIT) and (OBJ.woAddr <> nil) then
    begin

    ListWorldUsers.Send_Destroy(OBJ.woGUID);

    TWorldUnit(OBJ.woAddr).woLoc.x := sender.CharData.Enum.position.x;
    TWorldUnit(OBJ.woAddr).woLoc.y := sender.CharData.Enum.position.y;
    TWorldUnit(OBJ.woAddr).woLoc.z := sender.CharData.Enum.position.z;
    TWorldUnit(OBJ.woAddr).woLoc.facing := sender.CharData.facing;
    TWorldUnit(OBJ.woAddr).woLoc.Map := sender.CharData.Enum.mapID;
    TWorldUnit(OBJ.woAddr).woLoc.Zone := sender.CharData.Enum.zoneID;
    OBJ.woMap:= sender.CharData.Enum.mapID;

    ListWorldUsers.Send_CreateFromUnit(OBJ);
    end;

end;
function cmd_Goto(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  NewMap, NewZone: Word;
  NewPosX, NewPosY, NewPosZ, NewPosF: Single;
begin
  result:=true;

  OBJ:= World[sender.CharData.Selection];
  if (OBJ.woType = WO_UNIT) and (OBJ.woAddr <> nil) then
    begin

    NewPosX := TWorldUnit(OBJ.woAddr).woLoc.x;
    NewPosY := TWorldUnit(OBJ.woAddr).woLoc.y;
    NewPosZ := TWorldUnit(OBJ.woAddr).woLoc.z;
    NewPosF := TWorldUnit(OBJ.woAddr).woLoc.facing;
    NewZone := TWorldUnit(OBJ.woAddr).woLoc.Zone;
    NewMap := OBJ.woMap;

    sender.Teleport(NewMap, NewZone, NewPosX, NewPosY, NewPosZ, NewPosF);
    end;

end;
function cmd_ChangeState(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  imsg: T_CMSG_STANDSTATECHANGE;
  omsg: T_SMSG_STANDSTATE_UPDATE;
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;
  
  mainlog(p1);
  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', p1);

  sender.CharData.stand_state:= vall(p1);

  omsg.StandStateID:= imsg.StandStateID;
  sender.SockSend(msgBuild(sender.SBuf, omsg));

  OBJ.woType:= WO_PLAYER;
  OBJ.woGUID:= sender.CharData.Enum.GUID;
  OBJ.woMap:= sender.CharData.Enum.mapID;
  OBJ.woAddr:= sender;

  VR:= CValuesRecord.Create;
  VR.Add(UNIT_FIELD_BYTES_1);
  sender.Send_UpdateSelf(VR);
  ListWorldUsers.Send_UpdateFromPlayer_Values(OBJ, VR);
  VR.Free;
  sender.Send_CreateSelf;

end;
function cmd_CastSpell(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  SR: TSpellRecord;
  OBJ: TWorldRecord;
begin
  result:= true;
  SR.caster_guid:= sender.CharData.Enum.GUID;
  OBJ:= World[sender.CharData.Selection];

  SR.spell_cast_duration:= 1000;
  SR.spell_id:= vall(p1);
  SR.target_guid:= sender.CharData.Selection;
  SR.target_x:= TWorldUnit(OBJ.woAddr).woLoc.x;
  SR.target_y:= TWorldUnit(OBJ.woAddr).woLoc.y;
  SR.target_z:= TWorldUnit(OBJ.woAddr).woLoc.z;
  SR.target_string:= '';

  MainLog('CMSG_CAST_SPELL: spell='+strr(SR.spell_id)+', flags='+IntToHex(SR.target_flags, 4), 1,0,0);

  ListWorldUsers.Send_UpdateFromPlayer_SpellStart(SR);
  sleep(Random(1500));
  //sleep(SR.spell_cast_duration); // for actual animation
  ListWorldUsers.Send_UpdateFromPlayer_SpellGo(SR);
end;
function cmd_CreateItem(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  s: string;
  i, islot: longint;
  upkt: Tupkt;
  upkt_buf: array[0..65535] of byte;
  omsg1: T_SMSG_ITEM_PUSH_RESULT;
  omsg2: T_SMSG_INVENTORY_CHANGE_FAILURE;
begin
  result:= true;

  if (vall(p2) < 1) then p2:=inttostr(1);
  if (vall(p1) < 0) or (vall(p1) > Length(ItemTPL)-1) then
  begin
    s:= 'Item ID is out of range';
    sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
  end
  else
  begin
    if ItemTPL[vall(p1)].Name[0] <> '' then
    begin
      with ItemTPL[vall(p1)] do
      begin
        islot:= 0;
        for i:= InventoryPackSlotStart to InventoryPackSlotStart+InventoryPackSlotsCount do // main bag
          if sender.CharData.inventory_bag[0][i].Entry = 0 then
          begin
            islot:=i;
            break;
          end;

        if islot <> 0 then
        begin
          // add item
          //sender.CharData.ItemsAdd($FF, islot, vall(p1), ItemTPL[vall(p1)].MaxStackCount, 0);
          sender.CharData.ItemsAdd($FF, islot, vall(p1), vall(p2), 0);

          s:= 'Item ID '+p1+' was created with GUID '+int64tohex(sender.CharData.inventory_bag[0][islot].GUID)+' at slot '+strr(islot);
          sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
          s:= ItemTPL[vall(p1)].Name[0]+', model '+strr(ItemTPL[vall(p1)].DisplayInfoID);
          sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);

          sender.Send_CreateFromItem(sender.CharData.inventory_bag[0][islot]);

          pkt.InitCmd(sender.SBuf, SMSG_UPDATE_OBJECT);
          pkt.AddLong(sender.SBuf, 1);
          pkt.AddByte(sender.SBuf, 0);
          pkt.AddGUID(sender.SBuf, sender.CharData.Enum.GUID);

            upkt.Init(PLAYER_END);
            if islot in [0..PLAYER_VISIBLE_ITEMS_COUNT-1] then
              upkt.AddLong( PLAYER_VISIBLE_ITEM_1_ENTRYID + islot*(PLAYER_VISIBLE_ITEM_2_ENTRYID - PLAYER_VISIBLE_ITEM_1_ENTRYID), sender.CharData.inventory_bag[0][islot].Entry );
            upkt.AddInt64( PLAYER_FIELD_INV_SLOT_HEAD + islot*2, sender.CharData.inventory_bag[0][islot].GUID );
            upkt.MakeUpdateBlock(@upkt_buf);

          pkt.AddByte(sender.SBuf, upkt.blocks);
          pkt.AddArray(sender.SBuf, @upkt_buf, upkt.data_ofs);
          sender.SockSend(pkt.pktLen);

          omsg1.GUID:= sender.CharData.Enum.GUID;
          omsg1.PushFrom:= ITEM_PUSH_FROM_ITEM;
          omsg1.PushType:= ITEM_PUSH_TYPE_RECEIVE;
          omsg1.PushDisplay:= ITEM_PUSH_DISPLAY_ON;
          omsg1.ItemBag:= $FF; // main pack
          omsg1.ItemSlot:= islot;
          omsg1.ItemEntry:= sender.CharData.inventory_bag[0][i].Entry;
          omsg1.ItemTime:= 0;
          omsg1.ItemSuffix:= 0;
          omsg1.ItemCount:= vall(p2);
          sender.SockSend(msgBuild(sender.SBuf, omsg1));
        end
        else
        begin
          // inventory full
          omsg2.ResponseCode:= EQUIP_ERR_INVENTORY_FULL;
          omsg2.InventoryItemGUID:= 0;
          omsg2.InventoryGUID:= 0;
          omsg2.Unk:= 0;
          sender.SockSend(msgBuild(sender.SBuf, omsg2));
        end;
      end;
    end
    else
    begin
      s:= 'Item ['+p1+'] not found';
      sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
    end;
  end;
end;
function cmd_CreateItemMenu(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;
  if (Length(p2) > 0) then p1:=p1+' '+p2;
  if (Length(p3) > 0) then p1:=p1+' '+p3;
  if (Length(p4) > 0) then p1:=p1+' '+p4;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if pos(UpperCase(p1), UpperCase(ItemTPL[i].Name[0])) > 0 then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_ITEM;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $11000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;
function cmd_CreateItemMenuRandom(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
begin
  result:= true;
  if (Length(p2) > 0) then p1:=p1+' '+p2;
  if (Length(p3) > 0) then p1:=p1+' '+p3;
  if (Length(p4) > 0) then p1:=p1+' '+p4;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if pos(UpperCase(p1), UpperCase(ItemTPL[i].Name[0])) > 0 then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  ParseCommand(sender, '.i '+strr(ItemTPL[sender.CharData.VR.Values[Random(n)]].Entry));
end;
function cmd_CreateItemMenuRandomSlot(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
begin
  result:= true;
  if (Length(p2) > 0) then p1:=p1+' '+p2;
  if (Length(p3) > 0) then p1:=p1+' '+p3;
  if (Length(p4) > 0) then p1:=p1+' '+p4;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if (ItemTPL[i].InventoryTypeID = vall(p1)) and (ItemTPL[i].Name[0] <> '') then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  ParseCommand(sender, '.i '+strr(ItemTPL[sender.CharData.VR.Values[Random(n)]].Entry));
end;
function cmd_CreateItemMenuRandomQuality(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
begin
  result:= true;
  if (Length(p2) > 0) then p1:=p1+' '+p2;
  if (Length(p3) > 0) then p1:=p1+' '+p3;
  if (Length(p4) > 0) then p1:=p1+' '+p4;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if (ItemTPL[i].OverallQualityID = vall(p1)) and (ItemTPL[i].Name[0] <> '')  then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  ParseCommand(sender, '.i '+strr(ItemTPL[sender.CharData.VR.Values[Random(n)]].Entry));
end;
function cmd_CreateItemSlot(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;
  if (Length(p2) > 0) then p1:=p1+' '+p2;
  if (Length(p3) > 0) then p1:=p1+' '+p3;
  if (Length(p4) > 0) then p1:=p1+' '+p4;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if (ItemTPL[i].InventoryTypeID) = vall(p1) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_ITEM;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $11000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;
function cmd_CreateItemSlotQuality(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].InventoryTypeID) = vall(p1)) and (ItemTPL[i].OverallQualityID = vall(p2)) and (Length(ItemTPL[i].Name) <> 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_ITEM;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $11000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;
function cmd_CreateItemSlotQualityRandom(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
begin
  result:= true;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].InventoryTypeID) = vall(p1)) and (ItemTPL[i].OverallQualityID = vall(p2)) and (Length(ItemTPL[i].Name) <> 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);

  ParseCommand(sender, '.i '+strr(ItemTPL[sender.CharData.VR.Values[Random(n)]].Entry));
end;

function cmd_ItemMaterial(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].LockMaterial) = vall(p1)) and (Length(ItemTPL[i].Name) <> 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_ITEM;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $11000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;

function cmd_ItemMaterialMenu(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;
  if (Length(p3) > 0) then p2:=p2+' '+p3;
  if (Length(p4) > 0) then p2:=p2+' '+p4;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].LockMaterial) = vall(p1)) and (Length(ItemTPL[i].Name) <> 0) and (pos(UpperCase(p2), UpperCase(ItemTPL[i].Name[0])) > 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_ITEM;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $11000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;

function cmd_ItemMaterialQuality(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].LockMaterial) = vall(p1)) and (ItemTPL[i].OverallQualityID = vall(p2)) and (Length(ItemTPL[i].Name) <> 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_ITEM;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $11000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;

function cmd_ItemMaterialQualityRandom(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
begin
  result:= true;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].LockMaterial) = vall(p1)) and (ItemTPL[i].OverallQualityID = vall(p2)) and (Length(ItemTPL[i].Name) <> 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  ParseCommand(sender, '.i '+strr(ItemTPL[sender.CharData.VR.Values[Random(n)]].Entry));
end;

function cmd_ItemMaterialRandom(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
begin
  result:= true;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].LockMaterial) = vall(p1)) and (Length(ItemTPL[i].Name) <> 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  ParseCommand(sender, '.i '+strr(ItemTPL[sender.CharData.VR.Values[Random(n)]].Entry));
end;

function cmd_CreateItemLevel(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].Level) = vall(p1)) and (Length(ItemTPL[i].Name) <> 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_ITEM;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $11000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;

function cmd_ItemMaterialRandomMenu(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
begin
  result:= true;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].LockMaterial) = vall(p1)) and (Length(ItemTPL[i].Name) <> 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  ParseCommand(sender, '.i '+strr(ItemTPL[sender.CharData.VR.Values[Random(n)]].Entry));
end;

function cmd_CreateItemLevelMenu(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].Level) = vall(p1)) and (Length(ItemTPL[i].Name) <> 0) and (pos(UpperCase(p1), UpperCase(ItemTPL[i].Name[0])) > 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_ITEM;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $11000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $10000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(ItemTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;

function cmd_CreateItemLevelRandom(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
begin
  result:= true;

  sender.CharData.VR.Init;

  for i:= 0 to Length(ItemTPL)-1 do
    if ((ItemTPL[i].Level) = vall(p1)) and (Length(ItemTPL[i].Name) <> 0) then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  ParseCommand(sender, '.i '+strr(ItemTPL[sender.CharData.VR.Values[Random(n)]].Entry));

end;

function cmd_ItemSlotHelp(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  s: string;
begin
  result:= true;

  s:='';
  s:= s + '[NON_EQUIP] - 0'#13;
  s:= s + '[HEAD] - 1'#13;
  s:= s + '[NECK] - 2'#13;
  s:= s + '[SHOULDERS] - 3'#13;
  s:= s + '[BODY] - 4'#13;
  s:= s + '[CHEST] - 5'#13;
  s:= s + '[WAIST] - 6'#13;
  s:= s + '[LEGS] - 7'#13;
  s:= s + '[FEET] - 8'#13;
  s:= s + '[WRISTS] - 9'#13;
  s:= s + '[HANDS] - 10'#13;
  s:= s + '[FINGER] - 11'#13;
  s:= s + '[TRINKET] - 12'#13;
  s:= s + '[WEAPON] - 13'#13;
  s:= s + '[SHIELD] - 14'#13;
  s:= s + '[RANGED] - 15'#13;
  s:= s + '[CLOAK] - 16'#13;
  s:= s + '[TWOHAND_WEAPON] - 17'#13;
  s:= s + '[BAG] - 18'#13;
  s:= s + '[TABARD] - 19'#13;
  s:= s + '[ROBE] - 20'#13;
  s:= s + '[WEAPONMAINHAND] - 21'#13;
  s:= s + '[WEAPONOFFHAND= 22'#13;
  s:= s + '[HOLDABLE] - 23'#13;
  s:= s + '[AMMO] - 24'#13;
  s:= s + '[THROWN] - 25'#13;
  s:= s + '[RANGEDRIGHT] - 26'#13;
  s:= s + '[QUIVER] - 27'#13;
  s:= s + '[RELIC] - 28'#13;

  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
end;
function cmd_CreateUnit(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  s: string;
  woUnit: TWorldUnit;
  VR: CValuesRecord;
begin
  result:= true;

  if (vall(p1) < 0) or (vall(p1) > Length(CreatureTPL)-1) then
  begin
    s:= 'Creature ID is out of range';
    sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
  end
  else
  begin
    if CreatureTPL[vall(p1)].Name[0] <> '' then
    begin
      with CreatureTPL[vall(p1)] do
        begin
          woUnit:= TWorldUnit.Create(vall(p1));
          woUnit.woLoc.x:=      sender.CharData.Enum.position.x;
          woUnit.woLoc.y:=      sender.CharData.Enum.position.y;
          woUnit.woLoc.z:=      sender.CharData.Enum.position.z;
          woUnit.woLoc.facing:= sender.CharData.facing;
          woUnit.woLoc.Map:=    sender.CharData.Enum.mapID;
          woUnit.woLoc.Zone:=   sender.CharData.Enum.zoneID;
          woUnit.unDisplayID:=CreatureTPL[vall(p1)].DisplayID[0];
          woUnit.unNativeDisplayID:=CreatureTPL[vall(p1)].DisplayID[0];

          OBJ.woType:= WO_UNIT;
          OBJ.woGUID:= woUnit.woGUID;
          OBJ.woMap:= woUnit.woLoc.Map;
          OBJ.woAddr:= woUnit;
          World.Add(OBJ);

          ListWorldUsers.Send_CreateFromUnit(OBJ);

          if(vall(p2) > 0) then
          begin
            TWorldUnit(OBJ.woAddr).unDisplayID:= vall(p2);
           TWorldUnit(OBJ.woAddr).unNativeDisplayID:= vall(p2);

            VR:= CValuesRecord.Create;
           VR.Add(UNIT_FIELD_DISPLAYID);
           VR.Add(UNIT_FIELD_NATIVEDISPLAYID);
           ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);
           VR.Free;
           end;

          s:= 'Creature ID '+strr(woUnit.woEntry)+' was created with GUID '+int64tohex(OBJ.woGUID);
          sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
          s:= CreatureTPL[woUnit.woEntry].Name[0]+', model '+strr(CreatureTPL[woUnit.woEntry].DisplayID[0]);
//        sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
          sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
        end;
    end
    else
    begin
      s:= 'Creature ['+p1+'] not found';
      sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
    end;
  end;
end;
function cmd_CreateUnitMenu(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_COMPLETE: T_SMSG_GOSSIP_COMPLETE;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;

  if (Length(p2) > 0) then p1:=p1+' '+p2;
  if (Length(p3) > 0) then p1:=p1+' '+p3;
  if (Length(p4) > 0) then p1:=p1+' '+p4;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_COMPLETE));

  sender.CharData.VR.Init;

  for i:= 0 to Length(CreatureTPL)-1 do
    if pos(UpperCase(p1), UpperCase(CreatureTPL[i].Name[0])) > 0 then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_UNIT;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $20000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(CreatureTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $22000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $20000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(CreatureTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;
function cmd_CreateUnitMenuRandom(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
begin
  result:= true;

  if (Length(p2) > 0) then p1:=p1+' '+p2;
  if (Length(p3) > 0) then p1:=p1+' '+p3;
  if (Length(p4) > 0) then p1:=p1+' '+p4;


  sender.CharData.VR.Init;

  for i:= 0 to Length(CreatureTPL)-1 do
    if pos(UpperCase(p1), UpperCase(CreatureTPL[i].Name[0])) > 0 then
      sender.CharData.VR.Add(i);


  n:= Length(sender.CharData.VR.Values);
  ParseCommand(sender, '.u '+strr(CreatureTPL[sender.CharData.VR.Values[Random(n)]].Entry));

end;
function cmd_CreateUnitMenuTitle(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_COMPLETE: T_SMSG_GOSSIP_COMPLETE;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;

  if (Length(p2) > 0) then p1:=p1+' '+p2;
  if (Length(p3) > 0) then p1:=p1+' '+p3;
  if (Length(p4) > 0) then p1:=p1+' '+p4;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_COMPLETE));

  sender.CharData.VR.Init;

  for i:= 0 to Length(CreatureTPL)-1 do
    if pos(UpperCase(p1), UpperCase(CreatureTPL[i].GuildName)) > 0 then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_UNIT;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $20000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(CreatureTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $22000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $20000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(CreatureTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;
function cmd_DestroyObject(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  s: string;
begin
  result:= true;

  if sender.CharData.Selection <> 0 then
  begin
    OBJ:= World.ObjectByGUID[sender.CharData.Selection];

    if (OBJ.woType = WO_UNIT) and (OBJ.woAddr <> nil) then
    begin
      ListWorldUsers.Send_Destroy(OBJ.woGUID);

      TWorldUnit(OBJ.woAddr).Free;
      World.Del(OBJ);

      s:= 'Creature destroyed with GUID '+int64tohex(OBJ.woGUID);
      sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);

    end
    else
    begin
      s:= 'Can''t delete Object '+int64tohex(sender.CharData.Selection);
      sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
    end;
  end;
end;
function cmd_MountByCreature(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  s: string;
begin
  result:= true;

  if (vall(p1) < 0) or (vall(p1) > Length(CreatureTPL)-1) then
  begin
    s:= 'Creature ID is out of range';
    sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
  end
  else
    if CreatureTPL[vall(p1)].Name[0] <> '' then
      ParseCommand(sender, '.mom '+strr(CreatureTPL[vall(p1)].DisplayID[0]));
end;
function cmd_MountByModel(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;

  OBJ:= World[sender.CharData.Enum.GUID];

  TWorldUser(OBJ.woAddr).CharData.mount_model:= vall(p1);

  VR:= CValuesRecord.Create;
  VR.Add(UNIT_FIELD_MOUNTDISPLAYID);
  sender.Send_UpdateSelf(VR);
  ListWorldUsers.Send_UpdateFromPlayer_Values(OBJ, VR);
  VR.Free;

  ParseCommand(sender, '.s 16');
end;
function cmd_MountMenu(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i, n: longint;
  GOSSIP_COMPLETE: T_SMSG_GOSSIP_COMPLETE;
  GOSSIP_MESSAGE: T_SMSG_GOSSIP_MESSAGE;
  GOSSIP_TOOL: OGOSSIP_TOOL;
  m: GossipMenuRecord;
begin
  result:= true;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_COMPLETE));

  sender.CharData.VR.Init;

  for i:= 0 to Length(CreatureTPL)-1 do
    if pos(UpperCase(p1), UpperCase(CreatureTPL[i].Name[0])) > 0 then
      sender.CharData.VR.Add(i);

  n:= Length(sender.CharData.VR.Values);
  GOSSIP_TOOL.Init(GOSSIP_MESSAGE);
  GOSSIP_MESSAGE.GUID:= sender.CharData.Enum.GUID;
  GOSSIP_MESSAGE.Entry:= WO_PLAYER;
  GOSSIP_MESSAGE.NPCTextID:= n;

  if n > GOSSIP_MENU_COUNT then
  begin
    for i:= 0 to GOSSIP_MENU_COUNT-1 do
    begin
      m.Option:= $40000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(CreatureTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;

    m.Option:= $44000000 +2;
    m.IconID:= GOSSIP_ACTION_GOSSIP;
    m.InputBox:= 0;
    m.PayCost:= 0;
    m.Title:= '<next page>';
    m.PayText:= '';

    GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
  end
  else
  begin
    for i:= 0 to n-1 do
    begin
      m.Option:= $40000000 + sender.CharData.VR.Values[i];
      m.IconID:= GOSSIP_ACTION_INNKEEPER;
      m.InputBox:= 0;
      m.PayCost:= 0;
      m.Title:= Trim(CreatureTPL[sender.CharData.VR.Values[i]].Name[0] + ' (' + strr(sender.CharData.VR.Values[i]) + ')');
      m.PayText:= '';

      GOSSIP_TOOL.AddGossip(GOSSIP_MESSAGE, m);
    end;
  end;

  sender.SockSend(msgBuild(sender.SBuf, GOSSIP_MESSAGE));
end;
function cmd_DisMount(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;

  OBJ:= World[sender.CharData.Enum.GUID];

  TWorldUser(OBJ.woAddr).CharData.mount_model:= 0;

  VR:= CValuesRecord.Create;
  VR.Add(UNIT_FIELD_MOUNTDISPLAYID);
  sender.Send_UpdateSelf(VR);
  ListWorldUsers.Send_UpdateFromPlayer_Values(OBJ, VR);
  VR.Free;

  ParseCommand(sender, '.s 7');
end;
function cmd_MakeUnitAsHostile(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;

  if (sender.CharData.Selection <> 0) and (World[sender.CharData.Selection].woType = WO_UNIT) then
  begin
    OBJ:= World[sender.CharData.Selection];

    TWorldUnit(OBJ.woAddr).unFactionTemplate:= 21;

    VR:= CValuesRecord.Create;
    VR.Init;
    VR.Add(UNIT_FIELD_FACTIONTEMPLATE);
    ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);
    VR.Free;
  end;
end;
function cmd_MakeUnitAsNeutral(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;

  if (sender.CharData.Selection <> 0) and (World[sender.CharData.Selection].woType = WO_UNIT) then
  begin
    OBJ:= World[sender.CharData.Selection];

    TWorldUnit(OBJ.woAddr).unFactionTemplate:= 7;

    VR:= CValuesRecord.Create;
    VR.Init;
    VR.Add(UNIT_FIELD_FACTIONTEMPLATE);
    ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);
    VR.Free;
  end;
end;
function cmd_MakeUnitAsFriend(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;

  if (sender.CharData.Selection <> 0) and (World[sender.CharData.Selection].woType = WO_UNIT) then
  begin
    OBJ:= World[sender.CharData.Selection];

    TWorldUnit(OBJ.woAddr).unFactionTemplate:= 35;

    VR:= CValuesRecord.Create;
    VR.Init;
    VR.Add(UNIT_FIELD_FACTIONTEMPLATE);
    ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);
    VR.Free;
  end;
end;

function cmd_WorldObjectList(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  i: longint;
  s: string;
begin
  result:= true;

  s:= strr(World.Count)+' object in Worlds:'#13;
  for i:= 0 to World.Count-1 do
    s:= s + '  '+strr(i)+': map='+strr(World.ObjectByIndex[i].woMap)+', type='+strr(World.ObjectByIndex[i].woType)+', GUID='+int64tohex(World.ObjectByIndex[i].woGUID)+#13;

  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
end;
function cmd_DoTrigger(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  s: string;
begin
  result:= true;

  if (vall(p1) < 0) or (vall(p1) > Length(AreaTriggerDBC)-1) then
  begin
    s:= 'AreaTrigger ID is out of range';
    sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
  end
  else
  begin
    s:= 'Go to AreaTrigger ['+p1+']';
    sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
    if AreaTriggerDBC[vall(p1)].trigger_posx <> 0.0 then
    begin
      with AreaTriggerDBC[vall(p1)] do
        sender.Teleport(trigger_continent_id, 0, trigger_posx, trigger_posy, trigger_posz, 0.0);
    end
    else
    begin
      s:= 'AreaTrigger ['+p1+'] not found';
      sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
    end;
  end;
end;
function cmd_Save(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
begin
result:=true;
sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', 'Saving...');
DB_SaveChar(sender.CharData);
sleep(1);
if FileExists(sender.CharData.Enum.name+'/DBname.wtf') then
  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', 'Saved successfully!')
else
  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', 'Unable to save. Please relog.');
end;

function cmd_SaveWorld(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  i, map, x, y, z, u, m, facing: longint;
  worldfile: textfile;
  s: string;
begin
result:=true;

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
  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', '|cff6666ffWorld saved.|r');


end;

function cmd_Load(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  map, x, y, z, facing, u, m: longint;
  worldfile: textfile;
  woUnit: TWorldUnit;
  VR: CValuesRecord;
begin
result:=true;
  if FileExists('world.dat') then
  begin
  {$IOChecks off}
  {$I-}
  AssignFile(worldfile, 'world.dat');
  Reset(worldfile);
  while not Eof(worldfile) do
  begin
  ReadLn(worldfile, map, x, y, z, u, m, facing);
  MainLog('loaded an entry: ' +strr(u));
  
  woUnit:= TWorldUnit.Create(u);
  woUnit.woLoc.x:=      x;
  MainLog('x : ' +strr(x));
  woUnit.woLoc.y:=      y;
  MainLog('y : ' +strr(y));
  woUnit.woLoc.z:=      z;
  MainLog('z : ' +strr(z));
  woUnit.woLoc.Map:=    map;
  MainLog('map : ' +strr(map));

  if(facing > 0) then begin
    woUnit.woLoc.facing:= facing;
    MainLog('facing : ' +strr(facing));
  end;

  woUnit.unDisplayID:=CreatureTPL[u].DisplayID[0];
  woUnit.unNativeDisplayID:=CreatureTPL[u].DisplayID[0];

  OBJ.woType:= WO_UNIT;
  OBJ.woGUID:= woUnit.woGUID;
  OBJ.woMap:= woUnit.woLoc.Map;
  OBJ.woAddr:= woUnit;
  World.Add(OBJ);
  ListWorldUsers.Send_CreateFromUnit(OBJ);

  VR:= CValuesRecord.Create;
  VR.Add(UNIT_FIELD_DISPLAYID);
  VR.Add(UNIT_FIELD_NATIVEDISPLAYID);
  ListWorldUsers.Send_UpdateFromUnit_Values(OBJ, VR);

  if(m > 0) then begin
    TWorldUnit(OBJ.woAddr).unDisplayID:= m;
    TWorldUnit(OBJ.woAddr).unNativeDisplayID:= m;
    MainLog('morph : ' +strr(m));
  end;

  VR.Free;
  
  end;
  end;
  CloseFile(worldfile);
  {$I+}
  {$IOChecks on}


end;

function cmd_CreateObject(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  s: string;
  woObj: TWorldObject;
begin
  result:= true;

  if (vall(p1) < 0) or (vall(p1) > Length(GameObjectTPL)-1) then
  begin
    s:= 'Object ID is out of range';
    sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
  end
  else
  begin
    if GameObjectTPL[vall(p1)].Name[0] <> '' then
    begin
      with GameObjectTPL[vall(p1)] do
        begin
          woObj:= TWorldObject.Create(vall(p1));
          woObj.woLoc.x:=      sender.CharData.Enum.position.x;
          woObj.woLoc.y:=      sender.CharData.Enum.position.y;
          woObj.woLoc.z:=      sender.CharData.Enum.position.z;
          woObj.woLoc.facing:= sender.CharData.facing;
          woObj.woLoc.Map:=    sender.CharData.Enum.mapID;
          woObj.woLoc.Zone:=   sender.CharData.Enum.zoneID;
          woObj.woDisplayID:=GameObjectTPL[vall(p1)].DisplayID;

          OBJ.woType:= WO_GAMEOBJECT;
          OBJ.woGUID:= woObj.woGUID;
          OBJ.woMap:= woObj.woLoc.Map;
          OBJ.woAddr:= woObj;
          World.Add(OBJ);

          ListWorldUsers.Send_CreateFromGameObject(OBJ);

          s:= 'Object ID '+strr(woObj.woEntry)+' was created with GUID '+int64tohex(OBJ.woGUID);
          sender.Send_Message(sender.CharData.Enum.GUID, CHAT_MSG_SYSTEM, 0, '', s);
          s:= GameObjectTPL[woObj.woEntry].Name[0]+', model '+strr(GameObjectTPL[woObj.woEntry].DisplayID);
          sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
        end;
    end
    else
    begin
      s:= 'Object ['+p1+'] not found';
      sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);
    end;
  end;
end;


function cmd_SetSpawn(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  s: string;
  spawnfile: textfile;
begin
  result:= true;
  s:=''+strr(sender.CharData.Enum.mapID)+' '+single2str(sender.CharData.Enum.position.x)+' '+single2str(sender.CharData.Enum.position.y)+' '+single2str(sender.CharData.Enum.position.z);
  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', s);

  {$IOChecks off}

  {$I-}
  AssignFile(spawnfile, sender.CharData.Enum.name+'\'+'_spawnloc.wtf');
  ReWrite(spawnfile);
  WriteLn(spawnfile, s);
  CloseFile(spawnfile);
  {$I+}
end;
function cmd_Spawn(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  spawnmap: longint;
  spawnx, spawny, spawnz: single;
  spawnfile: textfile;
begin
  result:= true;
  {$IOChecks off}
  {$I-}
  AssignFile(spawnfile, sender.CharData.Enum.name+'\'+'_spawnloc.wtf');
  Reset(spawnfile);
  ReadLn(spawnfile, spawnmap, spawnx, spawny, spawnz);
  CloseFile(spawnfile);
  {$I+}
  {$IOChecks on}
  if(spawnmap <> 0) or (spawnx <> 0) or (spawny <> 0) or (spawnz <> 0) then
  ParseCommand(sender, '.go '+strr(spawnmap)+' '+single2str(spawnx)+' '+single2str(spawny)+' '+single2str(spawnz))
  else
  sender.Send_Message(0, CHAT_MSG_SYSTEM, 0, '', 'Error finding spawn. Try .setspawn first');
end;
function cmd_Test_ShapeShift(var sender: TWorldUser; p1,p2,p3,p4: string): boolean;
var
  OBJ: TWorldRecord;
  VR: CValuesRecord;
begin
  result:= true;

  OBJ:= World[sender.CharData.Enum.GUID];

  TWorldUser(OBJ.woAddr).CharData.stealth_visual_effect:= vall(p1);
  TWorldUser(OBJ.woAddr).CharData.shape_shift_form:= vall(p2);
  TWorldUser(OBJ.woAddr).CharData.shape_shift_stand:= vall(p3);

  VR:= CValuesRecord.Create;
  VR.Add(UNIT_FIELD_BYTES_1);
  sender.Send_UpdateSelf(VR);
  ListWorldUsers.Send_UpdateFromPlayer_Values(OBJ, VR);
  VR.Free;
end;

function ParseCommand(var sender: TWorldUser; msg: String): boolean;
var
  command, p1,p2,p3,p4: string;
begin
  result:= false;

  if msg = '' then exit;

  if msg[1] = '.' then
  begin
    command:= AnsiLowerCase(GetWord(msg,' ',1));
    p1:= GetWord(msg,' ',2);
    p2:= GetWord(msg,' ',3);
    p3:= GetWord(msg,' ',4);
    p4:= GetWord(msg,' ',5);

    if command='.h' then result:=     cmd_Help(              sender, p1,p2,p3,p4);
    if command='.hgo' then result:=   cmd_HelpGo(            sender, p1,p2,p3,p4);
    if command='.memo' then result:=     cmd_Memo(              sender, p1,p2,p3,p4);

    if command='.w' then result:=     cmd_WhereIam(          sender, p1,p2,p3,p4);
    if command='.f' then result:=     cmd_SetFlightMode(     sender, p1,p2,p3,p4);
    if command='.s' then result:=     cmd_SetSpeed(          sender, p1,p2,p3,p4);
    if command='.z' then result:=     cmd_SetScale(          sender, p1,p2,p3,p4);
    if command='.zb' then result:=    cmd_SetScaleBack(      sender, p1,p2,p3,p4);
    if command='.m' then result:=     cmd_SetModel(          sender, p1,p2,p3,p4);
    if command='.mb' then result:=    cmd_SetModelBack(      sender, p1,p2,p3,p4);
    if command='.i' then result:=     cmd_CreateItem(        sender, p1,p2,p3,p4);
    if command='.sp' then result:=    cmd_AddSpell(          sender, p1,p2,p3,p4);
    if command='.cb' then result:=    cmd_CastBack(          sender, p1,p2,p3,p4);
    if command='.cast' then result:=    cmd_CastSpell(       sender, p1,p2,p3,p4);
    if command='.cs' then result:=    cmd_ChangeState(       sender, p1,p2,p3,p4);
    if command='.roll' then result:=    cmd_Roll(            sender, p1,p2,p3,p4);
    if command='.who' then result:=     cmd_Who(            sender, p1,p2,p3,p4);
    if command='.pvp' then result:=    cmd_PVP(            sender, p1,p2,p3,p4);
    if command='.lvl' then result:=     cmd_LevelUp(         sender, p1,p2,p3,p4);
    if command='.gold' then result:=    cmd_SetGold(         sender, p1,p2,p3,p4);
    if command='.get' then result:=    cmd_Get(              sender, p1,p2,p3,p4);
    if command='.goto' then result:=   cmd_Goto(             sender, p1,p2,p3,p4);
    if command='.pb' then result:= cmd_SetBytesPlayer(       sender, p1,p2,p3,p4);
    if command='.pb2' then result:= cmd_SetBytesPlayer2(     sender, p1,p2,p3,p4);
    if command='.byte' then result:=    cmd_SetBytes(        sender, p1,p2,p3,p4);
    if command='.upd' then result:=     cmd_Update(          sender, p1,p2,p3,p4);
    if command='.ih' then result:=      cmd_ItemHelp(        sender, p1,p2,p3,p4);
    if command='.in' then result:=    cmd_CreateItemMenu(    sender, p1,p2,p3,p4);
    if command='.inr' then result:=    cmd_CreateItemMenuRandom(    sender, p1,p2,p3,p4);
    if command='.ish' then result:=   cmd_ItemSlotHelp(      sender, p1,p2,p3,p4);
    if command='.ins' then result:=   cmd_CreateItemSlot(      sender, p1,p2,p3,p4);
    if command='.isr' then result:=   cmd_CreateItemMenuRandomSlot(      sender, p1,p2,p3,p4);
    if command='.iqr' then result:=   cmd_CreateItemMenuRandomQuality(   sender, p1,p2,p3,p4);
    if command='.isq' then result:= cmd_CreateItemSlotQuality(  sender, p1,p2,p3,p4);
    if command='.isqr' then result:= cmd_CreateItemSlotQualityRandom( sender, p1,p2,p3,p4);

    if command='.im' then result:= cmd_ItemMaterial(         sender, p1,p2,p3,p4);
    if command='.imn' then result:= cmd_ItemMaterialMenu(         sender, p1,p2,p3,p4);
    if command='.imq' then result:= cmd_ItemMaterialQuality(         sender, p1,p2,p3,p4);
    if command='.imqr' then result:= cmd_ItemMaterialQualityRandom(         sender, p1,p2,p3,p4);
    if command='.imr' then result:= cmd_ItemMaterialRandom(         sender, p1,p2,p3,p4);
    if command='.imnr' then result:=cmd_ItemMaterialRandomMenu(         sender, p1,p2,p3,p4);

    if command='.ilvl' then result:= cmd_CreateItemLevel(                 sender, p1,p2,p3,p4);
    if command='.ilvln' then result:= cmd_CreateItemLevelMenu(                 sender, p1,p2,p3,p4);
    if command='.ilvlr' then result:= cmd_CreateItemLevelRandom(          sender, p1,p2,p3,p4);

    if command='.unr' then result:= cmd_CreateUnitMenuRandom( sender, p1,p2,p3,p4);
    if command='.u' then result:=     cmd_CreateUnit(        sender, p1,p2,p3,p4);
    if command='.un' then result:=    cmd_CreateUnitMenu(    sender, p1,p2,p3,p4);
    if command='.unt' then result:=    cmd_CreateUnitMenuTitle(    sender, p1,p2,p3,p4);
    if command='.d' then result:=     cmd_DestroyObject(     sender, p1,p2,p3,p4);
    if command='.moe' then result:=   cmd_MountByCreature(   sender, p1,p2,p3,p4);
    if command='.mom' then result:=   cmd_MountByModel(      sender, p1,p2,p3,p4);
    if command='.mon' then result:=   cmd_MountMenu(         sender, p1,p2,p3,p4);
    if command='.dmo' then result:=   cmd_DisMount(          sender, p1,p2,p3,p4);
    if command='.ho' then result:=    cmd_MakeUnitAsHostile( sender, p1,p2,p3,p4);
    if command='.ne' then result:=    cmd_MakeUnitAsNeutral( sender, p1,p2,p3,p4);
    if command='.fr' then result:=    cmd_MakeUnitAsFriend(  sender, p1,p2,p3,p4);

    if command='.wo' then result:=    cmd_WorldObjectList(   sender, p1,p2,p3,p4);
    if command='.t' then result:=     cmd_DoTrigger(         sender, p1,p2,p3,p4);
    if command='.ss' then result:=    cmd_Test_ShapeShift(   sender, p1,p2,p3,p4);
    if command='.setspawn' then result:=    cmd_SetSpawn(    sender, p1,p2,p3,p4);
    if command='.spawn' then result:=       cmd_Spawn(       sender, p1,p2,p3,p4);
    if command='.save' then result:=        cmd_Save(        sender, p1,p2,p3,p4);
//  if command='.load' then result:=        cmd_Load(        sender, p1,p2,p3,p4);

    if command='.go' then      begin result:=true; sender.Teleport(vall(p1), 0, str2single(p2), str2single(p3), str2single(p4), 0.0); end;
    if command='.obj' then result:=   cmd_CreateObject(      sender, p1,p2,p3,p4);
    if command='.saveworld' then result:= cmd_SaveWorld(     sender, p1,p2,p3,p4);

    if command='.human' then   begin result:=true; sender.Teleport( 0,   12,   -8949.950195, -132.492996,   83.531197,   0.0); end;
    if command='.dwarf' then   begin result:=true; sender.Teleport( 0,   01,   -6240.319824, 331.032990,    382.757996,  0.0); end;
    if command='.elf' then     begin result:=true; sender.Teleport( 1,   141,  10311.299805, 831.463013,    1326.410034, 0.0); end;
    if command='.orc' then     begin result:=true; sender.Teleport( 1,   14,   -618.518005,  -4251.669922,  38.717999,   0.0); end;
    if command='.undead' then  begin result:=true; sender.Teleport( 0,   85,   1676.349976,  1677.449951,   121.669998,  2.705260); end;
    if command='.tauren' then  begin result:=true; sender.Teleport( 1,   215,  -2917.580078, -257.980011,   52.996799,   0.0); end;
    if command='.dra' then     begin result:=true; sender.Teleport( 530, 3524, -3961.639893, -13931.200195, 100.614998,  2.083644); end;
    if command='.belf' then    begin result:=true; sender.Teleport( 530, 3430, 10349.599609, -6357.290039,  33.402599,   5.316046); end;

    if command='.golds' then   begin result:=true; sender.Teleport( 0, 12, -9457.468750, 54.702946, 56.208504, 2.192810); end;
    if command='.storm' then   begin result:=true; sender.Teleport( 0, 12, -9125.579102, 396.515106, 91.941780, 0.612589); end;
    if command='.iron' then    begin result:=true; sender.Teleport( 0, 1, -5049.721191, -778.815369, 494.001740, 5.106645); end;
  end;
end;

end.
