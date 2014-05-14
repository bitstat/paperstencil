/*jshint node:true */
module.exports = function( grunt ) {

grunt.loadNpmTasks( 'grunt-contrib-jshint' );
grunt.loadNpmTasks( 'grunt-contrib-connect' );
grunt.loadNpmTasks( 'grunt-contrib-qunit' );
grunt.loadNpmTasks( 'grunt-git-authors' );

var localPort = 8000;

grunt.initConfig({
	jshint: {
		options: {
			jshintrc: '.jshintrc'
		},
		main: [ '*.js' ],
		test: [ 'test/**/*.js' ]
	},
	connect: {
		server: {
			options: {
				port: localPort
			}
		}
	},
	qunit: {
		file: [ 'test/index.html' ],
		http: {
			options: {
				urls: [ 'http://localhost:' + localPort + '/test/index.html' ]
			}
		}
	}
});

grunt.registerTask('test', ['jshint', 'connect', 'qunit']);
grunt.registerTask('default', ['test']);

};
