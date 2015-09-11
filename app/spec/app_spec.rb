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


=begin
	it "Check /home/new-recipe when recipe exists" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		recipe = Recipe.create(:name => "recipe", :nration => 1, :username => "test")
		current_session.rack_session[:username] = "test"
		post '/home/new-recipe',:recipe_name => "recipe"
		assert_equal "{\"control\":1}", last_response.body
		recipe.destroy
		user.destroy
	end
=end


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
		get '/auth/google_oauth2/callback'
		expect(last_response).to be_redirect
	end

	it "Check callback FAIL for Facebook" do
		get '/auth/facebook/callback'
		expect(last_response).to be_redirect
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

	it "Acces to home FAIL" do
		get '/home'
		expect(last_response).to be_redirect
	end

	it "Acces to home SUCCESSFUL" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		current_session.rack_session[:username] = "test"
		get '/home'
		assert last_response.body.include? 'Menu'
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
		post '/home/new-recipe'
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
