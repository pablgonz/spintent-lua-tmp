local utf8 = require("unicode").utf8

-- =========================================================================
-- CACHÉ DE FUNCIONES GLOBALES LUA Y UTF8 (Optimización de Velocidad Nativa)
-- =========================================================================
local tonumber   = tonumber
local tostring   = tostring
local math_floor = math.floor
local t_insert   = table.insert
local t_concat   = table.concat

local s_match    = string.match
local s_gmatch   = string.gmatch
local s_sub      = string.sub
local s_gsub     = string.gsub

local u_len      = utf8.len
local u_sub      = utf8.sub

-- =========================================================================
-- BLOQUES LPEG COMPARTIDOS (Planos, sin _ENV)
-- =========================================================================
local lpeg_base = lpeg or require("lpeg")
local P, R, S, Cs, Ct, Cg, C = lpeg_base.P, lpeg_base.R, lpeg_base.S, lpeg_base.Cs, lpeg_base.Ct, lpeg_base.Cg, lpeg_base.C

local spintent_digit      = R"09"
local spintent_math_space = P"\\," + P"\\-" + P"\\;" + P"\\:" + P"\\!" + P"\\>" + P"\\quad" + P"\\qquad"
local spintent_num_chunk  = Cs(spintent_digit * ((spintent_math_space / "")^0 * spintent_digit)^0)

-- =========================================================================
-- 1. CANONICAL DICTIONARIES FOR SCIENTIFIC AND PHYSICAL UNITS
-- =========================================================================
local spintent_units = {
    ["°K"]   = "°K",
    ["A"]    = "A",    ["B"]    = "B",    ["Bq"]   = "Bq",   ["C"]    = "C",
    ["Da"]   = "Da",   ["F"]    = "F",    ["Gy"]   = "Gy",   ["H"]    = "H",
    ["Hz"]   = "Hz",   ["J"]    = "J",    ["K"]    = "K",    ["l"]    = "l",
    ["L"]    = "L",    ["ℓ"]    = "ℓ",    ["N"]    = "N",    ["Np"]   = "Np",
    ["Pa"]   = "Pa",   ["S"]    = "S",    ["Sv"]   = "Sv",   ["T"]    = "T",
    ["V"]    = "V",    ["W"]    = "W",    ["Wb"]   = "Wb",   ["a"]    = "a",
    ["atm"]  = "atm",  ["au"]   = "au",   ["b"]    = "b",    ["bar"]  = "bar",
    ["cal"]  = "cal",  ["cd"]   = "cd",   ["d"]    = "d",    ["dB"]   = "dB",
    ["dyn"]  = "dyn",  ["eV"]   = "eV",   ["erg"]  = "erg",  ["g"]    = "g",
    ["h"]    = "h",    ["ha"]   = "ha",   ["kat"]  = "kat",  ["kg"]   = "kg",
    ["km"]   = "km",   ["lm"]   = "lm",   ["lx"]   = "lx",   ["m"]    = "m",
    ["cm"]   = "cm",   ["min"]  = "min",  ["mm"]   = "mm",   ["mol"]  = "mol",
    ["pc"]   = "pc",   ["rad"]  = "rad",  ["rpm"]  = "rpm",  ["s"]    = "s",
    ["sr"]   = "sr",   ["t"]    = "t",    ["u"]    = "u",    ["w"]    = "w",
    ["y"]    = "y",    ["°"]    = "°",    ["°C"]   = "°C",   ["°F"]   = "°F",
    ["Ω"]    = "Ω",    ["℧"]    = "℧",    ["′"]    = "′",    ["″"]    = "″",
    ["Å"]    = "Å",    ["µ"]    = "µ",

    -- Imperial and US Customary Units
    ["pulgada"]    = "in",    ["pulgas"]     = "in",
    ["pie"]        = "ft",    ["pies"]       = "ft",
    ["yarda"]      = "yd",    ["yardas"]     = "yd",
    ["milla"]      = "mi",    ["millas"]     = "mi",
    ["libra"]      = "lb",    ["libras"]     = "lb",
    ["onza"]       = "oz",    ["onzas"]      = "oz",
    ["galon"]      = "gal",   ["galones"]    = "gal",
    ["hora"]       = "h",     ["horas"]      = "h",
    ["dia"]        = "d",     ["dias"]       = "d",
    ["caloria"]    = "cal",   ["calorias"]   = "cal",
    ["faradio"]    = "F",     ["culombio"]   = "C",
    ["bit"]        = "b",     ["byte"]       = "B",
    ["bytes"]      = "B",     ["fahrenheit"] = "°F",

    -- Word Alias Table for Full Unicodes
    ["kelvin"]   = "K",   ["Kelvin"]   = "K",
    ["ohmio"]    = "Ω",   ["ohm"]      = "Ω",   ["Omega"]    = "Ω",
    ["amperio"]  = "A",   ["ampere"]   = "A",
    ["voltio"]   = "V",   ["volt"]     = "V",
    ["vatio"]    = "W",   ["watt"]     = "W",
    ["julio"]    = "J",   ["joule"]    = "J",
    ["newton"]   = "N",
    ["pascal"]   = "Pa",
    ["hercio"]   = "Hz",  ["hertz"]    = "Hz",
    ["metro"]    = "m",   ["metros"]   = "m",
    ["segundo"]  = "s",   ["segundos"] = "s",
    ["litro"]    = "l",   ["l-litro"]  = "l",
    ["gramo"]    = "g",   ["gramos"]   = "g",
    ["angstrom"] = "Å",
    ["celsius"]  = "°C",  ["degC"]     = "°C",  ["℃"]        = "°C",
    ["degF"]     = "°F",  ["℉"]        = "°F",  ["micro"]    = "µ",

    -- Semantic Surgery
    ["minmin"]   = "′",   ["segseg"]   = "″",   ["u-masa"]   = "u",
    ["mho"]      = "℧",

    -- Compact Unicode Mappings
    ["㎡"]   = "m^2",      ["㎢"]   = "km^2",     ["㎠"]   = "cm^2",     ["㎜²"]  = "mm^2",
    ["㎥"]   = "m^3",      ["㎦"]   = "km^3",     ["㎤"]   = "cm^3",     ["㎜³"]  = "mm^3",
    ["㎐"]   = "Hz",       ["㎑"]   = "kHz",      ["㎒"]   = "MHz",      ["㎓"]   = "GHz",      ["㎔"]   = "THz",
    ["㎽"]   = "mW",       ["㎾"]   = "kW",       ["㎿"]   = "MW",       ["㎴"]   = "V",        ["㎵"]   = "kV",
    ["㎶"]   = "µV",       ["㎷"]   = "mV",       ["㎸"]   = "kV",       ["㎀"]   = "pA",       ["㎁"]   = "nA",
    ["㎂"]   = "µA",       ["㎃"]   = "mA",       ["㎄"]   = "kA",       ["㎫"]   = "MPa",      ["㎬"]   = "GPa",
    ["㎺"]   = "pW",       ["㎻"]   = "nW",       ["㎼"]   = "µW",
    ["㎍"]   = "µg",       ["㎎"]   = "mg",       ["㎏"]   = "kg",
    ["㎜"]   = "mm",       ["㎝"]   = "cm",       ["㎞"]   = "km",       ["㎛"]   = "µm",       ["㎕"]   = "µL",
    ["㎖"]   = "mL",       ["㎗"]   = "dL",       ["㎘"]   = "kL",       ["¼"]   = "cm^3",     ["㎧"]   = "m/s",
    ["㎨"]   = "m/s^2",    ["㎭"]   = "rad",      ["㎮"]   = "rad/s",    ["㎯"]   = "rad/s^2"
}

