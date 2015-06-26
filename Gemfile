source 'https://rubygems.org'

gem 'sinatra'
gem 'sinatra-base'
gem 'sinatra-flash'
gem 'data_mapper'
gem 'mail'
gem 'omniauth-oauth2'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'json'
gem 'thin', :platforms => :ruby

group :development do
  gem 'sinatra-contrib'
  gem 'sqlite3', :platforms => :ruby
  gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
  gem 'dm-sqlite-adapter'
end
=begin
group :production do
	platform :jruby do
		gem 'activerecord-jdbcpostgresql-adapter'
 		gem 'do_jdbc'
 		gem 'jruby-pgp'
	end

	platform :ruby do
  		gem 'do_postgres', '~> 0.10.16'
  		gem 'pg'
  	end

  	gem 'dm-postgres-adapter'
end
=end
group :test do
  gem 'rack-test'
  gem 'rake'
  gem 'minitest'
  gem 'test-unit'
  gem 'selenium-webdriver', '~> 2.46.2'
end
