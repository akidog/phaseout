module Phaseout
  class PhaseoutController < ::Phaseout::ApplicationController

    def update
      @seo_fields = Phaseout::SEOFields.find params[:key]
      if @seo_fields
        @seo_fields.values = params[:seo_field].to_h.symbolize_keys
        @seo_fields.save
        render json: @seo_fields.to_json
      else
        not_found
      end
    end

    def delete
      @seo_fields = Phaseout::SEOFields.find params[:key]
      if @seo_fields
        @seo_fields.delete
        render json: { status: :ok }.to_json
      else
        not_found
      end
    end

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
          stream.call(fields) if fields.present?
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

    def not_found(data = { status: :not_found })
      render json: data.to_json, status: 404
    end

  end
end
