#include "game.lua"


function justPassed(t)
	return gTime >= t and gTimeLast < t
end


function getFirst(str,split)
	split = split or " "
	i = string.find(str, split)
	if i then
		return string.sub(str, 1, i-1)
	else 
		return str
	end
end

function getSecond(str, split)
	split = split or " "
	i = string.find(str, split)
	if i then
		return string.sub(str, i+1, string.len(str))
	end
	return ""
end

function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        --print("****************\n")
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        		--print("str: " .. str .. " | " .. sep)
                table.insert(t, str)
        end
        --print("****************\n")
        return t
end



--------------------------------------------------------------------------------------------------------------------


function pause(dt, params)
	return gTime < params.length
end


--------------------------------------------------------------------------------------------------------------------

function newsIntro(dt, params)
	if gTime == 0 then
		logo = 0
		breaking = -400
		news = 400
		white = 0
		UiSound("tv/news-intro.ogg")
	end

	if justPassed(0.2) then
		SetValue("logo", 8, "bounce", 1)
	end
	if justPassed(1.3) then
		SetValue("breaking", 30, "easeout", 0.4)
	end
	if justPassed(1.5) then
		SetValue("news", 30, "easeout", 0.4)
	end
	if justPassed(1.9) then
		white = 0.5
		SetValue("white", 0, "linear", 1.4)
	end

	UiPush()
		UiTranslate(UiCenter(), UiMiddle())
		UiFont("bold.ttf", 24)
		UiColor(0.5,0,0)
		UiPush()
			UiTranslate(0, -50)
			UiScale(logo)
			UiAlign("center middle")
			UiText("LCN")
		UiPop()
		UiPush()
			UiTranslate(breaking, 70)
			UiScale(3.0)
			UiAlign("right")
			UiText("Breaking")
		UiPop()
		UiPush()
			UiTranslate(news, 70)
			UiScale(3.0)
			UiAlign("left")
			UiText("News")
		UiPop()
	UiPop()
	UiColor(1,1,1,white)
	UiRect(640, 480)
	
	return gTime < 4.0
end

function newsOutro(dt, params)
	host = "Host - Catlyn Sandstream"

	if gTime == 0 then
		logo = 0
		breaking = -400
		news = 400
		white = 0
		UiSound("tv/news-outro.ogg")
	end

	UiImage("tv/news_end.jpg")

	UiPush()
		UiFont("bold.ttf", 24)
		UiAlign("left middle")
		UiTranslate(0, 380)
		UiColor(1,1,1, 0.5)
		UiRect(330, 30)
		UiColor(0,0,0)
		UiTranslate(10, 0)
		UiText(host)
	UiPop()

	if justPassed(0.2) then
		SetValue("logo", 8, "bounce", 1)
	end
	
	UiPush()
		UiTranslate(UiCenter(), UiMiddle())
		UiFont("bold.ttf", 24)
		UiColor(0.5,0,0)
		UiPush()
			UiTranslate(0, -50)
			UiScale(logo)
			UiAlign("center middle")
			UiText("LCN")
		UiPop()
	UiPop()
	UiColor(1,1,1,white)
	UiRect(640, 480)
	
	return gTime < 4.0
end


--------------------------------------------------------------------------------------------------------------------

function mysteryIntro(dt, params)
	local lengthTime = 8
	
	if gTime == 0 then
		creep = 500
		SetValue("creep", 0, "easeout", 1.4)
		UiSound("tv/mystery.ogg")
		sia1 = 0
		sia2 = 0
		sia3 = 0
		sia4 = 0
		sis1 = 0
		sis2 = 0
		sis3 = 0
		sis4 = 0
	end


	--subimage1
	if justPassed(0.5) then
		SetValue("sia1", 1, "easein", 1)
		SetValue("sis1", 4, "linear", 4)
	end
	if justPassed(2.5) then
		SetValue("sia1", 0, "easeout", 3)
	end

	--subimage2
	if justPassed(1.5) then
		SetValue("sia2", 1, "easein", 1)
		SetValue("sis2", 4, "linear", 4)
	end
	if justPassed(3.5) then
		SetValue("sia2", 0, "easeout", 3)
	end

	--subimage3
	if justPassed(2.5) then
		SetValue("sia3", 1, "easein", 1)
		SetValue("sis3", 4, "linear", 4)
	end
	if justPassed(4.5) then
		SetValue("sia3", 0, "easeout", 3)
	end

	--subimage4
	if justPassed(3.5) then
		SetValue("sia4", 1, "easein", 1)
		SetValue("sis4", 4, "linear", 4)
	end
	if justPassed(5.5) then
		SetValue("sia4", 0, "easeout", 3)
	end

	UiPush()
		local subImageSizeFactor = 0.5
		local subImageMoveFactor = 0.25
		local subImageMoveLength = UiWidth() / (lengthTime*2)

		-- BG eye
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter(), UiMiddle())
			UiColorFilter(1,1,1,gTime)
			UiScale(1+gTime*0.1)
			UiImage("tv/mystery-eye.jpg")
		UiPop()
		-- Subimage1
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter() + sis1*subImageMoveLength, UiMiddle() + sis1*subImageMoveLength)
			UiColorFilter(1,1,1,sia1)
			UiScale(sis1*subImageSizeFactor)
			UiImage("tv/mystery-ankh.png")
		UiPop()
		-- Subimage1
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter() + sis2*subImageMoveLength, UiMiddle() - sis2*subImageMoveLength)
			UiColorFilter(1,1,1,sia2)
			UiScale(sis2*subImageSizeFactor)
			UiImage("tv/mystery-ufo.png")
		UiPop()
		-- Subimage3
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter() - sis3*subImageMoveLength, UiMiddle() - sis3*subImageMoveLength)
			UiColorFilter(1,1,1,sia3)
			UiScale(sis3*subImageSizeFactor)
			UiImage("tv/mystery-ufonews.png")
		UiPop()
		-- Subimage4
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter() - sis4*subImageMoveLength, UiMiddle() + sis4*subImageMoveLength)
			UiColorFilter(1,1,1,sia4)
			UiScale(sis4*subImageSizeFactor)
			UiImage("tv/mystery-pyramids.png")
		UiPop()

		UiColor(0.5, 0, 0, 1)
		UiFont("bold.ttf", 96)
		UiTranslate(0, creep)
		UiPush()
			UiTranslate(UiCenter() - 160 + math.sin(gTime*2.2) * 12, UiMiddle() - 120 + math.sin(gTime*2) * 20)
			UiText("T")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() - 80 - math.sin(gTime*1.8) * 16, UiMiddle() - 120 - math.sin(gTime*2.4) * 14)
			UiText("H")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() + 0 + math.sin(gTime*2.6) * 18, UiMiddle() - 120 + math.sin(gTime*1.8) * 16)
			UiText("E")
		UiPop()

		UiPush()
			UiTranslate(UiCenter() - 280 + math.sin(gTime*2.2) * 12, UiMiddle() + math.sin(gTime*2) * 20)
			UiText("M")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() - 160 - math.sin(gTime*1.8) * 12, UiMiddle() - math.sin(gTime*2.4) * 14)
			UiText("Y")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() - 80 + math.sin(gTime*2.6) * 20, UiMiddle() + math.sin(gTime*1.8) * 14)
			UiText("S")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() - 0 - math.sin(gTime*2.8) * 8, UiMiddle() - math.sin(gTime*3) * 10)
			UiText("T")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() + 80 + math.sin(gTime*1.1) * 13, UiMiddle() + math.sin(gTime*1.5) * 18)
			UiText("E")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() + 160 - math.sin(gTime*3.2) * 18, UiMiddle() - math.sin(gTime*2.2) * 12)
			UiText("R")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() + 240 + math.sin(gTime*2.3) * 14, UiMiddle() + math.sin(gTime*2.8) * 6)
			UiText("Y")
		UiPop()

		UiPush()
			UiTranslate(UiCenter() - 80 + math.sin(gTime*2.2) * 12, UiMiddle() + 120 + math.sin(gTime*2) * 18)
			UiText("S")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() - 0 - math.sin(gTime*1.8) * 10, UiMiddle() + 120 - math.sin(gTime*2.4) * 14)
			UiText("H")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() + 80 + math.sin(gTime*2.6) * 16, UiMiddle() + 120 + math.sin(gTime*1.8) * 20)
			UiText("O")
		UiPop()
		UiPush()
			UiTranslate(UiCenter() + 160 + math.sin(gTime*2.6) * 14, UiMiddle() + 120 + math.sin(gTime*1.8) * 12)
			UiText("W")
		UiPop()
	UiPop()
	
	return gTime < lengthTime
