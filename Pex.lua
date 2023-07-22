--[[

Module: Pex.lua
Written by: math-rad
Version: 1.2
Description: A lexing module. Some purposes of this module could be lexing code, identifying chat commands,  and more.
	- Whitespace is ignored unless it is contained within a string
	- Brackets store tokens instead of strings
		- Their type is specified in the third element of their token
	- Token: [ tokenString/bracketTokens, tokenType, (bracketType) ]
	
Version Notes: The first version, 1.1, had recursively tokenized brackets. As it was inefficent, I optimized it to only 'read' once.   

This is still a WIP.

]]

local Pex = {}
local LEXER = {}

LEXER.__index = LEXER
Pex.__lexer = LEXER

local insert, split = table.insert, string.split

local cache_GCMode = {
	["__mode"] = "kv"
}

local errorTemplate = "Pex error: %s; line: %s;"


local bracketMap = {
	['('] = ')',
	[')'] = '(',
	['['] = ']',
	[']'] = '[',
	['{'] = '}',
	['}'] = '{',
	['<'] = '>',  -- Support for angle brackets. to implement, update the bracket list in the configurations
	['>'] = '<'
}
local bracketTypes = {
	[')'] = "round",
	['('] = "round",
	[']'] = "square",
	['['] = "square",
	['}'] = "curly",
	['{'] = "curly",
	['>'] = "angle",
	['<'] = "angle",
}

local numberNotationSymbols = {
	['e'] = "scientific",
	['E'] = "scientific",
	['x'] = "hexadecimal",
	['X'] = "hexadecimal",
	['b'] = "binary",
	['B'] = "binary",
	['.'] = "decimal"
}

local characterMap = {}

(function(types)
	for characterType, characters in types do
		for _, character in characters:split('') do
			characterMap[character] = characterType
		end
	end
end)({
	["whitespace"] = " \t\n\v\r\f",
	["alphabetic"] = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz_", -- For simplicity, '_' is regarded as alphabetic
	["numeric"] = "0123456789",
	["operator"] = "=<>+-*/%^!",
	["special"] = "$#@&~?",
	["openBracket"] = "([{",
	["closedBracket"] = ")]}",
	["quote"] = "\"'`",
	["separator"] = ".,;",
});


local function IsAlphanumeric(character: string)
	return (characterMap[character] == "alphabetical") or (characterMap[character] == "numeric")
end

function LEXER:evaluateToken(token: string)
	return ""
end

function LEXER:lex(input: string)
	local tokens = {} 
	local currentToken = ""
	local tokenIndex = 0

	local currentBracket 
	local correspondingBracket
	local currentBracketType 


	local currentQuote


	local inBracket = false
	local inString = false

	local hasNumbers = false
	local hasLetters = false
	local isAlphanumeric = false
	local isIdentifier = false
	local startedWithNumber = false
	local startedWithLetter = false


	local isFloating = false
	local isHexadecimal = false
	local isBinary = false
	local isScientific = false

	local numberNotation

	local new = true

	local currentLine = 1 

	local function clearTokenFlags()
		inString = false
		hasNumbers = false
		hasLetters = false
		isAlphanumeric = false
		isIdentifier = false
		startedWithNumber = false
		startedWithLetter = false

		new = true

		currentQuote = nil

		numberNotation = nil

		tokenIndex = 0

	end

	local function putToken(Type, ...)
		if currentToken == '' then
			return
		end
		insert(tokens, {currentToken, Type or self:evaluateToken(currentToken), ...})
		currentToken = ''
		clearTokenFlags()
	end

	for index, character: string in split(input, '') do
		tokenIndex += 1
		if character == "\n" then
			currentLine += 1
		end
		local characterType : "whitespace" | "alphabetic" | "numeric" | "operator" | "special" | "openBracket" | "closedBracket" | "quote" | "separator" = characterMap[character]

		if new then
			if characterType == "alphabetic" then
				startedWithLetter = true
			elseif characterType == "numeric" then
				startedWithNumber = true
			end
		end

		if characterType == "alphabetic" then
			hasLetters = true
		elseif characterType == "numeric" then
			hasNumbers = true
		end

		if hasLetters and hasNumbers then
			isAlphanumeric = true 
		end

		local CharacterIsAlphanumeric = IsAlphanumeric(character)

		if inString then
			if character ~= currentQuote then
				currentToken ..= character
				continue
			else
				putToken("string")
				continue
			end
		elseif inBracket then
			if characterType == "openBracket" then
				putToken()
				tokens = {
					["parent"] = tokens,
					["previousBracketType"] = currentBracketType
				}
				currentBracketType = bracketTypes[character]
				continue
			elseif characterType == "closedBracket" then
				putToken()
				local bracketType = bracketTypes[character]

				if bracketType == currentBracketType then
					local parent, previousBracketType = tokens.parent, tokens.previousBracketType
					tokens.parent = nil
					tokens.previousBracketType = nil
					insert(parent, {tokens, "bracket", currentBracketType})
					tokens = parent 
					currentBracketType = previousBracketType
					inBracket = currentBracketType ~= nil
					continue
				else
					return {
						["error"] = string.format(errorTemplate, "Expected bracket to end", currentLine)
					}
				end
			end
		end 
		if characterType == "quote" then
			currentQuote = character
			putToken()
			inString = true 
			continue
		elseif characterType == "openBracket" then
			putToken()
			inBracket = true
			currentBracketType = bracketTypes[character]
			tokens = {
				["parent"] = tokens,
			}
			continue
		elseif characterType == "whitespace" then
			local lastCharacterType = characterMap[input:sub(index - 1, index - 1)]
			if lastCharacterType ~= "whitespace" then
				putToken()
				continue
			end
			continue
		else
			local lastCharacter, nextCharacter = input:sub(index - 1, index - 1), input:sub(index + 1, index + 1)
			local lastCharacterType, nextCharactertype = characterMap[lastCharacter], characterMap[nextCharacter]
			if characterType == lastCharacterType then
				if lastCharacterType == "separator" and characterType == "separator" and lastCharacter ~= character then
					putToken()
					currentToken = character
					continue
				end
				currentToken ..= character
				continue
			else
				if isAlphanumeric and CharacterIsAlphanumeric then
					if isIdentifier then
						currentToken ..= character
						continue
					elseif not isIdentifier then
						if startedWithLetter then
							isIdentifier = true
							currentToken ..= character
							continue
						else
							putToken()
							currentToken = character
						end
					end
				elseif characterType == "numeric" then
					if numberNotationSymbols[lastCharacter] then
						currentToken ..= character
						continue
					else
						putToken()
						currentToken = character

					end
				elseif character == '.' and new and nextCharactertype == "numeric" then
					numberNotation = "floating"
					currentToken ..= character
					continue
				elseif characterType == "operator" then
					
				elseif  (lastCharacterType == "numeric") and (nextCharactertype == "numeric") and numberNotationSymbols[character] then
					numberNotation = numberNotationSymbols[character]
					if numberNotation then
						print(numberNotation)
					end
					if numberNotation == "binary" and currentToken:sub(1, 1) ~= '0' then
						return {
							["error"] = string.format(errorTemplate, "malformed binary", currentLine)
						}
					end
					currentToken ..= character
					continue
				else
					putToken()
					currentToken = character
					continue
				end

			end


		end
	end

	putToken()

	return tokens 
end


function Pex:new(config)

	return setmetatable({
		["config"] = config,
		["cache"] = setmetatable({}, cache_GCMode)
	}, self.__lexer :: typeof(Pex.__lexer))
end

return Pex
