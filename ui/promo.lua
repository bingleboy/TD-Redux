#include "script/common.lua"

promoScale = 0					-- Scale of this dialog (0 not visible, 1 fully visible)
promoGroupWidth = {}			-- Remember the width of each group for scrolling purposes
promoGroupScroll = {}			-- Remember horizontal scroll position of each group
promoGroupScrollSmooth = {}		-- Visual smoothing for horizontal scrolling
promoSelected = ""				-- Registry key if selected mod
promoSelectedAlpha = 0			-- Scale of details window (also affect position of main window)
promoScroll = 0					-- Vertical scroll of promo groups
promoScrollSmooth = 0			-- Visual smoothing
promoGroupSpacing = 39			-- Spacing between promo groups
promoHoverMain = false			-- True if mouse pointer is hovering the main window
promoHoverSelected = false		-- True if mouse pointer is hovering the details window
promoLoaded = false				-- Remember if images are loaded, so that they can be unloaded when window is closed
promoLegalScale = 0
promoLargeScl = 1
promoLargeUI = false
promoScrollSelectedIntoView = false

promoScrollbar =
{
	pos = 0,
	possmooth = 0,
	dragstarty = 0,
	isdragging = false
}

--Helped for background color
function promoBgColor()
	--UiColor(24.0/255, 28.0/255, 30.0/255, 0.7)
	UiColor(24.0/255, 28.0/255, 30.0/255)
end

function promoTextColor()
	UiColor(0.75, 0.65, 0.35, 1.25)
end

--function isModDownloading(modId)
--	if string.sub(modId,1,6) == "steam-" and HasKey("mods.subscribestate."..string.sub(modId,7)) then
--		local id = string.sub(modId,7)
--		return GetBool("mods.subscribestate."..id..".downloading")
--		--return GetBool("mods.subscribestate."..id..".downloading") and not GetBool("mods.subscribestate."..id..".installed")
--	end
--	return false
--end
function isModDownloading(modId)
	if string.sub(modId,1,6) == "steam-" and HasKey("mods.pending."..string.sub(modId,7)) then
		local id = string.sub(modId,7)
		return GetBool("mods.pending."..id..".downloading")
		--return GetBool("mods.pending."..id..".downloading") and not GetBool("mods.pending."..id..".installed")
	end
	return false
end


--This function is called from main.lua when dialog should open
function promoShow()
	SetValue("promoScale", 1, "cosine", 0.25)
end


