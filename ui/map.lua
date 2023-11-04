#include "game.lua"
#include "script/common.lua"

gMapFade = 0
gMapInfoShown = false
gMapInfoScale = 0
gMapPathScale = 0
gMapPathType = 0
gMapPathPlay = false

gMapInfoHeight = 200
gMapListHeight = 200
gMapLocationInfoHeight = 0

gMapLocationInfoShown = false
gMapLocationInfoScale = 0
gMapLocationInfoName = ""
gMapLocationInfoImage = ""
gMapLocationInfoText = ""
gMapLocationInfoOutput = 0

gMapHasLastPath = false
gMapHasBestPath = false

gMapLocationIndex = 0
gMapLocationHighlight = 0
gMapFlashTargetList = true


function mapInit(missionId)
	gMapHasLastPath = (Command("game.path.has", missionId.."-last") and gMissions[missionId].alarmPath)
	gMapHasBestPath = (Command("game.path.has", missionId.."-best") and gMissions[missionId].alarmPath)
	gMapShowTargetHint = GetBool("savegame.hint.targetlocation")==false and string.sub(missionId,1,3)~="hub" and gMissionMode==true
	gMapTargetHintAlpha = 0
	gMapTimer = 0
end


function mapGetWorldInfo()
	gMapLocations = {}
	gMapPrimary = {}
	gMapSecondary = {}

	local player = {}
	player.name = "Your position" --"Cum Master"
	player.pos = GetPlayerPos()
	player.id = -1
	player.type = "player"
	gMapLocations[1] = player
	
	local ev = FindBodies("escapevehicle", true)
	if #ev > 0 then
		local escape = {}
		local name = GetTagValue(ev[1], "escapevehicle")
		if name ~= "" then
			escape.name = name
		else
			escape.name = "Escape vehicle"
		end
		escape.pos = GetBodyTransform(ev[1]).pos
		escape.id = -2
		escape.type = "escape"
		gMapLocations[2] = escape
	end

	local targets = FindBodies("target", true)
	for i=1,#targets do
		local target = {}
		if GetTagValue(targets[i], "target") ~= "cleared" and GetTagValue(targets[i], "target") ~= "disabled" then
			if GetTagValue(targets[i], "hidden") ~= "nolist" then
				target.hidden = HasTag(targets[i], "hidden")
				local words = splitString(GetDescription(targets[i]), ";")
				if words[2] then target.name = GetTranslatedStringByKey(words[2]) else target.name = "" end
				if target.name == "" then
					target.name = "Target"
				end
				target.pos = GetBodyTransform(targets[i]).pos
				target.id = targets[i]
				target.ok = HasTag(targets[i], "ok")
				if words[1] then target.desc = GetTranslatedStringByKey(words[1]) else target.desc = "" end
				if words[3] then target.info = GetTranslatedStringByKey(words[3]) else target.info = "" end
				if words[4] then target.image = "hud/target/"..words[4] else target.image = "" end
				local optional = HasTag(targets[i], "optional")
				if optional then
					target.type = "secondary"
					gMapSecondary[#gMapSecondary+1] = target
				else
					target.type = "primary"
					gMapPrimary[#gMapPrimary+1] = target
				end
			end
		end
	end
	table.sort(gMapLocations, function(a, b) return a.pos[3] < b.pos[3] end)
	table.sort(gMapPrimary, function(a, b) return a.pos[3] < b.pos[3] end)
	table.sort(gMapSecondary, function(a, b) return a.pos[3] < b.pos[3] end)
	
	local bodies = FindBodies("map", true)
	for i=1,#bodies do
		local target = {}
		local words = splitString(GetDescription(bodies[i]), ";")
		if words[2] then target.name = words[2] else target.name = "" end
		if target.name == "" then
			target.name = "Item"
		end
		target.pos = GetBodyTransform(bodies[i]).pos
		target.id = bodies[i]
		if words[1] then target.desc = words[1] else target.desc = "" end
		if words[3] then target.info = words[3] else target.info = "" end
		if words[4] then target.image = "hud/target/"..words[4] else target.image = "" end
		gMapLocations[#gMapLocations+1] = target
	end
end


function mapSelectLocation(loc, focus)
	gMapFlashTargetList = false
	if gMapShowTargetHint then
		gMapShowTargetHint = false
		if GetString("game.levelid") ~= "mall_intro" then
			SetBool("savegame.hint.targetlocation", true)
		end
	end
	if gSelectedTarget == loc.id then
		loc = nil
	end
	if loc then
		UiSound("hud/location.ogg")
		gSelectedTarget = loc.id
		if focus and not loc.hidden then
			SetString("game.map.focus", loc.pos[1].." "..loc.pos[2].." "..loc.pos[3])
		else
			SetString("game.map.focus", "0 0 0")
		end
	else
		gSelectedTarget = 0
		SetString("game.map.focus", "0 0 0")
	end
	if loc and loc.info and loc.info~="" then
		gMapLocationInfoName = loc.desc
		gMapLocationInfoText = loc.info
		gMapLocationInfoImage = loc.image
		gMapLocationInfoShown = false
		gMapLocationInfoScale = 0
		if not gMapLocationInfoShown then
			SetValue("gMapLocationInfoScale", 1, "cosine", 0.25)
			gMapLocationInfoShown = true
			gMapLocationInfoOutput = 0
		end
	else
		if gMapLocationInfoShown then
			SetValue("gMapLocationInfoScale", 0, "cosine", 0.25)
			gMapLocationInfoShown = false
		end
	end
end


function mapLocationListItem(loc)
	gMapLocationIndex = gMapLocationIndex + 1
	local highlight = 0
	if gMapFlashTargetList and loc.id > 0 then
		if math.floor(gMapLocationHighlight) == gMapLocationIndex then
			highlight = 1 - (gMapLocationHighlight-gMapLocationIndex)
		end
	end

	if gSelectedTarget == loc.id then
		UiColor(1,1,1)
	else
		local w = 0.7+highlight*0.3
		UiColor(w,w,w)
	end
	UiPush()
		if not loc.hidden then
			UiPush()
				UiAlign("center middle")
				UiTranslate(8, -6)
				if gSelectedTarget == loc.id then
					UiScale(0.5 + math.sin(GetTime()*10)*0.15)
				else
					UiScale(0.5 + highlight*0.3)
				end
				if loc.type == "player" then
					UiColor(1, 1, 1)
				elseif loc.type == "escape" then
					UiColor(0.5, 1, 0.5)
				elseif loc.type == "primary" then
					UiColor(1, 1, 0.5)
				elseif loc.type == "secondary" then
					UiColor(1, 1, 1)
				else
					UiColor(0.5, 0.8, 1)
				end
				if loc.ok then
					UiImage("hud/checkmark.png")
				else
					UiImage("hud/dot-small.png")
				end
			UiPop()
		end
		UiTranslate(20, 0)
		UiText(loc.name)
	UiPop()
	UiPush()
		UiTranslate(-5, -15)
		if UiIsMouseInRect(275, 20) then
			UiColor(1,1,1,0.1)
			UiRect(275, 20)
			if InputPressed("lmb") then
				mapSelectLocation(loc, true)
			end
		end
	UiPop()
	UiTranslate(0, 20)
end


function mapLocationMarker(loc)
	if not loc.hidden then 
		local x, y, dist = UiWorldToPixel(loc.pos)
		local scale = 30 / dist
		scale = clamp(scale, 0.4, 1)
		UiPush()
			UiTranslate(x, y)
			UiPush()
				UiAlign("center middle")
				if loc.type == "player" then
					scale = scale * 0.7
					UiPush()
						local pt = GetPlayerTransform()
						local xp, yp = UiWorldToPixel(loc.pos)
						local fwdPoint = TransformToParentPoint(pt, Vec(0,0,-10))
						fwdPoint[2] = loc.pos[2]
						local xf, yf = UiWorldToPixel(fwdPoint)
						UiRotate(math.deg(math.atan2(yp-yf, xf-xp)))
						UiScale(scale*5)
						UiImage("hud/location-fov.png")
					UiPop()
				end
				local a = 0
				if gSelectedTarget == loc.id then
					a = (math.sin(GetTime()*10)*0.5)
				end
				UiScale(scale * (1+a*0.8))
				if loc.type == "primary" then
					UiColor(1, 1, 0.5)
				elseif loc.type == "secondary" then
					UiColor(1, 1, 1)
				elseif loc.type == "escape" then
					UiColor(0.5, 1, 0.5)
				elseif loc.type == "player" then
					UiColor(1, 1, 1)
				else
					UiColor(0.5, 0.8, 1)
				end
				UiButtonHoverColor(.7, .7, .7)
				if UiImageButton("hud/location-dot.png") then
					mapSelectLocation(loc)
				end
			UiPop()
			if gSelectedTarget == loc.id and loc.type ~= "player" then
				UiPush()
					local h = math.floor(loc.pos[2] - (GetPlayerCameraTransform().pos[2] - 0.5))
					UiFont("regular.ttf", 20)
					UiTextShadow(0, 0, 0, 0.8, 1, 0.5)
					UiTranslate(40*scale, 0)
					UiAlign("left middle")				
					if h > 1 then
						UiText(h .. "m above player")
					elseif h < -1 then
						UiText((-h) .. "m below player")
					else
						UiText("Same level as player")
					end
				UiPop()
			end
		UiPop()
	end
end


function mapDrawTargetHint()
	UiPush()
		local showHint = gMapShowTargetHint and GetBool("hud.hasnotification")==false and gMapTimer > 1.5
		if #gMapPrimary == 0 and #gMapSecondary == 0 then
			showHint = false
		end
		if showHint then
			if gMapTargetHintAlpha == 0 then
				SetValue("gMapTargetHintAlpha", 1.0, "easeout", 0.3)
			end
		else
			if gMapTargetHintAlpha == 1 then
				SetValue("gMapTargetHintAlpha", 0.0, "easein", 0.1)
			end
		end
		UiColorFilter(1,1,1,gMapTargetHintAlpha)
		UiTranslate(290, 35)
		UiScale(gMapTargetHintAlpha, 1)
		drawHintArrow("Click target to show more info")	
	UiPop()
end


function drawMapInfo(missionId)
	UiPush()
		UiPush()
			missionTitle = gMissions[missionId].title
			missionType = gMissions[missionId].type
			missionDesc = gMissions[missionId].desc
			missionDesc2 = gMissions[missionId].desc2
			missionSecurityTitle = gMissions[missionId].securityTitle
			missionSecurityDesc = gMissions[missionId].securityDesc

			if HasKey("map.title") then
                missionTitle = GetString("map.title")
            end
            if HasKey("map.description") then
                missionDesc = GetString("map.description")
            end
            if HasKey("map.description2") then
                missionDesc2 = GetString("map.description2")
            end
            if HasKey("map.security.title") then
                missionSecurityTitle = GetString("map.security.title")
            end
            if HasKey("map.security.description") then
                missionSecurityDesc = GetString("map.security.description")
            end

			UiColor(0, 0, 0, 0.8)
			UiImageBox("common/box-solid-10.png", 500, gMapInfoHeight, 10, 10)
			UiTranslate(20, 36)
			UiColor(1,1,1)
			UiFont("bold.ttf", 32)
			UiAlign("left")
			UiText(missionTitle)
			UiTranslate(0, 22)
			if missionType then
				UiTranslate(0, 4)
				UiFont("bold.ttf", 22)
				UiText(missionType, true)
			end
			UiFont("regular.ttf", 20)
			UiWordWrap(450)
			UiColor(0.8, 0.8, 0.8)
			UiText(missionDesc, true)
			if missionDesc2 then
				UiTranslate(0, 10)
				if gMapTimer < 0.3 then
					if not gMapDesc2Scale then
						gMapDesc2Scale = 0
					end
					if gMapDesc2Scale == 1 then
						SetValue("gMapDesc2Scale", 0.0, "easein", 0.3)
					end
				else
					if gMapDesc2Scale == 0 then
						SetValue("gMapDesc2Scale", 1.0, "bounce", 0.5)
					end
				end
				UiColor(1.0, 1.0, 0.6)
				UiScale(1, gMapDesc2Scale)
				UiText(missionDesc2, true)
			end
			if missionSecurityTitle ~= "" then
				UiTranslate(0, 10)
				UiColor(1, 1, 1)
				UiFont("bold.ttf", 20)
				UiText("Security", true)
				UiFont("regular.ttf", 20)
				UiColor(.8, .5, .5)
				UiText(missionSecurityTitle, true)
				if missionSecurityDesc ~= "" then
					UiColor(0.8, 0.8, 0.8, 0.9)
					UiText(missionSecurityDesc, true)
				end
			end

			if not GetBool("game.path.recording") then
				if gMapHasLastPath or gMapHasBestPath then
					UiTranslate(0, 20)
					UiPush()
						UiButtonImageBox("common/box-solid-6.png", 6, 6, .25, .25, .25)
						UiFont("regular.ttf", 20)
						UiColor(1,1,1)

						UiPush()
							if not gMapHasLastPath then UiColorFilter(1,1,1,0.5) UiDisableInput() end
							if gMapPathType == 1 and gMapPathScale > 0 then UiFont("bold.ttf", 20) end
							if UiTextButton("Last path", 120, 26) then
								if (gMapPathType == 1 and gMapPathScale == 1) then
									SetValue("gMapPathScale", 0, "easein", 0.25)
								else
									SetValue("gMapPathScale", 1, "easeout", 0.25)
								end
								gMapPathType = 1
								Command("game.path.load", missionId.."-last")
							end
							if gMapPathType == 1 and gMapPathScale > 0 then
								UiColor(1,0.2,0.2)
								UiTranslate(8, -10)
								UiScale(0.5)
								UiImage("common/dot.png")
							end
						UiPop()
						UiTranslate(130, 0)

						UiPush()
							if not gMapHasBestPath then UiColorFilter(1,1,1,0.5) UiDisableInput() end
							if gMapPathType == 2 and gMapPathScale > 0 then UiFont("bold.ttf", 20) end
							if UiTextButton("Best path", 120, 26) then
								if (gMapPathType == 2 and gMapPathScale == 1) then
									SetValue("gMapPathScale", 0, "easein", 0.25)
								else
									SetValue("gMapPathScale", 1, "easeout", 0.25)
								end
								gMapPathType = 2
								Command("game.path.load", missionId.."-best")
							end
							if gMapPathType == 2 and gMapPathScale > 0 then
								UiColor(1,0.2,0.2)
								UiTranslate(8, -10)
								UiScale(0.5)
								UiImage("common/dot.png")
							end
						UiPop()
					UiPop()

					if gMapPathScale > 0 then
						UiPush()
							UiTranslate(0, 10)
							UiScale(1, gMapPathScale)
							UiTranslate(0, 20)
							UiAlign("left middle")
							UiColor(1,1,1)
							if gMapPathPlay then
								if UiImageButton("common/pause.png") then
									gMapPathPlay = false
								end
							else
								if UiImageButton("common/play.png") then
									gMapPathPlay = true
								end
							end
							UiTranslate(32, 0)
							local w = 380
							UiColor(.5, .5, .5)
							UiRect(w, 2)
							UiColor(1,1,1)
							local l = GetFloat("game.path.length")
							if l > 0 then
								--l = 60 -- GET FROM MISSION FILE
								local p = GetFloat("game.path.pos")
								if gMapPathPlay then
									p = math.min(p + GetTimeStep(), l)
									SetFloat("game.path.pos", p)
								end
								local val = GetFloat("game.path.pos") / l
								UiPush()
									UiAlign("center middle")
									val = UiSlider("common/dot.png", "x", val*w, 0, w) / w
									local n = val * l
									if gMapPathPlay and math.abs(n-p) > 0.1 then
										gMapPathPlay = false
									end
									SetFloat("game.path.pos", n)
								UiPop()
								UiTranslate(w+10, 0)
								UiText(math.floor(val*l*10)/10)
							end
						UiPop()
						UiTranslate(0, 30 * gMapPathScale)
					end
					UiTranslate(0, 20)
					SetFloat("game.path.alpha", gMapPathScale)
				else
					SetFloat("game.path.alpha", 0)
				end
			else
				SetFloat("game.path.alpha", 0)
			end
			_,gMapInfoHeight = UiGetRelativePos()
		UiPop()

		UiTranslate(0, gMapInfoHeight+20)

		UiPush()
			UiColor(0, 0, 0, 0.8)
			UiImageBox("common/box-solid-10.png", 300, gMapListHeight, 10, 10)
			UiWindow(300, gMapListHeight)
			 
			UiTranslate(20, 40)

			UiColor(.8, .8, .8)
			UiFont("bold.ttf", 20)
			UiText("Locations", true)
			UiFont("regular.ttf", 20)

			gMapLocationIndex = 0
			for i=1,#gMapLocations do
				mapLocationListItem(gMapLocations[i])
			end

			mapDrawTargetHint()
			
			if #gMapPrimary > 0 then
				UiTranslate(0, 20)
				UiColor(1, 1, 0.6)
				UiFont("bold.ttf", 20)
				UiText("Primary targets", true)
				UiFont("regular.ttf", 20)
				for i=1,#gMapPrimary do
					mapLocationListItem(gMapPrimary[i])
				end
			end

			if #gMapSecondary > 0 then
				UiTranslate(0, 20)
				UiColor(1, 1, 1)
				UiFont("bold.ttf", 20)
				if #gMapPrimary == 0 then
					UiText("Available targets", true)
				else
					UiText("Secondary targets", true)
				end
				UiFont("regular.ttf", 20)
				for i=1,#gMapSecondary do
					mapLocationListItem(gMapSecondary[i])
				end
			end

			gMapLocationHighlight = gMapLocationHighlight + GetTimeStep()*3
			if gMapLocationHighlight > gMapLocationIndex*2 then
				gMapLocationHighlight = 0
			end

			UiTranslate(0, 10)
			_,gMapListHeight = UiGetRelativePos()
		UiPop()

		local showLargeUI = GetBool("game.largeui")
		local w,h = UiGetImageSize(gMapLocationInfoImage)
		local imageScale = 1
		if w > 250 then
			imageScale = imageScale * (250/w)
		end
		if showLargeUI and (gMapInfoHeight+ 20 + gMapListHeight + 20  +  h*imageScale + 30) > 660  then
			UiTranslate(320, 0)
		else
			UiTranslate(0, gMapListHeight+20)
		end

		if gMapLocationInfoScale > 0 then
			UiPush()
				UiScale(1, gMapLocationInfoScale)
				UiColor(0, 0, 0, 0.8)
				UiImageBox("common/box-solid-10.png", 300, gMapLocationInfoHeight, 10, 10)
				UiWindow(300, gMapLocationInfoHeight)

				UiTranslate(20, 30)
				UiColor(1,1,1)

				if gMapLocationInfoImage ~= "" then
					UiPush()
						UiAlign("center top")
						UiTranslate(300*0.5-20, 0)
						UiScale(imageScale)
						UiImage(gMapLocationInfoImage)
					UiPop()
					UiTranslate(0, h*imageScale + 30)
				end
	
				UiFont("bold.ttf", 20)
				UiWordWrap(250)
				if gMapLocationInfoName ~= "" then
					UiText(gMapLocationInfoName, true)
				end
				if gMapLocationInfoScale > 0.9 and gMapLocationInfoOutput < 1.0 then
					if gMapLocationInfoOutput == 0 then
						UiSound("hud/location-info.ogg")
					end
					gMapLocationInfoOutput = gMapLocationInfoOutput + GetTimeStep()
				end
				UiFont("regular.ttf", 20)
				UiColor(0.8, 0.8, 0.8)
				UiText(gMapLocationInfoText, true, gMapLocationInfoOutput * string.len(gMapLocationInfoText))
			
				UiTranslate(0, 4)
				_,gMapLocationInfoHeight = UiGetRelativePos()
			UiPop()
		end

	UiPop()
end

function drawMap(missionId)
	local enabled = GetBool("game.map.enabled")
	gMapFade = GetFloat("game.map.fade")
	
	if math.min(1.0, gMapFade) == 1 then
		gMapTimer = gMapTimer + GetTimeStep()
	else
		gMapTimer = 0
	end

	if enabled then
		if not gMapInfoShown and gMapFade > 0.5 then
			gMapInfoShown = true
			SetValue("gMapInfoScale", 1, "easeout", 0.4)
			gSelectedTarget = 0
			gMapLocationInfoShown = false
			gMapLocationInfoScale = 0
		end
	else
		if gMapInfoShown and gMapFade < 0.9 then 
			gMapInfoShown = false
			SetValue("gMapInfoScale", 0, "easein", 0.4)
		end
	end

	if gMapFade > 0 then
		mapGetWorldInfo()

		UiPush()
			local showLargeUI = GetBool("game.largeui")
			if showLargeUI then
				UiScale(1.3)
			end
			UiPush()
				UiColorFilter(1,1,1,gMapFade*gMapFade)
				for i=1, #gMapLocations do
					mapLocationMarker(gMapLocations[i])
				end
				for i=1, #gMapPrimary do
					mapLocationMarker(gMapPrimary[i])
				end
				for i=1, #gMapSecondary do
					mapLocationMarker(gMapSecondary[i])
				end
			UiPop()

			UiTranslate(20-(1-gMapInfoScale)*700, 20)
			drawMapInfo(missionId)
		UiPop()
	end
end
