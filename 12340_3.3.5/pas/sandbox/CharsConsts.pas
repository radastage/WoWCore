unit CharsConsts;

interface

uses
  Struct, Defines;

procedure MakeRaceClassDefaultParams(race, cclass, gender: byte; var c: TCharData);

implementation

uses
  CharsConstsAlliance, CharsConstsHorde,
  Windows;

procedure MakeRaceClassDefaultParams(race, cclass, gender: byte; var c: TCharData);
begin
  c.Enum.GUID:= GetTickCount or GUID_TYPE_PLAYER;
  
  c.ItemsInit;
  c.SkillsInit;
  c.SpellsInit;
  c.ActionButtonsInit;
  c.Enum.mapID                 := 1;
  c.Enum.position.x            := 7927;
  c.Enum.position.y            := -2624;
  c.Enum.position.z            := 492.5;
  c.facing                     := 0;
  c.SkillsAdd($0000,98, 300,300, 0,0);
  c.SkillsAdd($0000,101, 300,300, 0,0);
  c.SkillsAdd($0000,109, 300,300, 0,0);
  c.SkillsAdd($0000,111, 300,300, 0,0);
  c.SkillsAdd($0000,113, 300,300, 0,0);
  c.SkillsAdd($0000,115, 300,300, 0,0);
  c.SkillsAdd($0000,137, 300,300, 0,0);
  c.SkillsAdd($0000,138, 300,300, 0,0);
  c.SkillsAdd($0000,139, 300,300, 0,0);
  c.SkillsAdd($0000,140, 300,300, 0,0);
  c.SkillsAdd($0000,141, 300,300, 0,0);
  c.SkillsAdd($0000,313, 300,300, 0,0);
  c.SkillsAdd($0000,315, 300,300, 0,0);
  c.SkillsAdd($0000,673, 300,300, 0,0);
  c.SkillsAdd($0000,759, 300,300, 0,0);
  c.SkillsAdd($0000,798, 300,300, 0,0);
  c.SkillsAdd($0000,799, 300,300, 0,0);
  c.SkillsAdd($0000,801, 300,300, 0,0);
  c.SkillsAdd($0000,805, 300,300, 0,0);
  c.SkillsAdd($0000,807, 300,300, 0,0);

  c.scale_x                    := 1;
  c.power_type                 := 1;
  c.max_health                 := 50;
  c.max_power[POWER_MANA]      := 0;
  c.max_power[POWER_RAGE]      := 1000;
  c.max_power[POWER_FOCUS]     := 100;
  c.max_power[POWER_ENERGY]    := 100;
  c.max_power[POWER_HAPPINESS] := 0;
  c.max_power[POWER_RUNES]     := 8;
  c.max_power[POWER_RUNIC]     := 1000;
  c.health                     := 50;
  c.power[POWER_MANA]          := 0;
  c.power[POWER_RAGE]          := 0;
  c.power[POWER_FOCUS]         := 100;
  c.power[POWER_ENERGY]        := 100;
  c.power[POWER_HAPPINESS]     := 0;
  c.power[POWER_RUNES]         := 8;
  c.power[POWER_RUNIC]         := 0;
  c.Enum.experienceLevel       := 1;
  c.faction_template           := 1;
  c.flags                      := $00000008;
  c.flags2                     := $00000800;
  c.mainhand_attack_time       := 2900;
  c.offhand_attack_time        := 2000;
  c.ranged_attack_time         := 0;
  c.bounding_radius            := 0.208000;
  c.combat_reach               := 1.5;
  c.enum_model                 := 1824;
  c.native_model               := 1824;
  c.mount_model                := 0;
  c.min_damage                 := 9.007143;
  c.max_damage                 := 11.007143;
  c.min_offhand_damage         := 0;
  c.max_offhand_damage         := 0;
  c.mod_cast_speed             := 1;
  c.stat[0]                    := 15;
  c.stat[1]                    := 15;
  c.stat[2]                    := 15;
  c.stat[3]                    := 15;
  c.stat[4]                    := 15;
  c.resist[0]                  := 0;
  c.resist[1]                  := 0;
  c.resist[2]                  := 0;
  c.resist[3]                  := 0;
  c.resist[4]                  := 0;
  c.resist[5]                  := 0;
  c.resist[6]                  := 0;
  c.base_mana                  := 0;
  c.base_health                := 20;
  c.attack_power               := 29;
  c.ranged_attack_time         := 0;
  c.min_ranged_damage          := 0;
  c.max_ranged_damage          := 0;
  c.hover_height               := 1;

  c.player_flags               := $00000000;
  c.xp                         := 0;
  c.next_level_xp              := 400;
  c.points1                    := 0;
  c.professions_left           := 2;
  c.ammo_id                    := 0;

