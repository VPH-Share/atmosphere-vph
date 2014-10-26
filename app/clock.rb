# require 'config/boot'
# require 'config/environment'

require_relative '../config/boot'
require_relative '../config/environment'
require 'atmosphere/clockwork'

module Clockwork
  include Atmopshere::Clockwork

  every(5.minutes, 'cleaning mi loging strategy cache') do
    MiCacheCleanerWorker.perform_async
  end
end