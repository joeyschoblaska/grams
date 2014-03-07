require "./bootstrap"

class Grams < Sinatra::Base
  get "/realtime" do
    params["hub.verify_token"] == Grams::Settings[:instagram_client_secret] ? params["hub.challenge"] : "No thank you"
  end

  post "/realtime" do
    JSON.parse(request.body.read).each do |update|
      Grams::Post.create_from_update(update)
    end

    status 200
  end
end
