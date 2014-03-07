class Grams < Sinatra::Base
  Settings = {
    :post_window => 60*60*24*2 # 48 hours
  }
end
