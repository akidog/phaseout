require 'redis'
require 'redis-namespace'

require 'phaseout/version'
require 'phaseout/engine'
require 'phaseout/seo_action'
require 'phaseout/seo_fields'
require 'phaseout/seo_helper'
require 'phaseout/seo'
require 'phaseout/handler'

module Phaseout
  def self.config_redis(connection, namespace = :phaseout)
    @redis = Redis::Namespace.new namespace, redis: connection
  end

  def self.redis
    @redis ||= config_redis(Redis.new)
  end

  def self.default_fields
    @default_fields ||= ::Phaseout::SEOHelper.instance_methods + [:other]
  end
end

ActiveSupport.on_load(:action_view){ include Phaseout::SEOHelper }
