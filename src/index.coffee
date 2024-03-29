path = require 'path'
fs = require 'fs'

require 'coffee-script/register'
_ = require 'underscore'

{Coffeestruct} = require './task-handling'

argv = require 'yargs'
	.alias 'w', 'watch'
	.argv

instance = new Coffeestruct()
(require path.join process.cwd(), 'Construct')(instance)

if not argv.watch
	task = argv._[0] ? 'main'

	instance.executeTask task, ->
		console.log 'Done building'

else
	# Watch files instead
	console.log 'Watching...'
	updated = []
	handleUpdate = _.debounce ->
		return if updated.length is 0

		instance.tree.update updated, triggerTarget: false, ->
			updated = []
			console.log 'Done building'
	, 500, true

	fs.watch '.', (event, filename) ->
		filename = path.resolve filename
		updated.push filename if not (filename in updated)
		handleUpdate()