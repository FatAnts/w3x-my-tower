local AB_HOTKEY_KV = {
    A = { 0, 1 },
    S = { 1, 1 },
    D = { 2, 1 },
    F = { 3, 1 },
    Z = { 0, 2 },
    X = { 1, 2 },
    C = { 2, 2 },
    V = { 3, 2 },
}

local yellow = {
    "A", "S", "D", "F",
}
local red = {
    "Z", "X", "C", "V",
}

-- abilities
-- 处理空技能槽
for _, v in ipairs(red) do
    local obj = slk.ability.Aamk:new("abilities_empty_" .. v)
    local Name = "红技能槽 - [" .. hColor.red(v) .. "]"
    local Tip = "红技能槽 - [" .. hColor.red(v) .. "]"
    obj.Name = Name
    obj.Tip = Tip
    obj.Ubertip = "使用技能书可以习得新的红点技能"
    obj.Buttonpos1 = AB_HOTKEY_KV[v][1]
    obj.Buttonpos2 = AB_HOTKEY_KV[v][2]
    obj.hero = 0
    obj.levels = 1
    obj.DataA1 = 0
    obj.DataB1 = 0
    obj.DataC1 = 0
    obj.Art = "war3mapImported\\icon_pas_Skillz.blp"
    local ab = {
        ABILITY_ID = obj:get_id(),
        ABILITY_BTN = v,
    }
    ?>
call SaveStr(hash_myslk, StringHash("abilities_empty"), StringHash("<?=v?>"), "<?=hSys.addslashes(json.stringify(ab))?>")
<?
end
for _, v in ipairs(yellow) do
    local obj = slk.ability.Aamk:new("abilities_empty_" .. v)
    local Name = "黄技能槽 - [" .. hColor.yellow(v) .. "]"
    local Tip = "黄技能槽 - [" .. hColor.yellow(v) .. "]"
    obj.Name = Name
    obj.Tip = Tip
    obj.Ubertip = "使用技能书可以习得新的黄点技能"
    obj.Buttonpos1 = AB_HOTKEY_KV[v][1]
    obj.Buttonpos2 = AB_HOTKEY_KV[v][2]
    obj.hero = 0
    obj.levels = 1
    obj.DataA1 = 0
    obj.DataB1 = 0
    obj.DataC1 = 0
    obj.Art = "ReplaceableTextures\\PassiveButtons\\PASBTNStatUp.blp"
    local ab = {
        ABILITY_ID = obj:get_id(),
        ABILITY_BTN = v,
    }
    ?>
call SaveStr(hash_myslk, StringHash("abilities_empty"), StringHash("<?=v?>"), "<?=hSys.addslashes(json.stringify(ab))?>")
<?
end

local level_limit = 10
local ab_index = 0
local ab_item_index = 0

