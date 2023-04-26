unit Defines;

interface

const
  APP_BUILD = '2400';

  GAME_TYPE_CLASSIC                    = 0;
  GAME_TYPE_BC                         = 1;
  GAME_TYPE_WOTLK                      = 2;
  GAME_TYPE_CATA                       = 3;
  GAME_TYPE_MOP                        = 4;

  // Char Server
  // ===========================================================================
  RESPONSE_SUCCESS                     = $00;
  RESPONSE_FAILURE                     = $01;
  RESPONSE_CANCELLED                   = $02;
  RESPONSE_DISCONNECTED                = $03;
  RESPONSE_FAILED_TO_CONNECT           = $04;
  RESPONSE_CONNECTED                   = $05;
  RESPONSE_VERSION_MISMATCH            = $06;

  CSTATUS_CONNECTING                   = $07;
  CSTATUS_NEGOTIATING_SECURITY         = $08;
  CSTATUS_NEGOTIATION_COMPLETE         = $09;
  CSTATUS_NEGOTIATION_FAILED           = $0A;
  CSTATUS_AUTHENTICATING               = $0B;

  AUTH_OK                              = $0C;
  AUTH_FAILED                          = $0D;
  AUTH_REJECT                          = $0E;
  AUTH_BAD_SERVER_PROOF                = $0F;
  AUTH_UNAVAILABLE                     = $10;
  AUTH_SYSTEM_ERROR                    = $11;
  AUTH_BILLING_ERROR                   = $12;
  AUTH_BILLING_EXPIRED                 = $13;
  AUTH_VERSION_MISMATCH                = $14;
  AUTH_UNKNOWN_ACCOUNT                 = $15;
  AUTH_INCORRECT_PASSWORD              = $16;
  AUTH_SESSION_EXPIRED                 = $17;
  AUTH_SERVER_SHUTTING_DOWN            = $18;
  AUTH_ALREADY_LOGGING_IN              = $19;
  AUTH_LOGIN_SERVER_NOT_FOUND          = $1A;
  AUTH_WAIT_QUEUE                      = $1B;
  AUTH_BANNED                          = $1C;
  AUTH_ALREADY_ONLINE                  = $1D;
  AUTH_NO_TIME                         = $1E;
  AUTH_DB_BUSY                         = $1F;
  AUTH_SUSPENDED                       = $20;
  AUTH_PARENTAL_CONTROL                = $21;
  AUTH_LOCKED_ENFORCED                 = $22;

  // enum REALM_LIST_RESULT
  REALM_LIST_IN_PROGRESS               = $23;
  REALM_LIST_SUCCESS                   = $24;
  REALM_LIST_FAILED                    = $25;
  REALM_LIST_INVALID                   = $26;
  REALM_LIST_REALM_NOT_FOUND           = $27;
  LAST_REALM_LIST_RESULT               = $28;

  // enum ACCOUNT_CREATE_RESULT
  ACCOUNT_CREATE_IN_PROGRESS           = $28;
  ACCOUNT_CREATE_SUCCESS               = $29;
  ACCOUNT_CREATE_FAILED                = $2A;
  LAST_ACCOUNT_CREATE_RESULT           = $2B;

  // enum CHAR_LIST_RESULT
  CHAR_LIST_RETRIEVING                 = $2B;
  CHAR_LIST_RETRIEVED                  = $2C;
  CHAR_LIST_FAILED                     = $2D;
  LAST_CHAR_LIST_RESULT                = $2E;

  // enum CHAR_CREATE_RESULT
  CHAR_CREATE_IN_PROGRESS              = $2E;
  CHAR_CREATE_SUCCESS                  = $2F;
  CHAR_CREATE_ERROR                    = $30;
  CHAR_CREATE_FAILED                   = $31;
  CHAR_CREATE_NAME_IN_USE              = $32;
  CHAR_CREATE_DISABLED                 = $33;
  CHAR_CREATE_PVP_TEAMS_VIOLATION      = $34;
  CHAR_CREATE_SERVER_LIMIT             = $35;
  CHAR_CREATE_ACCOUNT_LIMIT            = $36;
  CHAR_CREATE_SERVER_QUEUE             = $37;
  CHAR_CREATE_ONLY_EXISTING            = $38;
  CHAR_CREATE_EXPANSION                = $39;
  CHAR_CREATE_EXPANSION_CLASS          = $3A;
  CHAR_CREATE_LEVEL_REQUIREMENT        = $3B;
  CHAR_CREATE_UNIQUE_CLASS_LIMIT       = $3C;
  CHAR_CREATE_CHARACTER_IN_GUILD       = $3D;
  CHAR_CREATE_RESTRICTED_RACECLASS     = $3E;
  CHAR_CREATE_CHARACTER_CHOOSE_RACE    = $3F;
  CHAR_CREATE_CHARACTER_ARENA_LEADER   = $40;
  CHAR_CREATE_CHARACTER_DELETE_MAIL    = $41;
  CHAR_CREATE_CHARACTER_SWAP_FACTION   = $42;
  CHAR_CREATE_CHARACTER_RACE_ONLY      = $43;
  CHAR_CREATE_CHARACTER_GOLD_LIMIT     = $44;
  CHAR_CREATE_FORCE_LOGIN              = $45;
  LAST_CHAR_CREATE_RESULT              = $46;

  // enum CHAR_DELETE_RESULT
  CHAR_DELETE_IN_PROGRESS              = $46;
  CHAR_DELETE_SUCCESS                  = $47;
  CHAR_DELETE_FAILED                   = $48;
  CHAR_DELETE_FAILED_LOCKED_FOR_TRANSFER = $49;
  CHAR_DELETE_FAILED_GUILD_LEADER      = $4A;
  CHAR_DELETE_FAILED_ARENA_CAPTAIN     = $4B;
  LAST_CHAR_DELETE_RESULT              = $4C;

  // enum CHAR_LOGIN_RESULT
  CHAR_LOGIN_IN_PROGRESS               = $4C;
  CHAR_LOGIN_SUCCESS                   = $4D;
  CHAR_LOGIN_NO_WORLD                  = $4E;
  CHAR_LOGIN_DUPLICATE_CHARACTER       = $4F;
  CHAR_LOGIN_NO_INSTANCES              = $50;
  CHAR_LOGIN_FAILED                    = $51;
  CHAR_LOGIN_DISABLED                  = $52;
  CHAR_LOGIN_NO_CHARACTER              = $53;
  CHAR_LOGIN_LOCKED_FOR_TRANSFER       = $54;
  CHAR_LOGIN_LOCKED_BY_BILLING         = $55;
  CHAR_LOGIN_LOCKED_BY_MOBILE_AH       = $56;
  LAST_CHAR_LOGIN_RESULT               = $57;

  // enum CHAR_NAME_RESULT
  CHAR_NAME_SUCCESS                    = $57;
  CHAR_NAME_FAILURE                    = $58;
  CHAR_NAME_NO_NAME                    = $59;
  CHAR_NAME_TOO_SHORT                  = $5A;
  CHAR_NAME_TOO_LONG                   = $5B;
  CHAR_NAME_INVALID_CHARACTER          = $5C;
  CHAR_NAME_MIXED_LANGUAGES            = $5D;
  CHAR_NAME_PROFANE                    = $5E;
  CHAR_NAME_RESERVED                   = $5F;
  CHAR_NAME_INVALID_APOSTROPHE         = $60;
  CHAR_NAME_MULTIPLE_APOSTROPHES       = $61;
  CHAR_NAME_THREE_CONSECUTIVE          = $62;
  CHAR_NAME_INVALID_SPACE              = $63;
  CHAR_NAME_CONSECUTIVE_SPACES         = $64;
  CHAR_NAME_RUSSIAN_CONSECUTIVE_SILENT_CHARACTERS = $65;
  CHAR_NAME_RUSSIAN_SILENT_CHARACTER_AT_BEGINNING_OR_END = $66;
  CHAR_NAME_DECLENSION_DOESNT_MATCH_BASE_NAME = $67;

  // chat system
  LANG_UNIVERSAL                       = 0;
  LANG_ORCISH                          = 1;
  LANG_DARNASSIAN                      = 2;
  LANG_TAURAHE                         = 3;
  LANG_DWARVISH                        = 6;
  LANG_COMMON                          = 7;
  LANG_DEMONIC                         = 8;
  LANG_TITAN                           = 9;
  LANG_THELASSIAN                      = 10;
  LANG_DRACONIC                        = 11;
  LANG_KALIMAG                         = 12;
  LANG_GNOMISH                         = 13;
  LANG_TROLL                           = 14;
  LANG_GUTTERSPEAK                     = 33;
  LANG_DRAENEI                         = 35;
  LANG_ZOMBIE                          = 36;
  LANG_GNOMISH_BINARY                  = 37;
  LANG_GOBLIN_BINARY                   = 38;
  LANG_WORGEN                          = 39;
  LANG_GOBLIN                          = 40;

  CHAT_MSG_ADDON                       = -1;
  CHAT_MSG_SYSTEM                      = 00;
  CHAT_MSG_SAY                         = 01;
  CHAT_MSG_PARTY                       = 02;
  CHAT_MSG_RAID                        = 03;
  CHAT_MSG_GUILD                       = 04;
  CHAT_MSG_OFFICER                     = 05;
  CHAT_MSG_YELL                        = 06;
  CHAT_MSG_WHISPER                     = 07;
  CHAT_MSG_WHISPER_INFORM              = 08;
  CHAT_MSG_REPLY                       = 09;
  CHAT_MSG_EMOTE                       = 10;
  CHAT_MSG_TEXT_EMOTE                  = 11;
  CHAT_MSG_MONSTER_SAY                 = 12;
  CHAT_MSG_MONSTER_PARTY               = 13;
  CHAT_MSG_MONSTER_YELL                = 14;
  CHAT_MSG_MONSTER_WHISPER             = 15;
  CHAT_MSG_MONSTER_EMOTE               = 16;
  CHAT_MSG_CHANNEL                     = 17;
  CHAT_MSG_CHANNEL_JOIN                = 18;
  CHAT_MSG_CHANNEL_LEAVE               = 19;
  CHAT_MSG_CHANNEL_LIST                = 20;
  CHAT_MSG_CHANNEL_NOTICE              = 21;
  CHAT_MSG_CHANNEL_NOTICE_USER         = 22;
  CHAT_MSG_AFK                         = 23;
  CHAT_MSG_DND                         = 24;
  CHAT_MSG_IGNORED                     = 25;
  CHAT_MSG_SKILL                       = 26;
  CHAT_MSG_LOOT                        = 27;
  CHAT_MSG_MONEY                       = 28;
  CHAT_MSG_OPENING                     = 29;
  CHAT_MSG_TRADESKILLS                 = 30;
  CHAT_MSG_PET_INFO                    = 31;
  CHAT_MSG_COMBAT_MISC_INFO            = 32;
  CHAT_MSG_COMBAT_XP_GAIN              = 33;
  CHAT_MSG_COMBAT_HONOR_GAIN           = 34;
  CHAT_MSG_COMBAT_FACTION_CHANGE       = 35;
  CHAT_MSG_BG_SYSTEM_NEUTRAL           = 36;
  CHAT_MSG_BG_SYSTEM_ALLIANCE          = 37;
  CHAT_MSG_BG_SYSTEM_HORDE             = 38;
  CHAT_MSG_RAID_LEADER                 = 39;
  CHAT_MSG_RAID_WARNING                = 40;
  CHAT_MSG_RAID_BOSS_WHISPER           = 41;
  CHAT_MSG_RAID_BOSS_EMOTE             = 42;
  CHAT_MSG_FILTERED                    = 43;
  CHAT_MSG_BATTLEGROUND                = 44;
  CHAT_MSG_BATTLEGROUND_LEADER         = 45;
  CHAT_MSG_RESTRICTED                  = 46;

  // chanell notify type
  CHAT_NOTIFY_JOINED                   = $00;
  CHAT_NOTIFY_LEAVE                    = $01;
  CHAT_NOTIFY_YOU_JOINED               = $02;
  CHAT_NOTIFY_YOU_LEFT                 = $03;
  CHAT_NOTIFY_WRONG_PASS               = $04;
  CHAT_NOTIFY_NOT_ON                   = $05;
  CHAT_NOTIFY_NOT_MODERATOR            = $06;
  CHAT_NOTIFY_SET_PASS                 = $07;
  CHAT_NOTIFY_CHANGE_OWNER             = $08;
  CHAT_NOTIFY_NOT_ON2                  = $09;
  CHAT_NOTIFY_NOT_OWNER                = $0A;
  CHAT_NOTIFY_WHO_OWNER                = $0B;
  CHAT_NOTIFY_MODE_CHANGE              = $0C;
  CHAT_NOTIFY_ENABLE_ANNOUNCE          = $0D;
  CHAT_NOTIFY_DISABLE_ANNOUNCE         = $0E;
  CHAT_NOTIFY_MODERATED                = $0F;
  CHAT_NOTIFY_UNMODERATED              = $10;
  CHAT_NOTIFY_MUTED                    = $11;
  CHAT_NOTIFY_KICKED                   = $12;
  CHAT_NOTIFY_YOU_ARE_BANNED           = $13;
  CHAT_NOTIFY_BANNED                   = $14;
  CHAT_NOTIFY_UNBANNED                 = $15;
  CHAT_NOTIFY_UNK16                    = $16;
  CHAT_NOTIFY_ALREADY_ON               = $17;
  CHAT_NOTIFY_INVITED                  = $18;
  CHAT_NOTIFY_WRONG_ALLIANCE           = $19;
  CHAT_NOTIFY_WRONG_FACTION            = $1A;
  CHAT_NOTIFY_INVALID_NAME             = $1B;
  CHAT_NOTIFY_NOT_MODERATED            = $1C;
	CHAT_NOTIFY_YOU_INVITED              = $1D;
  CHAT_NOTIFY_INVITE_BANNED            = $1E;
  CHAT_NOTIFY_NOT_IN_AREA              = $1F;
  CHAT_NOTIFY_NOT_IN_LFG               = $20;
  CHAT_NOTIFY_VOICE_ON                 = $21;
  CHAT_NOTIFY_VOICE_OFF                = $22;
  CHAT_NOTIFY_COMPLAINT_ADDED          = $23;

  USER_CHANNEL                         = 1;
  DEFAULT_CHANNEL                      = 8;
  CITY_CHANNEL                         = 12;
  COMMON_CHANNEL                       = 24;
  GUILD_REC_CHANNEL                    = 56;
  TRADE_CHANNEL                        = 60;

  Channel_Owner                        = 5;
  Channel_Moderator                    = 2;
  Channel_Member                       = 4;
  Channel_Category_General             = 1;
  Channel_Category_Trade               = 2;
  Channel_Category_LocalDefense        = 22;
  Channel_Category_WorldDefense        = 23;
  Channel_Category_GuildRecruitment    = 25;
  Channel_Category_LookingForGroup     = 26;

  GENDER_MALE                          = 0;
  GENDER_FEMALE                        = 1;
  GENDER_NONE                          = 2;
  GenderStr: array[0..2] of string = (
  'Male',
  'Female',
  'None'
  );

  RACE_NONE                            = 0;
  RACE_HUMAN                           = 1;
  RACE_ORC                             = 2;
  RACE_DWARF                           = 3;
  RACE_NIGHT_ELF                       = 4;
  RACE_UNDEAD                          = 5;
  RACE_TAUREN                          = 6;
  RACE_GNOME                           = 7;
  RACE_TROLL                           = 8;
  RACE_GOBLIN                          = 9;
  RACE_BLOOD_ELF                       = 10;
  RACE_DRAENEI                         = 11;
  RACE_WORGEN                          = 22;
  RaceStr: array[0..22] of string = (
  'N/A',
  'Human',
  'Orc',
  'Dwarf',
  'Night Elf',
  'Undead',
  'Tauren',
  'Gnome',
  'Troll',
  'Goblin',
  'Blood Elf',
  'Draenei',
  'Fel Orc',
  'Naga',
  'N/A 14',
  'N/A 15',
  'N/A 16',
  'N/A 17',
  'Forest Troll',
  'Taunka',
  'N/A 20',
  'N/A 21',
  'Worgen'
  );

  CLASS_WARRIOR                        = 1;
  CLASS_PALADIN                        = 2;
  CLASS_HUNTER                         = 3;
  CLASS_ROGUE                          = 4;
  CLASS_PRIEST                         = 5;
  CLASS_DEATHKNIGHT                    = 6;
  CLASS_SHAMAN                         = 7;
  CLASS_MAGE                           = 8;
  CLASS_WARLOCK                        = 9;
  CLASS_UNK10                          = 10;
  CLASS_DRUID                          = 11;
  ClassStr: array[0..11] of string = (
  'N/A',
  'Warrior',
  'Paladin',
  'Hunter',
  'Rogue',
  'Priest',
  'Dark Knight',
  'Shaman',
  'Mage',
  'Warlock',
  'Unk10',
  'Druid'
  );

  // World Server
  // ===========================================================================
  GUID_TYPE_ITEM                       = $4700000000000000;
  GUID_TYPE_CONTAINER                  = $4700000000000000;
  GUID_TYPE_UNIT                       = $F130000000000000;
  GUID_TYPE_PLAYER                     = $0700000000000000;
  GUID_TYPE_PET                        = $0000000000000000;
  GUID_TYPE_GAMEOBJECT                 = $F110000000000000;
  GUID_TYPE_DYNAMICOBJECT              = $0000000000000000;
  GUID_TYPE_CORPSE                     = $0000000000000000;
  GUID_TYPE_GROUP                      = $FFFF000000000000;

  WO_ITEM                              = 1;
  WO_CONTAINER                         = 2;
  WO_UNIT                              = 3;
  WO_PLAYER                            = 4;
  WO_GAMEOBJECT                        = 5;
  WO_DYNAMICOBJECT                     = 6;
  WO_CORPSE                            = 7;

  TYPE_OBJECT                          = 1;
  TYPE_ITEM                            = 2;
  TYPE_CONTAINER                       = 4 + TYPE_ITEM;
  TYPE_UNIT                            = 8;
  TYPE_PLAYER                          = 16;
  TYPE_GAMEOBJECT                      = 32;
  TYPE_DYNAMICOBJECT                   = 64;
  TYPE_CORPSE                          = 128;
  TYPE_AIGROUP                         = 256;
  TYPE_AREATRIGGER                     = 512;

  POWER_MANA                           = 0;
  POWER_RAGE                           = 1;
  POWER_FOCUS                          = 2;
  POWER_ENERGY                         = 3;
  POWER_HAPPINESS                      = 4;
  POWER_RUNES                          = 5;
  POWER_RUNIC                          = 6;
  PowerStr: array[0..6] of string = (
  'Mana',
  'Rage',
  'Focus',
  'Energy',
  'Happiness',
  'Runes',
  'Runic'
  );

  STAT_STRENGTH                        = 0;
  STAT_AGILITY                         = 1;
  STAT_STAMINA                         = 2;
  STAT_INTELLECT                       = 3;
  STAT_SPIRIT                          = 4;
  STAT_MAX                             = 4;
  StatStr: array[0..4] of string = (
  'Strength',
  'Agility',
  'Stamina',
  'Intellect',
  'Spirit'
  );

  RESISTANCE_MAX                       = 6;

  UNIT_NPC_FLAG_NONE                   = $00000000;
  UNIT_NPC_FLAG_GOSSIP                 = $00000001;
  UNIT_NPC_FLAG_QUESTGIVER             = $00000002;
  UNIT_NPC_FLAG_TRAINER                = $00000010;
  UNIT_NPC_FLAG_TRAINER_CLASS          = $00000020;
  UNIT_NPC_FLAG_TRAINER_PROFESSION     = $00000040;
  UNIT_NPC_FLAG_VENDOR                 = $00000080;
  UNIT_NPC_FLAG_VENDOR_AMMO            = $00000100;
  UNIT_NPC_FLAG_VENDOR_FOOD            = $00000200;
  UNIT_NPC_FLAG_VENDOR_POISON          = $00000400;
  UNIT_NPC_FLAG_VENDOR_REAGENT         = $00000800;
  UNIT_NPC_FLAG_ARMORER                = $00001000;
  UNIT_NPC_FLAG_TAXIVENDOR             = $00002000;
  UNIT_NPC_FLAG_SPIRITHEALER           = $00004000;
  UNIT_NPC_FLAG_SPIRITGUIDE            = $00008000;
  UNIT_NPC_FLAG_INNKEEPER              = $00010000;
  UNIT_NPC_FLAG_BANKER                 = $00020000;
  UNIT_NPC_FLAG_PETITIONER             = $00040000;
  UNIT_NPC_FLAG_TABARDVENDOR           = $00080000;
  UNIT_NPC_FLAG_BATTLEMASTER           = $00100000;
  UNIT_NPC_FLAG_AUCTIONEER             = $00200000;
  UNIT_NPC_FLAG_STABLE                 = $00400000; // Send $03E5 OpCode
  UNIT_NPC_FLAG_GUILD_BANKER           = $00800000;

  GOSSIP_ACTION_GOSSIP                 = $00;
  GOSSIP_ACTION_VENDOR                 = $01;
  GOSSIP_ACTION_TAXI                   = $02;
  GOSSIP_ACTION_TRAINER                = $03;
  GOSSIP_ACTION_HEALER                 = $04;
  GOSSIP_ACTION_INNKEEPER              = $05;
  GOSSIP_ACTION_BANKER                 = $06;
  GOSSIP_ACTION_PETITION               = $07;
  GOSSIP_ACTION_TABARD                 = $08;
  GOSSIP_ACTION_BATTLEMASTER           = $09;
  GOSSIP_ACTION_AUCTIONER              = $0A;
  GOSSIP_ACTION_GOSSIP2                = $0B;
  GOSSIP_ACTION_GOSSIP3                = $0C;

  SPELL_TARGET_FLAG_SELF               = $0000;
  SPELL_TARGET_FLAG_UNIT               = $0002;
  SPELL_TARGET_FLAG_ITEM               = $0010;
  SPELL_TARGET_FLAG_SOURCE_LOCATION    = $0020;
  SPELL_TARGET_FLAG_DEST_LOCATION      = $0040;
  SPELL_TARGET_FLAG_PVP_CORPSE         = $0200;
  SPELL_TARGET_FLAG_OBJECT             = $0800;
  SPELL_TARGET_FLAG_TRADE_ITEM         = $1000;
  SPELL_TARGET_FLAG_STRING             = $2000;
  SPELL_TARGET_FLAG_UNKNOWN            = $4000;
  SPELL_TARGET_FLAG_CORPSE             = $8000;

  ADDON_TYPE_BANNED                    = 0;
  ADDON_TYPE_ENABLED                   = 1;
  ADDON_TYPE_BLIZZARD                  = 2;
  BlizzardPublicKey: array [0..255] of byte =
  ($C3, $5B, $50, $84,  $B9, $3E, $32, $42,  $8C, $D0, $C7, $48,  $FA, $0E, $5D, $54,
   $5A, $A3, $0E, $14,  $BA, $9E, $0D, $B9,  $5D, $8B, $EE, $B6,  $84, $93, $45, $75,
   $FF, $31, $FE, $2F,  $64, $3F, $3D, $6D,  $07, $D9, $44, $9B,  $40, $85, $59, $34,
   $4E, $10, $E1, $E7,  $43, $69, $EF, $7C,  $16, $FC, $B4, $ED,  $1B, $95, $28, $A8,
   $23, $76, $51, $31,  $57, $30, $2B, $79,  $08, $50, $10, $1C,  $4A, $1A, $2C, $C8,
   $8B, $8F, $05, $2D,  $22, $3D, $DB, $5A,  $24, $7A, $0F, $13,  $50, $37, $8F, $5A,
   $CC, $9E, $04, $44,  $0E, $87, $01, $D4,  $A3, $15, $94, $16,  $34, $C6, $C2, $C3,
   $FB, $49, $FE, $E1,  $F9, $DA, $8C, $50,  $3C, $BE, $2C, $BB,  $57, $ED, $46, $B9,
   $AD, $8B, $C6, $DF,  $0E, $D6, $0F, $BE,  $80, $B3, $8B, $1E,  $77, $CF, $AD, $22,
   $CF, $B7, $4B, $CF,  $FB, $F0, $6B, $11,  $45, $2D, $7A, $81,  $18, $F2, $92, $7E,
   $98, $56, $5D, $5E,  $69, $72, $0A, $0D,  $03, $0A, $85, $A2,  $85, $9C, $CB, $FB,
   $56, $6E, $8F, $44,  $BB, $8F, $02, $22,  $68, $63, $97, $BC,  $85, $BA, $A8, $F7,
   $B5, $40, $68, $3C,  $77, $86, $6F, $4B,  $D7, $88, $CA, $8A,  $D7, $CE, $36, $F0,
   $45, $6E, $D5, $64,  $79, $0F, $17, $FC,  $64, $DD, $10, $6F,  $F3, $F5, $E0, $A6,
   $C3, $FB, $1B, $8C,  $29, $EF, $8E, $E5,  $34, $CB, $D1, $2A,  $CE, $79, $C3, $9A,
   $0D, $36, $EA, $01,  $E0, $AA, $91, $20,  $54, $F0, $72, $D8,  $1E, $C7, $89, $D2);
  BlizzardPublickKeyCRC                = $4C1C776D;

  // Inventory
  INVTYPE_NON_EQUIP                    = 0;
  INVTYPE_HEAD                         = 1;
  INVTYPE_NECK                         = 2;
  INVTYPE_SHOULDERS                    = 3;
  INVTYPE_BODY                         = 4; // cloth robes only
  INVTYPE_CHEST                        = 5;
  INVTYPE_WAIST                        = 6;
  INVTYPE_LEGS                         = 7;
  INVTYPE_FEET                         = 8;
  INVTYPE_WRISTS                       = 9;
  INVTYPE_HANDS                        = 10;
  INVTYPE_FINGER                       = 11;
  INVTYPE_TRINKET                      = 12;
  INVTYPE_WEAPON                       = 13;
  INVTYPE_SHIELD                       = 14;
  INVTYPE_RANGED                       = 15;
  INVTYPE_CLOAK                        = 16;
  INVTYPE_TWOHAND_WEAPON               = 17;
  INVTYPE_BAG                          = 18;
  INVTYPE_TABARD                       = 19;
  INVTYPE_ROBE                         = 20;
  INVTYPE_WEAPONMAINHAND               = 21;
  INVTYPE_WEAPONOFFHAND                = 22;
  INVTYPE_HOLDABLE                     = 23;
  INVTYPE_AMMO                         = 24;
  INVTYPE_THROWN                       = 25;
  INVTYPE_RANGEDRIGHT                  = 26;
  INVTYPE_QUIVER                       = 27;
  INVTYPE_RELIC                        = 28;

  EQUIPMENT_SLOT_HEAD                  = 0;
  EQUIPMENT_SLOT_NECK                  = 1;
  EQUIPMENT_SLOT_SHOULDERS             = 2;
  EQUIPMENT_SLOT_BODY                  = 3;
  EQUIPMENT_SLOT_CHEST                 = 4;
  EQUIPMENT_SLOT_WAIST                 = 5;
  EQUIPMENT_SLOT_LEGS                  = 6;
  EQUIPMENT_SLOT_FEET                  = 7;
  EQUIPMENT_SLOT_WRISTS                = 8;
  EQUIPMENT_SLOT_HANDS                 = 9;
  EQUIPMENT_SLOT_FINGER1               = 10;
  EQUIPMENT_SLOT_FINGER2               = 11;
  EQUIPMENT_SLOT_TRINKET1              = 12;
  EQUIPMENT_SLOT_TRINKET2              = 13;
  EQUIPMENT_SLOT_BACK                  = 14;
  EQUIPMENT_SLOT_MAINHAND              = 15;
  EQUIPMENT_SLOT_OFFHAND               = 16;
  EQUIPMENT_SLOT_RANGED                = 17;
  EQUIPMENT_SLOT_TABARD                = 18;

  EQUIP_SLOT_TYPE: array [EQUIPMENT_SLOT_HEAD..EQUIPMENT_SLOT_TABARD] of set of byte = (
    [INVTYPE_HEAD],                                                         // 0:  EQUIPMENT_SLOT_HEAD
    [INVTYPE_NECK],                                                         // 1:  EQUIPMENT_SLOT_NECK
    [INVTYPE_SHOULDERS],                                                    // 2:  EQUIPMENT_SLOT_SHOULDERS
    [INVTYPE_BODY],                                                         // 3:  EQUIPMENT_SLOT_BODY
    [INVTYPE_CHEST,INVTYPE_ROBE],                                           // 4:  EQUIPMENT_SLOT_CHEST
    [INVTYPE_WAIST],                                                        // 5:  EQUIPMENT_SLOT_WAIST
    [INVTYPE_LEGS],                                                         // 6:  EQUIPMENT_SLOT_LEGS
    [INVTYPE_FEET],                                                         // 7:  EQUIPMENT_SLOT_FEET
    [INVTYPE_WRISTS],                                                       // 8:  EQUIPMENT_SLOT_WRISTS
    [INVTYPE_HANDS],                                                        // 9:  EQUIPMENT_SLOT_HANDS
    [INVTYPE_FINGER],                                                       // 10: EQUIPMENT_SLOT_FINGER1
    [INVTYPE_FINGER],                                                       // 11: EQUIPMENT_SLOT_FINGER2
    [INVTYPE_TRINKET],                                                      // 12: EQUIPMENT_SLOT_TRINKET1
    [INVTYPE_TRINKET],                                                      // 13: EQUIPMENT_SLOT_TRINKET2
    [INVTYPE_CLOAK],                                                        // 14: EQUIPMENT_SLOT_BACK
    [INVTYPE_WEAPON,INVTYPE_TWOHAND_WEAPON,INVTYPE_WEAPONMAINHAND],         // 15: EQUIPMENT_SLOT_MAINHAND
    [INVTYPE_WEAPON,INVTYPE_SHIELD,INVTYPE_WEAPONOFFHAND,INVTYPE_HOLDABLE], // 16: EQUIPMENT_SLOT_OFFHAND
    [INVTYPE_RANGED,INVTYPE_AMMO,INVTYPE_THROWN,INVTYPE_RANGEDRIGHT],       // 17: EQUIPMENT_SLOT_RANGED
    [INVTYPE_TABARD]                                                        // 18: EQUIPMENT_SLOT_TABARD
  );

  MaxContainerSlot                     = 40;
  MaxInventorySlot                     = 113;

  InventoryEquipSlotsCount             = 19;
  InventoryBagSlotsCount               = 4;
  InventoryPackSlotsCount              = 16; // (PLAYER_FIELD_BANK_SLOT_1 - PLAYER_FIELD_PACK_SLOT_1) div 2
  InventoryBankSlotsCount              = 28; // (PLAYER_FIELD_BANKBAG_SLOT_1 - PLAYER_FIELD_BANK_SLOT_1) div 2
  InventoryBankBagSlotsCount           = 7;  // (PLAYER_FIELD_VENDORBUYBACK_SLOT_1 - PLAYER_FIELD_BANKBAG_SLOT_1) div 2
  InventoryVendorBuyBackSlotsCount     = 12; // (PLAYER_FIELD_KEYRING_SLOT_1 - PLAYER_FIELD_VENDORBUYBACK_SLOT_1) div 2
  InventoryKeyRingSlotsCount           = 32; // (PLAYER_FARSIGHT - PLAYER_FIELD_KEYRING_SLOT_1) div 2

  InventoryEquipSlotStart              = 0;
  InventoryBagSlotStart                = InventoryEquipSlotStart         +InventoryEquipSlotsCount;
  InventoryPackSlotStart               = InventoryBagSlotStart           +InventoryBagSlotsCount;
  InventoryBankSlotStart               = InventoryPackSlotStart          +InventoryPackSlotsCount;
  InventoryBankBagSlotStart            = InventoryBankSlotStart          +InventoryBankSlotsCount;
  InventoryVendorBuyBackSlotStart      = InventoryBankBagSlotStart       +InventoryBankBagSlotsCount;
  InventoryKeyRingSlot                 = InventoryVendorBuyBackSlotStart +InventoryVendorBuyBackSlotsCount;

  EQUIP_ERR_OK                                   = 0;
  EQUIP_ERR_YOU_MUST_REACH_LEVEL_N               = 1;
  EQUIP_ERR_SKILL_ISNT_ENOUGH_TO_USE_ITEM        = 2;
  EQUIP_ERR_ITEM_DOESNT_GO_TO_SLOT               = 3;
  EQUIP_ERR_BAG_FULL                             = 4;
  EQUIP_ERR_PUT_NONEMPTY_BAG_TO_OTHER_BAG        = 5;
  EQUIP_ERR_CANT_TRADE_EQUIPPED_BAGS             = 6;
  EQUIP_ERR_ONLY_AMMO_CAN_GO_HERE                = 7;
  EQUIP_ERR_NO_REQUIRED_PROFICIENCY              = 8;
  EQUIP_ERR_NO_EQUIPMENT_SLOT_AVAILABLE          = 9;
  EQUIP_ERR_YOU_CAN_NEVER_USE_THAT_ITEM          = 10;
  EQUIP_ERR_YOU_CAN_NEVER_USE_THAT_ITEM2         = 11;
  EQUIP_ERR_NO_EQUIPMENT_SLOTS_IS_AVAILABLE      = 12;
  EQUIP_ERR_CANT_EQUIP_WITH_TWO_HANDED           = 13;
  EQUIP_ERR_CANT_DUAL_WIELD_YET                  = 14;
  EQUIP_ERR_ITEM_DOESNT_GO_INTO_BAG              = 15;
  EQUIP_ERR_ITEM_DOESNT_GO_INTO_BAG2             = 16;
  EQUIP_ERR_CANT_CARRY_MORE_OF_THIS              = 17;
  EQUIP_ERR_NO_EQUIPMENT_SLOT_AVAILABLE2         = 18;
  EQUIP_ERR_ITEM_CANT_STACK                      = 19;
  EQUIP_ERR_ITEM_CANT_BE_EQUIPPED                = 20;
  EQUIP_ERR_ITEMS_CANT_BE_SWAPPED                = 21;
  EQUIP_ERR_SLOT_IS_EMPTY                        = 22;
  EQUIP_ERR_ITEM_NOT_FOUND                       = 23;
  EQUIP_ERR_CANT_DROP_SOULBOUND                  = 24;
  EQUIP_ERR_OUT_OF_RANGE                         = 25;
  EQUIP_ERR_TRIED_TO_SPLIT_MORE_THAN_COUNT       = 26;
  EQUIP_ERR_COULDNT_SPLIT_ITEMS                  = 27;
  EQUIP_ERR_BAG_FULL2                            = 28;
  EQUIP_ERR_NOT_ENOUGH_MONEY                     = 29;
  EQUIP_ERR_NOT_A_BAG                            = 30;
  EQUIP_ERR_CAN_ONLY_DO_WITH_EMPTY_BAGS          = 31;
  EQUIP_ERR_DONT_OWN_THAT_ITEM                   = 32;
  EQUIP_ERR_CAN_EQUIP_ONLY1_QUIVER               = 33;
  EQUIP_ERR_MUST_PURCHASE_THAT_BAG_SLOT          = 34;
  EQUIP_ERR_TOO_FAR_AWAY_FROM_BANK               = 35;
  EQUIP_ERR_ITEM_LOCKED                          = 36;
  EQUIP_ERR_YOU_ARE_STUNNED                      = 37;
  EQUIP_ERR_YOU_ARE_DEAD                         = 38;
  EQUIP_ERR_CANT_DO_RIGHT_NOW                    = 39;
  EQUIP_ERR_BAG_FULL3                            = 40;
  EQUIP_ERR_CAN_EQUIP_ONLY1_QUIVER2              = 41;
  EQUIP_ERR_CAN_EQUIP_ONLY1_AMMO_POUCH           = 42;
  EQUIP_ERR_STACKABLE_CANT_BE_WRAPPED            = 43;
  EQUIP_ERR_EQUIPPED_CANT_BE_WRAPPED             = 44;
  EQUIP_ERR_WRAPPED_CANT_BE_WRAPPED              = 45;
  EQUIP_ERR_BOUND_CANT_BE_WRAPPED                = 46;
  EQUIP_ERR_UNIQUE_CANT_BE_WRAPPED               = 47;
  EQUIP_ERR_BAGS_CANT_BE_WRAPPED                 = 48;
  EQUIP_ERR_ALREADY_LOOTED                       = 49;
  EQUIP_ERR_INVENTORY_FULL                       = 50;
  EQUIP_ERR_BANK_FULL                            = 51;
  EQUIP_ERR_ITEM_IS_CURRENTLY_SOLD_OUT           = 52;
  EQUIP_ERR_BAG_FULL4                            = 53;
  EQUIP_ERR_ITEM_NOT_FOUND2                      = 54;
  EQUIP_ERR_ITEM_CANT_STACK2                     = 55;
  EQUIP_ERR_BAG_FULL5                            = 56;
  EQUIP_ERR_ITEM_SOLD_OUT                        = 57;
  EQUIP_ERR_OBJECT_IS_BUSY                       = 58;
  EQUIP_ERR_NONE                                 = 59;
  EQUIP_ERR_CANT_DO_IN_COMBAT                    = 60;
  EQUIP_ERR_CANT_DO_WHILE_DISARMED               = 61;
  EQUIP_ERR_NONE2                                = 62;
  EQUIP_ERR_ITEM_RANK_NOT_ENOUGH                 = 63;
  EQUIP_ERR_ITEM_REPUTATION_NOT_ENOUGH           = 64;
  EQUIP_ERR_CANT_EQUIP_ANOTHER_BAG_OF_THAT_TYPE  = 65;
  EQUIP_ERR_CANT_LOOT                            = 66;

  ITEM_PUSH_FROM_QUEST_REWARD          = -1;
  ITEM_PUSH_FROM_LOOT                  = 0;
  ITEM_PUSH_FROM_ITEM                  = 1;
  ITEM_PUSH_TYPE_RECEIVE               = 0;
  ITEM_PUSH_TYPE_CREATE                = 1;
  ITEM_PUSH_DISPLAY_OFF                = 0;
  ITEM_PUSH_DISPLAY_ON                 = 1;

implementation

end.
