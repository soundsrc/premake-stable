--
-- string.lua
-- Additions to Lua's built-in string functions.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


--
-- Returns true if `haystack` ends with the sequence `needle`.
--

	function string.endswith(haystack, needle)
		if (haystack and needle) then
			local hlen = haystack:len()
			local nlen = needle:len()
			if (hlen >= nlen) then
				return (haystack:sub(-nlen) == needle)
			end
		end
		
		return false
	end
	
	
--
-- Returns an array of strings, each of which is a substring of s
-- formed by splitting on boundaries formed by `pattern`.
-- 

	function string.explode(s, pattern, plain)
		if (pattern == '') then return false end
		local pos = 0
		local arr = { }
		for st,sp in function() return s:find(pattern, pos, plain) end do
			table.insert(arr, s:sub(pos, st-1))
			pos = sp + 1
		end
		table.insert(arr, s:sub(pos))
		return arr
	end
	

--
-- Find the last instance of a pattern in a string.
--

	function string.findlast(s, pattern, plain)
		local curr = 0
		repeat
			local next = s:find(pattern, curr + 1, plain)
			if (next) then curr = next end
		until (not next)
		if (curr > 0) then
			return curr
		end	
	end