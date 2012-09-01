#!/bin/sh

httperf --server localhost --port 8080 --uri /through --rate 25 --num-conn 50 --num-call 2 --timeout 60
