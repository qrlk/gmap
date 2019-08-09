script_name("E.D.I.T.H.")
script_author("Anthony Edward Stark")
script_version("alfa-6")
script_description("E.D.I.T.H. ��� �� �.�.�.�. (� �����������: Even in Death, I'm The Hero: ���� � ������ � �����) - ��� ���������������� ��������� ��� ���� ���� Stark Industries, ������� ������������� ������������ ������ ������ �� ���� ���� ��������� Stark Industries, � ����� ��������� ������ � ������ ��� ���������� ���������� ������� �������������������� ��������, ������������ ������������ ������ �� ���� ������ ���������� ����. ���� ��������� �����. ��������� � �������������� ����.")

local ip = 'ws://31.134.153.163:9128'
--local ip = 'http://localhost:8993'
local ad = {}
local copas = require 'copas'
local http = require 'copas.http'
local inspect = require "inspect"
local requests = require 'requests'--
local sampev = require 'lib.samp.events'
local websocket = require'websocket'
local client = websocket.client.copas({timeout = 2})

requests.http_socket, requests.https_socket = http, http
ATTACK_COLOR = 2865496064
DEFEN_COLOR = 2855877036
color = 0x7ef3fa


-- temp
--ATTACK_COLOR = 2868895268
--DEFEN_COLOR = 2852758528

current_nick = ""
checkafk = os.time()
wasafk = false
timeleft_type = 0
afk = {}
status0 = " "
status1 = " "
status2 = " "
check = false
offline = false
lasttime = 0
count = 0

local inicfg = require 'inicfg'

local key = require("vkeys")

local settings = inicfg.load({
  score =
  {
    posX = 23,
    posY = 426,
    size1 = 0.4,
    size2 = 2,
    key1 = 49,
    key2 = 50,
    enable = true,
    key3 = 51,
    key4 = 52,
    key5 = 53,
  },
  stats =
  {
    dmg = 0,
    kills = 0,
    deaths = 0,
  },
  usedrugs =
  {
    isactive = 1,
    sound = 1,
    txdtype = 1,
    --[Wait]
    cooldown = 60,
    --[DrugsPos]
    posX1 = 56,
    posY1 = 424,
    --[DrugsSize]
    size1 = 0.6,
    size2 = 1.2,
    --[DrugsStyle]
    style1 = 3,
    --[TimerPos]
    posX2 = 80,
    posY2 = 315,
    --[TimerSize]
    size3 = 0.4,
    size4 = 2,
    --[TimerStyle]
    style2 = 3,
    --[KEY]
    key = 88,
  },
}, 'score')


given = 0
k_given = 0

kills = 0
sendtype = 0
k_kills = 0
deaths = 0
waitforcapture = false
mode = false

