local utf8 = require("unicode").utf8

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
    for _, arg in ipairs(args) do
        local scan_type = (arg == "string" and "scan_argument") or "scan_" .. arg
        scanners[#scanners+1] = token[scan_type]
    end
    local scanning_func = function()
        local values = {}
        for _, scanner in ipairs(scanners) do values[#values+1] = scanner() end
        func(table.unpack(values))
    end
    local index = luatexbase.new_luafunction(name)
    lua.get_functions_table()[index] = scanning_func
    token.set_lua(name, index, "global", "protected")
end

local spintent_number_pattern do
    local _ENV = lpeg
    local sign             = S "+-"
    local decimal          = S ".," + P "{.}" + P "{,}"
    local semi             = P ";"
    local digit            = R "09"
    local math_space       = P"\\," + P"\\;" + P"\\:" + P"\\!" + P"\\>" + P"\\quad" + P"\\qquad"
    local num_part_req     = Cs(digit * ((math_space / "")^0 * digit)^0)
    local forbidden_in_extra = decimal + semi

    spintent_number_pattern = Ct(
        Cg(sign^-1, "sign")
        * Cg(num_part_req^-1, "integer")
        * (Cg(C(decimal), "decimal") * Cg(num_part_req, "fraction"))^-1
        * (semi * Cg(num_part_req, "period"))^-1
        * Cg(Cs((math_space / "" + (P(1) - forbidden_in_extra))^0), "extra")
        * P(-1)
    )
end

local function spintent_rae_format_digits(str_num, reverse)
    if not str_num or str_num == "" then return "" end
    str_num = tostring(str_num)
    local len = utf8.len(str_num) or #str_num
    if len <= 4 then return str_num end

    if reverse then
        local chunks = {}
        for i = 1, len, 3 do chunks[#chunks + 1] = utf8.sub(str_num, i, i + 2) end
        return table.concat(chunks, "\\,")
    else
        local first = len % 3
        if first == 0 then first = 3 end
        local chunks = { utf8.sub(str_num, 1, first) }
        for i = first + 1, len, 3 do chunks[#chunks + 1] = utf8.sub(str_num, i, i + 2) end
        return table.concat(chunks, "\\,")
    end
end

register_tex_cmd("luafun_clean_split_arg", function(raw_string)
    raw_string = raw_string:gsub("^%s*(.-)%s*$", "%1")
    local result = spintent_number_pattern:match(raw_string) or {}
    local above = ""
    local below = ""
    local unit_status = "valid"
    local has_units = "false"
    local denom_has_numeric = "false"

    if result.extra then
        local extra = result.extra:gsub("^%s*(.-)%s*$", "%1")
        if spintent_custom_spunit_aliases[extra] then extra = spintent_custom_spunit_aliases[extra] end

        if extra ~= "" then
            has_units = "true"
            local parts = {}
            for part in string.gmatch(extra, "[^/]+") do parts[#parts + 1] = part end
            if #parts > 2 or string.match(extra, "/%s*/") then
                unit_status = "multislash"
            else
                above = parts[1] or ""
                below = parts[2] or ""
                if below ~= "" and string.match(below, "^%s*%d") then
                    denom_has_numeric = "true"
                end
            end
        end
    end

    local is_million_clean = "false"
    if result.integer and result.integer ~= "" then
        local int_value = tonumber(result.integer)
        if int_value and int_value > 999999 and (int_value % 1000000 == 0) then
            is_million_clean = "true"
        end
    end

    local has_dec = (result.decimal and result.decimal ~= "") and true or false
    local has_per = (result.period and result.period ~= "") and true or false
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

    token.set_macro("l__spintent_luaset_sign_tl", result.sign or "")
    token.set_macro("l__spintent_luaset_part_int_tl", result.integer or "")
    token.set_macro("l__spintent_luaset_dec_sep_tl", result.decimal or "")
    token.set_macro("l__spintent_luaset_part_dec_tl", result.fraction or "")
    token.set_macro("l__spintent_luaset_part_period_tl", result.period or "")
    token.set_macro("l__spintent_luaset_arg_above_tl", above)
    token.set_macro("l__spintent_luaset_arg_below_tl", below)
    token.set_macro("l__spintent_luaset_status_str", unit_status)
    token.set_macro("l__spintent_luaset_has_units_str", has_units)
    token.set_macro("l__spintent_luaset_denom_has_numeric_coef_str", denom_has_numeric)
    token.set_macro("l__spintent_luaset_only_part_int_str", result.integer or "")
    token.set_macro("l__spintent_luaset_only_part_dec_str", result.fraction or "")
    token.set_macro("l__spintent_luaset_only_part_period_str", result.period or "")
    token.set_macro("l__spintent_luaset_format_part_int_str", spintent_rae_format_digits(result.integer, false))
    token.set_macro("l__spintent_luaset_format_part_dec_str", spintent_rae_format_digits(result.fraction, true))
    token.set_macro("l__spintent_luaset_millons_str", is_million_clean)
    token.set_macro("l__spintent_luaset_decimal_and_period_str", dec_and_per)
    token.set_macro("l__spintent_luaset_decimal_not_period_str", dec_not_per)
    token.set_macro("l__spintent_luaset_not_decimal_and_period_str", not_dec_and_per)
    token.set_macro("l__spintent_luaset_not_decimal_not_period_str", not_dec_not_per)

    if result.fraction and string.match(tostring(result.fraction), "^0+$") then
        token.set_macro("l__spintent_luaset_dec_is_all_zeros_str", "true")
    else
        token.set_macro("l__spintent_luaset_dec_is_all_zeros_str", "false")
    end
end, { "string" })
-- =========================================================================
-- 4. ADDITIONAL UNIT INTERFACES AND SANITIZING UTILITIES
-- =========================================================================
register_tex_cmd("luafun_define_custom_unit", function(unit_name, spoken_reading)
    unit_name = unit_name:gsub("^%s*(.-)%s*$", "%1"):gsub("%s+", "")
    spoken_reading = spoken_reading:gsub("^%s*(.-)%s*$", "%1")
    if spintent_units[unit_name] or spintent_normalizations[unit_name] then
        token.set_macro("l__spintent_spunit_luaset_register_status_str", "duplicate")
    else
        spintent_units[unit_name] = unit_name
        spintent_custom_spunit_spoken_names[unit_name] = spoken_reading
        token.set_macro("l__spintent_spunit_luaset_register_status_str", "success")
    end
end, { "string", "string" })

register_tex_cmd("luafun_spunit_lookup_alias", function(raw_unit_name)
    raw_unit_name = raw_unit_name:gsub("^%s*(.-)%s*$", "%1"):gsub("%s+", "")
    local clean_exp_format = raw_unit_name:gsub("{", ""):gsub("}", "")
    token.set_macro("l__spintent_spunit_luaset_is_sexagesimal_str", "false")

    local search_name = spintent_normalizations[clean_exp_format] or spintent_normalizations[raw_unit_name] or raw_unit_name
    local canonical = spintent_units[search_name] or spintent_units[clean_exp_format]

    if canonical then
        local base_clean = canonical:gsub("%^%-?%d+", "")
        local spoken = spintent_custom_spunit_spoken_names[base_clean]
            or spintent_unit_compact_spoken_names[raw_unit_name]
            or spintent_unit_compact_spoken_names[clean_exp_format]
            or spintent_unit_compact_spoken_names[search_name]
            or ":unit"

        token.set_macro("l__spintent_spunit_luaset_read_str", spoken)

        if canonical:match("%^") then
            local base, exp = canonical:match("([^%^]+)%^(%-?%d+)")
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
        local literal_base, literal_exp = clean_exp_format:match("([^%^]+)%^(%-?%d+)")
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

local tex_accent_replacements = {
    ["\\'a"] = "á", ["\\'e"] = "é", ["\\'i"] = "í", ["\\'o"] = "ó", ["\\'u"] = "ú",
    ["\\'A"] = "Á", ["\\'E"] = "É", ["\\'I"] = "Í", ["\\'O"] = "Ó", ["\\'U"] = "Ú",
    ["\\\"u"] = "ü", ["\\\"U"] = "Ü", ["\\~n"] = "ñ", ["\\~N"] = "Ñ"
}

register_tex_cmd("luafun_sanitize_read_arg", function(raw_accent_string)
    local clean_string = raw_accent_string
    clean_string = clean_string:gsub("{(%\\%'. -)}", "%1"):gsub("{(%\\%~.-)}", "%1"):gsub("{(%\\%\x22.-)}", "%1")
    clean_string = clean_string:gsub("(\\%'){(.-)}", "%1%2"):gsub("(\\%~){(.-)}", "%1%2"):gsub("(\\%\x22){(.-)}", "%1%2")
    clean_string = clean_string:gsub("\\%'.", tex_accent_replacements):gsub("\\%~.", tex_accent_replacements):gsub("\\%\x22.", tex_accent_replacements)
    clean_string = clean_string:gsub("{", ""):gsub("}", ""):gsub("%s+", "-")
    token.set_macro("l__spintent_clean_arg_str", clean_string)
end, { "string" })

register_tex_cmd("luafun_define_spunit_alias", function(alias_name, unit_expression)
    alias_name = alias_name:gsub("^%s*(.-)%s*$", "%1"):gsub("%s+", "")
    unit_expression = unit_expression:gsub("^%s*(.-)%s*$", "%1")
    if spintent_units[alias_name] or spintent_normalizations[alias_name] or spintent_custom_spunit_aliases[alias_name] then
        token.set_macro("l__spintent_spunit_luaset_register_status_str", "duplicate")
        return
    end
    local is_valid = true
    local _, slash_count = unit_expression:gsub("/", "")
    if slash_count > 1 then is_valid = false end

    if unit_expression:match("[^%a°ΩµÅℓ′″℧%*%/%^%-%d%s%'%\x22]") then is_valid = false end
    if is_valid then
        for unit_base in unit_expression:gmatch("[%a°ΩµÅℓ′″℧%'%\x22]+") do
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
    return math.floor((val_a * val_b) / spintent_gcd_algorithm(val_a, val_b))
end

local function execute_mcm_mcd_result(raw_csv_list, tl_out, operation_fn)
    local numbers = {}
    token.set_macro("l__spintent_spmcm_spmcd_luaset_error_str", "false")

    for item in raw_csv_list:gmatch("([^,]+)") do
        local clean_item = item:gsub("^%s*(.-)%s*$", "%1")
        local result = spintent_number_pattern:match(clean_item) or {}
        local es_natural = result.integer and (not result.sign or result.sign == "")
          and (not result.decimal or result.decimal == "") and (not result.period or result.period == "")
          and (not result.extra or result.extra:gsub("%s+", "") == "")
        if es_natural then
            table.insert(numbers, tonumber(result.integer))
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
-- SEXAGESIMAL SYSTEM (Real Optimized LPeg)
-- =========================================================================
local spintent_sexagesimal_pattern do
    local _ENV = lpeg
    local digit      = R "09"
    local math_space = P"\\,-" + P"\\;" + P"\\:" + P"\\!" + P"\\>" + P"\\quad" + P"\\qquad"
    local chunk      = Cs(digit * ((math_space / "")^0 * digit)^0)
    spintent_sexagesimal_pattern = Ct(Cg(chunk^-1, "a") * P ":" * Cg(chunk^-1, "b") * (P ":" * Cg(chunk^-1, "c"))^-1 * P(-1))
end

register_tex_cmd("luafun_parse_sexagesimal", function(raw_sexag_str)
    raw_sexag_str = raw_sexag_str:gsub("%s+", "")
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
    local clean = currency_name:gsub("^%s*(.-)%s*$", "%1"):lower()
    local resolved_symbol = spintent_internal_currencies[clean] or "$"

    local gram_entry = spintent_currency_grammatical_dict[clean] or spintent_currency_grammatical_dict[resolved_symbol]
      or { sing = "peso", plur = "pesos", conde = "de-pesos" }

    local position = "pre"
    if resolved_symbol == "€" then position = "post" end

    local raw_input = currency_name:gsub("^%s*(.-)%s*$", "%1")
    if raw_input == raw_input:upper() and raw_input:match("^[A-Za-z]+$") then
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
    local clean = raw_input:gsub("^%s*(.-)%s*$", "%1"):lower()
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
-- LUA SUBMODULE: \spdate AND \sptime (Optimized LPeg Engine)
-- =========================================================================
local spintent_date_pattern do
    local _ENV = lpeg
    local digit      = R"09"
    local math_space = P"\\," + P"\\;" + P"\\:" + P"\\!" + P"\\>" + P"\\quad" + P"\\qquad"
    local num        = Cs(digit * ((math_space / "")^0 * digit)^0)
    local sep        = S"/-"

    spintent_date_pattern = Ct(
        (Cg(num, "year") * sep * Cg(num, "month") * sep * Cg(num, "day") * P(-1)) +
        (Cg(num, "day") * sep * Cg(num, "month") * sep * Cg(num, "year") * P(-1))
    )
end

register_tex_cmd("luafun_spdate_parse", function(raw_date_input)
    if not raw_date_input then return end
    local clean_str = raw_date_input:gsub("%s+", "")
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

register_tex_cmd("luafun_sptime_parse", function(raw_time_input)
    if not raw_time_input then return end
    local clean_str = raw_time_input:gsub("%s+", "")

    if not clean_str:match("^[%d:]+$") then
        token.set_macro("l__spintent_sptime_luaset_error_str", "true")
        return
    end

    local parts = {}
    for num in clean_str:gmatch("%d+") do
        table.insert(parts, num)
    end

    if #parts < 2 or #parts > 3 then
        token.set_macro("l__spintent_sptime_luaset_error_str", "true")
        return
    end

    local h = tonumber(parts[1])
    local m = tonumber(parts[2])
    local s = parts[3] and tonumber(parts[3]) or nil

    if h >= 24 or m >= 60 then
        token.set_macro("l__spintent_sptime_luaset_error_str", "true")
        return
    end

    if s and s >= 60 then
        token.set_macro("l__spintent_sptime_luaset_error_str", "true")
        return
    end

    token.set_macro("l__spintent_sptime_luaset_error_str", "false")
    token.set_macro("l__spintent_sptime_luaset_base_str", parts[1] .. ":" .. parts[2])

    if #parts == 3 then
        token.set_macro("l__spintent_sptime_luaset_has_seconds_str", "true")
        token.set_macro("l__spintent_sptime_luaset_seconds_str", parts[3])

        if parts[2] == "15" or parts[2] == "30" then
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
-- LUA SUBMODULE: \spsiglo
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
  local chunks = {}
  for _, pair in ipairs(spintent_arab_to_roman_map) do
    while num >= pair[1] do
      table.insert(chunks, pair[2])
      num = num - pair[1]
    end
  end
  return table.concat(chunks)
end

local function spintent_roman_to_arabic(str_roman)
  local total = 0
  local i = 1
  local len = #str_roman

  while i <= len do
    local c1 = str_roman:sub(i, i)
    local v1 = spintent_roman_to_arab_map[c1] or 0

    if i + 1 <= len then
      local c2 = str_roman:sub(i + 1, i + 1)
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
  local clean = raw_siglo_input:gsub("%s+", ""):lower()
  local arabic_val = nil
  local roman_val = nil
  local is_error = false

  if clean:match("^%d+$") then
    arabic_val = tonumber(clean)
    if arabic_val > 0 and arabic_val <= 4000 then
      roman_val = spintent_arabic_to_roman(arabic_val)
    else
      is_error = true
    end
  elseif clean:match("^[ivxlcdm]+$") and clean ~= "" then
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