--The main draw function called from menu.lua
function promoDraw()
	promoLargeUI = GetBool("game.largeui")
	promoLargeScl = 1
	if promoLargeUI then
		promoLargeScl = 1.14
	end

	--First check if the dialog is open. If it was recently closed, unload all images to save memory
	if promoScale == 0 then
		if promoLoaded then
			--Unload images to save memory
			local groups = ListKeys("promo.groups")
			for i=1, #groups do
				local groupKey = "promo.groups."..groups[i]
				local items = ListKeys(groupKey.. ".items")
				for j=1, #items do
					local key = groupKey..".items."..items[j]
					local image = GetString(key .. ".image")
					local img = GetString(image)
					UiUnloadImage(img)
				end
			end
			promoLoaded = false
		end
		return
	end
	promoLoaded = true

	--Draw the UI
	if (promoScale == 1) and (promoLegalScale == 0) and not GetBool("savegame.legalnoticeshown") then
		SetValue("promoLegalScale", 1, "cosine", 0.25)
	end
	local showLegal = (promoLegalScale > 0)
	if showLegal then
		UiDisableInput()
	end

	if promoScale == 1 then
		SetBool("savegame.promoupdated", false)
	end

	UiModalBegin()
	UiPush()
		UiBlur(promoScale)
		UiColor(0.7,0.7,0.7, 0.25*promoScale)
		UiTranslate(0, 0)
		UiRect(UiWidth(), UiHeight())

		local w = 1200
		local h = 800
		UiAlign("center middle")
		UiTranslate(UiCenter(), UiMiddle()+30)
		UiScale(promoScale*promoLargeScl)
		UiColorFilter(1, 1, 1, promoScale*promoScale)

		UiPush()
			UiColor(0,0,0,0.75)
			UiImageBox("common/box-solid-shadow-50.png", w + promoSelectedAlpha*450, h, -50, -50)
			UiTranslate(-promoSelectedAlpha*450/2, 0)
			UiWindow(w, h, true)
			UiAlign("top left")
			promoHoverMain = UiIsMouseInRect(w,h)
			local promoHoverScrollArea = false
			UiPush()
				UiTranslate(10, 135)
				promoHoverScrollArea = UiIsMouseInRect(w-15,h-140)
			UiPop()

			UiTranslate(0, 35)
			UiPush()
				UiTranslate(8, 2)
				UiFont("bold.ttf", 36)
				UiColor(0.8, 0.8, 0.8, 1)
				UiAlign("left")
				UiText("FEATURED MODS")
				if promoLargeUI then
					UiFont("regular.ttf", 22)
				else
					UiFont("regular.ttf", 20)
				end
				UiAlign("left")
				UiTranslate(0, 32)
				UiWordWrap(1150)
				UiColor(0.65, 0.65, 0.65, 1.25)
				local rw, rh, rx, ry = UiText("Experience some of the best mods made by the Teardown community, hand-picked by Tuxedo Labs. Featured mods are updated regularly. Please note that all content below is created and published on Steam Workshop by their respective authors and not controlled by Tuxedo Labs.")
		        UiAlign("left")
				UiTranslate(rh+UiFontHeight())--UiTranslate(rx + 4, ry)
				UiColor(1, 1, 1)
				if UiTextButton("More info") then
					SetValue("promoLegalScale", 1, "cosine", 0.25)
				end
			UiPop()
			
			UiPush()
				UiTranslate(0, 100)
				UiWindow(w, h-140, true)
				UiTranslate(0, -promoScrollSmooth)
				local totalHeight = 0
				local selectedOffsetY = -1
			
				--Draw promo groups
				UiAlign("top left")
				local groups = ListKeys("promo.groups")
				for i=1, #groups do
					local key = "promo.groups."..groups[i]
					local groupTitle = GetString(key .. ".title")
					local form = GetString(key .. ".format")
					local size = GetString(key .. ".size")
					local largeTitle = false
					local groupHeight = 164
					if size == "large" then
						largeTitle = true
						groupHeight = 220
					end
					if not promoGroupWidth[i] then promoGroupWidth[i] = 0 end
					if not promoGroupScroll[i] then promoGroupScroll[i] = 0 end
					if not promoGroupScrollSmooth[i] then promoGroupScrollSmooth[i] = 0 end
				
					if promoLargeUI then
						UiFont("regular.ttf", 25)
					else
						UiFont("regular.ttf", 22)
					end

					local tw, th = UiGetTextSize(groupTitle)
					local maxScroll = math.max(promoGroupWidth[i] - (w-139), 0)
					local scrollLeft = promoGroupScroll[i] > 0
					local scrollRight = promoGroupScroll[i] < maxScroll
				
					UiPush()
						UiTranslate(10, 0)
						promoBgColor()
						UiImageBox("common/box-solid-10.png", w-40, groupHeight+30, 6, 6)

						UiPush()
							UiTranslate(14, 14)
							promoTextColor();
							UiText(groupTitle)
						UiPop()

						UiTranslate(50-2, 54-2)
						local itemHeight = groupHeight-40
						UiWindow(w-139+4, itemHeight+4, true, true)
						UiPush()
							UiTranslate(-32)
							local scrollLeftHover = showLegal==false and scrollLeft and UiIsMouseInRect(18, itemHeight)
						UiPop()
						UiPush()
							UiTranslate(w-124)
							local scrollRightHover = showLegal==false and scrollRight and UiIsMouseInRect(16, itemHeight)
						UiPop()
						local inArea = UiIsMouseInRect(w-124, itemHeight)
						UiTranslate(-promoGroupScrollSmooth[i], 0)
						UiTranslate(2, 2)

						local inputEnabled = (showLegal==false and inArea and scrollLeftHover==false and scrollRightHover==false)
						promoGroupWidth[i], selected, scroll_off, selected_posx, selected_in_group = promoDrawItems(key, itemHeight, form=="square", largeTitle, inputEnabled, -promoGroupScrollSmooth[i]+2)
						if selected~="" then
							promoGroupScroll[i] = math.min(promoGroupScroll[i] - scroll_off, maxScroll)
							if selected ~= promoSelected then
								promoSelected = selected
							end
						end
						if promoSelected ~= "" and promoScrollSelectedIntoView and selected_in_group then
							promoGroupScroll[i] = promoGroupScroll[i] - selected_posx
							selectedOffsetY = totalHeight
						end
					UiPop()

					--Left/right arrow and scrolling
					if showLegal==false then
						UiPush()
							local viewButton = UiIsMouseInRect(w, groupHeight)
							--local viewButton = true
							UiTranslate(59, 54)
							promoBgColor()
							if scrollLeft then
								UiPush()
									UiTranslate(-3, -2)
									UiScale(1, (itemHeight+4)/64)
									UiImage("common/hgradient-left-64.png")
									--UiColor(1,0,1,0.5)
									--UiRect(64,64)
								UiPop()
							end
							if viewButton and scrollLeft then
								UiPush()
									UiTranslate(-24, itemHeight/2)
									UiAlign("center middle")
									UiColor(1,1,1,0.15)
									if scrollLeftHover then
										UiColor(1,1,1,0.3)
									end
									if (scrollLeftHover and InputPressed("lmb")) or InputPressed("left") or InputPressed("leftarrow") then  
										promoGroupScroll[i] = math.max(promoGroupScroll[i] - 400, 0)
									end
									UiScale(-1, 1)
									if largeTitle then
										UiImage("menu/arrow_16x178.png")
									else
										UiImage("menu/arrow_16x124.png")
									end
								UiPop()
							end

							UiTranslate(w-184, 0)
							if scrollRight then
								UiPush()
									UiTranslate(-15, -2)
									UiScale(1, (itemHeight+4)/64)
									UiImage("common/hgradient-right-64.png")
									--UiColor(1,0,1,0.5)
									--UiRect(64,64)
								UiPop()
							end
							if viewButton and scrollRight then
								UiPush()
									UiTranslate(68, itemHeight/2)
									UiAlign("center middle")
									UiColor(1,1,1,0.15)
									if scrollRightHover then
										UiColor(1,1,1,0.3)
									end
									if (scrollRightHover and InputPressed("lmb")) or InputPressed("right") or InputPressed("rightarrow") then  
										promoGroupScroll[i] = math.min(promoGroupScroll[i] + 400, maxScroll)
									end
									UiScale(1, 1)
									if largeTitle then
										UiImage("menu/arrow_16x178.png")
									else
										UiImage("menu/arrow_16x124.png")
									end
								UiPop()
							end
						UiPop()
					end
				
					promoGroupScrollSmooth[i] = promoGroupScrollSmooth[i] + clamp((promoGroupScroll[i] - promoGroupScrollSmooth[i])*10*GetTimeStep(), -40, 40)
				
					UiTranslate(0, groupHeight+promoGroupSpacing)
					totalHeight = totalHeight + groupHeight+promoGroupSpacing
				end
				totalHeight = totalHeight - 10

				--More mods button
				UiPush()
					local steam_active = GetBool("game.steam.active") and GetBool("game.workshop")
					totalHeight = totalHeight+80
					UiTranslate(10, 14)
					UiColor(0.9, 0.9, 0.9)
					UiFont("regular.ttf", 24)
					if steam_active then
						UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.9)
						if UiTextButton("More mods...", 200, 40) then
							--Command("mods.browse", "")
							SetValue("promoScale", 0, "linear", 0.25)
							SetValue("gCreateScale", 1, "cosine", 0.25)
							gModSelectedScale=0
							updateMods()
							selectMod("")
						end
					else
						UiColor(0.8, 0.8, 0.8, 0.8)
						UiDisableInput()
						UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.2)
						UiTextButton("More mods...", 200, 40)
						UiEnableInput()
					end
				UiPop()
			UiPop()

			--Scrollbar
			if promoScrollbar.isdragging and InputReleased("lmb") then
				promoScrollbar.isdragging = false
			end
			UiPush()
				local h_scroll = h - 145
				if totalHeight > h_scroll then
					local scrollCount = totalHeight - h_scroll
					if scrollCount < 0 then scrollCount = 0 end

					local frac = h_scroll / totalHeight
					local pos = -promoScrollbar.possmooth / totalHeight
					if promoScrollbar.isdragging then
						local posx, posy = UiGetMousePos()
						local dy = (posy - promoScrollbar.dragstarty)
						promoScrollbar.pos = -dy / frac
					end

					UiPush()
						UiAlign("top left")
						UiTranslate(w-24, 100)
						UiColor(0.1, 0.1, 0.1, 0.8)
						UiImageBox("common/box-solid-4.png", 18, h_scroll, 4, 4)
						UiColor(1,1,1, 0.2)

						local bar_posy = 2 + pos * h_scroll
						local bar_sizey = h_scroll * frac - 4
						UiPush()
							UiTranslate(2,2)

							if bar_posy > 2 and UiIsMouseInRect(16, bar_posy-2) and InputPressed("lmb") then
								promoScrollbar.pos = promoScrollbar.pos + frac * totalHeight
							end
							local h2 = h_scroll - bar_sizey - bar_posy
							UiTranslate(0,bar_posy + bar_sizey)
							if h2 > 0 and UiIsMouseInRect(16, h2) and InputPressed("lmb") then
								promoScrollbar.pos = promoScrollbar.pos - frac * totalHeight
							end
						UiPop()

						UiTranslate(2,bar_posy)
						local in_rect = UiIsMouseInRect(12, bar_sizey)
						if promoScrollbar.isdragging then
							UiColor(1,1,1, 0.5)
						elseif in_rect then
							UiColor(1,1,1, 0.3)
						end

						if in_rect and InputPressed("lmb") then
							local posx, posy = UiGetMousePos()
							promoScrollbar.dragstarty = posy+102
							promoScrollbar.isdragging = true
						end
						UiImageBox("common/box-solid-4.png", 14, bar_sizey, 4, 4)
					UiPop()

					--Scroll into view
					if promoSelected ~= "" and promoScrollSelectedIntoView and selectedOffsetY >= 0 then
						promoScrollbar.pos = -selectedOffsetY
						promoScrollSelectedIntoView = false
					end

					promoScrollbar.pos = clamp(promoScrollbar.pos, -scrollCount, 0)
				else
					promoScrollbar.pos = 0
					promoScrollbar.possmooth = 0
				end

				--Wheel scrolling
				if promoHoverScrollArea then
					promoScrollbar.pos = -clamp((-promoScrollbar.pos - InputValue("mousewheel")*80), 0, math.max(0, totalHeight-h_scroll))
				end

				if promoScrollbar.isdragging then
					promoScrollbar.possmooth = promoScrollbar.pos
				else
					promoScrollbar.possmooth = promoScrollbar.possmooth + (promoScrollbar.pos-promoScrollbar.possmooth) * 10 * GetTimeStep()
				end

				promoScrollSmooth = -promoScrollbar.possmooth
			UiPop()
			--/Scrollbar

		UiPop()

		if promoSelected ~= "" and promoSelectedAlpha == 0 then
			SetValue("promoSelectedAlpha", 1, "cosine", 0.25)
		end
		
		--Draw the details window for selected mod
		if promoSelectedAlpha > 0 then
			promoDrawSelected(promoSelected, promoSelectedAlpha)
		end

		--Handle closing of this window
		local clickOutside = (InputPressed("lmb") and promoScale > 0.5 and promoHoverMain==false and promoHoverSelected==false)
		if InputPressed("pause") or clickOutside then
			SetValue("promoScale", 0, "linear", 0.25)
		end
	UiPop()
	UiModalEnd()

	--Legal stuff
	if promoLegalScale > 0 then
		UiEnableInput()
		promoDrawLegal()
	end
