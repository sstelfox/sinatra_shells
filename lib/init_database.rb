
require 'dm-core'

require 'dm-migrations'
require 'dm-serializer'
require 'dm-timestamps'
require 'dm-transactions'
require 'dm-types'
require 'dm-validations'

DataMapper::Logger.new($stdout, :info)
DataMapper.setup(:default, 'sqlite://' + File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'database.db')))

Dir[File.join(File.dirname(__FILE__), '..', 'models', '*.rb')].each do |m|
  require "models/#{File.basename(m, '.rb')}"
end

DataMapper.finalize

