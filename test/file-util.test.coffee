chai = require 'chai'
{asyncCatch} = require './common'

{expect} = chai
chai.should()

fileUtil = require '../src/file-util'

describe 'File utils', ->
	describe '.hasBeenModified()', ->
		it 'should return true when at least one input
		    file is newer than at least one output file'

		it 'should return false when all output files are
		    newer than the latest-modified input file'