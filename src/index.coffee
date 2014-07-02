path = require 'path'
fs = require 'fs'

_ = require 'underscore'
deptree = require 'deptree-updater'
async = require 'async'

tree = deptree()

class Coffeestruct
	constructor: ->
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
			tree file
			.dependsOn input...
			.onUpdate (..., async) ->
				action? input, output, async()

hasBeenModified = (output, input) ->
	if _.any (output.map (file) -> not fs.existsSync file)
		return true

	[inputModTimes, outputModTimes] = [
		(fs.statSync(file).mtime.getTime() for file in input)
		(fs.statSync(file).mtime.getTime() for file in output)
	]

	[latestInputTime, earliestOutputTime] = [_.max(inputModTimes), _.min(outputModTimes)]

	latestInputTime > earliestOutputTime

findFilesToUpdate = (task) ->
	files = instance.tasks[task].files
	totalFilesToUpdate = []

	needsUpdate = (output) ->
		if hasBeenModified (tree.dependents output), [output]
			totalFilesToUpdate.push output
			return false

		else return true

	## Figure out which files need updating
	process = (output) ->
		dependencies = tree.dependencies output

		if dependencies.length is 0
			needsUpdate output

		else
			vals = (process file for file in dependencies)
			if _.all vals
				needsUpdate output

	process file for file in files
	totalFilesToUpdate

executeTask = (task, callback) ->
	## Figure out which files need updating
	updateFiles = findFilesToUpdate task
	
	## Perform update
	tree.update updateFiles, triggerTarget: false, callback

# [node, script, argv...] = process.argv
argv = require 'yargs'
.alias 'w', 'watch'
.argv

instance = new Coffeestruct()
(require path.join process.cwd(), "Construct")(instance)

if not argv.watch
	task = argv._[0] ? "main"

	executeTask task, ->
		console.log "Done building"

else
	# Watch files instead
	console.log "Watching..."
	updated = []
	handleUpdate = _.debounce ->
		return if updated.length is 0

		tree.update updated, triggerTarget: false, ->
			updated = []
			console.log "Done building"
	, 500, true

	fs.watch '.', (event, filename) ->
		filename = path.resolve filename
		updated.push filename if not (filename in updated)
		handleUpdate()