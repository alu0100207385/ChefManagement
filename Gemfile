source 'https://rubygems.org'

gem 'sinatra'
gem 'sinatra-base'
gem 'data_mapper'
gem 'mail'
gem 'omniauth-oauth2'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'json'
gem 'thin', :platforms => :ruby

group :development do
  gem 'sinatra-contrib'
  gem 'dm-sqlite-adapter'
  gem 'sqlite3', :platforms => :ruby

  platforms :jruby do
    gem 'jdbc-sqlite3'
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jruby-openssl'
  end
  
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
  gem 'chromedriver-helper'
end
