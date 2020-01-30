require "game.scheduleFunc"

game.TRIGGER_DEMOVE = cj.CreateTrigger()
cj.TriggerAddAction(
    game.TRIGGER_DEMOVE,
    function()
        if (cj.GetIssuedOrderId() == 851971 or cj.GetIssuedOrderId() == 851986) then
            local index = hplayer.index(cj.GetOwningPlayer(cj.GetTriggerUnit()))
            cj.IssuePointOrderById(
                cj.GetTriggerUnit(),
                851983,
                cj.GetUnitX(cj.GetTriggerUnit()),
                cj.GetUnitY(cj.GetTriggerUnit())
            )
        end
    end
)

dzSetLumber = function(p, curWave)
    local lv = hdzapi.mapLv(p)
    if (lv == nil or lv < 1) then
        lv = 1
    end
    hdzapi.server.set.int(p, "lumber", hplayer.getLumber(p) + curWave + lv)
end

dzSetPrestige = function(p, iscs, isss)
    local cs = hdzapi.server.get.int(p, "prestigecs")
    local ss = hdzapi.server.get.int(p, "prestigess")
    if (iscs) then
        cs = cs + 1
        hdzapi.server.set.int(p, "prestigecs", cs)
        hdzapi.setRoomStat(p, "prestigecs", cs)
    end
    if (isss) then
        ss = ss + 1
        hdzapi.server.set.int(p, "prestigess", cs)
        hdzapi.setRoomStat(p, "prestigess", ss)
    end
    local prestige
    if (cs >= 500 and ss >= 100) then
        prestige = "九天至尊"
    elseif (cs >= 300 and ss >= 75) then
        prestige = "六道大仙"
    elseif (cs >= 200 and ss >= 50) then
        prestige = "神游三界"
    elseif (cs >= 150 and ss >= 25) then
        prestige = "灭劫星窍"
    elseif (cs >= 125 and ss >= 15) then
        prestige = "灵通三魂"
    elseif (cs >= 100 and ss >= 13) then
        prestige = "身越七魄"
    elseif (cs >= 90 and ss >= 11) then
        prestige = "超凡入圣"
    elseif (cs >= 80 and ss >= 9) then
        prestige = "超然世外"
    elseif (cs >= 70 and ss >= 7) then
        prestige = "猎尽天下"
    elseif (cs >= 60 and ss >= 5) then
        prestige = "登峰造极"
    elseif (cs >= 50 and ss >= 3) then
        prestige = "当世雄豪"
    elseif (cs >= 40 and ss >= 2) then
        prestige = "名扬四方"
    elseif (cs >= 30 and ss >= 1) then
        prestige = "一战成名"
    elseif (cs >= 20 and ss >= 0) then
        prestige = "游刃有余"
    elseif (cs >= 10 and ss >= 0) then
        prestige = "初露锋芒"
    elseif (cs >= 5 and ss >= 0) then
        prestige = "略有小成"
    else
        prestige = "初出茅庐"
    end
    hplayer.setPrestige(p, prestige)
    hdzapi.setRoomStat(p, "prestige", prestige)
end