end


--------------------------------------------------------------------------------------------------------------------

function diyIntro(dt, params)
	local lengthTime = 8
	
	if gTime == 0 then
		creep = 500
		SetValue("creep", 0, "easeout", 1.4)
		UiSound("tv/diy-intro.ogg")
		sia1 = 0
		sia2 = 0
		sia3 = 0
		sia4 = 0
		sis1 = 0
		sis2 = 0
		sis3 = 0
		sis4 = 0
	end


	--subimage1
	if justPassed(0.5) then
		SetValue("sia1", 1, "easein", 1)
		SetValue("sis1", 4, "linear", 4)
	end
	if justPassed(2.5) then
		SetValue("sia1", 0, "easeout", 3)
	end

	--subimage2
	if justPassed(1.5) then
		SetValue("sia2", 1, "easein", 1)
		SetValue("sis2", 4, "linear", 4)
	end
	if justPassed(3.5) then
		SetValue("sia2", 0, "easeout", 3)
	end

	--subimage3
	if justPassed(2.5) then
		SetValue("sia3", 1, "easein", 1)
		SetValue("sis3", 4, "linear", 4)
	end
	if justPassed(4.5) then
		SetValue("sia3", 0, "easeout", 3)
	end

	--subimage4
	if justPassed(3.5) then
		SetValue("sia4", 1, "easein", 1)
		SetValue("sis4", 4, "linear", 4)
	end
	if justPassed(5.5) then
		SetValue("sia4", 0, "easeout", 3)
	end

	UiPush()
		local subImageSizeFactor = 0.5
		local subImageMoveFactor = 0.25
		local subImageMoveLength = UiWidth() / (lengthTime*2)

		-- BG eye
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter(), UiMiddle())
			UiColorFilter(1,1,1,gTime)
			UiScale(1+gTime*0.1)
			UiImage("tv/diybg.jpg")
		UiPop()
		-- Subimage1
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter() + sis1*subImageMoveLength, UiMiddle() + sis1*subImageMoveLength)
			UiColorFilter(1,1,1,sia1)
			UiScale(sis1*subImageSizeFactor)
			UiImage("tv/diy1.png")
		UiPop()
		-- Subimage1
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter() + sis2*subImageMoveLength, UiMiddle() - sis2*subImageMoveLength)
			UiColorFilter(1,1,1,sia2)
			UiScale(sis2*subImageSizeFactor)
			UiImage("tv/diy2.png")
		UiPop()
		-- Subimage3
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter() - sis3*subImageMoveLength, UiMiddle() - sis3*subImageMoveLength)
			UiColorFilter(1,1,1,sia3)
			UiScale(sis3*subImageSizeFactor)
			UiImage("tv/diy3.png")
		UiPop()
		-- Subimage4
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter() - sis4*subImageMoveLength, UiMiddle() + sis4*subImageMoveLength)
			UiColorFilter(1,1,1,sia4)
			UiScale(sis4*subImageSizeFactor)
			UiImage("tv/diy4.png")
		UiPop()
	UiPop()
	
	return gTime < lengthTime
end


--------------------------------------------------------------------------------------------------------------------


function news(dt, params)
	reporter = params.reporter or "reporter"
	public = params.public or "man"

	if gTime == 0 then
		tickerPos = 900
		done = false
		hideticker = 1
		event = 0
		eventTimer = 0.0
		eventTime = 0.0
		endSound = false
				
		randomStudio = math.random(0,3)
		randomReporter = math.random(0,3)

	end

	if justPassed(1.0) then
		SetValue("hideticker", 0, "easeout", 0.4)
	end

	if eventTimer <= 0.0 then
		event = event + 1
		if event > #params.events then
			event = 1
		end
		eventTimer = 5.0
		eventTime = 0.0
	end
	
	if event > 0 then
		local prevFirst = ""
		local prevSecond = ""
		if event > 1 then
			prevFirst = getFirst(params.events[event-1])
			prevSecond = getSecond(params.events[event-1])
		end

		local nextFirst = ""
		local nextSecond = ""
		if event < #params.events-1 then
			nextFirst = getFirst(params.events[event+1])
			nextSecond = getSecond(params.events[event+1])
		end

		if prevFirst == "reporter" or prevFirst == "interview" then prevSecond = "" end
		if nextFirst == "reporter" or nextFirst == "interview" then nextSecond = "" end

		local e = params.events[event]
		local first = getFirst(e)
		local second = getSecond(e)
		if first == "studio" then
			if blink then
				UiImage("tv/news_blink.jpg")
			else
				if talk then
					UiImage("tv/news_talk.jpg")
				else
					UiImage("tv/news.jpg")
				end
			end
			if second ~= "" then
				UiPush()
					local t = 1.0
					if second == prevSecond and eventTime < 0.5 then
						t = eventTime*2.0
					end
					if second == nextSecond and eventTimer < 0.5 then
						t = eventTimer*2.0
					end
					UiTranslate(320*t, 70*t)
					UiScale(1.0-0.6*t)
					UiImage(second)
				UiPop()
			end
		elseif first == "still" then
			UiImage(second)
		elseif first == "zoom" then
			UiPush()
				UiAlign("center middle")
				UiTranslate(UiCenter(), UiMiddle())
				UiScale(1 + eventTime*0.03)
				UiImage(second)
			UiPop()
		elseif first == "shake" then
			UiPush()
				UiTranslate(UiCenter() + shakeX*10, UiMiddle() + shakeY*10)
				UiAlign("center middle")
				UiScale(1.05)
				UiPush()
					UiRotate(math.deg((shakeX+shakeY)*0.005))
					UiImage(second)
				UiPop()
				UiTranslate(-shakeX*5, -shakeY*5)
				UiRotate(math.deg((shakeX+shakeY)*0.002))
				if gFrame%130 < 5 then
					UiImage("tv/" .. reporter .. "_blink.png")
				else
					if talk then
						UiImage("tv/" .. reporter .. "_talk.png")
					else
						UiImage("tv/" .. reporter .. ".png")
					end
				end
			UiPop()
		elseif first == "reporter" then
			UiPush()				
				UiTranslate(UiCenter() + shakeX*10, UiMiddle() + shakeY*10)
				UiAlign("center middle")
				UiScale(1.05)
				UiPush()
					UiRotate(math.deg((shakeX+shakeY)*0.005))
					UiImage(second)
				UiPop()
				UiTranslate(-shakeX*5, -shakeY*5)
				UiRotate(math.deg((shakeX+shakeY)*0.002))
				if reporter ~= "" then
					if blink then
						UiImage("tv/" .. reporter .. "_blink.png")
					else
						if talk then
							UiImage("tv/" .. reporter .. "_talk.png")
						else
							UiImage("tv/" .. reporter .. ".png")
						end
					end
				end
			UiPop()
		elseif first == "interview" then
			UiPush()				
				UiTranslate(UiCenter() + shakeX*10, UiMiddle() + shakeY*10)
				UiAlign("center middle")
				UiScale(1.05)
				UiPush()
					UiRotate(math.deg((shakeX+shakeY)*0.005))
					UiImage(second)
				UiPop()
				UiTranslate(-shakeX*5, -shakeY*5)
				UiImage("tv/" .. public .. ".png")
				UiTranslate(-shakeX*5, -shakeY*5)
				UiRotate(math.deg((shakeX+shakeY)*0.002))
				if reporter ~= "" then
					if blink then
						UiImage("tv/" .. reporter .. "_blink.png")
					else
						if talk then
							UiImage("tv/" .. reporter .. "_talk.png")
						else
							UiImage("tv/" .. reporter .. ".png")
						end
					end
				end
			UiPop()
		end
		
		if first == "reporter" or first == "interview" then
			UiSoundLoop("tv/reporter" .. randomReporter .. ".ogg", .5)
		else
			UiSoundLoop("tv/studio" .. randomStudio .. ".ogg", .5)
		end
	end
	
	eventTimer = eventTimer - dt
	eventTime = eventTime + dt
	
	UiPush()
		UiTranslate(0, 390 + 120*hideticker)
		UiColor(0.3, 0.0, 0.0)
		UiRect(640, 60)

		UiPush()
			UiFont("bold.ttf", 24)
			UiAlign("left middle")
			UiTranslate(0, -15)
			UiColor(1,1,1, 0.5)
			UiRect(330, 30)
			UiColor(0,0,0)
			UiTranslate(10, 0)
			UiText(params.title)
		UiPop()
		
		UiColor(1,1,1)
		UiTranslate(tickerPos, 30)
		tickerPos = tickerPos - dt*170
		UiFont("bold.ttf", 24)
		UiScale(2.0)
		UiAlign("left middle")
		local w, h = UiText(params.ticker)
		if tickerPos + w*2.0 < 0 then
			done = true
		end
	UiPop()

	UiPush()
		UiTranslate(580, 12)
		UiColor(1, 1, 1, 0.5)
		UiRect(60, 26)

		UiTranslate(10, 20)
		UiColor(0.5, 0, 0, 1)
		UiFont("bold.ttf", 24)
		UiText("LCN")
	UiPop()

	return not done
