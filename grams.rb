require "./bootstrap"

class Grams < Sinatra::Base
  get "/posts" do
    params["hub.verify_token"] == Grams::Settings[:instagram_client_secret] ? params["hub.challenge"] : "No thank you"
  end
end
