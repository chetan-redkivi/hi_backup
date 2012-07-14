if url = ENV["REDISTOGO_URL"]
  uri = URI.parse(url)
  Rails.logger.info("Configured Redis with url #{url}")
  $redis = REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  Redis.current = REDIS
elsif Rails.env.development? or Rails.env.test?
  Redis.current = Redis.new
else
  Rails.logger.error "Failed to initialize Redis as REDISTOGO_URL is missing!"
end
