# Ruby Application Server Experiments

## How to Test?

First run:

    ./bin/slow-server.rb

This would simulate a slow remote server, which has two possible behaviours,
one for responding very slowly, and another for responding a very large
response. 4M data, to be precise. Then you can run the desired server to be
tested. After you launched the desired server, you can siege it via:

    http://localhost:8080/cpu

which is a CPU bound request.

    http://localhost:8080/latency

which would try to get response from the slow remote server for slow response.

    http://localhost:8080/through

which would try to get response from the slow remote server for large data.

## What Server to Pick?

Thread pool based: (for fast clients (i.e. have nginx or so in front) and
should setup pool size accordingly)

* ./server/zbatery-thread-pool.sh
* ./server/rainbows-thread-pool.sh
* ./server/puma-thread-pool.sh

Thread spawn based: (for fast clients (i.e. have nginx or so in front))

* ./server/zbatery-thread-spawn.sh
* ./server/rainbows-thread-spawn.sh
* ./server/webrick-thread-spawn.sh (not recommended, crashed)

Fiber pool based: (not recommended)

* ./server/zbatery-fiber-pool.sh
* ./server/rainbows-fiber-pool.sh

Fiber spawn based: (not recommended)

* ./server/zbatery-fiber-spawn.sh
* ./server/rainbows-fiber-spawn.sh

EventMachine based: (for slow clients (i.e. no nginx or so in front) and
non-CPU bound apps)

* ./server/rainbows-em.sh
* ./server/zbatery-em.sh
* ./server/thin-em.sh

EventMachine and thread pool based: (for slow clients (i.e. no nginx or so
in front) and should setup pool size accordingly)

* ./server/zbatery-em-thread-pool.sh
* ./server/rainbows-em-thread-pool.sh
* ./server/thin-em-thread-pool.sh

EventMachine and thread spawn based: (for slow clients (i.e. no nginx or so
in front))

* ./server/zbatery-em-thread-spawn.sh
* ./server/rainbows-em-thread-spawn.sh
* ./server/thin-em-thread-spawn.sh (not recommended, weird results)

EventMachine and fiber spawn based: (for slow clients (i.e. no nginx or so
in front) and for non-CPU bound apps)

* ./server/zbatery-em-fiber-spawn.sh
* ./server/rainbows-em-fiber-spawn.sh
* ./server/thin-em-fiber-spawn.sh
