module Phaseout
  module SEO
    extend ActiveSupport::Concern

    def seo_context
      @_seo_context ||= Hash.new
    end

    def seo_tags
      @_seo_tags || ''
    end

    def seo_tags=(value)
      @_seo_tags = value
    end

    class Base
      def initialize(controller)
        @controller = controller
      end

      def seo_tags_for(*args, &block)
        @controller.seo_tags_for *args, &block
      end
    end

    included do
      helper_method :seo_tags
      begin
        ( seo_class_name = "#{self.name}SEO" ).constantize.new(self).call
      rescue NameError
        raise "#{seo_class_name} not defined"
      end
    end

    module ClassMethods
      def seo_group_name
        @_seo_group_name ||= Hash.new
      end

      def seo_tags_for(main_action, actions: [ main_action ], as: main_action, key: as, editable: true, grouped_as: nil, &block)
        seo_action = Phaseout::SEOAction.new self.name, main_action
        seo_group_name[seo_action.key] = grouped_as || seo_action.key
        around_block = lambda do |controller, action_block|
          return action_block.call unless request.format.html?
          Phaseout::Handler.new(controller, main_action, as, key, editable, &block).call &action_block
        end
        around_action around_block, only: actions
      end
    end
  end
end
