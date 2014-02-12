local settings = require 'settings'
local storyboard = require 'storyboard'
local widget = require 'widget'
local cacharro = require 'vendor.cacharro.cacharro'
local dbconfig = require 'vendor.dbconfig.dbconfig'
local log = require 'vendor.log.log'

local scene = storyboard.newScene()
local webview, questionGrp, params

function table.shuffle(t)
	math.randomseed(os.time())
	assert(t, "table.shuffle() expected a table, got nil")
	local iterations = #t
	local j
	for i = iterations, 2, -1 do
		j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

---- Constants
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local halfViewX = display.viewableContentWidth / 2
local halfViewY = display.viewableContentHeight / 2
local rightX = centerX + halfViewX
local leftX = centerX - halfViewX
local bottomY = centerY + halfViewY
local topY = centerY - halfViewY
local backgroundSize = 1024

local function webListener( event )
	if event.type == 'loaded' then
		native.setActivityIndicator(false)
	elseif event.type == 'link' then
		vent:trigger('weburl', event.url)
		local url = event.url
		local protos, protoe = string.find(url, 'corona:')
		if protos and protoe then
			vent:trigger('coronaurl', event.url)
		end
	end
end

local function bye()
	sounds.pop()
	storyboard.hideOverlay('slideDown', 200)
end

local function showWebview()
	webview = native.newWebView(centerX - halfViewX, centerY - halfViewY, display.actualContentWidth, display.actualContentHeight)

		native.setActivityIndicator()
		webview:request(url)
		webview:addEventListener('urlRequest', webListener)
	-- end
end

local function answerTap(e)
	sounds.pop()
	if not e.target.ok then
		e.target:setFillColor(190, 70, 63)
		timer.performWithDelay(1000, bye)
	else
		display.remove(questionGrp)
		showWebview()
	end

	return true
end

function scene:exitScene()
	if webview then
		webview:removeSelf()
		webview = nil
	end
	questionGrp = nil
end

function scene:createScene(event)
	params = event.params
	assert(params and params.url, 'Called webview without params.url')

	local white = display.newRect( self.view, 0, 0, display.actualContentWidth, display.actualContentHeight )
	white:setReferencePoint(display.CenterReferencePoint)
	white.x = centerX
	white.y = centerY

	local questions = {
		{32, 15, {47, 45, 37}},
		{37, 12, {49, 31, 39}},
		{51, 32, {83, 80, 73}}
	}
	local questionNum = math.random(1, #questions)
	local question = questions[questionNum]

	local answers = {1, 2, 3}
	answers = table.shuffle(answers)

	local titleLbl = display.newImage(self.view, "vendor/forparents/images/parentgateText_"..lang..".png")
	titleLbl.x = centerX
	titleLbl.y = centerY - 200
	titleLbl.xScale = 0.8
	titleLbl.yScale = 0.8


	local pickLbl = display.newImage(self.view, "vendor/forparents/images/operation".. questionNum ..".png")
	pickLbl.x = centerX
	pickLbl.y = centerY - 100
	pickLbl.xScale = 0.8
	pickLbl.yScale = 0.8

	local leftBtn = display.newImage(self.view, "vendor/forparents/images/"..question[3][answers[1]]..".png")
	leftBtn.x = centerX - 200
	leftBtn.y = centerY + 80
	leftBtn.ok = answers[1] == 1
	leftBtn.xScale = 0.8
	leftBtn.yScale = 0.8
	leftBtn:addEventListener("tap", answerTap)


	local centerBtn = display.newImage(self.view, "vendor/forparents/images/"..question[3][answers[2]]..".png")
	centerBtn.x = centerX
	centerBtn.y = centerY + 80
	centerBtn.ok = answers[2] == 1
	centerBtn.xScale = 0.8
	centerBtn.yScale = 0.8
	centerBtn:addEventListener("tap", answerTap)

	local rightBtn = display.newImage(self.view, "vendor/forparents/images/"..question[3][answers[3]]..".png")
	rightBtn.x = centerX + 200
	rightBtn.y = centerY + 80
	rightBtn.ok = answers[3] == 1
	rightBtn.xScale = 0.8
	rightBtn.yScale = 0.8
	rightBtn:addEventListener("tap", answerTap)

	local backBtn = display.newImage(self.view, "vendor/forparents/images/back.png")
	backBtn:setReferencePoint(display.TopLeftReferencePoint)
	backBtn.x = leftX - 20
	backBtn.y = topY - 20
	backBtn.xScale = 0.9
	backBtn.yScale = 0.9
	backBtn:addEventListener("tap", bye)
end

function scene:enterScene()
end

scene:addEventListener('createScene', scene)
scene:addEventListener('enterScene', scene)
scene:addEventListener('exitScene', scene)
return scene

