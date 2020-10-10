local p         = premake
local compiledb = p.extensions.compiledb
local m         = { }

compiledb.compile_commands = m

--
-- Generate the global 'compile_commands.json' file
--

function m.generate( wks )
	p.indent( '\t' )

	local prj_it = p.workspace.eachproject( wks )
	local prj    = prj_it()
	local cfg_it = p.project.eachconfig( prj )
	local cfg    = cfg_it()

	for i,file in ipairs( cfg.files ) do
		if( path.isnativefile( file ) ) then
			m.write_file( cfg, file )
		end
	end
end

function m.write_file( cfg, filepath )
	p.push( '{' )
	p.w( '"directory": "%s",', path.getdirectory( filepath ) )
	m.write_arguments( cfg )
	p.pop( '}' )
end

function m.write_arguments( cfg )
	-- TODO: file configs may override flags
	local cppflags = p.tools.gcc.getcppflags( cfg )

	p.push( '"arguments": [' )

	for i=1,#cppflags do
		local line = string.format( '"%s"', cppflags[ i ] )

		-- Add comma for all lines except the last one
		if( i < #cppflags ) then line = line..',' end

		p.w( '%s', line )
	end

	p.pop( ']' )
end
