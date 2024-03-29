module.exports = (grunt) ->

	require('load-grunt-tasks')(grunt)

	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		
		coffee:
			build:
				expand: yes
				cwd: 'src/'
				src: '**/*.coffee'
				dest: 'lib/'
				ext: '.js'

		coffeelint:
			build:
				files: src: [
					'Gruntfile.coffee'
					'src/**/*.coffee', 'test/**/*.coffee'
				]

			options:
				no_tabs:
					level: 'ignore' # this is tab land, boy
				indentation:
					value: 1 # single tabs
				no_unnecessary_double_quotes:
					level: 'error' # single-quotes only unless necessary

		mochaTest:
			test:
				options:
					reporter: 'spec'
					require: ['coffee-script/register']

				src: ['test/**/*.test.{js,coffee}']

		watch:
			dev:
				files: ['src/**/*.{js,coffee}', 'test/**/*.{js,coffee}']
				tasks: ['lint', 'test', 'build']

			test:
				files: ['src/**/*.{js,coffee}', 'test/**/*.{js,coffee}']
				tasks: ['test']

			lint:
				files: ['src/**/*.{js,coffee}', 'test/**/*.{js,coffee}']
				tasks: ['lint']

	grunt.registerTask 'default', ['lint', 'test', 'build']

	grunt.registerTask 'build', ['coffee:build']

	grunt.registerTask 'lint', ['coffeelint:build']

	grunt.registerTask 'test', ['mochaTest:test']

	grunt.registerTask 'watch-dev', ['watch:dev']