local settings = require 'settings'
local storyboard = require 'storyboard'
local widget = require 'widget'
local log = require 'vendor.log.log'
local vent = require 'vendor.vent.vent'
local t = require 'vendor.tableutils.tableutils'

local scene = storyboard.newScene()
local webview, questionGrp, params, nav

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
	storyboard.hideOverlay('slideDown', 200)
end

local function showWebview()
	webview = native.newWebView(centerX - halfViewX, centerY - halfViewY + 70, display.actualContentWidth, display.actualContentHeight - 70)

	native.setActivityIndicator()
	webview:request(params.url)
	webview:addEventListener('urlRequest', webListener)
end

local function answerTap(e)
	if not e.target.ok then
		local errorColor = params.errorBackground or {190, 70, 63}
		e.target:setFillColor(unpack(errorBackground))
		timer.performWithDelay(1000, bye)
	else
		display.remove(questionGrp)
		questionGrp = nil
		nav:toFront()
		showWebview()
	end

	return true
end

function scene:exitScene()
	if webview then
		webview:removeSelf()
		webview = nil
	end
	vent:off('showurl', self.showUrl)
	questionGrp = nil
end

function scene.showUrl(event)
	if webview then
		local url = event.url or event.value
		if url then
			webview:request(url)
		end
	end
	return true
end

function scene:createScene(event)
	vent:on('showurl', self.showUrl)
	params = event.params
	local lang = params.lang or 'en'
	assert(params and params.url, 'Called webview without params.url')
	local navBgColor = params.navBackground or {0, 0, 0}

	if params.nav then
		nav = params.nav
	else
		nav = display.newGroup()
		local navBg = display.newRect(nav, 0, 0, display.actualContentWidth, 70)
		navBg:setReferencePoint(display.TopCenterReferencePoint)
		navBg.x = centerX
		navBg.y = centerY - halfViewY
		navBg:setFillColor(unpack(navBgColor))

		local navBack = display.newImage(nav, "vendor/gate-webview/images/back.png", true)
		navBack:setReferencePoint(display.CenterLeftReferencePoint)
		navBack.x = leftX + 0
		navBack.y = topY + 30
		navBack.xScale = 0.70
		navBack.yScale = 0.70
		navBack:addEventListener('tap', bye)
	end
	scene.view:insert(nav)

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
	answers = t.shuffle(answers)

	questionGrp = display.newGroup()
	local titleLbl = display.newImage(questionGrp, "vendor/gate-webview/images/parentgateText_"..lang..".png")
	titleLbl.x = centerX
	titleLbl.y = centerY - 200
	titleLbl.xScale = 0.8
	titleLbl.yScale = 0.8

	local pickLbl = display.newImage(questionGrp, "vendor/gate-webview/images/operation".. questionNum ..".png")
	pickLbl.x = centerX
	pickLbl.y = centerY - 100
	pickLbl.xScale = 0.8
	pickLbl.yScale = 0.8

	local leftBtn = display.newImage(questionGrp, "vendor/gate-webview/images/"..question[3][answers[1]]..".png")
	leftBtn.x = centerX - 200
	leftBtn.y = centerY + 80
	leftBtn.ok = answers[1] == 1
	leftBtn.xScale = 0.8
	leftBtn.yScale = 0.8
	leftBtn:addEventListener("tap", answerTap)


	local centerBtn = display.newImage(questionGrp, "vendor/gate-webview/images/"..question[3][answers[2]]..".png")
	centerBtn.x = centerX
	centerBtn.y = centerY + 80
	centerBtn.ok = answers[2] == 1
	centerBtn.xScale = 0.8
	centerBtn.yScale = 0.8
	centerBtn:addEventListener("tap", answerTap)

	local rightBtn = display.newImage(questionGrp, "vendor/gate-webview/images/"..question[3][answers[3]]..".png")
	rightBtn.x = centerX + 200
	rightBtn.y = centerY + 80
	rightBtn.ok = answers[3] == 1
	rightBtn.xScale = 0.8
	rightBtn.yScale = 0.8
	rightBtn:addEventListener("tap", answerTap)

	local backBtn = display.newImage(questionGrp, "vendor/gate-webview/images/back.png")
	backBtn:setReferencePoint(display.TopLeftReferencePoint)
	backBtn.x = leftX - 20
	backBtn.y = topY - 20
	backBtn.xScale = 0.9
	backBtn.yScale = 0.9
	backBtn:addEventListener("tap", bye)

	self.view:insert(questionGrp)

end

function scene:enterScene()
end

scene:addEventListener('createScene', scene)
scene:addEventListener('enterScene', scene)
scene:addEventListener('exitScene', scene)
return scene

