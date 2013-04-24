
base_directory = File.expand_path(File.dirname(__FILE__))
$:.unshift(base_directory) unless $:.include?(base_directory)

require 'rubygems'
require 'json'

require 'sinatra/base'
require 'sinatra/namespace'
require 'rack-flash'

require 'lib/core_ext/hash'
require 'lib/init_database'

require 'lib/scss_engine'

module Default
  class App < Sinatra::Base
    enable :logging, :sessions, :method_override

    set :root, File.expand_path(File.dirname(__FILE__))
    set :views, (self.root + '/views')
    set :public_folder, (self.root + '/public')

    configure :development do
      enable :raise_errors
      enable :show_exceptions
    end

    use Rack::Flash
    use ScssEngine

    register Sinatra::Namespace

    # Available methods: OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT
    get '/' do
      erb :index
    end

    not_found do
      erb :'404'
    end

    error do
      erb :error
    end
  end

  # Collect all the helpers, and routers that we'll be loading
  helpers = Dir[(App.root + '/helpers/*.rb')].map { |f| File.basename(f, '.rb') }
  routers = Dir[(App.root + '/routes/*.rb')].map { |f| File.basename(f, '.rb') }

  helpers.each { |h| require "helpers/#{h}" }
  routers.each { |r| require "routes/#{r}" }
end

