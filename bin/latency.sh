#!/bin/sh

httperf --hog --server localhost --port 8080 --uri /latency --num-calls 4 --burst-length 2 --num-conn 50 --rate 100 --timeout 60
