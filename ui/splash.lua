function init()
	t = 0
	showLogo = 0
	showText = 0
	done = false
	splashTime = 20
	requiredTime = 0
	
	animImage = "splash/logo-animation.png"
	animPreloaded = false
	animTime = 0.0
end


function tick()
	if animPreloaded then
		if not GetBool("options.better.splash") then Menu() end
		t = t + GetTimeStep()
		if t > splashTime or (t > requiredTime and InputPressed("any")) then
			if not done then
				Menu()
				done = true
			end
		end
	end
end


function drawTileAnimation(img, t, tileWidth, tileHeight, maxFrame)
	local timePerFrame = 0.016667
	local frame = math.min(math.floor(t / timePerFrame), maxFrame)
	local w, h = UiGetImageSize(img)
	local tilesX = math.floor(w/tileWidth)
	local tilesY = math.floor(h/tileHeight)
	local x = (frame % tilesX) * tileWidth
	local y = math.floor(frame / tilesX) * tileHeight
	UiImage(img, x, y, x+tileWidth, y+tileHeight)
end


function draw(dt)
	if not animPreloaded then
		UiGetImageSize(animImage)
		animPreloaded = true
		return
	end

	if t < 4.0 then
		UiPush()
			UiColor(0,0,0)
			UiRect(UiWidth(), UiHeight())

			UiAlign("center middle")
			UiTranslate(UiCenter(), UiMiddle()-70)
			UiColor(1,1,1)

			if t > 0.2 then
				if animTime == 0 then
					UiSound("splash/logo.ogg")
				end
				drawTileAnimation(animImage, animTime, 256, 256, 89)
				if animTime < 0.4 then
					animTime = animTime + dt*0.5
				else
					animTime = animTime + dt
				end
			end
			
			if t > 1.8 and showText==0 then
				SetValue("showText", 1, "bounce", 0.5)
			end

			if showText > 0 then
				UiTranslate(0, 160)
				UiColor(1, 1, 1, showText)
				UiScale(1, showText)
				UiImage("splash/logo-text.png")
			end			
		UiPop()
	else
		UiPush()
			UiColor(0,0,0)
			UiRect(UiWidth(), UiHeight())
			
			UiTranslate(UiCenter(), UiMiddle()-140)
			
			local showLargeUI = GetBool("game.largeui")
			if showLargeUI then
				UiScale(1.3)
			end
			
			UiAlign("center")
			UiFont("bold.ttf", 24)
			UiPush()
				UiScale(2)
				UiColor(1,.2,.2)
				UiText("WARNING")
			UiPop()
			UiTranslate(0, 40)
			UiColor(.8, .8, .8)
			UiWordWrap(500)
			UiText("This game contains flashing lights that may trigger seizures for people with photosensitive epilepsy.", true)

			UiTranslate(0, 40)
			UiColor(1, 1, 1)
			UiText("Teardown is a work of fiction and is intended for entertainment purposes only. We do not encourage any form of vandalism, theft, reckless driving, illegal activities or irresponsible behavior in the real world.", true)

			UiTranslate(0, 40)
			UiColor(.8, .8, .8)
			UiText("Press any key or button to continue", true)
			UiText("Copyright 2020-2023 Tuxedo Labs AB", true)
		UiPop()
	end
end

