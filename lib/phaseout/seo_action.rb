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

    def add(field_key)
      Phaseout.redis.sadd key, field_key
    end

    def remove(field_key)
      Phaseout.redis.srem key, field_key
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

    def self.find(key)
      self.new "action:#{key}"
    end

    def self.all(&block)
      unless block_given?
        values = []
        self.all{ |action| values << action }
        return values
      end

      Phaseout.redis.scan_each(match: 'action:*') do |value|
        yield self.new( value.match(/action\:/).post_match )
      end
    end
  end
end
