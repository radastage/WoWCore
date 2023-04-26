unit DB;

interface

uses
  TMSGStruct,
  Struct;

procedure DB_GetEnumCharList(account_name: string; var m: T_SMSG_CHAR_ENUM);
procedure DB_MakeNewChar(var e: T_CMSG_CHAR_CREATE; var c: TCharData);
procedure DB_AddChar(acc_name: string; var c: TCharData);
function  DB_CharExists(charname: string): boolean;
procedure DB_DeleteChar(guid: uInt64);
function  DB_LoadChar(guid: uInt64; var c: TCharData): boolean;
procedure DB_SaveChar(c: TCharData);

implementation

uses
  Responses,
  Convert, Logs,
  CharsConsts,
  ClassCharList,
  Defines;

procedure DB_GetEnumCharList(account_name: string; var m: T_SMSG_CHAR_ENUM);
var
  i, k, j, e: longint;
begin
  // all chars is here from all accounts
  m.Count:= ListChars.Count(account_name);
  if m.Count = 0 then exit;

  // matching from ListChars[] by AccountName
  k:= 0;
  for i:= 0 to ListChars.Count-1 do
    if ListChars.List[i].Login = account_name then
    begin
      m.Enum[k]:= ListChars.List[i].Enum;

      for j:= 0 to ENUM_PLAYER_ITEMS_COUNT-1 do
      begin
        e:= ListChars.List[i].inventory_bag[0][j].Entry;
        if e > Length(ItemTPL) then
        begin
          m.Enum[k].inventory[0][j].displayID:= 0;
          m.Enum[k].inventory[0][j].inventoryType:= 0;
          m.Enum[k].inventory[0][j].auraID:= 0;
          mainlog('DB_GetEnumCharList: ItemEntry='+strr(e)+', ItemTPL is nil.');
        end
        else
        begin
          m.Enum[k].inventory[0][j].displayID:= ItemTPL[e].DisplayInfoID;
          m.Enum[k].inventory[0][j].inventoryType:= ItemTPL[e].InventoryTypeID;
          m.Enum[k].inventory[0][j].auraID:= 0;
        end;
      end;

      inc(k);
      if k > ENUM_CHARS_COUNT then break;
    end;
end;
procedure DB_MakeNewChar(var e: T_CMSG_CHAR_CREATE; var c: TCharData);
begin
  c.Enum.name:=              e.name;
  c.Enum.raceID:=            e.raceID;
  c.Enum.classID:=           e.classID;
  c.Enum.sexID:=             e.sexID;
  c.Enum.skinID:=            e.skinID;
  c.Enum.faceID:=            e.faceID;
  c.Enum.hairStyleID:=       e.hairStyleID;
  c.Enum.hairColorID:=       e.hairColorID;
  c.Enum.facialHairStyleID:= e.facialHairStyleID;
  c.Enum.outfitID:=          e.outfitID;

  MakeRaceClassDefaultParams(e.raceID, e.classID, e.sexID, c);
end;
procedure DB_AddChar(acc_name: string; var c: TCharData);
begin
  c.Login:= acc_name;
  ListChars.Add(c);
end;
function  DB_CharExists(charname: string): boolean;
var
  i: longint;
begin
  result:= false;
  for i:= 0 to ListChars.Count-1 do
    if ListChars.List[i].Enum.name = charname then
    begin
      result:= true;
      exit;
    end;
end;

procedure DB_DeleteChar(guid: uInt64);
var
  i: longint;
  name: textfile;
begin
  {$IOChecks off}
  for i:= 0 to ListChars.Count-1 do
    if ListChars.List[i].Enum.GUID = guid then
    begin
      {$I-}
        AssignFile(name, ListChars.List[i].Enum.name+'\'+'DBname.wtf');
        ReWrite(name);
        WriteLn(name, '');
       CloseFile(name);
      {$I+}
     ListChars.Del(guid);
     end;
  {$IOChecks on}
end;

function  DB_LoadChar(guid: uInt64; var c: TCharData): boolean;
var
  i: longint;
begin
  result:= false;
  for i:= 0 to ListChars.Count-1 do
    if ListChars.List[i].Enum.GUID = guid then
    begin
      c:= ListChars.List[i];
      result:= true;
      exit;
    end;
end;
procedure DB_SaveChar(c: TCharData);
var
  i: longint;
  savepath: string;
  DBlist, char_file: textfile;
begin
  MainLog('Saving '+c.Enum.name);
  savepath := c.Enum.name;

  {$IOChecks off}
  RmDir(c.Enum.name);
  MkDir(c.Enum.name);

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBname.wtf');
  ReWrite(char_file);
  WriteLn(char_file, c.Enum.name);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBrace.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.Enum.raceID);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBclassID.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.Enum.classID);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBsexID.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.Enum.sexID);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBskinID.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.Enum.skinID);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBfaceID.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.Enum.faceID);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBhairstyleID.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.Enum.hairstyleID);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBhaircolorID.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.Enum.haircolorID);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBfacialhairstyleID.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.Enum.facialhairstyleID);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBaccountname.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.Login);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBmorph.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.enum_model);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBmount.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.mount_model);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBlevel.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.enum.experiencelevel);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem0.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][0].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem1.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][1].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem2.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][2].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem3.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][3].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem4.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][4].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem5.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][5].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem6.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][6].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem7.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][7].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem8.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][8].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem9.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][9].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem10.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][10].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem11.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][11].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem12.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][12].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem13.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][13].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem14.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][14].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem15.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][15].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem16.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][16].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem17.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][17].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem18.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][18].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem19.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][19].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem20.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][20].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem21.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][21].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem22.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][22].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem23.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][23].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem24.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][24].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem25.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][25].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem26.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][26].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem27.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][27].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem28.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][28].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem29.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][29].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem30.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][30].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem31.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][31].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem32.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][32].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem33.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][33].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem34.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][34].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem35.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][35].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem36.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][36].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem37.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][37].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'CharItem38.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.inventory_bag[0][38].Entry);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(char_file, savepath+'\'+'DBgold.wtf');
  Rewrite(char_file);
  WriteLn(char_file, c.coinage);
  CloseFile(char_file);
  {$I+}

  {$I-}
  AssignFile(DBlist, 'WoWcharlist.wtf');
  Rewrite(DBlist);
  erase(DBlist);
  for i:= 0 to ListChars.Count-1 do
    WriteLn(DBlist, ListChars.List[i].Enum.name);
  CloseFile(DBlist);
  {$I+}


  {$IOChecks on}

  for i:= 0 to ListChars.Count-1 do
    if ListChars.List[i].Enum.GUID = c.Enum.GUID then
    begin
      ListChars.List[i]:= c;
      exit;
    end;
    
end;

end.

