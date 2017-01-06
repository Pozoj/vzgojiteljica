# frozen_string_literal: true
class Rack::Attack
end

# Always allow requests from localhost
# (blacklist & throttles are skipped)
# Rack::Attack.whitelist('allow from localhost') do |req|
#   # Requests are allowed if the return value is truthy
#   '127.0.0.1' == req.ip || '::1' == req.ip
# end

Rack::Attack.blacklist('block blacklisted') do |req|
  (ENV['BLACKLISTED_IPS'] || '').split(',').include?(req.ip)
end

# Throttle requests to 5 requests per second per ip
# Rack::Attack.throttle('req/ip', :limit => 2, :period => 1.second) do |req|
#   # If the return value is truthy, the cache key for the return value
#   # is incremented and compared with the limit. In this case:
#   #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
#   #
#   # If falsy, the cache key is neither incremented nor checked.

#   req.ip
# end

# Throttle search attempts to 1 request every 2 seconds
Rack::Attack.throttle('articles/search', limit: 1, period: 2.seconds) do |req|
  req.ip if req.path == '/clanki/isci'
end
