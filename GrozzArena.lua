local GrozzArena = { }
GrozzArena.eventHandler = CreateFrame("Frame")
GrozzArena.eventHandler.events = { }
GrozzArena.consoleCommands = {}
GrozzArena.hooksSet = false
GrozzArena.debugPrintEnabled = false

----------------------------------------------------------------------------------------------------------
-- UTILITY
----------------------------------------------------------------------------------------------------------
function DebugPrint(arg)
	if (GrozzArena.debugPrintEnabled) then
		print(arg);
	end
end

----------------------------------------------------------------------------------------------------------
-- MAIN
----------------------------------------------------------------------------------------------------------
function GrozzArena.AddMacroToUpdate(macroName)
	local macroIndex = GetMacroIndexByName(macroName)
	
	if  macroIndex and macroIndex ~= 0 then
		if macroIndex > 36 then
			GrozzArena.localMacrosToUpdate[macroName] = true
			DebugPrint("Added local macro "..macroName.." to update for arena targets")
		else
			GrozzArena.globalMacrosToUpdate[macroName] = true
			DebugPrint("Added global macro "..macroName.." to update for arena targets")
		end
		
	else
		DebugPrint("Couldn't find macro "..macroName)
	end	
end

function GrozzArena.RemoveMacroToUpdate(macroName)
	if GrozzArena.localMacrosToUpdate[macroName] then
		GrozzArena.localMacrosToUpdate[macroName] = nil
		DebugPrint("Removed local macro "..macroName.." from updates for arena targets")
	elseif GrozzArena.globalMacrosToUpdate[macroName] then
		GrozzArena.globalMacrosToUpdate[macroName] = nil
		DebugPrint("Removed global macro "..macroName.." from updates for arena targets")
	else
		DebugPrint("Macro "..macroName.." isn't tracked. Removal failed")
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
		DebugPrint("Macro '"..macroName.."' not found. Skipped updating.")
	end
end

function GrozzArena.ArenaFrameClickHandler(self, button)
	local frameName = self:GetName()
	--DebugPrint("Clicked frame "..frameName)
	
	local arenaNum = frameName:match("%d+")
	
	if arenaNum then
		GrozzArena.resetMacros(arenaNum)
	else
		DebugPrint("Couldn't parse arenaNum in "..frameName)
	end
end

function GrozzArena.SetArenaHooks()
	--if GrozzArena.hooksSet then return end
	
	for i = 1,5 do
		--local arenaFrameName = "ArenaEnemyFrame"..i
		local arenaFrameName = "ArenaPrepFrame"..i
		local arenaFrame = _G[arenaFrameName]

		if (arenaFrame ~= nil) then
			DebugPrint("Hooking "..arenaFrameName)
			arenaFrame:HookScript("OnClick", GrozzArena.ArenaFrameClickHandler)
		else
			DebugPrint(arenaFrameName .. " not found")
		end

	end
	
	--GrozzArena.hooksSet = true
end

----------------------------------------------------------------------------------------------------------
-- HOOKING EVENTS, MAIN ENTRY POINT
----------------------------------------------------------------------------------------------------------

GrozzArena.eventHandler:RegisterEvent("ADDON_LOADED")
GrozzArena.eventHandler:RegisterEvent("PLAYER_LOGIN")
GrozzArena.eventHandler:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

GrozzArena.eventHandler:SetScript("OnEvent", function(self, event, arg1, ...)	
	if event == "ADDON_LOADED" then	
		local addonName = arg1
		if addonName == "Blizzard_ArenaUI" then
			--DebugPrint("Blizzard_ArenaUI loaded")
			GrozzArena.SetArenaHooks()
		elseif addonName == "GrozzArena" then
			print("GrozzArena loaded. Type /ga for help.")
			GrozzArena.localMacrosToUpdate = localMacrosToUpdate or {}
			GrozzArena.globalMacrosToUpdate = globalMacrosToUpdate or {}
			localMacrosToUpdate = GrozzArena.localMacrosToUpdate
			globalMacrosToUpdate = GrozzArena.globalMacrosToUpdate
		elseif addonName == "Blizzard_CompactRaidFrames" then
			DebugPrint("GrozzArena: Blizzard_CompactRaidRames loaded, hooking sort function...")
			-- answers the question "is t1 before t2?"
			CompactRaidFrameContainer.flowSortFunc = function(t1, t2) 
				if UnitIsUnit(t1,"player") then
					return true 	-- puts t1(player before t2
				elseif UnitIsUnit(t2,"player") then
					return false  	-- puts t2(player) before t1
				else
					return t1 < t2 	-- puts party1 before party2
				end
			end
		end
	elseif (event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS") then
		--GrozzArena.SetArenaHooks()
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
		DebugPrint("Tracking macro "..key) 
	end
	
	for key,_ in pairs(GrozzArena.globalMacrosToUpdate) do 
		DebugPrint("Tracking macro "..key) 
	end
end

for i=1,5 do
	GrozzArena.consoleCommands[tostring(i)] = function()
		GrozzArena.resetMacros(i);
	end
end

function GrozzArena.consoleCommands.debug()
	GrozzArena.debugPrintEnabled = not GrozzArena.debugPrintEnabled;
	print("GrozzArena DebugPrintEnabled: "..tostring(GrozzArena.debugPrintEnabled));
end

GrozzArena.consoleCommands.help = function()
	print([[GrozzArena /ga
debug - enables debug output
show - shows all tracked macros
add <macro name> - starts tracking macro
remove <macro name> - stops tracking macro
# - points all macros to arena#
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
		--DebugPrint("GrozzArena: "..cmd)
		consoleCmdHandler(param)
	else
		DebugPrint("GrozzArena: Command '"..cmd.."' is not supported")
	end
end