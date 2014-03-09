class Grams < Sinatra::Base
  class Post
    include Mongoid::Document
    include Mongoid::Timestamps

    field :instagram_id, :type => String
    field :link, :type => String
    field :likes, :type => Integer
    field :captin, :type => String
    field :tweeted, :type => Boolean

    attr_accessible :instagram_data

    def initialize(instagram_data)
      @instagram_data = instagram_data
    end

    def self.create_from_update(update)
      Instagram.geography_recent_media(update["object_id"]).each do |instagram_data|
        post = Grams::Post.new(instagram_data)

        if !where(:instagram_id => instagram_data["id"]).first && post.location_id && post.location_in_bounds? && post.active_location?
          post.instagram_id = instagram_data["id"]
          post.link = instagram_data["link"]
          post.likes = instagram_data["likes"]["count"]
          post.caption = instagram_data["caption"].try(:[], "text")
          post.tweeted = false

          post.save!
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
        if caption && caption.length > 115
          message << "\"#{caption[0,112]}...\" "
        elsif caption
          message << "\"#{caption}\" "
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

    def active_location?
      posts = Instagram.location_recent_media(location_id)
      posts.select{|p| p["user"]["username"]}.uniq.count > 1
    end

    def location_id
      instagram_data["location"]["id"]
    end

    def location_in_bounds?
      location = Geometry::Point.new(instagram_data["location"]["longitude"], instagram_data["location"]["latitude"])
      Grams::Settings[:neighborhood].contains?(location)
    end
  end
end
