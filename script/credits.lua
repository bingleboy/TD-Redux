#include "common.lua"


gCredits = 
{
	{
		{
			title = "Designed and directed by",
			content = {"Dennis Gustafsson"},
			pos = "lower",
			t0 = 22,
			t1 = 28,
		},
		{
			title = "Level design",
			content = {"Emil Bengtsson", "Kabi Jedhagen", "Olle Lundahl", "John Kearney", "Dennis Gustafsson"},
			pos = "lower left",
			t0 = 29,
			t1 = 38,
		},
		{
			title = "Voxel modeling",
			content = {"Emil Bengtsson", "John Kearney", "Olle Lundahl", "Kabi Jedhagen", "Niklas Mäckle", "Dennis Gustafsson", "Stefan Jonsson"},
			pos = "lower right",
			t0 = 38,
			t1 = 51,
		},
	},
	{
		{
			title = "Engine programming",
			content = {"Dennis Gustafsson", "Ludde Andersson"},
			pos = "center",
			t0 = 1,
			t1 = 8,
		},
		
		{
			title = "Music and sound design",
			content = {"Douglas Holmquist"},
			pos = "upper right",
			t0 = 10,
			t1 = 20,
		},
		{
			title = "Musicians",
			content = {"Andreas Baw", "Douglas Holmquist", "Kristian Durán"},
			scale = 0.8,
			pos = "right",
			t0 = 11,
			t1 = 20,
		},
		{
			title = "Foley artists",
			content = {"Mathias Schlegel", "Douglas Holmquist"},
			scale = 0.8,
			pos = "lower right",
			t0 = 12,
			t1 = 20,
		},
		{
			title = "Art direction",
			content = {"John Kearney"},
			pos = "upper",
			t0 = 21,
			t1 = 27,
		},
		{
			title = "Gameplay programming",
			content = {"Dennis Gustafsson", "Emil Bengtsson", "Olle Lundahl"},
			pos = "lower left",
			t0 = 28,
			t1 = 36,
		},	},
	{
		{
			title = "Project Management",
			content = {"Dennis Gustafsson", "Emil Bengtsson", "Marcus Dawson", "Deniz Misirli"},
			pos = "upper left",
			t0 = 1,
			t1 = 9,
		},
		{
			title = "Quality assurance",
			content = {"William Bergh", "Larry Walsh"},
			pos = "upper right",
			t0 = 3,
			t1 = 11,
		},
		{
			title = "A game by",
			content = {"Tuxedo Labs"},
			pos = "centered",
			t0 = 13,
			t1 = 24,
		},
	},
}


gPart = 0
gTime = 0


function init()
	local lvl = GetString("game.levelpath")
	if string.find(lvl, "hub.xml") then
		gPart = 1
	elseif string.find(lvl, "mansion.xml") then
		gPart = 2
	elseif string.find(lvl, "marina.xml") then
		gPart = 3
	end
end


function tick(dt)
	gTime = gTime + dt
end


function draw()
	if gPart == 0 then
		return
	end
	local sections = gCredits[gPart]
	local sectionsEnd = false
	for i=1, #sections do
		local s = sections[i]
		if gTime > s.t0 and gTime < s.t1 then
			UiPush()
			UiAlign("left")
			local width = 250
			local height = 32 + #s.content*36
			if string.find(s.pos, "lower") then
				UiTranslate(0, UiHeight() - 250 - height)
			elseif string.find(s.pos, "upper") then
				UiTranslate(0, 250)
			else
				UiTranslate(0, UiMiddle() - height/2)
			end
			if string.find(s.pos, "left") then
				UiTranslate(300, 0)
			elseif string.find(s.pos, "right") then
				UiTranslate(UiWidth() - 300 - width, 0)
			else
				UiTranslate(UiCenter()-width/2, 0)
			end
			if string.find(s.pos, "centered") then
				UiTranslate(width/2, 0)
				UiAlign("center")
			end	
			if s.scale then
				UiScale(s.scale)
			end
			local alpha = 1.0
			local fadeTime = 1.0
			local t = gTime - s.t0
			local duration = s.t1 - s.t0
			if t < fadeTime then
				alpha = t/fadeTime
			elseif t > duration-fadeTime then
				alpha = (duration-t)/fadeTime
			end
			UiColor(1,1,1,alpha)
			UiTextOutline(0,0,0,alpha,0.2)
			UiFont("bold.ttf", 32)
			UiText(s.title)
			UiFont("regular.ttf", 40)
			UiTranslate(0, UiFontHeight())
			for j=1, #s.content do
				UiText(s.content[j])		
				UiTranslate(0, 36)
			end
			UiPop()
		end

		sectionsEnd = gTime > s.t1 and i == #sections
	end

	if sectionsEnd and gPart == #sections and not Credits.prepared then
		Credits.prepare()
	elseif Credits.prepared then
		UiPush()
			UiColor(0,0,0)
			UiRect(UiWidth(), UiHeight())
		UiPop()
		
		Credits.draw()

		UiPush()
			UiColor(0,0,0)
			UiRect(UiWidth(), 100)
			UiTranslate(0, UiHeight()-100)
			UiRect(UiWidth(), 100)
		UiPop()
	end

	Credits.drawHint()

	if Credits.finished then
		Menu()
	end	
end
