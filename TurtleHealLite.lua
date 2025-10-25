-- TurtleHealLite: main logic (Lua)
local addonName = "TurtleHealLite"
local TH = {}
_G[addonName] = TH

-- default config
TH.db = {
  spells = { primary = "Regrowth", fallback = "Healing Touch" },
  showTargets = { "player", "target", "mouseover" },
  fontSize = 12,
}

-- utility
local function CreateUnitButton(unit, id)
  local name = "TH_UnitButton_"..id
  local btn = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
  btn:SetSize(110, 30)
  btn.unit = unit
  btn:SetPoint("CENTER", UIParent, "CENTER", 0, -50 - (id-1)*36)
  btn:SetAttribute("unit", unit)
  btn:RegisterForClicks("AnyDown")
  -- secure left click heal
  btn:SetAttribute("type1", "spell")
  btn:SetAttribute("spell", TH.db.spells.primary)
  -- right click: target unit
  btn:SetAttribute("type2", "target")

  local bg = btn:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(btn)
  bg:SetTexture(0,0,0,0.6)

  btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  btn.text:SetPoint("LEFT", 6, 6)
  btn.text:SetFont(btn.text:GetFont(), TH.db.fontSize)
  btn.text:SetText(unit)

  btn.timer = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  btn.timer:SetPoint("RIGHT", -6, 6)
  btn.timer:SetFont(btn.timer:GetFont(), TH.db.fontSize)
  btn.timer:SetText("")

  return btn
end

-- dynamic buttons table
TH.buttons = {}

local function UpdateButtons()
  for i,unit in ipairs(TH.db.showTargets) do
    local btn = TH.buttons[i]
    if not btn then
      btn = CreateUnitButton(unit, i)
      TH.buttons[i] = btn
    else
      btn.unit = unit
      btn:SetAttribute("unit", unit)
      btn.text:SetText(unit)
      btn:SetAttribute("spell", TH.db.spells.primary)
    end
  end
end

-- aura scanning
local function GetTrackedBuffRemaining(unit, spellNames)
  local i = 1
  while true do
    local name,_,_,_,_,expirationTime,_,caster = UnitBuff(unit, i)
    if not name then break end
    if spellNames[name] then
      if expirationTime and expirationTime > 0 then
        local remaining = expirationTime - GetTime()
        if remaining < 0 then remaining = 0 end
        return remaining, name, caster
      end
    end
    i = i + 1
  end
  return nil
end

-- tracked spells
TH.trackedSpellNames = {
  ["Rejuvenation"] = true,
  ["Regrowth"] = true,
  ["Lifebloom"] = true,
}

-- periodic update
local ticker
local function StartTicker()
  if ticker then return end
  ticker = C_Timer.NewTicker(0.25, function()
    for i,btn in ipairs(TH.buttons) do
      local unit = btn.unit
      if UnitExists(unit) then
        local remain, name, caster = GetTrackedBuffRemaining(unit, TH.trackedSpellNames)
        if remain then
          btn.timer:SetText(string.format("%.1fs", remain))
          btn:SetAlpha(1)
        else
          btn.timer:SetText("")
          btn:SetAlpha(0.6)
        end
        btn:SetAttribute("spell", TH.db.spells.primary)
      else
        btn.timer:SetText("(no unit)")
        btn:SetAlpha(0.4)
      end
    end
  end)
end

-- slash-command (/thl) robuste
do
    SLASH_TURTLEHEALLITE1 = "/thl"
    SlashCmdList["TURTLEHEALLITE"] = function(msg)
        if type(msg) ~= "string" then msg = "" end
        local cmd, rest = msg:match("^(%S*)%s*(.-)$")
        if type(rest) ~= "string" then rest = "" end

        if cmd == "spell" and rest ~= "" then
            TH.db.spells.primary = rest
            print("TurtleHealLite: primary spell set to", rest)
            UpdateButtons()
        elseif cmd == "show" and rest ~= "" then
            TH.db.showTargets = {}
            for u in rest:gmatch("%S+") do table.insert(TH.db.showTargets, u) end
            UpdateButtons()
        else
            print("TurtleHealLite commands:")
            print("/thl spell <name>   - set primary heal spell (left click)")
            print("/thl show <units>   - set unit list (player target mouseover party1 ...)")
        end
    end
end

-- init
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UNIT_AURA")
f:SetScript("OnEvent", function(self, event, arg1, ...)
  if event == "PLAYER_LOGIN" then
    UpdateButtons()
    StartTicker()
    print("TurtleHealLite loaded. Use /thl for options.")
  elseif event == "UNIT_AURA" then
    -- ticker updates timers
  end
end)
