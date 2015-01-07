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

  def self.routes
    return @routes if @routes

    @routes = Rails.application.routes.routes.map do |route|
      Phaseout::RouteWrapper.new route
    end.find_all do |route|
      route.not_internal? && route.verb.downcase.match(/get/)
    end
  end

  def self.route_tree
    return @route_tree if @route_tree
    @route_tree = Hash.new
    routes.each do |route|
      last_hash = @route_tree
      route.tokens.each do |type, value|
        last_hash = ( last_hash[ [type, value] ] ||= Hash.new )
      end
      last_hash[:routes] ||= []
      last_hash[:routes] << route.to_s
    end
    @route_tree
  end

  def self.title_tree_source
    TitleTreeGenerator.new(route_tree).call
  end

  def self.title_builder
  end
end

ActiveSupport.on_load(:action_view){ include Phaseout::SEOHelper }