-- made by FYP
function submenus_show(menu, caption, select_button, close_button, back_button)
  select_button, close_button, back_button = select_button or 'Select', close_button or 'Close', back_button or 'Back'
  prev_menus = {}
  function display(menu, id, caption)
    local string_list = {}
    for i, v in ipairs(menu) do
      table.insert(string_list, type(v.submenu) == 'table' and v.title .. '  >>' or v.title)
    end
    sampShowDialog(id, caption, table.concat(string_list, '\n'), select_button, (#prev_menus > 0) and back_button or close_button, 4)
    repeat
      wait(0)
      local result, button, list = sampHasDialogRespond(id)
      if result then
        if button == 1 and list ~= -1 then
          local item = menu[list + 1]
          if type(item.submenu) == 'table' then -- submenu
            table.insert(prev_menus, {menu = menu, caption = caption})
            if type(item.onclick) == 'function' then
              item.onclick(menu, list + 1, item.submenu)
            end
            return display(item.submenu, id + 1, item.submenu.title and item.submenu.title or item.title)
          elseif type(item.onclick) == 'function' then
            local result = item.onclick(menu, list + 1)
            if not result then return result end
            return display(menu, id, caption)
          end
        else -- if button == 0
          if #prev_menus > 0 then
            local prev_menu = prev_menus[#prev_menus]
            prev_menus[#prev_menus] = nil
            return display(prev_menu.menu, id - 1, prev_menu.caption)
          end
          return false
        end
      end
    until result
  end
  return display(menu, 31337, caption or menu.title)
end



function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  update("http://qrlk.me/dev/moonloader/!edith/stats.php", '['..string.upper(thisScript().name)..']: ', "http://qrlk.me/sampvk", "edithlog")
  asodkas, playerid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  playernick = sampGetPlayerNickname(playerid)
  serverip, serverport = sampGetCurrentServerAddress()

  intim = inicfg.load({
    usedrugs =
    {
      lasttime = 1,
      kolvo = "???",
    },
  }, 'EDITH\\'..serverip..'-'..playernick)
  if not doesFileExist(getGameDirectory().."\\moonloader\\config\\edith\\"..serverip.."-"..playernick..".ini") then
    inicfg.save(intim, 'EDITH\\'..serverip..'-'..playernick)
  end
  openchangelog("edithlog", "-")
  if sampGetCurrentServerAddress() ~= "46.39.225.193" and sampGetCurrentServerAddress() ~= "185.169.134.11" and sampGetCurrentServerAddress() ~= "176.32.37.37" then return end
  asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  licensenick = sampGetPlayerNickname(licenseid)
  sampRegisterChatCommand("bl", function() lua_thread.create(checkTab) end)
  sampRegisterChatCommand("bikerlist", function() lua_thread.create(checkTab) end)
  sampRegisterChatCommand("edith", function() lua_thread.create(function() updateMenu() submenus_show(mod_submenus_sa, '{348cb2}EDITH v'..thisScript().version, '�������', '�������', '�����') end) end)
  lua_thread.create(score)
  lua_thread.create(capturetimer)
  usedrugs = lua_thread.create(usedrugs)
  local connected, err = client:connect(ip, 'echo')
  if not connected then
    sampAddChatMessage("{7ef3fa}[EDITH]: {ff0000}�� �� ����� ���������� ����� �� ��������� ����������� ������. {7ef3fa}/edith - ���-�� ������������.", 0xff0000)
    sampAddChatMessage("{7ef3fa}[EDITH]: "..err, 0xff0000)
    offline = true
    wait(-1)
  else
    local ok = client:send(encodeJson({auth = licensenick}))
    if ok then
      local message, opcode = client:receive()
      if message then
        if message == "Granted!" then
          init()
          sampAddChatMessage("����� � ��������� �������� ����������� ������ �����������. ��� ������� ��������� � ������, ����.", 0x7ef3fa)
          sampAddChatMessage("E.D.I.T.H. "..thisScript().version.." � ����� �������. ��������� ����������: /edith. �������� ����, "..licensenick..".", 0x7ef3fa)
        else
          sampAddChatMessage("{7ef3fa}[EDITH]: {ff0000}� ��� ��� ������� � E.D.I.T.H. ���� ��������, ��� ��� ������, �������� �� ����.", 0xff0000)
          client:close()
          thisScript():unload()
          wait(1000)
        end
      else
        sampAddChatMessage("{7ef3fa}[EDITH]: {ff0000}������ ���������� �� ��������� ����������� ������.", 0xff0000)
        client:close()
        thisScript():unload()
        wait(1000)
      end
    else
      sampAddChatMessage("{7ef3fa}[EDITH]: {ff0000}������ ���������� �� ��������� ����������� ������.", 0xff0000)
      client:close()
      thisScript():unload()
      wait(1000)
    end
  end

  a = getCharHeading(playerPed)
  lua_thread.create(
    function()
      while connected do
				wait(0)
        asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        licensenick = sampGetPlayerNickname(licenseid)
        data = {}
        if getActiveInterior() == 0 then
          x, y, z = getCharCoordinates(playerPed)
          data["sender"] = {sender = licensenick, pos = {x = x, y = y, z = z}, heading = getCharHeading(playerPed), health = getCharHealth(playerPed)}
        end
        data["vehicles"] = nil
        getCar(199)
        getCar(200)
        getCar(201)
        getCar(202)
        getCar(203)
        getCar(204)
        getCar(205)
        getCar(506)
        getCar(196)
        --  getCar(330)
        a = os.clock()
        if waitforcapture then
          data["timeleft_type"] = sendtype
          waitforcapture = false
        end
        local ok = client:send(encodeJson(data))
        if ok then
          message1, opcode = client:receive()
          if message1 then
            offline = false
            ad = decodeJson(message1)
						print(os.clock())
            if ad["capture"]["time"] ~= nil then
              if timeleft_type ~= ad["capture"]["type"] or ad["capture"]["type"] == 2 then
                timeleft_type = ad["capture"]["type"]
                timeleft_base = math.floor(ad["capture"]["time"] + math.floor(os.time() - ad["timestamp"]))
              end
            end
          else
            print("�� ������")
            offline = true
          end
        else
          print('connection closed')
          offline = true
        end
      end
    end
  )

  while true do
    wait(0)

    x, y = getCharCoordinates(playerPed)
    if isKeyDown(77) and not sampIsChatInputActive() then
      renderDrawTexture(map, bX, bY, size, size, 0, - 1)
      --renderDrawTexture(matavoz, getX(0), getY(0), 16, 16, 0, - 1)
      renderDrawTexture(player, getX(x), getY(y), 16, 16, - getCharHeading(playerPed), - 1)
      if ad ~= nil then
        for k, v in pairs(ad) do
          if k == "nicks" then
            for z, v1 in pairs(v) do
              if z ~= licensenick then
                --������
                if ad["timestamp"] - v1["timestamp"] < 300 then
                  renderFontDrawText(font, v1["health"], getX(v1["x"]) + 12, getY(v1["y"]) + 2, 0xFF00FF00)
                  n1, n2 = string.match(z, "(.).+_(.).+")
                  if n1 and n2 then
                    renderFontDrawText(font, n1..n2, getX(v1["x"]) - 12, getY(v1["y"]) + 2, 0xFF00FF00)
                  end
                  renderDrawTexture(player, getX(v1["x"]), getY(v1["y"]), 16, 16, - v1["heading"], - 1)
                end
              end
            end
          end


          if k == "vehicles" then
            for z, v1 in pairs(v) do
              if ad["timestamp"] - v1["timestamp"] < 500 then
                if tonumber(z) == 506 then
                  color = 0xFFdedbd2
                else
                  color = 0xFF00FF00
                end

                if ad["timestamp"] - v1["timestamp"] > 3 then
                  renderFontDrawText(font, string.format("%.0f?", ad["timestamp"] - v1["timestamp"]), getX(v1["x"]) + 17, getY(v1["y"]) + 2, color)
                end

                if v1["health"] ~= nil then
                  if ad["timestamp"] - v1["healthstamp"] < 5 then
                    renderFontDrawText(font, v1["health"], getX(v1["x"]) - 25, getY(v1["y"]) + 2, color)
                  else
                    renderFontDrawText(font, v1["health"].."?", getX(v1["x"]) - 30, getY(v1["y"]) + 2, color)
                  end
                end
                renderDrawTexture(matavoz, getX(v1["x"]), getY(v1["y"]), 16, 16, - v1["heading"] + 90, - 1)
              end
            end
          end
        end
      end
    end
  end
end

function updateMenu()
  mod_submenus_sa = {
    {
      title = '���������� � �������',
      onclick = function()
        sampShowDialog(0, "{7ef3fa}/edith v."..thisScript().version.." - ����������� ������������.", "{00ff66}EDITH{ffffff} - ������ ������ ��� �������� ��� � ����� �������, ������ �� ������� ���������.\n\n{AAAAAA}������\n{00ff66}* ��������� - {ffffff}����� ������������ �� ����� ����� �������������� ����� ������.\n{00ff66}* ����������{ffffff} - ����� ���� �� ������� ��������.\n{00ff66}* EDISCORE - {ffffff}������� �����, ������ � ����, �������� � ���������������� ����� ������.\n{00ff66}* CAPTURETIMER - {ffffff}������ ����� � �������������� ����� ������� ����� ������.\n{00ff66}* ������ /usedrugs - {ffffff}������� ������ ��������, ���������� ������� � ��.\n\nP.S. ��������� ���������� � ������� ������� ������.", "����")
      end
    },
    {
      title = ' '
    },
    {
      title = '{AAAAAA}������'
    },
    {
      title = '{00ff66}���������',
      submenu = {
        {
          title = '���������� � ������',
          onclick = function()
            sampShowDialog(0, "{7ef3fa}/edith v."..thisScript().version.." - ���������� � ������ {00ff66}\"���������\"", "{00ff66}���������\n{ffffff}������ ������������ ��� �������� ������ ������������.\n���������� ���������� ����� ������ ����� ����� �������.\n���� ������ ����������, ������ �� ��������.\n\n{7ef3fa}M{ffffff} - ������� ����� �� ����� ���������� �������.\n\n�� ����� ����������:\n\n{7ef3fa}1. ���� ���������� � �����������.\n{7ef3fa}2. ���������� ������ ������.{ffffff}\n   *����� �� ����� 2 ����� - ��������.\n   *������ �� ����� - HP.\n{7ef3fa}3. ��������:{ffffff}\n   *����������� ������ ����� ������� ���� � ���� ������.\n   */dl ����������� ��� ��������� <20�.\n   *����� �� ����� - hp ������.\n   *������ - ����� ��������� ��� ������.\n{7ef3fa}4. ���� SOS ���� �������� �� �����, �������� ����� ������.{ffffff}\n\n{FF0000}�����: {ffffff}������ � Alfa ������, ����� �������� �����������.\n", "����")
          end
        },
      }
    },
    {
      title = '{00ff66}����������',
      submenu = {
        {
          title = '���������� � ������',
          onclick = function()
            sampShowDialog(0, "{7ef3fa}/edith v."..thisScript().version.." - ���������� � ������ {00ff66}\"����������\"", "{00ff66}����������{ffffff}\n�� ����� ������ ������ ������������� �������� ���������� ������.\n������ ��������� ��� � ������� ������ � �������� �����������.\n\n{7ef3fa}/bl(ist){ffffff} - ������� ����������.\n\n����������:\n* ������ ����������� ����� �� ������.\n* ����� ��������� ������� �� ��� � ��� �� �������.\n* ����� ���� ������, ����� ����� � ������� ������ �� ������� �����.", "����")
          end
        },
        {
          title = ' '
        },
        {
          title = '������� ����������',
          onclick = function()
            lua_thread.create(checkTab)
          end
        },
      }
    },
    {
      title = '{00ff66}CAPTURETIMER',
      submenu = {
        {
          title = '���������� � ������',
          onclick = function()
            sampShowDialog(0, "{7ef3fa}/edith v."..thisScript().version.." - ���������� � ������ {00ff66}\"CAPTURETIMER\"", "{00ff66}CAPTURETIMER{ffffff}\n������ ���������� ������ �� ����� ������ � ������ ������ ����.\n�������� ��� ����� ������, ��� � ���� �� �����.\n\n����������:\n* ������ ����� ���� ��������, ��� ��� ������ ���������� �� ��������� ������.\n* �������� ������� ��� ������������� � �������� �������.", "����")
          end
        },
      }
    },
    {
      title = '{00ff66}EDISCORE',
      submenu = {
        {
          title = '���������� � ������',
          onclick = function()
            sampShowDialog(0, "{7ef3fa}/edith v."..thisScript().version.." - ���������� � ������ {00ff66}\"EDISCORE\"", "{00ff66}EDISCORE{ffffff}\n������� ������� �����, ������ � ����, �������� � ���������������� ����� ������.\n��� ������ ���������, �� ������� �� ��������� ���������� ���� ���� �� �����.\n\n������� {7ef3fa}"..key.id_to_name(settings.score.key1).."{ffffff}, ����� �������� ���� ����.\n������� {7ef3fa}"..key.id_to_name(settings.score.key2).."{ffffff}, ����� �������� ��������.\n������� {7ef3fa}"..key.id_to_name(settings.score.key3).."{ffffff}, ����� �������� ������.\n������� {7ef3fa}"..key.id_to_name(settings.score.key4).."{ffffff}, ����� �������� ����������� ������� � �������.\n������� {7ef3fa}"..key.id_to_name(settings.score.key5).."{ffffff}, ����� ������� �����: �� ����� (�����) ��� �� �� ����� (�������).", "����")
          end
        },
        {
          title = '���������� ����������',
          onclick = function()
            sampShowDialog(0, "{7ef3fa}���� ����������", "{00ff66}�� �����:{ffffff}\n����: "..tostring(k_given).."\n�������: "..tostring(k_kills).."\n{00ff66}�� �����:{ffffff}\n����: "..tostring(given).."\n�������: "..tostring(kills).."\n�������: "..tostring(deaths).."\n"..string.format("K/D: %2.1f", kills / deaths).."\n{00ff66}�� �� �����:{ffffff}\n����: "..string.format("%2.1f", settings.stats.dmg).."\n�������: "..tostring(settings.stats.kills).."\n�������: "..tostring(settings.stats.deaths).."\n"..string.format("K/D: %2.1f", settings.stats.kills / settings.stats.deaths), "����")
          end
        },
        {
          title = ' '
        },
        {
          title = '���/���� ������: '..tostring(settings.score.enable),
          onclick = function()
            settings.score.enable = not settings.score.enable
            inicfg.save(settings, "score")
          end
        },
        {
          title = ' '
        },
        {
          title = '�������� �������',
          onclick = function()
            lua_thread.create(resetscore)
          end
        },
        {
          title = ' '
        },
        {
          title = '�������� ������� � ������',
          onclick = function()
            lua_thread.create(changepos)
          end
        },
        {
          title = '�������� ������� ���������',
          submenu = {
            {
              title = '�������� ���� ���� - {7ef3fa}'..key.id_to_name(settings.score.key1),
              onclick = function()
                lua_thread.create(changehotkey, 1)
              end
            },
            {
              title = '�������� �������� - {7ef3fa}'..key.id_to_name(settings.score.key2),
              onclick = function()
                lua_thread.create(changehotkey, 2)
              end
            },
            {
              title = '�������� ������ - {7ef3fa}'..key.id_to_name(settings.score.key3),
              onclick = function()
                lua_thread.create(changehotkey, 3)
              end
            },
            {
              title = '�������� K/D - {7ef3fa}'..key.id_to_name(settings.score.key4),
              onclick = function()
                lua_thread.create(changehotkey, 4)
              end
            },
            {
              title = '����� ������ (����� - �����, ������� - �� �����) - {7ef3fa}'..key.id_to_name(settings.score.key5),
              onclick = function()
                lua_thread.create(changehotkey, 5)
              end
            },
          },
          {
            title = '[4] ������������ ��������� ���������',
            onclick = function()
              cmdDrugsTxdDefault()
            end
          }
        },
      }
    },
    {
      title = '{00ff66}������ /usedrugs',
      submenu = {
        {
          title = '��������/��������� ������',
          onclick = function()
            lua_thread.create(cmdChangeUsedrugsActive)
          end
        },
        {
          title = ' '
        },
        {
          title = '�������� ������� �������',
          onclick = function()
            lua_thread.create(cmdChangeDrugsHotkey)
          end
        },
        {
          title = '�������� �������� �����',
          onclick = function()
            lua_thread.create(cmdChangeUsedrugsDelay)
          end
        },
        {
          title = '��������/��������� �����',
          onclick = function()
            cmdChangeUsedrugsSoundActive()
          end
        },
        {
          title = ' '
        },
        {
          title = '{AAAAAA}��������� TextDraw'
        },
        {
          title = '��������� "Drugs"',
          submenu = {
            {
              title = '[0] �������� ����� ���������� "Drugs"',
              submenu = {
                {
                  title = '[0] ������� ��� ������� - "Drugs"',
                  onclick = function()
                    cmdChangeDrugsTxdType(0)
                  end
                },
                {
                  title = '[1] ������� ��� ������� - "Drugs 150"',
                  onclick = function()
                    cmdChangeDrugsTxdType(1)
                  end
                },
                {
                  title = '[2] ������� ��� ������� - "150"',
                  onclick = function()
                    cmdChangeDrugsTxdType(2)
                  end
                },
              },
            },
            {
              title = '[1] �������� ����� "Drugs"',
              submenu = {
                {
                  title = '[0] "The San Andreas Font"',
                  onclick = function()
                    cmdChangeDrugsTxdStyle(0)
                  end
                },
                {
                  title = '[1] "Both case characters"',
                  onclick = function()
                    cmdChangeDrugsTxdStyle(1)
                  end
                },
                {
                  title = '[2] "Only capital letters"',
                  onclick = function()
                    cmdChangeDrugsTxdStyle(2)
                  end
                },
                {
                  title = '[3] "�����������"',
                  onclick = function()
                    cmdChangeDrugsTxdStyle(3)
                  end
                },
              },
              {
                title = '[4] ������������ ��������� ���������',
                onclick = function()
                  cmdDrugsTxdDefault()
                end
              }
            },
            {
              title = '[2] �������� ��������� � ������ "Drugs"',
              submenu = {
                {
                  title = '[0] �������� ��������� � ������ "Drugs"',
                  onclick = function()
                    cmdChangeDrugsPos(0)
                  end
                },
                {
                  title = '[1] ������������ ��������� ���������',
                  onclick = function()
                    cmdChangeDrugsPos(1)
                  end
                }
              },
            },
          }
        },
        {
          title = '��������� "DrugsTimer"',
          submenu = {
            {
              title = '[0] �������� ����� "DrugsTimer"',
              submenu = {
                {
                  title = '[0] "The San Andreas Font"',
                  onclick = function()
                    cmdChangeDrugsTimerTxdStyle(0)
                  end
                },
                {
                  title = '[1] "Both case characters"',
                  onclick = function()
                    cmdChangeDrugsTimerTxdStyle(1)
                  end
                },
                {
                  title = '[2] "Only capital letters"',
                  onclick = function()
                    cmdChangeDrugsTimerTxdStyle(2)
                  end
                },
                {
                  title = '[3] "�����������"',
                  onclick = function()
                    cmdChangeDrugsTimerTxdStyle(3)
                  end
                },
              },
            },
            {
              title = '[1] �������� ��������� � ������ "DrugsTimer"',
              submenu = {
                {
                  title = '[0] �������� ��������� � ������ "DrugsTimer"',
                  onclick = function()
                    cmdChangeDrugsTimerPos(0)
                  end
                },
                {
                  title = '[1] ������������ ��������� ���������',
                  onclick = function()
                    cmdChangeDrugsTimerPos(1)
                  end
                }
              },
            },
            {
              title = '[2] ������������ ��������� ���������',
              onclick = function()
                cmdDrugsTimerDefault()
              end
            }
          }
        },
        {
          title = '������������ ��������� ���������',
          onclick = function()
            cmdDrugsTxdDefault()
            cmdDrugsTimerDefault()
          end
        }
      }
    },
  }
end


function getCar(id)
  if data["vehicles"] == nil then data["vehicles"] = {} end
  result, car = sampGetCarHandleBySampVehicleId(id)
  if result then
    b1, b2, b3 = getCarCoordinates(car)
    a1, a2, a3 = getActiveCameraCoordinates()
    if isCarOnScreen(car) and not processLineOfSight(a1, a2, a3, b1, b2, b3) then
      local x, y, z = getCarCoordinates(car)
      local angle = getCarHeading(car)
      local engine = isCarEngineOn(car)
      if getDistanceBetweenCoords3d(a1, a2, a3, b1, b2, b3) <= 20 then
        local health = getCarHealth(car)
        table.insert(data["vehicles"], {id = id, pos = {x = x, y = y, z = z}, heading = angle, health = health, engine = engine})
      else
        table.insert(data["vehicles"], {id = id, pos = {x = x, y = y, z = z}, heading = angle, engine = engine})
      end
    end
  end
end

function getX(x)
  x = math.floor(x + 3000)
  return bX + x * (size / 6000) - 8
end

function getY(y)
  y = math.floor(y * - 1 + 3000)
  return bY + y * (size / 6000) - 8
end

function dn(nam)
  file = getGameDirectory().."\\moonloader\\resource\\edith\\"..nam
  if not doesFileExist(file) then
    downloadUrlToFile("http://qrlk.me/dev/moonloader/!edith/resource/"..nam, file)
  end
end

function init()
  if not doesDirectoryExist(getGameDirectory().."\\moonloader\\resource") then
    createDirectory(getGameDirectory().."\\moonloader\\resource")
  end
  if not doesDirectoryExist(getGameDirectory().."\\moonloader\\resource\\edith") then
    createDirectory(getGameDirectory().."\\moonloader\\resource\\edith")
  end
  dn("map1024.png")
  dn("map720.png")
  dn("map512.png")
  dn("matavoz.png")
  dn("pla.png")
  player = renderLoadTextureFromFile(getGameDirectory()..'/moonloader/resource/edith/pla.png')
  matavoz = renderLoadTextureFromFile(getGameDirectory()..'/moonloader/resource/edith/matavoz.png')
  font = renderCreateFont("Impact", 8, 4)
  resX, resY = getScreenResolution()
  if resX > 1024 and resY >= 1024 then
    bX = (resX - 1024) / 2
    bY = (resY - 1024) / 2
    size = 1024
    map = renderLoadTextureFromFile(getGameDirectory()..'/moonloader/resource/edith/map1024.png')
  elseif resX > 720 and resY >= 720 then
    bX = (resX - 720) / 2
    bY = (resY - 720) / 2
    size = 720
    map = renderLoadTextureFromFile(getGameDirectory()..'/moonloader/resource/edith/map720.png')
  else
    bX = (resX - 512) / 2
    bY = (resY - 512) / 2
    size = 512
    map = renderLoadTextureFromFile(getGameDirectory()..'/moonloader/resource/edith/map512.png')
  end
end
--------------------------------------------------------------------------------
--------------------------------������ ����������-------------------------------
--------------------------------------------------------------------------------
function usedrugs()
  if settings.usedrugs.isactive == 1 then
    if settings.usedrugs.txdtype == 0 then
      sampTextdrawCreate(617, "Drugs", settings.usedrugs.posX1, settings.usedrugs.posY1)
    end
    if settings.usedrugs.txdtype == 1 then
      sampTextdrawCreate(617, "Drugs "..intim.usedrugs.kolvo, settings.usedrugs.posX1, settings.usedrugs.posY1)
    end
    if settings.usedrugs.txdtype == 2 then
      sampTextdrawCreate(617, intim.usedrugs.kolvo, settings.usedrugs.posX1, settings.usedrugs.posY1)
    end
    if settings.score.enable then
      ust = lua_thread.create(usedrugstimer)
    end
    sampTextdrawSetStyle(617, settings.usedrugs.style1)
    sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 13447886)
    sampTextdrawSetOutlineColor(617, 1, - 16777216)
    narkotrigger = true
    while true do
      wait(0)
      if isKeyJustPressed(settings.usedrugs.key) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        if narkotrigger == true then
          if stopscan == nil then stopscan = 0 end
          kolvousedrugs = math.ceil((160 - getCharHealth(playerPed)) / 10)
          if kolvousedrugs == 0 then kolvousedrugs = 1 end
          if intim.usedrugs.kolvo ~= "???" and kolvousedrugs > tonumber(intim.usedrugs.kolvo) and tonumber(intim.usedrugs.kolvo) > 0 then kolvousedrugs = tonumber(intim.usedrugs.kolvo) end
          if kolvousedrugs == 16 then kolvousedrugs = 15 end
          if narkotrigger == true then sampSendChat("/usedrugs "..kolvousedrugs) end
        elseif isKeyDown(settings.usedrugs.key) then
          wait(200)
          if isKeyDown(settings.usedrugs.key) then
            sampSendChat("/usedrugs 1")
          end
        end
      end
    end
  end
end
function usedrugstimer()
  while true do
    wait(0)
    if narkotrigger == false then sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 65536 ) end
    while narkotrigger == false do
      wait(0)
      sampTextdrawCreate(618, intim.usedrugs.lasttime + settings.usedrugs.cooldown - os.time(), settings.usedrugs.posX2, settings.usedrugs.posY2)
      sampTextdrawSetStyle(618, settings.usedrugs.style2)
      sampTextdrawSetLetterSizeAndColor(618, settings.usedrugs.size3, settings.usedrugs.size4, - 13447886)
      sampTextdrawSetOutlineColor(618, 1, - 16777216)
      if intim.usedrugs.lasttime + settings.usedrugs.cooldown <= os.time() then
        sampTextdrawDelete(618)
        if settings.usedrugs.sound == 1 and isKeyDown(settings.usedrugs.key) == false then addOneOffSound(0.0, 0.0, 0.0, 1057) end
        sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 13447886)
        narkotrigger = true
      end
    end
  end
end
--------------------------------------------------------------------------------
---------------------------------CAPTURETIMER-----------------------------------
--------------------------------------------------------------------------------
function capturetimer()
  while true do
    wait(250)
    if os.time() - checkafk > 2 then
      wasafk = true
      lua_thread.create(function() wait(2000) wasafk = false end)
    end
    checkafk = os.time()
    if timeleft_type ~= 0 then
      if timeleft_type == 25 then
        timeleft = timeleft_base + 1500 - os.time()
      elseif timeleft_type == 10 then
        timeleft = timeleft_base + 600 - os.time()
      elseif timeleft_type == 2 then
        timeleft = timeleft_base + 120 - os.time()
      end
      if timeleft < 600 then
        timeleft_minute = math.floor(timeleft / 60)
        timeleft_seconds = timeleft % 60
        if timeleft_minute < 10 then timeleft_minute = "0"..timeleft_minute end
        if timeleft_seconds < 10 then timeleft_seconds = "0"..timeleft_seconds end
        sampTextdrawCreate(471, timeleft_minute..":"..timeleft_seconds, 588, 428)
        sampTextdrawSetStyle(471, 3)
        sampTextdrawSetLetterSizeAndColor(471, 0.5, 2, - 65536)
        sampTextdrawSetOutlineColor(471, 1, - 16777216)
      else
        timeleft_minute = math.floor(timeleft / 60)
        timeleft_seconds = timeleft % 60
        if timeleft_minute < 10 then timeleft_minute = "0"..timeleft_minute end
        if timeleft_seconds < 10 then timeleft_seconds = "0"..timeleft_seconds end
        sampTextdrawCreate(471, timeleft_minute..":"..timeleft_seconds, 588, 428)
        sampTextdrawSetStyle(471, 3)
        sampTextdrawSetLetterSizeAndColor(471, 0.5, 2, - 13447886)
        sampTextdrawSetOutlineColor(471, 1, - 16777216)
      end
    else
      if sampTextdrawIsExists(471) then
        sampTextdrawDelete(471)
      end
    end
  end
end
function sampev.onServerMessage(color, text)
  if string.find(text, "�������� ���������") then
    intim.usedrugs.lasttime = os.time()
    narkotrigger = false
    stopscan = nil
    inicfg.save(intim, 'EDITH\\'..serverip..'-'..playernick)
  end
  if string.find(text, "(� ��� ���� (%d+) �����)") then
    if string.match(text, "(%d+)", string.find(text, "(� ��� ���� (%d+) �����)")) ~= nil and string.match(text, "(%d+)", string.find(text, "(� ��� ���� (%d+) �����)")) ~= intim.usedrugs.kolvo then
      intim.usedrugs.kolvo = string.match(text, "(%d+)", string.find(text, "(� ��� ���� (%d+) �����)"))
      inicfg.save(intim, 'EDITH\\'..serverip..'-'..playernick)
      if settings.usedrugs.txdtype == 1 then
        sampTextdrawCreate(617, "Drugs "..intim.usedrugs.kolvo, settings.usedrugs.posX1, settings.usedrugs.posY1)
        sampTextdrawSetStyle(617, settings.usedrugs.style1)
        if os.time() < intim.usedrugs.lasttime + settings.usedrugs.cooldown then
          sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 65536 )
        else
          sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 13447886)
        end
        sampTextdrawSetOutlineColor(617, 1, - 16777216)
      end
      if settings.usedrugs.txdtype == 2 then
        sampTextdrawCreate(617, intim.usedrugs.kolvo, settings.usedrugs.posX1, settings.usedrugs.posY1)
        sampTextdrawSetStyle(617, settings.usedrugs.style1)
        if os.time() < intim.usedrugs.lasttime + settings.usedrugs.cooldown then
          sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 65536 )
        else
          sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 13447886)
        end
        sampTextdrawSetOutlineColor(617, 1, - 16777216)
      end
      text = nil
    end
  end
  if text == " �� ����� �� ����� �����" or text == " �� �������� � ���� �����" then
    intim.usedrugs.kolvo = "???"
    inicfg.save(intim, 'EDITH\\'..serverip..'-'..playernick)
    if settings.usedrugs.txdtype == 1 then
      sampTextdrawCreate(617, "Drugs "..intim.usedrugs.kolvo, settings.usedrugs.posX1, settings.usedrugs.posY1)
      sampTextdrawSetStyle(617, settings.usedrugs.style1)
      if os.time() < intim.usedrugs.lasttime + settings.usedrugs.cooldown then
        sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 65536 )
      else
        sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 13447886)
      end
      sampTextdrawSetOutlineColor(617, 1, - 16777216)
    end
    if settings.usedrugs.txdtype == 2 then
      sampTextdrawCreate(617, intim.usedrugs.kolvo, settings.usedrugs.posX1, settings.usedrugs.posY1)
      sampTextdrawSetStyle(617, settings.usedrugs.style1)
      if os.time() < intim.usedrugs.lasttime + settings.usedrugs.cooldown then
        sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 65536 )
      else
        sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 13447886)
      end
      sampTextdrawSetOutlineColor(617, 1, - 16777216)
    end
  end
  --������� � ���, �����, ������� �� ����.
  if not string.find(text, " �� ������ ", 1, true) and not string.find(text, " ����� �� ", 1, true) then trigger1 = true end
  if not string.find(text, " �����(�) � ��� ", 1, true) and not string.find(text, " ����� ", 1, true) then trigger2 = true end
  if ((string.find(text, "(( �������:", 1, true)) and not string.find(text, "����������", 1, true)) or string.find(text, "�� ������ 150 ����� ������������� ��������", 1, true) or (string.find(text, " �� ������ ", 1, true) and not string.find(text, "� ��� ����", 1, true) and string.find(text, " ����� �� ", 1, true) and trigger1 == true) or (string.find(text, " �����(�) � ��� ", 1, true) and string.find(text, " ����� ", 1, true) and trigger2 == true) then
    if string.match(text, "(%d+)") ~= nil or string.match(text, "(%d+)") then
      if string.find(text, " �� ������ ", 1, true) then intim.usedrugs.kolvo = intim.usedrugs.kolvo + string.match(text, "(%d+)") trigger1 = false
      elseif string.match(text, "(%d+)") ~= intim.usedrugs.kolvo and not string.find(text, " �����(�) � ��� ", 1, true) then intim.usedrugs.kolvo = string.match(text, "(%d+)") end
      if string.find(text, " �����(�) � ��� ", 1, true) and string.find(text, " ����� ", 1, true) then intim.usedrugs.kolvo = intim.usedrugs.kolvo - string.match(text, "(%d+)") trigger2 = false end
      inicfg.save(intim, 'EDITH\\'..serverip..'-'..playernick)
      if settings.usedrugs.txdtype == 1 then
        sampTextdrawCreate(617, "Drugs "..intim.usedrugs.kolvo, settings.usedrugs.posX1, settings.usedrugs.posY1)
        sampTextdrawSetStyle(617, settings.usedrugs.style1)
        if os.time() < intim.usedrugs.lasttime + settings.usedrugs.cooldown then
          sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 65536 )
        else
          sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 13447886)
        end
        sampTextdrawSetOutlineColor(617, 1, - 16777216)
      end
      if settings.usedrugs.txdtype == 2 then
        sampTextdrawCreate(617, intim.usedrugs.kolvo, settings.usedrugs.posX1, settings.usedrugs.posY1)
        sampTextdrawSetStyle(617, settings.usedrugs.style1)
        if os.time() < intim.usedrugs.lasttime + settings.usedrugs.cooldown then
          sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 65536 )
        else
          sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 13447886)
        end
        sampTextdrawSetOutlineColor(617, 1, - 16777216)
      end
    end
  end
  if string.find(text, "����� ����� 15 �����") then
    if not wasafk then
      lua_thread.create(function() waitforcapture = true sendtype = 25 end)
    end
    if offline and not wasafk then
      timeleft_type = 25
      timeleft_base = os.time()
    end
  end
  if string.find(text, "���� ��������") then
    if not wasafk then
      lua_thread.create(function() waitforcapture = true sendtype = 10 end)
    end
    if offline and not wasafk then
      timeleft_type = 10
      timeleft_base = os.time()
    end
  end
  if string.find(text, "��������� �� �������") then
    if not wasafk then
      lua_thread.create(function() waitforcapture = true sendtype = 2 end)
    end
    if offline and not wasafk then
      timeleft_type = 2
      timeleft_base = os.time()
    end
  end
  if string.find(text, "�� ���� �������") then
    if not wasafk then
      lua_thread.create(function() waitforcapture = true sendtype = 0 end)
    end
    if offline and not wasafk then
      timeleft_type = 0
      timeleft_base = os.time()
    end
  end
  if string.find(text, "�� ���� ��������") then
    if not wasafk then
      lua_thread.create(function() waitforcapture = true sendtype = 0 end)
    end
    if offline and not wasafk then
      timeleft_type = 0
      timeleft_base = os.time()
    end
  end
  --
  if check and color == -1 then
    if string.find(text, current_nick) ~= nil then
      if string.find(text, "AFK") == nil and string.find(text, "SLEEP") == nil then
        afk[current_nick] = "AWAKE"
      else
        afk[current_nick] = string.match(text, current_nick.." %[%d+%] %[LVL: %d+%] %[(.+)%]")
      end
      count = count + 1
      return false
    end
  end
