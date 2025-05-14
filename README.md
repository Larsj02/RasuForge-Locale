# RasuForge-Locale - Localization Library for RasuForge

RasuForge-Locale is a library for managing localization in World of Warcraft addons, specifically designed for the RasuForge framework. It allows addons to define and use localized strings based on the client's language settings or a specified active locale. The library also supports dynamic language changes at runtime, ensuring that the most valid string is always returned.

## Features

- **Simple Configuration**: Define all your locales, a fallback language, and the active locale in a straightforward configuration table when setting up your addon with RasuForge-Core.
- **Dynamic Language Switching**: Automatically retrieves the most valid string for the current active locale, supporting runtime language changes.
- **Direct Access**: Retrieve a Lua table containing all strings for the active (or fallback) language, with indexing that dynamically calls `GetString`.
- **Framework Integration**: Designed to integrate seamlessly with RasuForge-Core's dependency management and configuration system.
- **Runtime Locale Management**: Add, remove, or override locales dynamically during runtime.

## Usage

### Including RasuForge-Locale in your addon

Add RasuForge-Locale to your addon's directory structure (typically in a `Libs` folder) and include it in your TOC and XML files:

```xml
<!-- In your embeds.xml or equivalent -->
<Include file="Libs\RasuForge-Locale\lib.xml"/>
```

### Configuring Localizations (with RasuForge-Core)

When using `RasuForge-Core`, you configure `RasuForge-Locale` as part of your addon's dependency definition. The locale library instance provided to your addon will be pre-configured with these settings.

```lua
---@type RasuForge-Core
local rf = GetLib:GetLibrary("RasuForge-Core")

local addon = rf:CreateAddon({
    name = "MyAddon",
    version = "1.0.0",
    dependencies = {
        {
            library = "RasuForge-Locale",
            version = "1.0.0",
            config = {
                locales = {
                    ["enUS"] = {
                        GREETING = "Hello, World!",
                        FAREWELL = "Goodbye!",
                    },
                    ["deDE"] = {
                        GREETING = "Hallo, Welt!",
                        FAREWELL = "Auf Wiedersehen!",
                    },
                },
                fallback = "enUS",
                activeLocale = "deDE",
            },
        }
    },
})
```
The `activeLocale` determines which language's strings are primarily used. If a string is not found in the `activeLocale`, `RasuForge-Locale` will attempt to find it in the `fallback` language.

### Accessing Localized Strings

Once your addon is enabled and dependencies are loaded (e.g., within your addon's `OnEnable` method if using `RasuForge-Core`):

```lua
function addon:OnEnable()
    ---@type RFLocale-Instance
    local rfl = self:GetDependency("RasuForge-Locale")
    local L = rfl:GetLocale()

    print(L["GREETING"]) -- Prints "Hallo, Welt!" if activeLocale is deDE
    print(L["FAREWELL"]) -- Prints "Auf Wiedersehen!" if activeLocale is deDE
end
```
The `rfl:GetLocale()` method returns a Lua table where keys are your string identifiers (e.g., "GREETING") and values are the localized strings. Indexing this table dynamically calls `GetString` in the background, ensuring that the most valid string is always returned, even if the active locale changes at runtime.

## Advanced Features

RasuForge-Locale provides additional runtime functionality for managing and accessing localized strings dynamically.

### Getting a Specific String

The `:GetString` method retrieves a localized string for a given key. If the key is not found it returns the key itself.

```lua
---@type RFLocale-Instance
local rfl = self:GetDependency("RasuForge-Locale")

-- Retrieve a localized string
local greeting = rfl:GetString("GREETING")
print(greeting) -- Prints "Hallo, Welt!" if activeLocale is deDE

-- Retrieve a localized string for a specific locale
local englishGreeting = rfl:GetString("GREETING", "enUS")
print(englishGreeting) -- Prints "Hello, World!"
```

### Adding a New Locale

You can dynamically add a new locale at runtime using the `:AddLocale` method.

```lua
---@type RFLocale-Instance
local rfl = self:GetDependency("RasuForge-Locale")

-- Add a new locale
rfl:AddLocale("frFR", {
    GREETING = "Bonjour, le monde!",
    FAREWELL = "Au revoir!",
})

-- Access the new locale
rfl:SetActive("frFR")
print(rfl:GetString("GREETING")) -- Prints "Bonjour, le monde!"
```

### Removing a Locale

The `:RemoveLocale` method allows you to remove a locale dynamically.

```lua
---@type RFLocale-Instance
local rfl = self:GetDependency("RasuForge-Locale")

-- Remove a locale
rfl:RemoveLocale("deDE")

-- Attempting to access the removed locale will fall back to the fallback locale
rfl:SetActive("deDE")
print(rfl:GetString("GREETING")) -- Prints "Hello, World!" (fallback to enUS)
```

### Overriding All Locales

The `:SetLocales` method replaces all existing locales with a new set of locales. You can also specify a new fallback and active locale.

```lua
---@type RFLocale-Instance
local rfl = self:GetDependency("RasuForge-Locale")

-- Override all locales
rfl:SetLocales({
    ["esES"] = {
        GREETING = "¡Hola, Mundo!",
        FAREWELL = "¡Adiós!",
    },
}, "esES", "esES")

print(rfl:GetString("GREETING")) -- Prints "¡Hola, Mundo!"
```

These methods provide flexibility for addons that need to manage localization dynamically at runtime.

## License

This library is released under the [MIT License](https://opensource.org/licenses/MIT).

## Credits

RasuForge-Locale is developed as part of the RasuForge addon framework.
