local p         = premake
local compiledb = p.extensions.compiledb
local m         = { }

compiledb.compile_commands = m

--
-- Generate the global 'compile_commands.json' file
--

function m.generate( wks )
	p.indent( '\t' )
end

