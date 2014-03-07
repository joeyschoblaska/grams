class Grams < Sinatra::Base
  class Post
    include Mongoid::Document

    def self.create_from_update(update)
      Instagram.geography_recent_media(update["object_id"]).each do |post|
        unless where(:instagram_id => post["id"]).first
          create!({
            :instagram_id => post["id"],
            :link => post["link"],
            :likes => post["likes"]["count"]
          })
        end
      end
    end
  end
end
