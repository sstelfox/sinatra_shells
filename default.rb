
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

class Shell
  def close
    @read_socket.close
    @write_socket.close
    Process.waitpid(@pid)
  end

  def initialize(ws)
    @read_socket, @write_socket, @pid = PTY.spawn('env PS1="[\u@\h] \w\$ " TERM=xterm-256color COLUMNS=80 LINES=24 sh -i')
    @websocket = ws
    ObjectSpace.define_finalizer(self, method(:close))
  end

  def send(msg)
    @write_socket.puts(msg)
    while IO.select([@read_socket], nil, nil, 0])
      websocket.send(@read_socket.read_nonblock(1024))
    end
  end

  def websocket
    @websocket
  end
end

module Default
  class App < Sinatra::Base
    enable :logging, :sessions, :method_override

    set :root, File.expand_path(File.dirname(__FILE__))
    set :views, (self.root + '/views')
    set :public_folder, (self.root + '/public')

    set :shells, []

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

    get '/shells' do
      pass unless request.websocket?

      request.websocket do |ws|
        ws.onopen do
          settings.shells << Shell.new(ws)
        end
        ws.onmessage do |msg|
          EM.next_tick { settings.shells.each{ |s| s.send(msg) } }
        end
        ws.onclose do
          settings.shells.delete_if { |s| s.websocket == ws }
        end
      end
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

