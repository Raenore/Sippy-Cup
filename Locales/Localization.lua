-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local locale = GetLocale() or "enUS";

local locales = {
  enUS = SIPPYCUP.L_ENUS,
  frFR = SIPPYCUP.L_FRFR,
  ruRU = SIPPYCUP.L_RURU,
};

local base = locales["enUS"] or {};
local current = locales[locale] or {};

-- Fallback for missing keys: metatable so it falls back to English
setmetatable(current, {
  __index = base,
});

-- Assign to your main localization reference
SIPPYCUP.L = current;
