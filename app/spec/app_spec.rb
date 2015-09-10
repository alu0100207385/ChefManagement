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

require 'selenium-webdriver'

include Rack::Test::Methods
include Test::Unit::Assertions
include AppHelpers

describe "Test App: Check routes" do

	before :all do
		@browser = Selenium::WebDriver.for :firefox
		@site = 'http://localhost:9292/'
	end

	after :all do
		@browser.quit
	end

	it "#1.1. I can access welcome page" do
		@browser.get(@site)
		assert_equal((@browser.find_element(:id,"facebook-btn").text == "Sign In Facebook"), true)
	end


	it "#1.2. I can access register page" do
		@browser.get(@site+'register')
		@browser.manage.timeouts.implicit_wait = 3
		assert_equal(@browser.find_element(:id,"reg").enabled?, false)
	end

	it "#1.3. I can access home page" do
		user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")
		@browser.get(@site)
		@browser.find_element(:id,"username").send_keys(user.username)
		@browser.find_element(:id,"pass").send_keys("1234")
		@browser.manage.timeouts.implicit_wait = 3
		@browser.find_element(:id,"enter").click
		sleep(1)
		( "http://localhost:9292/home" == @browser.current_url)? (a = true) : (a = false)
		@browser.manage.timeouts.implicit_wait = 3
		@browser.find_element(:id,"logout").click
		( "http://localhost:9292/" == @browser.current_url)? (b = true) : (b = false)
		user.destroy
		assert(a&&b)
	end



=begin
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
=end
end
