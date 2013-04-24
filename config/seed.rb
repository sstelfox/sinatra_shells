
def simple_log(msg)
  printf("%-50.50s", msg)
end

def failed
  puts "[ Failed ]"
end

def success
  puts "[ Done ]"
end

def skipped
  puts "[ Skipped ]"
end

simple_log("Creating admin user...")
if User.first(username: 'admin')
  skipped
else
  u = User.new(username: 'admin', password: 'password', password_confirmation: 'password')
  u.save ? success : failed
end