end

--Draw all items in a promo group
function promoDrawItems(groupKey, groupHeight, square, largeTitle, inputEnabled, start_x)
	local totalWidth = 0
	local selected = ""
	local scroll_off = 0
	local selected_posx = 0
	local selected_in_group = false
	UiPush()
		UiColor(1,1,1)
		local items = ListKeys(groupKey..".items")
		for i=1, #items do
			local key = groupKey .. ".items." .. items[i]
			local image = GetString(key .. ".image")
			local title = GetString(key .. ".shorttitle")
			local iw, ih = UiGetImageSize(image)
			local scale = groupHeight/ih
			local width = iw * scale
			local height = ih * scale
			local pad = 0
			if square then
				pad = (iw-ih)/2
				width = (iw-pad*2) * scale
			end

			local hover = false
			UiPush()
				if UiIsMouseInRect(width, height) and inputEnabled then
					UiColor(0.8, 0.8, 0.8)
					hover = true
					if InputPressed("lmb") then
						selected = key
						UiSound("terminal/message-select.ogg")

						--auto-scroll partially visible items into view
						if start_x < 0 then
							scroll_off = 4-start_x
						end
						if (start_x + width) > 1061 then
							scroll_off = -(start_x + width - 1061)
						end
					end
				end

				if key == promoSelected then
					selected_in_group = true
					if start_x < 0 then
						selected_posx = 4 - start_x
					end
					if (start_x + width) > 1061 then
						selected_posx = 1061 - start_x - width
					end
					UiPush()
						UiColor(192/255, 166/255, 88/255)
						UiTranslate(-2, -2)
						UiScale((width+4)/32.0, (height+4)/32.0)
						if square then
							UiImageAlpha("menu/white_32.png", "menu/square_thumb_alpha.png")
						else
							UiImageAlpha("menu/white_32.png", "menu/480x270-rounded-corners-alpha.png")
						end
					UiPop()
				end
				UiScale(scale)
				if largeTitle then
					UiImageOverlayAlpha(image, "menu/overlay_gradient_270.png", "menu/480x270-rounded-corners-alpha.png", pad, 0, iw-pad, ih, 0, 0, 480, 270)
				else
					if square then
						UiImageOverlayAlpha(image, "menu/overlay_gradient_124.png", "menu/square_thumb_alpha.png", pad, 0, iw-pad, ih, 0, 0, 124, 124)
					else
						UiImageOverlayAlpha(image, "menu/overlay_gradient_124.png", "menu/480x270-rounded-corners-alpha.png", pad, 0, iw-pad, ih, 0, 0, 480, 270)
					end
				end
			UiPop()

			UiPush()
				if promoLargeUI then
					UiFont("regular.ttf", 22)
				else
					UiFont("regular.ttf", 18)
				end

				if key == promoSelected then
					promoTextColor()
				else
					UiColor(0.65,0.65,0.65,1.25)
				end
				UiAlign("left")
				UiWindow(width-10, height, true, true)
				UiTranslate(6, height-8)
				UiText(title)
			UiPop()

			local modKey = "mods.available."..items[i]
			if HasKey(modKey) then	
				UiPush()
					UiTranslate(16, 16)
					UiAlign("center middle")
					UiColor(0,0,0,1)
					UiImage("common/box-solid-4.png")
					UiColor(1,1,1)

					if GetBool(modKey..".playable") then
						UiImage("menu/promo-play.png")
						UiColor(1,1,1)
					elseif GetBool(items[i]..".active") then
						UiImage("menu/promo-active.png")
					else
						UiImage("menu/promo-inactive.png")
					end
				UiPop()
			end

			UiTranslate(width + 20, 0)
			totalWidth = totalWidth + width + 20
			start_x = start_x + width + 20
		end
	UiPop()
	return totalWidth - 20, selected, scroll_off, selected_posx, selected_in_group