end

--------------------------------------------------------------------------------------------------------------------


function mystery(dt, params)
	if gTime == 0 then
		done = false
		event = 0
		subs = false
		eventTimer = 0.0
		eventTime = 0.0
		alpha = 3
		eventLength = params.eventlength
		bgimage = params.bgimage
		bgsound = params.bgsound
	end
	UiPush()

	if eventTimer <= 0.0 then
		event = event + 1
		if event > #params.events then
			done = true
			event = #params.events
		end

			eventLength = getSecond(getFirst(params.events[event],"|"),"*")
			if eventLength == nil then
				eventLength = 4.0
			end
			eventTimer = eventLength
			eventTime = 0.0

	end
	
	if event > 0 and event <= #params.events then
		UiSoundLoop(bgsound)
		local e = params.events[event]
		local first = getFirst(getFirst(e,"|"),"*")
		local second = getSecond(e,"|")
		local images = split(second)
		if first == "title" then
			UiPush()
				UiPush()
					UiAlign("center middle")
					UiTranslate(UiCenter(), UiMiddle())
					if params.bgzoom > 0 then
						UiScale(1 + gTime*0.05)
					end
					UiImage(bgimage)
				UiPop()
				UiAlign("center middle")
				UiTranslate(UiWidth()/2,UiHeight()/2)
				UiScale(1+eventTime*0.1)
				UiFont("bold.ttf", 48)
				UiText(second)
			UiPop()
		elseif first == "outro" then
			alpha = alpha - dt
			UiColorFilter(1,1,1,alpha)
			UiPush()
				UiPush()
					UiAlign("center middle")
					UiTranslate(UiCenter(), UiMiddle())
					if params.bgzoom > 0 then
						UiScale(1 + gTime*0.05)
					end
					UiImage(bgimage)
				UiPop()
				UiAlign("center middle")
				UiTranslate(UiWidth()/2,UiHeight()/2)
				UiScale(1+eventTime*0.1)
				UiFont("bold.ttf", 48)
				UiText(second)
			UiPop()
		else
			UiPush()
				UiAlign("center middle")
				UiTranslate(UiCenter(), UiMiddle())
				if params.bgzoom > 0 then
					UiScale(1 + gTime*0.05)
				end
				UiImage(bgimage)
			UiPop()
			

			if #images > 1 then
				local timePerImage = eventLength/(#images)
				for i= 0, math.floor(eventTime/(timePerImage)),1 do
					UiPush()
						--if i == 0 then
						--	UiColorFilter(1,1,1,1)
						--else
							UiColorFilter(1,1,1,eventTime-timePerImage*i)
						--end
						
						--UiColorFilter(1,1,1,eventTimer)
						UiAlign("center middle")
						UiTranslate(UiWidth()/2,UiHeight()/2)
						UiImage(images[i+1])
					UiPop()
				end
			else
				UiPush()
					UiAlign("center middle")
					UiTranslate(UiWidth()/2,UiHeight()/2)
					if #images == 1 then
						UiScale(1+eventTime*0.1)
					end
					UiImage(images[1])
				UiPop()	
			end
			if eventTime > 0.5 and eventTime < eventLength-0.5 then
				subs = true
			else
				subs = false
			end
			if subs then
				UiPush()
					UiColor(0, 0, 0, 1)
					UiAlign("top left")
					UiFont("bold.ttf", 32)
					local textw, texth = UiGetTextSize(first)
					UiTranslate(UiWidth()/2 - textw/2 - 10,UiHeight()-100 - 10)
					UiRect(textw + 10, texth + 10)
					UiColor(1, 1, 1, 1)
					UiTranslate(5,5)
					UiText(first)
				UiPop()
			end
		end
		UiPop()
	end
	
	eventTimer = eventTimer - dt
	eventTime = eventTime + dt
	
	return not done
end


--------------------------------------------------------------------------------------------------------------------



function commercial1(dt, params)
	if gTime == 0 then
		UiSound("tv/auction.ogg")
		top = 0
		middle = 0
		bottom = 0
	end

	if justPassed(1.0) then
		SetValue("top", 1, "linear", 0.3)
	end
	if justPassed(2.0) then
		SetValue("middle", 1, "linear", 0.3)
	end
	if justPassed(3.0) then
		SetValue("bottom", 1, "linear", 0.3)
	end

	UiImage(params.image)

	UiAlign("center middle")
	UiFont("bold.ttf", 24)

	if params.top then
		UiPush()
			local a = top
			UiTranslate(UiCenter(), UiMiddle()-100 - (1.0-a)*200)
			UiScale(2.0)
			UiTextOutline(0, 0, 0, a, 0.2)
			UiColor(1, 1, 1, a)
			UiText(params.top)
		UiPop()
	end
	if params.middle then
		UiPush()
			local a = middle
			UiTranslate(UiCenter(), 240)
			UiScale(3.0*a)
			UiTextOutline(0, 0, 0, a, 0.2)
			UiColor(0.5, 1, 1, a)
			UiText(params.middle)
		UiPop()
	end
	if params.bottom then
		UiPush()
			local a = bottom
			UiTranslate(UiCenter(), UiMiddle()+100 + (1.0-a)*200)
			UiScale(2.0)
			UiTextOutline(0, 0, 0, a, 0.2)
			UiColor(1, 1, 0, a)
			UiText(params.bottom)
		UiPop()
	end

	return gTime < 8
end


--------------------------------------------------------------------------------------------------------------------



function commercial(dt, params)
	if gTime == 0 then
		UiSound(params.audio)
		top1 = 0
		bottom1 = 0
		top2 = 0
		bottom2 = 0
		image2 = 0
		fade = 1

		color1 = params.color1 or {r=1, g=1, b=1}
		color2 = params.color2 or {r=1, g=1, b=1}
		color3 = params.color3 or {r=1, g=1, b=1}
		color4 = params.color4 or {r=1, g=1, b=1}

		font1 = params.font1 or "bold.ttf"
		font2 = params.font2 or "bold.ttf"
		font3 = params.font3 or "bold.ttf"
		font4 = params.font4 or "bold.ttf"

		size1 = params.size1 or 24
		size2 = params.size2 or 24
		size3 = params.size3 or 24
		size4 = params.size4 or 24
	end

	if justPassed(1.0) then
		SetValue("top1", 1, "linear", 0.3)
	end
	if justPassed(2.0) then
		SetValue("bottom1", 1, "linear", 0.3)
	end
	
	if justPassed(4.8) then
		SetValue("fade", 0, "easeout", 0)
	end

	if justPassed(5.0) then
		SetValue("top2", 1, "linear", 0.3)
	end
	if justPassed(6.0) then
		SetValue("bottom2", 1, "linear", 0.3)
	end

	if gTime >= 5.0 then
		UiPush()
			if params.zoom2 then
				UiAlign("center middle")
				UiTranslate(UiCenter(), UiMiddle())
				UiScale(1 + gTime*0.03)
			end
			UiImage(params.image2)
		UiPop()
		UiAlign("center middle")
	end

	if params.text3 then
		UiPush()
			local a = top2
			UiFont(font3, size3)
			UiTranslate(UiCenter(), UiMiddle()-150 - (1.0-a)*200)
			UiScale(2.5)
			UiTextOutline(0, 0, 0, a, 0.3)
			UiColor(color3.r, color3.g, color3.b, a)
			UiText(params.text3)
		UiPop()
	end
	if params.text4 then
		UiPush()
			local a = bottom2
			UiFont(font4, size4)
			UiTranslate(UiCenter(), UiMiddle()+150 + (1.0-a)*200)
			UiScale(2.5)
			UiTextOutline(0, 0, 0, a, 0.3)
			UiColor(color4.r, color4.g, color4.b, a)
			UiText(params.text4)
		UiPop()
	end

	if gTime < 5.0 then
		UiPush()
			if params.zoom1 then
				UiAlign("center middle")
				UiTranslate(UiCenter(), UiMiddle())
				UiScale(1 + gTime*0.03)
			end
			UiImage(params.image1)
		UiPop()
		
		UiAlign("center middle")

		if params.text1 then
			UiPush()
				local a = top1
				UiFont(font1, size1)	
				UiTranslate(UiCenter(), UiMiddle()-150 - (1.0-a)*200)
				UiScale(2.5)
				UiTextOutline(0, 0, 0, a, 0.3)
				UiColor(color1.r, color1.g, color1.b, a)
				UiText(params.text1)
			UiPop()
		end
		if params.text2 then
			UiPush()
				local a = bottom1
				UiFont(font2, size2)
				UiTranslate(UiCenter(), UiMiddle()+150 + (1.0-a)*200)
				UiScale(2.5)
				UiTextOutline(0, 0, 0, a, 0.3)
				UiColor(color2.r, color2.g, color2.b, a)
				UiText(params.text2)
			UiPop()
		end
	end
	
	return gTime < 11
end


--------------------------------------------------------------------------------------------------------------------


function addShow(showFunc, showParams)
	gShows[#gShows+1] = {func = showFunc, params = showParams}
end


function isMissionCompleted(missionId)
	return GetInt("savegame.mission."..missionId..".score") > 0
end


function init()
	gTime = 0
	gTimeLast = 0
	gFrame = 0
	gFadeToBlack = 0

	gShows = {}
	addShow(pause, {length = 1})

	local lastCompleted = GetString("savegame.lastcompleted")


	if not isMissionCompleted("mall_intro") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Wrecked revenues",
				ticker = "The demolition sector continues to see a steep drop off in revenue following a quarter where construction outdid demolition by 437%. \"The demolition business just isn't what it used to be\" says Tracy from Löckelle Teardown Services.",
				events = 
				{
					"studio", 
					"studio tv/demochart.jpg", 
					"still tv/demochart.jpg", 
					"still tv/demochart.jpg", 
					"studio tv/tracy-mugshot.jpg", 
					"studio", 
					"studio", 
				}
			}	
		)
		addShow(news,
			{
				title = "Lee Chemicals in the black",
				ticker = "Lee Chemicals finally showed black figures for the last fiscal year. CEO Lawrence Lee Jr says they have expanded into \"new markets\" but doesn't want to go into further detail.",
				events = 
				{
					"studio", 
					"studio tv/lee.jpg", 
					"zoom tv/lee.jpg", 
					"studio",
				}
			}	
		)
		addShow(newsOutro)
	end

	if isMissionCompleted("mall_intro") and not isMissionCompleted("lee_computers") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Cultural heritage site destroyed",
				ticker = "The locally famous Löckelle Folk Museum has been demolished. Caretaker and enthusiast Bret Johnson found the building razed when arriving this morning. According to the police, the perpetrators did a quick job on the old building. An investigation has been opened.",
				events = 
				{
					"zoom tv/mall-intro-intro.jpg", 
					"studio tv/mall-intro-intro.jpg", 
					"studio tv/mall-intro-bg.jpg", 
					"interview tv/mall-intro-bg.jpg", 
					"zoom tv/mall-intro1.jpg",  
					"studio tv/mall-intro1.jpg", 
					"studio", 
				}
			}	
		)
		addShow(news,
			{
				title = "Lee Chemicals marina move",
				ticker = "Lee Chemicals is moving parts of their operation to the Westpoint marina. \"This opens up opportunities in new business areas where we, together with our partners, can disrupt the market through long term strategic synergies.\" says Lawrence Lee Jr, CEO of Lee Chemicals.",
				public="lawrence-lee-jr",
				events = 
				{
					"studio tv/lee2.jpg", 
					"zoom tv/lee2.jpg", 
					"interview tv/lee1.jpg", 
					"interview tv/lee1.jpg", 
					"interview tv/lee1.jpg", 
					"studio tv/lee1.jpg",
					"studio",
					"studio",
				}
			}	
		)
		addShow(newsOutro)
	end

	if isMissionCompleted("lee_computers") and not isMissionCompleted("lee_login") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Hit and run no fun for Lee son",
				ticker = "There has been a break-in at Lee Chemicals. The perpetrator caused property damage and managed to get away with electronic equipment. CEO Lawrence Lee Jr says they will upgrade security and should be up and running again soon.",
				public = "lawrence-lee-jr",
				events = 
				{
					"studio", 
					"reporter tv/lee.jpg", 
					"studio tv/lee.jpg", 
					"interview tv/destroyed.jpg", 
					"studio tv/lee-in-office.jpg", 
					"zoom tv/lee-in-office.jpg", 
					"studio",
				}
			}	
		)
		addShow(newsOutro)
		addShow(commercial1, {image="tv/auction.jpg", top="Black River", middle="Classic car auction", bottom="  This Wednesday\nCall 555-188-2789"})
	end

	if isMissionCompleted("lee_login") and not isMissionCompleted("marina_demolish") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Burglars gain access to gain access",
				ticker = "Lee Chemicals was hit by another smash and grab this weekend. Several buildings were damaged and a number of devices from the entry security system were stolen. The police says the break-in might be related to the event last week when computers were stolen.",
				events = 
				{
					"studio", 
					"studio tv/lee-login4.jpg", 
					"studio tv/lee-login5.jpg", 
					"studio tv/lee-login6.jpg", 
					"zoom tv/lee-login4.jpg", 
					"zoom tv/lee-login5.jpg", 
					"zoom tv/lee-login6.jpg", 
					"studio", 
				}
			}	
		)
		addShow(newsOutro)
		addShow(commercial,
			{
				audio = "tv/gubbgrill.ogg",
				image1 = "tv/ad-gubbgrill1.jpg",
				zoom1 = true,
				text1 = "Decent food",
				text2 = "Decent prices",
				image2 = "tv/ad-gubbgrill2.jpg",
				text3 = "In Westpoint marina",
				text4 = "Try our special!",
				size1 = 18,
				size2 = 18,
				size3 = 18,
				size4 = 18,
				color1 = {r=1, g=0, b=0},
				color2 = {r=1, g=1, b=0},
				color3 = {r=1, g=0, b=0},
				color4 = {r=1, g=1, b=0},
			}	
		)
	end
	
	if isMissionCompleted("marina_demolish") and not isMissionCompleted("marina_cars") then
		addShow(mysteryIntro)
		addShow(mystery,
			{
				eventlength = 6,
				bgimage = "tv/mystery-eye.jpg",
				bgsound="tv/mystery2.ogg",
				bgzoom = 1,
				events = 
				{
					"title*4|The ghost cabin", 
					"The four ocean cabins at the Westpoint marina.\nA popular holiday resort for many years.*6|tv/mystery-cabinphoto.jpg",
					"But according to harbor master Jim Daeglish,\nthere used to be five cabins.*8|tv/mystery-4cabins.png tv/mystery-5cabins.png", 
					"We searched through all available records.\nBut no proof of a fifth cabin could be found.*6|tv/mystery-document1.png tv/mystery-document2.png tv/mystery-document3.png tv/mystery-document4.png tv/mystery-document5.png tv/mystery-document6.png", 
					"Without evidence the rumors still persist.\nOf a ghost cabin...*6|tv/mystery-ghostcabin.png tv/mystery-questionmarks.png", 
					"outro*6|Next week:\nArt, or remnants\nfrom the afterlife?"
				}
			}
		)
	end

	if lastCompleted == "marina_cars" then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Aged automobiles abducted",
				ticker = "Two classic cars were reported stolen from Westpoint marina last night. \"Just typical, luck has not been on my side recently.\" says Lawrance Lee Jr who had bought the cars at an auction just a few days ago.",
				events = 
				{
					"studio", 
					"studio tv/lee-cars-intro.jpg", 
					"still tv/lee-cars-intro.jpg",
					"zoom tv/lee-cars1.jpg",
					"zoom tv/lee-cars2.jpg",
					"studio tv/lee-cars-intro.jpg",
				}
			}	
		)
		addShow(newsOutro)		
	end
	
	if lastCompleted == "marina_gps" then
		addShow(newsIntro)
		addShow(news,
			{
				title = "GPS units stolen",
				ticker = "The marina and several boats were damaged yesterday as thieves broke in and got away with expensive GPS navigation units. Harbor master Jim Daeglish says the marina has been subject to a string of vandalism and burglary incidents lately.",
				events = 
				{
					"studio", 
					"studio tv/marina-gps-intro.jpg", 
					"still tv/marina-gps-intro.jpg",
					"zoom tv/marina-gps1.jpg",
					"zoom tv/marina-gps2.jpg",
					"studio tv/marina-gps-intro.jpg", 
				}
			}	
		)
		addShow(newsOutro)
		addShow(commercial,
			{
				audio = "tv/expensive-kitchenware.ogg",
				image1 = "tv/ad-knife1.jpg",
				zoom1 = true,
				text1 = "Sharp.",
				text2 = "Simple.",
				image2 = "tv/ad-knife2.jpg",
				text3 = "Expensive.",
				text4 = "Knives.",
				color1= {r=0, g=0, b=0},
				color2= {r=0, g=0, b=0},
				color3= {r=0, g=0, b=0},
				color4= {r=0, g=0, b=0},
			}	
		)
	end

	if lastCompleted == "mansion_pool" then		
		addShow(newsIntro)
		addShow(news,
			{
				title = "Villa Gordon vandalized",
				ticker = "Returning from a business trip, Mr Woo found several of his valuable cars dumped in the ocean this morning. He says he has no idea why anyone would do this and calls it a tragedy.",
				events = 
				{
					"studio", 
					"studio tv/carwash-intro.jpg", 
					"still tv/carwash-intro.jpg",
					"zoom tv/carwash1.jpg",
					"zoom tv/carwash2.jpg",
					"studio",  
					"studio",
				}
			}	
		)
	end	

	if lastCompleted == "lee_safe" then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Spectacular break-in at Lee",
				ticker = "Lee chemicals suffered another spectacular break-in last night where property was damaged and the perpetrators got away with heavy security equipment according to the police. \"What is happening to Löckelle, do you need locks for your locks nowadays!?\" says CEO Lawrence Lee Jr.",
				events = 
				{
					"studio", 
					"studio tv/lee-safe1.jpg", 
					"still tv/lee-safe1.jpg", 
					"zoom tv/lee-safe2.jpg", 
					"studio tv/lee-safe2.jpg", 
					"still tv/lee-safe3.jpg", 
					"studio tv/lee-safe3.jpg", 
				}
			}	
		)
	end

	if isMissionCompleted("marina_cars") and not isMissionCompleted("lee_tower") then
		addShow(news,
			{
				title = "Lee Tower - 75th anniversary",
				ticker = "This weekend Lee Chemicals is celebrating the 75-year anniversary of the completion of the famous Lee Tower. Built by Lawrence Lee Sr, the Tower stands at an impressive 22 meters tall and was built with almost 3000 bricks. The top floor offers an amazing view of the surrounding countryside, including the dam and the new powerplant. After completion it was incorporated into the Lee Chemicals brand, symbolizing the success of the company.",
				public = "lawrence-lee-jr",
				events = 
				{
					"studio", 
					"studio tv/towerdocu-3.jpg", 
					"reporter tv/towerdocu-bg.jpg", 
					"studio tv/lee-grandfather.jpg", 
					"interview tv/towerdocu-bg.jpg", 
					"zoom tv/towerdocu-1.jpg",
					"zoom tv/towerdocu-6.jpg",
					"zoom tv/towerdocu-5.jpg",
					"zoom tv/towerdocu-9.jpg", 
					"studio tv/lee-chemicals-logo.jpg",
					"studio",
				}
			}	
		)
		addShow(newsOutro)
	end

	if isMissionCompleted("lee_tower") and not isMissionCompleted("mansion_art") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Lee tower toppled",
				ticker = "Lee chemicals famous tower torn down by unknown trespassers. This shameful deed happened right before the 75th anniversary of the tower. Rummaging around in the rubble, Lawrence Lee Jr express grief and anger. \"These half-wit neanderthals don't know what's coming for them! Attacking the heart and soul of my company! Of my family!\" he fumes, visibly upset.",
				public="lawrence-lee-jr",
				events = 
				{
					"zoom tv/lee-tower-intro.jpg", 
					"studio tv/lee-tower-intro.jpg", 
					"studio tv/lee-tower1.jpg", 
					"zoom tv/lee-tower2.jpg", 
					"zoom tv/lee-tower3.jpg", 
					"zoom tv/lee-tower4.jpg", 
					"interview tv/lee-tower-bg.jpg", 
					"studio tv/lee-tower-bg.jpg", 
					"studio", 
				}
			}	
		)
		addShow(newsOutro)
		addShow(commercial,
			{
				audio = "tv/parade.ogg",
				text1 = "Löckelle celebrations!",
				image1 = "tv/ad-parade1.jpg",
				text2 = "Home guard parade",
				image2 = "tv/ad-parade2.jpg",
				zoom2 = true,
				text3 = "Live music and fireworks!",
				size4 = 20,
				text4 = "See you at Evertides Mall!",
			}	
		)
	end

	if lastCompleted == "marina_tools" then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Tools missing from the marina",
				ticker = "Several expensive tools have been reported missing from the new dock construction at the marina. The police still have no suspect.",
				events = 
				{
					"studio tv/tools-intro.jpg", 
					"zoom tv/tools-intro.jpg",
					"studio tv/tools1.jpg", 
					"studio tv/tools2.jpg", 
					"studio", 
				}
			}	
		)
	end
	
	if isMissionCompleted("mansion_art") and not isMissionCompleted("marina_art_back") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Thunderstorm approaching",
				ticker = "A massive thunderstorm is approaching and is expected to hit the coast tonight. Meteorologist Sara Nimbusson recommends everyone to stay indoors and away from windows.",
				events = 
				{
					"studio", 
					"studio tv/weather3.jpg",
					"still tv/weather3.jpg", 
					"still tv/weather6.jpg", 
					"studio tv/weather6.jpg",
					"studio tv/weather6.jpg",
				}
			}	
		)
		addShow(newsOutro)
		addShow(commercial,
			{
				audio = "tv/bayran.ogg",
				image1 = "tv/ad-bayrans1.jpg",
				zoom1 = true,
				text1 = "When you are looking for",
				text2 = "a bright future",
				image2 = "tv/ad-bayrans2.jpg",
				text3 = "Choose",
				color3= {r=0, g=0, b=0},
				text4 = "Bayrans",
				size4 = 42,
				color4= {r=0, g=0, b=0},
			}	
		)
	end

	if lastCompleted == "mansion_fraud" then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Noise at Villa Gordon",
				ticker = "Loud noises near Villa Gordon. \"It sounded like they were tearing the place apart!\", bypassing jogger tells LCN. Mr Woo assures that there is nothing to worry about: \"This is typical of people who simply don't understand racing\"",
				events = 
				{
					"zoom tv/fraud4.jpg",
					"still tv/fraud2.jpg",
					"studio tv/fraud2.jpg",
					"zoom tv/fraud1.jpg",
					"studio tv/fraud1.jpg",
					"studio tv/fraud3.jpg",
					"studio",
				}
			}	
		)
		addShow(newsOutro)
		addShow(commercial,
			{
				audio = "tv/bluetide.ogg",
				image1 = "tv/ad-bluetide1.jpg",
				image2 = "tv/ad-bluetide3.jpg",
				zoom1 = true,
				text1 = "BlueTide",
				size1 = 36,
				text2 = "It's a lifestyle",
			}	
		)
	end

	if isMissionCompleted("marina_art_back") and not isMissionCompleted("caveisland_computers") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Marina struck by lightning",
				ticker = "Several buildings at the Westpoint marina were damaged during the thunderstorm last night. \"It's a miracle that the buildings are still standing. We see signs of fire, but the heavy rain must have put them all out!\" says harbor master Jim Daeglish.",
				events = 
				{
					"studio tv/thunder1.jpg", 
					"zoom tv/thunder4.jpg", 
					"zoom tv/thunder5.jpg", 
					"zoom tv/thunder2.jpg", 
					"studio tv/thunder2.jpg", 
					"zoom tv/thunder6.jpg",
					"zoom tv/thunder3.jpg",
				}
			}	
		)
		addShow(newsOutro)
		addShow(commercial,
			{
				audio = "tv/russian-caviar.ogg",
				image1 = "tv/ad-caviar1.jpg",
				zoom1 = true,
				text1 = "Want to impress?",
				text2 = "Want to flash cash?",
				image2 = "tv/ad-caviar2.jpg",
				text3 = "Russian caviar",
				color3= {r=1, g=0, b=0},
				text4 = "Goes well with\n fishy business",
			}	
		)
	end

	if isMissionCompleted("caveisland_computers") and not isMissionCompleted("mansion_safe") then
		addShow(diyIntro)
		addShow(mystery,
			{
				eventlength = 6,
				bgimage = "tv/black.jpg",
				bgsound="tv/diy.ogg",
				bgzoom = 0,
				events = 
				{
					"title*4|Portable\nwaterproof\nshed", 
					"The rain is pouring down. But you need to move\nyour precious water-sensitive swordfish.*6|tv/waterproof-rain.jpg tv/waterproof-precious.png",
					"And as it turns out, you have no covered truck.\nOnly an open truck, and some tables.*9|tv/w1.jpg tv/w3.jpg tv/w4.jpg", 
					"With some creativity you can build yourself a\nbeautiful portable shed!*6|tv/w5.jpg tv/w5.jpg", 
					"Or maybe you have some other material lying\naround, and can build these?*16|tv/white.jpg tv/w6s.png tv/w7s.png tv/w8s.png tv/w9s.png tv/w10s.png tv/w11s.png tv/w12s.png tv/w13s.png tv/w14s.png",
					"With some basic tools and some craftiness,\n your swordfish can travel safely.*5| tv/waterproof-precious.png", 
					"outro*6|Next week:\nA wall but no hole?\nWe play with\nEXPLOSIVES!?"
				}
			}
		)
	end

	if isMissionCompleted("mansion_safe") and not isMissionCompleted("lee_powerplant") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Increase in vandalism",
				ticker = "There has been yet another break-in in Löckelle county, this time the victim was Gordon Woo. The perpetrators managed to steal several of Mr Woo's personal safes. \"I'm clueless as to why they stole the safes, it's very unlikely that they will be able to open them, they are state of the art Quilez safes\", Woo said in an interview.",
				events = 
				{
					"studio", 
					"studio",
					"studio tv/gordon-office.jpg", 
					"studio tv/mansion-safe2.jpg", 
					"zoom tv/mansion-safe2.jpg", 
					"still tv/mansion-safe1.jpg", 
					"studio tv/mansion-safe1.jpg", 
					"studio",
				}
			}	
		)
		addShow(newsOutro)
		addShow(commercial,
			{
				audio = "tv/expensive-kitchenware.ogg",
				image1 = "tv/ad-foodprocessor1.jpg",
				zoom1 = true,
				text1 = "Mix.",
				text2 = "Blend.",
				image2 = "tv/ad-foodprocessor2.jpg",
				text3 = "Expensive.",
				text4 = "Food processor.",
				color1= {r=0, g=0, b=0},
				color2= {r=0, g=0, b=0},
				color3= {r=0, g=0, b=0},
				color4= {r=0, g=0, b=0},
			}	
		)
	end

	if lastCompleted == "caveisland_propane" then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Loud bangs in archipelago",
				ticker = "Several reports of loud bangs heard across the Löckelle archipelago yesterday evening. The coast guard sweeps the area to localize the noise. Oceanologist Dr. Pieré Troch says it might have been underwater gas pockets releasing hot gases as a result of the bad weather.",
				public = "troch",
				events = 
				{
					"studio", 
					"studio tv/propane2.jpg", 
					"studio tv/propane1.jpg", 
					"zoom tv/propane1.jpg", 
					"interview tv/propane3.jpg", 
					"interview tv/propane3.jpg", 
					"studio", 
				}
			}	
		)
		addShow(newsOutro)
	end

	if isMissionCompleted("lee_powerplant") and not isMissionCompleted("caveisland_dishes") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Reservoir dam breaks",
				ticker = "A sudden rise in water levels was reported in Löckelle municipality after the dam broke. Löckelle Recreational Fishing Club's Alisha Keen claims flooded areas are covered by current Quiteshallow fishing permits.",
				public="keen",
				events = 
				{
					"studio", 
					"studio tv/dam3.jpg", 
					"zoom tv/dam1.jpg", 
					"interview tv/dam2.jpg", 
					"studio tv/dam2.jpg",
					"studio",
				}
			}	
		)
		addShow(newsOutro)
	end

	if isMissionCompleted("caveisland_dishes") and not isMissionCompleted("lee_flooding") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Sudden satellite-TV coverage",
				ticker = "Since this morning a number of citizens have reported that they can now receive television programs previously unavailable. \"Finally I can watch the live broadcast of 'Best chefs of Greenland'\" says local food aficionado Graham Stölöp. There is no immediate explanation according to the National Television Commission.",
				public="stolop",
				events = 
				{
					"studio", 
					"studio tv/satelite2.jpg",
					"still tv/satelite2.jpg",
					"interview tv/satelite1.jpg", 
					"interview tv/satelite1.jpg", 
					"studio tv/satelite1.jpg", 
					"studio tv/ntc.jpg", 
					"studio",
				}
			}
		)
		addShow(newsOutro)
		addShow(commercial,
			{
				audio = "tv/bluetide.ogg",
				image1 = "tv/ad-bluetide2.jpg",
				text2 = "It's a lifestyle",
				image2 = "tv/ad-bluetide4.jpg",
				zoom2 = true,
				text3 = "BlueTide Extra Strong",
				text4 = "limited edition - $75",
			}	
		)
	end
	if isMissionCompleted("lee_flooding") and not isMissionCompleted("frustrum_chase") then
		addShow(commercial,
			{
				audio = "tv/bluetide.ogg",
				image1 = "tv/ad-bluetide2.jpg",
				text2 = "It's a lifestyle",
				image2 = "tv/ad-bluetide4.jpg",
				zoom2 = true,
				text3 = "BlueTide Extra Strong",
				text4 = "limited edition - $75",
			}	
		)
		addShow(commercial,
			{
				audio = "tv/expensive-kitchenware.ogg",
				image1 = "tv/ad-foodprocessor1.jpg",
				zoom1 = true,
				text1 = "Mix.",
				text2 = "Blend.",
				image2 = "tv/ad-foodprocessor2.jpg",
				text3 = "Expensive.",
				text4 = "Food processor.",
				color1= {r=0, g=0, b=0},
				color2= {r=0, g=0, b=0},
				color3= {r=0, g=0, b=0},
				color4= {r=0, g=0, b=0},
			}	
		)
	end

	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	---
	--				PART 2
	---
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------

	if isMissionCompleted("frustrum_chase") and not isMissionCompleted("factory_espionage") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Lee Chemicals decommissioned",
				ticker = "Following the arrest of Lawrence Lee Junior this summer, Lee Chemicals filed for bankrupcy and the historic chemical plant was decommisioned. The factory is currently scheduled for controlled demolision and the plot is on the market.",
				events = 
				{
					"studio tv/lee-convicted3.jpg", 
					"studio tv/lee-demolish3.jpg",
					"zoom tv/lee-demolish3.jpg",
					"still tv/lee-demolish2.jpg",
					"studio tv/lee-demolish1.jpg",
					"studio tv/lee-for-sale1.jpg",
					"zoom tv/lee-for-sale1.jpg",
					"still tv/lee-for-sale1.jpg",
				}
			}
		)
		addShow(newsOutro)
	end	

	if isMissionCompleted("factory_espionage") and not isMissionCompleted("caveisland_ingredients") then
		addShow(newsIntro)
		addShow(news,
			{
				title = "Gordon Woo buys Lee plot",
				ticker = 'Mr Woo announced today that he is taking over the land of the former Lee Chemicals factory. "Seeing these iconic buildings go away is hard for me who grew up here in Löckelle, but I think my new plans for this place will give our community something even more memorable.", says Mr Woo.',
				public = "gordon-office-solo",
				reporter = "",
				events = 
				{
					"studio",
					"studio tv/evertides1.jpg",
					"interview tv/evertides-breakin2.jpg",
					"interview tv/evertides-breakin2.jpg",
					"still tv/gordon-buys-lee1.jpg",
					"still tv/gordon-buys-lee2.jpg",
					"zoom tv/gordon-buys-lee2.jpg",
					"studio tv/gordon-buys-lee2.jpg",
					"studio",
				}
			}
		)
		addShow(newsOutro)
	end	

	if isMissionCompleted("caveisland_ingredients") and not isMissionCompleted("frustrum_tornado") then
		addShow(newsIntro)
		addShow(news,
			{
				title = 'Frustrum evacuated',
				ticker = 'Löckelle is currently experiencing unusually strong winds for this time of year. Over to Sara Nimbusson. "A storm is approaching Frustrum, we might even get local tornadoes." The residents have been evacuated.',
				events = 
				{
					"studio tv/frustrum-evacuated1.jpg", 
					"studio tv/frustrum-evacuated2.jpg",
					"still tv/nimbuson-tornado.jpg", 
					"studio tv/nimbuson-tornado.jpg",
					"studio",
					"studio",
				}
			}
		)
		addShow(news,
			{
				title = 'BlueTide shortage',
				ticker = 'Demand for the popular energy drink surges and it is currently out of stock in several stores. Meanwhile voices are raised towards health concerns as some people find it strangely addictive. We have tried to reach BlueTide Inc for a comment.',
				events = 
				{
					"studio tv/bluetide-shortage6.jpg",
					"studio tv/bluetide-shortage2.jpg",
					"zoom tv/bluetide-shortage3.jpg",
					"still tv/bluetide-shortage4.jpg",
					"zoom tv/bluetide-shortage4.jpg",
					"studio tv/bluetide-shortage5.jpg",
					"studio",
				}
			}
		)
		addShow(newsOutro)
	end	

	if isMissionCompleted("frustrum_tornado") and not isMissionCompleted("mall_shipping") then
		addShow(newsIntro)
		addShow(news,
			{
				title = 'Tornado strikes Frustrum',
				ticker = 'Massive property damage has been reported as tornadoes hit Frustrum. "This is the worst I\'ve seen in Löckelle!" Thanks to an early evacuation no injuries have been reported.',
				events = 
				{
					"studio tv/tornado-damage2.jpg",
					"studio tv/tornado-damage3.jpg",
					"reporter tv/tornado-damage1.jpg",
					"studio tv/tornado-damage4.jpg",
					"studio tv/tornado-damage5.jpg",
				}
			}
		)
		addShow(newsOutro)
	end

	if isMissionCompleted("mall_shipping") and not isMissionCompleted("carib_alarm") then
		addShow(newsIntro)
		addShow(news,
			{
				title = 'Break-in at Evertides',
				ticker = 'There has been a break-in at Evertides Mall. "We have had some.. issues with the former upper management, but one of my first actions is to deepen our strategic partnership with Quilez security", says newly appointed mall manager Erin Gregorius.',
				public = "erin-gregorius",
				events = 
				{
					"studio tv/evertides-breakin1.jpg",
					"still tv/evertides-breakin1.jpg",
					"interview tv/evertides-breakin2.jpg",
					"interview tv/evertides-breakin2.jpg",
					"still tv/evertides-breakin3.jpg",
					"zoom tv/evertides-breakin3.jpg",
					"studio tv/evertides-breakin3.jpg",
				}
			}
		)		
		addShow(newsOutro)
		--new song
		addShow(commercial,
			{
				audio = "tv/bayran.ogg",
				image1 = "tv/sunnymax2.jpg",
				zoom1 = true,
				zoom2 = true,
				text1 = "Sun in mind",
				text2 = "Electric kind",
				image2 = "tv/sunnymax3.jpg",
				text3 = "SunnyMax solarium",
				text4 = "Like the real deal. Almost.",
				color1= {r=214/255, g=208/255, b=53/255},
				color2= {r=214/255, g=208/255, b=53/255},
				color3= {r=214/255, g=208/255, b=53/255},
				color4= {r=214/255, g=208/255, b=53/255},
			}	
		)
	end	

	--more images of woonderland
	if isMissionCompleted("carib_alarm") and not isMissionCompleted("frustrum_vehicle") then
		addShow(newsIntro)
		addShow(news,
			{
				title = 'Truck stuck in muck',
				ticker = "A military truck being delivered to Löckelle Home Guard got stuck in the Löckelle canal today due to bad weather.\"We have been working all afternoon, but not getting anywhere\", says Oliver Funke with the Löckelle Home Guard. They will continue the operation tomorrow.",
				public = "oliver-funke",
				events = 
				{
					"studio",
					"studio tv/stuck-in-muck1.jpg",
					"still tv/stuck-in-muck1.jpg",
					"interview tv/truck-missing2.jpg",
					"still tv/stuck-in-muck1.jpg",
					"zoom tv/stuck-in-muck1.jpg",
					"still tv/stuck-in-muck2.jpg",
					"zoom tv/stuck-in-muck2.jpg",
					"studio tv/stuck-in-muck2.jpg",
					"studio",
				}
			}
		)	
		addShow(news,
			{
				title = 'New theme park announced',
				ticker = "Gordon Woo's \"Racing Woonderland\" will open just in time for the holidays. \"This is very close to heart. Löckelle has been missing a place where young people can gather around their interest in racing, have fun and talk about their local heroes. There will be racing rides, motorcycle carousel and even swan boats!\", says Mr Woo.",
				events = 
				{
					"still tv/visit-woonderland2.jpg",
					"still tv/visit-woonderland3.jpg",
					"zoom tv/visit-woonderland3.jpg",
					"still tv/visit-woonderland1.jpg",
					"still tv/visit-woonderland4.jpg",
					"zoom tv/visit-woonderland4.jpg",
				}
			}
		)
		addShow(newsOutro)
	end	

	if isMissionCompleted("frustrum_vehicle") and not isMissionCompleted("mall_radiolink") then
		addShow(newsIntro)
		addShow(news,
			{
				title = 'Military truck missing',
				ticker = "The truck that was stuck in the Frustrum canal was mysteriously found missing this morning. \"We suspect it got caught in the stream and we are now dragging the entire canal\", says Oliver Funke with the Home Guard.",
				public = "oliver-funke",
				events = 
				{
					"studio",
					"studio tv/truck-missing1.jpg",
					"still tv/truck-missing1.jpg",
					"interview tv/truck-missing2.jpg",
					"zoom tv/truck-missing1.jpg",
					"studio tv/truck-missing1.jpg",
				}
			}
		)	
		addShow(newsOutro)
		--new song
		addShow(commercial,
			{
				audio = "tv/bayran.ogg",
				image1 = "tv/evertides-christmas1.jpg",
				zoom1 = true,
				zoom2 = true,
				text1 = "Excited for the holidays?",
				text2 = "So are we!",
				image2 = "tv/evertides-christmas2.jpg",
				text3 = "Get in the spirit",
				text4 = "at Evertides Mall!",
				color2= {r=169/255, g=57/255, b=62/255},
				color1= {r=62/255, g=149/255, b=62/255},
				color4= {r=169/255, g=57/255, b=62/255},
				color3= {r=62/255, g=149/255, b=62/255},
			}	
		)
	end	

	if isMissionCompleted("mall_radiolink") and not isMissionCompleted("factory_robot") then
		addShow(newsIntro)
		addShow(news,
			{
				title = 'Evertides struck by vandalism',
				ticker = "The mall has been the target for heavy vandalism. Even though large portions of the building were torn down, no items have been reported stolen. \"Everything is currently on sale since the mall will need to close for renovations\" says mall manager Erin Gregorius.",
				public = "erin-gregorius",
				reporter = "",
				events = 
				{
					"studio tv/evertides-vandals1.jpg",
					"still tv/evertides-vandals1.jpg",
					"studio tv/evertides-vandals1.jpg",
					"studio tv/evertides-vandals2.jpg",
					"interview tv/evertides-vandals1.jpg",
					"still tv/evertides-vandals2.jpg",
					"studio tv/evertides-vandals2.jpg",
					"studio tv/evertides-vandals3.jpg",
					"still tv/evertides-vandals3.jpg",
					"zoom tv/evertides-vandals3.jpg",
				}
			}
		)
		addShow(newsOutro)
		--new song
		addShow(commercial,
			{
				audio = "tv/bayran.ogg",
				image1 = "tv/visit-woonderland3.jpg",
				zoom1 = true,
				zoom2 = true,
				text1 = "Speed, excitement, fun!",
				text2 = "Grand opening! Wroom!",
				image2 = "tv/visit-woonderland4.jpg",
				text3 = "Treat yourselves,",
				text4 = "visit Woonderland!",
				color1= {r=149/255, g=57/255, b=62/255},
				color2= {r=196/255, g=196/255, b=196/255},
				color3= {r=149/255, g=57/255, b=62/255},
				color4= {r=196/255, g=196/255, b=196/255},
			}	
		)
	end	

	if lastCompleted == "lee_woonderland" then
		addShow(news,
			{
				title = 'Gordon Woo bankrupt',
				ticker = "Racing enthusiast and former millionaire Gordon Woo filed for personal bankrupcy today, following the vandalism of his Racing Woonderland, just before the grand opening. The liquidator is looking for a new owner, but has found no interest so far.",
				events = 
				{
					"studio",
					"studio tv/woonderland-vandals1.jpg",
					"studio tv/woonderland-vandals2.jpg",
					"studio tv/woonderland-vandals3.jpg",
					"studio tv/woonderland-vandals4.jpg",
				}
			}
		)	
	end

	if isMissionCompleted("factory_robot") and not isMissionCompleted("factory_explosive") then
		addShow(newsIntro)
		addShow(news,
			{
				title = 'Suspected BlueTide overdose',
				ticker = "A teenager in Frustrum was found unconscious this morning, surrounded by large quantities of BlueTide cans. Medical experts are still evaluating the situation, but people are already protesting, demanding a ban on the popular energy drink.",
				events = 
				{
					"studio",
					"studio tv/teenager1.jpg",
					"still tv/teenager1.jpg",
					"studio tv/teenager1.jpg",
					"studio tv/teenager3.jpg",
					"zoom tv/teenager4.jpg",
					"studio tv/teenager4.jpg",
				}
			}
		)
		addShow(newsOutro)
		addShow(commercial,
			{
				audio = "tv/bayran.ogg",
				image1 = "tv/robot-ad2.jpg",
				zoom1 = true,
				text1 = "You have 20 seconds..",
				image2 = "tv/robot-ad1.jpg",
				text3 = "To recieve 10% off your",
				text4 = "new Quilez model 245!",
				color1= {r=149/255, g=40/255, b=40/255},
				color3= {r=1, g=1, b=1},
				color4= {r=1, g=1, b=1},
			}	
		)
	end	
	
	--rewrite and add a rock expert? make a new show?
	if isMissionCompleted("factory_explosive") and not isMissionCompleted("caveisland_roboclear") then
		addShow(news,
			{
				title = 'Rock solid science',
				ticker = "They are often taken for \"granited\", but how are cliffs made? Both water and wind work together in the creation of cliffs. Erosional cliffs forming among shorelines, like the steep cliffs in Cullington, tend to retreat more rapidly than other slopes due to the most extensive erosion taking place at the base of the cliff.",
				events = 
				{
					"studio",
					"studio tv/cliff1.jpg",
					"still tv/cliff1.jpg",
					"zoom tv/cliff2.jpg",
					"still tv/cliff3.jpg",
					"zoom tv/cliff3.jpg",
					"zoom tv/cliff4.jpg",
					"zoom tv/cliff5.jpg",
				}
			}
		)	
	end	

	if isMissionCompleted("caveisland_roboclear") and not isMissionCompleted("cullington_bomb") then
		addShow(newsIntro)
		addShow(news,
			{
				title = 'Strange vehicle spotted',
				ticker = "A heavy vehicle approaching Cullington has stirred up quite a scene in the neighborhood and a lot of people are evacuating their homes. \"I was just heading over to my brother when I saw this weird-looking truck. Being quite a big fella I tried to stop it, but it appears to have no driver!\", says Kenneth Rippe, eager to leave town with his brother.",
				public = "kenneth-rippe",
				events = 
				{
					"studio tv/truxterminator1.jpg",
					"still tv/truxterminator1.jpg",
					"still tv/truxterminator2.jpg",
					"studio tv/truxterminator2.jpg",
					"interview tv/truxterminator3.jpg",
					"interview tv/truxterminator3.jpg",
					"interview tv/truxterminator3.jpg",
					"still tv/truxterminator2.jpg",
					"studio tv/truxterminator2.jpg",
				}
			}
		)	
		addShow(newsOutro)
	end	

	--add amanatides
	if isMissionCompleted("cullington_bomb") then
		--addShow(newsIntro)
		addShow(news,
			{
				title = 'BlueTide boss behind bars',
				ticker = "Following the spectacular arrest on Hollowrock Island involving a vault with a secret tunnel and a drug lab on a private island in the Muratoris, Mr. Amanatides, the owner of BlueTide Inc, was convicted for mixing addictive substances into the popular energy drink. BlueTide has since been withdrawn from the market.",
				events = 
				{
					"studio tv/raid4.jpg",
					"still tv/raid5.jpg",
					"zoom tv/raid8.jpg",
					"still tv/raid7.jpg",
					"zoom tv/raid6.jpg",
					"studio tv/raid1.jpg",
					"still tv/raid1.jpg",
					"still tv/raid2.jpg",
					"studio tv/raid2.jpg",
					"studio tv/raid3.jpg",
					"zoom tv/raid3.jpg",
					"studio tv/raid3.jpg",
				}
			}
		)	
		addShow(newsOutro)
	end	
	
	gCurrentShow = 1
	
	shakeX = 0
	shakeY = 0
	shakeDx = 0
	shakeDy = 0

	talk = false
	talkTimer = 10
	
