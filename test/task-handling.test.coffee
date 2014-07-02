chai = require 'chai'
{asyncCatch} = require './common'

{expect} = chai
chai.should()

taskHandling = require '../src/task-handling'

describe 'Coffeestruct (task handling)', ->