--[[
started on 7/17/2023

]]

local util = require(script.utility)

local pex = {}

local READER = {}




local patterns = {
	["arithmetic"] = "[%+%-*/%^]",
	["separator"] = "[%.,;]"
}

local bracketMapping = {
	["("] = ")",
	["["] = "]",
	["{"] = "}",
}

local bracketTypes = {
	[")"] = "round",
	["]"] = "square",
	["}"] = "curly"
}


local charMap = {}
local function mapType(Type, characters: string)
	for character in characters:gmatch(".") do
		charMap[character] = Type
	end
end
-- alphabeticish, for simplicity im going to label it as that and see _ as a part of the alphabet 
mapType("ws", " \t\n\v\r\f")
mapType("alphabetic", "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz_") 
mapType("numeric", "0123456789")
mapType("separation", ".,;")
mapType("operation", "<>=+-/*%^")
mapType("special", "$#@&~?!")

mapType("ob", "({[")
mapType("cb", ")}]")
mapType("q", "\"'")


function READER:evaluateToken(token: string)

end



function READER:read(tokenString: string)
	tokenString = util.superString(tokenString)
	local tokens = util.tlr({})
	local currentToken = ""
	local currentBracket = ""
	local bracketCount = 0
	
	local inBracket = false
	local inString = false

	local hasNumbers = false
	local hasLetters = false
	local isFloating = false
	local isIdentifier = false
	local isAlphanumeric = false 
	local startedWithNumber = false
	local startedWithLetter = false


	local new = true

	local function clearFlags()
		inBracket = false
		inString = false
		hasNumbers = false
		hasLetters = false
		isFloating = false
		isAlphanumeric = false
		isIdentifier = false
		startedWithNumber = false 
		startedWithLetter = false
		new = true
	end
	

	
	local function addToken(token)
		if token[1] == "" then
			return
		end
		tokens:insert(token)
	end

	local function appendToken(c)
		
		currentToken ..= c 
	end

	local function endToken(tokenType, ...)
		addToken{currentToken, tokenType, ...}
		currentToken = ''
		clearFlags()
	end

	local function newToken(c, Type)
		if c == "}" then
			--print(debug.traceback())
		end
		addToken{currentToken, Type}
		currentToken = c 
		clearFlags()
		
	end

	local function finishToken(c, tokenType, ...)
		addToken{ currentToken .. c, tokenType, ...}
		currentToken = ''
		clearFlags()
	end



	local correspondingBracket
	local currentQuote
	
	local characterPosition = 0
	for character in tokenString:gmatch('.') do
		characterPosition += 1

		local lastCharacter, nextCharacter = tokenString[characterPosition - 1], tokenString[characterPosition + 1]
		local lastCharacterType, nextCharacterType = charMap[lastCharacter], charMap[nextCharacter]

		local characterType = charMap[character]
		--print("\n", character, characterType, lastCharacter, lastCharacterType)
		if inString then
			if character == currentQuote then
				endToken("string")
				currentQuote = nil
				continue
			else
				appendToken(character)
				continue
			end
		elseif inBracket then
			
			if character == currentBracket then
				bracketCount += 1
				appendToken(character)
				continue
			elseif character == correspondingBracket then
				bracketCount -= 1
				if bracketCount == 0 then
					endToken("bracket", self:read(currentToken), bracketTypes[correspondingBracket])
					correspondingBracket = nil
					currentBracket = nil
				else
					appendToken(character)
					continue
				end
			else
				appendToken(character)
				continue
			end
			
			
		elseif characterType == "q" then
			currentQuote = character
			endToken()
			inString = true
			continue
		elseif characterType == "ob" then
			currentBracket = character
			correspondingBracket = bracketMapping[character]
			bracketCount = 1
			endToken()
			inBracket = true
			continue
		else
			if characterType == "ws" then
				if lastCharacterType ~= "ws" then
					endToken()
					continue
				end
				continue
			end
			if new then
				if characterType == "numeric" then
					startedWithNumber = true
				elseif characterType == "alphabetic" then
					startedWithLetter = true
				end
				new = false
			end

			if characterType == "numeric" then
				hasNumbers = true
			end

			if characterType == "alphabetic" then
				hasLetters = true
			end

			if lastCharacterType == characterType then
				appendToken(character)
				continue
			else
				if isIdentifier and (characterType == "numeric") or (characterType == "alphabetic")  then
					if (lastCharacterType ~= "alphabetic") and (lastCharacterType ~= "numeric") and (lastCharacter ~= ".") then
						newToken(character)
						continue
					end
					appendToken(character)
					continue
				elseif (character == ".") and (lastCharacterType == nextCharacterType) and (lastCharacterType == "numeric") then
					
					if isFloating or hasLetters then
						finishToken(character, "?")
						continue
					end
					isFloating = true
					appendToken(character)
				elseif (characterType == "alphabetic") or (characterType == "numeric") then
					if (lastCharacterType ~= "alphabetic") and (lastCharacterType ~= "numeric") and (lastCharacter ~= ".") then
						newToken(character)
						continue
					end
					if hasLetters and hasNumbers then
						if startedWithNumber then
							finishToken(character, "?")
							continue
						end
						isIdentifier = true
					end
					appendToken(character)
					continue
				else
					newToken(character)
				end

			end
		end

	end
	
	endToken()
	
	return tokens


end

READER.__index = READER

function pex.new()
	return setmetatable({},  READER)
end


return pex	
--"[%a_][%w_]*"