end

--------------------------------------------------------------------------------
-------------------------------��������� ����������-----------------------------
--------------------------------------------------------------------------------
function cmdChangeDrugsHotkey()
  sampShowDialog(989, "��������� ������� �������", "������� \"����\", ����� ���� ������� ������ �������.\n��������� ����� ��������.", "����", "�������")
  while sampIsDialogActive(989) do wait(100) end
  local resultMain, buttonMain, typ = sampHasDialogRespond(988)
  if buttonMain == 1 then
    while ke1y == nil do
      wait(0)
      for i = 1, 200 do
        if isKeyDown(i) then
          settings.usedrugs.key = i
          sampAddChatMessage("����������� ����� ������� ������� - "..settings.usedrugs.key, color)
          inicfg.save(settings, "score") ke1y = 1 break
        end
      end
    end
  end
  ke1y = nil
end
function cmdDrugsTxdDefault()
  settings.usedrugs.style1 = 3
  settings.usedrugs.posX1 = 56
  settings.usedrugs.posY1 = 424
  settings.usedrugs.size1 = 0.6
  settings.usedrugs.size2 = 1.2
  inicfg.save(settings, "score")
  usedrugs:terminate()
  if narkotrigger == false then
    usedrugs:run()
    wait(100)
    narkotrigger = false
  else
    usedrugs:run()
  end
