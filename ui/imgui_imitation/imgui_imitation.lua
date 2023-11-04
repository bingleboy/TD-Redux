--This script and it's assets are entirely portable, so feel free to use them for yourself.

function imguiWindow(w,h,header,open,wrap)
	header = header or "Untitled Window"
	closed = false
	
	if open then
		UiImageBox("imgui_imitation/window_header.png",w,19,2,2)
	else
		UiImageBox("imgui_imitation/window.png",w,19,2,2)
	end
	UiPush()
		UiTranslate(9.5,9.5)
		UiAlign("center middle")
		UiPush()
			if not open then UiRotate(90) end
			if UiIsMouseInRect(17,17) then
				if InputDown("lmb") then
					UiColor(0.8,0.8,0.8)
				end
				UiImage("imgui_imitation/hover.png")
				if InputReleased("lmb") then
					open = not open
				end
			end
			UiImage("imgui_imitation/dropdown.png")
		UiPop()
		UiPush()
			UiTranslate(9.5,0)
			UiAlign("left middle")
			imguiFont(13)
			UiText(header)
		UiPop()
		UiPush()
			UiTranslate(w-19,0)
			if UiIsMouseInRect(17,17) then
				if InputDown("lmb") then
					UiColor(0.8,0.8,0.8)
				end
				UiImage("imgui_imitation/hover.png")
				if InputReleased("lmb") then
					closed=true
				end
			end
			UiImage("imgui_imitation/x.png")
		UiPop()
	UiPop()
	if open then
		UiTranslate(0,19)
		UiWindow(w,h-19,true)
		UiTranslate(0,-19)
		UiImageBox("imgui_imitation/window.png",w,h,2,2)
		UiTranslate(0,19)
		if wrap then UiWordWrap(w) end
	end
	return open, closed
end

function imguiRect(w,h,clip,wrap)
	clip = clip or true
	wrap = wrap or true
	UiImageBox("imgui_imitation/window.png",w,h,2,2)
	UiWindow(w,h,clip)
	if wrap then UiWordWrap(w) end
end

function imguiCheckbox(checked, text)
	offset=0
	changed = false
	if checked then offset = 19 end
	UiPush()
		if UiIsMouseInRect(19,19) then
			UiColor(1.33,1.33,1.33,1)
			if InputDown("lmb") then
				UiColor(2,2,2,1)
			end
			if InputReleased("lmb") then
				checked = not checked
				changed = true
			end
		end
		UiImage("imgui_imitation/checkbox.png",offset,0,19+offset,19)
		UiTranslate(24,0)
		imguiFont(13)
		UiText(text)
	UiPop()
	return checked, changed
end

function imguiFont(size)
	UiFont("imgui_imitation/ProggyClean.ttf",size)
end