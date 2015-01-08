module Phaseout
  class Handler
    attr_reader :controller, :action, :default

    def initialize(controller, action, as_pattern, key_pattern, editable, &block)
      @controller, @action, @as_pattern, @key_pattern, @editable = controller, action, as_pattern, key_pattern, editable
      @default = Phaseout::SEOFields.new key, as, &block
    end

    def call(&action_block)
      if seo_fields
        @controller.seo_tags = seo_fields.to_html @controller
      else
        @controller.seo_tags = @default.to_html @controller
      end
      action_block.call
      set_blank_field if @controller.status == 200 && @blank_field && @editable
      true
    end

    def as
      @as ||= eval_pattern @as_pattern
    end

    def key
      @key ||= I18n.transliterate( [ 'seo_key:', @controller.class.name, '#', @action, ':', eval_pattern(@key_pattern) ].join.gsub(/\s+/, '_').underscore )
    end

    def seo_fields
      return @seo_fields if @seo_fields
      dump = Phaseout.redis.get key
      if dump && dump != ''
        @seo_fields = Marshal.load dump
        @seo_fields.default = @default
        @seo_fields
      else
        @blank_field = true
        return nil
      end
    end

    def class_index_key
      ['action:', @controller.class.name, '#', @action].join.gsub(/\s+/, '_').underscore
    end

    protected
    def set_blank_field
      Phaseout::SEOAction.new(class_index_key).add key
      Phaseout::SEOFields.new(key, as).save
    end

    def eval_pattern(pattern)
      pattern.to_s.gsub( /\@([\w\d\.\_])+/ ) do |subpattern|
        varname, *methods = subpattern.split '.'
        if @controller.instance_variable_defined? varname.to_sym
          [ *methods, :to_s ].inject( @controller.instance_variable_get varname.to_sym ) do |result, method|
            result.public_send method
          end
        else
          ''
        end
      end
    end
  end
end