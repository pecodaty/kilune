import { useState, useEffect } from "react";
import {
  Home, Users, Swords, ShoppingBag, Shield, MessageCircle,
  Lock, Gift, Map, Star, ChevronRight, ChevronUp, ChevronDown, X,
  Zap, BookOpen, PawPrint
} from "lucide-react";

// ─── RUNE ICONS ───────────────────────────────────────────────────────────────
const FireRune = () => (
  <svg viewBox="0 0 24 24" width="22" height="22" fill="none">
    <path d="M12 3C12 3 17 9 15.5 14.5C14.5 18 10 19 8.5 15.5C7.5 13 9.5 11 11 13C11.8 14.2 11 16 9.5 16" stroke="#ff7733" strokeWidth="1.4" strokeLinecap="round"/>
    <path d="M12 3C12 3 19 10 17 16C15.5 20.5 9 21 7 17C6 14.5 8 12 10 14" stroke="#ffaa44" strokeWidth="1" strokeLinecap="round" opacity="0.6"/>
    <circle cx="12" cy="17.5" r="2" fill="#ff7733" opacity="0.5"/>
  </svg>
);
const IceRune = () => (
  <svg viewBox="0 0 24 24" width="22" height="22" fill="none">
    <line x1="12" y1="3" x2="12" y2="21" stroke="#66ddff" strokeWidth="1.4" strokeLinecap="round"/>
    <line x1="3" y1="12" x2="21" y2="12" stroke="#66ddff" strokeWidth="1.4" strokeLinecap="round"/>
    <line x1="5.6" y1="5.6" x2="18.4" y2="18.4" stroke="#66ddff" strokeWidth="1.4" strokeLinecap="round"/>
    <line x1="18.4" y1="5.6" x2="5.6" y2="18.4" stroke="#66ddff" strokeWidth="1.4" strokeLinecap="round"/>
    <polygon points="12,4.5 13.2,6.8 12,6.2 10.8,6.8" fill="#aaeeff"/>
    <polygon points="12,19.5 13.2,17.2 12,17.8 10.8,17.2" fill="#aaeeff"/>
    <circle cx="12" cy="12" r="2.2" fill="#66ddff" opacity="0.25" stroke="#aaeeff" strokeWidth="0.8"/>
  </svg>
);
const WindRune = () => (
  <svg viewBox="0 0 24 24" width="22" height="22" fill="none">
    <path d="M4 8 Q10 6,14 8 Q18 10,20 8 Q21 7,20.5 6" stroke="#aaddcc" strokeWidth="1.4" strokeLinecap="round"/>
    <path d="M3 12 Q9 10,13 12 Q17 14,19 12" stroke="#88ccbb" strokeWidth="1.4" strokeLinecap="round"/>
    <path d="M4 16 Q8 14,11 16 Q14 18,16 16 Q17 15,16.5 14" stroke="#aaddcc" strokeWidth="1.4" strokeLinecap="round"/>
    <circle cx="20.5" cy="6" r="1.2" fill="#aaddcc" opacity="0.7"/>
    <circle cx="16.5" cy="14" r="1.2" fill="#aaddcc" opacity="0.7"/>
  </svg>
);
const ShadowRune = () => (
  <svg viewBox="0 0 24 24" width="22" height="22" fill="none">
    <circle cx="12" cy="12" r="7" stroke="#8855cc" strokeWidth="1.2" fill="none" opacity="0.5"/>
    <path d="M12 5 L13.5 9 L17 9 L14.2 11.3 L15.3 15 L12 12.8 L8.7 15 L9.8 11.3 L7 9 L10.5 9 Z"
      stroke="#aa77ee" strokeWidth="1" fill="#6633aa" fillOpacity="0.3" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);
const AutoIcon = () => (
  <svg viewBox="0 0 16 16" width="13" height="13" fill="none">
    <path d="M13.5 8A5.5 5.5 0 1 1 8 2.5" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
    <path d="M10 2.5 L13.5 2.5 L13.5 6" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);

// ─── DATA ─────────────────────────────────────────────────────────────────────
const RARITY_COLOR: Record<string, string> = {
  Common: "#a090c0", Uncommon: "#22dd6e", Rare: "#448aff", Epic: "#aa44ff", Legendary: "#ffd700",
};

type InventoryItem = {
  id: string; name: string; slotType: string; level: number;
  rarity: keyof typeof RARITY_COLOR; color: string; icon: string;
  desc: string; stats: { label: string; value: string }[];
  enhancement: { current: number; max: number }; successChance: number;
  locked: { req: string; need: string }[];
  actions: string[];
};
const INVENTORY: InventoryItem[] = [
  {
    id: "trailguard", name: "Trailguard Armor", slotType: "armor", level: 3, rarity: "Rare",
    color: "#448aff", icon: "🛡️",
    desc: "Enchanted trailguard armor forged for heroes of the Shroomer realm.",
    stats: [{ label: "Health", value: "+22" }, { label: "Defense", value: "+2" }],
    enhancement: { current: 0, max: 12 }, successChance: 100,
    locked: [{ req: "+3", need: "4 Common or Rare" }, { req: "+6", need: "3 Rare" }, { req: "+9", need: "2 Epic" }, { req: "+12", need: "1 Legendary" }],
    actions: ["Enhance +1", "Arcane Dust ×1", "Refine"],
  },
  {
    id: "sunstep", name: "Sunstep Shoes", slotType: "shoes", level: 2, rarity: "Uncommon",
    color: "#22dd6e", icon: "👟",
    desc: "Feather-light shoes imbued with solar energy for swift movement.",
    stats: [{ label: "Speed", value: "+8" }, { label: "Agility", value: "+4" }],
    enhancement: { current: 0, max: 10 }, successChance: 100,
    locked: [{ req: "+3", need: "3 Common" }, { req: "+6", need: "2 Uncommon" }, { req: "+9", need: "1 Rare" }],
    actions: ["Enhance +1", "Solar Dust ×1", "Refine"],
  },
  {
    id: "ember_signet", name: "Ember Signet", slotType: "ring", level: 1, rarity: "Rare",
    color: "#ff7733", icon: "💍",
    desc: "A ring set with an ember crystal that pulses with inner flame.",
    stats: [{ label: "Power", value: "+15" }, { label: "Crit Chance", value: "+3%" }],
    enhancement: { current: 0, max: 12 }, successChance: 100,
    locked: [{ req: "+3", need: "4 Common or Rare" }, { req: "+6", need: "3 Rare" }, { req: "+9", need: "2 Epic" }, { req: "+12", need: "1 Legendary" }],
    actions: ["Enhance +1", "Arcane Dust ×1", "Refine"],
  },
  {
    id: "bulwark_band", name: "Bulwark Band", slotType: "accessory", level: 1, rarity: "Common",
    color: "#a090c0", icon: "📿",
    desc: "A simple band that offers a modest protective barrier.",
    stats: [{ label: "Defense", value: "+5" }, { label: "HP", value: "+10" }],
    enhancement: { current: 0, max: 8 }, successChance: 100,
    locked: [{ req: "+3", need: "3 Common" }, { req: "+6", need: "2 Uncommon" }],
    actions: ["Enhance +1", "Stone Dust ×1", "Refine"],
  },
];
const GEAR_SLOTS = [
  { id: "armor", label: "Armor", item: "trailguard" }, { id: "legs", label: "Legs", item: null },
  { id: "helmet", label: "Helmet", item: null }, { id: "belt", label: "Belt", item: null },
  { id: "shoes", label: "Shoes", item: "sunstep" }, { id: "shoulderpads", label: "Shoulderpads", item: null },
  { id: "weapon", label: "Weapon", item: null }, { id: "cape", label: "Cape", item: null },
  { id: "ring", label: "Ring", item: "ember_signet" }, { id: "accessory", label: "Accessory", item: "bulwark_band" },
  { id: "necklace", label: "Necklace", item: null }, { id: "wrist", label: "Wrist", item: null },
];
type TalentNode = { id: string; name: string; icon: string; current: number; max: number; color: string; desc: string };
const TALENTS_INIT: TalentNode[] = [
  { id: "atk", name: "Attack", icon: "⚔️", current: 2, max: 5, color: "#ff7733", desc: "Increases base Attack by 3% per level." },
  { id: "hp", name: "Health", icon: "💚", current: 1, max: 5, color: "#22dd6e", desc: "Increases max HP by 5% per level." },
  { id: "def", name: "Defense", icon: "🛡️", current: 0, max: 5, color: "#448aff", desc: "Increases Defense by 4% per level." },
  { id: "spd", name: "Attack Speed", icon: "⚡", current: 0, max: 5, color: "#ffd700", desc: "Increases attack speed by 2% per level." },
  { id: "crit", name: "Critical Chance", icon: "🎯", current: 0, max: 5, color: "#aa44ff", desc: "Increases critical hit chance by 2% per level." },
  { id: "skill", name: "Skill Power", icon: "✨", current: 1, max: 5, color: "#00e5c8", desc: "Increases Skill damage by 4% per level." },
];
const CAST_ORDER_INIT = [
  { id: "thorn_orb", name: "Thorn Orb", castTime: 3.0, icon: "🌿" },
  { id: "dew_restore", name: "Dew Restore", castTime: 8.0, icon: "💧" },
  { id: "canopy_wave", name: "Canopy Wave", castTime: 7.0, icon: "🌊" },
];
const HERO_CLASSES = [
  { id: "druid", name: "Druid", weapon: "Growth Staff", role: "Sustain Support", color: "#22dd6e", bgTint: "#0a2018", desc: "A sustaining nature channeler who restores allies and commands living magic.", tier: "Tier 0 · 8 Class Skills", skills: ["Thorn Orb","Draw Barriers","Thorn Ball","Vine Web","Screaming Light","Send Companion","Canopy Wave","Barn Guard"], advancements: ["Thornweaver","Grove Warden","Lifebloom Sage"], portrait: "🌿" },
  { id: "mage", name: "Mage", weapon: "Arcane Tome", role: "Burst Damage", color: "#448aff", bgTint: "#0a1428", desc: "A master of forbidden arcane arts who channels raw magical energy into devastating spells.", tier: "Tier 0 · 8 Class Skills", skills: ["Arcane Bolt","Mana Shield","Frost Nova","Blink","Arcane Surge","Ice Lance","Time Warp","Polymorph"], advancements: ["Archwizard","Spellbinder","Void Caller"], portrait: "✨" },
  { id: "warrior", name: "Warrior", weapon: "Greatsword", role: "Tank / DPS", color: "#ff7733", bgTint: "#2a1408", desc: "An unyielding frontline fighter who absorbs punishment and retaliates with crushing force.", tier: "Tier 0 · 8 Class Skills", skills: ["Shield Bash","Battle Cry","Whirlwind","Iron Skin","Charge","Rend","Rallying Cry","Bloodthirst"], advancements: ["Berserker","Paladin","Gladiator"], portrait: "⚔️" },
  { id: "assassin", name: "Assassin", weapon: "Twin Daggers", role: "Single Target DPS", color: "#aa44ff", bgTint: "#180a2a", desc: "A shadow-walking predator who eliminates single targets with precision and deadly efficiency.", tier: "Tier 0 · 8 Class Skills", skills: ["Backstab","Shadow Step","Smoke Screen","Poison Blade","Evasion","Fan of Knives","Death Mark","Shadowmeld"], advancements: ["Shadowblade","Nightstalker","Voidwalker"], portrait: "🗡️" },
  { id: "hunter", name: "Hunter", weapon: "Longbow", role: "Ranged DPS", color: "#ffd700", bgTint: "#2a2008", desc: "A keen-eyed tracker who commands beast companions and strikes from range with deadly arrows.", tier: "Tier 0 · 8 Class Skills", skills: ["Arrow Shot","Multi-Shot","Track Prey","Beast Bond","Camouflage","Explosive Trap","Eagle Eye","Volley"], advancements: ["Beastmaster","Ranger","Deadeye"], portrait: "🏹" },
] as const;
type HeroTab = "class" | "skills" | "talents" | "equipment" | "cards" | "pets";
type BattleView = "farming" | "lobby" | "dungeon";

const DUNGEONS = [
  { id: "golden", name: "Golden Dungeon", icon: "🔑", desc: "Raid the Sunken Vault and claim Gold.", reward: "Gold", rewardDesc: "Gold ×100", attempts: 3, maxAttempts: 3, power: 100, maxLevels: 5, enemy: "Gilded Scout", enemyIcon: "👑", color: "#ffd700" },
  { id: "cards", name: "Card Materials Dungeon", icon: "💎", desc: "Recover enhancement and refinement reagents.", reward: "Enhancement & Refinement", rewardDesc: "Enhancement ×5", attempts: 3, maxAttempts: 3, power: 150, maxLevels: 5, enemy: "Crystal Guardian", enemyIcon: "💎", color: "#448aff" },
  { id: "talent", name: "Talent Dungeon", icon: "⭐", desc: "Complete an ancient mastery trial.", reward: "Talent Materials", rewardDesc: "Talent Shard ×3", attempts: 3, maxAttempts: 3, power: 200, maxLevels: 5, enemy: "Trial Warden", enemyIcon: "⭐", color: "#aa44ff" },
  { id: "pet", name: "Pet Growth Dungeon", icon: "🐾", desc: "Gather Pet Essence in a companion sanctuary.", reward: "Pet Essence", rewardDesc: "Pet Essence ×10", attempts: 3, maxAttempts: 3, power: 120, maxLevels: 5, enemy: "Spirit Familiar", enemyIcon: "🌟", color: "#22dd6e" },
] as const;
type Dungeon = (typeof DUNGEONS)[number];

// ─── SHARED UI HELPERS ────────────────────────────────────────────────────────
function SectionPanel({ children, className = "" }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={`relative mx-2 my-1.5 ${className}`} style={{ background: "linear-gradient(180deg,#0e0a28 0%,#080418 100%)", border: "1px solid #2a184555" }}>
      <svg className="absolute inset-0 w-full h-full pointer-events-none" preserveAspectRatio="none" style={{ overflow: "visible" }}>
        <polyline points="0,14 0,0 14,0" fill="none" stroke="#d4a017" strokeWidth="1" opacity="0.45"/>
        <polyline points="calc(100% - 14),0 100%,0 100%,14" fill="none" stroke="#d4a017" strokeWidth="1" opacity="0.45"/>
        <polyline points="0,calc(100% - 14) 0,100% 14,100%" fill="none" stroke="#d4a017" strokeWidth="1" opacity="0.45"/>
        <polyline points="calc(100% - 14),100% 100%,100% 100%,calc(100% - 14)" fill="none" stroke="#d4a017" strokeWidth="1" opacity="0.45"/>
      </svg>
      <div className="relative z-10 p-3">{children}</div>
    </div>
  );
}
function SectionTitle({ children, action }: { children: React.ReactNode; action?: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between mb-3">
      <h3 style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 13, color: "#d4a017", letterSpacing: "0.06em" }}>{children}</h3>
      {action}
    </div>
  );
}
function HeroPillBtn({ label, color = "#00e5c8", onClick }: { label: string; color?: string; onClick?: () => void }) {
  return (
    <button onClick={onClick} className="flex items-center justify-center px-3" style={{ height: 26, background: "#0a0820", border: `1px solid ${color}55`, clipPath: "polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)" }}>
      <span style={{ fontSize: 9, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color, letterSpacing: "0.07em" }}>{label}</span>
    </button>
  );
}

