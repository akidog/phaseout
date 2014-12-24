require 'phaseout/seo_fields'
require 'phaseout/seo_helper'

module Phaseout
  module SEO
    extend ActiveSupport::Concern

    def seo_tags
      @_seo_tags ||= ''
    end

    def seo_tags=(value)
      @_seo_tags = value
    end

    included do
      helper_method :seo_tags
    end

    module ClassMethods
      def seo_tags_for(action, as: action, key: action, editable: true, &block)
        around_block = lambda do |controller, action_block|
          Phaseout::Handler.new(controller, action, as, key, editable, &block).call &action_block
        end
        around_action around_block, only: action
      end
    end
  end
end