end
function cmdDrugsTimerDefault()
  settings.usedrugs.style2 = 3
  settings.usedrugs.posX2 = 80
  settings.usedrugs.posY2 = 315
  settings.usedrugs.size3 = 0.4
  settings.usedrugs.size4 = 2
  inicfg.save(settings, "score")
  usedrugs:terminate()
  if narkotrigger == false then
    usedrugs:run()
    wait(100)
    narkotrigger = false
  else
    usedrugs:run()
  end
end
function cleardrugstxds()
  sampTextdrawDelete(617)
  sampTextdrawDelete(618)
end
function cmdChangeUsedrugsDelay()
  sampShowDialog(989, "��������� �������� �����", string.format("������� �������� � ��������.\n������� ��������: "..settings.usedrugs.cooldown.." ���."), "�������", "�������", 1)
  while sampIsDialogActive() do wait(100) end
  if tonumber(sampGetCurrentDialogEditboxText(989)) ~= nil then
    settings.usedrugs.cooldown = tonumber(sampGetCurrentDialogEditboxText(989))
    inicfg.save(settings, "score")
  end
end
function cmdChangeUsedrugsActive()
  if settings.usedrugs.isactive == 1 then settings.usedrugs.isactive = 0 sampAddChatMessage('[EDITH]: ������ ����� �������������.', color) cleardrugstxds()
    usedrugs:terminate()
  else settings.usedrugs.isactive = 1 sampAddChatMessage('[EDITH]: ������ ����� �����������.', color)
    if narkotrigger == false then
      usedrugs:run()
      wait(100)
      narkotrigger = false
    else
      usedrugs:run()
    end
  end
  inicfg.save(settings, "score")
