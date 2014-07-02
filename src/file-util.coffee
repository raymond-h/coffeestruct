_ = require 'underscore'

exports.hasBeenModified = (output, input) ->
	if _.any (output.map (file) -> not fs.existsSync file)
		return true

	[inputModTimes, outputModTimes] = [
		(fs.statSync(file).mtime.getTime() for file in input)
		(fs.statSync(file).mtime.getTime() for file in output)
	]

	[latestInputTime, earliestOutputTime] = [
		_.max(inputModTimes)
		_.min(outputModTimes)
	]

	latestInputTime > earliestOutputTime