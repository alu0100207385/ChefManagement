source 'https://rubygems.org'

#ruby '1.9.3', :engine => 'jruby', :engine_version => '1.7.19'

gem 'sinatra'
gem 'sinatra-base'
gem 'sinatra-flash'
gem 'data_mapper'

group :development do
	gem 'sqlite3', platform: :ruby
	gem 'activerecord-jdbcsqlite3-adapter', platform: :jruby
	gem 'dm-sqlite-adapter'
end

group :production do
 	gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby
 	gem 'do_jdbc', platform: :jruby
 	gem 'jruby-pgp', platform: :jruby
  	gem 'do_postgres', platform: :ruby
  	gem 'pg', platform: :ruby
  	gem 'dm-postgres-adapter'
end

