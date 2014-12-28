module Phaseout
  module SEO
    extend ActiveSupport::Concern

    def seo_tags
      @_seo_tags || ''
    end

    def seo_tags=(value)
      @_seo_tags = value
    end

    included do
      helper_method :seo_tags
    end

    module ClassMethods
      def seo_group_name
        @_seo_group_name ||= Hash.new
      end

      def seo_tags_for(action, as: action, key: as, editable: true, grouped_as: nil, &block)
        seo_action = Phaseout::SEOAction.new self.name, action
        seo_group_name[seo_action.key] = grouped_as || seo_action.key
        around_block = lambda do |controller, action_block|
          return action_block.call unless request.format.html?
          Phaseout::Handler.new(controller, action, as, key, editable, &block).call &action_block
        end
        around_action around_block, only: action
      end
    end
  end
end
