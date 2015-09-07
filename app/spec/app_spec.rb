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

describe "Test App: Check routes" do

	def app
    	MyApp
	end

	it "Access to welcome page" do
		get '/' 
		assert last_response.ok?
		assert last_response.body.include? 'Welcome to ChefManagement'
	end

	it "Access to register page" do
		get '/register' 
		assert last_response.ok?
		assert last_response.body.include? 'Create a new account'
	end

	it "Check login" do
		user = User.first_or_create(:username => "test", :email => "email@mail.com", :password => "1234")
		post '/login',:name => user.username, :password => user.password
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
		user.destroy
	end

	it "Check Log out" do
		user = User.first_or_create(:username => "test", :email => "email@mail.com", :password => "1234")
		post 'http://localhost:4567/login',:name => user.username, :password => user.password
		assert last_response.ok?
		get 'http://localhost:4567/logout'
		user.destroy
		assert_equal "http://localhost:4567/logout", last_request.url.to_s
	end

end


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

end