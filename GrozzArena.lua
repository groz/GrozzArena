if not MyFrame then
	CreateFrame("Frame", "MyFrame", UIParent)
end

MyFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
MyFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

function MyFrame_OnEvent(self, event, ...)
	if event == "PLAYER_REGEN_ENABLED" then
		print("Leaving combat")
		local body = GetMacroBody(1)
		print(body)
	elseif event == "PLAYER_REGEN_DISABLED" then
		print("Entering combat")
	end
end

MyFrame:SetScript("OnEvent", MyFrame_OnEvent)