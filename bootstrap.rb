require "rubygems"
require "bundler"

Bundler.require

require "./grams/settings"
require "./grams/post"

Mongoid.load!("./mongoid.yml")