local startTrigger = cj.CreateTrigger()
cj.TriggerRegisterTimerEvent(startTrigger, 1.0, false)
cj.TriggerAddAction(
    startTrigger,
    function()
        cj.DisableTrigger(cj.GetTriggeringTrigger())
        cj.DestroyTrigger(cj.GetTriggeringTrigger())
        --[[
            这里开始游戏正式开始了
            发挥你的想象力吧~
        ]]
        cj.FogEnable(false)
        cj.FogMaskEnable(false)
        hsound.bgmStop(nil)
        --
        for i = 1, hplayer.qty_max, 1 do
            local l = hdzapi.server.get.int(hplayer.players[i], "lumber")
            if (l == nil) then
                l = 0
            end
            game.playerOriginLumber[i] = l
            hplayer.setLumber(hplayer.players[i], l)
            hmsg.echo00(hplayer.players[i], " *** 根据你的地图等级和游玩次数，你得到了" .. hColor.green(l) .. "个木头")
            dzSetPrestige(hplayer.players[i], true, false)
        end
        htime.setInterval(
            5,
            function()
                for i = 1, hplayer.qty_max, 1 do
                    if
                        (his.playing(hplayer.players[i]) == true and his.playerSite(hplayer.players[i]) == true and
                            hplayer.getLumber(hplayer.players[i]) > game.playerOriginLumber[i])
                     then
                        hplayer.defeat(hplayer.players[i], "网络不稳定")
                        htime.setTimeout(
                            5.00,
                            function()
                                hmsg.echo(cj.GetPlayerName(hplayer.players[i]) .. "作弊了哦~系统干掉它了~")
                            end
                        )
                    end
                end
            end
        )
        --设置三围基础
        hattr.setThreeBuff(
            {
                str = {
                    life = 7,
                    attack_white = 0.06,
                    toughness = 0.02
                },
                agi = {
                    attack_white = 0.10,
                    attack_speed = 0.018,
                    avoid = 0.02
                },
                int = {
                    attack_white = 0.08,
                    resistance = 0.02
                }
            }
        )
        local btns = {
            "轻松" .. game.rule.yb.waveEnd .. "波",
            "死机挑战"
        }
        if (hplayer.qty_current <= 1) then
            table.insert(btns, "有趣对抗(AI模式)")
        else
            table.insert(btns, "有趣对抗")
        end
        -- 第一玩家选择模式
        hmsg.echo("第一个玩家正在选择（游戏模式）", 10)
        hdialog.create(
            nil,
            {
                title = "选择游戏模式",
                buttons = btns
            },
            function(btnIdx)
                hmsg.echo("选择了" .. btnIdx)
                if (btnIdx == "轻松" .. game.rule.yb.waveEnd .. "波") then
                    game.rule.cur = "yb"
                    hmsg.echo("|cffffff00各玩家合力打怪，打不过的会流到下一位玩家继续攻击，所有玩家都打不过就会扣除“大精灵”的生命，坚持100波胜利|r")
                    hsound.bgm(cg.gg_snd_bgm_hz, nil)
                    -- 大精灵
                    local bigElf =
                        hunit.create(
                        {
                            whichPlayer = game.ALLY_PLAYER,
                            unitId = game.thisUnits["大精灵"].UNIT_ID,
                            qty = 1,
                            x = 0,
                            y = 0
                        }
                    )
                    hevent.onDead(
                        bigElf,
                        function()
                            game.runing = false
                            hmsg.echo("不！“大精灵”GG了，结束啦~我们的守护")
                            htime.setTimeout(
                                5.00,
                                function(t, td)
                                    htime.delDialog(td)
                                    htime.delTimer(t)
                                    for i = 1, hplayer.qty_max, 1 do
                                        hplayer.defeat(hplayer.players[i], "再见~")
                                    end
                                end,
                                "退出倒计时"
                            )
                        end
                    )
                    cj.PingMinimapEx(x, y, 10, 255, 0, 0, false)
                    -- 构建出怪区域
                    for k, v in ipairs(game.pathPoint) do
                        for i, p in ipairs(v) do
                            local r = hrect.create(p[1], p[2], 100, 100, "rect" .. k .. i)
                            local tg = cj.CreateTrigger()
                            bj.TriggerRegisterEnterRectSimple(tg, r)
                            cj.TriggerAddAction(
                                tg,
                                function()
                                    if (his.enemyPlayer(cj.GetTriggerUnit(), game.ALLY_PLAYER)) then
                                        if (i == #v) then
                                            -- 最后一个
                                            local uVal = cj.GetUnitUserData(cj.GetTriggerUnit())
                                            if (uVal >= hplayer.qty_current - 1) then
                                                heffect.toUnit(
                                                    "Abilities\\Spells\\NightElf\\shadowstrike\\shadowstrike.mdl",
                                                    cj.GetTriggerUnit(),
                                                    1
                                                )
                                                if (his.alive(bigElf)) then
                                                    local slk = hunit.getSlk(cj.GetTriggerUnit())
                                                    local type = slk.TYPE
                                                    local huntDmg = 0
                                                    if (type == "boss") then
                                                        huntDmg = 3 * game.rule.yb.wave
                                                    elseif (type == "normal") then
                                                        huntDmg = game.rule.yb.wave
                                                    end
                                                    if (huntDmg > 0) then
                                                        hmsg.echo(
                                                            hColor.yellow(hunit.getName(cj.GetTriggerUnit())) ..
                                                                "造成了" .. hColor.red(huntDmg) .. "伤害"
                                                        )
                                                        heffect.toUnit(
                                                            "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl",
                                                            bigElf,
                                                            1
                                                        )
                                                        hunit.subCurLife(bigElf, huntDmg)
                                                        cj.PingMinimapEx(x, y, 10, 255, 0, 0, false)
                                                        htextTag.style(
                                                            htextTag.create2Unit(
                                                                bigElf,
                                                                "-" ..
                                                                    huntDmg ..
                                                                        " " ..
                                                                            game.bigElfTips[
                                                                                cj.GetRandomInt(1, #game.bigElfTips)
                                                                            ],
                                                                10.00,
                                                                "ff0000",
                                                                1,
                                                                1.1,
                                                                50.00
                                                            ),
                                                            "scale",
                                                            0,
                                                            0.05
                                                        )
                                                    end
                                                end
                                                hunit.del(cj.GetTriggerUnit(), 0)
                                            else
                                                cj.SetUnitUserData(cj.GetTriggerUnit(), uVal + 1)
                                                heffect.bindUnit(
                                                    "Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl",
                                                    cj.GetTriggerUnit(),
                                                    "origin",
                                                    2
                                                )
                                                local next = getNextRect(k)
                                                if (next ~= -1) then
                                                    cj.SetUnitPosition(
                                                        cj.GetTriggerUnit(),
                                                        game.pathPoint[next][1][1],
                                                        game.pathPoint[next][1][2]
                                                    )
                                                end
                                            end
                                        else
                                            -- 前段路途
                                            cj.IssuePointOrderById(
                                                cj.GetTriggerUnit(),
                                                851986,
                                                v[i + 1][1],
                                                v[i + 1][2]
                                            )
                                        end
                                    end
                                end
                            )
                        end
                    end
                    enemyGenYB(10)
                    hleaderBoard.create(
                        "yb",
                        1,
                        function(bl)
                            local bigElfLife = "GG"
                            if (his.alive(bigElf)) then
                                bigElfLife =
                                    hColor.white(math.floor(hunit.getCurLife(bigElf))) ..
                                    "/" .. math.floor(hunit.getMaxLife(bigElf))
                            end
                            hleaderBoard.setTitle(bl, "百波战力榜[" .. game.rule.yb.wave .. "波][精灵 " .. bigElfLife .. "]")
                            local data = {}
                            hplayer.loop(
                                function(p, pi)
                                    data[pi] = math.floor(0.3 * hplayer.getKill(p))
                                end
                            )
                            return data
                        end
                    )
                elseif (btnIdx == "死机挑战") then
                    game.rule.cur = "hz"
                    hmsg.echo("|cffffff00各玩家合力打怪，打不过的会流到下一位玩家继续攻击，所有玩家都打不过就会扣除“光辉城主”的生命，玩到死机为止！|r")
                    hsound.bgm(cg.gg_snd_bgm_hz, nil)
                    local bigElf =
                        hunit.create(
                        {
                            whichPlayer = game.ALLY_PLAYER,
                            unitId = game.thisUnits["光辉城主"].UNIT_ID,
                            qty = 1,
                            x = 0,
                            y = 0
                        }
                    )
                    hevent.onDead(
                        bigElf,
                        function()
                            game.runing = false
                            hmsg.echo("不！“光辉城主”GG了，还没死机就结束啦~我们的守护")
                            htime.setTimeout(
                                5,
                                function(t, td)
                                    htime.delDialog(td)
                                    htime.delTimer(t)
                                    for i = 1, hplayer.qty_max, 1 do
                                        hplayer.defeat(hplayer.players[i], "再见~")
                                    end
                                end,
                                "退出倒计时"
                            )
                        end
                    )
                    cj.PingMinimapEx(x, y, 10, 255, 0, 0, false)
                    -- 构建出怪区域
                    for k, v in ipairs(game.pathPoint) do
                        for i, p in ipairs(v) do
                            local r = hrect.create(p[1], p[2], 100, 100, "rect" .. k .. i)
                            local tg = cj.CreateTrigger()
                            bj.TriggerRegisterEnterRectSimple(tg, r)
                            cj.TriggerAddAction(
                                tg,
                                function()
                                    if (his.enemyPlayer(cj.GetTriggerUnit(), game.ALLY_PLAYER)) then
                                        if (i == #v) then
                                            -- 最后一个
                                            local uVal = cj.GetUnitUserData(cj.GetTriggerUnit())
                                            if (uVal >= hplayer.qty_current - 1) then
                                                heffect.toUnit(
                                                    "Abilities\\Spells\\NightElf\\shadowstrike\\shadowstrike.mdl",
                                                    cj.GetTriggerUnit(),
                                                    1
                                                )
                                                if (his.alive(bigElf)) then
                                                    local slk = hunit.getSlk(cj.GetTriggerUnit())
                                                    local type = slk.TYPE
                                                    local huntDmg = 0
                                                    if (type == "boss") then
                                                        huntDmg = 3 * game.rule.hz.wave
                                                    elseif (type == "normal") then
                                                        huntDmg = game.rule.hz.wave
                                                    end
                                                    if (huntDmg > 0) then
                                                        hmsg.echo(
                                                            hColor.yellow(hunit.getName(cj.GetTriggerUnit())) ..
                                                                "造成了" .. hColor.red(huntDmg) .. "伤害"
                                                        )
                                                        heffect.toUnit(
                                                            "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl",
                                                            bigElf,
                                                            1
                                                        )
                                                        hunit.subCurLife(bigElf, huntDmg)
                                                        cj.PingMinimapEx(x, y, 10, 255, 0, 0, false)
                                                        htextTag.style(
                                                            htextTag.create2Unit(
                                                                bigElf,
                                                                "-" ..
                                                                    game.rule.hz.wave ..
                                                                        " " ..
                                                                            game.bigElfTips[
                                                                                cj.GetRandomInt(1, #game.bigElfTips)
                                                                            ],
                                                                10.00,
                                                                "ff0000",
                                                                1,
                                                                1.1,
                                                                50.00
                                                            ),
                                                            "scale",
                                                            0,
                                                            0.05
                                                        )
                                                    end
                                                end
                                                hunit.del(cj.GetTriggerUnit(), 0)
                                            else
                                                cj.SetUnitUserData(cj.GetTriggerUnit(), uVal + 1)
                                                heffect.bindUnit(
                                                    "Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl",
                                                    cj.GetTriggerUnit(),
                                                    "origin",
                                                    2
                                                )
                                                local next = getNextRect(k)
                                                if (next ~= -1) then
                                                    cj.SetUnitPosition(
                                                        cj.GetTriggerUnit(),
                                                        game.pathPoint[next][1][1],
                                                        game.pathPoint[next][1][2]
                                                    )
                                                end
                                            end
                                        else
                                            -- 前段路途
                                            cj.IssuePointOrderById(
                                                cj.GetTriggerUnit(),
                                                851986,
                                                v[i + 1][1],
                                                v[i + 1][2]
                                            )
                                        end
                                    end
                                end
                            )
                        end
                    end
                    enemyGenHZ(10)
                    hleaderBoard.create(
                        "hz",
                        1,
                        function(bl)
                            local bigElfLife = "GG"
                            if (his.alive(bigElf)) then
                                bigElfLife =
                                    hColor.white(math.floor(hunit.getCurLife(bigElf))) ..
                                    "/" .. math.floor(hunit.getMaxLife(bigElf))
                            end
                            hleaderBoard.setTitle(bl, "无尽战力榜[" .. game.rule.hz.wave .. "波][城主 " .. bigElfLife .. "]")
                            local data = {}
                            hplayer.loop(
                                function(p, pi)
                                    data[pi] = math.floor(0.3 * hplayer.getKill(p))
                                end
                            )
                            return data
                        end
                    )
                elseif (btnIdx == "有趣对抗" or "有趣对抗(AI模式)") then
                    game.rule.cur = "dk"
                    if (btnIdx == "有趣对抗(AI模式)") then
                        game.rule.dk.ai = true
                        hmsg.echo("|cffffff00各玩家独立出怪升级，阶段升级时会在你的下家（顺时针方向）创建与兵塔相关的士兵攻击该玩家，对抗不过的玩家会被扣血直至出局[AI模式]|r")
                    else
                        hmsg.echo("|cffffff00各玩家独立出怪升级，阶段升级时会在你的下家（顺时针方向）创建与兵塔相关的士兵攻击该玩家，对抗不过的玩家会被扣血直至出局|r")
                    end
                    hsound.bgm(cg.gg_snd_bgm_dk, nil)
                    -- 构建出怪区域
                    for k, v in ipairs(game.pathPoint) do
                        for i, p in ipairs(v) do
                            local r = hrect.create(p[1], p[2], 100, 100, "rect" .. k .. i)
                            local tg = cj.CreateTrigger()
                            bj.TriggerRegisterEnterRectSimple(tg, r)
                            cj.TriggerAddAction(
                                tg,
                                function()
                                    local u = cj.GetTriggerUnit()
                                    if (his.enemyPlayer(u, game.ALLY_PLAYER)) then
                                        local playerIndex = hunit.getUserData(u)
                                        if (i == #v) then
                                            local slk = hunit.getSlk(u)
                                            local type = slk.TYPE
                                            -- 最后一格,前往下一区域
                                            local next = getNextRect(k)
                                            if (next ~= -1) then
                                                if (type == "tower_shadow") then
                                                    if (next == playerIndex) then
                                                        hunit.del(u, 2)
                                                        hsound.sound(cg.gg_snd_wb)
                                                        hmsg.echo(
                                                            hColor.green(cj.GetPlayerName(hplayer.players[playerIndex])) ..
                                                                hColor.yellow("实现了一轮完美进攻！！完爆其他玩家！！牛逼！！！")
                                                        )
                                                    else
                                                        cj.SetUnitPosition(
                                                            u,
                                                            game.pathPoint[next][1][1],
                                                            game.pathPoint[next][1][2]
                                                        )
                                                    end
                                                    if
                                                        (hplayer.getStatus(hplayer.players[k]) ==
                                                            hplayer.player_status.gaming)
                                                     then
                                                        local hunt = game.rule.dk.wave[playerIndex]
                                                        if (hunt >= hunit.getCurLife(game.playerTower[k])) then
                                                            hunit.kill(game.playerTower[k], 0)
                                                            hmsg.echo(
                                                                hColor.sky(cj.GetPlayerName(hplayer.players[k])) ..
                                                                    "被" ..
                                                                        hColor.sky(
                                                                            cj.GetPlayerName(
                                                                                hplayer.players[playerIndex]
                                                                            )
                                                                        ) ..
                                                                            "的" ..
                                                                                hColor.yellow(slk.Name) .. "进攻，直接战败了~"
                                                            )
                                                        else
                                                            hunit.subCurLife(game.playerTower[k], hunt)
                                                            hmsg.echo(
                                                                hColor.sky(cj.GetPlayerName(hplayer.players[k])) ..
                                                                    "被" ..
                                                                        hColor.sky(
                                                                            cj.GetPlayerName(
                                                                                hplayer.players[playerIndex]
                                                                            )
                                                                        ) ..
                                                                            "的" ..
                                                                                hColor.yellow(slk.Name) ..
                                                                                    "进攻，扣了" .. hColor.red(hunt) .. "血"
                                                            )
                                                            heffect.toUnit(
                                                                "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl",
                                                                game.playerTower[k],
                                                                1
                                                            )
                                                            htextTag.style(
                                                                htextTag.create2Unit(
                                                                    game.playerTower[k],
                                                                    "-" .. hunt,
                                                                    10.00,
                                                                    "ff0000",
                                                                    1,
                                                                    1.1,
                                                                    50.00
                                                                ),
                                                                "scale",
                                                                0,
                                                                0.05
                                                            )
                                                        end
                                                    end
                                                else
                                                    cj.SetUnitPosition(
                                                        u,
                                                        game.pathPoint[next][1][1],
                                                        game.pathPoint[next][1][2]
                                                    )
                                                end
                                            end
                                        else
                                            -- 前段路途
                                            cj.IssuePointOrderById(
                                                cj.GetTriggerUnit(),
                                                851986,
                                                v[i + 1][1],
                                                v[i + 1][2]
                                            )
                                        end
                                    end
                                end
                            )
                        end
                    end
                    enemyGenDK(30)
                    local bldk =
                        hleaderBoard.create(
                        "dk",
                        1,
                        function(bl)
                            local data = {}
                            hplayer.loop(
                                function(p, pi)
                                    data[pi] = game.rule.dk.wave[pi] or 0
                                end
                            )
                            return data
                        end
                    )
                    hleaderBoard.setTitle(bldk, "有趣对抗战绩榜")
                end
                -- 基本信使
                for k, v in pairs(game.courierPoint) do
                    local u
                    if (game.rule.dk.ai == true and his.playing(hplayer.players[k]) == false) then
                        u = createMyCourier(k, game.courier["涅磐火凤凰"].UNIT_ID)
                        cj.SetPlayerName(hplayer.players[k], "AI#" .. k)
                        hplayer.setStatus(hplayer.players[k], hplayer.player_status.gaming)
                    else
                        u = createMyCourier(k, game.courier["呆萌的青蛙"].UNIT_ID)
                        if (u ~= nil and hdzapi.hasMallItem(hplayer.players[k], "phoenix") == true) then
                            hitem.create(
                                {
                                    itemId = game.courierItem["涅磐火凤凰"].ITEM_ID,
                                    whichUnit = u
                                }
                            )
                        end
                        if (u ~= nil and hdzapi.hasMallItem(hplayer.players[k], "icemon") == true) then
                            hitem.create(
                                {
                                    itemId = game.courierItem["冰戟剑灵"].ITEM_ID,
                                    whichUnit = u
                                }
                            )
                        end
                        if (u ~= nil) then
                            hitem.create(
                                {
                                    itemId = game.effectModelItem["超次元套装礼包"].ITEM_ID,
                                    whichUnit = u
                                }
                            )
                        end
                    end
                end
                -- 基本兵塔
                for k, v in pairs(game.towerPoint) do
                    createMyTower(k, game.towers["人类·农民_1"].UNIT_ID)
                    addTowerSkillsRaceTeam(k)
                end
                -- 兵塔连接
                for k, v in pairs(game.towerLinkOffset) do
                    for i = 1, 4 do
                        createMyTowerLink(k, i)
                    end
                end
                -- 商店
                for _, v in pairs(game.medicineShopPoint) do
                    hunit.create(
                        {
                            whichPlayer = game.ALLY_PLAYER,
                            unitId = game.shops["药商"].UNIT_ID,
                            qty = 1,
                            x = v[1],
                            y = v[2]
                        }
                    )
                end
                hunit.create(
                    {
                        whichPlayer = game.ALLY_PLAYER,
                        unitId = game.shops["猎人之店"].UNIT_ID,
                        qty = 1,
                        x = -256,
                        y = 256
                    }
                )
                hunit.create(
                    {
                        whichPlayer = game.ALLY_PLAYER,
                        unitId = game.shops["信使之笼"].UNIT_ID,
                        qty = 1,
                        x = 256,
                        y = 256
                    }
                )
                --创建多面板
                hmultiBoard.create(
                    "player",
                    0.75,
                    function(mb, curPi)
                        --拼凑多面板数据，二维数组，行列模式
                        hmultiBoard.setTitle(mb, "玩家兵塔属性列表，地上怪物：" .. game.currentMon .. "只")
                        --开始当然是title了
                        local data = {}
                        local titData = {
                            {value = "大佬", icon = "ReplaceableTextures\\CommandButtons\\BTNRiderlessHorse.blp"},
                            {value = "称号", icon = "ReplaceableTextures\\CommandButtons\\BTNDivineIntervention.blp"},
                            {value = "状态", icon = "ReplaceableTextures\\CommandButtons\\BTNWellSpring.blp"},
                            {value = "兵塔", icon = "ReplaceableTextures\\CommandButtons\\BTNHumanBarracks.blp"},
                            {value = "等级", icon = "ReplaceableTextures\\CommandButtons\\BTNAltarOfKings.blp"},
                            {value = "天赋", icon = "ReplaceableTextures\\CommandButtons\\BTNDivineIntervention.blp"},
                            {value = "物攻", icon = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp"},
                            {value = "魔攻", icon = "ReplaceableTextures\\CommandButtons\\BTNArcaniteMelee.blp"},
                            {
                                value = "攻速",
                                icon = "ReplaceableTextures\\CommandButtons\\BTNImprovedUnholyStrength.blp"
                            },
                            {value = "增幅", icon = "ReplaceableTextures\\CommandButtons\\BTNControlMagic.blp"}
                        }
                        if (game.rule.cur == "dk") then
                            titData =
                                table.merge(
                                titData,
                                {
                                    {value = "护甲", icon = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"},
                                    {
                                        value = "减伤",
                                        icon = "ReplaceableTextures\\CommandButtons\\BTNStoneArchitecture.blp"
                                    },
                                    {
                                        value = "魔抗",
                                        icon = "ReplaceableTextures\\CommandButtons\\BTNSorceressMaster.blp"
                                    },
                                    {
                                        value = "反伤",
                                        icon = "ReplaceableTextures\\CommandButtons\\BTNDefend.blp"
                                    },
                                    {value = "回避", icon = "ReplaceableTextures\\CommandButtons\\BTNEnchantedCrows.blp"}
                                }
                            )
                        end
                        table.insert(data, titData)
                        --然后是form
                        for pi = 1, hplayer.qty_max, 1 do
                            local p = hplayer.players[pi]
                            if (his.playing(p) or game.rule.dk.ai == true) then
                                local tower = game.playerTower[pi]
                                local avatar = hunit.getAvatar(tower)
                                local name = hunit.getName(tower)
                                local attack_white = math.floor(hattr.get(tower, "attack_white"))
                                local attack_green = math.floor(hattr.get(tower, "attack_green"))
                                local attack_speed = math.round(hattr.get(tower, "attack_speed")) .. "%"
                                local damage_extent = math.round(hattr.get(tower, "damage_extent")) .. "%"
                                local tempData = {
                                    {value = cj.GetPlayerName(p), icon = nil},
                                    {value = hplayer.getPrestige(p), icon = nil},
                                    {value = hplayer.getStatus(p), icon = nil},
                                    {value = name, icon = avatar},
                                    {value = "Lv." .. hhero.getCurLevel(tower), icon = nil},
                                    {value = game.playerTowerLevel[pi], icon = nil},
                                    {value = attack_white, icon = nil},
                                    {value = attack_green, icon = nil},
                                    {value = attack_speed, icon = nil},
                                    {value = damage_extent, icon = nil}
                                }
                                if (game.rule.cur == "dk") then
                                    local defend = math.floor(hattr.get(tower, "defend"))
                                    local toughness = math.round(hattr.get(tower, "toughness"))
                                    local resistance = math.round(hattr.get(tower, "resistance")) .. "%"
                                    local damage_rebound = math.round(hattr.get(tower, "damage_rebound")) .. "%"
                                    local avoid = math.round(hattr.get(tower, "avoid")) .. "%"
                                    tempData =
                                        table.merge(
                                        tempData,
                                        {
                                            {value = defend, icon = nil},
                                            {value = toughness, icon = nil},
                                            {value = resistance, icon = nil},
                                            {value = damage_rebound, icon = nil},
                                            {value = avoid, icon = nil}
                                        }
                                    )
                                end
                                table.insert(data, tempData)
                            end
                        end
                        return data
                    end
                )
            end
        )
    end
)
