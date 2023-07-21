local _, addonTable = ...;

if not MaxDps then
    return;
end

local Priest = addonTable.Priest;
local MaxDps = MaxDps;

local HL = {
    Smite = 585,
    ShadowWordPain = 589,
    HolyFire = 14914,
    ShadowWordDeath = 32379,
    PowerInfusion = 10060,

    --Talents
    DivineStar = 110744,
    Halo = 120517,

    --Kyrian
    BoonoftheAscended = 325013,

    --NightFae
    FaeGuardians = 327661,

    --Venthyr
    Mindgames = 323673,

    --Necrolord
    UnholyNova = 324724,

};
function buff(unit, spellName)
    for i = 1, 40 do
        name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, spellId, shouldConsolidate =
            UnitBuff(unit, i)
        if not name then
            break
        end
        if spellId == spellName then
            return true
        end
    end
    return false
end

function AoeHeal(minHealth, numberOfInjured)
    local aoe = 0
    local groupSize = GetNumGroupMembers()

    if (UnitHealth("player") / UnitHealthMax("player")) * 100 <= minHealth then
        aoe = aoe + 1
    end

    for i = 1, groupSize do
        local unit = (IsInRaid() and "raid" or "party") .. i
        local healthPercent = (UnitHealth(unit) / UnitHealthMax(unit)) * 100

        if not UnitIsDead(unit) and UnitInRange(unit) and healthPercent <= minHealth then
            aoe = aoe + 1
        end
    end
    return aoe >= numberOfInjured
end

local CN = {
    None      = 0,
    Kyrian    = 1,
    Venthyr   = 2,
    NightFae  = 3,
    Necrolord = 4
};

setmetatable(HL, Priest.spellMeta);


function spell(spellId)
    if IsSpellKnown(spellId) then
        return spellId
    else
        return nil
    end
end

