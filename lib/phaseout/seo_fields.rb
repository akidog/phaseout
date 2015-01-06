module Phaseout
  class SEOFields
    attr_reader :key, :human_name
    attr_accessor :values, :default
    alias :fields :values

    def initialize(key, human_name, values = Hash.new, &block)
      @key, @human_name, @values = I18n.transliterate(key).gsub(/\s+/, '_').underscore, human_name, values
      yield(self) if block_given?
    end

    def to_html(controller)
      values = evaluated_values(controller).map do |helper, argument|
        controller.view_context.send helper, *argument
      end

      values << controller.view_context.og_auto_default

      values.compact.join.html_safe
    end

    def action_key
      @action_key ||= @key.match('seo_key:').post_match.match(':').pre_match
    end

    def action
      @action ||= ::Phaseout::SEOAction.new action_key
    end

    def id
      @key.match(/\#.+\:/).post_match.gsub(/\s+/, '_').underscore
    end

    def to_json
      {
        id:         id,
        key:        @key.match('seo_key:').post_match,
        fields:     @values,
        name:       @human_name,
        action_id:  action_key.gsub('#', '_').underscore,
        action_key: action_key
      }.to_json
    end

    def dump
      Marshal.dump self
    end

    def save
      Phaseout.redis.set key, self.dump
    end

    def delete
      Phaseout::SEOAction.find(action_key).remove key
      Phaseout.redis.del key
    end

    def evaluated_values(controller)
      @_values ||= if @default
        @default.evaluated_values(controller).merge @values
      else
        Hash[
          @values.map do |helper, argument|
            if argument.is_a? Proc
              [ helper, controller.instance_eval(&argument) ]
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
      "#<Phaseout::SEO #{action_key} #{@human_name}>"
    end
    alias :to_s :inspect

    def method_missing(method, *args, &block)
      if block_given?
        @values[method.to_sym] = block
      else
        @values[method.to_sym] = args unless args.empty?
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

    def self.all(action_key, &block)
      unless block_given?
        values = []
        self.all(action_key){ |field| values << field }
        return values
      end

      class_index_key = "#{Phaseout.redis.namespace}:action:#{action_key}"
      Phaseout.redis.sscan_each(class_index_key) do |value|
        yield self.find value.match('seo_key:').post_match
      end
    end
  end
end
