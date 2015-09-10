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
		expect(last_response).to be_redirect   # This works, but I want it to be more specific
  		#follow_redirect!
  		#expect(last_request.url).to eql '/home'
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
