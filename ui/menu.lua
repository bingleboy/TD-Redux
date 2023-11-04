#include "game.lua"
#include "options.lua"
#include "score.lua"
#include "debug.lua"
#include "promo.lua"

bgItems = {nil, nil}
bgCurrent = 0
bgPromoIndex = {}

-- Context Menu
showContextMenu = false
showBuiltinContextMenu = false
showSubscribedContextMenu = false
getContextMousePos = false
contextItem = ""
contextPosX = 0
contextPosY = 0
contextScale = 0

gActivations = 0

promo_full_initiated = false


-- Yes-No popup
yesNoPopup = 
{
	show = false,
	yes  = false,
	text = "",
	item = "",
	yes_fn = nil
}
function yesNoInit(text,item,fn)
	yesNoPopup.show = true
	yesNoPopup.yes  = false
	yesNoPopup.text = text
	yesNoPopup.item = item
	yesNoPopup.yes_fn = fn
end

function yesNo()
	local clicked = false
	UiModalBegin()
	UiPush()
		local w = 500
		local h = 160
		UiTranslate(UiCenter()-250, UiMiddle()-85)
		UiAlign("top left")
		UiWindow(w, h)
		UiColor(0.2, 0.2, 0.2)
		UiImageBox("common/box-solid-6.png", w, h, 6, 6)
		UiColor(1, 1, 1)
		UiImageBox("common/box-outline-6.png", w, h, 6, 6)

		if InputPressed("esc") then
			yesNoPopup.yes = false
			return true
		end

		UiColor(1,1,1,1)
		UiTranslate(16, 16)
		UiPush()
			UiTranslate(60, 20)
			UiFont("regular.ttf", 22)
			UiColor(1,1,1)
			UiText(yesNoPopup.text)
		UiPop()
		
		UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1)
		UiTranslate(77, 70)
		UiFont("regular.ttf", 22)
		UiColor(0.6, 0.2, 0.2)
		UiImageBox("common/box-solid-6.png", 140, 40, 6, 6)
		UiFont("regular.ttf", 26)
		UiColor(1,1,1,1)
		if UiTextButton("Yes", 140, 40) then
			yesNoPopup.yes = true
			clicked = true
		end

		UiTranslate(170, 0)
		if UiTextButton("No", 140, 40) then
			yesNoPopup.yes = false
			clicked = true
		end
	UiPop()
	UiModalEnd()
	return clicked
end

function deleteModCallback()
	if yesNoPopup.item ~= "" then
		Command("mods.delete", yesNoPopup.item)
		updateMods()
	end
end


function bgLoad(i)
	bg = {}
	bg.i = i+1
	bg.t = 0
	bg.x = 0
	bg.y = 0
	bg.vx = 0
	bg.vy = 0
	return bg
end


function bgDraw(bg)
	if bg then
		UiPush()
			local dt = GetTimeStep()
			bg.t = bg.t + dt
			local a = math.min(bg.t*0.6, 1.0)
			UiColor(1,1,1,a)
			UiScale(1.03 + bg.t*0.01)
			UiTranslate(bg.x, bg.y)
			if HasFile(slideshowImages[bg.i].image) then
				UiImage(slideshowImages[bg.i].image)
			end
		UiPop()
	end
end

bgIndex = 0
bgInterval = 6
bgTimer = bgInterval

