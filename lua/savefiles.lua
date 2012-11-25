
module ( "savefiles", package.seeall )

----------------------------------------------------------------
----------------------------------------------------------------
-- variables
----------------------------------------------------------------
local saveFiles = {}

----------------------------------------------------------------
-- exposed functions
----------------------------------------------------------------
function get ( filename )

	if not saveFiles [ filename ] then
		saveFiles [ filename ] = makeSaveFile ( filename ) 
		saveFiles [ filename ]:loadGame ()
	end	
	
	return saveFiles [ filename ]
end

----------------------------------------------------------------
-- local functions
----------------------------------------------------------------
function makeSaveFile ( filename )

	local savefile = {}
	
	savefile.filename = filename
	savefile.fileexist = false
	savefile.data = nil
	
	----------------------------------------------------------------
	savefile.loadGame = function ( self )

		local fullFileName = self.filename .. ".lua"
		local workingDir
        print('moai env dir', MOAIEnvironment.documentDirectory)
		workingDir = MOAIFileSystem.getWorkingDirectory ()
		MOAIFileSystem.setWorkingDirectory ( MOAIEnvironment.documentDirectory )

        --fullFileName = '/data/data/com.getmoai.samples/files/gameSave.lua'
        local fhand = io.open(fullFileName)
        if fhand ~= nil then
            print('readdata:',fhand:read("*all"), '-------------------')
        else
            print('nil file!!!!!!!!11')
        end

		if MOAIFileSystem.checkFileExists ( fullFileName ) then
            print('loading existing savefile')
			local file = io.open ( fullFileName, 'rb' )
			savefile.data = dofile ( fullFileName )
			self.fileexist = true
		else
            print('new savefile')
			savefile.data = {}
			self.fileexist = false
		end

		MOAIFileSystem.setWorkingDirectory ( workingDir )
		
		return self.fileexist
	end
	
	----------------------------------------------------------------
	savefile.saveGame = function ( self )

		local fullFileName = self.filename .. ".lua"
		local workingDir
		local serializer = MOAISerializer.new ()

		self.fileexist = true
		serializer:serialize ( self.data )
		local gamestateStr = serializer:exportToString ()
		print(MOAIEnvironment.documentDirectory, '.....', MOAIFileSystem.getWorkingDirectory () )
        print('saving:',gamestateStr)
		
		workingDir = MOAIFileSystem.getWorkingDirectory () 
		MOAIFileSystem.setWorkingDirectory ( MOAIEnvironment.documentDirectory )

		local file = io.open ( fullFileName, 'wb' )
		file:write ( gamestateStr )
		file:close ()
        print('fildata', io.open(fullFileName):read("*all") ,'-------------------')
		MOAIFileSystem.setWorkingDirectory ( workingDir )
	end

	return savefile
end

--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================


