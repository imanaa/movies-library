#!/bin/bash
cd c:/workspace/movies-library
rm tmp/pids/server.pid
export RAILS_ENV=development
rails server