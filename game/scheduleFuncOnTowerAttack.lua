-- 兵塔攻击到了
onTowerAttackTtgCount = 1
onTowerAttackTtg = function(u, string)
    htextTag.style(
        htextTag.create2Unit(u, string, 6.9 + onTowerAttackTtgCount * 0.1, "FFFF00", 2, 2, 10),
        "scale",
        0,
        onTowerAttackTtgCount * 0.15
    )
    onTowerAttackTtgCount = onTowerAttackTtgCount + 1
    htime.setTimeout(
        2,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            onTowerAttackTtgCount = onTowerAttackTtgCount - 1
        end
    )
end
onTowerAttack = function()
    local u = hevent.getAttacker()
    local targetUnit = hevent.getTargetUnit()
    for ABILITY_ID, v in pairs(hslk_global.abilitiesKV) do
        if (hskill.has(u, ABILITY_ID)) then
            local Name = v.Name
            local level = v.ABILITY_LEVEL or 1
            level = level * 2 - 1
            if (Name ~= nil) then
                if (Name == "侵毒连击" and math.random(1, 10) == 5) then
                    onTowerAttackTtg(u, Name)
                    hattr.set(
                        u,
                        5.00,
                        {
                            attack_hunt_type = "+poison",
                            attack_speed = "+" .. 10 * level
                        }
                    )
                end
                if (Name == "机关枪" and math.random(1, 5) == 3) then
                    onTowerAttackTtg(u, Name)
                    hattr.set(
                        u,
                        2.50 * level,
                        {
                            attack_speed = "+" .. 12.5 * level
                        }
                    )
                end
                if (Name == "掠夺黄金" and math.random(1, 40) <= level) then
                    onTowerAttackTtg(u, Name)
                    haward.forPlayerGold(10)
                end
                if (Name == "震晕践踏" and math.random(1, 10) == 5) then
                    onTowerAttackTtg(u, Name)
                    hskill.swimGroup(
                        {
                            range = 1000,
                            odds = 100,
                            during = 0.5 * level,
                            whichUnit = u,
                            filter = function()
                                return his.alive(cj.GetFilterUnit()) and his.enemy(cj.GetFilterUnit(), u)
                            end
                        }
                    )
                end
                if (Name == "炸裂践踏" and math.random(1, 10) == 5) then
                    onTowerAttackTtg(u, Name)
                    hskill.swimGroup(
                        {
                            range = 1000,
                            odds = 100,
                            during = 1.2 * level,
                            damage = 50 * level,
                            whichUnit = u,
                            sourceUnit = u,
                            model = "war3mapImported\\eff_shock_explosion.mdl",
                            filter = function()
                                return his.alive(cj.GetFilterUnit()) and his.enemy(cj.GetFilterUnit(), u)
                            end
                        }
                    )
                end
                if (Name == "冰花炸裂" and math.random(1, 7) == 4) then
                    onTowerAttackTtg(u, Name)
                    local x = cj.GetUnitX(u)
                    local y = cj.GetUnitY(u)
                    heffect.toXY("war3mapImported\\eff_FrostNova.mdl", x, y, 0)
                    local g =
                        hgroup.createByUnit(
                        u,
                        1000,
                        function()
                            return his.alive(cj.GetFilterUnit()) and his.enemy(cj.GetFilterUnit(), u)
                        end
                    )
                    cj.ForGroup(
                        g,
                        function()
                            local eu = cj.GetEnumUnit()
                            hattr.set(eu, 7.5, {move = "-" .. 45 * level})
                            heffect.toUnit("war3mapImported\\eff_frost_burst.mdl", eu, 0)
                            heffect.bindUnit("war3mapImported\\eff_icing.mdl", eu, "foot", 7.5)
                        end
                    )
                    cj.GroupClear(g)
                    cj.DestroyGroup(g)
                end
                if (Name == "死亡同步" and math.random(1, 500) == 265 and his.alive(targetUnit)) then
                    onTowerAttackTtg(u, Name)
                    heffect.bindUnit(
                        "Abilities\\Spells\\NightElf\\shadowstrike\\shadowstrike.mdl",
                        targetUnit,
                        "head",
                        1
                    )
                    hunit.kill(targetUnit, 0)
                end
            end
        end
    end
end
