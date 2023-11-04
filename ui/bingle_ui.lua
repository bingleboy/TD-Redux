#include "imgui_imitation/imgui_imitation.lua"
--[[
	This function draws a simple UI stepper widget for selecting one item from a list.
	vals - list of strings, all the possible values for the stepper
	index - the current index of the stepper
	resX, resY - the size of the stepper.
	loop - a boolean, determines if the items should loop or not.
	image - image for the left & right arrows.
	bg_color - the background color of the stepper
	width_scale - the width scale of the arrows. Useful in some cases when the image isn't wide enough
	
	it returns the index of the current item, and a boolean stating if that index changed.
	
]]--

lorem ="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

function UiStepper(vals,index,resX,resY,loop,image,bgR,bgG,bgB,bgA,width_scale)
	loop = loop or false
	image = image or "menu/arrow_button.png"
	bgR = bgR or 0.0
	bgG = bgG or 0.0
	bgB = bgB or 0.0
	bgA = bgA or 0.5
	width_scale = width_scale or 1
	changed = false
	local maxIndex = #vals
	UiPush()
		local w,h = UiGetImageSize(image)
		UiPush()
			UiColor(bgR,bgG,bgB,bgA)
			UiImageBox("common/box-6.png",resX,resY,3,3)
		UiPop()
		UiPush()
			UiColor(1,1,1)
			UiAlign("top right")
			UiPush()
				if not loop and index<=1 then
					UiColor(0.5,0.5,0.5)
					UiDisableInput()
				end
				UiScale((-width_scale*resY)/h,resY/h)
				if UiImageButton(image) then
					index = index - 1
					changed = true
				end
			UiPop()
			UiPush()
				if not loop and index>=maxIndex then
					UiColor(0.5,0.5,0.5)
					UiDisableInput()
				end
				UiTranslate(resX,0)
				UiScale((width_scale*resY)/h,resY/h)
				if UiImageButton(image) then
					index = index + 1
					changed = true
				end
			UiPop()
		UiPop()
		UiPush()
			buttonWidth = w*(width_scale*resY)/h
			UiTranslate(buttonWidth)
			UiWindow(resX-(2*buttonWidth),resY,true)
			UiTranslate((resX/2)-buttonWidth,resY/2)
			UiAlign("center middle")
			UiColor(1,1,1,1)
			UiFont("regular.ttf",resY*0.8)
			UiText(vals[index])
		UiPop()
	UiPop()
	if index < 1 then
		if loop then index = maxIndex else index = 1 end
	end
	if index > maxIndex then
		if loop then index = 1 else index = maxIndex end
	end
	return index, changed
end