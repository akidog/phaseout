require 'redis'
require 'redis-namespace'

require 'phaseout/version'
require 'phaseout/engine'
require 'phaseout/seo_action'
require 'phaseout/seo_fields'
require 'phaseout/seo_helper'
require 'phaseout/seo'
require 'phaseout/handler'

require 'phaseout/routes_tree'

module Phaseout
  def self.config_redis(connection, namespace = :phaseout)
    @redis = Redis::Namespace.new namespace, redis: connection
  end

  def self.redis
    @redis ||= config_redis(Redis.new)
  end

  def self.default_fields
    @default_fields ||= I18n.t('seo.fields').keys
  end
end

ActiveSupport.on_load(:action_view){ include Phaseout::SEOHelper }
