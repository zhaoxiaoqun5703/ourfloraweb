#!/bin/bash
# This scripts watches the directories ./coffeescript and ./scss and compiles them into
# ./js and ./css respectively.

# Kill the currently running compilers for this directory
kill `cat pids/sass.pid`
kill `cat pids/coffee.pid`

# Use npm's sass to watch for changes to the ./scss folder and compile into the ./css folder
sass --watch scss:css &
# Save the pid of the sass watch seeing as it's running in the background and we might want to kill / restart it later
echo $! > pids/sass.pid

# Use npm's coffee to watch for changes to the ./coffeescript folder and compile into the ./js folder
coffee --watch --compile --output ./js ./coffeescript &
# Save the pid of the coffee seeing as it's running in the background and we might want to kill / restart it later
echo $! > pids/coffee.pid