end

--Draw the additional window on the right side with details for the selected mod
function promoDrawSelected(key, scale)
	UiPush()
		local w = 450
		local h = 800
		UiAlign("center middle")
		UiTranslate(589, -5)
		UiScale(scale, 1)
		UiColor(0,0,0,0.8)

		local image = GetString(key .. ".image")
		local title = GetString(key .. ".title")
		local author = GetString(key .. ".author")
		local desc = GetString(key .. ".desc")
		local tags = GetString(key .. ".tags")
		local tmp = splitString(key, ".")
		local modId = tmp[#tmp]
		local modKey = "mods.available."..modId
		local hasMod = HasKey(modKey)
		local canPlay = hasMod and GetBool(modKey..".playable")
		local canEnable = hasMod and GetBool(modKey..".override")
		local hasOptions = hasMod and GetBool(modKey..".options")
		local isLoading = (hasMod==false and isModDownloading(modId))

		UiPush()
			UiAlign("top left")
			UiTranslate(-195, -375)
			promoBgColor()
			if hasOptions then
				UiImageBox("common/box-solid-shadow-50.png", w-40, h-145, -50, -50)
			else
				UiImageBox("common/box-solid-shadow-50.png", w-40, h-95, -50, -50)
			end
		UiPop()

		w = w-20
		h = h-10
		
		UiWindow(w, h, true, true)
		UiAlign("top left")
		promoHoverSelected = UiIsMouseInRect(w,h)

		UiColor(1,1,1)
		UiPush()
			local imgWidth = w-40
			local iw, ih = UiGetImageSize(image)
			UiTranslate(30, 30)
			local scale = imgWidth / iw
			UiPush()
				UiScale(scale)
				UiImageAlpha(image, "menu/480x270-rounded-corners-alpha.png")
			UiPop()
			UiTranslate(0, ih*scale + 36)
			UiAlign("left")
			UiFont("bold.ttf", 24)
			
			promoTextColor();
			UiText(title)
			
			UiTranslate(0, 30)

			if promoLargeUI then
				UiFont("regular.ttf", 22)
			else
				UiFont("regular.ttf", 20)
			end
			UiColor(0.65, 0.65, 0.65, 1.25)
			UiWordWrap(w-40)
			UiText(desc, true)
			
			UiTranslate(0, 30)
			promoTextColor();

			UiText("Author ")
			UiTranslate(60, 0)
			UiColor(0.65, 0.65, 0.65, 1.25)
			UiWordWrap(w-80)
			UiText(author, true)
			UiTranslate(-60, 0)

			promoTextColor();
			UiText("Tags ")
			UiTranslate(60, 0)
			UiColor(0.65, 0.65, 0.65, 1.25)
			UiWordWrap(w-80)
			UiText(tags, true)
		UiPop()

		local steam_active = GetBool("game.steam.active") and GetBool("game.workshop")
		UiPush()
			UiColor(1, 1, 1)
			UiFont("regular.ttf", 24)
			UiAlign("center middle")
			
			if hasOptions then
				UiPush()
					UiTranslate(330, h-70)
					UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.7)
					if UiTextButton("Options", 200, 40) then
						Command("mods.options", modId)
					end
				UiPop()
			end
			
			UiPush()
				UiTranslate(120, h-20)
				if not steam_active then
					UiColorFilter(0.8, 0.8, 0.8, 0.8)
					UiDisableInput()
				end
				UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.7)
				if UiTextButton("More details...", 200, 40) then
					Command("mods.browse", modId)
				end
			UiPop()

			UiPush()
				UiTranslate(330, h-20)
				if hasMod then 
					if canPlay then
						UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.7)
						UiColor(1, 1, 1)
						if UiTextButton("Play", 200, 40) then
							Command("mods.play", modId)
						end
					elseif canEnable then
						UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.7)
						if GetBool(modId..".active") then
							if UiTextButton("Enabled", 200, 40) then
								Command("mods.deactivate", modId)
								updateMods()
							end
							UiColor(1, 1, 0.5)
							UiTranslate(-60, 0)
							UiImage("menu/mod-active.png")
						else
							if UiTextButton("Disabled", 200, 40) then
								Command("mods.activate", modId)
								updateMods()
							end
							UiTranslate(-60, 0)
							UiImage("menu/mod-inactive.png")
						end
					else
						UiTranslate(-10, 0)
						UiText("Installed")
					end

				elseif isLoading then
				    UiColor(1, 1, 1)
					UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.2)
					UiColorFilter(1, 1, 1, 0.9)
					UiPush()
						UiDisableInput()
						local l = "Downloading"
						local t = math.mod(GetTime(), 4.0)
						if t > 1 then l = l.."." end
						if t > 2 then l = l.."." end
						if t > 3 then l = l.."." end
						UiTextButton(l, 200, 40)
					UiPop()
				else
					if steam_active then
						UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.7)
						if UiTextButton("Subscribe", 200, 40) then
							Command("mods.subscribe", modId)
						end
					else
						UiColor(0.8, 0.8, 0.8, 0.8)
						UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.2)
						UiDisableInput()
						UiTextButton("Subscribe", 200, 40)
						UiEnableInput()
					end
				end
			UiPop()
		UiPop()
	UiPop()
