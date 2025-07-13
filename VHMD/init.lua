while true do
local modules = peripheral.find("neuralInterface")
if not modules then
    error("Must have a neural interface", 0)
end

if not modules.hasModule("plethora:sensor") then error("Must have a sensor", 0) end
if not modules.hasModule("plethora:introspection") then error("Must have an introspection module", 0) end
if not modules.hasModule("plethora:kinetic", 0) then error("Must have a kinetic agument", 0) end
if not modules.hasModule("plethora:keyboard") then error("Must have a keyboard", 0) end
if not modules.hasModule("plethora:glasses") then error("Must have overlay glasses", 0) end

_G.VHMD = {}
VHMD.modules = modules
local meta = modules.getMetaOwner()
local canvas = modules.canvas()
local menuOpen = false
local screenWidth,screenHight=canvas.getSize()
local airborneCount = 0
local menuPointer=1
local quit=false
local menu = {}
local tickFuncs = {}
local drawFuncs = {}
local rootFuncs = {}

function VHMD.addRootFunction(func)
    rootFuncs[#rootFuncs+1]=func
end

VHMD.canvasObject = canvas

local function noFall()
    while true do
        if meta.isAirborne then
            airborneCount=airborneCount+1
        else
            airborneCount=0
        end
        if airborneCount > 10 then
            modules.launch(0,-90,.001)
        end
        sleep()
    end
end

local heldCtrl,heldAlt,heldShift=false,false,false

local function events()
    while true do
        local event,key = os.pullEvent()
        if event == "key" then
            if key == keys.leftCtrl or key == keys.rightCtrl then 
                heldCtrl = true
            elseif key == keys.leftAlt or key == keys.rightAlt then 
                heldAlt = true
            elseif key == keys.leftShift or key == keys.rightShift then 
                heldShift = true 
            elseif key == keys.m then
                if menuOpen then
                    menuOpen=false
                else
                    menuOpen=true
                end
            elseif heldAlt and key==keys.space then
                modules.launch(0,-90,4)
            elseif key == keys.up then
                if menuOpen then
                    if menuPointer ~= 1 then
                        menuPointer=menuPointer-1
                    end
                end
            elseif key == keys.down then
                if menuOpen then
                    if menuPointer ~= #menu then
                        menuPointer=menuPointer+1
                    end
                end
            elseif key == keys.enter then
                if menuOpen then
                    pcall(menu[menuPointer].func)
                end
            elseif heldAlt and key == keys.r then
                print("Reload triggered")
                break
            elseif heldAlt and key == keys.q then
                quit=true
                print("Exiting")
                break
            end
        elseif event == "key_up" then
            if key == keys.leftCtrl or key == keys.rightCtrl then 
                heldCtrl = false
            elseif key == keys.leftAlt or key == keys.rightAlt then 
                heldAlt = false
            elseif key == keys.leftShift or key == keys.rightShift then 
                heldShift = false 
            end
        end
    end
end

local function tick()
    while true do
        for _,v in ipairs(tickFuncs) do
            pcall(v)
        end
        sleep()
    end
end

local function drawEntry(show,x,y,text,selected)
    if show then
        canvas.addRectangle(x,y,116,9,0x4d4d4d80)
        if selected then
            canvas.addText({x,y},text,0x000000ff)
        else
            canvas.addText({x,y},text,0x000000ff)
        end
    end
end
local function drawMenu()
    local x,y=screenWidth/2-200,screenHight/2
    canvas.addRectangle(x-50,y-90,120,180,0x2d2d2d80)
    canvas.addRectangle(x-51,y+89,122,9,0x4d4d4d80)
    canvas.addText({x-50,y+90},"VHMD-I",0x000000ff)
    canvas.addText({x+70-10,y+90},"V1",0x000000ff)
    canvas.addRectangle(x-48,y-88,116,110,0x4d4d4d80)
    canvas.addRectangle(x-49,y-69,118,11,0x8d8d8df0)
    pcall(function()drawEntry(menuPointer>2,x-48,y-88,menu[menuPointer-2].text)end)
    pcall(function()drawEntry(menuPointer>1,x-48,y-78,menu[menuPointer-1].text)end)
    pcall(function()drawEntry(true,x-48,y-68,menu[menuPointer].text,true)end)
    pcall(function()drawEntry(menuPointer<#menu,x-48,y-58,menu[menuPointer+1].text)end)
    pcall(function()drawEntry(menuPointer<#menu-1,x-48,y-48,menu[menuPointer+2].text)end)
    pcall(function()drawEntry(menuPointer<#menu-2,x-48,y-38,menu[menuPointer+3].text)end)
    pcall(function()drawEntry(menuPointer<#menu-3,x-48,y-28,menu[menuPointer+4].text)end)
    pcall(function()drawEntry(menuPointer<#menu-4,x-48,y-18,menu[menuPointer+5].text)end)
    pcall(function()drawEntry(menuPointer<#menu-5,x-48,y-8,menu[menuPointer+6].text)end)
    pcall(function()drawEntry(menuPointer<#menu-6,x-48,y+2,menu[menuPointer+7].text)end)
    pcall(function()drawEntry(menuPointer<#menu-7,x-48,y+12,menu[menuPointer+8].text)end)
end

local function draw()
    while true do
        canvas.clear()
        for _,v in ipairs(drawFuncs) do
            pcall(v)
        end
        if menuOpen then
            drawMenu()
        end
        sleep()
    end
end

local function updateMeta()
    while true do
        meta=modules.getMetaOwner()
        sleep()
        VHMD.isMenuOpen = menuOpen
        VHMD.getMeta = meta
    end
end

function VHMD.addMenuElement(text,func)
    menu[#menu+1] = {text=text,func=func}
end

function VHMD.addTickFunction(func)
    tickFuncs[#tickFuncs+1] = func
end

function VHMD.addDrawCommand(func)
    drawFuncs[#drawFuncs+1] = func
end

for _,v in ipairs(fs.list("VHMD/modules/")) do
    if not fs.isDir("VHMD/modules/"..v) then
        dofile("VHMD/modules/"..v)
    end
end

parallel.waitForAny(noFall,events,updateMeta,draw,tick,table.unpack(rootFuncs))
sleep()
if quit then
    break
end
end