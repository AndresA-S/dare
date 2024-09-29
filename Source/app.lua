import 'CoreLibs/timer'

import 'backgroundBar'
import 'dynamicText'
import 'progressBar'
import 'tasks'

local barMaxWidth, barRadius <const> = 170, 4

local store         		<const> = playdate.datastore.read()
local timer         		<const> = playdate.timer
local minorFontName 		<const> = 'Roobert-11-Medium'
local majorFontName 		<const> = 'Roobert-24-Medium'
local taskLabel     		<const> = DynamicText(0, 0, minorFontName, 'left')
local infoLabel     		<const> = DynamicText(400, 0, minorFontName, 'right')
local instructionLabel		<const> = DynamicText (120, 155, minorFontName, 'centre')
local instructionLabel2		<const> = DynamicText (120, 185, minorFontName, 'centre')
local instruction   		<const> = DynamicText(200, 120, majorFontName, 'center')
local backgroundBar 		<const> = BackgroundBar(115, 120 + 22, barMaxWidth, barRadius)
local progressBar   		<const> = ProgressBar(115, 120 + 22, 0, barRadius)


App = {}

App.taskCursor        = store and store.taskCursor or 1
App.instructionCursor = 1
App.actualTask        = tasks[App.taskCursor]
App.timer             = nil

-- private functions:

local function refreshLabels()
	taskLabel:setContent(App.actualTask['name'])
	infoLabel:setContent(App.actualTask['info'])
	instructionLabel:setContent(nil)
	instructionLabel2:setContent(nil)

end

local function resetTimer()
	if App.timer then
		App.timer:remove()
	end

	local i = App.actualTask.instructions[App.instructionCursor]
	instruction:setContent(i.name)
	App.timer = timer.new(i.time, 0, barMaxWidth)
end

local function changeInstruction()
	App.instructionCursor = App.instructionCursor % #App.actualTask.instructions + 1
end

-- public methods:

function App:setup()
	refreshLabels()
	resetTimer()
	playdate.display.setInverted(true)
end

function App:run()

	if self.actualTask['name'] == 'Diffuse' then
		
		-- 'instructionCursor' points to the current 'instruction' in the 'task'
		local currentInstruction = self.actualTask.instructions[self.instructionCursor]

        if currentInstruction then
            -- Display the 'name' of the 'instruction' from the 'Diffuse' task on the screen
            instruction:setContent(currentInstruction.name)
        end

		instructionLabel:setContent("Ⓐ  No, it doesn't!")
		instructionLabel2:setContent("Ⓑ  It definitely does not!")


		-- Sets the width of the progress bar to zero to not display it 
		progressBar:setVisible(false)
        backgroundBar:setVisible(false)


	else
		-- Display and update the progress bar for other tasks
		progressBar:setVisible(true)
        backgroundBar:setVisible(true)
		progressBar:setWidth(self.timer.value)

	end

	sprite.update()
	timer.updateTimers()

	if self.timer.timeLeft == 0 then
		changeInstruction()
		resetTimer()
	end
end

function App:changeTask()
	self.instructionCursor = 1
	self.taskCursor        = self.taskCursor % #tasks + 1
	self.actualTask        = tasks[self.taskCursor]

	refreshLabels()
	resetTimer()
end

function App:write()
	playdate.datastore.write({ taskCursor = self.taskCursor })
end
