require "rubygems"
require "bundler"

Bundler.require

Mongoid.load!("./mongoid.yml")

require "./grams/settings"
require "./grams/post"
