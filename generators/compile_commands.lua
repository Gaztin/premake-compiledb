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

	p.push( '[' )

	for i=1,#cfg.files do
		local file = cfg.files[ i ]

		if( path.isnativefile( file ) ) then
			p.push( '{' )
			m.write_file( cfg, file )

			if( i == #cfg.files ) then
				p.pop( '}' )
			else
				p.pop( '},' )
			end
		end
	end

	p.pop( ']' )
end

function m.write_file( cfg, filepath )
	local directory = path.getdirectory( filepath )
	local basename  = path.getbasename( filepath )
	local output    = path.join( cfg.buildtarget.directory, basename..'.o' )

	p.w( '"file": "%s",', filepath )
	p.w( '"directory": "%s",', directory )
	p.w( '"output": "%s",', output )
	m.write_arguments( cfg )
end

function m.write_arguments( cfg )
	local compiler      = iif( p.project.isc( cfg.project ), 'gcc', 'g++' )
	-- TODO: file configs may override flags
	local cxxflags      = p.tools.gcc.getcxxflags( cfg )
	local defines       = p.tools.gcc.getdefines( cfg.defines )
	local undefines     = p.tools.gcc.getundefines( cfg.undefines )
	local forceincludes = p.tools.gcc.getforceincludes( cfg )
	local includedirs   = p.tools.gcc.getincludedirs( cfg, cfg.includedirs, cfg.sysincludedirs )
	local ldflags       = p.tools.gcc.getldflags( cfg )
	local libdirs       = p.tools.gcc.getLibraryDirectories( cfg )
	local links         = p.tools.gcc.getlinks( cfg, false, false )
	local arguments     = table.unique( table.join( compiler, cxxflags, defines, undefines, forceincludes, includedirs, ldflags, libdirs, links ) )

	p.push( '"arguments": [' )

	for i=1,#arguments do
		local line = string.format( '"%s"', arguments[ i ] )

		-- Add comma for all lines except the last one
		if( i < #arguments ) then line = line..',' end

		p.w( '%s', line )
	end

	p.pop( ']' )
end