//  c.ReputationsInit(race,cclass);

  Case race of
    // -------------------------------------------------------------------------
    // ALLIANCE
    // -------------------------------------------------------------------------
    RACE_HUMAN:
    begin
      case cclass of
        CLASS_WARRIOR:     RACE_HUMAN_CLASS_WARRIOR(c);
        CLASS_PALADIN:     RACE_HUMAN_CLASS_PALADIN(c);
        CLASS_ROGUE:       RACE_HUMAN_CLASS_ROGUE(c);
        CLASS_PRIEST:      RACE_HUMAN_CLASS_PRIEST(c);
        CLASS_DEATHKNIGHT: RACE_HUMAN_CLASS_DEATHKNIGHT(c);
        CLASS_MAGE:        RACE_HUMAN_CLASS_MAGE(c);
        CLASS_WARLOCK:     RACE_HUMAN_CLASS_WARLOCK(c);
      end;
    end;

    RACE_DWARF:
    begin
      case cclass of
        CLASS_WARRIOR:     RACE_DWARF_CLASS_WARRIOR(c);
        CLASS_PALADIN:     RACE_DWARF_CLASS_PALADIN(c);
        CLASS_HUNTER:      RACE_DWARF_CLASS_HUNTER(c);
        CLASS_ROGUE:       RACE_DWARF_CLASS_ROGUE(c);
        CLASS_PRIEST:      RACE_DWARF_CLASS_PRIEST(c);
        CLASS_DEATHKNIGHT: RACE_DWARF_CLASS_DEATHKNIGHT(c);
      end;
    end;

    RACE_NIGHT_ELF:
    begin
      case cclass of
        CLASS_WARRIOR:     RACE_NIGHTELF_CLASS_WARRIOR(c);
        CLASS_HUNTER:      RACE_NIGHTELF_CLASS_HUNTER(c);
        CLASS_ROGUE:       RACE_NIGHTELF_CLASS_ROGUE(c);
        CLASS_PRIEST:      RACE_NIGHTELF_CLASS_PRIEST(c);
        CLASS_DEATHKNIGHT: RACE_NIGHTELF_CLASS_DEATHKNIGHT(c);
        CLASS_DRUID:       RACE_NIGHTELF_CLASS_DRUID(c);
      end;
    end;

    RACE_GNOME:
    begin
      case cclass of
        CLASS_WARRIOR:     RACE_GNOME_CLASS_WARRIOR(c);
        CLASS_ROGUE:       RACE_GNOME_CLASS_ROGUE(c);
        CLASS_DEATHKNIGHT: RACE_GNOME_CLASS_DEATHKNIGHT(c);
        CLASS_MAGE:        RACE_GNOME_CLASS_MAGE(c);
        CLASS_WARLOCK:     RACE_GNOME_CLASS_WARLOCK(c);
      end;
    end;

    RACE_DRAENEI:
    begin
      case cclass of
        CLASS_WARRIOR:     RACE_DRAENEI_CLASS_WARRIOR(c);
        CLASS_PALADIN:     RACE_DRAENEI_CLASS_PALADIN(c);
        CLASS_HUNTER:      RACE_DRAENEI_CLASS_HUNTER(c);
        CLASS_PRIEST:      RACE_DRAENEI_CLASS_PRIEST(c);
        CLASS_DEATHKNIGHT: RACE_DRAENEI_CLASS_DEATHKNIGHT(c);
        CLASS_SHAMAN:      RACE_DRAENEI_CLASS_SHAMAN(c);
        CLASS_MAGE:        RACE_DRAENEI_CLASS_MAGE(c);
      end;
    end;

    // -------------------------------------------------------------------------
    // HORDE
    // -------------------------------------------------------------------------
    RACE_ORC:
    begin
      case cclass of
        CLASS_WARRIOR:     RACE_ORC_CLASS_WARRIOR(c);
        CLASS_HUNTER:      RACE_ORC_CLASS_HUNTER(c);
        CLASS_ROGUE:       RACE_ORC_CLASS_ROGUE(c);
        CLASS_DEATHKNIGHT: RACE_ORC_CLASS_DEATHKNIGHT(c);
        CLASS_SHAMAN:      RACE_ORC_CLASS_SHAMAN(c);
        CLASS_WARLOCK:     RACE_ORC_CLASS_WARLOCK(c);
      end;
    end;

    RACE_UNDEAD:
    begin
      case cclass of
        CLASS_WARRIOR:     RACE_UNDEAD_CLASS_WARRIOR(c);
        CLASS_ROGUE:       RACE_UNDEAD_CLASS_ROGUE(c);
        CLASS_PRIEST:      RACE_UNDEAD_CLASS_PRIEST(c);
        CLASS_DEATHKNIGHT: RACE_UNDEAD_CLASS_DEATHKNIGHT(c);
        CLASS_MAGE:        RACE_UNDEAD_CLASS_MAGE(c);
        CLASS_WARLOCK:     RACE_UNDEAD_CLASS_WARLOCK(c);
      end;
    end;

    RACE_TAUREN:
    begin
      case cclass of
        CLASS_WARRIOR:     RACE_TAUREN_CLASS_WARRIOR(c);
        CLASS_HUNTER:      RACE_TAUREN_CLASS_HUNTER(c);
        CLASS_DEATHKNIGHT: RACE_TAUREN_CLASS_DEATHKNIGHT(c);
        CLASS_SHAMAN:      RACE_TAUREN_CLASS_SHAMAN(c);
        CLASS_DRUID:       RACE_TAUREN_CLASS_DRUID(c);
      end;
    end;

    RACE_TROLL:
    begin
      case cclass of
        CLASS_WARRIOR:     RACE_TROLL_CLASS_WARRIOR(c);
        CLASS_HUNTER:      RACE_TROLL_CLASS_HUNTER(c);
        CLASS_ROGUE:       RACE_TROLL_CLASS_ROGUE(c);
        CLASS_PRIEST:      RACE_TROLL_CLASS_PRIEST(c);
        CLASS_DEATHKNIGHT: RACE_TROLL_CLASS_DEATHKNIGHT(c);
        CLASS_SHAMAN:      RACE_TROLL_CLASS_SHAMAN(c);
        CLASS_MAGE:        RACE_TROLL_CLASS_MAGE(c);
      end;
    end;

    RACE_BLOOD_ELF:
    begin
      case cclass of
        CLASS_PALADIN:     RACE_BLOODELF_CLASS_PALADIN(c);
        CLASS_HUNTER:      RACE_BLOODELF_CLASS_HUNTER(c);
        CLASS_ROGUE:       RACE_BLOODELF_CLASS_ROGUE(c);
        CLASS_PRIEST:      RACE_BLOODELF_CLASS_PRIEST(c);
        CLASS_DEATHKNIGHT: RACE_BLOODELF_CLASS_DEATHKNIGHT(c);
        CLASS_MAGE:        RACE_BLOODELF_CLASS_MAGE(c);
        CLASS_WARLOCK:     RACE_BLOODELF_CLASS_WARLOCK(c);
      end;
    end;
  End;

  c.SpellsAdd(668, 0);
  c.SpellsAdd(669, 0);
  c.SpellsAdd(670, 0);
  c.SpellsAdd(671, 0);
  c.SpellsAdd(672, 0);
  c.SpellsAdd(813, 0);
  c.SpellsAdd(814, 0);
  c.SpellsAdd(815, 0);
  c.SpellsAdd(816, 0);
  c.SpellsAdd(817, 0);
  c.SpellsAdd(7340, 0);
  c.SpellsAdd(7341, 0);
  c.SpellsAdd(17737, 0);
  c.SpellsAdd(29932, 0);
  c.speed_walk             := 2.5;
  c.speed_run              := 7.0;
  c.speed_run_back         := 4.5;
  c.speed_swim             := 4.722222;
  c.speed_swim_back        := 2.5;
  c.speed_flight           := 7.0;
  c.speed_flight_back      := 4.5;

  c.Enum.restInfo          := 2;
  c.Enum.guildID           := 0;
  c.Enum.petDisplayInfoID  := 0;
  c.Enum.petExperienceLevel:= 0;
  c.Enum.petCreatureFamilyID:= 0;
  c.native_model           := c.enum_model;
  c.enum_model_backup      := c.enum_model;
  c.mount_model            := 0;

  c.stand_state:= 0;
  c.sheathed:= 0;
  c.rest_state_xp          := 0;
  c.coinage                := 0;
end;

end.
