
module Lti2Tc

  class ApplicationController < ActionController::Base
    include OAuth::OAuthProxy
    def pre_process_tenant
      rack_parameters = OAuthRequest.collect_rack_parameters request
      key = rack_parameters[:oauth_consumer_key]
      @tool = Lti2Tc::Tool.where(:key => key).first
      secret = @tool.secret
      oauth_validation_using_secret secret
    end

    def oauth_validation_using_secret secret
      # OAuth check here
      tool_consumer_registry = Rails.application.config.tool_consumer_registry
      unless tool_consumer_registry.relaxed_oauth_check == 'true'
        request_wrapper = OAuthRequest.create_from_rack_request request
        begin
          request_wrapper.verify_signature? secret, Rails.application.config.nonce_cache, false
          @oauth_error = false
          return
        rescue
          # puts "Secret: #{secret}"
          puts "TP Signed Request: #{request_wrapper.signature_base_string}"
          @oauth_error = true
        end

        puts "request_wrapper: #{request_wrapper.request['parameters'].inspect}"
      end
    end
  end
end
