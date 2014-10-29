$redis_uri = ENV["REDISTOGO_URL"].present? ? URI.parse(ENV["REDISTOGO_URL"]) : nil
$redis = Redis::Namespace.new("nfl_draft", :redis => Redis.new(:url => $redis_uri))