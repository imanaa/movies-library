#!/bin/bash
cd c:/workspace/movies-library
export RAILS_ENV=production
bundle exec rake sunspot:solr:run