// ─── ITEM MODAL ───────────────────────────────────────────────────────────────
type ModalPayload = { type: "item"; data: InventoryItem } | { type: "talent"; data: TalentNode };
function ItemModal({ payload, onClose }: { payload: ModalPayload; onClose: () => void }) {
  const isItem = payload.type === "item";
  const item = isItem ? payload.data : null;
  const talent = !isItem ? payload.data : null;
  const accentColor = isItem ? RARITY_COLOR[item!.rarity] : talent!.color;
  return (
    <div className="absolute inset-0 z-50 flex items-center justify-center" style={{ background: "#00000088" }}>
      <div className="relative mx-3 w-full" style={{ maxWidth: 340 }}>
        <div className="relative" style={{ background: "linear-gradient(180deg,#0e0a28 0%,#060418 100%)", border: `1px solid ${accentColor}44`, boxShadow: `0 0 24px ${accentColor}22` }}>
          {(["tl","tr","bl","br"] as const).map(c => (
            <svg key={c} className="absolute" style={{ width: 16, height: 16, top: c.startsWith("t") ? 0 : undefined, bottom: c.startsWith("b") ? 0 : undefined, left: c.endsWith("l") ? 0 : undefined, right: c.endsWith("r") ? 0 : undefined }} viewBox="0 0 16 16">
              {c === "tl" && <polyline points="0,12 0,0 12,0" fill="none" stroke="#d4a017" strokeWidth="1.2" opacity="0.6"/>}
              {c === "tr" && <polyline points="4,0 16,0 16,12" fill="none" stroke="#d4a017" strokeWidth="1.2" opacity="0.6"/>}
              {c === "bl" && <polyline points="0,4 0,16 12,16" fill="none" stroke="#d4a017" strokeWidth="1.2" opacity="0.6"/>}
              {c === "br" && <polyline points="4,16 16,16 16,4" fill="none" stroke="#d4a017" strokeWidth="1.2" opacity="0.6"/>}
            </svg>
          ))}
          <div className="px-4 pt-4 pb-4">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <span style={{ fontSize: 20 }}>{isItem ? item!.icon : talent!.icon}</span>
                <div>
                  <h2 style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 14, color: "#e8d8ff", letterSpacing: "0.04em", lineHeight: 1 }}>{isItem ? item!.name.toUpperCase() : talent!.name.toUpperCase()}</h2>
                  {isItem && <span style={{ fontSize: 9, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: accentColor, letterSpacing: "0.06em" }}>{item!.rarity.toUpperCase()} · Lv.{item!.level}</span>}
                </div>
              </div>
              <button onClick={onClose} className="flex items-center justify-center" style={{ width: 28, height: 22, background: "#1e1040", border: "1px solid #3d206077", clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
                <X size={12} style={{ color: "#c8a0e0" }}/>
              </button>
            </div>
            <div style={{ height: 1, background: `linear-gradient(90deg,transparent,${accentColor}44,transparent)`, marginBottom: 12 }}/>
            <p style={{ fontSize: 9.5, color: "#7a6a9a", fontFamily: "'Rajdhani',sans-serif", fontWeight: 500, lineHeight: 1.6, marginBottom: 10 }}>{isItem ? item!.desc : talent!.desc}</p>
            <div style={{ display: "flex", flexDirection: "column", gap: 5, marginBottom: 12 }}>
              {isItem && (<>
                <StatRow label="Standard" value={item!.rarity} valueColor={accentColor}/>
                <StatRow label="Enhancement" value={`+${item!.enhancement.current}/${item!.enhancement.max}`} valueColor="#e8d8ff"/>
                <StatRow label="Success Chance" value={`${item!.successChance}%`} valueColor="#22dd6e"/>
                {item!.stats.map((s, i) => <StatRow key={i} label={s.label} value={s.value} valueColor="#00e5c8"/>)}
                <StatRow label="Equipped" value={item!.slotType.charAt(0).toUpperCase() + item!.slotType.slice(1)} valueColor="#a090c0"/>
              </>)}
              {!isItem && talent && (<>
                <StatRow label="Points Invested" value={`${talent.current} / ${talent.max}`} valueColor={accentColor}/>
                <StatRow label="Effect" value={talent.desc.split("Increases ")[1] || ""} valueColor="#00e5c8"/>
              </>)}
            </div>
            {isItem && item!.locked.length > 0 && (
              <div style={{ marginBottom: 12 }}>
                <div style={{ height: 1, background: "#2a184555", marginBottom: 8 }}/>
                {item!.locked.map((l, i) => (
                  <div key={i} className="flex justify-between items-center" style={{ marginBottom: 4 }}>
                    <span style={{ fontSize: 8.5, color: "#5a4878", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600 }}>Locked {l.req}</span>
                    <span style={{ fontSize: 8.5, color: "#7060a0", fontFamily: "'Rajdhani',sans-serif" }}>{l.need}</span>
                  </div>
                ))}
              </div>
            )}
            <div style={{ height: 1, background: "#2a184555", marginBottom: 10 }}/>
            <div className="flex gap-2">
              {isItem ? item!.actions.map((act, i) => (
                <button key={i} className="flex-1 flex items-center justify-center" style={{ height: 30, background: i === 0 ? "linear-gradient(90deg,#0a1535,#0d1a40,#0a1535)" : "#0a0820", border: `1px solid ${i === 0 ? "#00e5c8" : "#3d206077"}`, clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)", filter: i === 0 ? "drop-shadow(0 0 5px #00e5c833)" : undefined }}>
                  <span style={{ fontSize: 8.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: i === 0 ? "#00e5c8" : "#6050a0", letterSpacing: "0.05em" }}>{act}</span>
                </button>
              )) : (<>
                <button className="flex-1 flex items-center justify-center" style={{ height: 30, background: "linear-gradient(90deg,#0a1535,#0d1a40,#0a1535)", border: `1px solid ${talent!.color}`, clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)", filter: `drop-shadow(0 0 5px ${talent!.color}33)` }}>
                  <span style={{ fontSize: 9, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: talent!.color, letterSpacing: "0.05em" }}>UPGRADE POINT</span>
                </button>
                <button className="flex items-center justify-center px-3" style={{ height: 30, background: "#0a0820", border: "1px solid #3d206077", clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)" }}>
                  <span style={{ fontSize: 9, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#5a4080" }}>MAX</span>
                </button>
              </>)}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
function StatRow({ label, value, valueColor = "#e8d8ff" }: { label: string; value: string; valueColor?: string }) {
  return (
    <div className="flex items-center justify-between">
      <span style={{ fontSize: 9, color: "#5a4878", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600, letterSpacing: "0.04em" }}>{label}</span>
      <span style={{ fontSize: 9, color: valueColor, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700 }}>{value}</span>
    </div>
  );
}

// ─── ITEM TILE ────────────────────────────────────────────────────────────────
function ItemTile({ item, onClick, selected }: { item: InventoryItem; onClick: () => void; selected?: boolean }) {
  const rc = RARITY_COLOR[item.rarity];
  return (
    <button onClick={onClick} className="relative flex items-center gap-2 w-full" style={{ height: 52, padding: "0 8px", background: selected ? "#12093299" : "#0a0720", border: `1px solid ${selected ? rc + "88" : "#2a184555"}`, clipPath: "polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)", filter: selected ? `drop-shadow(0 0 6px ${rc}33)` : undefined, transition: "all 0.15s" }}>
      <div style={{ position: "absolute", left: 0, top: 6, bottom: 6, width: 2, background: rc, borderRadius: 1 }}/>
      <div className="relative flex-shrink-0 flex items-center justify-center" style={{ width: 32, height: 32 }}>
        <svg viewBox="0 0 32 32" className="absolute inset-0 w-full h-full"><polygon points="8,1 24,1 31,8 31,24 24,31 8,31 1,24 1,8" fill="#0d0825" stroke={rc} strokeWidth="0.8" opacity="0.7"/></svg>
        <span className="relative" style={{ fontSize: 14 }}>{item.icon}</span>
      </div>
      <div className="flex flex-col items-start flex-1 overflow-hidden">
        <span style={{ fontSize: 9.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#c8b8e8", letterSpacing: "0.02em", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: "100%" }}>{item.name}</span>
        <span style={{ fontSize: 8, color: rc, fontFamily: "'Rajdhani',sans-serif", fontWeight: 600 }}>Lv.{item.level} · {item.rarity}</span>
      </div>
      <div className="flex flex-col items-end flex-shrink-0">
        {item.stats.slice(0, 2).map((s, i) => <span key={i} style={{ fontSize: 8, color: "#00e5c8", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700 }}>{s.label.substring(0, 3)} {s.value}</span>)}
      </div>
    </button>
  );
}

// ─── CLASS ICON ───────────────────────────────────────────────────────────────
function ClassIcon({ id, color }: { id: string; color: string }) {
  if (id === "druid") return <svg width="16" height="16" viewBox="0 0 18 18" fill="none"><path d="M9 14 C9 14 4 10 4 6 C4 3 6.5 1.5 9 1.5 C11.5 1.5 14 3 14 6 C14 10 9 14 9 14Z" stroke={color} strokeWidth="1.2" fill={color} fillOpacity="0.2"/><line x1="9" y1="14" x2="9" y2="17" stroke={color} strokeWidth="1.2" strokeLinecap="round"/></svg>;
  if (id === "mage") return <svg width="16" height="16" viewBox="0 0 18 18" fill="none"><path d="M9 1.5 L10.4 6.2 L15.5 7 L11.5 10.5 L12.6 16 L9 13.5 L5.4 16 L6.5 10.5 L2.5 7 L7.6 6.2 Z" stroke={color} strokeWidth="1" fill={color} fillOpacity="0.2" strokeLinejoin="round"/></svg>;
  if (id === "warrior") return <svg width="16" height="16" viewBox="0 0 18 18" fill="none"><line x1="4" y1="4" x2="14" y2="14" stroke={color} strokeWidth="1.5" strokeLinecap="round"/><line x1="14" y1="4" x2="4" y2="14" stroke={color} strokeWidth="1.5" strokeLinecap="round"/></svg>;
  if (id === "assassin") return <svg width="16" height="16" viewBox="0 0 18 18" fill="none"><path d="M4 14 L14 4 M14 4 L10 4 M14 4 L14 8" stroke={color} strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/><path d="M6 12 L3 15.5" stroke={color} strokeWidth="1.2" strokeLinecap="round" opacity="0.6"/></svg>;
  return <svg width="16" height="16" viewBox="0 0 18 18" fill="none"><path d="M3 15 Q3 3 15 3" fill="none" stroke={color} strokeWidth="1.4" strokeLinecap="round"/><line x1="6" y1="9" x2="17" y2="9" stroke={color} strokeWidth="1.2" strokeLinecap="round"/><polygon points="15,7 17,9 15,11" fill={color}/></svg>;
}

// ─── CLASS TAB ────────────────────────────────────────────────────────────────
function ClassTab() {
  const [selectedId, setSelectedId] = useState<string>("druid");
  const [currentId, setCurrentId] = useState<string>("druid");
  const cls = HERO_CLASSES.find(c => c.id === selectedId)!;
  const isCurrent = selectedId === currentId;
  return (
    <div className="flex flex-1 overflow-hidden" style={{ minHeight: 0 }}>
      <div className="flex flex-col flex-shrink-0 overflow-y-auto" style={{ width: 86, scrollbarWidth: "none", borderRight: "1px solid #1e143388" }}>
        {HERO_CLASSES.map(c => (
          <button key={c.id} onClick={() => setSelectedId(c.id)} className="relative flex items-center gap-2 flex-shrink-0" style={{ height: 48, padding: "0 8px 0 10px", background: selectedId === c.id ? `${c.bgTint}dd` : "transparent", borderBottom: "1px solid #1e143344", transition: "background 0.15s" }}>
            <div style={{ position: "absolute", left: 0, top: 8, bottom: 8, width: 2, background: selectedId === c.id ? c.color : "#2a1845", borderRadius: 1, transition: "background 0.15s" }}/>
            <ClassIcon id={c.id} color={selectedId === c.id ? c.color : "#3d2060"}/>
            <div className="flex flex-col items-start">
              <span style={{ fontSize: 9, fontFamily: "'Cinzel',serif", fontWeight: 700, color: selectedId === c.id ? c.color : "#3d2060", letterSpacing: "0.04em", lineHeight: 1, transition: "color 0.15s" }}>{c.name}</span>
              {currentId === c.id && <span style={{ fontSize: 6, color: "#ffd700", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, marginTop: 1 }}>CURRENT</span>}
            </div>
          </button>
        ))}
      </div>
      <div className="flex-1 flex flex-col overflow-y-auto" style={{ scrollbarWidth: "none" }}>
        <div className="relative flex-shrink-0" style={{ height: 180 }}>
          <div className="absolute inset-0" style={{ background: `radial-gradient(ellipse 70% 80% at 50% 60%, ${cls.bgTint} 0%, #06040f 70%)` }}/>
          <svg viewBox="0 0 300 180" className="absolute inset-0 w-full h-full" preserveAspectRatio="xMidYMid meet">
            <defs>
              <linearGradient id="cp-gold" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor="#ffe066"/><stop offset="50%" stopColor="#9a6400"/><stop offset="100%" stopColor="#ffd700"/></linearGradient>
              <linearGradient id="cp-inner" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stopColor={cls.color} stopOpacity="0.1"/><stop offset="100%" stopColor={cls.color} stopOpacity="0.02"/></linearGradient>
              <radialGradient id="cp-glow" cx="50%" cy="100%" r="50%"><stop offset="0%" stopColor={cls.color} stopOpacity="0.3"/><stop offset="100%" stopColor={cls.color} stopOpacity="0"/></radialGradient>
            </defs>
            <path d="M 22 175 L 22 90 Q 22 16 150 10 Q 278 16 278 90 L 278 175 Z" fill="url(#cp-inner)" stroke="url(#cp-gold)" strokeWidth="1.3"/>
            <path d="M 34 175 L 34 95 Q 34 30 150 25 Q 266 30 266 95 L 266 175" fill="none" stroke={cls.color} strokeWidth="0.7" opacity="0.3"/>
            <circle cx="22" cy="175" r="3" fill="#ffd700" opacity="0.5"/>
            <circle cx="278" cy="175" r="3" fill="#ffd700" opacity="0.5"/>
            <polygon points="150,8 154,13 150,11 146,13" fill="#ffd700" opacity="0.7"/>
            <ellipse cx="150" cy="172" rx="90" ry="13" fill="url(#cp-glow)"/>
          </svg>
          <div className="absolute inset-0 flex items-center justify-center" style={{ paddingTop: 20, paddingBottom: 18 }}>
            <span style={{ fontSize: 80, lineHeight: 1, filter: `drop-shadow(0 0 18px ${cls.color}66) drop-shadow(0 4px 10px #000000aa)` }}>{cls.portrait}</span>
          </div>
        </div>
        <div className="flex flex-col flex-1 px-3 pt-2 pb-3 gap-2.5">
          <div>
            <h2 style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 16, color: cls.color, letterSpacing: "0.06em" }}>{cls.name.toUpperCase()}</h2>
            <div className="flex flex-wrap gap-1.5 mt-1">
              {[cls.weapon, cls.role].map((tag, i) => (
                <span key={i} className="px-2 py-px" style={{ fontSize: 7.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: i === 0 ? "#c8a0e0" : cls.color, background: i === 0 ? "#2a184599" : `${cls.bgTint}cc`, border: `1px solid ${i === 0 ? "#3d206066" : cls.color + "44"}`, clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)", letterSpacing: "0.04em" }}>{tag}</span>
              ))}
            </div>
          </div>
          <p style={{ fontSize: 9.5, color: "#7060a0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 500, lineHeight: 1.6 }}>{cls.desc}</p>
          <div>
            <p style={{ fontSize: 8, fontFamily: "'Cinzel',serif", fontWeight: 700, color: "#8070a0", letterSpacing: "0.06em", marginBottom: 5 }}>ABILITIES</p>
            <button className="w-full flex items-center justify-between px-3" style={{ height: 32, background: `linear-gradient(90deg,${cls.bgTint}cc,#0d0825cc)`, border: `1px solid ${cls.color}44`, clipPath: "polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)" }}>
              <span style={{ fontSize: 9.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: cls.color, letterSpacing: "0.04em" }}>{cls.tier}</span>
              <ChevronRight size={12} style={{ color: cls.color, opacity: 0.7 }}/>
            </button>
          </div>
          <div>
            <p style={{ fontSize: 8, fontFamily: "'Cinzel',serif", fontWeight: 700, color: "#8070a0", letterSpacing: "0.06em", marginBottom: 5 }}>SKILL POOL</p>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 4 }}>
              {cls.skills.map((sk, i) => (
                <div key={i} className="flex items-center gap-1.5 px-2" style={{ height: 24, background: "#0a0720", border: "1px solid #1e143355", clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
                  <div style={{ width: 5, height: 5, borderRadius: "50%", background: cls.color, opacity: 0.6, flexShrink: 0 }}/>
                  <span style={{ fontSize: 8, color: "#6050a0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{sk}</span>
                </div>
              ))}
            </div>
          </div>
          <div>
            <p style={{ fontSize: 8, fontFamily: "'Cinzel',serif", fontWeight: 700, color: "#8070a0", letterSpacing: "0.06em", marginBottom: 5 }}>ADVANCEMENTS</p>
            <div className="flex gap-2">
              {cls.advancements.map((adv, i) => (
                <div key={i} className="flex-1 flex items-center justify-center px-1" style={{ height: 26, background: "#090618", border: "1px solid #2a184566", clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)" }}>
                  <span style={{ fontSize: 8, color: "#5040a0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, textAlign: "center" }}>{adv}</span>
                </div>
              ))}
            </div>
          </div>
          <button onClick={() => setCurrentId(selectedId)} className="w-full flex items-center justify-center gap-2 mt-1" style={{ height: 38, background: isCurrent ? `linear-gradient(90deg,${cls.bgTint},#0d1535,${cls.bgTint})` : "linear-gradient(90deg,#0a1535,#0d1a40,#0a1535)", border: `1.5px solid ${isCurrent ? cls.color : "#00e5c8"}`, clipPath: "polygon(8px 0%,100% 0%,calc(100% - 8px) 100%,0% 100%)", filter: `drop-shadow(0 0 8px ${isCurrent ? cls.color : "#00e5c8"}33)` }}>
            <div style={{ width: 4, height: 4, transform: "rotate(45deg)", background: isCurrent ? cls.color : "#00e5c8" }}/>
            <span style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 10, color: isCurrent ? cls.color : "#00e5c8", letterSpacing: "0.1em" }}>{isCurrent ? "CURRENT CLASS" : "SELECT CLASS"}</span>
            <div style={{ width: 4, height: 4, transform: "rotate(45deg)", background: isCurrent ? cls.color : "#00e5c8" }}/>
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── SKILLS TAB ───────────────────────────────────────────────────────────────
function SkillsTab() {
  const [castOrder, setCastOrder] = useState([...CAST_ORDER_INIT]);
  const [castDelay, setCastDelay] = useState("0.5");
  const [ifUnavailable, setIfUnavailable] = useState<"Skip" | "Wait">("Skip");
  const [oneCycle, setOneCycle] = useState(false);
  function move(idx: number, dir: -1 | 1) {
    const n = [...castOrder]; const target = idx + dir;
    if (target < 0 || target >= n.length) return;
    [n[idx], n[target]] = [n[target], n[idx]]; setCastOrder(n);
  }
  return (
    <div className="flex-1 overflow-y-auto px-2 py-2" style={{ scrollbarWidth: "none" }}>
      <SectionPanel>
        <SectionTitle>AUTO-CAST SETUP</SectionTitle>
        <p style={{ fontSize: 8.5, color: "#6050a0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600, letterSpacing: "0.05em", marginBottom: 10 }}>CAST ORDER</p>
        <div className="flex flex-col gap-2">
          {castOrder.map((skill, i) => (
            <div key={skill.id} className="flex items-center gap-2" style={{ height: 44, padding: "0 8px", background: "#0a0720", border: "1px solid #2a184555", clipPath: "polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)" }}>
              <div className="flex items-center justify-center flex-shrink-0" style={{ width: 20, height: 20, background: "#0d0528", border: "1px solid #3d206066", clipPath: "polygon(3px 0%,100% 0%,calc(100% - 3px) 100%,0% 100%)" }}>
                <span style={{ fontSize: 9, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#5a4080" }}>{i + 1}</span>
              </div>
              <div className="relative flex-shrink-0 flex items-center justify-center" style={{ width: 28, height: 28 }}>
                <svg viewBox="0 0 28 28" className="absolute inset-0 w-full h-full"><polygon points="7,1 21,1 27,7 27,21 21,27 7,27 1,21 1,7" fill="#0d0825" stroke="#3d206077" strokeWidth="0.8"/></svg>
                <span className="relative" style={{ fontSize: 13 }}>{skill.icon}</span>
              </div>
              <div className="flex flex-col flex-1">
                <span style={{ fontSize: 9.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#c8b8e8" }}>{skill.name}</span>
                <span style={{ fontSize: 8, fontFamily: "'Rajdhani',sans-serif", fontWeight: 600, color: "#5a4080" }}>{skill.castTime.toFixed(1)}s cast</span>
              </div>
              <div className="flex flex-col gap-px flex-shrink-0">
                <button onClick={() => move(i, -1)} className="flex items-center justify-center" style={{ width: 22, height: 18, background: "#0d0528", border: "1px solid #2a184555", opacity: i === 0 ? 0.3 : 1 }}><ChevronUp size={11} style={{ color: "#7060a0" }}/></button>
                <button onClick={() => move(i, 1)} className="flex items-center justify-center" style={{ width: 22, height: 18, background: "#0d0528", border: "1px solid #2a184555", opacity: i === castOrder.length - 1 ? 0.3 : 1 }}><ChevronDown size={11} style={{ color: "#7060a0" }}/></button>
              </div>
            </div>
          ))}
        </div>
        <div className="flex items-center gap-2 mt-4 mb-3">
          <div className="flex items-center gap-1.5">
            <span style={{ fontSize: 8, color: "#6050a0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, whiteSpace: "nowrap" }}>Cast Delay</span>
            <input value={castDelay} onChange={e => setCastDelay(e.target.value)} style={{ width: 36, height: 24, background: "#0a0720", border: "1px solid #3d206055", color: "#e8d8ff", fontSize: 9, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, textAlign: "center", outline: "none", clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}/>
          </div>
          <div className="flex items-center gap-1.5 flex-1">
            <span style={{ fontSize: 8, color: "#6050a0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, whiteSpace: "nowrap" }}>If Unavailable</span>
            <button onClick={() => setIfUnavailable(p => p === "Skip" ? "Wait" : "Skip")} className="flex items-center justify-center px-2" style={{ height: 24, background: "#0a0720", border: "1px solid #3d206055", clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
              <span style={{ fontSize: 9, color: "#00e5c8", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700 }}>{ifUnavailable} ▾</span>
            </button>
          </div>
          <button onClick={() => setOneCycle(p => !p)} className="flex items-center gap-1" style={{ height: 24, padding: "0 8px", background: oneCycle ? "#0a1535" : "#0a0720", border: `1px solid ${oneCycle ? "#00e5c8" : "#3d206055"}`, clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
            <div style={{ width: 6, height: 6, borderRadius: "50%", background: oneCycle ? "#00e5c8" : "#3d2060" }}/>
            <span style={{ fontSize: 8.5, color: oneCycle ? "#00e5c8" : "#5a4080", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700 }}>One Cycle</span>
          </button>
        </div>
        <div className="flex gap-2">
          {[{ label: "Reset", color: "#5a4080", bg: "#0a0720", border: "#3d206077" }, { label: "Cancel", color: "#aa77ff", bg: "#0a0720", border: "#5a3088" }, { label: "Apply", color: "#00e5c8", bg: "linear-gradient(90deg,#0a1535,#0d1a40,#0a1535)", border: "#00e5c8" }].map(btn => (
            <button key={btn.label} className="flex-1 flex items-center justify-center" style={{ height: 34, background: btn.bg, border: `1px solid ${btn.border}`, clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)", filter: btn.label === "Apply" ? "drop-shadow(0 0 5px #00e5c833)" : undefined }}>
              <span style={{ fontSize: 10, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: btn.color, letterSpacing: "0.06em" }}>{btn.label.toUpperCase()}</span>
            </button>
          ))}
        </div>
      </SectionPanel>
    </div>
  );
}

// ─── TALENTS TAB ──────────────────────────────────────────────────────────────
function TalentsTab({ onModal }: { onModal: (p: ModalPayload) => void }) {
  const [talents] = useState<TalentNode[]>(TALENTS_INIT.map(t => ({ ...t })));
  return (
    <div className="flex-1 overflow-y-auto px-2 py-2" style={{ scrollbarWidth: "none" }}>
      <SectionPanel>
        <SectionTitle action={<HeroPillBtn label="Reset Talents" color="#ff7733"/>}>TALENT CONSTELLATION</SectionTitle>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 6 }}>
          {talents.map(t => (
            <button key={t.id} onClick={() => onModal({ type: "talent", data: t })} className="relative flex flex-col items-center justify-center gap-1 py-2 px-1" style={{ background: t.current > 0 ? `${t.color}11` : "#0a0720", border: `1px solid ${t.current > 0 ? t.color + "44" : "#2a184555"}`, clipPath: "polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)", filter: t.current > 0 ? `drop-shadow(0 0 5px ${t.color}22)` : undefined, transition: "all 0.15s" }}>
              <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 2, background: t.current > 0 ? `linear-gradient(90deg,transparent,${t.color},transparent)` : "transparent", opacity: t.current > 0 ? 0.7 : 0 }}/>
              <div className="relative flex items-center justify-center" style={{ width: 28, height: 28 }}>
                <svg viewBox="0 0 28 28" className="absolute inset-0 w-full h-full"><polygon points="7,1 21,1 27,7 27,21 21,27 7,27 1,21 1,7" fill="#0d0825" stroke={t.current > 0 ? t.color : "#2a1845"} strokeWidth={t.current > 0 ? "1" : "0.7"} opacity={t.current > 0 ? 0.8 : 0.4}/></svg>
                <span style={{ fontSize: 13, position: "relative" }}>{t.icon}</span>
              </div>
              <span style={{ fontSize: 7.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: t.current > 0 ? t.color : "#4a3870", letterSpacing: "0.02em", textAlign: "center", lineHeight: 1.2 }}>{t.name}</span>
              <div className="flex gap-0.5">{Array.from({ length: t.max }).map((_, pi) => <div key={pi} style={{ width: 5, height: 5, borderRadius: "50%", background: pi < t.current ? t.color : "#2a1845", opacity: pi < t.current ? 1 : 0.4 }}/>)}</div>
              <span style={{ fontSize: 7, color: t.current > 0 ? "#a090c0" : "#3a2858", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600 }}>{t.current}/{t.max}</span>
            </button>
          ))}
        </div>
      </SectionPanel>
    </div>
  );
}

// ─── EQUIPMENT TAB ────────────────────────────────────────────────────────────
function EquipmentTab({ onModal }: { onModal: (p: ModalPayload) => void }) {
  const [selectedSlot, setSelectedSlot] = useState<string | null>(null);
  const getItem = (id: string | null) => id ? INVENTORY.find(i => i.id === id) ?? null : null;
  return (
    <div className="flex-1 overflow-y-auto px-2 py-2" style={{ scrollbarWidth: "none" }}>
      <SectionPanel>
        <SectionTitle action={<HeroPillBtn label="Forge" color="#ffd700"/>}>HERO EQUIPMENT</SectionTitle>
        <p style={{ fontSize: 8, color: "#5a4080", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, letterSpacing: "0.05em", marginBottom: 8 }}>EQUIPPED GEAR</p>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 5, marginBottom: 14 }}>
          {GEAR_SLOTS.map(slot => {
            const item = getItem(slot.item); const rc = item ? RARITY_COLOR[item.rarity] : "#2a1845"; const isSelected = selectedSlot === slot.id;
            return item ? (
              <button key={slot.id} onClick={() => { setSelectedSlot(slot.id); onModal({ type: "item", data: item }); }} className="relative flex flex-col items-center justify-center gap-0.5 py-1.5" style={{ background: isSelected ? "#12093299" : "#0a0720", border: `1px solid ${isSelected ? rc + "88" : rc + "33"}`, clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)", filter: isSelected ? `drop-shadow(0 0 5px ${rc}33)` : undefined }}>
                <div style={{ width: 2, height: "60%", position: "absolute", left: 0, top: "20%", background: rc, opacity: 0.7 }}/>
                <span style={{ fontSize: 16 }}>{item.icon}</span>
                <span style={{ fontSize: 7, color: "#a090c0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, letterSpacing: "0.02em" }}>{item.name.split(" ")[0]}</span>
                <span style={{ fontSize: 6.5, color: rc, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700 }}>Lv.{item.level}</span>
              </button>
            ) : (
              <button key={slot.id} onClick={() => setSelectedSlot(null)} className="flex flex-col items-center justify-center gap-0.5 py-2" style={{ background: "#070518", border: "1px solid #1e143344", clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)" }}>
                <div style={{ width: 18, height: 18, borderRadius: "50%", background: "#120930", border: "1px solid #2a184544" }}/>
                <span style={{ fontSize: 7, color: "#2a1845", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, textTransform: "capitalize" }}>{slot.label}</span>
              </button>
            );
          })}
        </div>
        <p style={{ fontSize: 8, color: "#5a4080", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, letterSpacing: "0.05em", marginBottom: 8 }}>EQUIPMENT COLLECTION</p>
        <div className="flex flex-col gap-2">{INVENTORY.map(item => <ItemTile key={item.id} item={item} selected={false} onClick={() => onModal({ type: "item", data: item })}/>)}</div>
      </SectionPanel>
    </div>
  );
}

// ─── CARDS TAB ────────────────────────────────────────────────────────────────
function CardsTab({ onModal }: { onModal: (p: ModalPayload) => void }) {
  const [selectedCard, setSelectedCard] = useState<string | null>("ember_signet");
  return (
    <div className="flex-1 overflow-y-auto px-2 py-2" style={{ scrollbarWidth: "none" }}>
      <SectionPanel>
        <SectionTitle>EQUIPMENT CARDS</SectionTitle>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 5 }}>
          {INVENTORY.map(item => {
            const rc = RARITY_COLOR[item.rarity]; const isSelected = selectedCard === item.id;
            return (
              <button key={item.id} onClick={() => { setSelectedCard(item.id); onModal({ type: "item", data: item }); }} className="relative flex flex-col items-center justify-center gap-1 py-2.5 px-1" style={{ background: isSelected ? "#12093299" : "#0a0720", border: `1px solid ${isSelected ? rc + "99" : rc + "33"}`, clipPath: "polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)", filter: isSelected ? `drop-shadow(0 0 8px ${rc}44)` : undefined, transition: "all 0.15s" }}>
                {isSelected && <div style={{ position: "absolute", top: 0, left: 8, right: 8, height: 1, background: `linear-gradient(90deg,transparent,${rc}88,transparent)` }}/>}
                <div style={{ position: "absolute", left: 0, top: 8, bottom: 8, width: 2, background: rc, borderRadius: 1, opacity: 0.8 }}/>
                <div className="relative flex items-center justify-center" style={{ width: 34, height: 34 }}>
                  <svg viewBox="0 0 34 34" className="absolute inset-0 w-full h-full"><polygon points="8,1 26,1 33,8 33,26 26,33 8,33 1,26 1,8" fill={isSelected ? "#120932" : "#0d0825"} stroke={rc} strokeWidth="0.9" opacity={isSelected ? 1 : 0.5}/></svg>
                  <span className="relative" style={{ fontSize: 16 }}>{item.icon}</span>
                </div>
                <span style={{ fontSize: 8, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: isSelected ? "#c8b8e8" : "#5a4080", letterSpacing: "0.02em", textAlign: "center", lineHeight: 1.3 }}>{item.name.split(" ").slice(0, 2).join(" ")}</span>
                <span style={{ fontSize: 7.5, color: rc, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700 }}>Lv.{item.level}</span>
              </button>
            );
          })}
        </div>
      </SectionPanel>
    </div>
  );
}

// ─── PETS TAB ─────────────────────────────────────────────────────────────────
function PetsTab() {
  return (
    <div className="flex-1 flex flex-col items-center justify-center px-4 gap-3">
      <div style={{ fontSize: 48, filter: "drop-shadow(0 0 14px #aa44ff66)" }}>🐾</div>
      <p style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 12, color: "#5a4080", letterSpacing: "0.08em", textAlign: "center" }}>NO PETS BONDED</p>
      <p style={{ fontSize: 9.5, color: "#3a2858", fontFamily: "'Rajdhani',sans-serif", fontWeight: 500, textAlign: "center", lineHeight: 1.6 }}>Capture or summon a companion in battle to bond a pet to your hero.</p>
      <HeroPillBtn label="Visit Stables" color="#aa44ff"/>
    </div>
  );
}

// ─── HEROES SCREEN ────────────────────────────────────────────────────────────
const HERO_TABS: { id: HeroTab; label: string; icon: React.ReactNode }[] = [
  { id: "class", label: "Class", icon: <Users size={13} strokeWidth={1.8}/> },
  { id: "skills", label: "Skills", icon: <Zap size={13} strokeWidth={1.8}/> },
  { id: "talents", label: "Talents", icon: <Star size={13} strokeWidth={1.8}/> },
  { id: "equipment", label: "Equipment", icon: <Shield size={13} strokeWidth={1.8}/> },
  { id: "cards", label: "Cards", icon: <BookOpen size={13} strokeWidth={1.8}/> },
  { id: "pets", label: "Pets", icon: <PawPrint size={13} strokeWidth={1.8}/> },
];
function HeroesScreen({ onBack }: { onBack: () => void }) {
  const [heroTab, setHeroTab] = useState<HeroTab>("class");
  const [modal, setModal] = useState<ModalPayload | null>(null);
  return (
    <div className="absolute inset-0 flex flex-col" style={{ background: "#06040f" }}>
      {/* Header */}
      <div className="relative z-30 flex items-center gap-2 px-3 flex-shrink-0" style={{ height: 66 }}>
        <div className="absolute inset-0" style={{ background: "linear-gradient(180deg,#0d0825 0%,#08041a 100%)", borderBottom: "1px solid #2a184555" }}>
          <svg className="absolute inset-0 w-full h-full pointer-events-none" viewBox="0 0 390 66" preserveAspectRatio="none">
            <polyline points="0,16 0,1 16,1" fill="none" stroke="#d4a017" strokeWidth="1.1" opacity="0.45"/>
            <polyline points="374,1 390,1 390,16" fill="none" stroke="#d4a017" strokeWidth="1.1" opacity="0.45"/>
            <polyline points="0,50 0,65 16,65" fill="none" stroke="#d4a017" strokeWidth="1.1" opacity="0.45"/>
            <polyline points="374,65 390,65 390,50" fill="none" stroke="#d4a017" strokeWidth="1.1" opacity="0.45"/>
          </svg>
        </div>
        <div className="relative flex-shrink-0" style={{ width: 46, height: 46 }}>
          <svg viewBox="0 0 46 46" className="absolute inset-0 w-full h-full">
            <defs><linearGradient id="hh-ring" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor="#ffe066"/><stop offset="100%" stopColor="#8b6200"/></linearGradient></defs>
            <polygon points="12,1 34,1 45,12 45,34 34,45 12,45 1,34 1,12" fill="#180d38" stroke="url(#hh-ring)" strokeWidth="1.3"/>
          </svg>
          <div className="absolute inset-0 flex items-center justify-center" style={{ fontSize: 22 }}>🌿</div>
        </div>
        <div className="relative flex-1 flex flex-col justify-center">
          <span style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 15, color: "#ffd700", letterSpacing: "0.07em", lineHeight: 1 }}>FERN</span>
          <span style={{ fontSize: 8.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 600, color: "#6050a0", lineHeight: 1.5 }}>Lv.12 · HP 154/158 · Power 808</span>
          <span style={{ fontSize: 8, fontFamily: "'Cinzel',serif", fontWeight: 600, color: "#22dd6e", letterSpacing: "0.04em" }}>Druid</span>
        </div>
        <div className="relative flex flex-col items-end gap-1.5 flex-shrink-0">
          <div className="flex items-center gap-1 px-2" style={{ height: 22, background: "#0a0720", border: "1px solid #3d206077", clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)" }}>
            <span style={{ fontSize: 8, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#c8a0e0" }}>Hero 1</span>
            <ChevronDown size={9} style={{ color: "#6050a0" }}/>
          </div>
          <button onClick={onBack} className="flex items-center justify-center px-3" style={{ height: 22, background: "#0a0820", border: "1px solid #3d206077", clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)" }}>
            <span style={{ fontSize: 8.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#7060a0", letterSpacing: "0.05em" }}>Back</span>
          </button>
        </div>
      </div>
      {/* Content */}
      <div className="flex-1 flex flex-col overflow-hidden relative">
        {heroTab === "class"     && <ClassTab/>}
        {heroTab === "skills"    && <SkillsTab/>}
        {heroTab === "talents"   && <TalentsTab onModal={setModal}/>}
        {heroTab === "equipment" && <EquipmentTab onModal={setModal}/>}
        {heroTab === "cards"     && <CardsTab onModal={setModal}/>}
        {heroTab === "pets"      && <PetsTab/>}
        {modal && <ItemModal payload={modal} onClose={() => setModal(null)}/>}
      </div>
      {/* Tab bar */}
      <div className="relative flex-shrink-0" style={{ height: 54 }}>
        <div className="absolute inset-0" style={{ background: "linear-gradient(0deg,#07040f 0%,#0d0825 100%)", borderTop: "1px solid #2a184555" }}/>
        <div className="absolute top-0 left-0 right-0 flex pointer-events-none">
          {HERO_TABS.map(t => <div key={t.id} className="flex-1" style={{ height: 1.5, background: heroTab === t.id ? "linear-gradient(90deg,transparent,#00e5c8,transparent)" : "transparent", boxShadow: heroTab === t.id ? "0 0 8px #00e5c8" : undefined, transition: "background 0.2s" }}/>)}
        </div>
        <div className="relative flex" style={{ height: 54 }}>
          {HERO_TABS.map(t => (
            <button key={t.id} onClick={() => setHeroTab(t.id)} className="flex-1 flex flex-col items-center justify-center gap-px select-none">
              <div style={{ color: heroTab === t.id ? "#00e5c8" : "#3d2060", filter: heroTab === t.id ? "drop-shadow(0 0 4px #00e5c888)" : undefined, transition: "color 0.2s" }}>{t.icon}</div>
              <span style={{ fontSize: 7.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: heroTab === t.id ? "#a0f8e8" : "#3a2858", letterSpacing: "0.06em", textTransform: "uppercase", transition: "color 0.2s" }}>{t.label}</span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── DUNGEON ORNATE FRAME ─────────────────────────────────────────────────────
function DungeonFrameLayout({ title, rightAction, children, subtitle }: {
  title: string; rightAction?: React.ReactNode; children: React.ReactNode; subtitle?: string;
}) {
  return (
    <div className="absolute inset-0 flex flex-col" style={{ background: "linear-gradient(180deg,#04021a 0%,#08042e 50%,#04021a 100%)" }}>
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse 70% 50% at 50% 45%, #1a086644 0%, transparent 70%)", pointerEvents: "none" }}/>
      <div style={{ position: "absolute", left: 14, top: 0, bottom: 0, width: 1, background: "linear-gradient(180deg,transparent 0%,#00bcd433 10%,#00bcd455 50%,#00bcd433 90%,transparent 100%)" }}/>
      <div style={{ position: "absolute", right: 14, top: 0, bottom: 0, width: 1, background: "linear-gradient(180deg,transparent 0%,#00bcd433 10%,#00bcd455 50%,#00bcd433 90%,transparent 100%)" }}/>

      {/* Top ornament */}
      <div style={{ height: 54, flexShrink: 0, position: "relative" }}>
        <svg viewBox="0 0 390 54" className="absolute inset-0 w-full h-full" preserveAspectRatio="none">
          <polygon points="195,2 203,14 195,26 187,14" fill="#3311aa" stroke="#00e5c8" strokeWidth="1.2" opacity="0.9"/>
          <polygon points="195,6 201,14 195,22 189,14" fill="#6633cc" opacity="0.7"/>
          <ellipse cx="195" cy="14" rx="28" ry="12" fill="#2200aa" opacity="0.15"/>
          <path d="M 187 14 Q 155 14 130 24 Q 90 34 50 32 Q 28 31 14 32" fill="none" stroke="#00bcd4" strokeWidth="1.4" opacity="0.5" strokeLinecap="round"/>
          <path d="M 187 14 Q 158 18 132 30 Q 92 40 52 38 Q 28 37 14 38" fill="none" stroke="#4422aa" strokeWidth="0.8" opacity="0.3" strokeLinecap="round"/>
          <path d="M 203 14 Q 235 14 260 24 Q 300 34 340 32 Q 362 31 376 32" fill="none" stroke="#00bcd4" strokeWidth="1.4" opacity="0.5" strokeLinecap="round"/>
          <path d="M 203 14 Q 232 18 258 30 Q 298 40 338 38 Q 362 37 376 38" fill="none" stroke="#4422aa" strokeWidth="0.8" opacity="0.3" strokeLinecap="round"/>
          <circle cx="14" cy="32" r="3" fill="#00bcd4" opacity="0.35"/>
          <circle cx="376" cy="32" r="3" fill="#00bcd4" opacity="0.35"/>
          <circle cx="55" cy="33" r="1.5" fill="#4422aa" opacity="0.5"/>
          <circle cx="335" cy="33" r="1.5" fill="#4422aa" opacity="0.5"/>
        </svg>
      </div>

      {/* Header bar */}
      <div className="relative flex items-center px-4 flex-shrink-0" style={{ height: 42, background: "#0a062899", borderTop: "1px solid #2a18aa33", borderBottom: "1px solid #2a18aa33" }}>
        <div style={{ width: 3, height: 22, background: "linear-gradient(180deg,#00e5c8,#4422aa)", borderRadius: 2, marginRight: 10 }}/>
        <div className="flex flex-col flex-1">
          <span style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 15, color: "#d0c0f0", letterSpacing: "0.07em", textShadow: "0 0 16px #6633dd44", lineHeight: 1 }}>{title}</span>
          {subtitle && <span style={{ fontSize: 9, color: "#5a4888", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600, letterSpacing: "0.04em", marginTop: 1 }}>{subtitle}</span>}
        </div>
        {rightAction}
      </div>

      {/* Scrollable content */}
      <div className="flex-1 overflow-y-auto relative" style={{ scrollbarWidth: "none" }}>
        {children}
      </div>

      {/* Bottom ornament */}
      <div style={{ height: 38, flexShrink: 0, position: "relative" }}>
        <svg viewBox="0 0 390 38" className="absolute inset-0 w-full h-full" preserveAspectRatio="none">
          <path d="M 14 10 Q 80 10 140 20 Q 188 26 195 30 Q 202 26 250 20 Q 310 10 376 10" fill="none" stroke="#00bcd4" strokeWidth="1.2" opacity="0.4" strokeLinecap="round"/>
          <path d="M 14 14 Q 80 14 140 24 Q 188 30 195 34 Q 202 30 250 24 Q 310 14 376 14" fill="none" stroke="#4422aa" strokeWidth="0.7" opacity="0.25" strokeLinecap="round"/>
          <polygon points="195,12 202,24 195,36 188,24" fill="#3311aa" stroke="#00e5c8" strokeWidth="1" opacity="0.85"/>
          <polygon points="195,16 200,24 195,32 190,24" fill="#6633cc" opacity="0.65"/>
          <circle cx="14" cy="10" r="2" fill="#00bcd4" opacity="0.3"/>
          <circle cx="376" cy="10" r="2" fill="#00bcd4" opacity="0.3"/>
          <polyline points="0,0 14,0 14,38" fill="none" stroke="#4422aa" strokeWidth="0.8" opacity="0.35"/>
          <polyline points="390,0 376,0 376,38" fill="none" stroke="#4422aa" strokeWidth="0.8" opacity="0.35"/>
        </svg>
      </div>
    </div>
  );
}

function DungeonPillBtn({ label, onClick, color = "#6050a0" }: { label: string; onClick: () => void; color?: string }) {
  return (
    <button onClick={onClick} style={{ height: 28, padding: "0 14px", background: "#08061a", border: `1px solid ${color}55`, clipPath: "polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)" }}>
      <span style={{ fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, fontSize: 10.5, color, letterSpacing: "0.06em" }}>{label}</span>
    </button>
  );
}

// ─── BATTLE LOBBY ─────────────────────────────────────────────────────────────
function BattleLobby({ onDungeons, onHome }: { onDungeons: () => void; onHome: () => void }) {
  return (
    <DungeonFrameLayout title="BATTLE" subtitle="Choose a battle mode." rightAction={<DungeonPillBtn label="Home" onClick={onHome}/>}>
      <div style={{ padding: "20px 16px 0 16px" }}>
        <button onClick={onDungeons} className="w-full flex items-center gap-4 text-left" style={{
          padding: "14px 16px",
          background: "linear-gradient(135deg,#18093688,#0c041e88)",
          border: "1px solid #3a1a9944",
          borderLeft: "3px solid #00e5c8",
          clipPath: "polygon(0 0,100% 0,100% calc(100% - 10px),calc(100% - 10px) 100%,0 100%)",
          filter: "drop-shadow(0 4px 16px #2211aa22)",
        }}>
          <div className="relative flex-shrink-0 flex items-center justify-center" style={{ width: 50, height: 50 }}>
            <svg viewBox="0 0 50 50" className="absolute inset-0 w-full h-full">
              <defs><linearGradient id="dl-gold" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor="#ffe066"/><stop offset="100%" stopColor="#7a5000"/></linearGradient></defs>
              <polygon points="13,1 37,1 49,13 49,37 37,49 13,49 1,37 1,13" fill="#0d0530" stroke="url(#dl-gold)" strokeWidth="1.2"/>
              <polygon points="17,5 33,5 45,17 45,33 33,45 17,45 5,33 5,17" fill="none" stroke="#00e5c833" strokeWidth="0.7"/>
            </svg>
            <span style={{ position: "relative", fontSize: 24 }}>🗝️</span>
          </div>
          <div className="flex flex-col">
            <span style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 16, color: "#d0c0f0", letterSpacing: "0.04em", lineHeight: 1 }}>Dungeons</span>
            <span style={{ fontSize: 10.5, color: "#5a4888", fontFamily: "'Rajdhani',sans-serif", fontWeight: 500, marginTop: 4, letterSpacing: "0.03em" }}>Fixed Encounters · Daily Rewards</span>
          </div>
          <ChevronRight size={22} style={{ color: "#3a1a99", marginLeft: "auto", flexShrink: 0 }}/>
        </button>
      </div>
    </DungeonFrameLayout>
  );
}

// ─── DUNGEON LIST ─────────────────────────────────────────────────────────────
function DungeonList({ onClose, onEnter }: { onClose: () => void; onEnter: (d: Dungeon) => void }) {
  return (
    <DungeonFrameLayout title="DUNGEONS" rightAction={<DungeonPillBtn label="Close" onClick={onClose}/>}>
      <div style={{ padding: "14px 14px 0 14px", display: "flex", flexDirection: "column", gap: 12 }}>
        {DUNGEONS.map(d => (
          <div key={d.id} style={{ background: "linear-gradient(135deg,#14073488,#0c021a88)", border: "1px solid #2a149944", overflow: "hidden", clipPath: "polygon(0 0,100% 0,100% calc(100% - 8px),calc(100% - 8px) 100%,0 100%)" }}>
            <div style={{ height: 2, background: `linear-gradient(90deg,transparent,${d.color}88,${d.color},${d.color}88,transparent)` }}/>
            <div style={{ padding: "10px 14px 0 14px" }}>
              <div className="flex items-start gap-3 mb-2">
                <div className="relative flex-shrink-0 flex items-center justify-center" style={{ width: 36, height: 36 }}>
                  <svg viewBox="0 0 36 36" className="absolute inset-0 w-full h-full">
                    <polygon points="9,1 27,1 35,9 35,27 27,35 9,35 1,27 1,9" fill="#0d0525" stroke={d.color} strokeWidth="0.9" opacity="0.65"/>
                  </svg>
                  <span style={{ position: "relative", fontSize: 18 }}>{d.icon}</span>
                </div>
                <div className="flex-1">
                  <div style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 11.5, color: "#d0c0f0", letterSpacing: "0.04em", lineHeight: 1, marginBottom: 4 }}>{d.name}</div>
                  <div style={{ fontSize: 9.5, color: "#5a4888", fontFamily: "'Rajdhani',sans-serif", fontWeight: 500, lineHeight: 1.4 }}>{d.desc}</div>
                </div>
              </div>
              <div className="flex items-center justify-between" style={{ marginBottom: 10 }}>
                <span style={{ fontSize: 9, color: "#4a3870", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600 }}>Reward: <span style={{ color: d.color }}>{d.reward}</span></span>
                <span style={{ fontSize: 9, color: "#4a3870", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600 }}>Attempts: {d.attempts}/{d.maxAttempts}</span>
              </div>
            </div>
            <button onClick={() => onEnter(d)} style={{
              display: "block", width: "100%", height: 34,
              background: "linear-gradient(90deg,#004455,#00bcd4,#004455)",
              border: "none", borderTop: "1px solid #00bcd444", cursor: "pointer",
              fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 11,
              color: "#001a22", letterSpacing: "0.1em",
            }}>ENTER</button>
          </div>
        ))}
      </div>
    </DungeonFrameLayout>
  );
}

// ─── DUNGEON SELECTED ─────────────────────────────────────────────────────────
function DungeonSelected({ dungeon, level, setLevel, onBack, onChallenge }: {
  dungeon: Dungeon; level: number; setLevel: (l: number) => void;
  onBack: () => void; onChallenge: () => void;
}) {
  return (
    <DungeonFrameLayout title={dungeon.name.toUpperCase()} subtitle="Enemy & Boss Preview">
      <div className="flex flex-col items-center px-8 pt-6 gap-5">
        <div className="relative flex items-center justify-center" style={{ width: 64, height: 64 }}>
          <svg viewBox="0 0 64 64" className="absolute inset-0 w-full h-full">
            <defs><linearGradient id="ds-gold" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor="#ffe066"/><stop offset="50%" stopColor="#7a5000"/><stop offset="100%" stopColor="#ffd700"/></linearGradient></defs>
            <polygon points="16,1 48,1 63,16 63,48 48,63 16,63 1,48 1,16" fill="#0d0525" stroke="url(#ds-gold)" strokeWidth="1.5"/>
            <polygon points="22,7 42,7 57,22 57,42 42,57 22,57 7,42 7,22" fill="none" stroke={dungeon.color} strokeWidth="0.8" opacity="0.35"/>
          </svg>
          <span style={{ position: "relative", fontSize: 32, filter: `drop-shadow(0 0 10px ${dungeon.color}88)` }}>{dungeon.icon}</span>
        </div>

        <div className="flex items-center gap-6">
          <button onClick={() => setLevel(Math.max(1, level - 1))} className="flex items-center justify-center" style={{ width: 32, height: 32, background: "#0d0528", border: "1px solid #2a189944", clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
            <span style={{ fontSize: 16, color: level > 1 ? "#8066c0" : "#2a1845" }}>◄</span>
          </button>
          <span style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 20, color: "#d0c0f0", letterSpacing: "0.05em", minWidth: 80, textAlign: "center" }}>Level {level}</span>
          <button onClick={() => setLevel(Math.min(dungeon.maxLevels, level + 1))} className="flex items-center justify-center" style={{ width: 32, height: 32, background: "#0d0528", border: "1px solid #2a189944", clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
            <span style={{ fontSize: 16, color: level < dungeon.maxLevels ? "#8066c0" : "#2a1845" }}>►</span>
          </button>
        </div>

        <div className="w-full" style={{ background: "#0a062888", border: "1px solid #2a18aa33", padding: "16px 20px" }}>
          {[
            { label: "Attempts Remaining", value: `${dungeon.attempts} / ${dungeon.maxAttempts}` },
            { label: "Recommended Power", value: `${dungeon.power * level}` },
            { label: "Rewards", value: dungeon.rewardDesc },
          ].map((row, i) => (
            <div key={i} className="flex items-center justify-between" style={{ marginBottom: i < 2 ? 10 : 0 }}>
              <span style={{ fontSize: 10.5, color: "#5a4888", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600 }}>{row.label}</span>
              <span style={{ fontSize: 10.5, color: "#c0b0e0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700 }}>{row.value}</span>
            </div>
          ))}
        </div>

        <button onClick={onChallenge} className="w-full flex items-center justify-center" style={{
          height: 46,
          background: "linear-gradient(90deg,#2a0a6a,#5533cc,#2a0a6a)",
          border: "1px solid #8855ff99",
          clipPath: "polygon(10px 0%,100% 0%,calc(100% - 10px) 100%,0% 100%)",
          filter: "drop-shadow(0 0 12px #4422aa55)",
        }}>
          <span style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 14, color: "#e0d0ff", letterSpacing: "0.1em" }}>CHALLENGE</span>
        </button>

        <button onClick={onBack} className="w-full flex items-center justify-center" style={{
          height: 38,
          background: "#080520",
          border: "1px solid #2a18aa33",
          clipPath: "polygon(10px 0%,100% 0%,calc(100% - 10px) 100%,0% 100%)",
        }}>
          <span style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 12, color: "#5040a0", letterSpacing: "0.08em" }}>BACK</span>
        </button>
      </div>
    </DungeonFrameLayout>
  );
}

// ─── DUNGEON BATTLE ───────────────────────────────────────────────────────────
function DungeonBattle({ dungeon, level, onLeave }: { dungeon: Dungeon; level: number; onLeave: () => void }) {
  const [autoMode, setAutoMode] = useState(true);
  const [phase, setPhase] = useState(1);
  const [enemyHp, setEnemyHp] = useState(100);
  const [victory, setVictory] = useState(false);

  useEffect(() => {
    if (!autoMode || victory) return;
    const t = setInterval(() => setEnemyHp(hp => Math.max(0, hp - 8)), 280);
    return () => clearInterval(t);
  }, [autoMode, victory]);

  useEffect(() => {
    if (enemyHp <= 0 && !victory) {
      if (phase < 5) {
        const t = setTimeout(() => { setPhase(p => p + 1); setEnemyHp(100); }, 600);
        return () => clearTimeout(t);
      } else {
        const t = setTimeout(() => setVictory(true), 600);
        return () => clearTimeout(t);
      }
    }
  }, [enemyHp, phase, victory]);

  return (
    <div className="absolute inset-0 flex flex-col" style={{ background: "#06040f" }}>
      <div className="relative flex flex-col items-center pt-2.5 pb-1.5 flex-shrink-0 z-20" style={{ background: "linear-gradient(180deg,#0c082299 0%,transparent 100%)" }}>
        <span style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 13, color: "#d0c0f0", letterSpacing: "0.05em", textShadow: "0 0 12px #6633dd44" }}>
          {dungeon.name} · Level {level}
        </span>
        <div className="flex items-center gap-2 mt-0.5">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} style={{ width: 22, height: 4, background: i < phase ? dungeon.color : "#1a0a3a", border: `1px solid ${i < phase ? dungeon.color + "88" : "#2a1845"}`, borderRadius: 2, transition: "background 0.3s" }}/>
          ))}
          <span style={{ fontSize: 9, color: "#6050a0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600, marginLeft: 2 }}>Phase {phase}/5</span>
        </div>
        <div style={{ position: "absolute", right: 12, top: 10 }}>
          <span style={{ fontSize: 9, color: "#c0b0e0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, background: "#0a062888", padding: "2px 8px", border: "1px solid #2a189933" }}>
            {victory ? "CLEAR!" : "1 Enemy"}
          </span>
        </div>
      </div>

      <div className="relative flex-1 overflow-hidden">
        <ForestBackground/>
        <div style={{ position: "absolute", inset: 0, background: "linear-gradient(180deg,#11005522 0%,transparent 40%)", pointerEvents: "none" }}/>
        <StoneGround/>

        <div className="absolute" style={{ bottom: 58, left: 20 }}>
          <div style={{ fontSize: 50, lineHeight: 1, filter: "drop-shadow(0 0 16px #a060ff66) drop-shadow(2px 6px 8px #00000099)" }}>🧝</div>
          <div style={{ marginTop: 4, width: 52, height: 4, background: "#0a0820", border: "1px solid #2a184555" }}>
            <div style={{ height: "100%", width: "44%", background: "#22dd6e", boxShadow: "0 0 4px #22dd6e66" }}/>
          </div>
        </div>

        {!victory && (
          <div className="absolute" style={{ bottom: 60, right: 16 }}>
            <div style={{ padding: "4px 10px", background: "#1a050599", border: "1.5px solid #ff663388", marginBottom: 4, clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
              <span style={{ fontSize: 8.5, fontFamily: "'Cinzel',serif", fontWeight: 700, color: "#ff9966", letterSpacing: "0.04em" }}>{dungeon.enemy}</span>
            </div>
            <div style={{ fontSize: 44, lineHeight: 1, filter: "drop-shadow(0 0 12px #ff440044)", textAlign: "center" }}>{dungeon.enemyIcon}</div>
            <div style={{ width: "100%", height: 4, background: "#0a0820", border: "1px solid #2a184555", marginTop: 4, marginBottom: 2 }}>
              <div style={{ height: "100%", width: `${enemyHp}%`, background: "#ff4444", boxShadow: "0 0 4px #ff444466", transition: "width 0.2s" }}/>
            </div>
            <span style={{ fontSize: 7.5, color: "#ff7755", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700 }}>{enemyHp}/100</span>
          </div>
        )}

        {victory && (
          <div className="absolute inset-0 flex items-center justify-center z-10">
            <div style={{ textAlign: "center", background: "#0d082299", border: "1px solid #ffd70066", padding: "20px 32px", clipPath: "polygon(10px 0%,100% 0%,calc(100% - 10px) 100%,0% 100%)" }}>
              <div style={{ fontSize: 36, marginBottom: 8 }}>✨</div>
              <p style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 15, color: "#ffd700", letterSpacing: "0.08em", marginBottom: 6 }}>DUNGEON CLEAR!</p>
              <p style={{ fontSize: 10, color: "#8066c0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600, marginBottom: 12 }}>Rewards: {dungeon.rewardDesc}</p>
              <button onClick={onLeave} style={{ height: 34, padding: "0 24px", background: "linear-gradient(90deg,#2a0a6a,#5533cc,#2a0a6a)", border: "1px solid #8855ff99", clipPath: "polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)", fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 11, color: "#e0d0ff", letterSpacing: "0.08em" }}>COLLECT</button>
            </div>
          </div>
        )}

        {!victory && (
          <button onClick={onLeave} style={{ position: "absolute", bottom: 10, right: 16, height: 28, padding: "0 14px", background: "#0a0820aa", border: "1px solid #2a184566", clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)" }}>
            <span style={{ fontSize: 9.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#6050a0", letterSpacing: "0.05em" }}>Leave</span>
          </button>
        )}
      </div>

      <div className="flex-shrink-0 z-20" style={{ background: "linear-gradient(0deg,#060210 0%,#0e0a28 100%)", padding: "6px 8px" }}>
        <div className="flex items-center" style={{ gap: 5 }}>
          <AutoBtn active={autoMode} onToggle={() => setAutoMode(p => !p)}/>
          <div style={{ width: 1, height: 40, background: "linear-gradient(0deg,transparent,#3d2060,transparent)", flexShrink: 0 }}/>
          <div className="flex items-center flex-1 justify-center" style={{ gap: 4 }}>
            {[<FireRune key="f"/>, <IceRune key="i"/>, <WindRune key="w"/>].map((icon, i) => <SkillBtn key={i} idx={100 + i} icon={icon} locked={false}/>)}
            <SkillBtn idx={103} locked={true} levelReq={40}/>
            <SkillBtn idx={104} locked={true} levelReq={55}/>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── LEAVE MODAL ──────────────────────────────────────────────────────────────
function DungeonLeaveModal({ onLeave, onCancel }: { onLeave: () => void; onCancel: () => void }) {
  return (
    <div className="absolute inset-0 z-50 flex items-center justify-center" style={{ background: "#00000077" }}>
      <div style={{ width: 290, position: "relative" }}>
        <div style={{ position: "absolute", top: -16, left: "50%", transform: "translateX(-50%)", zIndex: 1 }}>
          <svg viewBox="0 0 32 32" width="32" height="32">
            <polygon points="16,1 24,12 16,23 8,12" fill="#3311aa" stroke="#00e5c8" strokeWidth="1.3"/>
            <polygon points="16,5 22,12 16,19 10,12" fill="#6633dd" opacity="0.75"/>
            <circle cx="16" cy="12" r="3" fill="#00e5c8" opacity="0.5"/>
          </svg>
        </div>

        <div style={{ background: "linear-gradient(180deg,#0e0a2a 0%,#070420 100%)", border: "1px solid #4422aa66", boxShadow: "0 0 32px #2211aa33" }}>
          {(["tl","tr","bl","br"] as const).map(c => (
            <svg key={c} className="absolute" style={{ width: 16, height: 16, top: c.startsWith("t") ? 0 : undefined, bottom: c.startsWith("b") ? 0 : undefined, left: c.endsWith("l") ? 0 : undefined, right: c.endsWith("r") ? 0 : undefined }} viewBox="0 0 16 16">
              {c === "tl" && <polyline points="0,12 0,0 12,0" fill="none" stroke="#4422aa" strokeWidth="1.2" opacity="0.7"/>}
              {c === "tr" && <polyline points="4,0 16,0 16,12" fill="none" stroke="#4422aa" strokeWidth="1.2" opacity="0.7"/>}
              {c === "bl" && <polyline points="0,4 0,16 12,16" fill="none" stroke="#4422aa" strokeWidth="1.2" opacity="0.7"/>}
              {c === "br" && <polyline points="4,16 16,16 16,4" fill="none" stroke="#4422aa" strokeWidth="1.2" opacity="0.7"/>}
            </svg>
          ))}

          <div style={{ padding: "24px 22px 20px 22px", textAlign: "center" }}>
            <div style={{ height: 1, background: "linear-gradient(90deg,transparent,#4422aa88,transparent)", marginBottom: 16 }}/>
            <h2 style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 15, color: "#d0c0f0", letterSpacing: "0.05em", marginBottom: 10 }}>Leave Dungeon?</h2>
            <p style={{ fontSize: 10, color: "#5a4888", fontFamily: "'Rajdhani',sans-serif", fontWeight: 500, lineHeight: 1.65, marginBottom: 20 }}>
              This attempt has already been used. Leave without claiming rewards?
            </p>
            <div className="flex gap-3">
              {[
                { label: "Leave", onClick: onLeave, glow: true },
                { label: "Cancel", onClick: onCancel, glow: false },
              ].map(btn => (
                <button key={btn.label} onClick={btn.onClick} className="flex-1 flex items-center justify-center" style={{
                  height: 38,
                  background: btn.glow ? "linear-gradient(90deg,#2a0a6a,#5533cc,#2a0a6a)" : "#0d0828",
                  border: `1px solid ${btn.glow ? "#8855ff88" : "#4422aa44"}`,
                  clipPath: "polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)",
                  filter: btn.glow ? "drop-shadow(0 0 8px #4422aa44)" : undefined,
                }}>
                  <span style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 12, color: btn.glow ? "#e0d0ff" : "#5040a0", letterSpacing: "0.07em" }}>{btn.label}</span>
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── DUNGEON SCREEN (orchestrator) ────────────────────────────────────────────
function DungeonScreen({ onClose }: { onClose: () => void }) {
  const [view, setView] = useState<"list" | "selected" | "battle">("list");
  const [selectedDungeon, setSelectedDungeon] = useState<Dungeon | null>(null);
  const [dungeonLevel, setDungeonLevel] = useState(1);
  const [showLeave, setShowLeave] = useState(false);

  return (
    <div className="absolute inset-0">
      {view === "list" && (
        <DungeonList onClose={onClose} onEnter={d => { setSelectedDungeon(d); setDungeonLevel(1); setView("selected"); }}/>
      )}
      {view === "selected" && selectedDungeon && (
        <DungeonSelected dungeon={selectedDungeon} level={dungeonLevel} setLevel={setDungeonLevel}
          onBack={() => setView("list")} onChallenge={() => setView("battle")}/>
      )}
      {view === "battle" && selectedDungeon && (
        <DungeonBattle dungeon={selectedDungeon} level={dungeonLevel} onLeave={() => setShowLeave(true)}/>
      )}
      {showLeave && (
        <DungeonLeaveModal
          onLeave={() => { setShowLeave(false); setView("list"); }}
          onCancel={() => setShowLeave(false)}/>
      )}
    </div>
  );
}

// ─── GUILD DATA ───────────────────────────────────────────────────────────────
const GUILD_MEMBERS_DATA = [
  { id: 1, name: "Enki",         position: "Member", weeklyActivity: 147, status: "online",  avatar: "🧝" },
  { id: 2, name: "ovi",          position: "Leader", weeklyActivity: 820, status: "1w ago",  avatar: "🧙" },
  { id: 3, name: "Kasuma",       position: "Member", weeklyActivity: 310, status: "2mo ago", avatar: "🗡️" },
  { id: 4, name: "Joseplay12",   position: "Member", weeklyActivity:   0, status: "2mo ago", avatar: "🏹" },
  { id: 5, name: "Darkon",       position: "Member", weeklyActivity:   0, status: "3mo ago", avatar: "🛡️" },
  { id: 6, name: "Pimpolho",     position: "Member", weeklyActivity:   0, status: "3mo ago", avatar: "🌿" },
  { id: 7, name: "Shadowwolfz5", position: "Member", weeklyActivity:   0, status: "3mo ago", avatar: "💀" },
  { id: 8, name: "MEG",          position: "Member", weeklyActivity:   0, status: "3mo ago", avatar: "🌸" },
];
const GUILD_SHOP_DATA = [
  { id: "awaken",  name: "Awakening Scroll",  icon: "📜", price: 4000,  color: "#ffd700" },
  { id: "enhance", name: "Enhancement Gear",  icon: "⚙️", price: 4000,  color: "#448aff" },
  { id: "summon",  name: "Summoning Essence", icon: "✨", price: 10000, color: "#aa44ff" },
  { id: "soul",    name: "Soul Crystal",      icon: "💎", price: 10000, color: "#00e5c8" },
];
const GUILD_SCHEDULE_DATA = [
  { id: "treasure", name: "Family Treasure Hunt",     type: "Daily", time: "19:00", status: "available"   as const, icon: "🗺️" },
  { id: "abyssal",  name: "Cross the Abyssal Portal", type: "Daily", time: "19:00", status: "coming_soon" as const, icon: "🌀" },
];
const GUILD_RESEARCH_DATA = [
  { id: "atk",  name: "Battle Mastery",  desc: "Increases all members ATK by 1% per level.",      level: 3, max: 10, color: "#ff7733", icon: "⚔️" },
  { id: "hp",   name: "Vitality Ward",   desc: "Increases all members Max HP by 1.5% per level.", level: 5, max: 10, color: "#22dd6e", icon: "💚" },
  { id: "def",  name: "Iron Bastion",    desc: "Reduces damage taken by 0.5% per level.",          level: 2, max: 10, color: "#448aff", icon: "🛡️" },
  { id: "spd",  name: "Swift Pursuit",   desc: "Increases Move Speed by 1% per level.",            level: 1, max: 10, color: "#ffd700", icon: "⚡" },
];
type GuildModal = "hall" | "boss" | "shop" | "academy" | "schedule" | null;
type GuildHallTab = "hall" | "members" | "donation";

function GuildBackground() {
  return (
    <svg viewBox="0 0 390 580" className="absolute inset-0 w-full h-full" preserveAspectRatio="xMidYMid slice" style={{ pointerEvents: "none" }}>
      <defs>
        <linearGradient id="gsky" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" stopColor="#030110"/><stop offset="55%" stopColor="#0b0422"/><stop offset="100%" stopColor="#130828"/>
        </linearGradient>
        <radialGradient id="gamb" cx="50%" cy="25%" r="55%">
          <stop offset="0%" stopColor="#3311aa" stopOpacity="0.22"/><stop offset="100%" stopColor="transparent" stopOpacity="0"/>
        </radialGradient>
        <radialGradient id="gtorch" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stopColor="#ff8800" stopOpacity="0.38"/><stop offset="100%" stopColor="transparent" stopOpacity="0"/>
        </radialGradient>
        <pattern id="gfloor" x="0" y="0" width="48" height="22" patternUnits="userSpaceOnUse">
          <rect x="1" y="1" width="45" height="19" fill="#0d0828" stroke="#221855" strokeWidth="0.7" rx="1"/>
        </pattern>
      </defs>
      <rect width="390" height="580" fill="url(#gsky)"/>
      <ellipse cx="195" cy="120" rx="200" ry="130" fill="url(#gamb)"/>
      <rect x="0" y="90" width="64" height="380" fill="#09061c"/>
      <rect x="0" y="78" width="64" height="15" fill="#0c0825"/>
      {[0,1,2].map(i => <rect key={"lb"+i} x={i*22} y="64" width="15" height="17" fill="#0c0825" rx="1"/>)}
      <line x1="64" y1="78" x2="64" y2="470" stroke="#251855" strokeWidth="1"/>
      {[110,132,154,176,198,220,242,264,286,308,330].map((y,i) => <line key={"ls"+i} x1="0" y1={y} x2="64" y2={y} stroke="#14103a" strokeWidth="0.7" opacity="0.5"/>)}
      <rect x="326" y="90" width="64" height="380" fill="#09061c"/>
      <rect x="326" y="78" width="64" height="15" fill="#0c0825"/>
      {[0,1,2].map(i => <rect key={"rb"+i} x={326+i*22} y="64" width="15" height="17" fill="#0c0825" rx="1"/>)}
      <line x1="326" y1="78" x2="326" y2="470" stroke="#251855" strokeWidth="1"/>
      {[110,132,154,176,198,220,242,264,286,308,330].map((y,i) => <line key={"rs"+i} x1="326" y1={y} x2="390" y2={y} stroke="#14103a" strokeWidth="0.7" opacity="0.5"/>)}
      <ellipse cx="56" cy="220" rx="44" ry="44" fill="url(#gtorch)"/>
      <rect x="51" y="214" width="10" height="18" fill="#5a3010" rx="2"/>
      <ellipse cx="56" cy="212" rx="6" ry="8" fill="#ff9922"/>
      <ellipse cx="56" cy="208" rx="3.5" ry="6" fill="#ffee44" opacity="0.8"/>
      <ellipse cx="334" cy="220" rx="44" ry="44" fill="url(#gtorch)"/>
      <rect x="329" y="214" width="10" height="18" fill="#5a3010" rx="2"/>
      <ellipse cx="334" cy="212" rx="6" ry="8" fill="#ff9922"/>
      <ellipse cx="334" cy="208" rx="3.5" ry="6" fill="#ffee44" opacity="0.8"/>
      <line x1="30" y1="95" x2="30" y2="150" stroke="#5a3800" strokeWidth="2.5"/>
      <path d="M 30 95 L 52 102 L 30 120 L 8 102 Z" fill="#00bcd4" opacity="0.8"/>
      <line x1="360" y1="95" x2="360" y2="150" stroke="#5a3800" strokeWidth="2.5"/>
      <path d="M 360 95 L 382 102 L 360 120 L 338 102 Z" fill="#00bcd4" opacity="0.8"/>
      {[[35,22],[92,12],[145,28],[195,8],[260,18],[315,28],[358,14],[72,50],[178,42],[298,46]].map(([x,y],i) =>
        <circle key={"st"+i} cx={x} cy={y} r={i%4===0?1.2:0.7} fill="#fff" opacity={0.2+i%3*0.1}/>
      )}
      <rect x="0" y="450" width="390" height="130" fill="#080520"/>
      <line x1="0" y1="450" x2="390" y2="450" stroke="#3322cc" strokeWidth="1.5" opacity="0.3"/>
      <rect x="0" y="452" width="390" height="80" fill="url(#gfloor)"/>
    </svg>
  );
}

function GuildEmblem({ size = 64 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      <defs>
        <radialGradient id="gem-inner" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stopColor="#1e0a44"/><stop offset="100%" stopColor="#06030f"/>
        </radialGradient>
      </defs>
      <circle cx="32" cy="32" r="30" stroke="#ffd700" strokeWidth="1.8" fill="url(#gem-inner)"/>
      <circle cx="32" cy="32" r="23" stroke="#00bcd4" strokeWidth="0.9" fill="none" opacity="0.6"/>
      {[[32,48,32,55],[43,43,49,49],[48,32,55,32],[43,21,49,15],[32,16,32,9],[21,21,15,15],[16,32,9,32],[21,43,15,49]].map(([x1,y1,x2,y2],i) =>
        <line key={i} x1={x1} y1={y1} x2={x2} y2={y2} stroke="#ffd700" strokeWidth="0.8" opacity="0.35"/>
      )}
      <path d="M32 14 C38 17 41 22 40 28 C39 34 36 37 32 38 C28 37 25 34 24 28 C23 22 26 17 32 14Z" fill="#cc2200" opacity="0.9"/>
      <path d="M24 26 C18 21 13 23 15 30" fill="none" stroke="#aa1100" strokeWidth="3.5" strokeLinecap="round"/>
      <path d="M40 26 C46 21 51 23 49 30" fill="none" stroke="#aa1100" strokeWidth="3.5" strokeLinecap="round"/>
      <path d="M30 38 C29 44 30 49 32 51 C34 49 35 44 34 38" fill="#aa1100" opacity="0.7"/>
      <circle cx="29" cy="22" r="2.2" fill="#ff6600"/>
      <circle cx="35" cy="22" r="2.2" fill="#ff6600"/>
      <circle cx="29" cy="22" r="0.9" fill="#fff" opacity="0.8"/>
      <circle cx="35" cy="22" r="0.9" fill="#fff" opacity="0.8"/>
      <polygon points="32,2 34.5,6 32,4.5 29.5,6" fill="#ffd700"/>
      <polygon points="32,62 34.5,58 32,59.5 29.5,58" fill="#ffd700"/>
      <polygon points="2,32 6,29.5 4.5,32 6,34.5" fill="#ffd700"/>
      <polygon points="62,32 58,29.5 59.5,32 58,34.5" fill="#ffd700"/>
    </svg>
  );
}

function GuildHallCard({ onClick }: { onClick: () => void }) {
  return (
    <button onClick={onClick} className="relative w-full" style={{ height: 190 }}>
      <div className="absolute inset-0" style={{ background: "linear-gradient(180deg,#0e0830 0%,#09051e 65%,#120830 100%)", border: "1px solid #3d206088" }}/>
      {(["tl","tr","bl","br"] as const).map(c => (
        <svg key={c} className="absolute" style={{ width: 18, height: 18, top: c[0]==="t"?0:undefined, bottom: c[0]==="b"?0:undefined, left: c[1]==="l"?0:undefined, right: c[1]==="r"?0:undefined }} viewBox="0 0 18 18">
          {c==="tl"&&<polyline points="0,14 0,0 14,0" fill="none" stroke="#ffd700" strokeWidth="1.5" opacity="0.75"/>}
          {c==="tr"&&<polyline points="4,0 18,0 18,14" fill="none" stroke="#ffd700" strokeWidth="1.5" opacity="0.75"/>}
          {c==="bl"&&<polyline points="0,4 0,18 14,18" fill="none" stroke="#ffd700" strokeWidth="1.5" opacity="0.75"/>}
          {c==="br"&&<polyline points="4,18 18,18 18,4" fill="none" stroke="#ffd700" strokeWidth="1.5" opacity="0.75"/>}
        </svg>
      ))}
      <svg className="absolute inset-0 w-full h-full" viewBox="0 0 358 190" preserveAspectRatio="none">
        <defs>
          <linearGradient id="arch-teal" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#00bcd4" stopOpacity="0.15"/>
            <stop offset="50%" stopColor="#00e5c8" stopOpacity="0.8"/>
            <stop offset="100%" stopColor="#00bcd4" stopOpacity="0.15"/>
          </linearGradient>
          <radialGradient id="gh-amb" cx="50%" cy="42%" r="45%">
            <stop offset="0%" stopColor="#4422aa" stopOpacity="0.25"/><stop offset="100%" stopColor="transparent" stopOpacity="0"/>
          </radialGradient>
        </defs>
        <ellipse cx="179" cy="88" rx="140" ry="100" fill="url(#gh-amb)"/>
        <rect x="18" y="24" width="28" height="148" fill="#100838" stroke="#3d2060" strokeWidth="0.8"/>
        <rect x="18" y="17" width="28" height="10" fill="#180a42"/>
        <rect x="312" y="24" width="28" height="148" fill="#100838" stroke="#3d2060" strokeWidth="0.8"/>
        <rect x="312" y="17" width="28" height="10" fill="#180a42"/>
        <path d="M 46 62 Q 179 8 312 62" fill="none" stroke="url(#arch-teal)" strokeWidth="2.8"/>
        <path d="M 46 62 Q 179 8 312 62" fill="none" stroke="#00e5c8" strokeWidth="12" opacity="0.06"/>
        <path d="M 54 68 Q 179 18 304 68" fill="none" stroke="#00bcd4" strokeWidth="0.9" opacity="0.3"/>
        <line x1="46" y1="62" x2="18" y2="82" stroke="#ffd700" strokeWidth="1" opacity="0.4"/>
        <circle cx="18" cy="82" r="3" fill="#ffd700" opacity="0.5"/>
        <line x1="312" y1="62" x2="340" y2="82" stroke="#ffd700" strokeWidth="1" opacity="0.4"/>
        <circle cx="340" cy="82" r="3" fill="#ffd700" opacity="0.5"/>
        <polygon points="179,6 184,14 179,11 174,14" fill="#ffd700" opacity="0.9"/>
        <line x1="38" y1="160" x2="320" y2="160" stroke="#2a1855" strokeWidth="0.8" opacity="0.7"/>
      </svg>
      <div className="absolute flex items-center justify-center" style={{ top: 24, left: 0, right: 0 }}>
        <div style={{ filter: "drop-shadow(0 0 14px #cc220044)" }}><GuildEmblem size={78}/></div>
      </div>
      <div className="absolute flex flex-col items-center gap-0.5" style={{ bottom: 12, left: 0, right: 0 }}>
        <span style={{ fontFamily: "'Cinzel',serif", fontWeight: 700, fontSize: 16, color: "#ffd700", letterSpacing: "0.09em", textShadow: "0 0 14px #ffd70044" }}>IRON PACT</span>
        <div className="flex items-center gap-3">
          <span style={{ fontSize: 9, color: "#7060a0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600 }}>Members 72/90</span>
          <div style={{ width: 1, height: 9, background: "#3d2060" }}/>
          <span style={{ fontSize: 9, color: "#7060a0", fontFamily: "'Rajdhani',sans-serif", fontWeight: 600 }}>Level 10</span>
          <div style={{ width: 1, height: 9, background: "#3d2060" }}/>
          <span style={{ fontSize: 9, color: "#00e5c8", fontFamily: "'Rajdhani',sans-serif", fontWeight: 700 }}>View Details ▸</span>
        </div>
      </div>
    </button>
  );
}

function GuildAreaTile({ icon, label, subtitle, color, badge, onClick }: {
  icon: string; label: string; subtitle: string; color: string; badge?: string; onClick: () => void;
}) {
  return (
    <button onClick={onClick} className="relative flex flex-col items-center justify-center gap-2" style={{
      height: 108,
      background: `linear-gradient(160deg,${color}10 0%,${color}05 100%)`,
      border: `1px solid ${color}44`,
      clipPath: "polygon(8px 0%,100% 0%,calc(100% - 8px) 100%,0% 100%)",
      filter: `drop-shadow(0 2px 8px ${color}18)`,
    }}>
      <div style={{ position:"absolute", top:0, left:10, right:10, height:1.5, background:`linear-gradient(90deg,transparent,${color}88,transparent)` }}/>
      <div style={{ position:"absolute", left:0, top:14, bottom:14, width:2, background:color, borderRadius:1, opacity:0.7 }}/>
      {badge && (
        <div style={{ position:"absolute", top:6, right:8, height:16, padding:"0 6px", background:`${color}22`, border:`1px solid ${color}66`, clipPath:"polygon(3px 0%,100% 0%,calc(100% - 3px) 100%,0% 100%)" }}>
          <span style={{ fontSize:7.5, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color }}>{badge}</span>
        </div>
      )}
      <div className="relative flex items-center justify-center" style={{ width:44, height:44 }}>
        <svg viewBox="0 0 44 44" className="absolute inset-0 w-full h-full">
          <polygon points="11,1 33,1 43,11 43,33 33,43 11,43 1,33 1,11" fill="#0d0825" stroke={color} strokeWidth="1.2" opacity="0.75"/>
          <polygon points="15,5 29,5 39,15 39,29 29,39 15,39 5,29 5,15" fill="none" stroke={color} strokeWidth="0.5" opacity="0.28"/>
        </svg>
        <span style={{ position:"relative", fontSize:22, filter:`drop-shadow(0 0 6px ${color}66)` }}>{icon}</span>
      </div>
      <div className="flex flex-col items-center">
        <span style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:10.5, color:"#d0c0f0", letterSpacing:"0.04em", lineHeight:1 }}>{label}</span>
        <span style={{ fontSize:8.5, color, fontFamily:"'Rajdhani',sans-serif", fontWeight:600, marginTop:2 }}>{subtitle}</span>
      </div>
    </button>
  );
}

function GuildDetailsContent() {
  return (
    <div className="flex flex-col items-center px-4 py-4 gap-4">
      <div style={{ filter:"drop-shadow(0 0 16px #cc220033)" }}><GuildEmblem size={76}/></div>
      <div className="text-center">
        <h2 style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:18, color:"#ffd700", letterSpacing:"0.07em" }}>IRON PACT</h2>
        <div className="flex items-center justify-center gap-4 mt-1.5">
          <span style={{ fontSize:9.5, color:"#6050a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:600 }}>Members 72/90</span>
          <div style={{ width:1, height:10, background:"#3d2060" }}/>
          <span style={{ fontSize:9.5, color:"#6050a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:600 }}>Lv.10</span>
        </div>
      </div>
      <div className="w-full" style={{ background:"#0a082088", border:"1px solid #2a184544", padding:"12px 14px" }}>
        {[{ label:"Guild EXP", value:4500, max:6000, color:"#00e5c8" },{ label:"Guild Funds", value:38000, max:100000, color:"#ffd700" }].map(s => (
          <div key={s.label} style={{ marginBottom: s.label==="Guild EXP"?10:0 }}>
            <div className="flex justify-between items-center mb-1">
              <span style={{ fontSize:8.5, color:"#6050a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:600 }}>{s.label}</span>
              <span style={{ fontSize:8.5, color:s.color, fontFamily:"'Rajdhani',sans-serif", fontWeight:700 }}>{s.value.toLocaleString()}/{s.max.toLocaleString()}</span>
            </div>
            <div style={{ height:5, background:"#120930", border:`1px solid ${s.color}22`, clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
              <div style={{ height:"100%", width:`${(s.value/s.max)*100}%`, background:`linear-gradient(90deg,${s.color}55,${s.color})`, boxShadow:`0 0 4px ${s.color}66` }}/>
            </div>
          </div>
        ))}
      </div>
      <div className="w-full" style={{ background:"#08061888", border:"1px solid #3d206044", padding:"12px 14px" }}>
        <p style={{ fontSize:8.5, fontFamily:"'Cinzel',serif", fontWeight:700, color:"#d4a017", letterSpacing:"0.06em", marginBottom:8 }}>ANNOUNCEMENT</p>
        <p style={{ fontSize:10, color:"#7060a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:500, lineHeight:1.65 }}>chicos no se olviden de donar al clan cada reset y entrar al teatro magico</p>
      </div>
      <div className="flex gap-3 w-full">
        {["Family List","Family Log"].map((label,i) => (
          <button key={label} className="flex-1 flex items-center justify-center" style={{ height:38, background: i===0?"linear-gradient(90deg,#0a1535,#0d1a40,#0a1535)":"#0a0820", border:`1px solid ${i===0?"#00e5c8":"#3d206066"}`, clipPath:"polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)", filter:i===0?"drop-shadow(0 0 5px #00e5c822)":undefined }}>
            <span style={{ fontSize:9.5, fontFamily:"'Cinzel',serif", fontWeight:700, color:i===0?"#00e5c8":"#4a3870", letterSpacing:"0.05em" }}>{label.toUpperCase()}</span>
          </button>
        ))}
      </div>
    </div>
  );
}

function GuildMembersContent() {
  return (
    <div className="flex flex-col">
      <div className="flex items-center px-3 py-2 flex-shrink-0 sticky top-0" style={{ background:"#0a0820", borderBottom:"1px solid #2a184555" }}>
        <span className="flex-1" style={{ fontSize:8.5, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:"#4a3870", letterSpacing:"0.04em" }}>Name</span>
        <span style={{ fontSize:8.5, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:"#4a3870", width:68, textAlign:"center" }}>Weekly Act.</span>
        <span style={{ fontSize:8.5, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:"#4a3870", width:58, textAlign:"right" }}>Position</span>
      </div>
      {GUILD_MEMBERS_DATA.map((m,i) => (
        <div key={m.id} className="flex items-center px-3 py-2" style={{ background:i%2===0?"#0a0720":"#090618", borderBottom:"1px solid #1e143333" }}>
          <div className="relative flex-shrink-0 flex items-center justify-center" style={{ width:32, height:32, marginRight:8 }}>
            <svg viewBox="0 0 32 32" className="absolute inset-0 w-full h-full"><rect x="1" y="1" width="30" height="30" fill="#0d0825" stroke={m.position==="Leader"?"#ffd700":"#3d2060"} strokeWidth={m.position==="Leader"?1.5:0.8}/></svg>
            <span style={{ position:"relative", fontSize:15 }}>{m.avatar}</span>
          </div>
          <div className="flex-1 flex flex-col overflow-hidden">
            <span style={{ fontSize:10, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:m.status==="online"?"#00e5c8":"#c8b8e8", overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap" }}>{m.name}</span>
            <span style={{ fontSize:7.5, color:m.status==="online"?"#22dd6e":"#3a2858", fontFamily:"'Rajdhani',sans-serif", fontWeight:600 }}>{m.status==="online"?"Online":m.status}</span>
          </div>
          <span style={{ width:68, textAlign:"center", fontSize:10, color:"#6050a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:700 }}>{m.weeklyActivity}</span>
          <span style={{ width:58, textAlign:"right", fontSize:9, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:m.position==="Leader"?"#ffd700":"#5a4080" }}>{m.position}</span>
        </div>
      ))}
    </div>
  );
}

function GuildDonationContent() {
  const [donated, setDonated] = useState(false);
  const items = ["🐠","🦋",null];
  return (
    <div className="flex flex-col items-center px-4 py-6 gap-5">
      <p style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:14, color:"#d4a017", letterSpacing:"0.06em" }}>Donation</p>
      <div className="flex gap-4">
        {items.map((item,i) => (
          <div key={i} className="relative flex items-center justify-center" style={{ width:64, height:64, background:"#0a0720", border:`1px solid ${item?"#3d2060":"#1e1440"}`, clipPath:"polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)" }}>
            {item ? <span style={{ fontSize:28 }}>{item}</span> : <div style={{ width:22, height:22, borderRadius:"50%", background:"#120930", border:"1px solid #2a1845" }}/>}
            {item && <div style={{ position:"absolute", bottom:2, left:0, right:0, textAlign:"center" }}><span style={{ fontSize:7, color:"#6050a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:700 }}>Lv.{i+1}</span></div>}
          </div>
        ))}
      </div>
      <button onClick={() => setDonated(true)} style={{ height:42, padding:"0 32px", background: donated?"#0a0820":"linear-gradient(90deg,#0a2035,#0d3040,#0a2035)", border:`1px solid ${donated?"#3d206055":"#00e5c8"}`, clipPath:"polygon(8px 0%,100% 0%,calc(100% - 8px) 100%,0% 100%)", filter:donated?undefined:"drop-shadow(0 0 8px #00e5c833)" }}>
        <span style={{ fontSize:12, fontFamily:"'Cinzel',serif", fontWeight:700, color:donated?"#3a2858":"#00e5c8", letterSpacing:"0.1em" }}>{donated?"DONATED":"FREE"}</span>
      </button>
      <span style={{ fontSize:9.5, color:"#5a4080", fontFamily:"'Rajdhani',sans-serif", fontWeight:600 }}>Remaining attempts today: 5</span>
    </div>
  );
}

function GuildHallModal({ onClose }: { onClose: () => void }) {
  const [tab, setTab] = useState<GuildHallTab>("hall");
  const tabs: { id: GuildHallTab; label: string }[] = [
    { id:"hall", label:"Family Hall" },{ id:"members", label:"Members" },{ id:"donation", label:"Donation" },
  ];
  return (
    <div className="absolute inset-0 z-50 flex flex-col" style={{ background:"#06040f" }}>
      <div className="relative flex items-center justify-center flex-shrink-0" style={{ height:56 }}>
        <svg className="absolute inset-0 w-full h-full pointer-events-none" viewBox="0 0 390 56" preserveAspectRatio="none">
          <defs><linearGradient id="gmod-hdr" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stopColor="#1a0a3a"/><stop offset="50%" stopColor="#2a1060"/><stop offset="100%" stopColor="#1a0a3a"/></linearGradient></defs>
          <rect width="390" height="56" fill="url(#gmod-hdr)"/>
          <path d="M 40 56 Q 195 30 350 56" fill="none" stroke="#ffd700" strokeWidth="1.2" opacity="0.45"/>
          <path d="M 20 56 Q 195 22 370 56" fill="none" stroke="#ffd700" strokeWidth="0.5" opacity="0.2"/>
          <polygon points="195,26 200,34 195,31 190,34" fill="#ffd700" opacity="0.8"/>
        </svg>
        <span style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:15, color:"#ffd700", letterSpacing:"0.07em", textShadow:"0 0 14px #ffd70033" }}>Family Details</span>
        <button onClick={onClose} className="absolute right-3 top-1/2 -translate-y-1/2 flex items-center justify-center" style={{ width:28, height:24, background:"#1e1040", border:"1px solid #3d206066", clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
          <X size={12} style={{ color:"#7060a0" }}/>
        </button>
      </div>
      <div className="flex-1 overflow-y-auto" style={{ scrollbarWidth:"none" }}>
        {tab === "hall"     && <GuildDetailsContent/>}
        {tab === "members"  && <GuildMembersContent/>}
        {tab === "donation" && <GuildDonationContent/>}
      </div>
      <div className="relative flex flex-shrink-0" style={{ height:52, borderTop:"1px solid #2a184555", background:"linear-gradient(0deg,#07040f,#0d0825)" }}>
        <div className="absolute top-0 left-0 right-0 flex pointer-events-none">
          {tabs.map(t => <div key={t.id} className="flex-1" style={{ height:1.5, background:tab===t.id?"linear-gradient(90deg,transparent,#ffd700,transparent)":undefined }}/>)}
        </div>
        {tabs.map(t => (
          <button key={t.id} onClick={() => setTab(t.id)} className="flex-1 flex flex-col items-center justify-center gap-0.5">
            <span style={{ fontSize:9, fontFamily:"'Cinzel',serif", fontWeight:700, color:tab===t.id?"#ffd700":"#3a2858", letterSpacing:"0.05em", textTransform:"uppercase" }}>{t.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}

function GuildBossModal({ onClose }: { onClose: () => void }) {
  return (
    <div className="absolute inset-0 z-50 flex flex-col" style={{ background:"linear-gradient(180deg,#110208 0%,#180510 60%,#0e0210 100%)" }}>
      <div className="relative flex items-center px-4 flex-shrink-0" style={{ height:56, background:"#0e0210", borderBottom:"1px solid #ff440033" }}>
        <div style={{ width:3, height:22, background:"linear-gradient(180deg,#ff4422,#aa1100)", borderRadius:2, marginRight:10 }}/>
        <span style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:14, color:"#ff9966", letterSpacing:"0.05em", flex:1 }}>GUILD BOSS</span>
        <button onClick={onClose} className="flex items-center justify-center" style={{ width:28, height:24, background:"#180510", border:"1px solid #ff440033", clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}><X size={12} style={{ color:"#ff7755" }}/></button>
      </div>
      <div className="flex items-center justify-center py-2.5" style={{ background:"#ff440010", borderBottom:"1px solid #ff440022" }}>
        <span style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:13, color:"#ff9966", letterSpacing:"0.04em" }}>Conquer the Lava Behemoth</span>
      </div>
      <div className="flex-1 flex flex-col items-center justify-center gap-3" style={{ padding:"0 24px" }}>
        <div className="relative flex items-center justify-center" style={{ width:110, height:120 }}>
          <span style={{ fontSize:80, lineHeight:1, filter:"drop-shadow(0 0 24px #ff440077) drop-shadow(0 0 48px #aa110044)" }}>🌋</span>
          <span style={{ position:"absolute", bottom:4, left:"50%", transform:"translateX(-50%)", fontSize:38, filter:"drop-shadow(0 0 10px #ff660044)" }}>🔥</span>
        </div>
        <div className="w-full">
          <div className="flex justify-between items-center mb-1">
            <span style={{ fontSize:9, color:"#ff9966", fontFamily:"'Rajdhani',sans-serif", fontWeight:700 }}>BOSS HP</span>
            <span style={{ fontSize:9, color:"#ff6644", fontFamily:"'Rajdhani',sans-serif", fontWeight:700 }}>1,240,000 / 2,000,000</span>
          </div>
          <div style={{ height:8, background:"#0e0210", border:"1px solid #ff440033", clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
            <div style={{ height:"100%", width:"62%", background:"linear-gradient(90deg,#aa1100,#ff4400)", boxShadow:"0 0 6px #ff440077" }}/>
          </div>
        </div>
        <div className="w-full" style={{ background:"#0e021088", border:"1px solid #ff440022", padding:"10px 14px" }}>
          <p style={{ fontSize:9, fontFamily:"'Cinzel',serif", color:"#d4a017", letterSpacing:"0.05em", marginBottom:8 }}>CONQUEST REWARDS</p>
          <p style={{ fontSize:8.5, color:"#5a4080", fontFamily:"'Rajdhani',sans-serif", fontWeight:600, marginBottom:8 }}>According to Boss Level</p>
          <div className="flex gap-4">
            {["💎 x120","📜 x3","⭐ x5"].map((r,i) => <span key={i} style={{ fontSize:10, color:"#c8b8e8", fontFamily:"'Rajdhani',sans-serif", fontWeight:700 }}>{r}</span>)}
          </div>
        </div>
        <span style={{ fontSize:8.5, color:"#4a3060", fontFamily:"'Rajdhani',sans-serif", fontWeight:600, textAlign:"center" }}>Sweep rewards based on highest DMG achieved</span>
      </div>
      <div className="flex gap-3 px-4 pb-6">
        <button className="flex-1 flex items-center justify-center" style={{ height:46, background:"#0e0210", border:"1px solid #ff440033", clipPath:"polygon(8px 0%,100% 0%,calc(100% - 8px) 100%,0% 100%)" }}>
          <span style={{ fontSize:12, fontFamily:"'Cinzel',serif", fontWeight:700, color:"#5a3040", letterSpacing:"0.08em" }}>SWEEP</span>
        </button>
        <button className="flex-1 flex items-center justify-center" style={{ height:46, background:"linear-gradient(90deg,#6a0a0a,#aa1100,#6a0a0a)", border:"1px solid #ff440066", clipPath:"polygon(8px 0%,100% 0%,calc(100% - 8px) 100%,0% 100%)", filter:"drop-shadow(0 0 10px #ff220033)" }}>
          <span style={{ fontSize:12, fontFamily:"'Cinzel',serif", fontWeight:700, color:"#ffaa88", letterSpacing:"0.08em" }}>CHALLENGE</span>
        </button>
      </div>
    </div>
  );
}

function GuildShopModal({ onClose }: { onClose: () => void }) {
  return (
    <div className="absolute inset-0 z-50 flex flex-col" style={{ background:"linear-gradient(180deg,#04020f 0%,#08031a 100%)" }}>
      <div className="relative flex items-center px-4 flex-shrink-0" style={{ height:56, background:"#06041488", borderBottom:"1px solid #ffd70022" }}>
        <div style={{ width:3, height:22, background:"linear-gradient(180deg,#ffd700,#8b6200)", borderRadius:2, marginRight:10 }}/>
        <div className="flex-1">
          <span style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:14, color:"#ffd700", letterSpacing:"0.05em" }}>GUILD SHOP</span>
          <div className="flex items-center gap-1 mt-0.5">
            <span style={{ fontSize:8.5, color:"#6050a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:600 }}>Guild Coins:</span>
            <span style={{ fontSize:9, color:"#ffd700", fontFamily:"'Rajdhani',sans-serif", fontWeight:700 }}>48,360</span>
          </div>
        </div>
        <button onClick={onClose} className="flex items-center justify-center" style={{ width:28, height:24, background:"#0a0820", border:"1px solid #ffd70033", clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}><X size={12} style={{ color:"#a08040" }}/></button>
      </div>
      <div className="flex items-center justify-center py-2" style={{ background:"#ffd70008", borderBottom:"1px solid #ffd70018" }}>
        <span style={{ fontSize:9, color:"#d4a017", fontFamily:"'Rajdhani',sans-serif", fontWeight:700, letterSpacing:"0.06em" }}>DAILY LIMIT - RESETS MIDNIGHT</span>
      </div>
      <div className="flex-1 overflow-y-auto px-3 py-3" style={{ scrollbarWidth:"none" }}>
        <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:10 }}>
          {GUILD_SHOP_DATA.map(item => (
            <div key={item.id} style={{ background:"#0a0720", border:`1px solid ${item.color}33`, clipPath:"polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)" }}>
              <div style={{ height:2, background:`linear-gradient(90deg,transparent,${item.color}66,transparent)` }}/>
              <div className="flex flex-col items-center gap-2 p-3">
                <div className="relative flex items-center justify-center" style={{ width:54, height:54 }}>
                  <svg viewBox="0 0 54 54" className="absolute inset-0 w-full h-full">
                    <polygon points="14,1 40,1 53,14 53,40 40,53 14,53 1,40 1,14" fill="#0d0825" stroke={item.color} strokeWidth="1.1" opacity="0.65"/>
                  </svg>
                  <span style={{ position:"relative", fontSize:26, filter:`drop-shadow(0 0 8px ${item.color}55)` }}>{item.icon}</span>
                </div>
                <span style={{ fontSize:10, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:"#c8b8e8", textAlign:"center", lineHeight:1.2 }}>{item.name}</span>
                <div className="flex items-center gap-1">
                  <span style={{ fontSize:12, color:item.color, fontFamily:"'Rajdhani',sans-serif", fontWeight:700 }}>🪙 {item.price.toLocaleString()}</span>
                </div>
                <button className="w-full flex items-center justify-center" style={{ height:32, background:`${item.color}11`, border:`1px solid ${item.color}66`, clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
                  <span style={{ fontSize:9.5, fontFamily:"'Cinzel',serif", fontWeight:700, color:item.color, letterSpacing:"0.06em" }}>PURCHASE</span>
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function GuildScheduleModal({ onClose }: { onClose: () => void }) {
  const [schedTab, setSchedTab] = useState<"daily"|"weekly">("daily");
  return (
    <div className="absolute inset-0 z-50 flex flex-col" style={{ background:"linear-gradient(180deg,#04020f 0%,#08031a 100%)" }}>
      <div className="relative flex items-center px-4 flex-shrink-0" style={{ height:56, background:"#06041488", borderBottom:"1px solid #aa44ff22" }}>
        <div style={{ width:3, height:22, background:"linear-gradient(180deg,#aa44ff,#4422aa)", borderRadius:2, marginRight:10 }}/>
        <span style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:14, color:"#c8a0ff", letterSpacing:"0.05em", flex:1 }}>EVENT SCHEDULE</span>
        <button onClick={onClose} className="flex items-center justify-center" style={{ width:28, height:24, background:"#0a0820", border:"1px solid #aa44ff33", clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}><X size={12} style={{ color:"#7050a0" }}/></button>
      </div>
      <div className="relative flex flex-shrink-0" style={{ height:38, background:"#08041a", borderBottom:"1px solid #2a184555" }}>
        {(["daily","weekly"] as const).map(t => (
          <button key={t} onClick={() => setSchedTab(t)} className="flex-1 flex items-center justify-center relative">
            <span style={{ fontSize:10, fontFamily:"'Cinzel',serif", fontWeight:700, color:schedTab===t?"#aa44ff":"#3a2858", letterSpacing:"0.05em" }}>{t.charAt(0).toUpperCase()+t.slice(1)}</span>
            {schedTab===t && <div style={{ position:"absolute", bottom:0, left:"25%", right:"25%", height:1.5, background:"linear-gradient(90deg,transparent,#aa44ff,transparent)" }}/>}
          </button>
        ))}
      </div>
      <div className="flex-1 overflow-y-auto px-3 py-3 flex flex-col gap-3" style={{ scrollbarWidth:"none" }}>
        {schedTab==="daily" ? GUILD_SCHEDULE_DATA.map(evt => (
          <div key={evt.id} style={{ background:"#0a0720", border:"1px solid #3d206044", clipPath:"polygon(0 0,100% 0,100% calc(100% - 6px),calc(100% - 6px) 100%,0 100%)" }}>
            <div style={{ height:2, background:`linear-gradient(90deg,transparent,${evt.status==="available"?"#22dd6e55":"#3d206044"},transparent)` }}/>
            <div className="flex items-center gap-3 px-4 py-3">
              <div className="relative flex-shrink-0 flex items-center justify-center" style={{ width:46, height:46 }}>
                <svg viewBox="0 0 46 46" className="absolute inset-0 w-full h-full"><polygon points="12,1 34,1 45,12 45,34 34,45 12,45 1,34 1,12" fill="#0d0825" stroke={evt.status==="available"?"#22dd6e":"#3d2060"} strokeWidth="0.9" opacity="0.65"/></svg>
                <span style={{ position:"relative", fontSize:22, filter:evt.status==="available"?"drop-shadow(0 0 6px #22dd6e44)":undefined }}>{evt.icon}</span>
              </div>
              <div className="flex-1">
                <span style={{ fontSize:11, fontFamily:"'Cinzel',serif", fontWeight:700, color:evt.status==="available"?"#d0c0f0":"#4a3870", letterSpacing:"0.03em", lineHeight:1, display:"block" }}>{evt.name}</span>
                <span style={{ fontSize:8.5, color:"#5a4080", fontFamily:"'Rajdhani',sans-serif", fontWeight:600, marginTop:2, display:"block" }}>{evt.type} {evt.status==="available"?evt.time:`Next: ${evt.time}`}</span>
              </div>
              {evt.status==="available" ? (
                <button className="flex items-center justify-center px-5 flex-shrink-0" style={{ height:34, background:"linear-gradient(90deg,#0a2a10,#0d3a18)", border:"1px solid #22dd6e55", clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
                  <span style={{ fontSize:11, fontFamily:"'Cinzel',serif", fontWeight:700, color:"#22dd6e", letterSpacing:"0.08em" }}>GO</span>
                </button>
              ) : (
                <div className="flex items-center justify-center px-3 flex-shrink-0" style={{ height:34, background:"#0a0720", border:"1px solid #2a184544" }}>
                  <span style={{ fontSize:8, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:"#3a2858" }}>Coming soon</span>
                </div>
              )}
            </div>
          </div>
        )) : (
          <div className="flex flex-col items-center justify-center py-10 gap-3">
            <span style={{ fontSize:38, filter:"drop-shadow(0 0 12px #aa44ff33)" }}>📅</span>
            <p style={{ fontSize:10, fontFamily:"'Cinzel',serif", fontWeight:700, color:"#3a2858", letterSpacing:"0.07em" }}>NO WEEKLY EVENTS</p>
            <p style={{ fontSize:9, color:"#2a1845", fontFamily:"'Rajdhani',sans-serif", fontWeight:500 }}>Check back each week for new events.</p>
          </div>
        )}
      </div>
    </div>
  );
}

function GuildAcademyModal({ onClose }: { onClose: () => void }) {
  return (
    <div className="absolute inset-0 z-50 flex flex-col" style={{ background:"linear-gradient(180deg,#04020f 0%,#08031a 100%)" }}>
      <div className="relative flex items-center px-4 flex-shrink-0" style={{ height:56, background:"#06041488", borderBottom:"1px solid #448aff22" }}>
        <div style={{ width:3, height:22, background:"linear-gradient(180deg,#88aaff,#1a3a88)", borderRadius:2, marginRight:10 }}/>
        <div className="flex-1">
          <span style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:14, color:"#88aaff", letterSpacing:"0.05em" }}>GUILD ACADEMY</span>
          <div className="mt-0.5"><span style={{ fontSize:8.5, color:"#5050a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:600 }}>Shared buffs for all members</span></div>
        </div>
        <button onClick={onClose} className="flex items-center justify-center" style={{ width:28, height:24, background:"#0a0820", border:"1px solid #448aff33", clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}><X size={12} style={{ color:"#5070a0" }}/></button>
      </div>
      <div className="flex-1 overflow-y-auto px-3 py-3 flex flex-col gap-3" style={{ scrollbarWidth:"none" }}>
        {GUILD_RESEARCH_DATA.map(r => (
          <div key={r.id} style={{ background:"#0a0720", border:`1px solid ${r.color}22`, clipPath:"polygon(6px 0%,100% 0%,calc(100% - 6px) 100%,0% 100%)" }}>
            <div style={{ height:2, background:`linear-gradient(90deg,transparent,${r.color}55,transparent)` }}/>
            <div className="flex items-center gap-3 px-3 py-3">
              <div className="relative flex-shrink-0 flex items-center justify-center" style={{ width:44, height:44 }}>
                <svg viewBox="0 0 44 44" className="absolute inset-0 w-full h-full"><polygon points="11,1 33,1 43,11 43,33 33,43 11,43 1,33 1,11" fill="#0d0825" stroke={r.color} strokeWidth="1.1" opacity="0.65"/></svg>
                <span style={{ position:"relative", fontSize:21, filter:`drop-shadow(0 0 6px ${r.color}44)` }}>{r.icon}</span>
              </div>
              <div className="flex-1">
                <div className="flex items-center justify-between mb-1">
                  <span style={{ fontSize:11, fontFamily:"'Cinzel',serif", fontWeight:700, color:"#d0c0f0", letterSpacing:"0.03em" }}>{r.name}</span>
                  <span style={{ fontSize:9, color:r.color, fontFamily:"'Rajdhani',sans-serif", fontWeight:700 }}>Lv.{r.level}/{r.max}</span>
                </div>
                <p style={{ fontSize:8.5, color:"#5a4080", fontFamily:"'Rajdhani',sans-serif", fontWeight:500, marginBottom:6, lineHeight:1.45 }}>{r.desc}</p>
                <div style={{ height:4, background:"#0a0820", border:`1px solid ${r.color}22`, clipPath:"polygon(3px 0%,100% 0%,calc(100% - 3px) 100%,0% 100%)" }}>
                  <div style={{ height:"100%", width:`${(r.level/r.max)*100}%`, background:`linear-gradient(90deg,${r.color}55,${r.color})`, boxShadow:`0 0 4px ${r.color}44` }}/>
                </div>
              </div>
              <button className="flex-shrink-0 flex items-center justify-center px-3 ml-2" style={{ height:38, background:`${r.color}11`, border:`1px solid ${r.color}55`, clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
                <span style={{ fontSize:9, fontFamily:"'Cinzel',serif", fontWeight:700, color:r.color, letterSpacing:"0.04em" }}>UPGRADE</span>
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function GuildScreen({ onBack }: { onBack: () => void }) {
  const [modal, setModal] = useState<GuildModal>(null);
  const areas = [
    { id:"boss"     as const, icon:"🔥", label:"Guild Boss",     subtitle:"Lava Behemoth",  color:"#ff4422", badge:"Active" },
    { id:"shop"     as const, icon:"🛒", label:"Guild Shop",     subtitle:"4 items listed", color:"#ffd700" },
    { id:"academy"  as const, icon:"📚", label:"Guild Academy",  subtitle:"4 researches",   color:"#448aff" },
    { id:"schedule" as const, icon:"📅", label:"Guild Schedule", subtitle:"2 events today", color:"#aa44ff" },
  ] as const;
  return (
    <div className="absolute inset-0 flex flex-col" style={{ background:"#06040f" }}>
      <div className="absolute inset-0"><GuildBackground/></div>
      <div className="relative z-30 flex items-center gap-2 px-3 flex-shrink-0" style={{ height:64 }}>
        <div className="absolute inset-0" style={{ background:"linear-gradient(180deg,#0d0825cc 0%,#08041acc 100%)", borderBottom:"1px solid #2a184555" }}>
          <svg className="absolute inset-0 w-full h-full pointer-events-none" viewBox="0 0 390 64" preserveAspectRatio="none">
            <polyline points="0,14 0,1 14,1" fill="none" stroke="#d4a017" strokeWidth="1.1" opacity="0.45"/>
            <polyline points="376,1 390,1 390,14" fill="none" stroke="#d4a017" strokeWidth="1.1" opacity="0.45"/>
            <polyline points="0,50 0,63 14,63" fill="none" stroke="#d4a017" strokeWidth="1.1" opacity="0.45"/>
            <polyline points="376,63 390,63 390,50" fill="none" stroke="#d4a017" strokeWidth="1.1" opacity="0.45"/>
          </svg>
        </div>
        <div className="relative flex-shrink-0"><GuildEmblem size={44}/></div>
        <div className="relative flex-1 flex flex-col justify-center">
          <span style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:15, color:"#ffd700", letterSpacing:"0.07em", lineHeight:1 }}>IRON PACT</span>
          <span style={{ fontSize:8.5, fontFamily:"'Rajdhani',sans-serif", fontWeight:600, color:"#6050a0", lineHeight:1.5 }}>Lv.10 · 72/90 Members</span>
        </div>
        <div className="relative flex flex-col items-end gap-1.5 flex-shrink-0">
          <div className="flex items-center gap-1 px-2" style={{ height:20, background:"#0a0720", border:"1px solid #ffd70033", clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
            <span style={{ fontSize:8, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:"#ffd700" }}>🪙 48,360</span>
          </div>
          <button onClick={onBack} className="flex items-center justify-center px-3" style={{ height:22, background:"#0a0820", border:"1px solid #3d206077", clipPath:"polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)" }}>
            <span style={{ fontSize:8.5, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:"#7060a0", letterSpacing:"0.05em" }}>Back</span>
          </button>
        </div>
      </div>
      <div className="relative z-10 flex-1 overflow-y-auto flex flex-col px-4 py-3 gap-3" style={{ scrollbarWidth:"none" }}>
        <GuildHallCard onClick={() => setModal("hall")}/>
        <div className="flex items-center gap-2">
          <div style={{ flex:1, height:1, background:"linear-gradient(90deg,transparent,#3d2060)" }}/>
          <span style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:8.5, color:"#4a3870", letterSpacing:"0.12em" }}>GUILD AREAS</span>
          <div style={{ flex:1, height:1, background:"linear-gradient(90deg,#3d2060,transparent)" }}/>
        </div>
        <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:10 }}>
          {areas.map(a => (
            <GuildAreaTile key={a.id} icon={a.icon} label={a.label} subtitle={a.subtitle} color={a.color} badge={"badge" in a ? a.badge : undefined} onClick={() => setModal(a.id)}/>
          ))}
        </div>
      </div>
      {modal === "hall"     && <GuildHallModal     onClose={() => setModal(null)}/>}
      {modal === "boss"     && <GuildBossModal     onClose={() => setModal(null)}/>}
      {modal === "shop"     && <GuildShopModal     onClose={() => setModal(null)}/>}
      {modal === "academy"  && <GuildAcademyModal  onClose={() => setModal(null)}/>}
      {modal === "schedule" && <GuildScheduleModal onClose={() => setModal(null)}/>}
    </div>
  );
}

// ─── BATTLE SHARED COMPONENTS ─────────────────────────────────────────────────
function SkillBtn({ icon, locked = false, idx, levelReq }: { icon?: React.ReactNode; locked?: boolean; idx: number; levelReq?: number }) {
  const [pressed, setPressed] = useState(false);
  const g = `sg${idx}`;
  return (
    <button onPointerDown={() => !locked && setPressed(true)} onPointerUp={() => setPressed(false)} onPointerLeave={() => setPressed(false)}
      className="relative flex items-center justify-center select-none flex-shrink-0"
      style={{ width: 50, height: 50, transform: pressed ? "scale(0.91)" : "scale(1)", transition: "transform 0.1s", filter: !locked ? "drop-shadow(0 0 5px #00e5c844)" : undefined }}>
      <svg viewBox="0 0 50 50" className="absolute inset-0 w-full h-full pointer-events-none">
        <defs>
          <linearGradient id={`${g}-gold`} x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor={locked ? "#3a2450" : "#ffe066"}/><stop offset="45%" stopColor={locked ? "#1e1030" : "#9a6400"}/><stop offset="100%" stopColor={locked ? "#3a2450" : "#ffd700"}/></linearGradient>
          <linearGradient id={`${g}-bg`} x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor={locked ? "#110820" : "#18204a"}/><stop offset="100%" stopColor={locked ? "#0a0515" : "#0d1535"}/></linearGradient>
          <linearGradient id={`${g}-shine`} x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stopColor="#ffffff" stopOpacity={locked ? "0.02" : "0.09"}/><stop offset="100%" stopColor="#ffffff" stopOpacity="0"/></linearGradient>
        </defs>
        <polygon points="13,1 37,1 49,13 49,37 37,49 13,49 1,37 1,13" fill={`url(#${g}-bg)`} stroke={`url(#${g}-gold)`} strokeWidth="1.5"/>
        <polygon points="13,1 37,1 49,13 49,37 37,49 13,49 1,37 1,13" fill={`url(#${g}-shine)`}/>
        <polygon points="17,6 33,6 44,17 44,33 33,44 17,44 6,33 6,17" fill="none" stroke={locked ? "#2a1845" : "#00e5c8"} strokeWidth="0.8" opacity={locked ? 0.2 : 0.45}/>
        {([[13,13],[37,13],[37,37],[13,37]] as [number,number][]).map(([cx,cy],i) => <circle key={i} cx={cx} cy={cy} r="2.2" fill={locked ? "#2a1845" : "#ffd700"} opacity={locked ? 0.2 : 0.9}/>)}
        {!locked && <line x1="13" y1="8" x2="20" y2="15" stroke="#fff" strokeWidth="0.8" opacity="0.22" strokeLinecap="round"/>}
      </svg>
      <div className="relative z-10 flex flex-col items-center justify-center gap-0.5">
        {locked ? <><Lock size={13} strokeWidth={2} style={{ color: "#3a2455" }}/>{levelReq && <span style={{ fontSize: 6.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#3a2455" }}>Lv.{levelReq}</span>}</>
          : <div style={{ color: "#00e5c8", filter: "drop-shadow(0 0 4px #00e5c8aa)" }}>{icon}</div>}
      </div>
    </button>
  );
}
function AutoBtn({ active, onToggle }: { active: boolean; onToggle: () => void }) {
  return (
    <button onClick={onToggle} className="relative flex flex-col items-center justify-center select-none flex-shrink-0"
      style={{ width: 44, height: 50, filter: active ? "drop-shadow(0 0 6px #00e58077)" : undefined, transition: "filter 0.25s" }}>
      <svg viewBox="0 0 44 50" className="absolute inset-0 w-full h-full pointer-events-none">
        <defs>
          <linearGradient id="auto-gold" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor="#ffe066"/><stop offset="50%" stopColor="#8b6200"/><stop offset="100%" stopColor="#ffd700"/></linearGradient>
          <linearGradient id="auto-bg" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stopColor={active ? "#0d2e1a" : "#14102e"}/><stop offset="100%" stopColor={active ? "#071510" : "#09070f"}/></linearGradient>
          <linearGradient id="auto-shine" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stopColor="#ffffff" stopOpacity="0.09"/><stop offset="100%" stopColor="#ffffff" stopOpacity="0"/></linearGradient>
        </defs>
        <polygon points="10,1 34,1 43,11 43,39 34,49 10,49 1,39 1,11" fill="url(#auto-bg)" stroke="url(#auto-gold)" strokeWidth="1.5"/>
        <polygon points="10,1 34,1 43,11 43,39 34,49 10,49 1,39 1,11" fill="url(#auto-shine)"/>
        <polygon points="14,5 30,5 39,15 39,35 30,45 14,45 5,35 5,15" fill="none" stroke={active ? "#00e580" : "#3d2060"} strokeWidth="0.7" opacity={active ? 0.55 : 0.3}/>
      </svg>
      <div className="relative z-10 flex flex-col items-center gap-0.5">
        <div style={{ color: active ? "#00e580" : "#5a4080" }}><AutoIcon/></div>
        <span style={{ fontSize: 7.5, fontFamily: "'Cinzel',serif", fontWeight: 700, color: active ? "#00e580" : "#5a4080", letterSpacing: "0.04em", lineHeight: 1 }}>AUTO</span>
      </div>
    </button>
  );
}
function StatBar({ value, max, color, label }: { value: number; max: number; color: string; label: string }) {
  const pct = Math.min(100, (value / max) * 100);
  return (
    <div className="flex items-center gap-1.5" style={{ marginBottom: 3 }}>
      <span style={{ fontSize: 8, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color, width: 14 }}>{label}</span>
      <div className="relative flex-1" style={{ height: 7 }}>
        <div className="absolute inset-0" style={{ background: "#06020f", border: "1px solid #2a1845", clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)" }}/>
        <div className="absolute inset-y-0 left-0" style={{ width: `${pct}%`, background: `linear-gradient(90deg,${color}44,${color})`, boxShadow: `0 0 6px ${color}66`, clipPath: "polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)", transition: "width 0.4s" }}/>
        <div style={{ position: "absolute", right: 2, top: "50%", transform: "translateY(-50%) rotate(45deg)", width: 3, height: 3, background: color, opacity: 0.8 }}/>
      </div>
      <span style={{ fontSize: 8, fontFamily: "'Rajdhani',sans-serif", fontWeight: 600, color: "#a090c0", width: 32, textAlign: "right" }}>{value}/{max}</span>
    </div>
  );
}
function OrnaDivider({ positions }: { positions: number[] }) {
  const mid = Math.floor(positions.length / 2);
  return (
    <svg viewBox="0 0 390 10" className="w-full" style={{ height: 10, display: "block" }}>
      <defs><linearGradient id="div-gx" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stopColor="#3d2060" stopOpacity="0"/><stop offset="20%" stopColor="#d4a017" stopOpacity="0.45"/><stop offset="50%" stopColor="#ffd700" stopOpacity="0.9"/><stop offset="80%" stopColor="#d4a017" stopOpacity="0.45"/><stop offset="100%" stopColor="#3d2060" stopOpacity="0"/></linearGradient></defs>
      <line x1="0" y1="5" x2="390" y2="5" stroke="url(#div-gx)" strokeWidth="1"/>
      {positions.map((x, i) => <polygon key={i} points={`${x},2 ${x+3.5},5 ${x},8 ${x-3.5},5`} fill={i === mid ? "#ffd700" : "#7b2ff7"} opacity={i === mid ? 0.95 : 0.5}/>)}
    </svg>
  );
}
function Timer() {
  const [s, setS] = useState(1);
  useEffect(() => { const t = setInterval(() => setS(x => x + 1), 1000); return () => clearInterval(t); }, []);
  return <span style={{ fontSize: 8.5, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#ffd700" }}>{String(Math.floor(s/60)).padStart(2,"0")}:{String(s%60).padStart(2,"0")}</span>;
}
function ForestBackground() {
  return (
    <svg viewBox="0 0 390 480" className="absolute inset-0 w-full h-full" preserveAspectRatio="xMidYMid slice" style={{ pointerEvents: "none" }}>
      <defs>
        <linearGradient id="sky" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stopColor="#040118"/><stop offset="40%" stopColor="#0b0930"/><stop offset="75%" stopColor="#0d1232"/><stop offset="100%" stopColor="#121828"/></linearGradient>
        <linearGradient id="trunk" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stopColor="#0a0522"/><stop offset="40%" stopColor="#150a38"/><stop offset="100%" stopColor="#0a0522"/></linearGradient>
        <radialGradient id="orb-glow" cx="50%" cy="50%" r="50%"><stop offset="0%" stopColor="#00e5c8" stopOpacity="0.9"/><stop offset="40%" stopColor="#00bcd4" stopOpacity="0.5"/><stop offset="100%" stopColor="#004455" stopOpacity="0"/></radialGradient>
        <radialGradient id="purple-glow" cx="50%" cy="50%" r="50%"><stop offset="0%" stopColor="#a060ff" stopOpacity="0.7"/><stop offset="100%" stopColor="#4020aa" stopOpacity="0"/></radialGradient>
        <radialGradient id="scene-light" cx="55%" cy="35%" r="50%"><stop offset="0%" stopColor="#004455" stopOpacity="0.25"/><stop offset="100%" stopColor="transparent" stopOpacity="0"/></radialGradient>
        <filter id="soft-glow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceGraphic" stdDeviation="6" result="blur"/><feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
        <filter id="hard-glow" x="-30%" y="-30%" width="160%" height="160%"><feGaussianBlur in="SourceGraphic" stdDeviation="3" result="blur"/><feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
      </defs>
      <rect width="390" height="480" fill="url(#sky)"/>
      <ellipse cx="215" cy="168" rx="180" ry="150" fill="url(#scene-light)"/>
      {[{cx:20,h:130,w:28},{cx:55,h:160,w:35},{cx:310,h:140,w:30},{cx:345,h:170,w:38}].map((t,i) => <g key={i} opacity="0.55"><ellipse cx={t.cx} cy={310-t.h*0.55} rx={t.w*0.5} ry={t.h*0.55} fill="#08042a"/></g>)}
      <path d="M 185 340 C 182 300,178 260,175 220 C 172 185,180 160,195 145 C 210 130,215 115,215 95" stroke="url(#trunk)" strokeWidth="22" fill="none" strokeLinecap="round"/>
      <path d="M 180 220 C 155 205,120 195,85 185" stroke="#0d0535" strokeWidth="12" fill="none" strokeLinecap="round"/>
      <path d="M 210 210 C 235 195,268 185,305 175" stroke="#0d0535" strokeWidth="12" fill="none" strokeLinecap="round"/>
      {[{cx:195,cy:80,rx:55,ry:38},{cx:145,cy:100,rx:38,ry:28},{cx:248,cy:95,rx:40,ry:30}].map((e,i) => <ellipse key={i} cx={e.cx} cy={e.cy} rx={e.rx} ry={e.ry} fill="#0d0540" opacity={0.72}/>)}
      {[{cx:83,cy:182,r:6,col:"#00e5c8"},{cx:306,cy:172,r:6,col:"#00e5c8"},{cx:195,cy:55,r:7,col:"#00e5c8"}].map((o,i) => <g key={i} filter="url(#hard-glow)"><circle cx={o.cx} cy={o.cy} r={o.r} fill={o.col} opacity="0.9"/><circle cx={o.cx} cy={o.cy} r={o.r*0.5} fill="#ffffff" opacity="0.6"/></g>)}
      <ellipse cx="197" cy="170" rx="40" ry="40" fill="url(#orb-glow)" filter="url(#soft-glow)" opacity="0.8"/>
      <ellipse cx="165" cy="145" rx="20" ry="20" fill="url(#purple-glow)" filter="url(#soft-glow)" opacity="0.6"/>
      <rect x="0" y="270" width="390" height="28" fill="#0a0a2a" opacity="0.35"/>
    </svg>
  );
}
function StoneGround() {
  return (
    <div className="absolute bottom-0 left-0 right-0" style={{ height: 70 }}>
      <svg viewBox="0 0 390 70" className="absolute inset-0 w-full h-full" preserveAspectRatio="none">
        <defs>
          <linearGradient id="gnd" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stopColor="#1e2a3a"/><stop offset="100%" stopColor="#0e1520"/></linearGradient>
          <pattern id="stone-tile" x="0" y="0" width="44" height="22" patternUnits="userSpaceOnUse"><rect x="1" y="1" width="41" height="19" rx="1.5" fill="#1a2535" stroke="#253040" strokeWidth="0.6"/></pattern>
          <pattern id="stone-tile-b" x="22" y="22" width="44" height="22" patternUnits="userSpaceOnUse"><rect x="1" y="1" width="41" height="19" rx="1.5" fill="#182230" stroke="#22303e" strokeWidth="0.6"/></pattern>
        </defs>
        <rect x="0" y="10" width="390" height="60" fill="url(#gnd)"/>
        <rect x="0" y="12" width="390" height="22" fill="url(#stone-tile)"/>
        <rect x="0" y="34" width="390" height="22" fill="url(#stone-tile-b)"/>
        <line x1="0" y1="11" x2="390" y2="11" stroke="#4a6080" strokeWidth="1.5" opacity="0.6"/>
        <rect x="0" y="8" width="390" height="6" fill="#00bcd4" opacity="0.06"/>
      </svg>
    </div>
  );
}
function NavBar({ activeNav, setActiveNav, onBattleNavClick }: { activeNav: string; setActiveNav: (id: string) => void; onBattleNavClick?: () => void }) {
  const items = [
    { id: "home", icon: <Home size={15} strokeWidth={1.8}/>, label: "Home" },
    { id: "heroes", icon: <Users size={15} strokeWidth={1.8}/>, label: "Heroes" },
    { id: "battle", icon: <Swords size={17} strokeWidth={2}/>, label: "Battle" },
    { id: "guild", icon: <Shield size={15} strokeWidth={1.8}/>, label: "Guild" },
    { id: "shop", icon: <ShoppingBag size={15} strokeWidth={1.8}/>, label: "Shop" },
  ];
  return (
    <div className="relative" style={{ height: 72 }}>
      <svg viewBox="0 0 390 72" className="absolute inset-0 w-full h-full pointer-events-none" preserveAspectRatio="none">
        <defs>
          <linearGradient id="nav-bg2" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stopColor="#100d28"/><stop offset="100%" stopColor="#07040f"/></linearGradient>
          <linearGradient id="arch-gold" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stopColor="#3d2060" stopOpacity="0.2"/><stop offset="40%" stopColor="#d4a017" stopOpacity="0.7"/><stop offset="50%" stopColor="#ffd700" stopOpacity="1"/><stop offset="60%" stopColor="#d4a017" stopOpacity="0.7"/><stop offset="100%" stopColor="#3d2060" stopOpacity="0.2"/></linearGradient>
        </defs>
        <path d="M 0 22 Q 90 22 148 14 Q 170 8 195 4 Q 220 8 242 14 Q 300 22 390 22 L 390 72 L 0 72 Z" fill="url(#nav-bg2)"/>
        <path d="M 0 22 Q 90 22 148 14 Q 170 8 195 4 Q 220 8 242 14 Q 300 22 390 22" fill="none" stroke="url(#arch-gold)" strokeWidth="1.2"/>
      </svg>
      <div className="relative flex items-end" style={{ height: 72 }}>
        {items.map((item, i) => {
          const isBattle = item.id === "battle"; const isActive = activeNav === item.id;
          return (
            <button key={item.id} onClick={() => { if (item.id === "battle" && onBattleNavClick) onBattleNavClick(); else setActiveNav(item.id); }}
              className="flex-1 flex flex-col items-center justify-end select-none" style={{ paddingBottom: 6 }}>
              {isActive && <div className="absolute top-0" style={{ left:`${i*20}%`, width:"20%", height:1, background:"linear-gradient(90deg,transparent,#00e5c8,transparent)", boxShadow:"0 0 6px #00e5c8" }}/>}
              <div className="relative flex items-center justify-center" style={{ width: isBattle?38:30, height: isBattle?38:30, marginBottom:2, marginTop: isBattle?0:8 }}>
                {(isActive||isBattle) && (
                  <svg viewBox="0 0 38 38" className="absolute inset-0 w-full h-full pointer-events-none">
                    <defs><linearGradient id={`ng-${item.id}`} x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor="#ffe066"/><stop offset="100%" stopColor="#9a6400"/></linearGradient></defs>
                    <polygon points={isBattle?"9,1 29,1 37,9 37,29 29,37 9,37 1,29 1,9":"7,1 31,1 37,7 37,31 31,37 7,37 1,31 1,7"} fill={isActive?"#0d1830":"#0a0f20"} stroke={`url(#ng-${item.id})`} strokeWidth={isBattle?"1.5":"1"}/>
                    {isBattle&&<polygon points="13,5 25,5 33,13 33,25 25,33 13,33 5,25 5,13" fill="none" stroke={isActive?"#00e5c8":"#ffd70033"} strokeWidth="0.7" opacity="0.6"/>}
                  </svg>
                )}
                <div style={{ color:isActive?"#00e5c8":isBattle?"#d4a017":"#4a3068", filter:isActive?"drop-shadow(0 0 4px #00e5c8aa)":undefined, transition:"color 0.2s" }}>{item.icon}</div>
              </div>
              <span style={{ fontSize:isBattle?8:7.5, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:isActive?"#a0f8e8":isBattle?"#d4a017":"#3a2858", letterSpacing:"0.08em", textTransform:"uppercase", transition:"color 0.2s" }}>{item.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ─── APP ──────────────────────────────────────────────────────────────────────
export default function App() {
  const [activeNav, setActiveNav] = useState("battle");
  const [battleView, setBattleView] = useState<BattleView>("farming");
  const [autoMode, setAutoMode] = useState(true);
  const [dmgVisible, setDmgVisible] = useState(true);

  useEffect(() => {
    const t = setInterval(() => { setDmgVisible(false); setTimeout(() => setDmgVisible(true), 300); }, 2800);
    return () => clearInterval(t);
  }, []);

  useEffect(() => { if (activeNav !== "battle") setBattleView("farming"); }, [activeNav]);

  const isHeroes = activeNav === "heroes";
  const isGuild  = activeNav === "guild";
  const isBattle = activeNav === "battle";
  const isDungeon = isBattle && battleView === "dungeon";
  const isLobby = isBattle && battleView === "lobby";
  const isFarming = isBattle && battleView === "farming";

  const skills = [
    { icon: <FireRune/>, locked: false }, { icon: <IceRune/>, locked: false },
    { icon: <WindRune/>, locked: false }, { icon: <ShadowRune/>, locked: true, levelReq: 40 },
    { locked: true, levelReq: 55 }, { locked: true, levelReq: 70 },
  ];

  function handleBattleNavClick() {
    if (isBattle) {
      setBattleView(v => v === "farming" ? "lobby" : "farming");
    } else {
      setActiveNav("battle");
      setBattleView("lobby");
    }
  }

  return (
    <div className="size-full flex items-center justify-center" style={{ background: "#020108" }}>
      <div className="relative flex flex-col overflow-hidden"
        style={{ width: "min(390px,100vw)", height: "min(844px,100vh)", background: "#06040f" }}>

        {isHeroes && <HeroesScreen onBack={() => setActiveNav("battle")}/>}
        {isDungeon && <DungeonScreen onClose={() => setBattleView("lobby")}/>}
        {isGuild && <GuildScreen onBack={() => setActiveNav("battle")}/>}

        {!isHeroes && !isDungeon && !isGuild && (
          <>
            {/* TOP HUD */}
            <div className="relative z-30 flex items-start gap-2 px-2 pt-2 pb-1" style={{ minHeight: 74 }}>
              <svg className="absolute inset-0 w-full h-full pointer-events-none" viewBox="0 0 390 74" preserveAspectRatio="none">
                <defs>
                  <linearGradient id="hud-bg" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stopColor="#0d0825" stopOpacity="0.97"/><stop offset="100%" stopColor="#08041a" stopOpacity="0.8"/></linearGradient>
                  <linearGradient id="hud-line" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stopColor="#3d2060" stopOpacity="0.2"/><stop offset="35%" stopColor="#d4a017" stopOpacity="0.65"/><stop offset="65%" stopColor="#d4a017" stopOpacity="0.65"/><stop offset="100%" stopColor="#3d2060" stopOpacity="0.2"/></linearGradient>
                </defs>
                <rect width="390" height="74" fill="url(#hud-bg)"/>
                <rect x="4" y="4" width="382" height="66" fill="none" stroke="#00e5c8" strokeWidth="0.4" opacity="0.12" rx="1"/>
                <line x1="0" y1="73.5" x2="390" y2="73.5" stroke="url(#hud-line)" strokeWidth="1"/>
                <polyline points="0,18 0,1 18,1" stroke="#d4a017" strokeWidth="1.2" fill="none" opacity="0.55"/>
                <polyline points="372,1 390,1 390,18" stroke="#d4a017" strokeWidth="1.2" fill="none" opacity="0.55"/>
                <polyline points="0,56 0,73 18,73" stroke="#d4a017" strokeWidth="1.2" fill="none" opacity="0.55"/>
                <polyline points="372,73 390,73 390,56" stroke="#d4a017" strokeWidth="1.2" fill="none" opacity="0.55"/>
              </svg>
              <div className="relative flex-shrink-0" style={{ width: 52, height: 52, marginTop: 4 }}>
                <div style={{ position:"absolute",inset:-7,borderRadius:"50%",background:"radial-gradient(circle,#7733ff55 0%,transparent 65%)",filter:"blur(5px)",animation:"classGlow 2.2s ease-in-out infinite" }}/>
                <svg viewBox="0 0 52 52" className="absolute inset-0 w-full h-full">
                  <defs><linearGradient id="av-ring" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor="#ffe066"/><stop offset="50%" stopColor="#8b6200"/><stop offset="100%" stopColor="#ffd700"/></linearGradient><clipPath id="av-clip"><polygon points="13,1 39,1 51,13 51,39 39,51 13,51 1,39 1,13"/></clipPath></defs>
                  <polygon points="13,1 39,1 51,13 51,39 39,51 13,51 1,39 1,13" fill="none" stroke="#8844ff" strokeWidth="3.5" opacity="0.28"/>
                  <polygon points="13,1 39,1 51,13 51,39 39,51 13,51 1,39 1,13" fill="#180d38" stroke="url(#av-ring)" strokeWidth="1.5"/>
                  <text x="26" y="36" textAnchor="middle" fontSize="27" clipPath="url(#av-clip)">⚔️</text>
                </svg>
                <div className="absolute -bottom-1.5 left-1/2 -translate-x-1/2 flex items-center justify-center px-2" style={{ height:13, background:"linear-gradient(90deg,#0d0520,#1e1040,#0d0520)", border:"1px solid #d4a01777", clipPath:"polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
                  <span style={{ fontSize:7, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:"#ffd700" }}>Lv.32</span>
                </div>
              </div>
              <div className="relative flex-1 flex flex-col" style={{ marginTop: 4 }}>
                <div className="flex items-center gap-2 mb-1.5">
                  <span style={{ fontFamily:"'Cinzel',serif", fontWeight:700, fontSize:15, color:"#ffd700", textShadow:"0 0 12px #ffd70044", letterSpacing:"0.07em" }}>FERO</span>
                  <div className="flex items-center gap-1 px-2 py-px" style={{ background:"#0d052099", border:"1px solid #3d206066", clipPath:"polygon(5px 0%,100% 0%,calc(100% - 5px) 100%,0% 100%)" }}>
                    <span style={{ fontSize:7.5, color:"#7060a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:600 }}>Elite · Farming</span>
                    <Timer/>
                  </div>
                </div>
                <StatBar value={69} max={158} color="#22dd6e" label="HP"/>
                <StatBar value={48} max={80}  color="#448aff" label="MP"/>
              </div>
              <div className="relative flex flex-col gap-1 flex-shrink-0" style={{ marginTop: 4 }}>
                <button className="relative flex items-center justify-center" style={{ width:48, height:22 }}>
                  <svg viewBox="0 0 48 22" className="absolute inset-0 w-full h-full pointer-events-none"><rect x="1" y="1" width="46" height="20" rx="2" fill="#0d0520" stroke="#3d206077" strokeWidth="1"/></svg>
                  <div className="relative z-10 flex items-center gap-1"><Map size={10} style={{ color:"#7060a0" }}/><span style={{ fontSize:7.5, color:"#7060a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:700, letterSpacing:"0.06em" }}>MAP</span></div>
                </button>
                <button className="relative flex items-center justify-center gap-1" style={{ width:48, height:30 }}>
                  <svg viewBox="0 0 48 30" className="absolute inset-0 w-full h-full pointer-events-none"><defs><linearGradient id="cap-g" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor="#ffe066"/><stop offset="100%" stopColor="#8b6200"/></linearGradient></defs><polygon points="8,1 40,1 47,8 47,22 40,29 8,29 1,22 1,8" fill="#0d0520" stroke="url(#cap-g)" strokeWidth="1.2"/></svg>
                  <Gift size={11} style={{ color:"#ffd700", flexShrink:0 }}/>
                  <div className="flex flex-col relative z-10"><span style={{ fontSize:6, fontFamily:"'Cinzel',serif", fontWeight:700, color:"#c8900a", lineHeight:1 }}>Cap.</span><span style={{ fontSize:6, fontFamily:"'Cinzel',serif", fontWeight:700, color:"#ffd700", lineHeight:1 }}>Reward</span></div>
                </button>
              </div>
            </div>

            {/* Stage label */}
            <div className="relative z-20 flex items-center justify-between px-3">
              <div style={{ width: 64 }}/>
              <div className="flex items-center gap-1.5 px-3 py-px" style={{ background:"#0d052099", border:"1px solid #3d206055", borderTop:"none", clipPath:"polygon(8px 0%,calc(100% - 8px) 0%,100% 100%,0% 100%)" }}>
                <Star size={7} style={{ color:"#ffd700" }} fill="#ffd700"/>
                <span style={{ fontSize:8.5, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:"#c8a0e0", letterSpacing:"0.07em" }}>
                  {isLobby ? "Battle Modes" : "2F · Forest Path 2"}
                </span>
                <Star size={7} style={{ color:"#ffd700" }} fill="#ffd700"/>
              </div>
              {isFarming && (
                <button onClick={() => setBattleView("lobby")} className="flex items-center gap-0.5" style={{ height: 20, padding: "0 8px", background: "#0a0820", border: "1px solid #3d206066", clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
                  <span style={{ fontSize: 8, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#6050a0" }}>Modes</span>
                  <ChevronRight size={9} style={{ color: "#6050a0" }}/>
                </button>
              )}
              {isLobby && (
                <button onClick={() => setBattleView("farming")} className="flex items-center gap-0.5" style={{ height: 20, padding: "0 8px", background: "#0a0820", border: "1px solid #3d206066", clipPath: "polygon(4px 0%,100% 0%,calc(100% - 4px) 100%,0% 100%)" }}>
                  <span style={{ fontSize: 8, fontFamily: "'Rajdhani',sans-serif", fontWeight: 700, color: "#6050a0" }}>Battle</span>
                  <ChevronRight size={9} style={{ color: "#6050a0" }}/>
                </button>
              )}
            </div>

            {/* Main content */}
            <div className="relative flex-1 overflow-hidden">
              {isLobby ? (
                <BattleLobby
                  onDungeons={() => setBattleView("dungeon")}
                  onHome={() => setBattleView("farming")}/>
              ) : (
                <>
                  <ForestBackground/>
                  <StoneGround/>
                  <div className="absolute" style={{ bottom:56, left:22 }}>
                    <div style={{ fontSize:54, lineHeight:1, filter:"drop-shadow(0 0 16px #a060ff66) drop-shadow(2px 6px 8px #00000099)" }}>🧝</div>
                  </div>
                  {dmgVisible && (
                    <div className="absolute" style={{ left:52, bottom:115, animation:"floatUp 2.5s ease-out forwards" }}>
                      <span style={{ fontSize:13, fontFamily:"'Rajdhani',sans-serif", fontWeight:700, color:"#ffee44", textShadow:"0 0 10px #ffaa00,0 1px 3px #00000099" }}>+247</span>
                    </div>
                  )}
                </>
              )}
            </div>

            {/* Skill bar — farming only */}
            {isFarming && (
              <div className="relative z-20">
                <OrnaDivider positions={[100, 195, 290]}/>
                <div className="flex items-center px-2" style={{ paddingTop:7, paddingBottom:7, gap:6, background:"linear-gradient(0deg,#060210 0%,#0e0a28 100%)" }}>
                  <AutoBtn active={autoMode} onToggle={() => setAutoMode(a => !a)}/>
                  <div style={{ width:1, height:40, background:"linear-gradient(0deg,transparent,#3d2060,transparent)", flexShrink:0 }}/>
                  <div className="flex items-center" style={{ gap:5, flex:1, justifyContent:"center" }}>
                    {skills.map((s, i) => <SkillBtn key={i} idx={i} icon={s.icon} locked={s.locked} levelReq={(s as any).levelReq}/>)}
                  </div>
                </div>
              </div>
            )}

            {/* World chat — farming only */}
            {isFarming && (
              <div className="relative z-20 flex items-center gap-2 px-3" style={{ height:26, background:"#07031566", borderTop:"1px solid #2a184555" }}>
                <MessageCircle size={10} style={{ color:"#6050a0", flexShrink:0 }}/>
                <span style={{ fontSize:9.5, color:"#6050a0", fontFamily:"'Rajdhani',sans-serif", fontWeight:500, flex:1, overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap" }}>
                  <span style={{ color:"#d4a017" }}>[World] </span>SilverArrow: Forest Path 2 is wild tonight 🔥
                </span>
                <button style={{ fontSize:8.5, color:"#d4a017", fontFamily:"'Rajdhani',sans-serif", fontWeight:700, whiteSpace:"nowrap" }}>Chat ▸</button>
              </div>
            )}

            {/* Nav bar */}
            <div className="relative z-30">
              <OrnaDivider positions={[39,117,195,273,351]}/>
              <NavBar activeNav={activeNav} setActiveNav={setActiveNav} onBattleNavClick={handleBattleNavClick}/>
            </div>
          </>
        )}

      </div>

      <style>{`
        @keyframes classGlow { 0%,100%{opacity:.35;transform:scale(1)}50%{opacity:1;transform:scale(1.2)} }
        @keyframes floatUp { 0%{opacity:0;transform:translateY(0)}15%{opacity:1}85%{opacity:.7}100%{opacity:0;transform:translateY(-36px)} }
        *{-webkit-tap-highlight-color:transparent}
        ::-webkit-scrollbar{display:none}
      `}</style>
    </div>
  );
}