end


promoFull = ""

function promoInitFull(promoKey)
	if promoFull == "" then
		promoFull = promoKey
	end
end


function promoDrawFeatured()

	if GetBool("savegame.promoupdated") then
		SetBool("savegame.promoclosed", false)
	end
	if GetInt("savegame.startcount") < 5 or GetBool("savegame.promoclosed") then
		return
	end

	if promoFull == "" then
		return
	end
	itemKey = promoFull

	local image = GetString(itemKey .. ".image")
	local title = GetString(itemKey .. ".shorttitle")
	local author = GetString(itemKey .. ".author")
	local tmp = splitString(itemKey, ".")
	local modId = tmp[#tmp]
	local modKey = "mods.available."..modId
	local hasMod = HasKey(modKey)
	local canPlay = hasMod and GetBool(modKey..".playable")
	--local canEnable = hasMod and GetBool(modKey..".override")
	local isLoading = (hasMod==false and isModDownloading(modId))

	local iw, ih = UiGetImageSize(image)
	local steam_active = GetBool("game.steam.active")

	local scl = 1
	if promoLargeUI then
		scl = 1.2
	end

	UiPush()
		local w = 328
		local h = 272
		UiTranslate(UiWidth() - (w + 40)*scl, UiHeight() - (h + 40)*scl)
		UiScale(scl)

		UiPush()
			UiColor(0,0,0,0.6)
			UiAlign("top left")
			UiImageBox("common/box-solid-shadow-50.png", w, h, -50, -50)
			UiWindow(w, h, true)
			UiAlign("top left")
			UiTranslate(4, 4)

			UiPush()
				UiColor(144/255.0, 128/255.0, 96/255.0)
				UiImage("menu/promo-gradient.png")
				UiTranslate(4, 3)
				UiFont("bold.ttf", 22)
				UiColor(0.8, 0.8, 0.8, 1)
				UiText("FEATURED MOD")
			UiPop()

			UiPush()
				UiTranslate(w-19, 14)
				UiColor(0.8, 0.8, 0.8)
				UiAlign("center middle")
				UiScale(0.8, 0.8)
				if UiImageButton("menu/promo-x.png") then
					SetBool("savegame.promoclosed", true)
				end
			UiPop()

			UiPush()
				UiTranslate(0, 37)
				UiScale((w-8)/iw, (h-92)/ih)
				UiColor(1,1,1,0.8)
				UiImageAlpha(image, "menu/480x270-rounded-corners-alpha.png")

				if UiIsMouseInRect(iw, ih) and InputPressed("lmb") then
					promoSelected = itemKey
					promoShow()
				end
			UiPop()
			if hasMod then
				UiPush()
					UiTranslate(w-30, h-75)
					UiAlign("center middle")
					UiColor(0,0,0,1)
					UiImage("common/box-solid-4.png")
					UiColor(1,1,1)

					if canPlay then
						UiImage("menu/promo-play.png")
						UiColor(1,1,1)
					elseif GetBool(modId..".active") then
						UiImage("menu/promo-active.png")
					else
						UiImage("menu/promo-inactive.png")
					end
				UiPop()
			end

			UiPush()
				UiTranslate(0, h-48)
				promoTextColor()
				UiFont("regular.ttf", 20)
				UiWindow(w-125,25,true)
				UiText(title)
			UiPop()

			UiPush()
				UiTranslate(0, h-30)
				UiColor(0.65, 0.65, 0.65, 1.25)
				UiFont("regular.ttf", 20)
				UiWindow(w-125,25,true)
				UiText(author)
			UiPop()

			UiPush()
				UiTranslate(w-108, h-46)
				UiColor(1, 1, 1)
				UiFont("regular.ttf", 24)
				UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.7)
				if UiTextButton("Info...", 100, 40) then
					promoSelected = itemKey
					promoScrollSelectedIntoView = true
					promoShow()
				end
			UiPop()
		UiPop()
	UiPop()
