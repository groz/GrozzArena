local GrozzArena = { }
GrozzArena.eventHandler = CreateFrame("Frame")
GrozzArena.eventHandler.events = { }
GrozzArena.consoleCommands = {}
GrozzArena.hooksSet = false
GrozzArena.isBlizzardUIReady = false

----------------------------------------------------------------------------------------------------------
-- MAIN
----------------------------------------------------------------------------------------------------------
function GrozzArena.AddMacroToUpdate(macroName)
	GrozzArena.macrosToUpdate[macroName] = true
	print("Added macro "..macroName.." to update for arena targets")
end

function GrozzArena.RemoveMacroToUpdate(macroName)
	GrozzArena.macrosToUpdate[macroName] = nil
	print("Removed macro "..macroName.." from updates for arena targets")
end

function GrozzArena.UpdateArenaTargetInMacro(macroName, arenaTarget)
	local macroIndex = GetMacroIndexByName(macroName)
	
	if  macroIndex and macroIndex ~= 0 then
	
		local macroBody = GetMacroBody(macroIndex)
		local newMacroBody = macroBody:gsub("arena(%d+)", arenaTarget)
		
		EditMacro(macroIndex, macroName, nil, newMacroBody)
		
		print("Macro '"..macroName.."' retargeted to "..arenaTarget)
	else
		print("Macro '"..macroName.."' not found. Skipped updating.")
	end
end

function GrozzArena.ArenaFrameClickHandler(self, button)
	if button ~= "RightButton" then
		return
	end
	
	--local frameName = self:GetName()	
	local frameName = "ArenaEnemyFrame1"
	
	print("Clicked frame #"..frameName)
	
	local arenaNum = frameName:match("%d+")
	
	if arenaNum then
		for macroName,_ in pairs(GrozzArena.macrosToUpdate) do
			GrozzArena.UpdateArenaTargetInMacro(macroName, "arena"..arenaNum)
		end
	else
		print("Couldn't parse arenaNum in "..frameName)
	end
end

function GrozzArena.SetArenaHooks()
	if GrozzArena.hooksSet then return end
	
	for i = 1,5 do
		--local arenaFrameName = "PlayerFrame"
		local arenaFrameName = "ArenaEnemyFrame"..i
		local arenaFrame = _G[arenaFrameName]

		if (arenaFrame ~= nil) then
			print("Hooking "..arenaFrameName)
			arenaFrame:HookScript("OnClick", GrozzArena.ArenaFrameClickHandler)
		else
			print(arenaFrameName .. " not found")
		end
				
	end
	
	GrozzArena.hooksSet = true
end

----------------------------------------------------------------------------------------------------------
-- HOOKING EVENTS, MAIN ENTRY POINT
----------------------------------------------------------------------------------------------------------

GrozzArena.eventHandler:RegisterEvent("ADDON_LOADED")
GrozzArena.eventHandler:RegisterEvent("PLAYER_LOGIN")
GrozzArena.eventHandler:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

GrozzArena.eventHandler:SetScript("OnEvent", function(self, event, arg1, ...)
	if event == "ADDON_LOADED" then	
		if arg1 == "Blizzard_ArenaUI" then
			GrozzArena.isBlizzardUIReady = true
			print("Blizzard_ArenaUI loaded")
		elseif arg1 == "GrozzArena" then			
			macrosToUpdate = macrosToUpdate or {}
			GrozzArena.macrosToUpdate = macrosToUpdate
			print("GrozzArena loaded")
		end
	else if (event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS") then
		if GrozzArena.isBlizzardUIReady then
			GrozzArena.SetArenaHooks()
		end
	end	
end)

----------------------------------------------------------------------------------------------------------
-- SLASH COMMANDS
----------------------------------------------------------------------------------------------------------
function GrozzArena.consoleCommands.add(macroName)
	GrozzArena.AddMacroToUpdate(macroName)
end

function GrozzArena.consoleCommands.remove(macroName)
	GrozzArena.RemoveMacroToUpdate(macroName)
end

function GrozzArena.consoleCommands.show()
	for key,_ in pairs(GrozzArena.macrosToUpdate) do 
		print("Tracking macro "..key) 
	end
end

SLASH_GROZZARENA1 = "/ga"
SLASH_GROZZARENA2 = "/grozzarena"

SlashCmdList["GROZZARENA"] = function(msg, editbox)
	local cmd,param = msg:match("(%w-) (.*)")
	cmd = cmd or msg:match("(%w+)") -- for commands without params
	
	local consoleCmdHandler = GrozzArena.consoleCommands[cmd]
	
	if consoleCmdHandler then
		print("GrozzArena: "..cmd)
		consoleCmdHandler(param)
	else
		print("GrozzArena: Command '"..cmd.."' is not supported")
	end
end