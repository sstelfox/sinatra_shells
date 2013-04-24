
# Set some local variables and the local path
environment = (ENV['RACK_ENV'] ||= 'development')
base_directory = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$:.unshift(base_directory) unless $:.include?(base_directory)

listen(3000)
timeout(10)
worker_processes(4)
working_directory(base_directory)

stderr_path(File.join(base_directory, 'logs', "#{environment}.log"))

preload_app(true)

