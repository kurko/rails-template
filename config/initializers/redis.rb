$redis = Redis.new(url: "#{ENV["REDIS_URL"]}#{ENV.fetch("REDIS_DB")}")