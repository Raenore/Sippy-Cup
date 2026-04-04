-- Copyright The Sippy Cup Authors
-- Inspired by Eavesdropper
-- SPDX-License-Identifier: Apache-2.0

local DEFAULT_LOCALE_CODE = "enUS";

---@class SC.LocalizationClass
---@field New fun(defaultLocaleContent:table<string,string>):SC.Localization
---@field RegisterNewLocale fun(self:SC.LocalizationClass, code:string, name:string, content:table<string,string>)
---@field SetCurrentLocale fun(self:SC.LocalizationClass, code:string, fallback:boolean|nil)
---@field GetText fun(self:SC.LocalizationClass, key:string, ...:any):string
---@field GetDefaultLocale fun(self:SC.LocalizationClass):string
---@field GetPreferredLocale fun(self:SC.LocalizationClass):string
local Localization = {};
Localization.__index = Localization;

---Create a new localization instance
---@param defaultLocaleContent table<string,string>
---@return SC.Localization
function Localization:New(defaultLocaleContent)
	local localeInstance = setmetatable({}, self);

	-- Separate metatable for instance to avoid infinite recursion
	local mt = {
		__index = function(t, k)
			if Localization[k] then
				return Localization[k];  -- class method
			else
				return t:GetText(k);     -- instance key lookup
			end
		end,
		__call = function(t, k, ...)
			return t:GetText(k, ...);
		end
	};
	setmetatable(localeInstance, mt);

	localeInstance.locales = {};
	localeInstance.currentLocaleCode = DEFAULT_LOCALE_CODE;

	if defaultLocaleContent then
		localeInstance:RegisterNewLocale(DEFAULT_LOCALE_CODE, "Default", defaultLocaleContent);
	end

	return localeInstance;
end

---Register a new locale table
---@param code string
---@param name string
---@param content table<string,string>
function Localization:RegisterNewLocale(code, name, content) -- luacheck: no unused (name)
	if type(code) ~= "string" then return; end
	if type(content) ~= "table" then content = {}; end

	self.locales[code] = content;
end

---Set the active locale
---@param code string
---@param fallback boolean|nil
function Localization:SetCurrentLocale(code, fallback)
	if self.locales[code] then
		self.currentLocaleCode = code;
	elseif fallback then
		self.currentLocaleCode = self:GetDefaultLocale();
	end
end

---Get the default locale
---@return string
function Localization:GetDefaultLocale()
	return DEFAULT_LOCALE_CODE;
end

---Get the preferred locale, optionally overridden by GAME_LOCALE
---@return string
function Localization:GetPreferredLocale()
	-- GAME_LOCALE takes explicit priority
	if GAME_LOCALE ~= nil and self.locales[GAME_LOCALE] then
		return GAME_LOCALE;
	end

	-- Fall back to current, then default
	if self.currentLocaleCode and self.locales[self.currentLocaleCode] then
		return self.currentLocaleCode;
	end
	return DEFAULT_LOCALE_CODE;
end

---Get a localized string by key
---@param key string
---@param ... any
---@return string
function Localization:GetText(key, ...)
	local text;
	local active = self.locales[self.currentLocaleCode];

	if active then
		text = active[key];
	end

	if text == nil then
		text = self.locales[DEFAULT_LOCALE_CODE] and self.locales[DEFAULT_LOCALE_CODE][key];
	end

	if text == nil then
		text = key;
	end

	if select("#", ...) > 0 then
		return text:format(...);
	end

	return text;
end

---Flavour syntax: localization.KEY
function Localization:__index(key)
	return self:GetText(key);
end

---Flavour syntax: localization("KEY", ...)
function Localization:__call(key, ...)
	return self:GetText(key, ...);
end

SC.LocalizationClass = Localization;
