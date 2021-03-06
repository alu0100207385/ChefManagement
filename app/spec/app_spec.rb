# -*- coding: utf-8 -*-
require 'coveralls'
Coveralls.wear!

require_relative './../controllers/app.rb'
require_relative "./../helpers/helpers.rb"
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'rubygems'
require 'rspec'
require 'test/unit'
require 'data_mapper'

include Rack::Test::Methods
include Test::Unit::Assertions
include AppHelpers

require File.join(File.dirname(__FILE__), 'app_spec_helper.rb')

describe "Test App: Check routes" do

	def app
    	MyApp
	end


	it "Access to root app (session out)" do
		get '/' 
		assert last_response.ok?
		assert last_response.body.include? 'Welcome to ChefManagement'
	end

	it "Access to root app (session in)" do
		current_session.rack_session[:username] = "foo"
    	get '/'
		expect(last_response).to be_redirect
	end

	it "Post redirect to root" do
		post '/'
		expect(last_response).to be_redirect
	end

	it "Access to register page" do
		get '/register' 
		assert last_response.ok?
		assert last_response.body.include? 'Create a new account'
	end

	it "Access to register page when session in" do
		user = User.create(:username => "test", :email => "foo@mail.com", :password => "1234")
		current_session.rack_session[:username] = "test"
		get '/register' 
		expect(last_response).to be_redirect
		follow_redirect!
  		expect(last_request.path).to eq('/')
  		user.destroy
	end

	it "Check register OK" do
		post '/register', :username => "test", :password => '1234', :email => "email@mail.com"
		assert last_response.ok?
		assert_equal "{\"control\":0}", last_response.body
		User.first(:username => "test", :email => "email@mail.com").destroy
	end

	it "Check register FAIL: username exists" do
		user = User.create(:username => "test", :email => "foo@mail.com", :password => "1234")
		post '/register', :username => "test", :password => '1234', :email => "email@mail.com"
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
		user.destroy
	end

	it "Check register FAIL: email exists" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		post '/register', :username => "foo", :password => '1234', :email => "email@mail.com"
		assert last_response.ok?
		assert_equal "{\"control\":2}", last_response.body
		user.destroy
	end

	it "Check login OK" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		post '/login',:username => user.username, :password => "1234"
		assert last_response.ok?
		assert_equal "{\"control\":0}", last_response.body
		user.destroy
	end

	it "Check login FAIL: user no exists" do
		post '/login',:username => "foo", :password => "1234"
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
	end

	it "Check login FAIL: error password" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		post '/login',:username => user.username, :password => "123"
		assert last_response.ok?
		assert_equal "{\"control\":2}", last_response.body
		user.destroy
	end

	it "Check Log out" do
		current_session.rack_session[:username] = "foo"
    	get '/logout' 
    	current_session.rack_session[:username].clear #Ejecutamos el clear para la sesion en rack
    	assert (current_session.rack_session[:username].empty?)
		expect(last_response).to be_redirect
	end

	it "Check callback FAIL for Google" do
		get '/auth/:name/callback', :name => "google_oauth2"
		expect(last_response).to be_redirect
		follow_redirect!
  		expect(last_request.path).to eq('/auth/failure')
	end

	it "Check callback FAIL for Facebook" do
		get '/auth/:name/callback', :name => "facebook"
		expect(last_response).to be_redirect
		follow_redirect!
  		expect(last_request.path).to eq('/auth/failure')
	end

	it "Check recovery when user exists" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		post '/recovery-account', :recoveryusername => user.username
		assert last_response.ok?
		assert_equal "{\"control\":0}", last_response.body
		user.destroy
	end

	it "Check recovery when user not exists" do
		post '/recovery-account', :recoveryusername => "foo"
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
	end

	it "Access to home FAIL" do
		get '/home'
		expect(last_response).to be_redirect
	end

	it "Access to home SUCCESSFUL" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		current_session.rack_session[:username] = "test"
		get '/home'
		assert last_response.body.include? 'Menu'
		recipe.destroy
		user.destroy
	end

	it "Check /home/recipe when user not exists" do
		current_session.rack_session[:username] = "foo"
		get '/home/recipe'
		assert last_response.ok?
		assert_equal "{\"control\":2}", last_response.body
	end

	it "Check /home/recipe when recipe exists" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		current_session.rack_session[:username] = "test"
		get '/home/recipe'
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
		user.destroy
	end

	it "Check /home/recipe when recipe not exists" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		recipe = Recipe.create(:name => "test_recipe", :nration => 1, :username => "test")
		current_session.rack_session[:username] = "test"
		get '/home/recipe', :recipe => "test_recipe", :user => "test"
		assert last_response.ok?
		assert_equal "{\"control\":0,\"username\":\"test\"}", last_response.body
		user.destroy
		recipe.destroy
	end

	it "Check /home/new-recipe redirect OK" do
		current_session.rack_session[:username] = "test"
		post '/home/new-recipe', :recipe_name => "recipe"
		expect(last_response).to be_redirect
		follow_redirect!
  		expect(last_request.path).to eq('/')
	end

	it "Check /home/new-recipe FAIL: recipe already exists" do
		current_session.rack_session[:username] = "test"
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		post '/home/new-recipe', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
		recipe.destroy
		user.destroy
	end

	it "Check /home/new-recipe OK" do
		current_session.rack_session[:username] = "test"
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		post '/home/new-recipe', :recipe_name => "recipe", :nration => 2, :origin => "Spain"
		assert last_response.ok?
		assert_equal "{\"control\":0,\"user\":\"test\"}", last_response.body
		assert !(Recipe.first(:name => "recipe", :username => user.username).is_a? NilClass)
		Recipe.first(:name => "recipe", :username => user.username).destroy
		user.destroy
	end

	it "Check /home/new-recipe OK (with all params)" do
		current_session.rack_session[:username] = "test"
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		post '/home/new-recipe', :recipe_name => "recipe", :nration => 2, :vegan => "yes", :allergens => "", :origin => ""
		assert last_response.ok?
		assert_equal "{\"control\":0,\"user\":\"test\"}", last_response.body
		assert !(Recipe.first(:name => "recipe", :username => user.username).is_a? NilClass)
		Recipe.first(:name => "recipe", :username => user.username).destroy
		user.destroy
	end

	it "Check /home/new-ingredient: FAIL (session out)" do
		post '/home/new-ingredient'
		assert last_response.ok?
		assert_equal "{\"control\":-1}", last_response.body
	end

	it "Check add ingredient: FAIL (session out or recipe does not exist)" do
		post '/home/:recipe-name/add-ingredient'
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
	end

	it "Check add ingredient: FAIL (ingredient already exists)" do
		current_session.rack_session[:username] = "test"
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		ingredient = Ingredient.create(:name => "ing", :cost => 2, :quantity => 1, :recipe => recipe)
		post '/home/recipe/add-ingredient', :ing_name => "ing"
		assert last_response.ok?
		assert_equal "{\"control\":2}", last_response.body
		ingredient.destroy
		recipe.destroy
	end

	it "Check add ingredient: OK (quantity)" do
		current_session.rack_session[:username] = "test"
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		recipe2 = Recipe2.create(:name => "recipe", :nration => 1, :username => "test", :recipe => recipe)
		post '/home/recipe/add-ingredient', :ing_name => "ing", :quantity_op => 'Quantity', :ing_name => "ing", :ing_cost => 2, :ing_unity_cost => "€/u", :n_quantity => 1, :ing_decrease => 0
		assert last_response.ok?
		assert_equal "{\"control\":0,\"cost\":4.0,\"ration_cost\":2.0}", last_response.body
		Ingredient.first(:name => "ing", :recipe => recipe).destroy
		recipe2.destroy
		recipe.destroy
	end

	it "Check add ingredient: OK (weight)" do
		current_session.rack_session[:username] = "test"
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		post '/home/recipe/add-ingredient', :ing_name => "ing" ,:quantity_op => 'Weight', :ing_name => "ing", :ing_cost => 2, :weight_un => 1, :ing_unity_cost => "€/kg", :n_quantity => 1, :ing_decrease => 0
		assert last_response.ok?
		assert_equal "{\"control\":0,\"cost\":2.0,\"ration_cost\":2.0}", last_response.body
		Ingredient.first(:name => "ing", :recipe => recipe).destroy
		recipe.destroy
	end

	it "Check add ingredient: OK (volume)" do
		current_session.rack_session[:username] = "test"
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		post '/home/recipe/add-ingredient', :ing_name => "ing" ,:quantity_op => 'Volume', :ing_name => "ing", :ing_cost => 2, :volume_un => 1, :ing_unity_cost => "€/l", :n_quantity => 1, :ing_decrease => 0
		assert last_response.ok?
		assert_equal "{\"control\":0,\"cost\":2.0,\"ration_cost\":2.0}", last_response.body
		Ingredient.first(:name => "ing", :recipe => recipe).destroy
		recipe.destroy
	end

	it "Check delete ingredient: FAIL (recipe not exists)" do
		current_session.rack_session[:username] = "test"
		post '/home/delete-ingredient/ing', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
	end

	it "Check delete ingredient: FAIL (ingredient not exists)" do
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		current_session.rack_session[:username] = "test"
		post '/home/delete-ingredient/ing', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":2}", last_response.body
		recipe.destroy
	end

	it "Check delete ingredient: OK (quantity)" do
		recipe = Recipe.create(:name => "recipe", :cost => 10, :ration_cost => 5, :nration => 2, :username => "test")
		rec_compuesta = Recipe.create(:name => "recipeX", :cost => 10, :ration_cost => 10, :nration => 1, :username => "test")
		rec2 = Recipe2.create(:name => "recipe", :nration => 5, :username => "test", :recipe => rec_compuesta)
		ingredient = Ingredient.create(:name => "ing", :cost => 10, :unity_cost => 10, :quantity => 1, :weight => 0, :volume => 0, :recipe => recipe)
		current_session.rack_session[:username] = "test"
		post '/home/delete-ingredient/ing', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":0,\"cost\":0.0,\"ration_cost\":0.0}", last_response.body
		assert Ingredient.first(:name => "ing", :recipe => recipe).is_a? NilClass
		rec2.destroy
		recipe.destroy
		rec_compuesta.destroy
	end

	it "Check delete ingredient: OK (weight)" do
		recipe = Recipe.create(:name => "recipe", :nration => 1, :cost => 2, :ration_cost => 2,:username => "test")
		ingredient = Ingredient.create(:name => "ing", :cost => 2, :quantity => 0, :weight=> 1, :volume => 0, :recipe => recipe)
		current_session.rack_session[:username] = "test"
		post '/home/delete-ingredient/ing', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":0,\"cost\":0.0,\"ration_cost\":0.0}", last_response.body
		assert Ingredient.first(:name => "ing", :recipe => recipe).is_a? NilClass
		recipe.destroy
	end

	it "Check delete ingredient: OK (volume)" do
		recipe = Recipe.create(:name => "recipe", :nration => 1, :cost => 2, :ration_cost => 2,:username => "test")
		ingredient = Ingredient.create(:name => "ing", :cost => 2, :quantity => 0, :weight=> 0, :volume => 1, :recipe => recipe)
		current_session.rack_session[:username] = "test"
		post '/home/delete-ingredient/ing', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":0,\"cost\":0.0,\"ration_cost\":0.0}", last_response.body
		assert Ingredient.first(:name => "ing", :recipe => recipe).is_a? NilClass
		recipe.destroy
	end

	it "Check /home/edit-recipe: FAIL (session out)" do
		post '/home/edit-recipe/:name'
		assert last_response.ok?
		assert_equal "{\"control\":-1}", last_response.body
	end

	it "Check access home/edit-ingredient FAIL: (session out) or recipe does not exist" do
		get '/home/edit-ingredient/:name'
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
	end

	it "Check access home/edit-ingredient FAIL: ingredient does not exist" do
		current_session.rack_session[:username] = "test"
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		get '/home/edit-ingredient/ing', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":2}", last_response.body
		recipe.destroy
	end
	
	it "Check access home/edit-ingredient OK (weight)" do
		current_session.rack_session[:username] = "test"
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		ingredient = Ingredient.create(:name => "ing", :cost => 2, :quantity => 1, :recipe => recipe)
		get '/home/edit-ingredient/ing', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":\"weight\",\"cost\":2.0,\"weight\":null,\"weight_un\":null,\"decrease\":0.0}", last_response.body
		ingredient.destroy
		recipe.destroy
	end

	it "Check access home/edit-ingredient OK (volume)" do
		current_session.rack_session[:username] = "test"
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		ingredient = Ingredient.create(:name => "ing", :cost => 2, :quantity => 1, :weight => 0, :volume => 1, :recipe => recipe)
		get '/home/edit-ingredient/ing', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":\"volume\",\"cost\":2.0,\"volume\":1.0,\"volume_un\":null,\"decrease\":0.0}", last_response.body
		ingredient.destroy
		recipe.destroy
	end

	it "Check access home/edit-ingredient OK (quantity)" do
		current_session.rack_session[:username] = "test"
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		ingredient = Ingredient.create(:name => "ing", :cost => 2, :quantity => 1, :weight => 0, :volume => 0, :recipe => recipe)
		get '/home/edit-ingredient/ing', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":\"quantity\",\"cost\":2.0,\"quantity\":1,\"decrease\":0.0}", last_response.body
		ingredient.destroy
		recipe.destroy
	end

	it "Check edit ingredient when recipe does not change/exist" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		current_session.rack_session[:username] = "test"
		post '/home/edit-ingredient/:name', :recipe_name => "recipe"
		assert last_response.ok?
		assert_equal "{\"control\":2}", last_response.body
		user.destroy
	end

	it "Check edit ingredient OK (quantity & change ing name)" do
		recipe = Recipe.create(:name => "recipe", :cost => 10, :ration_cost => 5, :nration => 2, :username => "test")
		rec_compuesta = Recipe.create(:name => "recipeX", :cost => 10, :ration_cost => 10, :nration => 1, :username => "test")
		rec2 = Recipe2.create(:name => "recipe", :nration => 5, :username => "test", :recipe => rec_compuesta)
		ingredient = Ingredient.create(:name => "ing", :cost => 10, :unity_cost => 10, :quantity => 1, :weight => 0, :volume => 0, :recipe => recipe)
		current_session.rack_session[:username] = "test"
		post '/home/edit-ingredient/ing', :recipe_name => "recipe", :new_name => "ingX", :cost => 6, :unity_cost => "euro/u", :quantity_op => 'Quantity', :n_quantity => 1, :decrease => 0
		assert last_response.ok?
		assert_equal "{\"control\":0,\"control2\":\"quantity\",\"name\":\"ingX\",\"cost\":6.0,\"unity_cost\":\"euro/u\",\"quantity\":1,\"decrease\":0.0,\"rec_cost\":6.0,\"rec_ration_cost\":3.0}", last_response.body
		Ingredient.first(:name => "ingX", :recipe => recipe).destroy
		rec2.destroy
		recipe.destroy
		rec_compuesta.destroy
	end

	it "Check edit ingredient OK (weight)" do
		recipe = Recipe.create(:name => "recipe", :cost => 10, :ration_cost => 5, :nration => 2, :username => "test")
		ingredient = Ingredient.create(:name => "ing", :cost => 10, :unity_cost => 10, :quantity => 0, :weight => 1, :volume => 0, :recipe => recipe)
		current_session.rack_session[:username] = "test"
		post '/home/edit-ingredient/ing', :recipe_name => "recipe", :new_name => "ing", :cost => 6, :unity_cost => "euro/kg", :quantity_op => 'Weight', :weight_un => "kg", :n_quantity => 1, :decrease => 0
		assert last_response.ok?
		assert_equal "{\"control\":0,\"control2\":\"weight\",\"name\":\"ing\",\"cost\":6.0,\"unity_cost\":\"euro/kg\",\"weight\":1.0,\"weight_un\":\"kg\",\"decrease\":0.0,\"rec_cost\":6.0,\"rec_ration_cost\":3.0}", last_response.body
		ingredient.destroy
		recipe.destroy
	end

	it "Check edit ingredient OK (volume)" do
		recipe = Recipe.create(:name => "recipe", :cost => 10, :ration_cost => 5, :nration => 2, :username => "test")
		ingredient = Ingredient.create(:name => "ing", :cost => 10, :unity_cost => 10, :quantity => 0, :weight => 0, :volume => 1, :recipe => recipe)
		current_session.rack_session[:username] = "test"
		post '/home/edit-ingredient/ing', :recipe_name => "recipe", :new_name => "ing", :cost => 6, :unity_cost => "euro/l", :quantity_op => 'Volume', :n_quantity => 1, :volume_un => "l", :decrease => 0
		assert last_response.ok?
		assert_equal "{\"control\":0,\"control2\":\"volume\",\"name\":\"ing\",\"cost\":6.0,\"unity_cost\":\"euro/l\",\"volume\":1.0,\"volume_un\":\"l\",\"decrease\":0.0,\"rec_cost\":6.0,\"rec_ration_cost\":3.0}", last_response.body
		ingredient.destroy
		recipe.destroy
	end

	it "Check ingredient" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test", :cost => 6, :nration => 2, :ration_cost => 3)
		recipe2 = Recipe2.create(:id => 10, :name => "recipe2", :nration => 1, :username => "test", :recipe => recipe)
		current_session.rack_session[:username] = "test"
		post '/home/delete-ing-rec/:name', :original_recipe => "recipe", :rec_name => "recipe2", :rec_username => "test"
		assert last_response.ok?
		assert_equal "{\"control\":0,\"cost\":6.0,\"ration_cost\":3.0}", last_response.body
		recipe2.destroy
		recipe.destroy
		user.destroy
	end

	it "Check calculator (quantity)" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		recipe = Recipe.create(:name => "recipe", :nration => 2, :username => "test", :cost => 10, :ration_cost => 5)
		recipe2 = Recipe.create(:name => "recipe2", :nration => 2, :username => "test", :cost => 4, :ration_cost => 2)		
		rec2 = Recipe2.create(:name => "recipe2", :nration => 2, :username => "test", :recipe => recipe)
		ingredient = Ingredient.create(:name => "ing", :cost => 2, :quantity => 1, :weight => 0, :volume => 0, :recipe => recipe)
		ingredient2 = Ingredient.create(:name => "ingX", :cost => 4, :quantity => 1, :weight => 0, :volume => 0, :recipe => recipe2)
		current_session.rack_session[:username] = "test"
		get '/home/calculate', :recipe_name => "recipe", :recipe_username => "test", :nrations => "4"
		assert_equal "{\"control\":0,\"recipe_name\":\"recipe\",\"ing\":[[\"ing\",2,\"un\",2.0]],\"rec2\":[[\"recipe2\",\"test\",8.0]],\"instructions\":null}", last_response.body
		ingredient.destroy
		ingredient2.destroy
		rec2.destroy
		recipe2.destroy
		recipe.destroy
		user.destroy
	end

	it "Check calculator (weight)" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		recipe = Recipe.create(:name => "recipe", :nration => 2, :username => "test", :cost => 10, :ration_cost => 5)
		recipe2 = Recipe.create(:name => "recipe2", :nration => 2, :username => "test", :cost => 4, :ration_cost => 2)		
		rec2 = Recipe2.create(:name => "recipe2", :nration => 2, :username => "test", :recipe => recipe)
		ingredient = Ingredient.create(:name => "ing", :cost => 2, :quantity => 0, :weight => 1, :volume => 0, :recipe => recipe)
		ingredient2 = Ingredient.create(:name => "ingX", :cost => 4, :quantity => 0, :weight => 1, :volume => 0, :recipe => recipe2)
		current_session.rack_session[:username] = "test"
		get '/home/calculate', :recipe_name => "recipe", :recipe_username => "test", :nrations => "4"
		assert_equal "{\"control\":0,\"recipe_name\":\"recipe\",\"ing\":[[\"ing\",2.0,null,2.0]],\"rec2\":[[\"recipe2\",\"test\",8.0]],\"instructions\":null}", last_response.body
		ingredient.destroy
		ingredient2.destroy
		rec2.destroy
		recipe2.destroy
		recipe.destroy
		user.destroy
	end


	it "Check calculator (volume)" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		recipe = Recipe.create(:name => "recipe", :nration => 2, :username => "test", :cost => 10, :ration_cost => 5)
		recipe2 = Recipe.create(:name => "recipe2", :nration => 2, :username => "test", :cost => 4, :ration_cost => 2)		
		rec2 = Recipe2.create(:name => "recipe2", :nration => 2, :username => "test", :recipe => recipe)
		ingredient = Ingredient.create(:name => "ing", :cost => 2, :quantity => 0, :weight => 0, :volume => 1, :recipe => recipe)
		ingredient2 = Ingredient.create(:name => "ingX", :cost => 4, :quantity => 0, :weight => 0, :volume => 1, :recipe => recipe2)
		current_session.rack_session[:username] = "test"
		get '/home/calculate', :recipe_name => "recipe", :recipe_username => "test", :nrations => "4"
		assert_equal "{\"control\":0,\"recipe_name\":\"recipe\",\"ing\":[[\"ing\",2.0,null,2.0]],\"rec2\":[[\"recipe2\",\"test\",8.0]],\"instructions\":null}", last_response.body
		ingredient.destroy
		ingredient2.destroy
		rec2.destroy
		recipe2.destroy
		recipe.destroy
		user.destroy
	end

	it "Access to user settings: check redirect" do
		get '/home/settings'
		expect(last_response).to be_redirect
		follow_redirect!
  		expect(last_request.path).to eq('/')
	end

	it "Access to user settings: check redirect" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		current_session.rack_session[:username] = "test"
		get '/home/settings'
		assert last_response.ok?
		assert last_response.body.include? 'Profile'
  		user.destroy
	end

	it "Check edit user settings: without changes" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		current_session.rack_session[:username] = "test"
		post '/home/settings/edit-user', :new_email => "", :new_password => ""
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
		user.destroy
	end

	it "Check edit user settings: profile has changed (new password)" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		current_session.rack_session[:username] = "test"
		post '/home/settings/edit-user', :new_email => "", :new_password => "12345"
		assert last_response.ok?
		assert_equal "{\"control\":0}", last_response.body
		user.destroy
	end

	it "Check edit user settings: profile has changed (new email)" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		current_session.rack_session[:username] = "test"
		post '/home/settings/edit-user', :new_email => "test@mail.com", :new_password => ""
		assert last_response.ok?
		assert_equal "{\"control\":0}", last_response.body
		User.first(:username => "test").destroy
	end

	it "Check edit user settings: profile has not changed because email already exists" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		foo = User.create(:username => "foo", :email => "foo@mail.com", :password => "1234")
		current_session.rack_session[:username] = "test"
		post '/home/settings/edit-user', :new_email => "foo@mail.com", :new_password => ""
		assert last_response.ok?
		assert_equal "{\"control\":2}", last_response.body
		foo.destroy
		user.destroy
	end

	it "Check delete user: SUCCESS" do
		User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		Recipe2.create(:id => 10, :name => "recipe2", :nration => 1, :username => "test", :recipe => recipe)
		current_session.rack_session[:username] = "test"
		post '/home/settings/delete-user'
		assert User.first(:username => "test").is_a? NilClass
		assert Recipe.first(:name => "test", :username => "test").is_a? NilClass
		assert Recipe2.first(:id => 10).is_a? NilClass
		expect(last_response).to be_redirect
		follow_redirect!
  		expect(last_request.path).to eq('/')
	end

	it "Check failure route" do
		get '/auth/failure'
		expect(last_response).to be_ok
		assert last_response.body.include? 'Possible reasons'
	end

