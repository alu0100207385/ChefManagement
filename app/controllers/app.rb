# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra/base'
require 'data_mapper'
require 'tilt/erb'

class MyApp < Sinatra::Base

	configure :development do
   		DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/bbdd.db" )
   	end

   	configure :production do
   		DataMapper.setup(:default, ENV['DATABASE_URL'])
   	end

	DataMapper::Logger.new($stdout, :debug)
	DataMapper::Model.raise_on_save_failure = true

	require_relative '../models/model'

	DataMapper.finalize
	DataMapper.auto_upgrade!


	configure do
		set :root, File.dirname(__FILE__)
		set :views, Proc.new { File.join(root, "../views") }
		set :erb, :layout => :'layouts/layout'
		set :public_folder, Proc.new { File.join(root, "../../public") }
	end

	get '/' do
		#@list = User.all
		erb :index
	end

	post '/login' do
		@user = params[:username]
		@pass = params[:password]
		erb :home
	end

	get '/register' do
		erb :register
	end
=begin
	post '/delete' do
		User.destroy
		redirect '/'
	end
=end


	# start the server if ruby file executed directly
  	run! if app_file == $0
end
