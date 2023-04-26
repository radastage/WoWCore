unit Spawn1;

interface

uses
  ClassConnection, Forms, Unit1;

procedure LoadSpawn1;

implementation

uses
  Responses, Struct, Defines, ClassWorld, Logs, Convert,
  SysUtils;

procedure LoadSpawn1;
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

end.
