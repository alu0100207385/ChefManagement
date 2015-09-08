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

group :development, :test do
  gem 'dm-sqlite-adapter'
  gem 'sinatra-contrib'
  gem 'sqlite3', :platforms => :ruby
=begin
  platforms :jruby do
    gem 'jdbc-sqlite3'
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jruby-openssl'
  end
=end
end

group :production do
  gem 'pg'
  gem 'do_postgres'
  gem 'dm-postgres-adapter'
=begin
  platform :jruby do
    gem 'activerecord-jdbcpostgresql-adapter'
    gem 'do_jdbc'
    gem 'jruby-pgp'
  end
=end
end


group :test do
  gem 'rack-test'
  gem 'rake'
  gem 'minitest'
  gem 'test-unit'
  gem 'selenium-webdriver', '~> 2.46.2'
  gem 'chromedriver-helper'
  gem 'rspec'
  gem 'coveralls', require: false
end
