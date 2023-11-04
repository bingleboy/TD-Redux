function init()
	
end


function draw()
	local a = GetFloat("game.loading.alpha")
	local showText = GetBool("game.loading.text")

	if a < 0 then a = 0 end
	if a > 1 then a = 1 end
	UiColor(0,0,0, a)
	UiRect(UiWidth(), UiHeight())
	
	UiColorFilter(1,1,1, a*a)
	if showText then
		UiFont("regular.ttf", 32)
		UiAlign("center middle")
		UiTranslate(UiCenter(), UiMiddle())
		UiColor(0.96, 0.96, 0.96)
		local scale = 1+(1-a)
		UiPush()
			showLargeUI = GetBool("game.largeui")
			if showLargeUI then
				UiScale(scale*1.3)
			else 
				UiScale(scale)
			end
			UiText("LOADING")
		UiPop()
		
		local mods = ListKeys("mods.available")
		local activeMods = {}
		local more = 0
		for i=1, #mods do
			local active = GetBool("mods.available."..mods[i]..".active")
			if active then
			    if #activeMods > 8 and showLargeUI then
					more = more +1
				elseif #activeMods > 10 then
					more = more + 1
				else
					local name = GetString("mods.available."..mods[i]..".name")
					if string.len(name) > 128 then
						activeMods[#activeMods+1] = string.sub(name, 1, 128) .. "..."
					else
						activeMods[#activeMods+1] = name
					end
				end
			end
		end
		if more > 0 then
			activeMods[#activeMods+1] = "...and "..more.." more"
		end
		if #activeMods > 0 then
			UiPush()
				UiFont("regular.ttf", 22)
				local width = 200
				local height = 48+#activeMods*UiFontHeight()
				UiTranslate(0, 250)
				for i=1, #activeMods do
					local w,h = UiGetTextSize(activeMods[i])
					w = w + 60
					if w > width then
						width = w
					end
				end
				showLargeUI = GetBool("game.largeui")
				if showLargeUI then
					UiScale(1.3)
				end
				UiImageBox("common/box-outline-6.png", width, height, 6, 6)
				UiWindow(width, height)
				UiAlign("left")
				UiPush()
					UiTranslate(width*0.5-60, -15)
					UiColor(0,0,0)
					UiRect(120, 30)
					UiColor(0.96, 0.96, 0.96)
					UiTranslate(4, 22)
					UiText("Active mods")
				UiPop()
				UiTranslate(30, 44)
				UiColor(1,1,0.7)
				for i=1, #activeMods do
					UiText(activeMods[i], true)
				end
			UiPop()
		end
	end
end

