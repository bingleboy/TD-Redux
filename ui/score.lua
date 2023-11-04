#include "game.lua"


function getScoreDetails(id, score)
	local mission = gMissions[id];

	local details = {}
	details.required = mission.required
	details.optional = mission.primary + mission.secondary - mission.required

	if score >= mission.required then
		details.requiredTaken = mission.required
	else
		details.requiredTaken = score
	end

	details.optionalTaken = clamp(score - mission.required, 0, mission.primary + mission.secondary - mission.required)

	details.bonuses = 0
	details.bonusesTaken = 0
	details.bonus = {}
	local s = mission.primary + mission.secondary
	for i=1, #mission.bonus do
		local t = mission.bonus[i]

		if score >= s then
			details.bonuses = details.bonuses + 1
			details.bonus[i] = {}
			details.bonus[i].desc = t.." seconds left"
			if score > s then
				details.bonus[i].score = 1
				details.bonusesTaken = details.bonusesTaken + 1
			else
				details.bonus[i].score = 0
			end
		end
		s = s + 1
	end

	return details
end


function drawTargetDots(count, taken, blinkUntaken)
	UiPush()
		for i=1,count do
			if taken >= i then
				UiPush()
					UiScale(0.65,0.65)
					UiImage("common/score-target-taken-1.png")
				UiPop()
			else
				UiPush()
					if blinkUntaken then
						local a = .7 + math.sin(GetTime()*10)*0.3
						UiColorFilter(1, 1, 1, a)
					end
					UiScale(0.65,0.65)
					UiImage("common/score-target-1.png")
				UiPop()
			end
			UiTranslate(-18, 0)
		end
	UiPop()
	return 18*count
end


gScoreShown = 0
gScoreCanvasHeight = 0
gScoreTimer = 0
gScoreBonusScale = 0
gScoreStatsScale = 0


function initDrawScore()
	gScoreShown = 0
	gScoreTimer = 0.5
	gScoreCanvasHeight = 0
	SetValue("gScoreBonusScale", 0)
	SetValue("gScoreStatsScale", 0)
end


function drawScore(title, id, score, timeLeft, missionTime, animate, scoreFrame)
	UiPush()
		UiAlign("left")
		local details
		if animate then
			local eval = false
			if gScoreShown < score+1 then
				gScoreTimer = gScoreTimer - GetTimeStep()
				if gScoreTimer < 0.0 then
					gScoreShown = gScoreShown + 1
					gScoreTimer = 0.15
					if gScoreShown == score+1 then
						SetValue("gScoreStatsScale", 1, "linear", 0.5)
						UiSound("common/score-stats-500.ogg")
					else
						eval = true
					end
				end
			end
			if gScoreShown < score then
				score = gScoreShown
			end
			details = getScoreDetails(id, score);
			if eval then
				if score <= details.required + details.optional then
					UiSound("score.ogg")
				else
					UiSound("common/score-bonus.ogg")
				end

				if score == details.required then
					gScoreTimer = gScoreTimer + 0.2
				end
				if score == details.required + details.optional then
					gScoreTimer = gScoreTimer + 0.4
					if gScoreBonusScale == 0.0 and details.bonuses > 0 then
						SetValue("gScoreBonusScale", 1, "linear", 0.3)
						UiSound("common/score-bonus-shown.ogg")
					end
				end
				if score > details.required + details.optional then
					gScoreTimer = gScoreTimer + 0.2
				end
			end
		else
			details = getScoreDetails(id, score);
			gScoreBonusScale = 1
			gScoreStatsScale = 1
		end

		UiTranslate(0, 20)
		UiFont("bold.ttf", 24)
		UiColor(.5, .5, .5)
		UiTranslate(30, 0)
		if scoreFrame then
			UiImageBox("common/score-frame-7.png", 390, gScoreCanvasHeight, 7, 7)
			UiPush()
				local scoreTitle = "Score"
				local title = scoreTitle .. " " .. score
				local w = UiGetTextSize(title)
				UiTranslate(30, -14)
				UiColor(.27,.27,.27)
				UiRect(w+16, 30)
				UiColor(1, 1, 1)
				UiTranslate(10, 22)
				UiText(title, true)
			UiPop()
		end
		UiTranslate(40, 50)

		UiColor(1, 1, 1)
		UiFont("bold.ttf", 22)
		UiText("Targets", true)
		UiTranslate(0, -4)
		UiFont("regular.ttf", 20)

		UiColor(1,1,1)
		UiPush()
			UiTranslate(260, -16)
			drawTargetDots(details.required, details.requiredTaken)
		UiPop()
		UiText("Required", true)

		if details.optional > 0 then
			UiPush()
				UiTranslate(260, -16)
				UiColor(.6, .6, .6)
				drawTargetDots(details.optional, details.optionalTaken, true)
			UiPop()
			UiText("Optional", true)
		end

		if #details.bonus > 0 then
			UiTranslate(0, 15)
			UiFont("regular.ttf", 24)
			UiColor(.5, .8, .5)
			local h;
			UiPush()
				UiScale(1, gScoreBonusScale)
				UiText("Bonus", true)
				UiTranslate(0, -4)
				UiFont("regular.ttf", 20)
				UiColor(0.6,0.75,0.6)
				for i=1, #details.bonus do
					UiPush()
						UiTranslate(260, -16)
						UiColor(.6, .8, .6)
						drawTargetDots(1, details.bonus[i].score, true)
					UiPop()
					UiText(details.bonus[i].desc, true)
					_,h = UiGetRelativePos()
				end
			UiPop()
			UiTranslate(0, h)
		end

		UiTranslate(0, 15)
		UiFont("bold.ttf", 24)
		UiColor(1, 1, .7)
		UiText("Stats", true)
		UiTranslate(0, -4)

		UiFont("regular.ttf", 20)
		UiColor(1, 1, .7)
		if timeLeft > 0 then
			UiPush()
				if gScoreStatsScale > 0 then
					UiTranslate(280, 0)
					UiAlign("right")
					UiText(math.floor(timeLeft*gScoreStatsScale*10+0.5)/10 .. "s")
				end
			UiPop()
			UiText("Time left", true)
		end
		if missionTime > 0 then
			UiPush()
				if gScoreStatsScale > 0 then
					UiTranslate(280, 0)
					UiAlign("right")							
					local m = math.floor(gScoreStatsScale*missionTime/60)
					local s = math.floor(gScoreStatsScale*missionTime-m*60)
					if m > 0 then
						UiText(m.."m "..s.."s")
					else
						UiText(s.."s")
					end
				end
			UiPop()
			UiText("Mission time", true)
		end
		if timeLeft == 0 and missionTime == 0 then
			UiText("Mission skipped", true)
		end
		_,gScoreCanvasHeight = UiGetRelativePos()
	UiPop()
	return gScoreCanvasHeight
end

