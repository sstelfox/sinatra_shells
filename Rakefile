

task "environment" do
  require './default'
end

# This will print all of the configured routes for the sinatra application in
# the order that the route was first specified. All of the methods will be
# combined together and it will format the output into neat columns. Very useful
# for debugging when an incorrect route is being hit.
desc "List all of the routes configured"
task :routes => [:environment] do
  require 'sinatra/decompile'

  rl = Default::App.routes.each_with_object(Hash.new([])) do |verb, route_listing|
    verb[1].each do |route|
      route_listing[route[0].source] += [verb[0]]
    end
  end
  longest_column = rl.values.map { |v| v.join(", ").length }.max
  rl.each_pair do |route, methods|
    printf("%-#{longest_column}s  %s\n", methods.sort.join(", "), Sinatra::Decompile.decompile(route))
  end
end

desc "Run a console with the application loaded"
task :console do
  require 'pry'
  pry
end

namespace :db do
  desc "Upgrade or initialize the database"
  task :migrate => [:environment] do
    DataMapper.auto_upgrade!
  end

  desc "Blow away the current database and start from scratch"
  task :reset => [:environment] do
    DataMapper.auto_migrate!
  end

  desc "Seed the database with initial required data"
  task :seed => [:environment, 'db:migrate'] do
    require './config/seed'
  end
end

