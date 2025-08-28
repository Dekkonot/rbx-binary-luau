local exhaustive = require("../exhaustive")

export type FontWeight =
	"Thin"
	| "ExtraLight"
	| "Light"
	| "Regular"
	| "Medium"
	| "SemiBold"
	| "Bold"
	| "ExtraBold"
	| "Heavy"

export type FontStyle = "Normal" | "Italic"

local DEFAULT_WEIGHT: FontWeight = "Regular"
local DEFAULT_STYLE: FontStyle = "Normal"

local function weight_from_value(value: number): FontWeight
	if value == 100 then
		return "Thin"
	elseif value == 200 then
		return "ExtraLight"
	elseif value == 300 then
		return "Light"
	elseif value == 400 then
		return "Regular"
	elseif value == 500 then
		return "Medium"
	elseif value == 600 then
		return "SemiBold"
	elseif value == 700 then
		return "Bold"
	elseif value == 800 then
		return "ExtraBold"
	elseif value == 900 then
		return "Heavy"
	else
		error(`the provided value {value} does not correspond to any FontWeight`)
	end
end

local function weight_to_value(weight: FontWeight): number
	if weight == "Thin" then
		return 100
	elseif weight == "ExtraLight" then
		return 200
	elseif weight == "Light" then
		return 300
	elseif weight == "Regular" then
		return 400
	elseif weight == "Medium" then
		return 500
	elseif weight == "SemiBold" then
		return 600
	elseif weight == "Bold" then
		return 700
	elseif weight == "ExtraBold" then
		return 800
	elseif weight == "Heavy" then
		return 900
	else
		return exhaustive(weight, `unknown FontWeight {weight}`)
	end
end

local function style_from_value(value: number): FontStyle?
	if value == 0 then
		return "Normal"
	elseif value == 1 then
		return "Italic"
	else
		return nil
	end
end

local function style_to_value(style: FontStyle): number
	if style == "Normal" then
		return 0
	elseif style == "Italic" then
		return 1
	else
		return exhaustive(style, `unknown FontStyle {style}`)
	end
end

return {
	DEFAULT_WEIGHT = DEFAULT_WEIGHT,
	DEFAULT_STYLE = DEFAULT_STYLE,
	weight_from_value = weight_from_value,
	weight_to_value = weight_to_value,
	style_from_value = style_from_value,
	style_to_value = style_to_value,
}
