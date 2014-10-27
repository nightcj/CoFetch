
require "luaScript/Common/Extern"
luaLoad("Model/Component/BackgroundBox")

PopupTouchPriorityBase = -1024 --为了处理多层弹出排级问题
PopupNum = 1

ZORDER = 1024

PopupLayer = class("PopupLayer",function() 
    return CCLayer:create()
end)

PopupLayer.__index = PopupLayer

PopupLayer.title = nil
PopupLayer.width = nil
PopupLayer.height = nil

PopupLayer.maskPriority = 0

PopupLayer.bgSprite = nil
PopupLayer.frame = nil

PopupLayer.titleSize = 0
PopupLayer.contentSize = 0
PopupLayer.buttomSize = 0

PopupLayer.title = nil
PopupLayer.contentLayer = nil
PopupLayer.content = nil
PopupLayer.buttom = nil

PopupLayer.menu = nil

PopupLayer.closeButtonShow = true
PopupLayer.closeButtonPos_x = nil
PopupLayer.closeButtonPos_x = nil

PopupLayer.actionArray = nil

local s = CCDirector:sharedDirector():getWinSize()
--创建一个继承CCLayer的界面的SystemAwardPopup
----------------------------------------
---------------接口函数-------------------
----------------------------------------
function PopupLayer:create(title, content, width, height)
	local t = PopupLayer.new(title,width,height,content)
	t:makeDialog()
	return t
end

function PopupLayer:createWithText(title, text, width, height)
	local text_m = CCLabelTTF:create(text,"",24)
	local size = text_m:getContentSize()
	local t = nil

	t = PopupLayer.new(title,width,height,text_m)
	t:makeDialog()
	return t
end

function PopupLayer:setBackground(sprite)
	self.backSprite = sprite
end

--添加动画
function PopupLayer:addAction(action)
	-- print("myhaha func",self.actionArray)
	self.actionArray:addObject(action)
end

--注册回调,当弹出窗口本身动画完成时,会调用回调函数
function PopupLayer:registerCallFunc(callFunc)
	-- print("myhaha func",self.actionArray)
	self.callFunc = callFunc
end

--关闭Popup
function PopupLayer:close()
	--self:setTouchEnable
	self:removeFromParentAndCleanup(true)
    PopupNum = PopupNum - 1
end
function PopupLayer:show()

	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(self,ZORDER)
end
--设置背景
function PopupLayer:setBackground(sprite)
	self.backSprite = sprite
end

--添加按钮函数
function PopupLayer:addButton(button,x,y)
	if self.menu ~= nil then
		button:setPosition(x,y)
		self.menu:addChild(button)
	end
end

-- 工具函数
-- width 			按钮宽度
-- height 			按钮高度
-- func 			回调函数
-- fromSpriteCache	是否来自缓存
-- normal 			正常状态图片
-- press 			浮上状态图片
-- disable 			不可用状态图片

--当所有状态图为均空时,为透明按钮
function PopupLayer:buttonTools(width,height,func,normal,press,disable)
	local normal_m = nil
	local press_m = nil
	local disable_m = nil
	if normal then
		normal_m = CCScale9Sprite:createWithSpriteFrameName(normal)
	end
	if press then
		press_m = CCScale9Sprite:createWithSpriteFrameName(press)
	end
	if disable then
		disable_m = CCScale9Sprite:createWithSpriteFrameName(disable)
	end

	if normal_m then
		normal_m:setAnchorPoint(ccp(0.5,0.5))
		normal_m:setPreferredSize(CCSizeMake(width, height))
	end

	if press_m then
		press_m:setAnchorPoint(ccp(0.5,0.5));
		press_m:setPreferredSize(CCSizeMake(width, height))
	end

	if disable_m then
		disable_m:setAnchorPoint(ccp(0.5,0.5));
		disable_m:setPreferredSize(CCSizeMake(width, height))
	end

	local btn = nil
	if normal_m or press_m or disable_m then
		btn = CCMenuItemSprite:create(normal_m,press_m,disable_m)
	else
		normal_m = CCSprite:create()
		normal_m:setContentSize(CCSizeMake(width,height))
		btn = CCMenuItemSprite:create(normal_m,press_m,disable_m)
	end
	btn:registerScriptTapHandler(func)
	return btn

end
----------------------------------------
---------------接口函数结束---------------
----------------------------------------


function PopupLayer:ctor(title, width, height, content, closeButton)
	plistLoad("image/mission.plist")
	--self:setContentSize(CCSizeMake(width,height))
	self.title = title
	self.width = width
	self.height = height
	self.content = content
	self.menu = CCMenuX:create()

	self.actionArray = CCArray:create()
	self.buttomButtonArray = {}

	-- logLine( "myhaha"..closeButton )
	if closeButton == nil then
		self.closeButtonShow = true
	else
		self.closeButtonShow = closeButton
	end
	
	self:initMask() --初始化遮罩层
	
end


--内部初始化工具方法
function PopupLayer:initMask()
	local maskLayer = CCLayerColor:create(ccc4(155,155,155,100),s.width, s.height)--背景sprite
	self:addChild(maskLayer)

	local buttonMask = CCMenuItemSprite:create(nil,nil,nil)
	buttonMask:setPosition(ccp(0,0))
	buttonMask:setAnchorPoint(ccp(0,0))

	buttonMask:setContentSize(CCSizeMake(s.width,s.height))
	local mask = CCMenuX:create()
	self.mask = mask
	mask:setPosition(ccp(0,0))
	mask:addChild(buttonMask)

	self.maskPriority = PopupTouchPriorityBase - (PopupNum - 1)
	mask:setTouchPriority(self.maskPriority)
	PopupNum = PopupNum + 1

	maskLayer:addChild(mask)
