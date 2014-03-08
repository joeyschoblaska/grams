require "./bootstrap"

task :console do
  binding.pry
end

task :create_subscription do
  lat = ENV["LAT"] || raise("You must supply a LAT")
  lng = ENV["LNG"] || raise("You must supply a LNG")
  radius = ENV["RADIUS"] || raise("You must supply a RADIUS")

  `curl -F 'client_id=#{Grams::Settings[:instagram_client_id]}' \
     -F 'client_secret=#{Grams::Settings[:instagram_client_secret]}' \
     -F 'object=geography' \
     -F 'aspect=media' \
     -F 'verify_token=#{Grams::Settings[:instagram_client_secret]}' \
     -F 'lat=#{lat}' \
     -F 'lng=#{lng}' \
     -F 'radius=#{radius}' \
     -F 'callback_url=#{URI.join(Grams::Settings[:public_url], "/realtime")}' \
     https://api.instagram.com/v1/subscriptions/`
end

task :remove_subscriptions do
  `curl -X DELETE 'https://api.instagram.com/v1/subscriptions?client_secret=#{Grams::Settings[:instagram_client_secret]}&object=all&client_id=#{Grams::Settings[:instagram_client_id]}'`
end

task :delete_old_posts do
  Grams::Post.old.where(:tweeted => false).delete
end

task :update_active_posts do
  Grams::Post.active.each do |post|
    begin
      post.update_from_instagram
    rescue Instagram::BadRequest => e
      puts e.message
      post.destroy
    end
  end
end

task :tweet_most_popular do
  gram = Grams::Post.most_popular

  unless gram.tweeted
    gram.tweet!
    gram.follow_author if gram.original_tweet
  end
end