local spintent_unit_compact_spoken_names = {
    ["㎡"]      = "metro-cuadrado",
    ["㎥"]      = "metro-cúbico",
    ["㎢"]      = "kilómetro-cuadrado",
    ["㎟"]      = "milímetro-cuadrado",
    ["㎠"]      = "centímetro-cuadrado",
    ["㎣"]      = "milímetro-cúbico",
    ["㎤"]      = "centímetro-cúbico",
    ["㎦"]      = "kilómetro-cúbico",
    ["¼"]      = "centímetro-cúbico",
    ["㎧"]      = "metros-por-segundo",
    ["㎨"]      = "metros-por-segundo-al-cuadrado",
    ["㎐"]      = "hercio",
    ["℃"]      = "grados-celsius",
    ["℉"]      = "grados-fahrenheit",
    ["'"]      = "minutos",
    ["''"]     = "segundos",
    ['"']      = "segundos",
    ["minmin"] = "minutos",
    ["segseg"] = "segundos",
    ["′"]      = "minutos",
    ["″"]      = "segundos"
}

local spintent_custom_spunit_spoken_names = {}
local spintent_custom_spunit_aliases      = {}

local spintent_normalizations = {
    ["K"] = "K", ["Ω"] = "Ω", ["ℓ"] = "l", ["μ"] = "µ", ["°K"] = "°K",
    ["'"]  = "′", ["''"] = "″", ['"']  = "″", ["minmin"] = "′", ["segseg"] = "″"
}

-- =========================================================================
-- 2. ADVANCED SEMANTIC INFRASTRUCTURE FOR CURRENCIES (\spmoney)
-- =========================================================================
local spintent_internal_currencies = {
    ["$"]        = "$",         ["€"]        = "€",         ["£"]        = "£",         ["¥"]        = "¥",
    ["¢"]        = "¢",         ["₩"]        = "₩",         ["₪"]        = "₪",         ["₹"]        = "₹",
    ["₽"]        = "₽",         ["₺"]        = "₺",         ["₴"]        = "₴",
    ["dolar"]    = "$",         ["dolares"]  = "$",         ["usd"]      = "$",
    ["peso"]     = "$",         ["pesos"]    = "$",         ["clp"]      = "$",         ["mxn"]      = "$",
    ["euro"]     = "€",         ["euros"]    = "€",         ["eur"]      = "€",
    ["libra"]    = "£",         ["libras"]   = "£",         ["gbp"]      = "£",
    ["yen"]      = "¥",         ["yenes"]    = "¥",         ["yuan"]     = "¥",         ["yuanes"]   = "¥",
    ["jpy"]      = "¥",         ["cny"]      = "¥",         ["centavo"]  = "¢",         ["centavos"] = "¢",
    ["won"]      = "₩",         ["wons"]     = "₩",         ["krw"]      = "₩",
    ["shekel"]   = "₪",         ["shekels"]  = "₪",         ["sequel"]   = "₪",         ["sequeles"] = "₪",
    ["ils"]      = "₪",         ["rupia"]    = "₹",         ["rupias"]   = "₹",         ["inr"]      = "₹",
    ["rublo"]    = "₽",         ["rublos"]   = "₽",         ["rub"]      = "₽",
    ["lira"]     = "₺",         ["liras"]    = "₺",         ["try"]      = "₺",
    ["grivna"]   = "₴",         ["grivnas"]  = "₴",         ["uah"]      = "₴",
}

