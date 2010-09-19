# Defines HTTY::RequestsUtil.

require 'net/http'
require 'net/https'
require 'uri'
require File.expand_path("#{File.dirname __FILE__}/response")
require 'rack/test'

module HTTY; end
module HTTY::Rack; end
module HTTY::HTTP; end

module HTTY::Rack::RequestsUtil
  
  module RackApp
    def self.app
      @app ||= build_app
    end
    
    extend Rack::Test::Methods
    
    private
      def self.build_app
        config_file = File.read(find_config_file)
        Rack::Builder.new { instance_eval(config_file) }.to_app
      end
      
      def self.find_config_file
        if Dir.glob("config.ru").length > 0
          File.join(Dir.pwd,"config.ru")
        elsif Dir.pwd != "/"
          Dir.chdir("..") { find_config_file }
        else
          raise "Cannot find config.ru"
        end
      end
  end
  
  class << self
    %w(get post put head delete).each do |verb|
      define_method(verb) do |request|
        request(request) do
          RackApp.send verb, '/'
        end
      end
    end
  end
 
protected

  def self.http_response_to_status(http_response)
    [http_response.status, "bla"] #alpha...
  end

private

  def self.request(request)
    http_response = yield
    headers = []
    http_response.headers.each do |*h|
      headers << h
    end
    request.send :response=,
                 HTTY::Response.new(:status  => http_response_to_status(http_response),
                                    :headers => headers,
                                    :body    => http_response.body)
    request
  end

end


# Provides support for making HTTP(S) requests.
module HTTY::HTTP::RequestsUtil

  # Makes an HTTP DELETE request with the specified _request_.
  def self.delete(request)
    request(request) do |host|
      host.delete request.send(:path_query_and_fragment), request.headers
    end
  end

  # Makes an HTTP GET request with the specified _request_.
  def self.get(request)
    request(request) do |host|
      host.request_get request.send(:path_query_and_fragment), request.headers
    end
  end

  # Makes an HTTP HEAD request with the specified _request_.
  def self.head(request)
    request(request) do |host|
      host.head request.send(:path_query_and_fragment), request.headers
    end
  end

  # Makes an HTTP OPTIONS request with the specified _request_.
  def self.options(request)
    request(request) do |host|
      host.options request.send(:path_query_and_fragment), request.headers
    end
  end

  # Makes an HTTP POST request with the specified _request_.
  def self.post(request)
    request(request) do |host|
      host.post request.send(:path_query_and_fragment),
                request.body,
                request.headers
    end
  end

  # Makes an HTTP PUT request with the specified _request_.
  def self.put(request)
    request(request) do |host|
      host.put request.send(:path_query_and_fragment),
               request.body,
               request.headers
    end
  end

  # Makes an HTTP TRACE request with the specified _request_.
  def self.trace(request)
    request(request) do |host|
      host.trace request.send(:path_query_and_fragment), request.headers
    end
  end

protected

  def self.http_response_to_status(http_response)
    [http_response.code,
     http_response.code_type.name.gsub(/^Net::HTTP/,       '').
                                  gsub(/(\S)([A-Z][a-z])/, '\1 \2')]
  end

private

  def self.request(request)
    http = Net::HTTP.new(request.uri.host, request.uri.port)
    http.use_ssl = true if request.uri.kind_of?(URI::HTTPS)
    http.start do |host|
      http_response = yield(host)
      headers = []
      http_response.canonical_each do |*h|
        headers << h
      end
      request.send :response=,
                   HTTY::Response.new(:status  => http_response_to_status(http_response),
                                      :headers => headers,
                                      :body    => http_response.body)
    end
    request
  end

end
