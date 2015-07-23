# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra/base'
require 'data_mapper'
require 'tilt/erb'

require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-facebook'
require 'json'

require_relative '../helpers/helpers.rb'

include AppHelpers

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
		#set :public_folder, Proc.new { File.join(root, "../../public") }
		set :public_folder, 'public'
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

############################## LOGIN & LOGOUT #########################################
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

	get '/logout' do
	   session.clear
	   redirect '/'
	end


	get '/auth/:name/callback' do
		config = YAML.load_file 'app/config/config.yml'
		auth = request.env['omniauth.auth']
		user = User.new
		#user = User.first(:username => session[:username])
		case params[:name]

		when 'google_oauth2'
			session[:username] = user.username = auth['info'].name
			user.email = auth['info'].email
			session[:network] = user.network = 'google'
			#if (User.count(:username => session[:username]) == 0) || (User.count(:username => session[:username], :network => 'google') == 0) #Si no existe lo incluimos en la bbdd
			if (User.first(:username => auth['info'].name).is_a? NilClass)
				user.save
			end
			redirect '/home'

		when 'facebook'
			session[:username] = user.username = auth['info'].name
			user.email = auth['info'].email
			session[:network] = user.network = 'facebook'
			#if (User.count(:username => user.username) == 0) || (User.count(:username => session[:username], :network => 'facebook') == 0)  #Si no existe lo incluimos en la bbdd
			if (User.first(:username => auth['info'].name).is_a? NilClass)
				user.save
			end
			redirect '/home'
		else
			redirect '/auth/failure'
		end
	end

############################## CRUD USER #########################################

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
			account_information(params[:username], params[:password], params[:email], 'ChefManagement: Welcome to ChefManagement')
			{:control => 0}.to_json
		end
	end

	post '/home/settings/edit-user' do
		user = User.first(:username => session[:username])
		cambio = 1 #no se han producido cambios
		if (params[:new_email] != "")
			if ( (User.first(:email => params[:new_email])).is_a? NilClass )
				user.update(:email => params[:new_email])
				cambio = 0
			else #Ese correo ya esta registrado en la bbdd
				cambio = 2
			end
		end
		if (params[:new_password] != "")
			user.update(:password => params[:new_password])
			cambio = 0
		end
		
		content_type 'application/json'
		case cambio
		when 0
			{:control => 0}.to_json
		when 1 #no se han producido cambios
			{:control => 1}.to_json
		when 2 #correo en uso
			{:control => 2}.to_json
		end
	end


	post '/home/settings/delete-user' do
		user = User.first(:username => session[:username])
		user.destroy
	  	session.clear
	  	redirect '/'
	end


	post '/recovery-account' do
		user = User.first(:username => params[:recoveryusername])
		if (!user.is_a? NilClass)
			new_pass = (0...2).map { (65 + rand(26)) }.join
			user.update(:password => new_pass)
			account_information(user.username, new_pass, user.email, 'ChefManagement: New password');
		end
		content_type 'application/json'
		if (!user.is_a? NilClass)
			{:control => 0}.to_json
		else
			{:control => 1}.to_json #El usuario no existe
		end
	end