local spintent_currency_grammatical_dict = {
    ["$"]        = { sing = "peso",                  plur = "pesos",                  conde = "de-pesos" },
    ["peso"]     = { sing = "peso",                  plur = "pesos",                  conde = "de-pesos" },
    ["pesos"]    = { sing = "peso",                  plur = "pesos",                  conde = "de-pesos" },
    ["clp"]      = { sing = "peso-chileno",          plur = "pesos-chilenos",          conde = "de-pesos-chilenos" },
    ["mxn"]      = { sing = "peso-mexicano",         plur = "pesos-mexicanos",         conde = "de-pesos-mexicanos" },
    ["dolar"]    = { sing = "dólar",                 plur = "dólares",                conde = "de-dólares" },
    ["dolares"]  = { sing = "dólar",                 plur = "dólares",                conde = "de-dólares" },
    ["usd"]      = { sing = "dólar-estadounidense",  plur = "dólares-estadounidenses", conde = "de-dólares-estadounidenses" },
    ["euro"]     = { sing = "euro",                  plur = "euros",                  conde = "de-euros" },
    ["euros"]    = { sing = "euro",                  plur = "euros",                  conde = "de-euros" },
    ["eur"]      = { sing = "euro",                  plur = "euros",                  conde = "de-euros" },
    ["libra"]    = { sing = "libra",                 plur = "libras",                 conde = "de-libras" },
    ["libras"]   = { sing = "libra",                 plur = "libras",                 conde = "de-libras" },
    ["gbp"]      = { sing = "libra",                 plur = "libras",                 conde = "de-libras" },
    ["yen"]      = { sing = "yen",                   plur = "yenes",                  conde = "de-yenes" },
    ["yenes"]    = { sing = "yen",                   plur = "yenes",                  conde = "de-yenes" },
    ["jpy"]      = { sing = "yen",                   plur = "yenes",                  conde = "de-yenes" },
    ["yuan"]     = { sing = "yuan",                  plur = "yuanes",                 conde = "de-yuanes" },
    ["yuanes"]   = { sing = "yuan",                  plur = "yuanes",                 conde = "de-yuanes" },
    ["cny"]      = { sing = "yuan",                  plur = "yuanes",                 conde = "de-yuanes" },
    ["won"]      = { sing = "won",                   plur = "wons",                   conde = "de-wons" },
    ["krw"]      = { sing = "won",                   plur = "wons",                   conde = "de-wons" },
    ["shekel"]   = { sing = "séquel",                plur = "séqueles",               conde = "de-séqueles" },
    ["ils"]      = { sing = "séquel",                plur = "séqueles",               conde = "de-séqueles" },
    ["rupia"]    = { sing = "rupia",                 plur = "rupias",                 conde = "de-rupias" },
    ["inr"]      = { sing = "rupia",                 plur = "rupias",                 conde = "de-rupias" },
    ["rublo"]    = { sing = "rublo",                 plur = "rublos",                 conde = "de-rublos" },
    ["rub"]      = { sing = "rublo",                 plur = "rublos",                 conde = "de-rublos" },
    ["lira"]     = { sing = "lira",                  plur = "liras",                  conde = "de-liras" },
    ["try"]      = { sing = "lira",                  plur = "liras",                  conde = "de-liras" },
    ["grivna"]   = { sing = "grivna",                plur = "grivnas",                conde = "de-grivnas" },
    ["uah"]      = { sing = "grivna",                plur = "grivnas",                conde = "de-grivnas" },
}

local spintent_currency_subunits_matrix = {
    ["pesos"]                   = { sing = "centavo", plur = "centavos" },
    ["pesos-chilenos"]          = nil,
    ["pesos-colombianos"]       = nil,
    ["pesos-mexicanos"]         = { sing = "centavo", plur = "centavos" },
    ["dólares"]                 = { sing = "centavo", plur = "centavos" },
    ["dólares-estadounidenses"] = { sing = "centavo", plur = "centavos" },
    ["euros"]                   = { sing = "céntimo", plur = "céntimos" },
    ["libras"]                  = { sing = "penique", plur = "peniques" },
    ["yenes"]                   = nil,
    ["yuanes"]                  = { sing = "fen",     plur = "fen" },
    ["wons"]                    = nil,
    ["séqueles"]                = { sing = "ágora",   plur = "agorot" },
    ["rupias"]                  = { sing = "paisa",   plur = "paisas" },
    ["rublos"]                  = { sing = "kopek",   plur = "kopeks" },
    ["liras"]                   = { sing = "kuruş",   plur = "kuruş" },
    ["grivnas"]                 = { sing = "kopek",   plur = "kopeks" }
}