end

#########################################################################################

describe "Test Heleper functions" do

	def app
    	MyApp
	end

	it "Funtion: account_information" do
	   assert_equal(Mail::Message,account_information("Username","1234","mail@email.com","Tests for coverlls").class)
	end

	it "Funtion: merma" do
	   assert_equal merma(10, 50), 5
	end

	it "Funtion: GetIds" do
	   assert_equal GetIds("Username_Recipe"), ["Username", "Recipe"]
	end

	it "Funtion: calculator1" do
	   assert_equal calculator(25, 4, 2), 12
	end

	it "Funtion: calculator2" do
	   assert_equal calculator(25, 2, 2), 25
	end

	it "Function: GenerateNewRecipeName" do
		resul = false
		cad = GenerateNewRecipeName("rice")
		if (cad.include? "rice") and (cad.size == 8)
			resul = true
		end
		assert(resul)
	end

	it "Funtion: to_bool" do
		assert(to_bool("true")&&!to_bool("false"))
	end

	it "Function: ClearUpdates" do
		File.new("public/uploads/test.json", "w")
		ClearUpdates()
		assert_equal Dir.glob(File.dirname(__FILE__)+"/../../public/uploads/*.json").size, 0
		File.new("public/uploads/recipe.json", "w+") # Para mantener el archivo por defecto en el repositorio
	end

end
