local GrozzArena = { }
GrozzArena.eventHandler = CreateFrame("Frame")
GrozzArena.eventHandler.events = { }
GrozzArena.consoleCommands = {}
GrozzArena.hooksSet = false

GrozzArena.localMacrosToUpdate = localMacrosToUpdate or {}
GrozzArena.globalMacrosToUpdate = globalMacrosToUpdate or {}

----------------------------------------------------------------------------------------------------------
-- MAIN
----------------------------------------------------------------------------------------------------------
function GrozzArena.AddMacroToUpdate(macroName)
	local macroIndex = GetMacroIndexByName(macroName)
	
	if  macroIndex and macroIndex ~= 0 then
		if macroIndex <= 36 then
			GrozzArena.localMacrosToUpdate[macroName] = true
			print("Added local macro "..macroName.." to update for arena targets")
		else
			GrozzArena.globalMacrosToUpdate[macroName] = true
			print("Added global macro "..macroName.." to update for arena targets")
		end
		
	else
		print("Couldn't find macro "..macroName)
	end	
end

function GrozzArena.RemoveMacroToUpdate(macroName)
	if GrozzArena.localMacrosToUpdate[macroName] then
		GrozzArena.localMacrosToUpdate[macroName] = nil
		print("Removed local macro "..macroName.." from updates for arena targets")
	elseif GrozzArena.globalMacrosToUpdate[macroName] then
		GrozzArena.globalMacrosToUpdate[macroName] = nil
		print("Removed global macro "..macroName.." from updates for arena targets")
	else
		print("Macro "..macroName.." isn't tracked. Removal failed")
	end
end

function GrozzArena.resetMacros(i)
	for macroName,_ in pairs(GrozzArena.localMacrosToUpdate) do
		GrozzArena.UpdateArenaTargetInMacro(macroName, "arena"..i)
	end
	
	for macroName,_ in pairs(GrozzArena.globalMacrosToUpdate) do
		GrozzArena.UpdateArenaTargetInMacro(macroName, "arena"..i)
	end
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
	local frameName = self:GetName()
	--print("Clicked frame "..frameName)
	
	local arenaNum = frameName:match("%d+")
	
	if arenaNum then
		GrozzArena.resetMacros(arenaNum)
	else
		print("Couldn't parse arenaNum in "..frameName)
	end
end

function GrozzArena.SetArenaHooks()
	if GrozzArena.hooksSet then return end
	
	for i = 1,5 do
		--local arenaFrameName = "ArenaEnemyFrame"..i
		local arenaFrameName = "ArenaPrepFrame"..i
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
		print(arg1)
		if arg1 == "Blizzard_ArenaUI" then
			print("Blizzard_ArenaUI loaded")
		elseif arg1 == "GrozzArena" then
			GrozzArena.localMacrosToUpdate = localMacrosToUpdate or {}
			GrozzArena.globalMacrosToUpdate = globalMacrosToUpdate or {}
			print("GrozzArena loaded")
		end
	elseif (event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS") then
		GrozzArena.SetArenaHooks()
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
	for key,_ in pairs(GrozzArena.localMacrosToUpdate) do 
		print("Tracking macro "..key) 
	end
	
	for key,_ in pairs(GrozzArena.globalMacrosToUpdate) do 
		print("Tracking macro "..key) 
	end
end

GrozzArena.consoleCommands["1"] = function() 
	GrozzArena.resetMacros(1);
end

GrozzArena.consoleCommands["2"] = function()
	GrozzArena.resetMacros(2);
end

GrozzArena.consoleCommands["3"] = function() 
	GrozzArena.resetMacros(3);
end

GrozzArena.consoleCommands["4"] = function() 
	GrozzArena.resetMacros(4);
end

GrozzArena.consoleCommands["5"] = function() 
	GrozzArena.resetMacros(5);
end

GrozzArena.consoleCommands.help = function()
	print([[
GrozzArena	
Usage:
	show - shows all tracked macros
	add <macro name> - starts tracking macro
	remove <macro name> - stops tracking macro
	# - changes all macros to point to arena#
	left-click on arena prep frame - points all macros to clicked target
]])
end

SLASH_GROZZARENA1 = "/ga"
SLASH_GROZZARENA2 = "/grozzarena"

SlashCmdList["GROZZARENA"] = function(msg, editbox)
	local cmd,param = msg:match("(%w-) (.*)")
	cmd = cmd or msg:match("(%w+)") -- for commands without params	
	cmd = msg and cmd or 'help'	-- if no parameters given default to 'help'
	
	local consoleCmdHandler = GrozzArena.consoleCommands[cmd]
	
	if consoleCmdHandler then
		print("GrozzArena: "..cmd)
		consoleCmdHandler(param)
	else
		print("GrozzArena: Command '"..cmd.."' is not supported")
	end
end