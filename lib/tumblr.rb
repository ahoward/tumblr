#
# built-in
#
  require "uri"
  require "yaml"
#
# gems
#
  begin
    require 'rubygems'
  rescue LoadError
    nil
  end
  require "main"
  require "fattr"
  require "httpclient"
#
# tumblr.rb
#
  module Tumblr
    Version = '2.1.0'

    class << Tumblr
      def version() Tumblr::Version end

      def for *a, &b
        Account.new *a, &b
      end
    end


    class Account
      fattr "name"
      fattr "email"
      fattr "password"
      fattr "debug"
      fattr("uri"){ "http://#{ name }.tumblr.com" }
      fattr("generator"){ "tumblr.rb" }
      fattr("proxy"){ ENV["HTTP_PROXY"] }
      fattr("httpclient"){ HTTPClient.new proxy }
      fattr("api"){ API.new "account" => account }
      fattr("account"){ self }

      def initialize options = {}
        options.each{|k,v| send k, v}
        httpclient.debug_dev = debug if debug?
      end

      def options
        {
          'email' => email,
          'password' => password,
          'generator' => generator,
        }
      end

      def method_missing m, *a, &b
        super unless api.respond_to? m
        api.send m, *a, &b
      end
    end

    class API 
      fattr "account"
      fattr("uri"){ "#{ account.uri }/api" }
      fattr("uri_write"){ "#{ uri }/write" }
      fattr("uri_read"){ "#{ uri }/read" }
      fattr("uri_read_json"){ "#{ uri }/read/json" }
      fattr("uri_delete"){ "#{ uri }/delete" }

      def initialize options = {}
        options.each{|k,v| send k, v}
      end

      def write type, options = {}
        json = options.delete('json') || options.delete(:json)
        uri = uri_write
        post uri, options.merge(account.options).merge('type' => type)
      end

      def read type, options = {}
        json = options.delete('json') || options.delete(:json)
        uri = json ? uri_read_json : uri_read
        get uri, options.merge(account.options)
      end

      def delete type, options = {}
        json = options.delete('json') || options.delete(:json)
        uri = uri_delete
        post uri, options.merge(account.options)
      end

      def authenticate options = {}
        post uri_write, 
             options.merge(account.options).merge('action' => 'authenticate')
      end

      def check_vimeo options = {}
        post uri_write, 
             options.merge(account.options).merge('action' => 'check-vimeo')
      end

      def check_audio options = {}
        post uri_write, 
             options.merge(account.options).merge('action' => 'check-audio')
      end

      def post uri, options = {}
        following_redirects(uri, options) do |uri, options|
          account.httpclient.post uri, options, "content-type" => boundary
        end
      end

      def get uri, options = {}
        following_redirects(uri, options) do |uri, options|
          account.httpclient.get uri, options
        end
      end

      def boundary
        random = Array::new(8){ "%2.2d" % rand(42) }.join("__")
        "multipart/form-data; boundary=___#{ random }___"
      end

      def following_redirects uri, options = {} 
        42.times do
          res = yield uri, options
          if HTTP::Status.successful?(res.status)
            return res
          elsif HTTP::Status.redirect?(res.status)
            uri = handle_redirect uri, res
          else
            return res
          end
        end
        raise "followed too damn many redirects!"
      end

      def handle_redirect uri, res
        newuri = URI.parse res.header['location'][0]
        newuri = uri + newuri unless newuri.is_a?(URI::HTTP)
        newuri
      end

      def self.successful? res
        HTTP::Status.successful? res.status
      end
    end

    def self.successful? status 
      status = status.status rescue status 
      HTTP::Status.successful? status
    end
  end
