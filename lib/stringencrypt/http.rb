# frozen_string_literal: true

require "json"
require "net/http"
require "openssl"
require "securerandom"
require "uri"

class StringEncrypt
  # Stdlib HTTP helper. Multipart for API form posts / file uploads; urlencoded when needed.
  module Http
    class << self
      def post_multipart(url, fields, user_agent:, files: {})
        boundary = "----PELock#{SecureRandom.hex(16)}"
        body = build_multipart(fields, files, boundary)
        request(url, body, user_agent, "multipart/form-data; boundary=#{boundary}")
      end

      def post_urlencoded(url, fields, user_agent:)
        pairs = []
        fields.each do |key, value|
          next if value.nil?

          pairs << [key.to_s, normalize_form_value(value)]
        end
        request(url, URI.encode_www_form(pairs), user_agent, "application/x-www-form-urlencoded")
      end

      def parse_json(body)
        return nil if body.nil? || body.to_s.empty?

        JSON.parse(body)
      rescue JSON::ParserError
        nil
      end

      def request(url, body, user_agent, content_type)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = 30
        http.read_timeout = 180
        req = Net::HTTP::Post.new(uri.request_uri)
        req["User-Agent"] = user_agent
        req["Content-Type"] = content_type
        req.body = body
        http.request(req).body
      rescue StandardError
        nil
      end

      def build_multipart(fields, files, boundary)
        body = String.new(encoding: Encoding::ASCII_8BIT)
        fields.each do |name, value|
          next if value.nil?

          body << "--#{boundary}\r\n"
          body << "Content-Disposition: form-data; name=\"#{name}\"\r\n\r\n"
          body << value.to_s.dup.force_encoding(Encoding::UTF_8).b
          body << "\r\n"
        end
        files.each do |name, file|
          filename = file[:filename] || File.basename(file[:path].to_s)
          content = file[:content] || File.binread(file[:path])
          content_type = file[:content_type] || "application/octet-stream"
          body << "--#{boundary}\r\n"
          body << "Content-Disposition: form-data; name=\"#{name}\"; filename=\"#{filename}\"\r\n"
          body << "Content-Type: #{content_type}\r\n\r\n"
          body << content.b
          body << "\r\n"
        end
        body << "--#{boundary}--\r\n"
        body
      end

      def normalize_form_value(value)
        case value
        when true then "1"
        when false then "0"
        else value.to_s
        end
      end
    end
  end
end
