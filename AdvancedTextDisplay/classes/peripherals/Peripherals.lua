-- Reactor / Turbine Control
-- (c) 2017 Thor_s_Crafter
-- Version 3.0
-- https://gitlab.com/seekerscomputercraft/extremereactorcontrol/-/blob/main/classes/Peripherals.lua?ref_type=heads


--Peripherals
_G.monitors = {} --Monitor
_G.controlMonitor = "" --Monitor

--Total count of all attachments
_G.amountMonitors = 0
_G.smallMonitor = 1

-- function that grabs all peripherals and initializes the correct one as client
local function searchPeripherals()
    local peripheralList = peripheral.getNames()
    for i = 1, #peripheralList do
        local periItem = peripheralList[i]
        local periType = peripheral.getType(periItem)
        local peri = peripheral.wrap(periItem)
        
        
        if periType == "monitor" then
            print("Monitor - "..periItem)
            if(peripheralList[i] == controlMonitor) then
                --add to output monitors
                _G.monitors[amountMonitors] = peri
                _G.amountMonitors = amountMonitors + 1
            else
                _G.controlMonitor = peri
            end
        end
    end
end

-- function that grabs all peripherals and checks if the required ones are attached
function _G.checkPeripherals()
    --Check for errors
    term.clear()
    term.setCursorPos(1,1)

    if controlMonitor == "" then
        error("Monitor not found!\nPlease check and reboot the computer (Press and hold Ctrl+R)")
    end

    --Monitor clear
    controlMonitor.setBackgroundColor(colors.black)
    controlMonitor.setTextColor(colors.red)
    controlMonitor.clear()
    controlMonitor.setCursorPos(1,1)
    controlMonitor.setTextScale(0.5)

    --Monitor too small
    local monX,monY = controlMonitor.getSize() 
end

-- function that will grab all attached peripherals, set up the correct one and connect the modem to the server
function _G.initPeripherals()
    searchPeripherals()
    _G.checkPeripherals()
end

