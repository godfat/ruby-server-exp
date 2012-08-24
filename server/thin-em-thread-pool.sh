#!/bin/sh

thin -e none -p 8080 -t 30 --max-conns 64 start -r ./config/thin-em-thread-pool --threaded
