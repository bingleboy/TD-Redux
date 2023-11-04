function init()
	aboutPos = GetLocationTransform(FindLocation("start", true)).pos
	aboutEnd = GetLocationTransform(FindLocation("end", true)).pos
	aboutEndFade = 0
	aboutStartFade = 1
	SetValue("aboutStartFade", 0, "linear", 4)
		
	aboutInfo = 
	{
		{ image = "ui/menu/logo.png" },
		{ title = "Dennis Gustafsson", info="Programming, game design\nStory and original idea\nGame director\nLee Chemicals" },
		{ title = "Emil Bengtsson", info="Missions, level design and assets\nLöckelle Hub\nFrustrum\nQuilez security" },
		{ title = "Olle Lundahl", info="Evertides Mall\nMuratori islands\nAssets, challenges" },
		{ title = "Douglas Holmquist", info="Music and sound design" },
		{ title = "Kabi Jedhagen", info="West point Marina\nVilla Gordon\nHollowrock Island" },
		{ title = "John Kearney", info="Art direction\nAssets, lighting" },
		{ title = "Niklas Mäckle", info="Assets, vehicles, trees" },
		{ title = "Ludde Andersson", info="Additional programming" },
		{ title = "Marcus Dawson", info="Project management\nQuality assurance" },
		{ title = "William Bergh", info="Quality assurance" },
		{ title = "Larry Walsh", info="Quality assurance" },
		{ title = "Deniz Misirli", info="Additional project management" },
		{ title = "Stefan Jonsson", info="Additional level design, assets" },
		{ title = "Special thanks", info="ephtracy\nMathias Schlegel\nAndreas Baw\nKristian Durán\nShailesh Prabhu\nSimon Flesser\nDaniel Andersson\nAlex Camilleri\nJohan Eriksson\nMalmö DevHub" },
		{ title = "Teardown uses", info="libjpeg (libjpeg.sourceforge.net)\nlibpng (libpng.org)\nzlib (zlib.net)\nlua (lua.org)\nogg vorbis (xiph.org/vorbis)\nstb_truetype (github.com/nothings/stb)\nglew (glew.sourceforge.net)\nDear ImGui (github.com/ocornut/imgui)\nRapidXML (rapidxml.sourceforge.net)\nLato font by Lukasz Dziedzic (latofonts.com)\nSkyboxes from noemotion.net (CC BY-ND 4.0)\nSkyboxes from polyhaven.com (CC0) and hdri-skies.com\n" },
	}
end


function tick()
	SetBool("game.disablepause", true)
	SetBool("game.disablemap", true)

	local dt = GetTimeStep()
	aboutPos[1] = aboutPos[1] + dt * 1.7
	
	if aboutPos[1] > aboutEnd[1] and aboutEndFade == 0 then
		-- main scene end
		SetValue("aboutEndFade", 1, "linear", 3)
	end
	if aboutEndFade == 1 or (InputLastPressedKey()~="") then
		Menu()
	end
	
	SetCameraTransform(Transform(aboutPos), 90)
	PlayMusic("about.ogg")
	
end


function draw()
	local canvas = UiCanvasSize()
	UiWindow(canvas.w, canvas.h)

	local locs = FindLocations("txt", true)
	for i=1,#locs do
		local loc = locs[i]
		local pos = GetLocationTransform(loc).pos
		local x,y,d = UiWorldToPixel(pos)
		if x > -500 and x < UiWidth()+500 then
			UiPush()
				UiTranslate(x-100, y)
				UiAlign("left")
				local a = aboutInfo[i]
				if a then
					if a.image then
						UiImage(a.image)
					end
					if a.title and a.info then
						UiFont("bold.ttf", 44)
						UiText(a.title)
						UiTranslate(0, 24)
						UiFont("regular.ttf", 22)
						UiAlign("left")
						UiColor(.8, .8, .8)
						UiText(a.info, true)
					end
				end
			UiPop()
		end
	end
	
	if aboutEndFade > 0 then
		UiMute(Credits.fade, true)
		UiColor(0,0,0,aboutEndFade)
		UiRect(UiWidth(), UiHeight())
		
	end
	
	if aboutStartFade > 0 then
		UiColor(0,0,0,aboutStartFade)
		UiRect(UiWidth(), UiHeight())
	end
	
end

