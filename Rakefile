task :default => :sinatra

desc "Run the server via Sinatra (1)"
task :sinatra do
	sh "ruby app/controllers/app.rb"
end

desc "Run the server via Sinatra (2)"
task :s do
	sh "ruby app/controllers/app.rb"
end

desc "Run the server via rackup"
task :r do
	sh "rackup"
end

desc "Open repository"
task :repo do
	sh "gnome-open https://github.com/alu0100207385/ChefManagement"
end

desc "Run tests in local machine"
task :local_tests do
	sh "gnome-terminal -x sh -c 'rackup' && sh -c 'bundle exec ruby app/tests/test.rb'"
end

desc "Run tests: rake test[navigator] || navigator is an optional argument = [firefox(default)|chrome]"
task :tests, [:nav] do |task, args|
	sh "ruby app/tests/test.rb #{args[:nav]}"
end

desc "Run tests with rspec"
task :spec do
  sh "rspec -I. app/spec/app_spec.rb"
  #sh "rspec -I. app/spec/helper_spec.rb"
end