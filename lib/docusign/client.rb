require 'openssl'
require 'open-uri'
require 'net/http'

module Docusign
  class Client

    def get(path, **options)
      url = uri(path, options[:query])
      request = ::Net::HTTP::Get.new(url.request_uri, default_headers.merge(options[:headers].to_h))
      dispatch(url, request)
    end

    def delete(path, **options)
      url = uri(path)
      request = ::Net::HTTP::Delete.new(url.request_uri, default_headers.merge(options[:headers].to_h))
      request.body = format_data(options[:payload]).to_json if options.has_key?(:payload)
      dispatch(url, request)
    end

    def put(path, **options)
      url = uri(path)
      request = ::Net::HTTP::Put.new(url.request_uri, default_headers.merge(options[:headers].to_h))
      request.body = format_data(options[:payload]).to_json if options.has_key?(:payload)
      dispatch(url, request)
    end

    def post(path, **options)
      url = uri(path)
      request = ::Net::HTTP::Post.new(url.request_uri, default_headers.merge(options[:headers].to_h))
      request.body = format_data(options[:payload]).to_json if options.has_key?(:payload)
      dispatch(url, request)
    end

    def information
      unless @information
        begin
          response = get("#{Docusign.config.endpoint}/#{Docusign.config.version}/login_information", headers: default_headers)
          raise ::Docusign::LoginError, response.message if response.error?
          @information = response
        rescue => e
        end
      end
      @information || ::Docusign::Response.new
    end

    def base_url
      primary = information.login_accounts([]).find { |account| account.account_id == Docusign.config.account_id.to_i } || Docusign::Data.new
      primary.base_url || 'https://www.docusign.net/restapi'
    end

    private

      def dispatch(url, req)
        response = http(url).request(req)
        ::Docusign::Response.new(response)
      end

      def http(url)
        url = uri(url) if url.is_a?(String)
        net_http = ::Net::HTTP.new(url.host, url.port)
        net_http.use_ssl = url.scheme == 'https'

        if net_http.use_ssl?
          net_http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          net_http.verify_depth = 5
        end

        net_http
      end

      def uri(path, query={})
        if path.start_with?('http')
          URI.parse("#{path}?#{query.to_h.to_query}".gsub(/\?$/, ''))
        else
          URI.parse("#{base_url}/#{path.gsub(/^\/+/, '')}?#{query.to_h.to_query}".gsub(/\?$/, ''))
        end
      end

      def default_headers
        {
          'Content-Type' => 'application/json',
          'X-DocuSign-Authentication' => {
            'Username' => Docusign.config.username,
            'Password' => Docusign.config.password,
            'IntegratorKey' => Docusign.config.key
          }.to_json
        }
      end

      def format_data(data)
        if data.is_a?(Hash)
          data.map { |k,v| { k.to_s.camelize(:lower) => format_data(v) } }.reduce(Hash.new, :merge).reject { |_,v| v.blank? }
        elsif data.is_a?(Array)
          data.map { |d| format_data(d) }
        else
          data.to_s
        end
      end

  end
end