end
function cmdChangeUsedrugsSoundActive()
  if settings.usedrugs.sound == 1 then settings.usedrugs.sound = 0 sampAddChatMessage('[EDITH]: "�����" ��� ��������� �� ����� ��������.', color) else settings.usedrugs.sound = 1 sampAddChatMessage('[EDITH]: "�����" ��� ��������� �� ����� �������.', color)
  end
  inicfg.save(settings, "score")
end
function cmdChangeDrugsTxdType(param)
  local txdtype = tonumber(param)
  if txdtype == 0 then settings.usedrugs.txdtype = 0 end
  if txdtype == 1 then settings.usedrugs.txdtype = 1 end
  if txdtype == 2 then settings.usedrugs.txdtype = 2 end
  inicfg.save(settings, "score")
  usedrugs:terminate()
  if narkotrigger == false then
    usedrugs:run()
    wait(100)
    narkotrigger = false
  else
    usedrugs:run()
  end
end
function cmdChangeDrugsPos(param)
  local drugspostype = tonumber(param)
  if drugspostype == 0 then
    local bckpX1 = settings.usedrugs.posX1
    local bckpY1 = settings.usedrugs.posY1
    local bckpS1 = settings.usedrugs.size1
    local bckpS2 = settings.usedrugs.size2
    sampShowDialog(3838, "��������� ��������� � �������.", "{ffcc00}��������� ��������� textdraw.\n{ffffff}�������� ��������� ����� � ������� ������� �����.\n\n{ffcc00}��������� ������� textdraw.\n{ffffff}�������� ������ ��������������� ����� � ������� {00ccff}'-'{ffffff} � {00ccff}'+'{ffffff}.\n{ffffff}�������� ������ �� ����������� ����� � ������� {00ccff}'9'{ffffff} � {00ccff}'0'{ffffff}.\n{ffffff}�������� ������ �� ��������� ����� � ������� {00ccff}'7'{ffffff} � {00ccff}'8'{ffffff}.\n\n{ffcc00}��� ������� ���������?\n{ffffff}������� \"Enter\", ����� ������� ���������.\n������� ������, ����� �������� ���������.\n� ���� ����� ������������ ������.", "� �����")
    while sampIsDialogActive(3838) == true do wait(100) end
    while true do
      wait(0)
      if bckpY1 > 0 and bckpY1 < 480 and bckpX1 > 0 and bckpX1 < 640 then
        wait(0)
        if isKeyDown(40) and bckpY1 + 1 < 480 then bckpY1 = bckpY1 + 1 end
        if isKeyDown(38) and bckpY1 - 1 > 0 then bckpY1 = bckpY1 - 1 end
        if isKeyDown(37) and bckpX1 - 1 > 0 then bckpX1 = bckpX1 - 1 end
        if isKeyDown(39) and bckpX1 + 1 < 640 then bckpX1 = bckpX1 + 1 end
        if isKeyJustPressed(57) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
          end
        end
        if isKeyJustPressed(48) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
          end
        end

        if isKeyJustPressed(55) then
          if bckpS2 - 0.1 > 0 then
            bckpS2 = bckpS2 - 0.1
          end
        end
        if isKeyJustPressed(56) then
          if bckpS2 + 0.1 > 0 then
            bckpS2 = bckpS2 + 0.1
          end
        end
        if isKeyJustPressed(189) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
            bckpS2 = bckpS1 * 2
          end
        end
        if isKeyJustPressed(187) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
            bckpS2 = bckpS1 * 2
          end
        end
        if settings.usedrugs.isactive == 1 then
          if settings.usedrugs.txdtype == 0 then
            sampTextdrawCreate(617, "Drugs", bckpX1, bckpY1)
          end
          if settings.usedrugs.txdtype == 1 then
            sampTextdrawCreate(617, "Drugs "..intim.usedrugs.kolvo, bckpX1, bckpY1)
          end
          if settings.usedrugs.txdtype == 2 then
            sampTextdrawCreate(617, intim.usedrugs.kolvo, bckpX1, bckpY1)
          end
          sampTextdrawSetStyle(617, settings.usedrugs.style1)
          sampTextdrawSetLetterSizeAndColor(617, bckpS1, bckpS2, - 13447886)
          sampTextdrawSetOutlineColor(617, 1, - 16777216)
        end
        if isKeyJustPressed(13) then
          settings.usedrugs.posX1 = bckpX1
          settings.usedrugs.posY1 = bckpY1
          settings.usedrugs.size1 = bckpS1
          settings.usedrugs.size2 = bckpS2
          addOneOffSound(0.0, 0.0, 0.0, 1052)
          inicfg.save(settings, "score")
          usedrugs:terminate()
          if narkotrigger == false then
            usedrugs:run()
            wait(100)
            narkotrigger = false
          else
            usedrugs:run()
          end
          break
        end
        if isKeyJustPressed(32) then
          addOneOffSound(0.0, 0.0, 0.0, 1053)
          usedrugs:terminate()
          if narkotrigger == false then
            usedrugs:run()
            wait(100)
            narkotrigger = false
          else
            usedrugs:run()
          end
          break
        end
      end
    end
  end
  if drugspostype == 1 then
    settings.usedrugs.posX1 = 56
    settings.usedrugs.posY1 = 424
    settings.usedrugs.size1 = 0.6
    settings.usedrugs.size2 = 1.2
    addOneOffSound(0.0, 0.0, 0.0, 1052)
    inicfg.save(settings, "score")
    usedrugs:terminate()
    if narkotrigger == false then
      usedrugs:run()
      wait(100)
      narkotrigger = false
    else
      usedrugs:run()
    end
  end
