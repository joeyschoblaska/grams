class Grams < Sinatra::Base
  yaml = File.exists?("./settings.yml") ? YAML.load_file("./settings.yml") : {}

  Settings = Hash.new.tap do |settings|
    %w(public_url mongohq_url instagram_client_id instagram_client_secret).each do |key|
      settings[key.to_sym] = yaml[key] || ENV[key.upcase]
    end

    settings[:post_window] = 60*60*24*2 # 48 hours
  end
end
