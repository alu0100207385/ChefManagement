source 'https://rubygems.org'

#ruby '1.9.3', :engine => 'jruby', :engine_version => '1.7.19'

gem 'sinatra'
gem 'sinatra-base'
gem 'sinatra-flash'
gem 'data_mapper'
gem 'mail'
gem 'omniauth-oauth2'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'

group :development do
	gem 'sqlite3', platform: :ruby
	gem 'activerecord-jdbcsqlite3-adapter', platform: :jruby
	gem 'dm-sqlite-adapter'
end

group :production do
	platform :jruby do
		gem 'activerecord-jdbcpostgresql-adapter'
 		gem 'do_jdbc'
 		gem 'jruby-pgp'
	end

	platform :ruby do
  		gem 'do_postgres'
  		gem 'pg'
  	end

  	gem 'dm-postgres-adapter'
end