end
function cmdChangeDrugsTimerPos(param)
  local drugspostype = tonumber(param)
  if drugspostype == 0 then
    local bckpX1 = settings.usedrugs.posX2
    local bckpY1 = settings.usedrugs.posY2
    local bckpS1 = settings.usedrugs.size3
    local bckpS2 = settings.usedrugs.size4
    sampShowDialog(3838, "��������� ��������� � �������.", "{ffcc00}��������� ��������� textdraw.\n{ffffff}�������� ��������� ����� � ������� ������� �����.\n\n{ffcc00}��������� ������� textdraw.\n{ffffff}�������� ������ ��������������� ����� � ������� {00ccff}'-'{ffffff} � {00ccff}'+'{ffffff}.\n{ffffff}�������� ������ �� ����������� ����� � ������� {00ccff}'9'{ffffff} � {00ccff}'0'{ffffff}.\n{ffffff}�������� ������ �� ��������� ����� � ������� {00ccff}'7'{ffffff} � {00ccff}'8'{ffffff}.\n\n{ffcc00}��� ������� ���������?\n{ffffff}������� \"Enter\", ����� ������� ���������.\n������� ������, ����� �������� ���������.\n� ���� ����� ������������ ������.", "� �����")
    while sampIsDialogActive(3838) == true do wait(100) end
    while true do
      wait(0)
      if bckpY1 > 0 and bckpY1 < 480 and bckpX1 > 0 and bckpX1 < 640 then
        wait(0)
        if isKeyDown(40) and bckpY1 + 1 < 480 then bckpY1 = bckpY1 + 1 end
        if isKeyDown(38) and bckpY1 - 1 > 0 then bckpY1 = bckpY1 - 1 end
        if isKeyDown(37) and bckpX1 - 1 > 0 then bckpX1 = bckpX1 - 1 end
        if isKeyDown(39) and bckpX1 + 1 < 640 then bckpX1 = bckpX1 + 1 end
        if isKeyJustPressed(57) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
          end
        end
        if isKeyJustPressed(48) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
          end
        end
        if isKeyJustPressed(55) then
          if bckpS2 - 0.1 > 0 then
            bckpS2 = bckpS2 - 0.1
          end
        end
        if isKeyJustPressed(56) then
          if bckpS2 + 0.1 > 0 then
            bckpS2 = bckpS2 + 0.1
          end
        end
        if isKeyJustPressed(57) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
          end
        end
        if isKeyJustPressed(48) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
          end
        end
        if isKeyJustPressed(55) then
          if bckpS2 - 0.1 > 0 then
            bckpS2 = bckpS2 - 0.1
          end
        end
        if isKeyJustPressed(56) then
          if bckpS2 + 0.1 > 0 then
            bckpS2 = bckpS2 + 0.1
          end
        end
        if isKeyJustPressed(189) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
            bckpS2 = bckpS1 * 5
          end
        end
        if isKeyJustPressed(187) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
            bckpS2 = bckpS1 * 5
          end
        end
        if settings.usedrugs.isactive == 1 then
          sampTextdrawCreate(422, "69", bckpX1, bckpY1)
          sampTextdrawSetStyle(422, settings.usedrugs.style2)
          sampTextdrawSetLetterSizeAndColor(422, bckpS1, bckpS2, - 13447886)
          sampTextdrawSetOutlineColor(422, 1, - 16777216)
        end
        if isKeyJustPressed(13) then
          sampTextdrawDelete(422)
          if narkotrigger == false then sampTextdrawSetLetterSizeAndColor(617, settings.usedrugs.size1, settings.usedrugs.size2, - 65536 ) end
          settings.usedrugs.posX2 = bckpX1
          settings.usedrugs.posY2 = bckpY1
          settings.usedrugs.size3 = bckpS1
          settings.usedrugs.size4 = bckpS2
          addOneOffSound(0.0, 0.0, 0.0, 1052)
          inicfg.save(settings, "score")
          usedrugs:terminate()
          if narkotrigger == false then
            usedrugs:run()
            wait(100)
            narkotrigger = false
          else
            usedrugs:run()
          end
          break
        end
        if isKeyJustPressed(32) then
          sampTextdrawDelete(422)
          addOneOffSound(0.0, 0.0, 0.0, 1053)
          usedrugs:terminate()
          if narkotrigger == false then
            usedrugs:run()
            wait(100)
            narkotrigger = false
          else
            usedrugs:run()
          end
          break
        end
      end
    end
  end
  if drugspostype == 1 then
    sampTextdrawDelete(618)
    settings.usedrugs.posX2 = 80
    settings.usedrugs.posY2 = 315
    settings.usedrugs.size3 = 0.4
    settings.usedrugs.size4 = 2
    addOneOffSound(0.0, 0.0, 0.0, 1052)
    inicfg.save(settings, "score")
    usedrugs:terminate()
    if narkotrigger == false then
      usedrugs:run()
      wait(100)
      narkotrigger = false
    else
      usedrugs:run()
    end
  end
end
function cmdChangeDrugsTxdStyle(param)
  local txdstyle = tonumber(param)
  settings.usedrugs.style1 = txdstyle
  addOneOffSound(0.0, 0.0, 0.0, 1052)
  inicfg.save(settings, "score")
  usedrugs:terminate()
  if narkotrigger == false then
    usedrugs:run()
    wait(100)
    narkotrigger = false
  else
    usedrugs:run()
  end
end
function cmdChangeDrugsTimerTxdStyle(param)
  local txdstyle = tonumber(param)
  settings.usedrugs.style2 = txdstyle
  addOneOffSound(0.0, 0.0, 0.0, 1052)
  inicfg.save(settings, "score")
  usedrugs:terminate()
  if narkotrigger == false then
    usedrugs:run()
    wait(100)
    narkotrigger = false
  else
    usedrugs:run()
  end
