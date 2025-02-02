local basalt = require("basalt")

-- List of strings to display
local textLines = {
    {text = "First Line", bgColor = colors.red, textColor = colors.white, textScale = 1, textAlign = "center"},
    {text = "Second Line", bgColor = colors.black, textColor = colors.yellow, textScale = 1, textAlign = "left"},
    {text = "Third Line", bgColor = colors.red, textColor = colors.white, textScale = 1, textAlign = "right"},
    {text = "Fourth Line", bgColor = colors.black, textColor = colors.yellow, textScale = 1, textAlign = "center"},
}

-- debugging
local debugPrint = true
local debugUI = true
local hideVersionFooter = true

-- table contrains energyMeters[i].id as key and the value is the displayData{clientInfo = energyMeters[i], display = already created frame}
local displayCells = {}
setmetatable(displayCells, {__index = "displayData"})


-- GUI COMPONENT SETTINGS

local numLines = #textLines
-- Background colors for alternating rows
local colorsList = {colors.green, colors.blue}

-- Store row frames in an array
local lineFrames = {}

-- footer settings (including prev/next buttons and page label)
local btnWidth,btnHeight = 6,1
local lblWidth,lblHeight = 20, btnHeight
local btnDefaultColor, btnClickedColor = colors.gray, colors.lime
local btnHighlighDuration = 0.2

-- version footer settings
local versionFooterHeight = 1
local versionFooterColor = colors.lightBlue


-- all settings for displayed cells
local cellWidth, cellHeight = 18, 6
local cellBackground = colors.yellow
local cellSpacing = 1

-- background Color
local bgColor = colors.lightGray

-- if not debug mode, set header and footer color to bgColor
if not debugUI then
    headerColor = bgColor
    filterHeaderColor = bgColor
    footerColor = bgColor
end

-- GUI COMPONENT SETTINGS END



-- GUI COMPONENTS

local displayedCells = {}

-- create main window
local main = basalt.addMonitor()
main:setMonitor(_G.controlMonitor)

-- default content pane
local flex = main:addFlexbox():setWrap("wrap"):setBackground(colors.yellow):setPosition(1, 1):setSize("parent.w", "parent.h"):setDirection("column"):setSpacing(0)

-- flexbox that contains the individual energy meter displays
if hideVersionFooter then
    versionFooterHeight = 0
end

--local main = flex:addFlexbox():setWrap("wrap"):setBackground(bgColor):setSize("parent.w", "parent.h" .. "-" .. versionFooterHeight):setSpacing(cellSpacing):setJustifyContent("center")--:setOffset(-1, 0)
local main = flex:addFrame():setBackground(bgColor):setSize("parent.w", "parent.h" .. "-" .. versionFooterHeight)--:setOffset(0, -1)

-- frame that contains the footer (previous, next, page number)
if not hideVersionFooter then
    local versionFooter = flex:addFrame():setBackground(versionFooterColor):setSize("parent.w", 1)
end

-- amount of cells per page
local flexWidth, flexHeight = main:getSize()
local numCellsRow = math.floor((flexWidth + cellSpacing) / (cellWidth + cellSpacing))
local numCellsCol = math.floor((flexHeight + cellSpacing) / (cellHeight + cellSpacing))

-- static elements with dynamic content
local energyLbl = {}
local energyBar = {}

local rateLblIn = {}
local rateLblOut = {}
local effectiveRateLbl = {}
local etaLbl = {}

-- GUI COMPONENTS END


---------------------------
-- function declarations --
---------------------------
local animateButtonClick
local animateButtonToggle
local setupMonitor

--------------------------
-- function definitions --
--------------------------



--------------
-- Setup UI --
--------------

-- set up all ui element references 
setupMonitor = function()
    -- setup header
    --energyLbl = header:addLabel():setText("Energy: STORED"):setFontSize(1):setSize("parent.w / 2", 1):setPosition(0, 1):setTextAlign("center")
    --energyBar = header:addProgressbar():setProgress(0):setSize("parent.w / 3", 1):setPosition("1/12 * parent.w", 3):setProgressBar(colors.lime):setDirection("right"):setBackground(colors.black)
    

    -- set up lines

    -- Calculate row height
    local lineHeight = math.floor(main:getHeight() / numLines)

    -- Add rows with alternating colors
    
    for i, line in ipairs(textLines) do
        --lineFrames[i] = main:addFlexbox():setWrap("nowrap"):setBackground(line.bgColor):setPosition(1, (i - 1) * lineHeight):setSize("parent.w", lineHeight):setJustifyContent("center")
        lineFrames[i] = main:addFrame():setBackground(line.bgColor):setPosition(1, (i - 1) * lineHeight + 1):setSize("parent.w", lineHeight)
    end

    for i, line in ipairs(textLines) do
        lineFrames[i]:addLabel()
            :setText(line.text)
            :setFontSize(line.textScale)
            :setSize("parent.w", "parent.h")
            --:setPosition("1", "1")
            :setTextAlign(line.textAlign)
            :setForeground(line.textColor)
    end

    -- setup footer
    if not hideVersionFooter then
	    versionFooter:addLabel():setText("version: " .. _G.version):setFontSize(1):setSize("parent.w/2", 1):setPosition("parent.w/2", versionFooterHeight):setTextAlign("right"):setForeground(colors.gray)
	end

    -- auto update the monitor
    basalt.autoUpdate()
end



----------------
-- ANIMATIONS --
----------------

-- animation for button click
animateButtonClick = function(btn)
    btn:setBackground(btnClickedColor)
    sleep(btnHighlighDuration)
    btn:setBackground(btnDefaultColor)
end

-- animation for button toggle
animateButtonToggle = function(btn, state)
    if state then
        btn:setBackground(btnClickedColor)
    else
        btn:setBackground(btnDefaultColor)
    end
end

-- animation for button group toggle
animateButtonToggleGroup = function(btnGroup, btn)
    for k,v in pairs(btnGroup) do
        if v ~= btn then
            animateButtonToggle(v, false)
        end
    end
    animateButtonToggle(btn, true)
end

-- animation with text update for filter button
toggleFilterShowSpecificTypeText = function(btn)
    local type = btn:getText()
    if type == "Filter All" then
        btn:setText("Filter Input")
        btn:setSize(14,1)
        toggleFilterShowSpecificType("Input")
    elseif type == "Filter Input" then
        btn:setText("Filter Output")
        btn:setSize(15,1)
        toggleFilterShowSpecificType("Output")
    elseif type == "Filter Output" then
        btn:setText("Filter All")
        btn:setSize(14,1)
        toggleFilterShowSpecificType("All")
    end
end

-- animation with text update for sorting attribute button
toggleSortAttrText = function(btn)
    if btn:getText() == "Sort by Name" then
        btn:setText("Sort by Rate")
        sortingAttr = "rate"
    else
        btn:setText("Sort by Name")
        sortingAttr = "name"
    end
end

-- animation with text update for sorting direction button
toggleSortDirText = function(btn)
    if btn:getText() == "Sort Ascending" then
        btn:setText("Sort Descending")
		btn:setSize(17,1)
        sortingDir = "desc"
    else
        btn:setText("Sort Ascending")
		btn:setSize(16,1)
        sortingDir = "asc"
    end
end



----------------------------------------
-- ACTUAL MONITOR PROGRAM STARTS HERE --
----------------------------------------
print("THIS IS THE MONITOR PROGRAM!")

-- Run the pinger and the listener and monitor updaters in parallel
parallel.waitForAll(setupMonitor)

--------------------------------------
-- ACTUAL MONITOR PROGRAM ENDS HERE --
--------------------------------------
