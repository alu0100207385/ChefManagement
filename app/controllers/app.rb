# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra/base'
require 'data_mapper'
require 'tilt/erb'

require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-facebook'
require 'json'


class MyApp < Sinatra::Base
	
	set :environment, :development
	
	configure :development, :test do
   		DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/bbdd.db" )
   	end

   	configure :production do
   		DataMapper.setup(:default, ENV['DATABASE_URL'])
   	end

	DataMapper::Logger.new($stdout, :debug)
	DataMapper::Model.raise_on_save_failure = true

	require_relative '../models/model'

	DataMapper.finalize
	# DataMapper.auto_migrate!
	DataMapper.auto_upgrade!

	enable :sessions

	configure do
		set :root, File.dirname(__FILE__)
		set :views, Proc.new { File.join(root, "../views") }
		set :erb, :layout => :'layouts/default'
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
		provider :facebook, config['fidentifier'], config['fsecret'],
		{
			:scope => 'email, public_profile'
		}
	end

########################################################################
	get '/' do
		if (session[:username] != nil)
			redirect '/home'
		else
			erb :index, :layout => :'layouts/welcome'
		end
	end

	post '/' do
		redirect '/'
	end

	post '/login' do
		user = User.first(:username => params[:username])
		content_type 'application/json'

		if (params[:username]!= "") and (params[:password]!= "")
			if (user.is_a? NilClass) 
				{:control => 1}.to_json #usuario no registrado en la bbdd
			elsif (user.password == params[:password])
		 		session[:username] = params[:username]
		 		{:control => 0}.to_json #ok
			else
				{:control => 2}.to_json #pass no coinciden
		   	end
		end
	end


	get '/auth/:name/callback' do
		config = YAML.load_file 'app/config/config.yml'
		auth = request.env['omniauth.auth']
		user = User.new
		#user = User.first(:username => session[:username])
		case params[:name]

		when 'google_oauth2'
			session[:username] = user.username = auth['info'].name
			#session[:email] = 
			user.email = auth['info'].email
			user.network = 'google'
			if User.count(:username => session[:username]) == 0 #Si no existe lo incluimos en la bbdd
				user.save
			end
			redirect '/home'

		when 'facebook'
			session[:username] = user.username = auth['info'].name
			#session[:email] = 
			user.email = auth['info'].email
			user.network = 'facebook'
			if User.count(:username => user.username) == 0 #Si no existe lo incluimos en la bbdd
				user.save
			end
			redirect '/home'
		else
			redirect '/auth/failure'
		end
	end


	get '/register' do
		@user = User.first(:username => session[:username])
		if (@user.is_a? NilClass)
			erb :register, :layout => :'layouts/welcome'
		else
			redirect '/'
		end
	end


	post '/register' do
		user = User.new
		user.username = params[:username]
		user.password = params[:password]
		user.email = params[:email]
		content_type 'application/json'

      	if (!User.first(:username => params[:username]).is_a? NilClass)
			{:control => 1}.to_json
		elsif (!User.first(:email => params[:email]).is_a? NilClass)
			{:control => 2}.to_json
		else
			user.save
			session[:username] = params[:username]
			{:control => 0}.to_json
		end
	end


	get '/home' do
		@user = User.first(:username => session[:username])
		#@user = session[:username]
		if (!@user.is_a? NilClass)
			erb :home, :layout => :'layouts/default'
		else
			redirect '/'
		end
	end


	post '/recovery-account' do
		#puts "-->#{params[:recoveryaccount]}"
		#puts "--> #{User.first(:username => params[:recoveryaccount]).class}"
		content_type 'application/json'
		if (!User.first(:username => params[:recoveryaccount]).is_a? NilClass)
			{:control => 0}.to_json
		else
			{:control => 1}.to_json #El usuario no existe
		end
	end


	get '/home/settings' do
		@user = User.first(:username => session[:username])
		if (!@user.is_a? NilClass)
			erb :settings, :layout => :'layouts/default'
		else
			redirect '/'
		end
	end

	post '/home/settings/edit-user' do
		content_type 'application/json'
		puts "-->#{session[:username]}"
		puts "-->#{params[:prueba]}"
		puts "-->#{params[:new_password]}"
		puts "-->#{params[:new_email]}"
		user = User.first(:username => session[:username])
		if (!user.is_a? NilClass)
			puts "-->ok"
			if (params[:new_email] != "" )
				user.email = params[:new_email]
			end
			if (params[:new_password] != "" )
				user.password = params[:new_password]
			end
			if user.save
				{:control => 0}.to_json #Datos guardados con exito
			else
				{:control => 1}.to_json
			end
=begin
			if ( (params[:new_email] == "" ) and (params[:password] == "" )) or ((params[:new_email] == "" ) and (params[:password].size < 4 )) #Hay q estabelcer el tam minimo de la pass
				{:control => 1}.to_json 
			elsif user.save
				{:control => 0}.to_json #Datos guardados con exito
			else
				{:control => 1}.to_json
			end
=end
		end
	end


	post '/home/settings/delete-user' do
		user = User.first(:username => session[:username])
		if (!user.is_a? NilClass)
			user.destroy
	  		session.clear
	  		redirect '/'
	  	end
	end


	get '/logout' do
	   session.clear
	   redirect '/'
	end


	# start the server if ruby file executed directly
  	run! if app_file == $0
end