end

function PopupLayer:createBackFrame()
	local backFrame = CCLayerColor:create(ccc4(0,0,0,0),self.width, self.height)

	local bg = nil
	if self.backSprite ~= nil then
		bg = BackgroundBox:createWithSpriteFrameName(self.width, self.height, self.backSprite)
		bg:setPosition(self.width / 2, self.height / 2)
		backFrame:addChild(bg)
	end
	
	return backFrame
end

function PopupLayer:makeDialog()
	--size set
	self.titleSize ,self.buttomSize = self:makeSize()
	self.contentSize = self.height - self.titleSize - self.buttomSize
	--end

	self.frame = self:createBackFrame()
	--self.frame:setContentSize(CCSizeMake(width,height))
	self.frame:ignoreAnchorPointForPosition(false)
	self.frame:setAnchorPoint(ccp(0.5,0.5))
	self.frame:setPosition(ccp(s.width/2,s.height/2))
	self:addChild(self.frame)

	--menu 
	self.menu:setTouchPriority(self.maskPriority)
	self.menu:setPosition(ccp(0,0))
	self.frame:addChild(self.menu,99)
	--

	self.title = self:createTitle()
	self.title:ignoreAnchorPointForPosition(false)
	self.title:setAnchorPoint(ccp(0.5,0.5))
	self.title:setPosition(ccp(self.width/2,self.height - self.titleSize / 2))
	self.frame:addChild(self.title)

	self.contentLayer = self:createContent()
	self.contentLayer:ignoreAnchorPointForPosition(false)
	self.contentLayer:setAnchorPoint(ccp(0.5,0.5))
	self.contentLayer:setPosition(ccp(self.width / 2,self.height - self.titleSize - self.contentSize / 2))
	self.frame:addChild(self.contentLayer)

	if self.content ~= nil then
		local t = tolua.cast(self.content, "CCSprite")  
		print(t,self.content)
		t:ignoreAnchorPointForPosition(false)
		t:setAnchorPoint(ccp(0.5,0.5))
		t:setPosition(ccp(self.width / 2,self.contentSize / 2))
		self.contentLayer:addChild(t)
	end

	self.buttom = self:createButtom()
	self.buttom:ignoreAnchorPointForPosition(false)
	self.buttom:setAnchorPoint(ccp(0.5,0.5))
	self.buttom:setPosition(ccp(self.width/2,self.buttomSize / 2))
	self.frame:addChild(self.buttom)


	self:createButtomButton(self.buttomButtonArray)
	-- if self.buttomButtonArray then
	-- 	--add button to buttom
	-- end
	local pos = 0
	if #self.buttomButtonArray ~= 0 then
		pos = self.width/#self.buttomButtonArray
		for i = 1,#self.buttomButtonArray do
			local obj = self.buttomButtonArray[i]
			local t = pos * (2 * i - 1) / 2
			self:addButton(obj, t, self.buttomSize / 2)
		end
	end

	if self.closeButtonShow then

		local closeButt = self:createCloseButton()
		if self.closeButtonPos_x ~= nil and PopupLayer.closeButtonPos_y ~= nil then
			self:addButton(closeButt, closeButtonPos_x, closeButtonPos_x)
		else
			closeButt:setAnchorPoint(ccp(1,1))
			self:addButton(closeButt, self.width, self.height)
		end
	end

	--动画
	self:makeAnimation(self.frame , self.actionArray)

	if self.callFunc ~= nil then
		self.actionArray:addObject(CCCallFunc:create(self.callFunc))
	end

	local runSequence = CCSequence:create(self.actionArray)
	if runSequence ~= nil then
		self.frame:runAction(runSequence)
	end
	--
end

----------------------------------------
---------------可定制函数-----------------
----------------------------------------
function PopupLayer:makeSize()
	return 20,30
end

--重写此方法可以改变原有动画
function PopupLayer:makeAnimation(frame,ary)
	frame:setScale(0.01)
	ary:addObject(CCScaleTo:create(0.2,1.2))
	ary:addObject(CCScaleTo:create(0.1,1))
end

--子类重写此方法可以定制头部背景
function PopupLayer:createTitle()
	local title_m = CCLayerColor:create(ccc4(255,0,0,0),self.width, self.titleSize)
	return title_m

end

--子类重写此方法可以设置内容域的背景
function PopupLayer:createContent()
	local contentLayer_m = CCLayerColor:create(ccc4(0,0,255,0),self.width,self.contentSize)
	return contentLayer_m
end

--子类重写此方法可以设置底部域的背景
function PopupLayer:createButtom()
	local buttom_m = CCLayerColor:create(ccc4(0,255,0,0),self.width, self.buttomSize)
	return buttom_m
end

--设置底部按钮,当子类重写这个方法时,会根据子类重写的方法去安放底部的按钮
--它和使用addButton的区别是,它可以一次加多个按钮,并且系统会自动按照按钮生成顺序
--在底部对齐排放按钮
--
--内置尺寸
--self.buttomSize --底部高
--self.width -- 宽

--参数 ary -> 为一个数组,按照暗访顺序将按钮添加到数组
--使用示例
--ary[1] = self:buttonTools(405,60,btnCallBack,"wcl_mission_bigbutton.png")
--ary[2] = self:buttonTools(405,60,btnCallBack,"wcl_mission_bigbutton.png")
function PopupLayer:createButtomButton(ary)
	return nil
end

--子类重写此方法可以替换要显示的关闭按钮
function PopupLayer:createCloseButton()
	return self:buttonTools(60,60,function() self:close() end,"wcl_mission_exit.png")
end

----------------------------------------
--------------可定制函数结束---------------
----------------------------------------



