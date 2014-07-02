path = require 'path'

_ = require 'underscore'
deptree = require 'deptree-updater'

{hasBeenModified} = require './file-util'

class exports.Coffeestruct
	constructor: ->
		@tree = deptree()
		@tasks = {}

	task: (name, params) ->
		files = ([].concat params.files).map (f) -> path.resolve f

		@tasks[name] =
			name: name
			files: files
			action: params.action

	file: (output, input, action) ->
		output = ([].concat output).map (f) -> path.resolve f
		input = ([].concat input).map (f) -> path.resolve f

		for file in output
			@tree file
			.dependsOn input...
			.onUpdate (..., async) ->
				action? input, output, async()


exports.findFilesToUpdate = (instance, task) ->
	files = instance.tasks[task].files
	totalFilesToUpdate = []

	needsUpdate = (output) ->
		if hasBeenModified (instance.tree.dependents output), [output]
			totalFilesToUpdate.push output
			return false

		else return true

	## Figure out which files need updating
	process = (output) ->
		dependencies = instance.tree.dependencies output

		if dependencies.length is 0
			needsUpdate output

		else
			vals = (process file for file in dependencies)
			if _.all vals
				needsUpdate output

	process file for file in files
	totalFilesToUpdate

exports.executeTask = (instance, task, callback) ->
	## Figure out which files need updating
	updateFiles = exports.findFilesToUpdate instance, task
	
	## Perform update
	instance.tree.update updateFiles, triggerTarget: false, callback