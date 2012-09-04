#!/bin/sh

httperf --hog --server localhost --port 8080 --uri /cpu --num-calls 4 --burst-length 2 --num-conn 2 --rate 8 --print-reply
