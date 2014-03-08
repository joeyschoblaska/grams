class Grams < Sinatra::Base
  class Post
    include Mongoid::Document

    def self.create_from_update(update)
      Instagram.geography_recent_media(update["object_id"]).each do |post|
        location = Geometry::Point.new(post["location"]["longitude"], post["location"]["latitude"])

        if !where(:instagram_id => post["id"]).first && Grams::Settings[:neighborhood].contains?(location) && post["location"]["id"]
          create!({
            :instagram_id => post["id"],
            :link => post["link"],
            :likes => post["likes"]["count"],
            :username => post["user"]["username"],
            :caption => post["caption"].try(:[], "text"),
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
      active.order_by("likes DESC").first
    end

    def instagram_data
      @instagram_data ||= Instagram.media_item(instagram_id)
    end

    def update_from_instagram
      update_attributes({
        :link => instagram_data["link"],
        :likes => instagram_data["likes"]["count"],
        :username => instagram_data["user"]["username"],
        :caption => instagram_data["caption"].try(:[], "text")
      })
    end

    def twitter_client
      @twitter_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = Grams::Settings[:twitter_api_key]
        config.consumer_secret     = Grams::Settings[:twitter_api_secret]
        config.access_token        = Grams::Settings[:twitter_access_token]
        config.access_token_secret = Grams::Settings[:twitter_access_token_secret]
      end
    end

    def tweets_mentioning_link
      twitter_client.search(link, :result_type => "recent")
    end

    def original_tweet
      tweets_mentioning_link.sort_by{|t| t.id}.first
    end

    def twitter_message
      "".tap do |message|
        if caption
          caption.gsub!(/\s#\w+/, "")
          if caption.length > 115
            message << "\"#{caption[0,112]}...\" "
          else
            message << "\"#{caption}\" "
          end
        end

        message << link
      end
    end

    def tweet!
      if original_tweet
        twitter_client.retweet(original_tweet)
      else
        twitter_client.update(twitter_message)
      end

      update_attribute :tweeted, true
    end

    def follow_author
      twitter_client.follow(original_tweet.try(:user))
    end
  end
end
