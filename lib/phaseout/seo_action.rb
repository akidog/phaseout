module Phaseout
  class SEOAction
    attr_reader :controller, :action

    def initialize(controller_or_key, action = nil)
      if action
        @controller, @action = controller_or_key, action
      else
        @controller, @action = controller_or_key.split '#'
      end
    end

    def key
      I18n.transliterate([ @controller, @action ].join '#' ).gsub(/\s+/, '_').underscore
    end

    def id
      I18n.transliterate([ @controller, @action ].join '-' ).gsub(/\s+/, '_').underscore
    end

    def fields(&block)
      if block_given?
        SEOFields.all self.key, &block
      else
        @fields ||= SEOFields.all self.key
      end
    end

    def name
      controller.camelize.constantize.seo_group_name[key] || key
    end

    def to_json
      {
        id:         id,
        key:        key,
        name:       name,
        action:     action,
        controller: controller
      }.to_json
    end

    def self.all(&block)
      unless block_given?
        values = []
        self.all{ |action| values << action }
        return values
      end

      pattern = "#{Phaseout.redis.namespace}:action:*"
      Phaseout.redis.scan_each(match: pattern) do |value|
        yield self.new( value.match(/#{ Phaseout.redis.namespace }\:action\:/).post_match )
      end
    end
  end
end
