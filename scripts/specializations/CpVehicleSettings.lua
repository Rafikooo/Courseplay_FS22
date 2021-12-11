--[[
    Vehicle specific settings
]]--

---@class CpVehicleSettings
CpVehicleSettings = {}

CpVehicleSettings.MOD_NAME = g_currentModName
CpVehicleSettings.KEY = "."..CpVehicleSettings.MOD_NAME..".cpVehicleSettings"
function CpVehicleSettings.initSpecialization()
	local schema = Vehicle.xmlSchemaSavegame
    schema:register(XMLValueType.INT,"vehicles.vehicle(?)"..CpVehicleSettings.KEY.."(?)#value","Setting value")
    schema:register(XMLValueType.STRING,"vehicles.vehicle(?)"..CpVehicleSettings.KEY.."(?)#name","Setting name")
end


function CpVehicleSettings.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(AIFieldWorker, specializations) 
end

function CpVehicleSettings.registerEventListeners(vehicleType)	
--	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", CpVehicleSettings)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", CpVehicleSettings)
end
function CpVehicleSettings.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, 'getCpSetting', CpVehicleSettings.getSetting)
    SpecializationUtil.registerFunction(vehicleType, 'getCpSettingValue', CpVehicleSettings.getSettingValue)
    SpecializationUtil.registerFunction(vehicleType, 'setCpSettingValue', CpVehicleSettings.setSettingValue)
    SpecializationUtil.registerFunction(vehicleType, 'setCpSettingFloatValue', CpVehicleSettings.setSettingFloatValue)
    SpecializationUtil.registerFunction(vehicleType, 'getCpSettings', CpVehicleSettings.getSettings)
end

--- Gets a single setting by it's name.
---@param name string
---@return AIParameterSettingList
function CpVehicleSettings:getSetting(name)
    local spec = self.spec_cpVehicleSettings
    return spec.settingsByName[name]
end

--- Gets a single setting value by it's name.
---@param name string
---@return any
function CpVehicleSettings:getSettingValue(name)
    local spec = self.spec_cpVehicleSettings
    return spec.settingsByName[name]:getValue()
end

--- Sets a single setting value by it's name.
---@param name string
---@param value any
function CpVehicleSettings:setSettingValue(name,value)
    local spec = self.spec_cpVehicleSettings
    return spec.settingsByName[name]:setValue(value)
end

--- Sets a single setting float value by it's name.
---@param name string
---@param value any
function CpVehicleSettings:setSettingFloatValue(name,value)
    local spec = self.spec_cpVehicleSettings
    return spec.settingsByName[name]:setFloatValue(value)
end

--- Gets all settings.
---@return table
function CpVehicleSettings:getSettings()
    local spec = self.spec_cpVehicleSettings
    return spec.settings
end

function CpVehicleSettings:onLoad(savegame)
	--- Register the spec: spec_CpVehicleSettings
    local specName = CpVehicleSettings.MOD_NAME .. ".cpVehicleSettings"
    self.spec_cpVehicleSettings = self["spec_" .. specName]
    local spec = self.spec_cpVehicleSettings

    --- Clones the generic settings to create different settings containers for each vehicle. 
    spec.settings,spec.settingsByName = CpSettingsUtil.cloneSettingsTable(CpVehicleSettings.settings,self)

    CpVehicleSettings.loadSettings(self,savegame)
end


--- Loads the generic settings setup from an xmlFile.
function CpVehicleSettings.loadSettingsSetup()
    local filePath = Utils.getFilename("config/VehicleSettingsSetup.xml", g_Courseplay.BASE_DIRECTORY)
    CpSettingsUtil.loadSettingsFromSetup(CpVehicleSettings,filePath)
end
CpVehicleSettings.loadSettingsSetup()

function CpVehicleSettings.getSettingSetup()
    return CpVehicleSettings.settingsBySubTitle,CpVehicleSettings.pageTitle
end

function CpVehicleSettings:loadSettings(savegame)
    if savegame == nil or savegame.resetVehicles then return end
    local spec = self.spec_cpVehicleSettings
	savegame.xmlFile:iterate(savegame.key..CpVehicleSettings.KEY, function (ix, key)
        local name = savegame.xmlFile:getValue(key.."#name")
        local setting = spec.settingsByName[name]
        if setting then
            setting:loadFromXMLFile(savegame.xmlFile, key)
            CpUtil.debugVehicle(CpUtil.DBG_HUD,self,"Loaded setting: %s, value:%s, key: %s",setting:getName(),setting:getValue(),key)
        end
	end)
end

function CpVehicleSettings:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_cpVehicleSettings
    for i,setting in ipairs(spec.settings) do 
        local key = string.format("%s(%d)",key,i-1)
        setting:saveToXMLFile(xmlFile, key, usedModNames)
        xmlFile:setValue(key.."#name",setting:getName())
        CpUtil.debugVehicle(CpUtil.DBG_HUD,self,"Saved setting: %s, value:%s, key: %s",setting:getName(),setting:getValue(),key)
    end
end