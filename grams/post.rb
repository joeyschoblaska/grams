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
            :thumbnail => post["images"]["thumbnail"]["url"],
            :username => post["user"]["username"],
            :caption => post["caption"]["text"],
            :created_at => Time.now,
            :tweeted => false
          })
        end
      end
    end

    def self.old
      where(:created_at => {"$lt" => Time.now - Grams::Settings[:max_post_age]})
    end

    def self.active
      where(:created_at => {"$gt" => Time.now - Grams::Settings[:max_post_age]})
    end

    def self.most_popular
      order_by("likes DESC").first
    end

    def instagram_data
      @instagram_data ||= Instagram.media_item(instagram_id)
    end

    def update_from_instagram
      update_attributes({
        :link => instagram_data["link"],
        :likes => instagram_data["likes"]["count"],
        :thumbnail => instagram_data["images"]["thumbnail"]["url"],
        :username => instagram_data["user"]["username"],
        :caption => instagram_data["caption"]["text"]
      })
    end
  end
end