local spintent_currency_spoken_names = {
    ["$"]        = "pesos",                    ["peso"]    = "pesos",                    ["pesos"]   = "pesos",
    ["clp"]      = "pesos-chilenos",           ["mxn"]     = "pesos-mexicanos",
    ["dolar"]    = "dólares-estadounidenses",  ["dolares"] = "dólares-estadounidenses",  ["usd"]     = "dólares-estadounidenses",
    ["euro"]     = "euros",                    ["euros"]   = "euros",                    ["eur"]     = "euros",
    ["libra"]    = "libras",                   ["libras"]  = "libras",                   ["gbp"]     = "libras",
    ["yen"]      = "yenes",                    ["yenes"]   = "yenes",                    ["jpy"]     = "yenes",
    ["yuan"]     = "yuanes",                   ["yuanes"]  = "yuanes",                   ["cny"]     = "yuanes",
    ["centavo"]  = "centavos",                 ["centavos"]= "centavos",
    ["won"]      = "wons",                     ["krw"]     = "wons",
    ["shekel"]   = "séqueles",                 ["ils"]     = "séqueles",
    ["rupia"]    = "rupias",                   ["inr"]     = "rupias",
    ["rublo"]    = "rublos",                   ["rub"]     = "rublos",
    ["lira"]     = "liras",                    ["try"]     = "liras",
    ["grivna"]   = "grivnas",                  ["uah"]     = "grivnas",
}