end
--------------------------------------------------------------------------------
-------------------------------------SCORE--------------------------------------
--------------------------------------------------------------------------------
function score()
  if settings.score.enable then
    sampTextdrawCreate(440, "0", settings.score.posX, settings.score.posY)
    sampTextdrawSetStyle(440, 3)
    sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 1)
    sampTextdrawSetOutlineColor(440, 1, - 16777216)

    lua_thread.create(
      function()
        while true do
          wait(200)
          if isCharDead(PLAYER_PED) then
            if killer ~= nil and killer_id ~= nil and killer_w ~= nil and killer_b ~= nil and k_given ~= nil and k_kills ~= nil then
              sampAddChatMessage("{7ef3fa}[EDITH]:{ef3226} "..killer.."{808080}["..killer_id.."]{ffffff} ���� ��� �� {ef3226}"..getweaponname(killer_w).."{ffffff} ����� � {ef3226}"..getbodypart(killer_b)..".", - 1)
              sampAddChatMessage("{7ef3fa}[EDITH]: {ffffff}�� ����� �� ������� {ef3226}"..math.floor(k_given).."{ffffff} �����, � ��� {ef3226}"..k_kills.."{ffffff} "..getending(k_kills)..".", - 1)
            end
            k_given = 0
            k_kills = 0
            deaths = deaths + 1
            settings.stats.deaths = settings.stats.deaths + 1
            inicfg.save(settings, "score")
            while isCharDead(PLAYER_PED) ~= false do
              wait(200)
            end
          end
        end
      end
    )
    while true do
      wait(10)
      if isKeyDown(settings.score.key1) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        if mode then
          sampTextdrawSetString(440, string.format("%2.1f", settings.stats.dmg))
        else
          sampTextdrawSetString(440, string.format("%2.1f", given))
        end
      elseif isKeyDown(settings.score.key2) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        if mode then
          sampTextdrawSetString(440, string.format("K:%d", settings.stats.kills))
        else
          sampTextdrawSetString(440, string.format("K:%d", kills))
        end
      elseif isKeyDown(settings.score.key3) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        if mode then
          sampTextdrawSetString(440, string.format("D:%d", settings.stats.deaths))
        else
          sampTextdrawSetString(440, string.format("D:%d", deaths))
        end
      elseif isKeyDown(settings.score.key4) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        if mode then
          sampTextdrawSetString(440, string.format("K/D:%2.1f", settings.stats.kills / settings.stats.deaths))
        else
          sampTextdrawSetString(440, string.format("K/D:%2.1f", kills / deaths))
        end
      elseif wasKeyPressed(settings.score.key5) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        mode = not mode
        addOneOffSound(0.0, 0.0, 0.0, 1052)
        if mode then
          sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 65536)
        else
          sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 1)
        end
      else
        if mode then
          sampTextdrawSetString(440, string.format("%2.1f", k_given))
        else
          sampTextdrawSetString(440, string.format("%2.1f", k_given))
        end
      end
    end
  end
end

function getending(count)
  count = count % 10
  if count == 0 then
    return "�������"
  elseif count == 1 then
    return "��������"
  elseif count == 2 or count == 3 or count == 4 then
    return "��������"
  elseif count > 5 then
    return "�������"
  end
end

function sampev.onSendGiveDamage(playerID, damage, weaponID, bodypart)
  if sampIsPlayerConnected(playerID) then
    result, handle2 = sampGetCharHandleBySampPlayerId(playerID)
    if result then
      health = sampGetPlayerHealth(playerID)
      if health < damage or health == 0 then
        kills = kills + 1
        k_kills = k_kills + 1
        settings.stats.kills = settings.stats.kills + 1
        inicfg.save(settings, "score")
      end
    end
    k_given = k_given + damage
    given = given + damage
    settings.stats.dmg = settings.stats.dmg + damage
    inicfg.save(settings, "score")
  end
end

function sampev.onSendTakeDamage(playerID, damage, weaponID, bodypart)
  if sampIsPlayerConnected(playerID) then
    killer = sampGetPlayerNickname(playerID)
    killer_id = playerID
    killer_w = weaponID
    killer_b = bodypart
  end
end


function resetscore()
  settings.stats.dmg = 0
  settings.stats.kills = 0
  settings.stats.deaths = 0
  k_given = 0
  given = 0
  kills = 0
  k_kills = 0
  deaths = 0
  addOneOffSound(0.0, 0.0, 0.0, 1052)
  inicfg.save(settings, "score")
end

function changepos()
  local bckpX1 = settings.score.posX
  local bckpY1 = settings.score.posY
  local bckpS1 = settings.score.size1
  local bckpS2 = settings.score.size2
  sampShowDialog(3838, "��������� ��������� � �������.", "{ffcc00}��������� ��������� textdraw.\n{ffffff}�������� ��������� ����� � ������� ������� �����.\n\n{ffcc00}��������� ������� textdraw.\n{ffffff}�������� ������ ��������������� ����� � ������� {00ccff}'-'{ffffff} � {00ccff}'+'{ffffff}.\n{ffffff}�������� ������ �� ����������� ����� � ������� {00ccff}'9'{ffffff} � {00ccff}'0'{ffffff}.\n{ffffff}�������� ������ �� ��������� ����� � ������� {00ccff}'7'{ffffff} � {00ccff}'8'{ffffff}.\n\n{ffcc00}��� ������� ���������?\n{ffffff}������� \"Enter\", ����� ������� ���������.\n������� ������, ����� �������� ���������.\n� ���� ����� ������������ ������.", "� �����")
  while sampIsDialogActive(3838) == true do wait(100) end
  while true do
    wait(0)
    if bckpY1 > 0 and bckpY1 < 480 and bckpX1 > 0 and bckpX1 < 640 then
      wait(0)
      if isKeyDown(40) and bckpY1 + 1 < 480 then bckpY1 = bckpY1 + 1 end
      if isKeyDown(38) and bckpY1 - 1 > 0 then bckpY1 = bckpY1 - 1 end
      if isKeyDown(37) and bckpX1 - 1 > 0 then bckpX1 = bckpX1 - 1 end
      if isKeyDown(39) and bckpX1 + 1 < 640 then bckpX1 = bckpX1 + 1 end
      if isKeyJustPressed(57) then
        if bckpS1 - 0.1 > 0 then
          bckpS1 = bckpS1 - 0.1
        end
      end
      if isKeyJustPressed(48) then
        if bckpS1 + 0.1 > 0 then
          bckpS1 = bckpS1 + 0.1
        end
      end
      if isKeyJustPressed(55) then
        if bckpS2 - 0.1 > 0 then
          bckpS2 = bckpS2 - 0.1
        end
      end
      if isKeyJustPressed(56) then
        if bckpS2 + 0.1 > 0 then
          bckpS2 = bckpS2 + 0.1
        end
      end
      if isKeyJustPressed(57) then
        if bckpS1 - 0.1 > 0 then
          bckpS1 = bckpS1 - 0.1
        end
      end
      if isKeyJustPressed(48) then
        if bckpS1 + 0.1 > 0 then
          bckpS1 = bckpS1 + 0.1
        end
      end
      if isKeyJustPressed(55) then
        if bckpS2 - 0.1 > 0 then
          bckpS2 = bckpS2 - 0.1
        end
      end
      if isKeyJustPressed(56) then
        if bckpS2 + 0.1 > 0 then
          bckpS2 = bckpS2 + 0.1
        end
      end
      if isKeyJustPressed(189) then
        if bckpS1 - 0.1 > 0 then
          bckpS1 = bckpS1 - 0.1
          bckpS2 = bckpS1 * 5
        end
      end
      if isKeyJustPressed(187) then
        if bckpS1 + 0.1 > 0 then
          bckpS1 = bckpS1 + 0.1
          bckpS2 = bckpS1 * 5
        end
      end
      sampTextdrawCreate(422, "999", bckpX1, bckpY1)
      sampTextdrawSetStyle(422, 3)
      sampTextdrawSetLetterSizeAndColor(422, bckpS1, bckpS2, - 1)
      sampTextdrawSetOutlineColor(422, 1, - 16777216)
      if isKeyJustPressed(13) then
        sampTextdrawDelete(422)
        settings.score.posX = bckpX1
        settings.score.posY = bckpY1
        settings.score.size1 = bckpS1
        settings.score.size2 = bckpS2
        addOneOffSound(0.0, 0.0, 0.0, 1052)
        inicfg.save(settings, "score")
        sampTextdrawSetPos(440, settings.score.posX, settings.score.posY)
        sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 1)
        break
      end
      if isKeyJustPressed(32) then
        sampTextdrawDelete(422)
        addOneOffSound(0.0, 0.0, 0.0, 1053)
        break
      end
    end
  end
end

function changehotkey(mode)
  local modes =
  {
    [1] = " ��� ������ �� �� �����",
    [2] = " ��� �������",
    [3] = " ��� �������",
    [4] = " ��� k/d",
    [5] = " ��� ����� ������ �����/�� �����"
  }
  if tonumber(mode) == nil or tonumber(mode) < 1 or tonumber(mode) > 5 then
    sampAddChatMessage("1) ���������� ����� �� �����: "..key.id_to_name(settings.score.key1)..". 2) ���������� ��������: "..key.id_to_name(settings.score.key2)..". 3) ���������� ������: "..key.id_to_name(settings.score.key3)..". 4) k/d: "..key.id_to_name(settings.score.key4)..". 5) �����/�� �����: "..key.id_to_name(settings.score.key5)..".", - 1)
    sampAddChatMessage("��������: /ediscorekey [1|2|3|4|5]", - 1)
  else
    mode = tonumber(mode)
    sampShowDialog(989, "��������� ������� �������"..modes[mode], "������� \"����\", ����� ���� ������� ������ �������.\n��������� ����� ��������.", "����", "�������")
    while sampIsDialogActive(989) do wait(100) end
    local resultMain, buttonMain, typ = sampHasDialogRespond(988)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            if mode == 1 then
              settings.score.key1 = i
            end
            if mode == 2 then
              settings.score.key2 = i
            end
            if mode == 3 then
              settings.score.key3 = i
            end
            if mode == 4 then
              settings.score.key4 = i
            end
            if mode == 5 then
              settings.score.key5 = i
            end
            sampAddChatMessage("����������� ����� ������� ������� - "..key.id_to_name(i), - 1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "score")
            ke1y = 1
            break
          end
        end
      end
    end
    ke1y = nil
  end
