# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra/base'
require 'data_mapper'
require 'tilt/erb'

require 'omniauth-oauth2'
require 'omniauth-google-oauth2'


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

	enable :sessions

	configure do
		set :root, File.dirname(__FILE__)
		set :views, Proc.new { File.join(root, "../views") }
		set :erb, :layout => :'layouts/layout'
		set :public_folder, Proc.new { File.join(root, "../../public") }
	end

	use OmniAuth::Builder do
	  config = YAML.load_file 'app/config/config.yml'
	  provider :google_oauth2, config['gidentifier'], config['gsecret'],
	  {
	     :authorize_params => {
	        :force_login => 'false'
	      }
	    }
	end

########################################################################
	get '/' do
		erb :index
	end


	post '/login' do
		user = User.first(:username => params[:username])
		@control = 0

		if(user.is_a? NilClass)
			@control = 1 #el usuario no existe en la bbdd
			erb :index
		elsif (user.password == params[:password])
 			@control = 0
 			session[:username] = params[:username]
			erb :home
   		end
	end


	get '/auth/:name/callback' do
		config = YAML.load_file 'app/config/config.yml'
		auth = request.env['omniauth.auth']
		#    puts "--> #{auth}"
		user = User.first(:username => session[:username])

		case params[:name]

		when 'google_oauth2'
			user = User.new
			session[:username] = user.username = auth['info'].name
			session[:email] = user.email = auth['info'].email
			if User.count(:username => user.username) == 0 #Si no existe lo incluimos en la bbdd
				user.save
			end
			redirect '/home'
=begin
			goo = GoogleData.new(:user => user)
			goo.token = auth.credentials.token
			goo.id_token = auth.extra.id_token
			goo.gid = auth.uid
			goo.save
=end
		else
			redirect '/auth/failure'
		end
	end


	get '/register' do
		erb :register
	end


	post '/register' do
		user = User.new
		user.username = params[:username]
		user.password = params[:password]
		user.email = params[:email]

		@control = 0
		if User.count(:username => user.username) == 0 #comprobamos si existe
      		user.save
      		@control = 0
      		session[:username] = params[:username]
      		redirect '/home'
      	else
      		@control = 1
      	end
	end


	get '/home' do
		@user = session[:username]
		if (!@user.is_a? NilClass)
			erb :home
		else
			redirect '/'
		end
	end


	get '/settings' do
		if session[:username] != nil
			@user = User.first(:username => session[:username])
			erb :settings
		else
			redirect '/'
		end
	end


	get '/delete-user' do
		user = User.first(:username => session[:username])
		user.destroy
  		session.clear
  		redirect '/'
	end


	get '/logout' do
	   session.clear
	   redirect '/'
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