############################## CRUD RECIPE & ING #########################################

	get '/home' do
		@user = User.first(:username => session[:username])
		@rec = Recipe.all
		if (!@user.is_a? NilClass)
			@current_user = session[:username]
			erb :home
		else
			redirect '/'
		end
	end


	get '/home/recipe' do
		user = User.first(:username => session[:username])
		content_type 'application/json'
		if (!user.is_a? NilClass)
			#rec = GetIds(params[:recipe])
			if (!Recipe.first(:name => params[:recipe], :username => params[:user]).is_a? NilClass)
				params[:user].gsub!(' ','-')
				{:control => 0, :username => params[:user]}.to_json
			else
				{:control => 1}.to_json
			end
		else
			{:control => 1}.to_json
		end
	end


	get '/home/recipe/:name' do
		params[:name].gsub!('-',' ')
		c = GetIds(params[:name]);
		@recipe = Recipe.first(:name => c[0], :username => c[1])
		@ing = Ingredient.all(:order => [:name.asc] ,:recipe => @recipe)
		@current_user = session[:username]

		erb :recipe, :layout => :'layouts/default3'
	end


	post '/home/new-recipe' do
		user = User.first(:username => session[:username])
		if (!user.is_a? NilClass)
			rec = Recipe.first(:name => params[:recipe_name].gsub!('=',''), :username => session[:username])
			content_type 'application/json'
			if (rec.is_a? NilClass) #Si no se encuentra en la bbdd la creamos
				recipe = Recipe.new
				recipe.name = params[:recipe_name]
				recipe.nration = params[:nration]
				recipe.username = user.username
				recipe.pos = params[:order]
				recipe.type = params[:type]
				recipe.nivel = params[:nivel]
				recipe.production_time = params[:time]
				if (params[:vegan] == "yes")
					recipe.vegan = true
				else
					recipe.vegan = false
				end
				if (params[:allergens] == "")
					recipe.warning = ""
				else
					recipe.warning = params[:allergens]
				end
				if (params[:origin] == "")
					recipe.origin = ""
				else
					recipe.origin = params[:origin]
				end
				recipe.save
				{:control => 0}.to_json
			else
				{:control => 1}.to_json #Esa receta ya se encuentra en la bbdd
			end
		else
			redirect '/'
		end
	end

	post '/home/new-ingredient' do
		user = User.first(:username => session[:username])
		if (!user.is_a? NilClass)
			@recipe = Recipe.first(:name => params[:recipe_name], :username => session[:username])
			content_type 'application/json'
			if (Ingredient.first(:name => params[:ing_name], :recipe => @recipe).is_a? NilClass) #Si no existe en esa receta
				if (!params[:instructions].empty?)
					params[:instructions] = params[:instructions].gsub(/<\/?[^>]*>/, '').gsub(/\n\n+/, "\n").gsub(/^\n|\n$/, '')
					@recipe.update(:instructions => params[:instructions])
				end
				case params[:quantity_op]
				when 'Quantity'
					Ingredient.first_or_create(:name => params[:ing_name], :cost => params[:ing_cost], :unity_cost => params[:ing_unity_cost], :quantity => params[:n_quantity], :weight => 0.0, :weight_un => "", :volume => 0.0, :volume_un => "", :decrease => params[:ing_decrease], :recipe => @recipe)
				when 'Weight'
					Ingredient.first_or_create(:name => params[:ing_name], :cost => params[:ing_cost], :unity_cost => params[:ing_unity_cost], :quantity => 0, :weight => params[:n_quantity], :weight_un => params[:weight_un], :volume => 0.0, :volume_un => "", :decrease => params[:ing_decrease], :recipe => @recipe)
				when 'Volume'
					Ingredient.first_or_create(:name => params[:ing_name], :cost => params[:ing_cost], :unity_cost => params[:ing_unity_cost], :quantity => 0, :weight => 0.0, :weight_un => "", :volume => params[:n_quantity], :volume_un => params[:volume_un], :decrease => params[:ing_decrease], :recipe => @recipe)
				end
				nuevo_costo = (@recipe.cost + (params[:ing_cost].to_f * params[:n_quantity].to_f)).round(2)
				nuevo_costo_rat = (nuevo_costo/@recipe.nration).round(2)
				puts "-->nuevo_costo= #{nuevo_costo}"
				puts "-->nuevo_costo_rat= #{nuevo_costo_rat}"
				@recipe.update(:cost => nuevo_costo,:ration_cost => nuevo_costo_rat)
				{:control => 0, :cost => nuevo_costo, :ration_cost => nuevo_costo_rat}.to_json
			else
				{:control => 1}.to_json #Ese ingrediente ya se encuentra en la bbdd
			end
		else
			{:control => -1}
		end
	end


	get '/home/edit-recipe/:name' do
		rec = params[:name]
		rec.gsub!('-',' ')
		@rec = Recipe.first(:name => rec, :username => session[:username])
		@ing = Ingredient.all(:order => [:name.asc], :recipe => @rec)

		erb :'edit-recipe', :layout => :'layouts/default3'
	end


	post '/home/edit-recipe/:name' do
		content_type 'application/json'
		if (!User.first(:username => session[:username]).is_a? NilClass)
			rec = Recipe.first(:name => params[:recipe_name], :username => session[:username])
			if (!rec.is_a? NilClass)
				rec.update(:nration => params[:nration])
				rec.update(:ration_cost => (rec.cost / params[:nration].to_i).round(2));
				rec.update(:pos => params[:order])
				rec.update(:type => params[:type])
				rec.update(:nivel => params[:nivel])
				rec.update(:production_time => params[:time])
				if (params[:vegan] == "yes")
					rec.update(:vegan => true)
				else
					rec.update(:vegan => false)
				end
				if (params[:allergens] == "")
					rec.update(:warning => "")
				else
					rec.update(:warning => params[:allergens])
				end
				if (params[:origin] == "")
					rec.update(:origin => "")
				else
					rec.update(:origin => params[:origin])
				end
				if (params[:instructions] == "")
					rec.update(:instructions => "")
				else
					rec.update(:instructions => params[:instructions])
				end
				{:control => 0, :user => rec.username}.to_json #Actualizado con exito
			end
		else
			{:control => -1}.to_json #Error
		end
	end


	post '/home/delete-recipe/:name' do
		#params[:name].gsub!('-',' ')
		rec = Recipe.first(:name => params[:recipe_name], :username => session[:username])
		content_type 'application/json'
		if (session[:username] == rec.username)
			Ingredient.all(:recipe => rec).destroy
			rec.destroy
			{:control => 0}.to_json
		else
			{:control => 1}.to_json
		end
	end


	post '/home/:recipe_name/add-ingredient' do
		rec = Recipe.first(:name => params[:recipe_name], :username => session[:username])
		content_type 'application/json'
		if (!rec.is_a? NilClass)
			if (Ingredient.first(:name => params[:ing_name], :recipe => rec).is_a? NilClass) #Si no existe en esa receta
				case params[:quantity_op]
				when 'Quantity'
					Ingredient.first_or_create(:name => params[:ing_name], :cost => params[:ing_cost], :unity_cost => params[:ing_unity_cost], :quantity => params[:n_quantity], :weight => 0.0, :weight_un => "", :volume => 0.0, :volume_un => "", :decrease => params[:ing_decrease], :recipe => rec)
				when 'Weight'
					Ingredient.first_or_create(:name => params[:ing_name], :cost => params[:ing_cost], :unity_cost => params[:ing_unity_cost], :quantity => 0, :weight => params[:n_quantity], :weight_un => params[:weight_un], :volume => 0.0, :volume_un => "", :decrease => params[:ing_decrease], :recipe => rec)
				when 'Volume'
					Ingredient.first_or_create(:name => params[:ing_name], :cost => params[:ing_cost], :unity_cost => params[:ing_unity_cost], :quantity => 0, :weight => 0.0, :weight_un => "", :volume => params[:n_quantity], :volume_un => params[:volume_un], :decrease => params[:ing_decrease], :recipe => rec)
				end
				nuevo_costo = (rec.cost + (params[:ing_cost].to_f * params[:n_quantity].to_f)).round(2)
				nuevo_costo_rat = (nuevo_costo/rec.nration).round(2)
				rec.update(:cost => nuevo_costo,:ration_cost => nuevo_costo_rat)
				{:control => 0, :cost => nuevo_costo, :ration_cost => nuevo_costo_rat}.to_json
			else
				{:control => 2}.to_json #Ese ingrediente ya existe en la receta
			end
		else
			{:control => 1}.to_json #Error. No se encuentra esa receta
		end
	end


	post '/home/delete-ingredient/:name' do
		rec = Recipe.first(:name => params[:recipe_name], :username => session[:username])
		content_type 'application/json'
		if (!rec.is_a? NilClass)
			params[:name].gsub!('-',' ')
			ing = Ingredient.first(:name => params[:name], :recipe => rec)
			if (!ing.is_a? NilClass)
				if (ing.weight != 0)
					n = ing.weight * ing.cost
				elsif (ing.volume != 0)
					n = ing.volume * ing.cost
				else
					n = ing.quantity * ing.cost
				end
				nuevo_costo = (rec.cost - n).round(2)
				rec.update(:cost => nuevo_costo)
				rec.update(:ration_cost => (nuevo_costo/rec.ration_cost).round(2))
				ing.destroy
				{:control => 0, :cost => nuevo_costo, :ration_cost => rec.ration_cost}.to_json #Ing borrado con exito
			else
				{:control => 2}.to_json #No existe ingrediente
			end
		else
			{:control => 1}.to_json #No existe recipe
		end
	end

=begin
#Edit Ingredient
	post '/home/edit-ingredient/:name' do
		#params[:name].gsub!('-',' ')
		rec = Recipe.first(:name => params[:recipe_name])
		content_type 'application/json'
		if (session[:username] == rec.username)
			Ingredient.all(:recipe => rec).destroy
			rec.destroy
			{:control => 0}.to_json
		else
			{:control => 1}.to_json
		end
	end
=end

################################# OTROS ##################################
	get '/home/settings' do
		@user = User.first(:username => session[:username])
		if (!@user.is_a? NilClass)
			erb :settings, :layout => :'layouts/default2'
		else
			redirect '/'
		end
	end


	# start the server if ruby file executed directly
  	run! if app_file == $0
end
