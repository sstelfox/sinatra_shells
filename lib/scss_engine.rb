
require 'sass'
require 'compass'

class ScssEngine < Sinatra::Base
  set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
  set :views, (self.root + '/assets/scss')

  configure do
    Compass.configuration do |config|
      config.project_path = ScssEngine.root
      config.sass_dir = (ScssEngine.root + '/assets/scss')
      config.images_dir = (ScssEngine.root + '/assets/imgs')

      config.http_path = '/'
      config.http_images_path = '/imgs'
      config.http_stylesheets_path = '/css'
    end

    set :scss, Compass.sass_engine_options
  end

  get '/css/*.css' do |path|
    cache_control :public, :must_revalidate, :max_age => 300
    scss path.to_sym
  end
end