-- 处理技能(书)数据
for _, v in ipairs(abilities) do
    -- 这一轮是技能等级的
    for level = 1, level_limit, 1 do
        -- 这一轮是处理类型的
        local ABILITY_COLOR = red
        if (v.ABILITY_COLOR == "yellow") then
            ABILITY_COLOR = yellow
        elseif (v.ABILITY_COLOR == "all") then
            ABILITY_COLOR = hSys.mergeTable(red, yellow)
        end
        local Ubertip = v.Ubertip or ""
        v.Val = v.Val or {}
        if (Ubertip ~= "") then
            for vali = 1, 5, 1 do
                local valmatch = "{val#" .. vali .. "}"
                if (v.Val[vali] == nil) then
                    v.Val[vali] = 0
                end
                if (string.find(Ubertip, valmatch) ~= nil) then
                    Ubertip = string.gsub(Ubertip, valmatch, "|cffffcc00" .. v.Val[vali] .. "|r")
                else
                    vali = 99
                end
            end
        end
        for _, s in ipairs(ABILITY_COLOR) do
            ab_index = ab_index + 1
            local obj = slk.ability.Aamk:new("abilities_" .. v.Name .. "_" .. level .. "_" .. s)
            local Name = v.Name .. "[Lv" .. level .. "]" .. "[" .. s .. "]"
            local Tip = v.Name .. " - [|cffffcc00等级 " .. level .. "|r]" .. " - [|cffffcc00" .. s .. "|r]"
            obj.Name = Name
            obj.Tip = Tip
            obj.Ubertip = Ubertip
            obj.Buttonpos1 = AB_HOTKEY_KV[s][1]
            obj.Buttonpos2 = AB_HOTKEY_KV[s][2]
            obj.hero = 0
            obj.levels = 1
            obj.DataA1 = 0
            obj.DataB1 = 0
            obj.DataC1 = 0
            obj.Art = v.Art
            v.ABILITY_ID = obj:get_id()
            v.ABILITY_BTN = s
            v.abilityLV = level
            ?>
        call SaveStr(hash_myslk, StringHash("abilities"), <?=ab_index?>, "<?=hSys.addslashes(json.stringify(v))?>")
            <?
        end
        -- 物品
        if (v.ABILITY_COLOR ~= "all") then
            ab_item_index = ab_item_index + 1
            local iobj = slk.item.gold:new("abilities_items_" .. v.Name .. "_" .. level)
            local goldcost = 0
            if (v.ABILITY_COLOR == 'red') then
                iobj.Name = "[技能书·红]《" .. level .. "级" .. v.Name .. "》"
                iobj.Tip = "点击学习红技能书：|cffffcc00《" .. level .. "级" .. v.Name .. "》|r"
                iobj.file = "Objects\\InventoryItems\\tomeRed\\tomeRed.mdl"
                iobj.abilList = UsedID.BookRed
                goldcost = level * 10
            elseif (v.ABILITY_COLOR == 'yellow') then
                iobj.Name = "[技能书·黄]《" .. level .. "级" .. v.Name .. "》"
                iobj.Tip = "点击学习黄技能书：|cffffcc00《" .. level .. "级" .. v.Name .. "》|r"
                iobj.file = "Objects\\InventoryItems\\tomeBrown\\tomeBrown.mdl"
                iobj.abilList = UsedID.BookYellow
                goldcost = level * 20
            end
            iobj.UberTip = "能学习到技能：|n" .. Ubertip
            iobj.Description = "技能书：" .. Ubertip
            iobj.Art = v.Art
            iobj.scale = 1.00
            iobj.goldcost = goldcost
            iobj.lumbercost = 0
            iobj.sellable = 1
            iobj.cooldownID = ""
            iobj.class = "Charged"
            iobj.powerup = 0
            local hitem = {
                Name = v.Name,
                Art = v.Art,
                goldcost = goldcost,
                lumbercost = 0,
                ITEM_ID = iobj:get_id(),
                ABILITY_ID = v.ABILITY_ID,
                ABILITY_COLOR = v.ABILITY_COLOR,
                ABILITY_LEVEL = level,
                WEIGHT = 0.01,
                OVERLIE = 999,
                TRIGGER_CALL = v.TRIGGER_CALL or nil,
            }
            ?>
        call SaveStr(hash_myslk, StringHash("abilitiesItems"), <?=ab_item_index?>, "<?=hSys.addslashes(json.stringify(hitem))?>")
            <?
        end
    end
end

local towerPower = {
    "SSS", "SS", "S", "A", "B", "C", "D", "E"
}
for _, v in ipairs(towerPower) do
    local obj = slk.ability.Aamk:new("abilities_tower_power_" .. v)
    local Name = "兵塔阶级 - [" .. hColor.yellow(v) .. "]"
    local Tip = "兵塔阶级 - [" .. hColor.yellow(v) .. "]"
    obj.Name = Name
    obj.Tip = Tip
    obj.Ubertip = "这是一个" .. hColor.yellow(v) .. "级的兵塔"
    obj.Buttonpos1 = 1
    obj.Buttonpos2 = 0
    obj.hero = 0
    obj.levels = 1
    obj.DataA1 = 0
    obj.DataB1 = 0
    obj.DataC1 = 0
    obj.Art = "war3mapImported\\icon_pas_Letter_" .. v .. ".blp"
    local ab = {
        ABILITY_ID = obj:get_id(),
        ABILITY_BTN = v,
    }
    ?>
call SaveStr(hash_myslk, StringHash("abilities_tower_power"), StringHash("<?=v?>"), "<?=hSys.addslashes(json.stringify(ab))?>")
<?
end

?>
call SaveInteger(hash_myslk, StringHash("abilities_qty"), 0, <?=ab_index?>)
call SaveInteger(hash_myslk, StringHash("abilities_item_qty"), 0, <?=ab_item_index?>)
<?