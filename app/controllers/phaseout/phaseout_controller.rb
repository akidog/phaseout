module Phaseout
  class PhaseoutController < ::Phaseout::ApplicationController

    def actions
      streamed_json_response do |stream|
        ::Phaseout::SEOAction.all do |seo_action|
          stream.call seo_action
        end
      end
    end

    def action_keys
      streamed_json_response do |stream|
        ::Phaseout::SEOFields.all(params[:key]) do |fields|
          stream.call fields
        end
      end
    end

    protected
    def streamed_json_response(&block)
      headers['Content-Type']      = 'application/json'
      headers['X-Accel-Buffering'] = 'no'
      headers['Cache-Control']   ||= 'no-cache'
      headers.delete 'Content-Length'

      response.stream.write '['

      first = true
      stream_block = lambda do |data|
        if first
          first = false
          response.stream.write data.to_json
        else
          response.stream.write ",#{data.to_json}"
        end
      end

      yield stream_block

      response.stream.write ']'
      response.stream.close
    end

  end
end
