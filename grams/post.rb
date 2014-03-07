class Grams < Sinatra::Base
  class Post
    include Mongoid::Document

    def self.create_from_update(update)
      Instagram.geography_recent_media(update["object_id"]).each do |post|
        location = Geometry::Point.new(post["location"]["longitude"], post["location"]["latitude"])

        if !where(:instagram_id => post["id"]).first && Grams::Settings[:neighborhood].contains?(location)
          create!({
            :instagram_id => post["id"],
            :link => post["link"],
            :likes => post["likes"]["count"],
            :username => post["user"]["username"],
            :created_at => Time.now,
            :tweeted => false
          })
        end
      end
    end

    def self.old
      where(:created_at => {"$lt" => Time.now - Grams::Settings[:post_window]})
    end

    def self.active
      where(:created_at => {"$gt" => Time.now - Grams::Settings[:post_window]})
    end

    def self.most_popular
      order_by("likes DESC").first
    end

    def update_from_instagram
      data = Instagram.media_item(instagram_id)

      update_attributes({
        :link => data["link"],
        :likes => data["likes"]["count"],
        :username => data["user"]["username"]
      })
    end
  end
end
