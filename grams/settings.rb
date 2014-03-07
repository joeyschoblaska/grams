class Grams < Sinatra::Base
  yaml = File.exists?("./settings.yml") ? YAML.load_file("./settings.yml") : {}

  Settings = {
    :post_window => 60*60*24*2, # 48 hours
    :mongohq_url => yaml["mongohq_url"] || ENV["MONGOHQ_URL"]
  }
end