end


function update()
	gFrame = gFrame + 1
	shakeDx = (shakeDx + math.random(-100,100)*0.0003) * 0.9
	shakeDy = (shakeDy + math.random(-100,100)*0.0003) * 0.9
	shakeX = (shakeX + shakeDx) * 0.99
	shakeY = (shakeY + shakeDy) * 0.99
	if shakeX > 1.0 then shakeX = 1.0 shakeDx = 0.0 end
	if shakeX < -1.0 then shakeX = -1.0 shakeDx = 0.0 end
	if shakeY > 1.0 then shakeY = 1.0 shakeDy = 0.0 end
	if shakeY < -1.0 then shakeY = -1.0 shakeDy = 0.0 end

	talkTimer = talkTimer - 1
	if talkTimer <= 0 then
		talk = not talk
		talkTimer = math.random(2, 10)
	end
	
	blink = (gFrame%130) < 5
end


function draw()
	if UiHeight() ~= 480 then
		UiPush()
			UiColor(0.2, 0.2, 0.2)
			UiRect(UiWidth(), UiHeight())
		UiPop()
		UiTranslate(UiCenter(), UiMiddle())
		UiAlign("center middle")
		UiWindow(640, 480, true)
		UiAlign("left")
		UiPush()
			UiColor(0,0,0)
			UiRect(UiWidth(), UiHeight())
		UiPop()
	end
	local dt = GetTimeStep()
	UiPush()
		local done = not gShows[gCurrentShow].func(dt, gShows[gCurrentShow].params)
	UiPop()

	if done then
		gFadeToBlack = gFadeToBlack + dt*3.0
		if gFadeToBlack >= 1.0 then
			gCurrentShow = gCurrentShow + 1
			if gCurrentShow > #gShows then
				gCurrentShow = 1
			end
			gTime = 0.0
			gTimeLast = 0.0
		end
	else
		if gFadeToBlack > 0.0 then
			gFadeToBlack = gFadeToBlack - dt*3.0
			if gFadeToBlack < 0.0 then gFadeToBlack = 0 end
		end
		gTimeLast = gTime
		gTime = gTime + dt
	end

	if gFadeToBlack > 0.0 then
		UiColor(0, 0, 0, gFadeToBlack)
		UiRect(640, 480)
	end
end


