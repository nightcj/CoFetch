require "luaScript/Common/Extern"
local isLoaded = false

BackgroundBox = class( "BackgroundBox",function( )
		return CCSprite:create()
end)
BackgroundBox.__index = BackgroundBox


-- 创建一个黑框风格背景，大小由参数传入
function BackgroundBox:create( width, height, sprite)
	if isLoaded == false then
		plistLoad("image/frame/frame.plist")
		isLoaded = true
	end
	local bg = nil
	if sprite == nil then
		bg = CCScale9Sprite:create("image/Frame/frame_bg.png")
	else
		bg = CCScale9Sprite:create(sprite)
	end
	bg:setAnchorPoint(ccp(0.5,0.5));
	bg:setPreferredSize(CCSizeMake(width, height))
	return bg
end

function BackgroundBox:createWithSpriteFrameName( width, height, sprite)
	if isLoaded == false then
		plistLoad("image/frame/frame.plist")
		isLoaded = true
	end
	local bg = nil
	if sprite == nil then
		bg = CCScale9Sprite:createWithSpriteFrameName("frame_bg.png")
	else
		bg = CCScale9Sprite:createWithSpriteFrameName(sprite)
	end
	bg:setAnchorPoint(ccp(0.5,0.5));
	bg:setPreferredSize(CCSizeMake(width, height))
	return bg
end