function Priest:Holy()
    local fd = MaxDps.FrameData;
    local covenantId = fd.covenant.covenantId;
    fd.targets = MaxDps:SmartAoe();
    local cooldown = fd.cooldown;
    local targetHp = MaxDps:TargetPercentHealth() * 100;
    local health = UnitHealth('player');
    local healthMax = UnitHealthMax('player');
    local healthPercent = (health / healthMax) * 100;
    local mana = UnitPower("player", 0)
    -- Essences
    MaxDps:GlowEssences();
    -- Cooldowns
    MaxDps:GlowCooldown(HL.PowerInfusion, cooldown[HL.PowerInfusion].ready);



    if cooldown[64901].ready and mana < 21 then
        return spell(64901)
    end

    local noTarget = not UnitExists("target")
    if (UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target")) or noTarget then
        if healthPercent <= 20 and cooldown[47788].ready then
            return spell(47788)
        end
        if healthPercent <= 30 and cooldown[19236].ready then
            return spell(19236)
        end

        if healthPercent <= 35 and cooldown[373481].ready then
            return spell(373481)
        end
        return Priest:AoeHeal(fd) or Priest:SelfHeal(fd) or Priest:Damage(fd)
    else
        if targetHp <= 20 and cooldown[47788].ready then
            return spell(47788)
        end


        if targetHp <= 35 and cooldown[373481].ready then
            return spell(373481)
        end
        return Priest:AoeHeal(fd) or Priest:TargetHeal(fd) or Priest:Damage(fd)
    end
end

function Priest:AoeHeal(fd)
    fd.targets = MaxDps:SmartAoe();
    local cooldown = fd.cooldown;
    local targets = fd.targets;
    local gcd = fd.gcd;
    local targetHp = MaxDps:TargetPercentHealth() * 100;
    local health = UnitHealth('target');
    local healthMax = UnitHealthMax('target');
    local healthPercent = (health / healthMax) * 100;


    if AoeHeal(40, 3) and cooldown[64843].ready then
        return spell(64843)
    end
    if cooldown[200183].ready and AoeHeal(70, 3) and (not cooldown[34861].ready and not cooldown[2050].ready) then
        return spell(200183)
    end
    if AoeHeal(85, 3) and cooldown[34861].ready then
        return spell(34861)
    end
    if AoeHeal(80, 3) and cooldown[204883].ready then
        return spell(204883)
    end

    if AoeHeal(85, 3) and cooldown[596].ready then
        return spell(596)
    end
end

function Priest:TargetHeal(fd)
    fd.targets = MaxDps:SmartAoe();
    local cooldown = fd.cooldown;
    local targets = fd.targets;
    local gcd = fd.gcd;
    local targetHp = MaxDps:TargetPercentHealth() * 100;
    local health = UnitHealth('target');
    local healthMax = UnitHealthMax('target');
    local healthPercent = (health / healthMax) * 100;

    local talents = fd.talents;

    if healthPercent <= 70 and cooldown[2050].ready then
        return spell(2050)
    end


    if (talents[390992]) then
        if buff("player", 114255) and healthPercent <= 85 or (healthPercent <= 70) then
            return spell(2061)
        else
            --soin
            if buff("player", 390993) and healthPercent <= 90 then
                return spell(2060)
            end
        end
    else
        if healthPercent <= 70 then
            return spell(2060)
        else
            --soin
            if healthPercent <= 85 then
                return spell(2060)
            end
        end
    end



    if healthPercent <= 90 and not buff("target", 139) then
        return spell(139)
    end
end

function Priest:SelfHeal(fd)
    fd.targets = MaxDps:SmartAoe();
    local cooldown = fd.cooldown;
    local health = UnitHealth('player');
    local healthMax = UnitHealthMax('player');
    local selfHealthPercent = (health / healthMax) * 100;
    local talents = fd.talents;

    if selfHealthPercent <= 70 and cooldown[2050].ready then
        return spell(2050)
    end

    if (talents[390992]) then
        if buff("player", 114255) and selfHealthPercent <= 85 or (selfHealthPercent <= 70) then
            return spell(2061)
        else
            --soin
            if buff("player", 390993) and selfHealthPercent <= 90 then
                return spell(2060)
            end
        end
    else
        if selfHealthPercent <= 70 then
            return spell(2060)
        else
            --soin
            if selfHealthPercent <= 85 then
                return spell(2060)
            end
        end
    end



    if selfHealthPercent <= 90 and not buff("player", 139) then
        return spell(138)
    end
end

function Priest:Damage(fd)
    fd.targets = MaxDps:SmartAoe();
    local cooldown = fd.cooldown;
    local buff = fd.buff;
    local debuff = fd.debuff;
    local talents = fd.talents;
    local targets = fd.targets;
    local gcd = fd.gcd;
    local targetHp = MaxDps:TargetPercentHealth() * 100;
    local health = UnitHealth('player');
    local healthMax = UnitHealthMax('player');
    local healthPercent = (health / healthMax) * 100;
    if (UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target")) then
        if cooldown[34433].ready then
            return spell(34433)
        end

        if cooldown[88625].ready then
            return spell(88625)
        end

        if (not cooldown[14914].ready) and cooldown[372616].ready
            and UnitHealth("target") / UnitHealthMax("target") >= 0.35 then
            return spell(372616)
        end

        if talents[HL.DivineStar] and cooldown[HL.DivineStar].ready then
            return spell(HL.DivineStar);
        end

        if talents[HL.Halo] and cooldown[HL.Halo].ready then
            return spell(HL.Halo);
        end

        if targetHp <= 20 and cooldown[HL.ShadowWordDeath].ready then
            return spell(HL.ShadowWordDeath);
        end

        if debuff[HL.ShadowWordPain].refreshable and cooldown[HL.ShadowWordPain].ready then
            return spell(HL.ShadowWordPain);
        end

        if cooldown[HL.HolyFire].ready then
            return HL.HolyFire;
        end

        if cooldown[HL.Smite].ready then
            return HL.Smite;
        end
    end
end
