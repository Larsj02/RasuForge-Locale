---@class RasuForge-Locale : RFCore-DependencyLib
local RFLocale = {}

---@alias LocaleString string
---|"enUS"
---|"koKR"
---|"frFR"
---|"deDE"
---|"zhCN"
---|"esES"
---|"zhTW"
---|"esMX"
---|"ruRU"
---|"ptBR"
---|"itIT"

---@type RasuForge-Locale
RFLocale = GetLib:RegisterLibrary("RasuForge-Locale", "1.0.0", RFLocale)
if not RFLocale then return end

---@class RFLocale-Instance : RFCore-DependencyLibInstance
---@field _locales table<LocaleString, table<string, string>>
---@field _addon ?RFCore-Addon
---@field _fallback ?string
---@field _activeLocale ?string
local RFLocaleInstance = {
    _locales = {},
    _addon = nil,
    _fallback = nil,
    _activeLocale = nil,
}

--- Creates a new instance of the RasuForge-Locale library.
---@param addon RFCore-Addon
---@param config table
---@return RFLocale-Instance
function RFLocale:New(addon, config)
    local instance = CreateFromMixins(RFLocaleInstance)
    instance._addon = addon

    instance._locales = config.locales or {}
    instance._fallback = config.fallback or nil
    instance._activeLocale = config.activeLocale or nil

    return instance
end

--- Returns the RasuForge-Addon instance associated with this locale instance.
---@return RFCore-Addon
function RFLocaleInstance:GetAddon()
    return self._addon
end

--- Returns the locales for the specified language.
---@param language ?LocaleString
---@return table<string, string>
function RFLocaleInstance:GetLocale(language)
    local locales = {}
    setmetatable(locales, {
        __index = function (_, key)
            language = self:GetValidLanguage(language)

            return self:GetString(key, language)
        end
    })
    return locales
end

--- Returns the next valid language for the specified language.
---@param language ?LocaleString
---@return LocaleString
function RFLocaleInstance:GetValidLanguage(language)
    language = language or (self:GetActive() or GetLocale())
    language = self:HasLocale(language) and language
        or self:HasLocale(self:GetFallback()) and self:GetFallback()
        or "enUS"
    return language
end

--- Returns the string for the specified key and language.
---@param key string
---@param language ?LocaleString
---@return string
function RFLocaleInstance:GetString(key, language)
    self:GetAddon():Assert(type(key) =="string", "Key must be a string")
    local locales = self._locales[self:GetValidLanguage(language)]
    if locales[key] then
        return locales[key]
    end
    return key
end

--- Returns the active locale.
---@return LocaleString
function RFLocaleInstance:GetActive()
    return self._activeLocale or GetLocale()
end

--- Sets the active locale.
---@param language ?LocaleString
function RFLocaleInstance:SetActive(language)
    if language and self._locales[language] then
        self._activeLocale = language
        return
    end
    self._activeLocale = nil
end

--- Returns the fallback locale.
---@return LocaleString?
function RFLocaleInstance:GetFallback()
    return self._fallback
end

--- Sets the fallback locale.
---@param language ?LocaleString
function RFLocaleInstance:SetFallback(language)
    if language and self._locales[language] then
        self._fallback = language
        return
    end
    self._fallback = nil
end

--- Returns the fallback locale for the specified language.
---@param language ?LocaleString
---@return boolean
function RFLocaleInstance:HasLocale(language)
    return self._locales[language]
end

--- Adds a new locale for the specified language.
---@param language LocaleString
---@param locale table<string, string>
function RFLocaleInstance:AddLocale(language, locale)
    self:GetAddon():Assert(type(language) == "string", "Language must be a string")
    self:GetAddon():Assert(type(locale) == "table", "Locale must be a table")
    if not self:HasLocale(language) then
        self._locales[language] = {}
    end
    for key, value in pairs(locale) do
        self._locales[language][key] = value
    end
end

--- Removes the locale for the specified language.
---@param language LocaleString
function RFLocaleInstance:RemoveLocale(language)
    if self:HasLocale(language) then
        self._locales[language] = nil
    end
    if self:GetActive() == language then
        self:SetActive()
    end
    if self:GetFallback() == language then
        self:SetFallback()
    end
end

--- Overrides the locales for all languages.
---@param locales table<LocaleString, table<string, string>>
---@param newFallback ?LocaleString
---@param newActive ?LocaleString
function RFLocaleInstance:SetLocales(locales, newFallback, newActive)
    self._locales = locales or {}

    if not self:HasLocale(self:GetActive()) then
        self:SetActive(newActive)
    end
    if not self:HasLocale(self:GetFallback()) then
        self:SetFallback(newFallback)
    end
end