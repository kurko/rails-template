require 'clockwork'
require './config/boot'
require './config/environment'

# Usage: bundle exec clockwork config/clock.rb
#
# See https://github.com/Rykian/clockwork for documentation.
module Clockwork
  configure do |config|
    config[:logger] = Rails.logger
    config[:tz] = 'UTC'
    config[:thread] = true
  end

  handler do |job|
    puts "[clock] Running #{job}"
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end
  #
  # Examples:
  # every(1.hour, 'heartbeat.job') { do_something }
  # every(1.day, 'midnight.job', :at => '00:00', tz: 'UTC')
end
