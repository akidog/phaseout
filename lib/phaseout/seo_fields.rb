module Phaseout
  class SEOFields
    attr_reader :key, :human_name
    attr_accessor :values, :default

    def initialize(key, human_name, values = Hash.new, &block)
      @key, @human_name, @values = key, human_name, values
      yield(self) if block_given?
    end

    def to_html(controller)
      evaluated_values(controller).map do |helper, argument|
        controller.view_context.send helper, *argument
      end.join.html_safe
    end

    def dump
      Marshal.dump self
    end

    def save
      Phaseout.redis.set key, self.dump
    end

    def evaluated_values(controller)
      @_values ||= if @default
        @default.evaluated_values(controller).merge @values
      else
        Hash[
          @values.map do |helper, argument|
            if argument.is_a? Proc
              [ helper, argument.call(controller) ]
            else
              [ helper, argument ]
            end
          end
        ]
      end
    end

    def [](index)
      values[index.to_sym]
    end

    def []=(index, value)
      values[index.to_sym] = value
    end

    def inspect
      "#<Phaseout::SEO #{ @key.match('seo_key:').post_match.match('/').pre_match } #{@human_name}>"
    end
    alias :to_s :inspect

    def method_missing(method, *args, &block)
      if block_given?
        @values[method.to_sym] = block
      else
        @values[method.to_sym] = args
      end
    end

    def marshal_dump
      [ @key, @human_name, @values ]
    end

    def marshal_load(dump_array)
      @key, @human_name, @values = dump_array
    end

    def self.find(key)
      dump = Phaseout.redis.get "seo_key:#{key}"
      dump ? Marshal.load(dump) : nil
    end

    def self.actions(&block)
      pattern = "#{Phaseout.redis.namespace}:action:*"
      cursor, values = Phaseout.redis.scan 0, match: pattern
      while cursor != 0
        cursor = cursor.to_i
        values.each do |value|
          yield value.match(/#{ Phaseout.redis.namespace }\:action\:/).post_match
        end
        cursor, values = Phaseout.redis.scan cursor, match: pattern
        cursor = cursor.to_i
      end
    end

    def self.fields_for(action_signature, &block)
      class_index_key = "#{Phaseout.redis.namespace}:action:#{action_signature}"
      cursor, keys = Phaseout.redis.sscan class_index_key, 0
      while cursor != 0
        cursor = cursor.to_i
        keys.each{ |value| yield self.find(value.match('seo_key:').post_match) }
        cursor, keys = Phaseout.redis.sscan class_index_key, cursor
        cursor = cursor.to_i
      end
    end

  end
end