end


function promoDrawLegal()
	if promoLegalScale == 1 then
		SetBool("savegame.legalnoticeshown", true)
	end

	UiModalBegin()
	UiPush()
		UiBlur(promoLegalScale)

		local w = 800
		--local h = 540
		local h = 430
		UiTranslate(UiCenter(), UiMiddle())
		UiScale(promoLegalScale*promoLargeScl)

		UiColor(0,0,0,0.9*promoLegalScale)
		UiAlign("center middle")
		UiImageBox("common/box-solid-shadow-50.png", w, h, -50, -50)
		UiWindow(w, h)
		UiAlign("left top")

		UiPush()
			UiFont("bold.ttf", 36)
			UiColor(0.85, 0.85, 0.85)
			UiAlign("center")
			UiTranslate(UiCenter(), 45)
			UiText("Notice")
		UiPop()

		UiPush()
			UiFont("regular.ttf", 22)
			UiTranslate(UiCenter()-380, 90)
			UiAlign("left")
			UiWordWrap(750)
			UiColor(0.65, 0.65, 0.65, 1.25)
			UiText("This window showcases some of the best mods of Teardown that we have been able to find.", true)
			UiText("", true)
			UiText("Please be advised that, these mods are still mods created independently from Tuxedo Labs, and as such we cannot take responsibility for their content or their continued proper functioning, though we of course try to ensure quality across the board.", true)
			UiText("", true)
			UiText("If you are the creator of one of the mods featured herein and know that the mod which you have created contains materials (including imagery or references) belonging to a third party, please contact us at ", true)
			UiFont("bold.ttf", 22)
			UiTranslate(165, -22)
			UiText("report@tuxedolabs.com", true)
			UiColor(0.65, 0.65, 0.65, 1.25)
			UiFont("bold.ttf", 22)
			UiTranslate(-165, 0)
			UiText("", true)
			UiText("If you are the rights holder to any intellectual property right and believe that your right is being infringed hereby", false)
			UiFont("regular.ttf", 22)
			UiTranslate(210, 22)
			UiText(", please contact us at ", false)
			UiFont("bold.ttf", 22)
			UiTranslate(175, 0)
			UiText("report@tuxedolabs.com", false)
			UiFont("regular.ttf", 22)
		UiPop()

		UiPush()
			UiColor(0.85, 0.85, 0.85, 1.25)
			UiFont("regular.ttf", 24)
			UiAlign("center")
			UiTranslate(UiCenter(), h - 35)
			UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.7)
			if UiTextButton("Ok", 200, 40) then
				SetValue("promoLegalScale", 0, "cosine", 0.25)
			end
		UiPop()

		--Handle closing of this window
		if InputPressed("esc") or (not UiIsMouseInRect(w, h) and InputPressed("lmb")) then
			SetValue("promoLegalScale", 0, "cosine", 0.25)
		end
	UiPop()
	UiModalEnd()
end
