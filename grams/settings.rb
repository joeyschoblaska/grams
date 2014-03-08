class Grams < Sinatra::Base
  yaml = File.exists?("./settings.yml") ? YAML.load_file("./settings.yml") : {}

  Settings = Hash.new.tap do |settings|
    %w(public_url mongohq_url instagram_client_id instagram_client_secret).each do |key|
      settings[key.to_sym] = yaml[key] || ENV[key.upcase]
    end

    settings[:max_post_age] = 60*60*24*2 # 48 hours

    points = [
      [-87.73131, 41.93146],
      [-87.68792, 41.93187],
      [-87.68728, 41.91392],
      [-87.72187, 41.91325]
    ]

    points.map!{|p| Geometry::Point.new(*p)}

    settings[:neighborhood] = Geometry::Polygon.new(points)
  end
end
