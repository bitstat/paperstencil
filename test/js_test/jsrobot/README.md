JSRobot
=======
A testing utility for web-apps that can generate real keystrokes rather than simply simulating the JavaScript event firing. This allows the keystroke to trigger the built-in browser behaviour which isn't otherwise possible.

Documentation
-------------
For documentation on how to use JSRobot refer to the [JSRobot website](http://tinymce.ephox.com/jsrobot).

Building
--------
An ant build script is included.  You will need a Java Development Kit installed, plus [Apache Ant](http://ant.apache.org). Running 'ant jar' will build the JSRobot.jar file required to run the tests.  'ant dist' will build a zip distribution.

When deploying you will only need the robot.js and JSRobot.jar files from the root directory (JSRobot.jar is built by ant).

License
-------
Released under the [Apache License Version 2.0](http://github.com/ephox/JSRobot/raw/master/LICENSE).