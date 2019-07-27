script_name("E.D.I.T.H.")
script_author("Anthony Edward Stark")
script_version("alfa-1")
script_description("E.D.I.T.H. ��� �� �.�.�.�. (� �����������: Even in Death, I'm The Hero: ���� � ������ � �����) - ��� ���������������� ��������� ��� ���� ���� Stark Industries, ������� ������������� ������������ ������ ������ �� ���� ���� ��������� Stark Industries, � ����� ��������� ������ � ������ ��� ���������� ���������� ������� �������������������� ��������, ������������ ������������ ������ �� ���� ������ ���������� ����. ���� ��������� �����. ��������� � �������������� ����.")

local ip = 'http://31.134.153.163:8993'
local ip = 'http://localhost:8993'
local ad = {}
local copas = require 'copas'
local http = require 'copas.http'
local inspect = require "inspect"
local requests = require 'requests'
requests.http_socket, requests.https_socket = http, http
function httpRequest(method, request, args, handler) -- lua-requests
  -- start polling task
  if not copas.running then
    copas.running = true
    lua_thread.create(function()
      wait(0)
      while not copas.finished() do
        local ok, err = copas.step(0)
        if ok == nil then error(err) end
        wait(0)
      end
      copas.running = false
    end)
  end
  -- do request
  if handler then
    return copas.addthread(function(m, r, a, h)
      copas.setErrorHandler(function(err) h(nil, err) end)
      h(requests.request(m, r, a))
    end, method, request, args, handler)
  else
    local results
    local thread = copas.addthread(function(m, r, a)
      copas.setErrorHandler(function(err) results = {nil, err} end)
      results = table.pack(requests.request(m, r, a))
    end, method, request, args)
    while coroutine.status(thread) ~= 'dead' do wait(0) end
    return table.unpack(results)
  end
end



function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  update("http://qrlk.me/dev/moonloader/!edith/stats.php", '['..string.upper(thisScript().name)..']: ', "http://qrlk.me/sampvk", "edithlog")
  openchangelog("edithlog", "-")
  if sampGetCurrentServerAddress() ~= "46.39.225.193" and sampGetCurrentServerAddress() ~= "185.169.134.11" then return end
  asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  licensenick = sampGetPlayerNickname(licenseid)
  local response, err = httpRequest('GET', {ip, data = licensenick})
  if err then sampAddChatMessage("�� �� ����� ���������� ����� �� ���������� Stark Industries. ��������, ����.", - 1) return end
  if response.text == "Granted!" then
    init()
    sampAddChatMessage("����� � ��������� �������� Stark Industries �����������. ��� ������� ��������� � ������, ����.", - 1)
  else
    sampAddChatMessage("�� �� ����� ���������� ����� �� ���������� Stark Industries. ��������, ����.", - 1) return
  end
  sampAddChatMessage("E.D.I.T.H. "..thisScript().version.." � ����� �������. ��������� ����������: /edith. �������� ����, "..licensenick..".", - 1)
  sampRegisterChatCommand("edith", function() sampAddChatMessage("�������� � ��������") end)
  a = getCharHeading(playerPed)
  lua_thread.create(
    function()
      --print(inspect(data))
      a = true
      while a do
        wait(50)
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
        a = os.clock()
        local response, err = httpRequest('POST', {ip, data = encodeJson(data)})
        if err then print(err) end
        print("Request took: "..os.clock() - a)
        if response ~= nil then
          ad = decodeJson(response.text)
        end
        --a = false
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
                if os.time() - v1["timestamp"] < 300 then
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
              if os.time() - v1["timestamp"] < 60 then
                if tonumber(z) == 506 then
                  renderFontDrawText(font, v1["health"], getX(v1["x"]) + 17, getY(v1["y"]) + 2, 0xFFdedbd2)
                else
                  renderFontDrawText(font, v1["health"], getX(v1["x"]) + 17, getY(v1["y"]) + 2, 0xFF00FF00)
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

function getCar(id)
  if data["vehicles"] == nil then data["vehicles"] = {} end
  result, car = sampGetCarHandleBySampVehicleId(id)
  if result then
    local x, y, z = getCarCoordinates(car)
    local angle = getCarHeading(car)
    local engine = isCarEngineOn(car)
    local health = getCarHealth(car)
    table.insert(data["vehicles"], {id = id, pos = {x = x, y = y, z = z}, heading = angle, health = health, engine = engine})
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

function init()
  player = renderLoadTextureFromFile(getGameDirectory()..'/moonloader/resource/pla.png')
  matavoz = renderLoadTextureFromFile(getGameDirectory()..'/moonloader/resource/matavoz.png')
  font = renderCreateFont("Impact", 8, 4)
  resX, resY = getScreenResolution()
  if resX > 1024 and resY >= 1024 then
    bX = (resX - 1024) / 2
    bY = (resY - 1024) / 2
    size = 1024
    map = renderLoadTextureFromFile(getGameDirectory()..'/moonloader/resource/map1024.png')
  elseif resX > 720 and resY >= 720 then
    bX = (resX - 720) / 2
    bY = (resY - 720) / 2
    size = 720
    map = renderLoadTextureFromFile(getGameDirectory()..'/moonloader/resource/map720.png')
  else
    bX = (resX - 512) / 2
    bY = (resY - 512) / 2
    size = 512
    map = renderLoadTextureFromFile(getGameDirectory()..'/moonloader/resource/map512.png')
  end
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
