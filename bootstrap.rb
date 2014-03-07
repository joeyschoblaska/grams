require "rubygems"
require "uri"
require "bundler"

Bundler.require

require "./grams/settings"
require "./grams/post"

Mongoid.load!("./mongoid.yml")

Instagram.configure do |config|
  config.client_id = Grams::Settings[:instagram_client_id]
  config.client_secret = Grams::Settings[:instagram_client_secret]
end