function initSlideShowLevel(level)
	local i=1
	while HasFile("menu/slideshow/"..level..i..".jpg") do
		local item = {}
		item.image = "menu/slideshow/"..level..i..".jpg"
		item.promo = ""
		slideshowImages[#slideshowImages+1] = item
		i = i + 1
	end
end

function initSlideShowPromo()
	local groups = ListKeys("promo.groups")
	for i=1, #groups do
		local groupKey = "promo.groups."..groups[i]
		local items = ListKeys(groupKey.. ".items")
		for j=1, #items do
			local img = GetString(groupKey..".items."..items[j]..".full_image")
			if img ~= "" then
				local item = {}
				item.image = img
				item.promo = groupKey..".items."..items[j]
				slideshowImages[#slideshowImages+1] = item
				promoInitFull(item.promo)
			end
		end
	end

	bgPromoIndex[0] = #slideshowImages-1
	bgPromoIndex[1] = 1
end

function initSlideshow()
	slideshowImages = {}
	initSlideShowLevel("hub")
	if isLevelUnlocked("lee") then
		initSlideShowLevel("lee")
	end
	if isLevelUnlocked("marina") then
		initSlideShowLevel("marina")
	end
	if isLevelUnlocked("mansion") then
		initSlideShowLevel("mansion")
	end
	if isLevelUnlocked("mall") then
		initSlideShowLevel("mall")
	end
	if isLevelUnlocked("caveisland") then
		initSlideShowLevel("caveisland")
	end
	if isLevelUnlocked("frustrum") then
		initSlideShowLevel("frustrum")
	end
	if isLevelUnlocked("carib") then
		initSlideShowLevel("carib")
	end
	if isLevelUnlocked("factory") then
		initSlideShowLevel("factory")
	end
	if isLevelUnlocked("cullington") then
		initSlideShowLevel("cullington")
	end
	if HasKey("savegame.mod.builtin-artvandals.cinematic.complete") then
		initSlideShowLevel("tillaggaryd")
	end

	--Scramble order
	for i=1, #slideshowImages do
		local j = math.random(1, #slideshowImages)
		local tmp = slideshowImages[j]
		slideshowImages[j] = slideshowImages[i]
		slideshowImages[i] = tmp
	end

	--Reset the slideshow ticker to point at first image with no previous image
	bgPromoIndex[0] = -1
	bgPromoIndex[1] = -1

	bgIndex = 0
	bgCurrent = 0
	bgItems[0] = bgLoad(bgIndex)
	bgItems[1] = nil
	bgTimer = bgInterval	
end

function init()
	SetInt("savegame.startcount", GetInt("savegame.startcount")+1)
	
	betterOptions=false
	betterOptionsOpen=false
	flames=0
	
	if not HasKey("options.better.customLogo") then
		SetBool("options.better.customLogo",true)
	end
	
	gMods = {}
	for i=1,3 do
		gMods[i] = {}
		gMods[i].items = {}
		gMods[i].pos = 0
		gMods[i].possmooth = 0
		gMods[i].sort = 0
		gMods[i].filter = 0
		gMods[i].dragstarty = 0
		gMods[i].isdragging = false
	end
	gMods[1].title = "Built-In"
	gMods[2].title = "Subscribed"
	gMods[3].title = "Local files"
	gModSelected = ""
	gModSelectedScale = 0

	updateMods()
	initSlideshow()

	gOptionsScale = 0
	gSandboxScale = 0
	gChallengesScale = 0
	gExpansionsScale =0  
	gPlayScale = 0
	
	gChallengeLevel = ""
	gChallengeLevelScale = 0
	gChallengeSelected = ""

	gCreateScale = 0
	gPublishScale = 0
	
	local showLargeUI = GetBool("game.largeui")
	gUiScaleUpFactor = 1.0
    if showLargeUI then
		gUiScaleUpFactor = 1.2
	end

	gDeploy = GetBool("game.deploy")
end


function isLevelUnlocked(level)
	local missions = ListKeys("savegame.mission")
	local levelMissions = {}
	for i=1,#missions do
		local missionId = missions[i]
		if gMissions[missionId] and GetBool("savegame.mission."..missionId) then
			if missionId ~= "mall_intro" and missionId ~= "factory_espionage" and gMissions[missionId].level == level then
				return true
			end
		end
	end
	return false
end


function selectLevel(selected, alwaysUnlocked, challenges)
	if not gLevelSelectScroll then
		gLevelSelectScroll = 0
		SetValue("gLevelSelectScroll", 1, "cosine", 0.5)
	end
	if not selected then selected = "" end
	local ret = selected
	local visibleLevels = 0
	UiPush()
		local w = 740
		UiTranslate(60, 0)
		UiWindow(w, 200, true)
		UiTranslate(150 - gLevelSelectScroll*150, 0)
		for i=1, #gSandbox do
			local level = gSandbox[i].level
			local image = gSandbox[i].image
			local name = gSandbox[i].name
			local show = true
			if challenges and (level == "cullington" or level == "hub_carib") and (not GetBool("options.better.forceShowChallenges")) then
				show = false
			end
			if show then
				UiPush()
					if visibleLevels+1 < gLevelSelectScroll or visibleLevels+1 > gLevelSelectScroll + 4 then
						UiDisableInput()
					end
					local locked = not (isLevelUnlocked(level) or alwaysUnlocked)

					-- Carib hub is a special case since it doesn't contain any missions to check against, so unlocking once the travel email is recieved
					if level == "hub_carib" and GetInt("savegame.message.carib_travel") > 0 then 
						locked = false 
					end

					UiPush()
						if locked then
							UiDisableInput()
							UiColorFilter(.5, .5, .5)
						end
						if level ~= selected and selected ~= "" then
							UiColorFilter(1,1,1,0.5)
						end
						UiScale(0.64,0.64)
						UiImageOverlayAlpha(image,"menu/level/mask2.png","menu/level/mask.png",0,0,350,200,0,0,350,200)
						UiColor(0,0,0,0)
						if UiImageButton(image) then
							UiSound("common/click.ogg")
							ret = level
						end
					UiPop()
					if locked then
						UiPush()
							UiTranslate(64, 64)
							UiAlign("center middle")
							UiImage("menu/locked.png")
						UiPop()
						if UiIsMouseInRect(128, 128) then
							UiPush()
								UiAlign("center middle")
								UiTranslate(64,  180)
								UiFont("regular.ttf", 18)
								UiColor(.8, .8, .8)
								UiText("Play campaign or\nunlock in options")
							UiPop()
						end
					end

					UiAlign("center")
					UiTranslate(64, 150)
					if level == selected then
						UiColor(0.8, 0.8, 0.8)
						UiFont("bold.ttf", 22)
					else
						UiColor(0.8, 0.8, 0.8)
						UiFont("regular.ttf", 22)
					end
					UiText(name)
				UiPop()
				UiTranslate(150, 0)
				visibleLevels = visibleLevels + 1
			end
		end
	UiPop()
	UiPush()
		UiPush()
			if gLevelSelectScroll > 1 then
				UiColor(1,1,1, 0.8)
			else
				UiColor(1,1,1, 0.1)
				UiDisableInput()
			end
			UiTranslate(15, 40)
			if UiImageButton("menu/arrow-left.png") or InputPressed("left") or InputPressed("leftarrow") then
				SetValue("gLevelSelectScroll", 1, "cosine", 0.3)
			end
		UiPop()
		UiPush()
			if gLevelSelectScroll < visibleLevels-4 then
				UiColor(1,1,1, 0.8)
			else
				UiColor(1,1,1, 0.1)
				UiDisableInput()
			end
			UiTranslate(810, 40)
			if UiImageButton("menu/arrow-right.png") or InputPressed("right") or InputPressed("rightarrow") then
				SetValue("gLevelSelectScroll", visibleLevels-4, "cosine", 0.3)
			end
		UiPop()
	UiPop()
	gLevelSelectScroll = math.min(gLevelSelectScroll, visibleLevels-4)
	return ret
end

function drawSandbox(scale)
	local open = true
	UiPush()
		local w = 840
		local h = 440
		UiTranslate(UiCenter(), UiMiddle())
		UiScale(scale*gUiScaleUpFactor)
		UiColorFilter(1, 1, 1, scale)
		UiColor(0,0,0, 0.5)
		UiAlign("center middle")
		UiImageBox("common/box-solid-shadow-50.png", w, h, -50, -50)
		UiWindow(w, h)
		UiAlign("left top")
		UiColor(1,1,1)
		if InputPressed("esc") or (not UiIsMouseInRect(UiWidth(), UiHeight()) and InputPressed("lmb")) then
			open = false
		end

		UiPush()
			UiFont("bold.ttf", 48)
			UiColor(1,1,1)
			UiAlign("center")
			UiTranslate(UiCenter(), 80)
			UiText("SANDBOX")
		UiPop()
		
		UiPush()
			UiFont("regular.ttf", 22)
			local tw, th = UiGetTextSize("Free roam sandbox play with unlimited resources and no challenge.")
			UiTranslate(w/2 - tw/2, 90)
			UiWordWrap(tw)
			UiColor(0.8, 0.8, 0.8)
			UiText("Free roam sandbox play with unlimited resources and no challenge.Play the campaign to unlock more environments and tools. If you want to unlock everything without playing through the campaign you can enable that in the             menu.")
			UiTranslate(201, 66)
			UiColor(1, 0.95, .7)
			if UiTextButton("options") then
				optionsTab = "game"
				SetValue("gOptionsScale", 1.0, "easeout", 0.25)
			end
		UiPop()

		UiPush()
			UiTranslate(0, 220)
			local selected = selectLevel(nil, GetInt("options.game.sandbox.unlocklevels") == 1, false)
			if selected then
				for i=1, #gSandbox do
					if selected == gSandbox[i].level then
						StartLevel(gSandbox[i].id, gSandbox[i].file, gSandbox[i].layers)
					end
				end
			end
		UiPop()

	UiPop()
	return open
end

function drawExpansions(scale)
	local open = true
	UiPush()
		local w = 1024
		local h = 440
		UiTranslate(UiCenter(), UiMiddle())
		UiScale(scale*gUiScaleUpFactor)
		UiColorFilter(1, 1, 1, scale)
		UiColor(0,0,0, 0.5)
		UiAlign("center middle")
		UiImageBox("common/box-solid-shadow-50.png", w, h, -50, -50)
		UiWindow(w, h)
		UiAlign("left top")
		UiColor(1,1,1)
		if InputPressed("esc") or (not UiIsMouseInRect(UiWidth(), UiHeight()) and InputPressed("lmb")) then
			open = false
		end

		UiPush()
			UiFont("bold.ttf", 48)
			UiColor(1,1,1)
			UiAlign("center")
			UiTranslate(UiCenter(), 80)
			UiText("EXPANSIONS")
		UiPop()
		
		UiPush()
			UiFont("regular.ttf", 22)
			local tw = 550
			UiTranslate(w/2 - tw/2 + 20, 90)
			UiWordWrap(tw)
			UiColor(0.8, 0.8, 0.8)
			UiText("Expansions are created by the Teardown team. You are welcome to play them at any time, but they are intended to be played once the campaign is finished.")
		UiPop()

		UiPush()
			local w = 800
			UiAlign("center middle")
			UiTranslate(UiCenter(),UiMiddle()+100)
			--UiRect(200,200)
			UiTranslate(-w/4, 0)
			for i=1, #gExpansions do
				local level = gExpansions[i].level
				local image = gExpansions[i].image
				local name = gExpansions[i].name
				local available = gExpansions[i].available
				UiPush()
					UiAlign("center middle")
					UiPush()
						if not available then
							UiDisableInput()
							UiColorFilter(.5, .5, .5)
						end
						--UiTranslate(-50, 0)
						if UiImageButton(image) then
							UiSound("common/click.ogg")
							Command("mods.play", level)
						end
					UiPop()
					if not available then
						UiPush()
							UiAlign("center middle")
							UiImage("menu/locked.png")
						UiPop()
						if UiIsMouseInRect(128, 128) then
							UiPush()
								UiAlign("center middle")
								UiFont("regular.ttf", 20)
								UiColor(.8, .8, .8)
								UiTranslate(0,30)
								UiText("Coming soon")
							UiPop()
						end
					end
					
					UiTranslate(0, 75)
					UiColor(0.8, 0.8, 0.8)
					UiFont("regular.ttf", 22)
					UiText(name)
				UiPop()
				UiTranslate(450, 0)
			end
		UiPop()
	UiPop()
	return open
end


--Return list of challenges for level, sorted alphabetically with unlocked first
function getChallengesForLevel(level)
	local ret = {}
	local locked = {}
	for id, ch in pairs(gChallenges) do
		if ch.level == level then
			if isChallengeUnlocked(id) then
				ret[#ret+1] = id
			else
				locked[#locked+1] = id
			end
		end
	end
	table.sort(ret, function(a,b) return gChallenges[a].title < gChallenges[b].title end)
	table.sort(locked, function(a,b) return gChallenges[a].title < gChallenges[b].title end)
	for i=1,#locked do 
		ret[#ret+1] = locked[i]
	end
	return ret
end


function isChallengeUnlocked(id)
	local c = gChallenges[id]
	if c.unlockMission then
		return GetInt("savegame.mission." .. c.unlockMission .. ".score") > 0
	end
	return true
end


function getChallengeStars(id)
	return GetInt("savegame.challenge." .. id .. ".stars")
end


function getChallengeScoreDetails(id)
	return GetString("savegame.challenge." .. id .. ".scoredetails")
end


function drawChallenges(scale)
	local open = true
	UiPush()
		local w = 840
		local h = 400 + gChallengeLevelScale*300
		UiTranslate(UiCenter(), UiMiddle())
		UiScale(scale*gUiScaleUpFactor)
		UiColorFilter(1, 1, 1, scale)
		UiColor(0,0,0, 0.5)
		UiAlign("center middle")
		UiImageBox("common/box-solid-shadow-50.png", w, h, -50, -50)
		UiWindow(w, h)
		UiAlign("left top")
		UiColor(1,1,1)
		if InputPressed("esc") or (not UiIsMouseInRect(UiWidth(), UiHeight()) and InputPressed("lmb")) then
			open = false
		end

		UiPush()
			UiFont("bold.ttf", 48)
			UiColor(1,1,1)
			UiAlign("center")
			UiTranslate(UiCenter(), 80)
			UiText("CHALLENGES")
		UiPop()
		
		UiPush()
			UiFont("regular.ttf", 22)
			local tw, th = UiGetTextSize("You play challenges with the same tools and upgrades you have unlocked in the campaign.")
			UiTranslate(w/2 - tw/2, 90)
			UiWordWrap(tw)
			UiColor(0.8, 0.8, 0.8)
			UiText("Challenges are experimental game modes where you can try out your skills. Unlock new environments and challenges by playing the campaign. You play challenges with the same tools and upgrades you have unlocked in the campaign.")
		UiPop()
	
		UiPush()
			UiTranslate(0, 190)
			local selected = selectLevel(gChallengeLevel, false, true)
			if selected ~= gChallengeLevel then
				SetValue("gChallengeLevelScale", 1, "cosine", 0.25)
				gChallengeLevel = selected
				gChallengeSelected = ""
			end
		UiPop()
		
		UiTranslate(34, 400)
		if gChallengeLevelScale > 0 then
			UiPush()
				UiScale(1, gChallengeLevelScale)
				UiColor(1,1,1)
				UiPush()
					UiPush()
						UiTranslate(10, 0)
						UiFont("bold.ttf", 32)
						UiText("Challenge")
					UiPop()
					UiTranslate(0, 40)
					UiWindow(200, 200)
					UiColor(1,1,1,0.05)
					UiImageBox("common/box-solid-6.png", UiWidth(), UiHeight(), 6, 6)
					UiTranslate(10, 28)
					UiFont("regular.ttf", 22)
					UiColor(1,1,1)
					local list = getChallengesForLevel(gChallengeLevel)
					UiAlign("left")
					local lockedInfo = false
					if #list == 0 then
						UiColor(1, 1, 1, 0.5)
						UiTranslate(430, 80)
						UiText("Not available")
					end
					for i=1, #list do
						local id = list[i]
						local mouseOver = false
						UiPush()
							local unlocked = isChallengeUnlocked(id)
							UiTranslate(-10, -18)
							UiColor(0,0,0,0)
							if gChallengeSelected == id then
								UiColor(1,1,1,0.1)
							else
								if UiIsMouseInRect(UiWidth(), 28) then
									mouseOver = true
									UiColor(0,0,0,0.1)
									if not unlocked then
										lockedInfo = true
									end
								end
							end
							if unlocked and mouseOver then
								if InputPressed("lmb") then
									UiSound("terminal/message-select.ogg")
									gChallengeSelected = id
								end
							end
							UiRect(UiWidth(), 28)
						UiPop()
						UiPush()
							if not unlocked then
								UiColor(1,1,1,0.5)
								UiPush()
									UiTranslate(170, -7)
									UiAlign("center middle")
									UiImage("menu/locked-small.png")
								UiPop()
							else
								local stars = getChallengeStars(id)
								if stars > 0 then
									UiPush()
										UiTranslate(170, -6)
										UiAlign("center middle")
										UiScale(0.6)
										for i=1,stars do
											UiImage("common/star.png")
											UiTranslate(-25, 0)
										end
									UiPop()
								end
							end
							UiTranslate(0, 2)
							UiText(gChallenges[id].title, true)
						UiPop()
						UiTranslate(0, 28)
					end
				UiPop()
				if lockedInfo then
					UiPush()
						UiAlign("center middle")
						UiTranslate(90,  270)
						UiFont("regular.ttf", 20)
						UiColor(.8, .8, .8)
						UiText("Unlocked in\ncampaign")
					UiPop()
				end
				UiPush()
					UiTranslate(250, 0)
					if gChallengeSelected ~= "" then
						UiPush()
							UiTranslate(10, 0)
							UiFont("bold.ttf", 32)
							UiText(gChallenges[gChallengeSelected].title)
						UiPop()
					end
					UiTranslate(0, 40)
					UiWindow(520, 200)
					UiColor(1,1,1,0.05)
					UiImageBox("common/box-solid-6.png", UiWidth(), UiHeight(), 6, 6)
					UiColor(1,1,1)

					if gChallengeSelected ~= "" then
						local challenge = gChallenges[gChallengeSelected]
						UiPush()
							UiTranslate(10, 10)
							UiFont("regular.ttf", 20)
							UiWordWrap(UiWidth()-20)
							UiText(challenge.desc)
						UiPop()
						local stars = getChallengeStars(gChallengeSelected)
						local details = getChallengeScoreDetails(gChallengeSelected)
						if stars > 0 or details ~= "" then
							UiPush()
								UiTranslate(20, 125)
								UiFont("regular.ttf", 20)
								UiPush()
									UiColor(1,1,0.5)
									for i=1,stars do
										UiImage("common/star.png")
										UiTranslate(25, 0)
									end
									for i=stars+1, 5 do
										UiImage("common/star-outline.png")
										UiTranslate(25, 0)
									end
								UiPop()
								UiTranslate(0, 30)
								UiText(details)
							UiPop()
						end
						UiPush()
							UiFont("regular.ttf", 26)
							UiTranslate(UiWidth()-120, UiHeight()-40)
							UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.7)
							UiAlign("center middle")	
							UiPush()
								UiColor(.7, 1, .8, 0.2)
								UiImageBox("common/box-solid-6.png", 200, 40, 6, 6)
							UiPop()
							if UiTextButton("Play", 200, 40) then
								StartLevel(gChallengeSelected, challenge.file, challenge.layers)
							end
						UiPop()	
					end
				UiPop()
			UiPop()
		end
	UiPop()
	return open
end

function listMods(list, w, h, issubscribedlist)
	local ret = ""
	local rmb_pushed = false
	if list.isdragging and InputReleased("lmb") then
		list.isdragging = false
	end
	UiPush()
		UiAlign("top left")
		UiFont("regular.ttf", 22)

		local mouseOver = UiIsMouseInRect(w+12, h)
		if mouseOver then
			list.pos = list.pos + InputValue("mousewheel")
			if list.pos > 0 then
				list.pos = 0
			end
		end
		if not UiReceivesInput() then
			mouseOver = false
		end

		local itemsInView = math.floor(h/UiFontHeight())
		if #list.items > itemsInView then
			local scrollCount = (#list.items-itemsInView)
			if scrollCount < 0 then scrollCount = 0 end

			local frac = itemsInView / #list.items
			local pos = -list.possmooth / #list.items
			if list.isdragging then
				local posx, posy = UiGetMousePos()
				local dy = 0.0445 * (posy - list.dragstarty)
				list.pos = -dy / frac
			end

			UiPush()
				UiTranslate(w, 0)
				UiColor(1,1,1, 0.07)
				UiImageBox("common/box-solid-4.png", 14, h, 4, 4)
				UiColor(1,1,1, 0.2)

				local bar_posy = 2 + pos*(h-4)
				local bar_sizey = (h-4)*frac
				UiPush()
					UiTranslate(2,2)
					if bar_posy > 2 and UiIsMouseInRect(8, bar_posy-2) and InputPressed("lmb") then
						list.pos = list.pos + frac * #list.items
					end
					local h2 = h - 4 - bar_sizey - bar_posy
					UiTranslate(0,bar_posy + bar_sizey)
					if h2 > 0 and UiIsMouseInRect(10, h2) and InputPressed("lmb") then
						list.pos = list.pos - frac * #list.items
					end
				UiPop()

				UiTranslate(2,bar_posy)
				UiImageBox("common/box-solid-4.png", 10, bar_sizey, 4, 4)
				--UiRect(10, bar_sizey)
				if UiIsMouseInRect(10, bar_sizey) and InputPressed("lmb") then
					local posx, posy = UiGetMousePos()
					list.dragstarty = posy
					list.isdragging = true
				end
			UiPop()
			list.pos = clamp(list.pos, -scrollCount, 0)
		else
			list.pos = 0
			list.possmooth = 0
		end

		UiWindow(w, h, true)
		UiColor(1,1,1,0.07)
		UiImageBox("common/box-solid-6.png", w, h, 6, 6)

		UiTranslate(10, 24)
		if list.isdragging then
			list.possmooth = list.pos
		else
			list.possmooth = list.possmooth + (list.pos-list.possmooth) * 10 * GetTimeStep()
		end
		UiTranslate(0, list.possmooth*22)

		UiAlign("left")
		UiColor(0.95,0.95,0.95,1)
		for i=1, #list.items do
			UiPush()
				UiTranslate(10, -18)
				UiColor(0,0,0,0)
				local id = list.items[i].id
				if gModSelected == id then
					UiColor(1,1,1,0.1)
				else
					if mouseOver and UiIsMouseInRect(228, 22) then
						UiColor(0,0,0,0.1)
						if InputPressed("lmb") then
							UiSound("terminal/message-select.ogg")
							ret = id
						end
					end
				end
				if mouseOver and UiIsMouseInRect(228, 22) and InputPressed("rmb") then
					ret = id
					rmb_sel = id;
					rmb_pushed = true
				end
				UiRect(w, 22)
			UiPop()

			if list.items[i].override then
				UiPush()
				UiTranslate(-10, -18)
				if mouseOver and UiIsMouseInRect(22, 22) and InputPressed("lmb") then
					if list.items[i].active then
						Command("mods.deactivate", list.items[i].id)
						updateMods()
						list.items[i].active = false
					else
						Command("mods.activate", list.items[i].id)
						updateMods()
						list.items[i].active = true
					end
				end
				UiPop()

				UiPush()
					UiTranslate(2, -6)
					UiAlign("center middle")
					UiScale(0.5)
					if list.items[i].active then
						UiColor(1, 1, 0.5)
						UiImage("menu/mod-active.png")
					else
						UiImage("menu/mod-inactive.png")
					end
				UiPop()
			end
			UiPush()
				UiTranslate(10, 0)
				if issubscribedlist and list.items[i].showbold then
					UiFont("bold.ttf", 20)
				end
				UiText(list.items[i].name)
			UiPop()
			UiTranslate(0, 22)
		end

		if not rmb_pushed and mouseOver and InputPressed("rmb") then
			rmb_pushed = true
		end

	UiPop()

	return ret, rmb_pushed
end


function getActiveModCount(builtinmod, steammod, localmod)

	local count = 0

	local mods = ListKeys("mods.available")
	for i=1,#mods do
		local id = mods[i]
		local active = GetBool("mods.available."..id..".active")
		if active then
			if builtinmod and string.sub(id,1,8) == "builtin-" then
				count = count+1
			end
			if steammod and string.sub(id,1,6) == "steam-" then
				count = count+1
			end
			if localmod and string.sub(id,1,6) == "local-" then
				count = count+1
			end
		end
	end

	return count
end


function deactivateMods(builtinmod, steammod, localmod)
	local mods = ListKeys("mods.available")
	for i=1,#mods do
		local id = mods[i]
		local active = GetBool("mods.available."..id..".active")
		if active then
			if builtinmod and string.sub(id,1,8) == "builtin-" then
				Command("mods.deactivate", id)
			end
			if steammod and string.sub(id,1,6) == "steam-" then
				Command("mods.deactivate", id)
			end
			if localmod and string.sub(id,1,6) == "local-" then
				Command("mods.deactivate", id)
			end
		end
	end
end


function updateMods()
	Command("mods.refresh")

	gMods[1].items = {}
	gMods[2].items = {}
	gMods[3].items = {}

	local mods = ListKeys("mods.available")
	local foundSelected = false
	for i=1,#mods do
		local mod = {}
		mod.id = mods[i]
		mod.name = GetString("mods.available."..mods[i]..".listname")
		mod.override = GetBool("mods.available."..mods[i]..".override") and not GetBool("mods.available."..mods[i]..".playable")
		mod.active = GetBool(mods[i]..".active")
		mod.steamtime = GetInt("mods.available."..mods[i]..".steamtime")
		mod.subscribetime = GetInt("mods.available."..mods[i]..".subscribetime")
		mod.showbold = false;

		local iscontentmod = GetBool("mods.available."..mods[i]..".playable")
		if string.sub(mod.id,1,8) == "builtin-" then
			if gMods[1].filter == 0 or (gMods[1].filter == 1 and not iscontentmod) or (gMods[1].filter == 2 and iscontentmod) then
				gMods[1].items[#gMods[1].items+1] = mod
			end
		end
		if string.sub(mod.id,1,6) == "steam-" then
			mod.showbold = GetBool("mods.available."..mods[i]..".showbold")
			if gMods[2].filter == 0 or (gMods[2].filter == 1 and not iscontentmod) or (gMods[2].filter == 2 and iscontentmod) then
				gMods[2].items[#gMods[2].items+1] = mod
			end
		end
		if string.sub(mod.id,1,6) == "local-" then
			if gMods[3].filter == 0 or (gMods[3].filter == 1 and not iscontentmod) or (gMods[3].filter == 2 and iscontentmod) then
				gMods[3].items[#gMods[3].items+1] = mod
			end
		end
		if gModSelected ~= "" and gModSelected == mods[i] then
			foundSelected = true
		end
	end
	if gModSelected ~= "" and not foundSelected then
		gModSelected = ""
	end

	for i=1,3 do
		if gMods[i].sort == 0 then
			table.sort(gMods[i].items, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
		elseif gMods[i].sort == 1 then
			table.sort(gMods[i].items, function(a, b) return a.steamtime > b.steamtime end)
		else
			table.sort(gMods[i].items, function(a, b) return a.subscribetime > b.subscribetime end)
		end
	end
end


function selectMod(mod)
	gModSelected = mod
	if mod ~= "" then
		Command("mods.updateselecttime", gModSelected)
	Command("game.selectmod", gModSelected)
	end
end


function contextMenu(sel_mod)
	local open = true
	UiModalBegin()
	UiPush()
		local w = 177
		local h = 128
		if sel_mod == "" then
			h = 85
		end

		local x = contextPosX
		local y = contextPosY
		UiTranslate(x, y)
		UiAlign("left top")
		UiScale(1, contextScale)
		UiWindow(w, h, true)
		UiColor(0.2,0.2,0.2,1)
		UiImageBox("common/box-solid-6.png", w, h, 6, 6)
		UiColor(1, 1, 1)
		UiImageBox("common/box-outline-6.png", w, h, 6, 6, 1)

		--lmb click outside
		if InputPressed("esc") or (not UiIsMouseInRect(w, h) and InputPressed("lmb")) then
			open = false
		end

		--rmb click outside
		if InputPressed("esc") or (not UiIsMouseInRect(w, h) and InputPressed("rmb")) then
			return false
		end

		--Indent 12,8
		w = w - 24
		h = h - 16
		UiTranslate(12, 8)
		UiFont("regular.ttf", 22)
		UiColor(1,1,1,0.5)

		--New global mod
		if UiIsMouseInRect(w, 22) then
			UiColor(1,1,1,0.2)
			UiRect(w, 22)
			if InputPressed("lmb") then
				Command("mods.new", "global")
				updateMods()
				open = false
			end
		end
		UiColor(1,1,1,1)
		UiText("New global mod")

		--New content mod
		UiTranslate(0, 22)
		if UiIsMouseInRect(w, 22) then
			UiColor(1,1,1,0.2)
			UiRect(w, 22)
			if InputPressed("lmb") then
				Command("mods.new", "content")
				updateMods()
				open = false
			end
		end
		UiColor(1,1,1,1)
		UiText("New content mod")

		if sel_mod ~= "" then
			--Duplicate mod
			UiTranslate(0, 22)
			if UiIsMouseInRect(w, 22) then
				UiColor(1,1,1,0.2)
				UiRect(w, 22)
				if InputPressed("lmb") then
					Command("mods.makelocalcopy", sel_mod)
					updateMods()
					open = false
				end
			end
			UiColor(1,1,1,1)
			UiText("Duplicate mod")

			--Delete mod
			UiTranslate(0, 22)
			if UiIsMouseInRect(w, 22) then
				UiColor(1,1,1,0.2)
				UiRect(w, 22)
				if InputPressed("lmb") then
					yesNoInit("Are you sure you want to delete this mod?",sel_mod,deleteModCallback)
					open = false
				end
			end
			UiColor(1,1,1,1)
			UiText("Delete mod")
		end

		--Disable all
		UiTranslate(0, 22)
		local count = getActiveModCount(false, false, true)
		if count > 0 then
			if UiIsMouseInRect(w, 22) then
				UiColor(1,1,1,0.2)
				UiRect(w, 22)
				if InputPressed("lmb") then
					deactivateMods(false, false, true)
					updateMods()
					open = false
				end
			end
			UiColor(1,1,1,1)
		else
			UiColor(0.8,0.8,0.8,1)
		end
		UiText("Disable All")
	UiPop()
	UiModalEnd()

	return open
end


function contextMenuSubscribed(sel_mod)
	local open = true
	UiModalBegin()
	UiPush()
		local w = 135
		local h = 85
		if sel_mod == "" then
			h = 38
		end

		local x = contextPosX
		local y = contextPosY
		UiTranslate(x, y)
		UiAlign("left top")
		UiScale(1, contextScale)
		UiWindow(w, h, true)
		UiColor(0.2,0.2,0.2,1)
		UiImageBox("common/box-solid-6.png", w, h, 6, 6)
		UiColor(1, 1, 1)
		UiImageBox("common/box-outline-6.png", w, h, 6, 6, 1)

		--lmb click outside
		if InputPressed("esc") or (not UiIsMouseInRect(w, h) and InputPressed("lmb")) then
			open = false
		end

		--rmb click outside
		if InputPressed("esc") or (not UiIsMouseInRect(w, h) and InputPressed("rmb")) then
			return false
		end

		--Indent 12,8
		w = w - 24
		h = h - 16
		UiTranslate(12, 8)
		UiFont("regular.ttf", 22)
		UiColor(1,1,1,0.5)

		if sel_mod ~= "" then
			--Browse
			if UiIsMouseInRect(w, 22) then
				UiColor(1,1,1,0.2)
				UiRect(w, 22)
				if InputPressed("lmb") then
					Command("mods.unsubscribe", sel_mod)
					updateMods()
					open = false
				end
			end
			UiColor(1,1,1,1)
			UiText("Unsubscribe")

			--New content mod
			UiTranslate(0, 22)
			if UiIsMouseInRect(w, 22) then
				UiColor(1,1,1,0.2)
				UiRect(w, 22)
				if InputPressed("lmb") then
					Command("mods.browsesubscribed", sel_mod)
					open = false
				end
			end
			UiColor(1,1,1,1)
			UiText("Details...")
			UiTranslate(0, 22)
		end

		--Disable all
		local count = getActiveModCount(false, true, false)
		if count > 0 then
			if UiIsMouseInRect(w, 22) then
				UiColor(1,1,1,0.2)
				UiRect(w, 22)
				if InputPressed("lmb") then
					deactivateMods(false, true, false)
					updateMods()
					open = false
				end
			end
			UiColor(1,1,1,1)
		else
			UiColor(0.8,0.8,0.8,1)
		end
		UiText("Disable All")
	UiPop()
	UiModalEnd()

	return open
end


function contextMenuBuiltin(sel_mod)
	local open = true
	UiModalBegin()
	UiPush()
		local w = 135
		local h = 38

		local x = contextPosX
		local y = contextPosY
		UiTranslate(x, y)
		UiAlign("left top")
		UiScale(1, contextScale)
		UiWindow(w, h, true)
		UiColor(0.2,0.2,0.2,1)
		UiImageBox("common/box-solid-6.png", w, h, 6, 6)
		UiColor(1, 1, 1)
		UiImageBox("common/box-outline-6.png", w, h, 6, 6, 1)

		--lmb click outside
		if InputPressed("esc") or (not UiIsMouseInRect(w, h) and InputPressed("lmb")) then
			open = false
		end

		--rmb click outside
		if InputPressed("esc") or (not UiIsMouseInRect(w, h) and InputPressed("rmb")) then
			return false
		end

		--Indent 12,8
		w = w - 24
		h = h - 16
		UiTranslate(12, 8)
		UiFont("regular.ttf", 22)
		UiColor(1,1,1,0.5)

		--Disable all
		local count = getActiveModCount(true, false, false)
		if count > 0 then
			if UiIsMouseInRect(w, 22) then
				UiColor(1,1,1,0.2)
				UiRect(w, 22)
				if InputPressed("lmb") then
					deactivateMods(true, false, false)
					updateMods()
					open = false
				end
			end
			UiColor(1,1,1,1)
		else
			UiColor(0.8,0.8,0.8,1)
		end
		UiText("Disable All")
	UiPop()
	UiModalEnd()

	return open
end


function drawCreate(scale)
	local open = true
	UiPush()
		local w = 890
		local h = 604 + gModSelectedScale*270
		UiTranslate(UiCenter(), UiMiddle())
		UiScale(scale*gUiScaleUpFactor)
		UiColorFilter(1, 1, 1, scale)
		UiColor(0,0,0, 0.5)
		UiAlign("center middle")
		UiImageBox("common/box-solid-shadow-50.png", w, h, -50, -50)
		UiWindow(w, h)
		UiAlign("left top")
		UiColor(0.96,0.96,0.96)
		if InputPressed("esc") or (not UiIsMouseInRect(UiWidth(), UiHeight()) and InputPressed("lmb")) then
			open = false
			gMods[1].isdragging = false;
			gMods[2].isdragging = false;
			gMods[3].isdragging = false;
		end

		UiPush()
			UiFont("bold.ttf", 48)
			UiColor(1,1,1)
			UiAlign("center")
			UiTranslate(UiCenter(), 60)
			UiText("MODS")
		UiPop()
		
		UiPush()
			UiPush()
				UiFont("regular.ttf", 22)
				UiTranslate(UiCenter(), 100)
				UiAlign("center")
				UiWordWrap(600)
				UiColor(0.8, 0.8, 0.8)
				UiText("Create your own mods using Lua scripting and the free voxel modeling program MagicaVoxel. We have provided example mods that you can modify or replace with your own creations. Find out more on our web page:", true)
				UiTranslate(0, 2)
				UiFont("bold.ttf", 22)
				UiColor(1, 0.95, .7)
				if UiTextButton("www.teardowngame.com/modding") then
					Command("game.openurl", "http://www.teardowngame.com/modding")
				end
			UiPop()

			UiTranslate(30, 220)
			UiPush()
			for i=1,3 do
				UiPush()
					UiFont("bold.ttf", 22)
					UiAlign("left")
					UiText(gMods[i].title)
					UiTranslate(0, 10)
					local h = 338
					if i==2 then
						h = 271
						UiTranslate(0, 32)
					end

					local selected, rmb_pushed = listMods(gMods[i], 250, h, i==2)
					if selected ~= "" then
						selectMod(selected)
						if i==2 then
							updateMods()
						end
					end

					if i == 2 then
						UiPush()
							UiTranslate(40, -11)
							UiFont("regular.ttf", 19)
							UiAlign("center")
							UiColor(1,1,1,0.8)
							UiButtonImageBox("common/box-solid-4.png", 4, 4, 1, 1, 1, 0.1)
							if gMods[i].filter == 0 then
								if UiTextButton("All", 80, 26) then
									gMods[i].filter = 1
									updateMods()
								end
							elseif gMods[i].filter == 1 then
								if UiTextButton("Global", 80, 26) then
									gMods[i].filter = 2
									updateMods()
								end
							else
								if UiTextButton("Content", 80, 26) then
									gMods[i].filter = 0
									updateMods()
								end
							end
						UiPop()					
						UiPush()
							UiTranslate(167, -11)
							UiFont("regular.ttf", 19)
							UiAlign("center")
							UiColor(1,1,1,0.8)
							UiButtonImageBox("common/box-solid-4.png", 4, 4, 1, 1, 1, 0.1)
							if gMods[i].sort == 0 then
								if UiTextButton("Alphabetical", 166, 26) then
									gMods[i].sort = 1
									updateMods()
								end
							elseif gMods[i].sort == 1 then
								if UiTextButton("Recently updated", 166, 26) then
									gMods[i].sort = 2
									updateMods()
								end
							else
								if UiTextButton("Recently subscribed", 166, 26) then
									gMods[i].sort = 0
									updateMods()
								end
							end
						UiPop()
					end

					if i == 1 and rmb_pushed then
						showContextMenu = false
						showSubscribedContextMenu = false
						showBuiltinContextMenu = true
						SetValue("contextScale", 1, "bounce", 0.35)
						contextItem = selected
						getContextMousePos = true
					end
					if i == 2 and rmb_pushed then
						showContextMenu = false
						showSubscribedContextMenu = true
						showBuiltinContextMenu = false
						SetValue("contextScale", 1, "bounce", 0.35)
						contextItem = selected
						getContextMousePos = true
					end
					if i == 3 and rmb_pushed then
						showContextMenu = true
						showSubscribedContextMenu = false
						showBuiltinContextMenu = false
						SetValue("contextScale", 1, "bounce", 0.35)
						contextItem = selected
						getContextMousePos = true
					end
				UiPop()
				if i==2 then
					UiPush()
						if not GetBool("game.workshop") then 
							UiPush()
								UiFont("regular.ttf", 20)
								UiTranslate(50, 110)
								UiColor(0.7, 0.7, 0.7)
								UiText("Steam Workshop is\ncoming soon")
							UiPop()
							UiDisableInput()
							UiColorFilter(1,1,1,0.5)
						end
						UiTranslate(0, 318)
						UiFont("regular.ttf", 22)
						UiButtonImageBox("common/box-solid-6.png", 6, 6, 1, 1, 1, 0.1)
						if UiTextButton("Manage subscribed...", 250, 30) then
							Command("mods.browse")
						end
					UiPop()
				end
				if i==1 then
					if showBuiltinContextMenu and InputPressed("esc") or (not UiIsMouseInRect(UiWidth(), UiHeight()) and (InputPressed("lmb") or InputPressed("rmb"))) then
						showBuiltinContextMenu = false
					end
				end
				if i==2 then
					if showSubscribedContextMenu and InputPressed("esc") or (not UiIsMouseInRect(UiWidth(), UiHeight()) and (InputPressed("lmb") or InputPressed("rmb"))) then
						showSubscribedContextMenu = false
					end
				end
				if i==3 then
					if showContextMenu and InputPressed("esc") or (not UiIsMouseInRect(UiWidth(), UiHeight()) and (InputPressed("lmb") or InputPressed("rmb"))) then
						showContextMenu = false
					end
				end
				UiTranslate(290, 0)
			end
			UiPop()
			
			UiColor(0,0,0,0.1)
			
			UiTranslate(0, 380)
			if gModSelected ~= "" and gModSelectedScale == 0 then
				SetValue("gModSelectedScale", 1, "cosine", 0.25)
			end
			UiPush()
				local modKey = "mods.available."..gModSelected
				UiAlign("left")
				if gModSelectedScale > 0 then
					UiScale(1, gModSelectedScale)
					local mw = w-60
					local mh = 250
					UiColor(1,1,1, 0.07)
					UiImageBox("common/box-solid-6.png", mw, mh, 6, 6)
					UiWindow(mw, mh)
					UiPush()
						local name = GetString(modKey..".name")
						if gModSelected ~= "" and name == "" then name = "Unknown" end
						local author = GetString(modKey..".author")
						if gModSelected ~= "" and author == "" then author = "Unknown" end
						local tags = GetString(modKey..".tags")
						local description = GetString(modKey..".description")
						local timestamp = GetString(modKey..".timestamp")

						UiTranslate(30, 40)
						UiColor(1,1,1,1)
						UiFont("bold.ttf", 32)
						UiText(name)
						UiTranslate(0, 20)
						UiFont("regular.ttf", 20)

						if author ~= "" then
							UiTranslate(0, -22)
							UiWindow(500,25,true)
							UiTranslate(0, 22)
							UiText("By " .. author, true)
						end
						if tags ~= "" then
							UiTranslate(0, -22)
							UiWindow(500,25,true)
							UiTranslate(0, 22)
							UiText("Tags: " .. tags, true)
						end

						UiWindow(510,96,true)
						UiWordWrap(500)
						UiFont("regular.ttf", 20)
						UiTranslate(0, 12)
						UiColor(.8, .8, .8)
						UiText(description, true)
					UiPop()

					UiPush()
						UiColor(1,1,1,1)
						UiFont("regular.ttf", 16)
						UiTranslate(30, mh - 24)
						if timestamp ~= "" then
							UiColor(0.5, 0.5, 0.5)
							UiText("Updated " .. timestamp, true)
						end
					UiPop()

					UiColor(1, 1, 1)
					UiFont("regular.ttf", 24)
					UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.7)
					UiAlign("center middle")	
				
					if GetBool(modKey..".playable") then
						UiPush()
							UiTranslate(mw-120,mh-40)
							UiPush()
								UiColor(.7, 1, .8, 0.2)
								UiImageBox("common/box-solid-6.png", 200, 40, 6, 6)
							UiPop()
							if UiTextButton("Play", 200, 40) then
								Command("mods.play", gModSelected)
							end
						UiPop()
					else
						if GetBool(modKey..".override") then
							UiPush()
								UiTranslate(mw-120,mh-40)
								if GetBool(gModSelected..".active") then
									if UiTextButton("Enabled", 200, 40) then
										Command("mods.deactivate", gModSelected)
										updateMods()
									end
									UiColor(1, 1, 0.5)
									UiTranslate(-60, 0)
									UiImage("menu/mod-active.png")
								else
									if UiTextButton("Disabled", 200, 40) then
										Command("mods.activate", gModSelected)
										updateMods()
									end
									UiTranslate(-60, 0)
									UiImage("menu/mod-inactive.png")
								end
							UiPop()
						end
					end
					if GetBool(modKey..".options") then
						UiPush()
							UiTranslate(mw-120,mh-90)
							if UiTextButton("Options", 200, 40) then
								Command("mods.options", gModSelected)
							end
						UiPop()
					end
					if GetBool(modKey..".local") then
						if GetBool(modKey..".playable") then
							UiPush()
								UiTranslate(mw-120,40)
								if UiTextButton("Edit", 200, 40) then
									Command("mods.edit", gModSelected)
								end
							UiPop()
						end
					else
						if gModSelected ~= "" then
							UiPush()
								UiTranslate(mw-120,40)
								if UiTextButton("Make local copy", 200, 40) then
									Command("mods.makelocalcopy", gModSelected)
									updateMods()
								end
							UiPop()
						end
					end
					if GetBool(modKey..".local") then
						UiPush()
							UiTranslate(mw-120,90)
							if not GetBool("game.workshop")or not GetBool("game.workshop.publish") then 
								UiDisableInput()
								UiColorFilter(1,1,1,0.5)
							end
							if UiTextButton("Publish...", 200, 40) then
								SetValue("gPublishScale", 1, "cosine", 0.25)
								Command("mods.publishbegin", gModSelected)
							end
							if not GetBool("game.workshop.publish") then
								UiTranslate(0, 30)
								UiFont("regular.ttf", 18)
								UiText("Unavailable in experimental")
							end
						UiPop()
						UiPush()
							UiTranslate(UiCenter(),mh+5)
							UiColor(0.5, 0.5, 0.5)
							UiFont("regular.ttf", 18)
							UiAlign("center top")
							local path = GetString(modKey..".path")
							local w,h = UiGetTextSize(path)
							if UiIsMouseInRect(w, h) then
								UiColor(1, 0.8, 0.5)
								if InputPressed("lmb") then
									Command("game.openfolder", path)
								end
							end
							UiText(path, true)
						UiPop()
					end
				end
			UiPop()
		UiPop()
	UiPop()

	------------------------------------ PUBLISH ----------------------------------------------
	if gPublishScale > 0 then
		open = true
		UiModalBegin()
		UiBlur(gPublishScale)
		UiPush()
			local w = 700
			local h = 800
			UiTranslate(UiCenter(), UiMiddle())
			UiScale(gPublishScale)
			UiColorFilter(1, 1, 1, scale)
			UiColor(0,0,0, 0.5)
			UiAlign("center middle")
			UiImageBox("common/box-solid-shadow-50.png", w, h, -50, -50)
			UiWindow(w, h)
			UiAlign("left top")
			UiColor(1,1,1)

			local publish_state = GetString("mods.publish.state")
			local canEsc = publish_state ~= "uploading"
			if canEsc and (InputPressed("esc") or (not UiIsMouseInRect(UiWidth(), UiHeight()) and InputPressed("lmb"))) then
				SetValue("gPublishScale", 0, "cosine", 0.25)
				Command("mods.publishend")
			end
			
			UiPush()
				UiFont("bold.ttf", 48)
				UiColor(1,1,1)
				UiAlign("center")
				UiTranslate(UiCenter(), 60)
				UiText("PUBLISH MOD")
			UiPop()
			
			local modKey = "mods.available."..gModSelected
			UiPush()
				UiTranslate(50, 100)
				local mw = 335
				local mh = mw
				UiPush()
					UiTranslate((w-100-mw)/2, 0)
					UiPush()
						UiColor(1, 1, 1, 0.05)
						UiRect(mw, mh)
					UiPop()
					local id = GetString("mods.publish.id")
					local name = GetString(modKey..".name")
					local author = GetString(modKey..".author")
					local tags = GetString(modKey..".tags")
					local description = GetString(modKey..".description")
					local previewPath = "RAW:"..GetString(modKey..".path").."/preview.jpg"
					local hasPreview = HasFile(previewPath)
					local missingInfo = false
					if hasPreview then
						local pw,ph = UiGetImageSize(previewPath)
						local scale = math.min(mw/pw, mh/ph)
						UiPush()
							UiTranslate(mw/2, mh/2)
							UiAlign("center middle")
							UiColor(1,1,1)
							UiScale(scale)
							UiImage(previewPath)
						UiPop()
					else
						UiPush()
							UiFont("regular.ttf", 20)
							UiTranslate(mw/2, mh/2)
							UiColor(1, 0.2, 0.2)
							UiAlign("center middle")
							UiText("No preview image", true)
						UiPop()
					end
				UiPop()
				UiTranslate(0, 400)
				UiFont("bold.ttf", 32)
				UiAlign("left")
				if name ~= "" then
					UiText(name)
				else
					UiColor(1,0.2,0.2)
					UiText("Name not specified")
					UiColor(1,1,1)
					missingInfo = true
				end

				UiTranslate(0, 20)
				UiFont("regular.ttf", 20)

				if id ~= "0" then
					UiText("Workshop ID: "..id, true)
				end
				if author ~= "" then
					UiText("By " .. author, true)
				else
					UiColor(1,0.2,0.2)
					UiText("Author not specified", true)
					UiColor(1,1,1)
					missingInfo = true
				end

				UiAlign("left top")
				if tags ~= "" then
					UiTranslate(0, -16)
					UiWindow(mw,22,true)
					UiText("Tags: " .. tags, true)
					UiTranslate(0, 16)
				end
				UiWordWrap(mw)
				UiFont("regular.ttf", 20)
				UiColor(.8, .8, .8)

				if description ~= "" then
					UiWindow(mw,104,true)
					UiText(description, true)
				else
					UiColor(1,0.2,0.2)
					UiText("Description not specified", true)
					UiColor(1,1,1)
					missingInfo = true
				end
			UiPop()
			UiPush()
				local state = GetString("mods.publish.state")
				local canPublish = (state == "ready" or state == "failed")
				local update = (id ~= "0")
				local done = (state == "done")
				local failMessage = GetString("mods.publish.message")
					
				if missingInfo then
					canPublish = false
					failMessage = "Incomplete information in info.txt"
				elseif not hasPreview then
					canPublish = false
					failMessage = "Preview image not found: preview.jpg"
				end

				UiTranslate(w-50, h-30)
				UiAlign("bottom right")
				UiFont("regular.ttf", 24)
				UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.7)

				if state == "uploading" then
					if UiTextButton("Cancel", 200, 40) then
						Command("mods.publishcancel")
					end
					local progress = GetFloat("mods.publish.progress")
					if progress < 0.1 then
						progress = 0.1
					end
					if progress > 0.9 then
						progress = 0.9
					end
					UiTranslate(-600, -40)
					UiAlign("top left")
					UiColor(0,0,0)
					UiRect(350, 40)
					UiColor(1,1,1)
					UiTranslate(2,2)
					UiRect(346*progress, 36)
					UiColor(0.5, 0.5, 0.5)
					UiTranslate(175, 20)
					UiAlign("center middle")
					UiText("Uploading")
				else
					UiPush()
						if done then
							if UiTextButton("Done", 200, 40) then
								SetValue("gPublishScale", 0, "easein", 0.25)
								Command("mods.publishend")
							end				
						else
							if not canPublish then
								UiDisableInput()
								UiColorFilter(1,1,1,0.3)
							end
							local caption = "Publish"
							if update then
								caption = "Publish update"
							end
							UiPush()
								UiAlign("center middle")
								UiTranslate(-160, -65)
								UiText("Visibility")
								UiTranslate(55,5)
								UiColor(1,1,0.7)
								local val = GetInt("mods.publish.visibility")
								UiButtonImageBox()
								UiAlign("left")
								if val == -1 then

								elseif val == 0 then
									if UiTextButton("Public", 200, 40) then
										SetInt("mods.publish.visibility", 1)
									end
								elseif val == 1 then
									if UiTextButton("Friends", 200, 40) then
										SetInt("mods.publish.visibility", 2)
									end
								elseif val == 2 then
									if UiTextButton("Private", 200, 40) then
										SetInt("mods.publish.visibility", 3)
									end
								else
									if UiTextButton("Unlisted", 200, 40) then
										SetInt("mods.publish.visibility", 0)
									end
								end
							UiPop()
							if UiTextButton(caption, 200, 40) then
								Command("mods.publishupload")
							end				
						end
					UiPop()
					if failMessage ~= "" then
						UiColor(1, 0.2, 0.2)
						UiTranslate(-600, -20)
						UiAlign("left middle")
						UiFont("regular.ttf", 20)
						UiWordWrap(350)
						UiText(failMessage)
					end
				end
			UiPop()
		UiPop()
		UiModalEnd()
	end
	
	-- context menu
	if showContextMenu then
		if getContextMousePos then
			contextPosX, contextPosY = UiGetMousePos()
			getContextMousePos = false
		end
		showContextMenu = contextMenu(contextItem)
		if not showContextMenu then
			contextScale = 0
		end
	end

	if showSubscribedContextMenu then
		if getContextMousePos then
			contextPosX, contextPosY = UiGetMousePos()
			getContextMousePos = false
		end
		showSubscribedContextMenu = contextMenuSubscribed(contextItem)
		if not showSubscribedContextMenu then
			contextScale = 0
		end
	end

	if showBuiltinContextMenu then
		if getContextMousePos then
			contextPosX, contextPosY = UiGetMousePos()
			getContextMousePos = false
		end
		showBuiltinContextMenu = contextMenuBuiltin(contextItem)
		if not showBuiltinContextMenu then
			contextScale = 0
		end
	end

	-- yes-no popup
	if yesNoPopup.show and yesNo() then
		yesNoPopup.show = false
		if yesNoPopup.yes and yesNoPopup.yes_fn ~= nil then
			yesNoPopup.yes_fn()
		end
	end

	return open
end

function mainMenu()
	if InputPressed("f5") then Menu() end
	UiPush()
		UiColor(0,0,0, 0.75)
		UiRect(UiWidth(), 150)
		UiColor(1,1,1)
		UiPush()
			UiTranslate(300, 75)
			UiAlign("center middle")
			UiScale(0.6)
			UiImage("menu/logo.png")
			if GetBool("options.better.customLogo") then
				UiTranslate(-100,95)
				UiScale(2)
				UiImage("menu/logoSubtext.png")
			end
		UiPop()
		UiFont("regular.ttf", 36)
		UiTranslate(800, 30)
		UiTranslate(0, 50)
		UiAlign("center middle")
		UiPush()
			UiButtonImageBox("common/box-outline-fill-6.png", 6, 6, 0.96, 0.96, 0.96)
			UiColor(0.96, 0.96, 0.96)
			local bh = 50
			local bo = 56
			
			UiPush()
				if UiTextButton("Play", 250, bh) then
					UiSound("common/click.ogg")
					if gPlayScale == 0 then
						SetValue("gPlayScale", 1.0, "easeout", 0.25)
					else
						SetValue("gPlayScale", 0.0, "easein", 0.25)
					end
				end
			UiPop()

			UiTranslate(300, 0)

			UiPush()
				if UiTextButton("Options", 250, bh) then
					UiSound("common/click.ogg")
					SetValue("gOptionsScale", 1.0, "easeout", 0.25)
					SetValue("gPlayScale", 0.0, "easein", 0.25)
				end
			UiPop()

			UiTranslate(300, 0)

			UiPush()
				if UiTextButton("Credits", 250, bh) then
					UiSound("common/click.ogg")
					StartLevel("about", "about.xml")
					SetValue("gPlayScale", 0.0, "easein", 0.25)
				end
			UiPop()
				
			UiTranslate(300, 0)

			UiPush()
				if UiTextButton("Quit", 250, bh) then
					UiSound("common/click.ogg")
					Command("game.quit")
					SetValue("gPlayScale", 0.0, "easein", 0.25)
				end
			UiPop()
		UiPop()
	UiPop()

	if gPlayScale > 0 then
		local bw = 206
		local bh = 40
		local bo = 48
		UiPush()
			UiTranslate(672, 160)
			UiScale(1, gPlayScale)
			UiColorFilter(1,1,1,gPlayScale)
			if gPlayScale < 0.5 then
				UiColorFilter(1,1,1,gPlayScale*2)
			end
			UiColor(0,0,0,0.75)
			UiFont("regular.ttf", 26)
			UiImageBox("common/box-solid-10.png", 256, 352, 10, 10)
			UiColor(1,1,1)
			UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1)

			UiButtonImageBox("common/box-outline-fill-6.png", 6, 6, 0.96, 0.96, 0.96)
			UiColor(0.96, 0.96, 0.96)

			UiAlign("top left")
			UiTranslate(25, 25)

			if UiTextButton("Campaign", bw, bh) then
				UiSound("common/click.ogg")
				startHub()
			end	
			UiTranslate(0, bo)

			if UiTextButton("Sandbox", bw, bh) then
				UiSound("common/click.ogg")
				SetValue("gSandboxScale", 1, "cosine", 0.25)
			end			
			UiTranslate(0, bo)

			if UiTextButton("Challenges", bw, bh) then
				UiSound("common/click.ogg")
				SetValue("gChallengesScale", 1, "cosine", 0.25)
				gChallengeLevel = ""
				gChallengeLevelScale = 0
			end			
			UiTranslate(0, bo)
			
			if UiTextButton("Expansions", bw, bh) then
				UiSound("common/click.ogg")
				SetValue("gExpansionsScale", 1, "cosine", 0.25)
				gChallengeLevel = ""
				gChallengeLevelScale = 0
			end			
			UiTranslate(0, bo)

			UiTranslate(0, 22)

			UiPush()
				if not GetBool("promo.available") then
					UiDisableInput()
					UiColorFilter(1,1,1,0.5)
				end
				if UiTextButton("Featured mods", bw, bh) then
					UiSound("common/click.ogg")
					promoShow()
				end
				if GetBool("savegame.promoupdated") then
					UiPush()
						UiTranslate(200, 0)
						UiAlign("center middle")
						UiImage("menu/promo-notification.png")
					UiPop()
				end
			UiPop()
			UiTranslate(0, bo)
			if UiTextButton("Mod manager", bw, bh) then
				UiSound("common/click.ogg")
				SetValue("gCreateScale", 1, "cosine", 0.25)
				gModSelectedScale=0
				updateMods()
				selectMod("")
			end			
		UiPop()
	end
	if gSandboxScale > 0 then
		UiPush()
			UiBlur(gSandboxScale)
			UiColor(0.7,0.7,0.7, 0.25*gSandboxScale)
			UiRect(UiWidth(), UiHeight())
			UiModalBegin()
			if not drawSandbox(gSandboxScale) then
				SetValue("gSandboxScale", 0, "cosine", 0.25)
			end
			UiModalEnd()
		UiPop()
	end
	if gChallengesScale > 0 then
		UiPush()
			UiBlur(gChallengesScale)
			UiColor(0.7,0.7,0.7, 0.25*gChallengesScale)
			UiRect(UiWidth(), UiHeight())
			UiModalBegin()
			if not drawChallenges(gChallengesScale) then
				SetValue("gChallengesScale", 0, "cosine", 0.25)
			end
			UiModalEnd()
		UiPop()
	end
	if gExpansionsScale> 0 then
		UiPush()
			UiBlur(gExpansionsScale)
			UiColor(0.7,0.7,0.7, 0.25*gExpansionsScale)
			UiRect(UiWidth(), UiHeight())
			UiModalBegin()
			if not drawExpansions(gExpansionsScale) then
				SetValue("gExpansionsScale", 0, "cosine", 0.25)
			end
			UiModalEnd()
		UiPop()
	end
	if gCreateScale > 0 then
		UiPush()
			UiBlur(gCreateScale-gPublishScale)
			UiColor(0.7,0.7,0.7, 0.25*gCreateScale)
			UiRect(UiWidth(), UiHeight())
			UiModalBegin()
			if not drawCreate(gCreateScale) then
				SetValue("gCreateScale", 0, "cosine", 0.25)
			end
			UiModalEnd()
		UiPop()
	end
	if gOptionsScale > 0 then
		UiPush()
			UiBlur(gOptionsScale)
			UiColor(0.7,0.7,0.7, 0.25*gOptionsScale)
			UiRect(UiWidth(), UiHeight())
			UiModalBegin()
			if not drawOptions(gOptionsScale, true) then
				SetValue("gOptionsScale", 0, "cosine", 0.25)
			end
			UiModalEnd()
		UiPop()
	end
	
	if betterOptions then
		UiPush()
			local windowW = 500
			local windowH = 600
			UiAlign("top left")
			UiTranslate(400,400)
			local closed = false
			if GetBool("options.better.alternateTitle") then
				betterOptionsOpen, closed = imguiWindow(windowW,windowH,"Additional Settings",betterOptionsOpen,true)
			else
				betterOptionsOpen, closed = imguiWindow(windowW,windowH,"Shitless: Settings",betterOptionsOpen,true)
			end
			if closed then betterOptions = false end
			imguiFont(13)
			UiPush()
				if betterOptionsOpen then
					UiTranslate(5,5)
					UiWordWrap(windowW-29)
					local new, changed = imguiCheckbox(GetBool("options.better.customLogo"),"Draw custom logo subtext")
					if changed then SetBool("options.better.customLogo",new) end
					
					UiTranslate(0,25)
					new, changed = imguiCheckbox(GetBool("options.better.graphicsAnywhere"),"Allow changing graphics settings anywhere (could maybe cause bugs)")
					if changed then SetBool("options.better.graphicsAnywhere",new) end
					
					UiTranslate(0,25)
					new, changed = imguiCheckbox(GetBool("options.better.splash"),"Show splash screen")
					if changed then SetBool("options.better.splash",new) end
					
					UiTranslate(0,25)
					new, changed = imguiCheckbox(GetBool("options.better.forceShowChallenges"),"Force showing Cullington & Carib hub in challenges")
					if changed then SetBool("options.better.forceShowChallenges",new) end
					
					UiTranslate(0,25)
					new, changed = imguiCheckbox(GetBool("options.better.photoNoClamp"),"Unclamp photomode sliders")
					if changed then SetBool("options.better.photoNoClamp",new) end
					
					UiTranslate(0,25)
					new, changed = imguiCheckbox(GetBool("options.better.photoThroughGlass"),"Ignore glass when setting photomode DOF")
					if changed then SetBool("options.better.photoThroughGlass",new) end
					
					UiTranslate(0,25)
					new, changed = imguiCheckbox(GetBool("options.better.photoDof"),"Seperately set DOF start & end (press crouch while setting dof, or just dont use this setting at all, this shit is broken)")
					if changed then SetBool("options.better.photoDof",new) end
					
					UiTranslate(0,25+UiFontHeight())
					new, changed = imguiCheckbox(GetBool("options.better.optionsCornerDumpster"),"Show Saber dumpster in corner of settings")
					if changed then
						SetBool("options.better.optionsCornerDumpster",new)
						if not new then SetValue("flames",0,"cosine",0.1) end
					end
					
					UiTranslate(0,25)
					new, changed = imguiCheckbox(GetBool("options.better.alternateTitle"),"Alternate (family friendly) title")
					if changed then SetBool("options.better.alternateTitle",new) end
				end
			UiPop()
			UiTranslate(UiWidth()-5,UiHeight())
			UiAlign("bottom right")
			UiText("v 1.0")
			if GetBool("options.better.optionsCornerDumpster") then
				UiTranslate(10-UiWidth(),0)
				UiAlign("bottom left")
				UiPush()
					local w=220
					local h=319
					UiTranslate(12,-90)
					local t = 12*GetTime()
					local frame = math.floor(t%7)
					
					UiScale(0.5,0.5)
					UiImage("menu/flames.png",frame*w,0,(frame+1)*w,flames*h)
				UiPop()
				UiPush()
					UiScale(1/3,1/3)
					if UiImageButton("saber.png") then
						if flames<=0.5 then
							SetValue("flames",1,"easeout",4)
						else
							SetValue("flames",0,"cosine",1)
						end
					end
				UiPop()
				UiPush()
					UiTranslate(100,0)
					UiColor(1,1,1,0.2)
					UiText("Image by Autumnatic")
				UiPop()
			end
		UiPop()
	end
end


function tick()
	if GetTime() > 0.1 then
		if gActivations >= 2 then
			PlayMusic("menu-long.ogg")
		else
			PlayMusic("menu.ogg")
		end
		SetFloat("game.music.volume", (1.0 - 0.8*gCreateScale))
	end
	
end


function drawBackground()
	if promo_full_initiated == false and GetBool("promo.available") and GetInt("savegame.startcount") >= 5 then
		promo_full_initiated = true
		initSlideShowPromo()
	end

	UiPush()
		if bgTimer >= 0 then
			bgTimer = bgTimer - GetTimeStep()
			if bgTimer < 0 then
				bgIndex = math.mod(bgIndex + 1, #slideshowImages)
				if bgPromoIndex[0] >= 0 then
					bgIndex = bgPromoIndex[0]
					bgPromoIndex[0] = bgPromoIndex[1]
					bgPromoIndex[1] = -1
				end
				bgTimer = bgInterval

				bgCurrent = 1-bgCurrent
				bgItems[bgCurrent] = bgLoad(bgIndex)
			end
		end

		UiTranslate(UiCenter(), UiMiddle())
		UiAlign("center middle")
		bgDraw(bgItems[1-bgCurrent])
		bgDraw(bgItems[bgCurrent])
	UiPop()

	if promo_full_initiated then
		promoDrawFeatured()
	end
end


function draw()
	UiButtonHoverColor(0.8,0.8,0.8,1)

	UiPush()
		--Create a safe 1920x1080 window that will always be visible on screen
		local x0,y0,x1,y1 = UiSafeMargins()
		UiTranslate(x0,y0)
		UiWindow(x1-x0,y1-y0, true)

		drawBackground()
		mainMenu()
		
	UiPop()

	if not gDeploy and mainMenuDebug then
		mainMenuDebug()
	end

	UiPush()
		local version = GetString("game.version")
		local patch = GetString("game.version.patch")
		if patch ~= "" then
			version = version .. " (" .. patch .. ")"
		end
		UiTranslate(UiWidth()-10, UiHeight()-10)
		UiFont("regular.ttf", 18)
		UiAlign("right")
		UiColor(1,1,1,0.5)
		if UiTextButton(version) then
			Command("game.openurl", "http://teardowngame.com/changelog/?version="..GetString("game.version"))
		end
		UiTranslate(20-UiWidth())
		UiAlign("left")
		local buttonText = "Teardown: Shitless by Bingle"
		if GetBool("options.better.alternateTitle") then buttonText = "Teardown Redux by Bingle" end
		if UiTextButton(buttonText) then
			betterOptions = not betterOptions
			betterOptionsOpen = true
		end
	UiPop()

	if gCreateScale > 0 and GetBool("game.saveerror") then
		UiPush()
			UiColorFilter(1,1,1,gCreateScale)
			UiFont("bold.ttf", 20)
			UiTextOutline(0, 0, 0, 1, 0.1)
			UiColor(1,1,.5)
			UiAlign("center")
			UiTranslate(UiCenter(), UiHeight()-100)
			UiWordWrap(600)
			UiText("Teardown was denied write access to your Documents folder. This is usually caused by Windows Defender or similar security software. Without access to the Documents folder, local mods will not function correctly.")
		UiPop()
	end
	
	promoDraw()
end


function handleCommand(cmd)
	if cmd == "resolutionchanged" then
		gOptionsScale = 1
		optionsTab = "display"
	end
	if cmd == "activate" then
		initSlideshow()
		gActivations = gActivations + 1
	end
	if cmd == "updatemods" then
		updateMods()
	end
end

