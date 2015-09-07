# -*- coding: utf-8 -*-
require 'coveralls'
Coveralls.wear!

require_relative './../controllers/app.rb'
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

	it "Check register" do
		post '/register', :username => "test", :password => '1234', :email => "email@mail.com"
		assert last_response.ok?
		assert_equal "{\"control\":0}", last_response.body
		User.first(:username => "test", :email => "email@mail.com").destroy
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

	it "Check recovery" do
		user = User.first_or_create(:username => "test", :email => "email@mail.com", :password => "1234")
		post '/recovery-account', :recovery_account => user.username
		assert last_response.ok?
		assert_equal "{\"control\":1}", last_response.body
		user.destroy
	end

	it "Check failiure route" do
		get '/auth/failure'
		expect(last_response).to be_ok
	end

end