end

function getbodypart(part)
  local names = {
    [3] = "����",
    [4] = "����",
    [5] = "����� ����",
    [6] = "������ ����",
    [7] = "����� ����",
    [8] = "������ ����",
    [9] = "������"
  }
  return names[part]
end

function getweaponname(weapon) -- getweaponname by FYP
  local names = {
    [0] = "������",
    [1] = "�������",
    [2] = "������ ��� ������",
    [3] = "����������� �������",
    [4] = "����",
    [5] = "����",
    [6] = "������",
    [7] = "���",
    [8] = "������",
    [9] = "���������",
    [10] = "�������� �����",
    [11] = "�����",
    [12] = "���������",
    [13] = "������������ ���������",
    [14] = "������",
    [15] = "������",
    [16] = "�������",
    [17] = "������������� ����",
    [18] = "�������� ��������",
    [22] = "���������",
    [23] = "��������� � ����������",
    [24] = "Deagle",
    [25] = "Shotgun",
    [26] = "������",
    [27] = "������� ���������",
    [28] = "Micro SMG/Uzi",
    [29] = "MP5",
    [30] = "AK-47",
    [31] = "M4",
    [32] = "Tec-9",
    [33] = "��������",
    [34] = "����������� ��������",
    [35] = "���",
    [36] = "HS Rocket",
    [37] = "�������",
    [38] = "��������",
    [39] = "Satchel Charge",
    [40] = "Detonator",
    [41] = "�������� ���������",
    [42] = "������������",
    [43] = "Camera",
    [44] = "Night Vis Goggles",
    [45] = "Thermal Goggles",
  [46] = "Parachute" }
  return names[weapon]
end
--------------------------------------------------------------------------------
-------------------------------------BLIST--------------------------------------
--------------------------------------------------------------------------------
function checkTab()
  bl_update()
  while sampIsDialogActive() and sampGetCurrentDialogId() == 4172 do
    wait(100)
    local result, button, list, input = sampHasDialogRespond(4172)
    if result then
      if button == 1 and list == 1 then
        number = sampGetCurrentDialogListItem()
        bl_update()
        sampSetCurrentDialogListItem(number)
        lua_thread.create(checkAfk)
      end
    end
    if sampIsDialogActive() and not sampIsChatInputActive() then
      number = sampGetCurrentDialogListItem()
      bl_update()
      sampSetCurrentDialogListItem(number)
    end
  end
end

function checkAfk()
  afk = {}
  check = true
  count = 0
  for k, v in pairs(attackers) do
    if sampIsPlayerConnected(v) then
      current_nick = sampGetPlayerNickname(v)
      status0 = tostring(count).."/"..tostring(#attackers + #defenders)
      status1 = "�������� "
      status2 = current_nick
      sampSendChat("/id "..v)
      wait(1500)
    end
  end
  for k, v in pairs(defenders) do
    if sampIsPlayerConnected(v) then
      current_nick = sampGetPlayerNickname(v)
      status0 = tostring(count).."/"..tostring(#attackers + #defenders)
      status1 = "�������� "
      status2 = current_nick
      sampSendChat("/id "..v)
      wait(1500)
    end
  end
  check = false
  status0 = " "
  status1 = " "
  status2 = " "
  lasttime = os.time()
end

function bl_update()
  attackers = {}
  defenders = {}
  _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  for i = 0, sampGetMaxPlayerId(false) do
    if sampIsPlayerConnected(i) or (_ and myid == i) then
      if sampGetPlayerColor(i) == ATTACK_COLOR then
        table.insert(attackers, i)
      elseif sampGetPlayerColor(i) == DEFEN_COLOR then
        table.insert(defenders, i)
      end
    end
  end
  text = ""
  text = text.."�\t� ����������\t���\tAFK\n"
  text = text.." \n"..status0.."\t"..status1.."\t"..status2.."\tcheck\n \t{DC143C}�����:\n"
  kolvo_a = 0
  for k, v in pairs(attackers) do
    text = text..string.format("{DC143C}%s\t%s\t{DC143C}%s\t{DC143C}%s\n", k, isStream(v), string.format("%s{808080}[%s]", sampGetPlayerNickname(v), v), getAfk(v))
    if isStream(v) == "{00FFFF}��" then
      kolvo_a = kolvo_a + 1
    end
  end
  text = text.." \t{1E90FF}������:\n"
  kolvo_d = 0
  for k, v in pairs(defenders) do
    text = text..string.format("{1E90FF}%s\t%s\t{1E90FF}%s\t{1E90FF}%s\n", k, isStream(v), string.format("%s{808080}[%s]", sampGetPlayerNickname(v), v), getAfk(v))
    if isStream(v) == "{00FFFF}��" then
      kolvo_d = kolvo_d + 1
    end
  end
  if lasttime == 0 then
    caption = "�������� �� ����."
  else
    caption = string.format("���� %u �. �����", os.time() - lasttime)
  end
  sampShowDialog(4172, string.format("{808080}[/bikerlist] {DC143C}�����: %u/%u. {1E90FF}������: %u/%u. %s", kolvo_a, #attackers, kolvo_d, #defenders, caption), text, string.format("{DC143C}%u.%u", kolvo_a, #attackers), string.format("{1E90FF}%u.%u", kolvo_d, #defenders), 5)
end

function getAfk(id)
  _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  if myid == id then
    return "N/A"
  elseif sampIsPlayerConnected(id) then
    if afk[sampGetPlayerNickname(id)] == nil then
      return "-"
    else
      return afk[sampGetPlayerNickname(id)]
    end
  end
end

function isStream(searchid)
  for k, PED in pairs(getAllChars()) do
    local res, id = sampGetPlayerIdByCharHandle(PED)
    if res then
      if sampIsPlayerConnected(id) and sampGetPlayerNickname(id) == sampGetPlayerNickname(searchid) then
        return "{00FFFF}��"
      end
    end
  end
  return "{808080}���"
end


--------------------------------------------------------------------------------
------------------------------------UPDATE--------------------------------------
--------------------------------------------------------------------------------
function update(php, prefix, url, komanda)
  komandaA = komanda
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  local ffi = require 'ffi'
  ffi.cdef[[
	int __stdcall GetVolumeInformationA(
			const char* lpRootPathName,
			char* lpVolumeNameBuffer,
			uint32_t nVolumeNameSize,
			uint32_t* lpVolumeSerialNumber,
			uint32_t* lpMaximumComponentLength,
			uint32_t* lpFileSystemFlags,
			char* lpFileSystemNameBuffer,
			uint32_t nFileSystemNameSize
	);
	]]
  local serial = ffi.new("unsigned long[1]", 0)
  ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
  serial = serial[0]
  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local nickname = sampGetPlayerNickname(myid)

  php = php..'?id='..serial..'&n='..nickname..'&i='..sampGetCurrentServerAddress()..'&v='..getMoonloaderVersion()..'&sv='..thisScript().version

  downloadUrlToFile(php, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            if info.changelog ~= nil then
              changelogurl = info.changelog
            end
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix, komanda)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'���������� ����������. ������� ���������� c '..thisScript().version..' �� '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('��������� %d �� %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('�������� ���������� ���������.')
                      if komandaA ~= nil then
                        sampAddChatMessage((prefix..'���������� ���������! ��������� �� ���������� - /'..komandaA..'.'), color)
                      end
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'���������� ������ ��������. �������� ���������� ������..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': ���������� �� ���������.')
            end
          end
        else
          print('v'..thisScript().version..': �� ���� ��������� ����������. ��������� ��� ��������� �������������� �� '..url)
          update = false
          return
        end
      end
    end
  )
  while update ~= false do wait(100) end
end

function openchangelog(komanda, url)
  sampRegisterChatCommand(komanda,
    function()
      lua_thread.create(
        function()
          if changelogurl == nil then
            changelogurl = url
          end
          sampShowDialog(222228, "{ff0000}���������� �� ����������", "{ffffff}"..thisScript().name.." {ffe600}������ � alfa ������.\n��� ������, ��� ��� �������� ����������.\n��������� ������� �����, ����� �� ���������...", "�������", "��������")
          --[[    sampShowDialog(222228, "{ff0000}���������� �� ����������", "{ffffff}"..thisScript().name.." {ffe600}���������� ������� ���� changelog ��� ���.\n���� �� ������� {ffffff}�������{ffe600}, ������ ���������� ������� ������:\n        {ffffff}"..changelogurl.."\n{ffe600}���� ���� ���� ���������, �� ������ ������� ��� ������ ����.", "�������", "��������")
          while sampIsDialogActive() do wait(100) end
          local result, button, list, input = sampHasDialogRespond(222228)
          if button == 1 then
            os.execute('explorer "'..changelogurl..'"')
          end]]
        end
      )
    end
  )
end
