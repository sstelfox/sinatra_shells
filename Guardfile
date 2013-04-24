
notification :off

guard :process, name: 'DefaultAppServer', command: 'unicorn -c config/unicorn.rb' do
  watch(%r{^config/(.+).rb$})
  watch(%r{^helpers/(.+)\.rb$})
  watch(%r{^lib/(.+)\.rb$})
  watch(%r{^models/(.+)\.rb$})
  watch(%r{^routes/(.+)\.rb$})
  
  watch('config.ru')
  watch('Gemfile.lock')
  watch('nca.rb')
end