-- =========================================================================
-- 3. COMMAND INFRASTRUCTURE AND PARSERS MOTOR (LPeg)
-- =========================================================================
local function register_tex_cmd(name, func, args)
    name = "__spintent_" .. name .. ":" .. ("n"):rep(#args)
    local scanners = {}
    for i = 1, #args do
        local scan_type = (args[i] == "string" and "scan_argument") or "scan_" .. args[i]
        scanners[i] = token[scan_type]
    end

    local scanning_func
    -- Optimización: Despacho sin alocamiento de tablas para 1 o 2 argumentos
    if #scanners == 1 then
        local s1 = scanners[1]
        scanning_func = function() func(s1()) end
    elseif #scanners == 2 then
        local s1, s2 = scanners[1], scanners[2]
        scanning_func = function() func(s1(), s2()) end
    else
        scanning_func = function()
            local values = {}
            for i = 1, #scanners do values[i] = scanners[i]() end
            func(table.unpack(values))
        end
    end

    local index = luatexbase.new_luafunction(name)
    lua.get_functions_table()[index] = scanning_func
    token.set_lua(name, index, "global", "protected")
end

local spintent_num_sign             = S "+-"
local spintent_num_decimal          = S ".," + P "{.}" + P "{,}"
local spintent_num_semi             = P ";"
local spintent_forbidden_in_extra   = spintent_num_decimal + spintent_num_semi

local spintent_number_pattern = Ct(
    Cg(spintent_num_sign^-1, "sign")
    * Cg(spintent_num_chunk^-1, "integer")
    * (Cg(C(spintent_num_decimal), "decimal") * Cg(spintent_num_chunk, "fraction"))^-1
    * (spintent_num_semi * Cg(spintent_num_chunk, "period"))^-1
    * Cg(Cs((spintent_math_space / "" + (P(1) - spintent_forbidden_in_extra))^0), "extra")
    * P(-1)
)

local function spintent_rae_format_digits(str_num, reverse)
    if not str_num or str_num == "" then return "" end
    str_num = tostring(str_num)
    local len = u_len(str_num) or #str_num
    if len <= 4 then return str_num end

    local chunks = {}
    if reverse then
        for i = 1, len, 3 do t_insert(chunks, u_sub(str_num, i, i + 2)) end
    else
        local first = len % 3
        if first == 0 then first = 3 end
        t_insert(chunks, u_sub(str_num, 1, first))
        for i = first + 1, len, 3 do t_insert(chunks, u_sub(str_num, i, i + 2)) end
    end
    return t_concat(chunks, "\\,")
end

register_tex_cmd("luafun_clean_split_arg", function(raw_string)
    raw_string = s_gsub(raw_string, "^%s*(.-)%s*$", "%1")
    local result = spintent_number_pattern:match(raw_string) or {}

    local r_sign     = result.sign or ""
    local r_int      = result.integer or ""
    local r_dec      = result.decimal or ""
    local r_frac     = result.fraction or ""
    local r_period   = result.period or ""
    local r_extra    = result.extra

    local above = ""
    local below = ""
    local unit_status = "valid"
    local has_units = "false"
    local denom_has_numeric = "false"

    if r_extra then
        local extra = s_gsub(r_extra, "^%s*(.-)%s*$", "%1")
        if spintent_custom_spunit_aliases[extra] then extra = spintent_custom_spunit_aliases[extra] end

        if extra ~= "" then
            has_units = "true"
            local parts = {}
            for part in s_gmatch(extra, "[^/]+") do t_insert(parts, part) end
            if #parts > 2 or s_match(extra, "/%s*/") then
                unit_status = "multislash"
            else
                above = parts[1] or ""
                below = parts[2] or ""
                if below ~= "" and s_match(below, "^%s*%d") then
                    denom_has_numeric = "true"
                end
            end
        end
    end

    local is_million_clean = "false"
    if r_int ~= "" then
        local int_value = tonumber(r_int)
        if int_value and int_value > 999999 and (int_value % 1000000 == 0) then
            is_million_clean = "true"
        end
    end

    local has_dec = r_dec ~= ""
    local has_per = r_period ~= ""
    local dec_and_per, dec_not_per, not_dec_and_per, not_dec_not_per = "false", "false", "false", "false"

    if has_dec and has_per then
        dec_and_per = "true"
    elseif has_dec and not has_per then
        dec_not_per = "true"
    elseif not has_dec and has_per then
        not_dec_and_per = "true"
    else
        not_dec_not_per = "true"
    end

    token.set_macro("l__spintent_luaset_sign_tl", r_sign)
    token.set_macro("l__spintent_luaset_part_int_tl", r_int)
    token.set_macro("l__spintent_luaset_dec_sep_tl", r_dec)
    token.set_macro("l__spintent_luaset_part_dec_tl", r_frac)
    token.set_macro("l__spintent_luaset_part_period_tl", r_period)
    token.set_macro("l__spintent_luaset_arg_above_tl", above)
    token.set_macro("l__spintent_luaset_arg_below_tl", below)
    token.set_macro("l__spintent_luaset_status_str", unit_status)
    token.set_macro("l__spintent_luaset_has_units_str", has_units)
    token.set_macro("l__spintent_luaset_denom_has_numeric_coef_str", denom_has_numeric)
    token.set_macro("l__spintent_luaset_only_part_int_str", r_int)
    token.set_macro("l__spintent_luaset_only_part_dec_str", r_frac)
    token.set_macro("l__spintent_luaset_only_part_period_str", r_period)
    token.set_macro("l__spintent_luaset_format_part_int_str", spintent_rae_format_digits(r_int, false))
    token.set_macro("l__spintent_luaset_format_part_dec_str", spintent_rae_format_digits(r_frac, true))
    token.set_macro("l__spintent_luaset_millons_str", is_million_clean)
    token.set_macro("l__spintent_luaset_decimal_and_period_str", dec_and_per)
    token.set_macro("l__spintent_luaset_decimal_not_period_str", dec_not_per)
    token.set_macro("l__spintent_luaset_not_decimal_and_period_str", not_dec_and_per)
    token.set_macro("l__spintent_luaset_not_decimal_not_period_str", not_dec_not_per)

    if r_frac ~= "" and s_match(r_frac, "^0+$") then
        token.set_macro("l__spintent_luaset_dec_is_all_zeros_str", "true")
    else
        token.set_macro("l__spintent_luaset_dec_is_all_zeros_str", "false")
    end
end, { "string" })

-- =========================================================================
-- 4. ADDITIONAL UNIT INTERFACES AND SANITIZING UTILITIES
-- =========================================================================
register_tex_cmd("luafun_define_custom_unit", function(unit_name, spoken_reading)
    unit_name = s_gsub(s_gsub(unit_name, "^%s*(.-)%s*$", "%1"), "%s+", "")
    spoken_reading = s_gsub(spoken_reading, "^%s*(.-)%s*$", "%1")
    if spintent_units[unit_name] or spintent_normalizations[unit_name] then
        token.set_macro("l__spintent_spunit_luaset_register_status_str", "duplicate")
    else
        spintent_units[unit_name] = unit_name
        spintent_custom_spunit_spoken_names[unit_name] = spoken_reading
        token.set_macro("l__spintent_spunit_luaset_register_status_str", "success")
    end
end, { "string", "string" })

register_tex_cmd("luafun_spunit_lookup_alias", function(raw_unit_name)
    raw_unit_name = s_gsub(s_gsub(raw_unit_name, "^%s*(.-)%s*$", "%1"), "%s+", "")
    local clean_exp_format = s_gsub(s_gsub(raw_unit_name, "{", ""), "}", "")
    token.set_macro("l__spintent_spunit_luaset_is_sexagesimal_str", "false")

    local search_name = spintent_normalizations[clean_exp_format] or spintent_normalizations[raw_unit_name] or raw_unit_name
    local canonical = spintent_units[search_name] or spintent_units[clean_exp_format]

    if canonical then
        local base_clean = s_gsub(canonical, "%^%-?%d+", "")
        local spoken = spintent_custom_spunit_spoken_names[base_clean]
            or spintent_unit_compact_spoken_names[raw_unit_name]
            or spintent_unit_compact_spoken_names[clean_exp_format]
            or spintent_unit_compact_spoken_names[search_name]
            or ":unit"

        token.set_macro("l__spintent_spunit_luaset_read_str", spoken)

        if s_match(canonical, "%^") then
            local base, exp = s_match(canonical, "([^%^]+)%^(%-?%d+)")
            if base and exp then
                token.set_macro("l__spintent_spunit_luaset_canonical_str", base)
                token.set_macro("l__spintent_spunit_luaset_compact_exp_str", exp)
                token.set_macro("l__spintent_spunit_luaset_is_compact_str", "true")
            else
                token.set_macro("l__spintent_spunit_luaset_canonical_str", canonical)
                token.set_macro("l__spintent_spunit_luaset_is_compact_str", "false")
            end
        else
            token.set_macro("l__spintent_spunit_luaset_canonical_str", canonical)
            token.set_macro("l__spintent_spunit_luaset_is_compact_str", "false")
        end

        if canonical == "°" or canonical == "′" or canonical == "″" then
            token.set_macro("l__spintent_spunit_luaset_is_sexagesimal_str", "true")
        else
            token.set_macro("l__spintent_spunit_luaset_is_sexagesimal_str", "false")
        end
        token.set_macro("l__spintent_spunit_luaset_lookup_status_str", "found")
    else
        local literal_base, literal_exp = s_match(clean_exp_format, "([^%^]+)%^(%-?%d+)")
        if literal_base and literal_exp then
            local canonical_base = spintent_units[spintent_normalizations[literal_base] or literal_base]
            if canonical_base then
                token.set_macro("l__spintent_spunit_luaset_canonical_str", canonical_base)
                token.set_macro("l__spintent_spunit_luaset_compact_exp_str", literal_exp)
                token.set_macro("l__spintent_spunit_luaset_is_compact_str", "true")
                local spoken = spintent_custom_spunit_spoken_names[canonical_base] or ":unit"
                token.set_macro("l__spintent_spunit_luaset_read_str", spoken)
                if canonical_base == "°" or canonical_base == "′" or canonical_base == "″" then
                    token.set_macro("l__spintent_spunit_luaset_is_sexagesimal_str", "true")
                end
                token.set_macro("l__spintent_spunit_luaset_lookup_status_str", "found")
            else
                token.set_macro("l__spintent_spunit_luaset_is_compact_str", "false")
                token.set_macro("l__spintent_spunit_luaset_lookup_status_str", "notfound")
            end
        else
            token.set_macro("l__spintent_spunit_luaset_is_compact_str", "false")
            token.set_macro("l__spintent_spunit_luaset_lookup_status_str", "notfound")
        end
    end
end, { "string" })

local spintent_tex_accents = {
    ["\\'a"] = "á", ["\\'e"] = "é", ["\\'i"] = "í", ["\\'o"] = "ó", ["\\'u"] = "ú",
    ["\\'A"] = "Á", ["\\'E"] = "É", ["\\'I"] = "Í", ["\\'O"] = "Ó", ["\\'U"] = "Ú",
    ["\\\"u"] = "ü", ["\\\"U"] = "Ü", ["\\~n"] = "ñ", ["\\~N"] = "Ñ"
}

register_tex_cmd("luafun_sanitize_read_arg", function(raw_accent_string)
    local clean = s_gsub(raw_accent_string, "[{}]", "")
    clean = s_gsub(clean, "\\[\'~\x22].", spintent_tex_accents)
    clean = s_gsub(clean, "%s+", "-")
    token.set_macro("l__spintent_clean_arg_str", clean)
end, { "string" })

register_tex_cmd("luafun_define_spunit_alias", function(alias_name, unit_expression)
    alias_name = s_gsub(s_gsub(alias_name, "^%s*(.-)%s*$", "%1"), "%s+", "")
    unit_expression = s_gsub(unit_expression, "^%s*(.-)%s*$", "%1")
    if spintent_units[alias_name] or spintent_normalizations[alias_name] or spintent_custom_spunit_aliases[alias_name] then
        token.set_macro("l__spintent_spunit_luaset_register_status_str", "duplicate")
        return
    end
    local is_valid = true
    local _, slash_count = s_gsub(unit_expression, "/", "")
    if slash_count > 1 then is_valid = false end

    if s_match(unit_expression, "[^%a°ΩµÅℓ′″℧%*%/%^%-%d%s%'%\x22]") then is_valid = false end
    if is_valid then
        for unit_base in s_gmatch(unit_expression, "[%a°ΩµÅℓ′″℧%'%\x22]+") do
            if not (spintent_units[unit_base] or spintent_normalizations[unit_base]) then is_valid = false; break end
        end
    end
    if not is_valid then
        token.set_macro("l__spintent_spunit_luaset_register_status_str", "invalid-expr")
    else
        spintent_custom_spunit_aliases[alias_name] = unit_expression
        token.set_macro("l__spintent_spunit_luaset_register_status_str", "success")
    end
end, { "string", "string" })

-- =========================================================================
-- GCD / LCM ARITHMETIC ALGORITHMS
-- =========================================================================
local function spintent_gcd_algorithm(val_a, val_b)
    while val_b ~= 0 do val_a, val_b = val_b, val_a % val_b end
    return val_a
end

local function spintent_lcm_algorithm(val_a, val_b)
    if val_a == 0 or val_b == 0 then return 0 end
    return math_floor((val_a * val_b) / spintent_gcd_algorithm(val_a, val_b))
end

local function execute_mcm_mcd_result(raw_csv_list, tl_out, operation_fn)
    local numbers = {}
    token.set_macro("l__spintent_spmcm_spmcd_luaset_error_str", "false")

    for item in s_gmatch(raw_csv_list, "([^,]+)") do
        local clean_item = s_gsub(item, "^%s*(.-)%s*$", "%1")
        local result = spintent_number_pattern:match(clean_item) or {}

        local r_int  = result.integer
        local r_sign = result.sign
        local r_dec  = result.decimal
        local r_per  = result.period
        local r_ext  = result.extra

        local es_natural = r_int and (not r_sign or r_sign == "")
          and (not r_dec or r_dec == "") and (not r_per or r_per == "")
          and (not r_ext or s_gsub(r_ext, "%s+", "") == "")

        if es_natural then
            t_insert(numbers, tonumber(r_int))
        else
            token.set_macro("l__spintent_spmcm_spmcd_luaset_error_str", "true")
            return
        end
    end
    if #numbers == 0 then
        token.set_macro("l__spintent_spmcm_spmcd_luaset_error_str", "true")
        return
    end
    local final_result = numbers[1]
    for i = 2, #numbers do final_result = operation_fn(final_result, numbers[i]) end
    token.set_macro(tl_out, string.format("%d", final_result))
end

register_tex_cmd("luafun_calculate_mcd", function(raw_csv_list)
    execute_mcm_mcd_result(raw_csv_list, "l__spintent_spmcd_luaset_mcd_value_tl", spintent_gcd_algorithm)
end, { "string" })

register_tex_cmd("luafun_calculate_mcm", function(raw_csv_list)
    execute_mcm_mcd_result(raw_csv_list, "l__spintent_luaset_mcm_value_tl", spintent_lcm_algorithm)
end, { "string" })

-- =========================================================================
-- SEXAGESIMAL SYSTEM
-- =========================================================================
local spintent_sexagesimal_pattern = Ct(
    Cg(spintent_num_chunk^-1, "a") * P ":" * Cg(spintent_num_chunk^-1, "b") * (P ":" * Cg(spintent_num_chunk^-1, "c"))^-1 * P(-1)
)

register_tex_cmd("luafun_parse_sexagesimal", function(raw_sexag_str)
    raw_sexag_str = s_gsub(raw_sexag_str, "%s+", "")
    local result = spintent_sexagesimal_pattern:match(raw_sexag_str)

    if not result then
        token.set_macro("l__spintent_spsexag_error_status_str", "true")
        return
    end

    token.set_macro("l__spintent_spsexag_error_status_str", "false")
    token.set_macro("l__spintent_spsexag_luaset_grado_str", result.a or "")
    token.set_macro("l__spintent_spsexag_luaset_minuto_str", result.b or "")
    token.set_macro("l__spintent_spsexag_luaset_segundo_str", result.c or "")
end, { "string" })

-- =========================================================================
-- 5. CRITICAL FINANCIAL METADATA AND GRAMMATICAL RESOLUTION INTERFACES
-- =========================================================================
register_tex_cmd("luafun_spmoney_lookup_metadata", function(currency_name)
    local clean = s_gsub(currency_name, "^%s*(.-)%s*$", "%1"):lower()
    local resolved_symbol = spintent_internal_currencies[clean] or "$"

    local gram_entry = spintent_currency_grammatical_dict[clean] or spintent_currency_grammatical_dict[resolved_symbol]
      or { sing = "peso", plur = "pesos", conde = "de-pesos" }

    local position = "pre"
    if resolved_symbol == "€" then position = "post" end

    local raw_input = s_gsub(currency_name, "^%s*(.-)%s*$", "%1")
    if raw_input == raw_input:upper() and s_match(raw_input, "^[A-Za-z]+$") then
        token.set_macro("l__spintent_spmoney_luaset_print_iso_str", "true")
    else
        token.set_macro("l__spintent_spmoney_luaset_print_iso_str", "false")
    end

    local sub_db = spintent_currency_subunits_matrix[gram_entry.plur]

    token.set_macro("l__spintent_spmoney_luaset_resolved_symbol_str", resolved_symbol)
    token.set_macro("l__spintent_spmoney_luaset_resolved_position_str", position)
    token.set_macro("l__spintent_spmoney_luaset_resolved_sing_str", gram_entry.sing)
    token.set_macro("l__spintent_spmoney_luaset_resolved_plur_str", gram_entry.plur)
    token.set_macro("l__spintent_spmoney_luaset_resolved_conde_str", gram_entry.conde)

    if sub_db then
        token.set_macro("l__spintent_spmoney_luaset_has_subunits_tl", "true")
        token.set_macro("l__spintent_spmoney_luaset_resolved_subsing_str", sub_db.sing)
        token.set_macro("l__spintent_spmoney_luaset_resolved_subplur_str", sub_db.plur)
    else
        token.set_macro("l__spintent_spmoney_luaset_has_subunits_tl", "false")
        token.set_macro("l__spintent_spmoney_luaset_resolved_subsing_str", "")
        token.set_macro("l__spintent_spmoney_luaset_resolved_subplur_str", "")
    end
end, { "string" })

register_tex_cmd("luafun_spmoney_normalize_key", function(raw_input)
    local clean = s_gsub(raw_input, "^%s*(.-)%s*$", "%1"):lower()
    local resolved_symbol = spintent_internal_currencies[clean]
    local resolved_spoken = nil

    if resolved_symbol then
        resolved_spoken = spintent_currency_spoken_names[clean] or spintent_currency_spoken_names[resolved_symbol]
    else
        resolved_spoken = spintent_currency_spoken_names[clean]
    end

    if resolved_spoken then
        token.set_macro("l__spintent_spmoney_luaset_currency_arg_str", resolved_spoken)
        token.set_macro("l__spintent_spmoney_luaset_lookup_status_str", "found")
    else
        token.set_macro("l__spintent_spmoney_luaset_currency_arg_str", raw_input)
        token.set_macro("l__spintent_spmoney_luaset_lookup_status_str", "notfound")
    end
end, { "string" })

-- =========================================================================
-- LUA SUBMODULE: \spdate AND \sptime
-- =========================================================================
local spintent_date_sep = S"/-"

local spintent_date_pattern = Ct(
    (Cg(spintent_num_chunk, "year") * spintent_date_sep * Cg(spintent_num_chunk, "month") * spintent_date_sep * Cg(spintent_num_chunk, "day") * P(-1)) +
    (Cg(spintent_num_chunk, "day") * spintent_date_sep * Cg(spintent_num_chunk, "month") * spintent_date_sep * Cg(spintent_num_chunk, "year") * P(-1))
)

register_tex_cmd("luafun_spdate_parse", function(raw_date_input)
    if not raw_date_input then return end
    local clean_str = s_gsub(raw_date_input, "%s+", "")
    local result = spintent_date_pattern:match(clean_str)

    if not result then
        token.set_macro("l__spintent_spdate_luaset_error_str", "true")
        return
    end

    token.set_macro("l__spintent_spdate_luaset_error_str", "false")
    token.set_macro("l__spintent_spdate_luaset_day_str", result.day)
    token.set_macro("l__spintent_spdate_luaset_month_str", result.month)
    token.set_macro("l__spintent_spdate_luaset_year_str", result.year)
    token.set_macro("l__spintent_spdate_luaset_output_str", result.day .. "/" .. result.month .. "/" .. result.year)
end, { "string" })

local spintent_time_pattern = Ct(
    Cg(spintent_num_chunk, "h") * P":" * Cg(spintent_num_chunk, "m") * (P":" * Cg(spintent_num_chunk, "s"))^-1 * P(-1)
)

register_tex_cmd("luafun_sptime_parse", function(raw_time_input)
    if not raw_time_input then return end
    local clean_str = s_gsub(raw_time_input, "%s+", "")
    local result = spintent_time_pattern:match(clean_str)

    if not result then
        token.set_macro("l__spintent_sptime_luaset_error_str", "true")
        return
    end

    local h = tonumber(result.h)
    local m = tonumber(result.m)
    local s = result.s and tonumber(result.s) or nil

    if not h or not m or h >= 24 or m >= 60 or (s and s >= 60) then
        token.set_macro("l__spintent_sptime_luaset_error_str", "true")
        return
    end

    token.set_macro("l__spintent_sptime_luaset_error_str", "false")
    token.set_macro("l__spintent_sptime_luaset_base_str", result.h .. ":" .. result.m)

    if result.s then
        token.set_macro("l__spintent_sptime_luaset_has_seconds_str", "true")
        token.set_macro("l__spintent_sptime_luaset_seconds_str", result.s)

        if result.m == "15" or result.m == "30" then
            token.set_macro("l__spintent_sptime_luaset_is_fraction_str", "true")
        else
            token.set_macro("l__spintent_sptime_luaset_is_fraction_str", "false")
        end
    else
        token.set_macro("l__spintent_sptime_luaset_has_seconds_str", "false")
        token.set_macro("l__spintent_sptime_luaset_seconds_str", "")
        token.set_macro("l__spintent_sptime_luaset_is_fraction_str", "false")
    end
end, { "string" })

-- =========================================================================
-- LUA SUBMODULE: \spsiglo (Optimizado sin alocamiento de tablas)
-- =========================================================================
local spintent_arab_to_roman_map = {
  {1000, "m"}, {900, "cm"}, {500, "d"}, {400, "cd"},
  {100, "c"}, {90, "xc"}, {50, "l"}, {40, "xl"},
  {10, "x"}, {9, "ix"}, {5, "v"}, {4, "iv"}, {1, "i"}
}

local spintent_roman_to_arab_map = {
  i = 1, v = 5, x = 10, l = 50, c = 100, d = 500, m = 1000
}

local function spintent_arabic_to_roman(num)
  local result = ""
  for i = 1, #spintent_arab_to_roman_map do
    local pair = spintent_arab_to_roman_map[i]
    while num >= pair[1] do
      result = result .. pair[2]
      num = num - pair[1]
    end
  end
  return result
end

local function spintent_roman_to_arabic(str_roman)
  local total = 0
  local i = 1
  local len = #str_roman

  while i <= len do
    local c1 = s_sub(str_roman, i, i)
    local v1 = spintent_roman_to_arab_map[c1] or 0

    if i + 1 <= len then
      local c2 = s_sub(str_roman, i + 1, i + 1)
      local v2 = spintent_roman_to_arab_map[c2] or 0

      if v1 < v2 then
        total = total + (v2 - v1)
        i = i + 2
      else
        total = total + v1
        i = i + 1
      end
    else
      total = total + v1
      i = i + 1
    end
  end
  return total
end

register_tex_cmd("luafun_spsiglo_parse", function(raw_siglo_input)
  local clean = s_gsub(raw_siglo_input, "%s+", ""):lower()
  local arabic_val = nil
  local roman_val = nil
  local is_error = false

  if s_match(clean, "^%d+$") then
    arabic_val = tonumber(clean)
    if arabic_val > 0 and arabic_val <= 4000 then
      roman_val = spintent_arabic_to_roman(arabic_val)
    else
      is_error = true
    end
  elseif s_match(clean, "^[ivxlcdm]+$") and clean ~= "" then
    roman_val = clean
    arabic_val = spintent_roman_to_arabic(clean)

    if spintent_arabic_to_roman(arabic_val) ~= clean then
      is_error = true
    end
  else
    is_error = true
  end

  if is_error then
    token.set_macro("l__spintent_spsiglo_luaset_error_str", "true")
    token.set_macro("l__spintent_spsiglo_luaset_arabic_str", "")
    token.set_macro("l__spintent_spsiglo_luaset_roman_min_str", "")
  else
    token.set_macro("l__spintent_spsiglo_luaset_error_str", "false")
    token.set_macro("l__spintent_spsiglo_luaset_arabic_str", tostring(arabic_val))
    token.set_macro("l__spintent_spsiglo_luaset_roman_min_str", roman_val)
  end
end, { "string" })
