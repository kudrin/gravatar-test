require 'sinatra'
require 'dalli'

set :raise_errors, false
set :show_exceptions, false

# Use memcache client
set :cache, Dalli::Client.new

APP_KEY = 'gravatar'
MEMCACHE_TIMEOUT = 600
MEMCACHE_ENABLED = true

# If application use remote protexted memcacche server
# set :cache, Dalli::Client.new(ENV["MEMCACHIER_SERVERS"],
#                   {:username => ENV["MEMCACHIER_USERNAME"],
#                    :password => ENV["MEMCACHIER_PASSWORD"]} 

module Gravatar
  class Avatar

    HOST = 'www.gravatar.com'
    PATH = 'avatar'

    POSSIBLE_SCHEMES = [:http, :https]
    POSSIBLE_EXTENTIONS = %w{.jpg .jpeg .gif .png}

    attr_reader :email, :scheme, :extension

    def initialize(email, scheme: :http, extension: '.jpeg')
      self.email     = email
      self.scheme    = scheme
      self.extension = extension
    end

    def email=(value)
      raise ArgumentError unless value =~ /\A([^@\s]+)@((?:[-a-z0-9.]+\.)+[a-z]{2,})\Z/i
      @email = value
    end  

    def scheme=(value)
      raise ArgumentError unless POSSIBLE_SCHEMES.include? value.to_sym
      @scheme = value.to_sym
    end  

    def extension=(value)
      raise ArgumentError unless POSSIBLE_EXTENTIONS.include? value
      @extension=value
    end

    def url
      '%{scheme}://%{host}/%{path}/%{hash}%{extension}' % {
        scheme: scheme,
        host: HOST,
        path: PATH,
        hash: email_hash,
        extension: extension
      }
    end

    private

    def email_hash
      Digest::MD5.hexdigest(@email)
    end
  end
end

helpers do
  def scheme
    request.scheme
  end

  def key
    '%{app_key}:%{scheme}:%{request_path}' % {
      app_key: APP_KEY,
      scheme: scheme,
      request_path: request.fullpath
    }
  end  
  
  def cache(&block)
    if MEMCACHE_ENABLED
      settings.cache.fetch(key) do
        result = block.call
        settings.cache.set(key, result, MEMCACHE_TIMEOUT)
        result
      end 
    else
     block.call
    end 
  end
end

not_found do
  status 404
  body ''
end

get '/gravatar/:email' do
  cache do
    begin
      Gravatar::Avatar.new(params[:email], scheme: scheme).url
    rescue ArgumentError
      halt 422
    end
  end
end
