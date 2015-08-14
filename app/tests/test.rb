# -*- coding: utf-8 -*-
require_relative '../controllers/app.rb'
require 'rubygems'
require 'test/unit'
require 'minitest/autorun'
require 'rack/test'
require 'selenium-webdriver'
require 'data_mapper'

include Rack::Test::Methods
include Test::Unit::Assertions

def app
   Sinatra::Application
end

=begin
def setup
	case ARGV[0].to_s
		when 'firefox'
			@browser = Selenium::WebDriver.for :firefox
		when 'chrome'
			@browser = Selenium::WebDriver.for :chrome
		else #Si no hay argumentos, default webdriver = firefox
			@browser = Selenium::WebDriver.for :firefox
	end
	@site = 'http://localhost:9292/'
	@browser.get(@site)
	@browser.manage().window().maximize()
	@browser.manage.timeouts.implicit_wait = 5
end

def teardown
	@browser.quit
end
=end

=begin			
	prefs = {
	  :download => {
	    :prompt_for_download => false, 
	    :default_directory => "/usr/local/bin/chromedriver"
	  }
	}
	@browser = Selenium::WebDriver.for :chrome, :prefs => prefs
=end


describe "Test Chat App: Check pages and links" do
   
	before :all do
		case ARGV[0].to_s
			when 'firefox'
				@browser = Selenium::WebDriver.for :firefox
			when 'chrome'
				@browser = Selenium::WebDriver.for :chrome
			else #Si no hay argumentos, default webdriver = firefox
				@browser = Selenium::WebDriver.for :firefox
		end
		@site = 'http://localhost:9292/'
		@browser.get(@site)
		@browser.manage().window().maximize()
		@browser.manage.timeouts.implicit_wait = 5
	end

	after :all do
		@browser.quit
	end

	it "##1. I can access welcome page" do
		control = false
		if (@browser.find_element(:id,"facebook-btn").text == "Sign In Facebook") and (@browser.find_element(:id,"google-btn").text == "Sign In Google+")
			control = true
		end
		assert_equal(control, true)
	end

	it "##2. I can access register page" do
		@browser.find_element(:id,"register").click
		@browser.manage.timeouts.implicit_wait = 3
		assert_equal("http://localhost:9292/register", @browser.current_url)
	end

	it "##3. I can activate register button" do
		@browser.find_element(:id,"register").click
		@browser.manage.timeouts.implicit_wait = 3
		@browser.find_element(:id,"accept_terms").click
		assert(@browser.find_element(:id, "reg").enabled?, "Register button button should be activated")
	end

	#....

end

##################################################################################################

describe "Test Chat App: User create and login" do
	
	before :all do
		case ARGV[0].to_s
			when 'firefox'
				@browser = Selenium::WebDriver.for :firefox
			when 'chrome'
				@browser = Selenium::WebDriver.for :chrome
			else #Si no hay argumentos, default webdriver = firefox
				@browser = Selenium::WebDriver.for :firefox
		end
		@site = 'http://localhost:9292/'
		@browser.get(@site)
		@browser.manage().window().maximize()
		@browser.manage.timeouts.implicit_wait = 5
		
		@user = User.create(:username => "test", :email => "email@mail.com", :password => "1234")

	end

	after :all do
		@browser.manage.timeouts.implicit_wait = 2
		@browser.quit
		@user.destroy
		sleep(2)
	end


	it "##1. I can log in & log out" do
		@browser.find_element(:id,"username").send_keys(@user.username)
		@browser.find_element(:id,"pass").send_keys("1234")
		@browser.manage.timeouts.implicit_wait = 3
		@browser.find_element(:id,"enter").click
		sleep(1)
		( "http://localhost:9292/home" == @browser.current_url)? (a = true) : (a = false)
		@browser.manage.timeouts.implicit_wait = 3
		@browser.find_element(:id,"logout").click
		( "http://localhost:9292/" == @browser.current_url)? (b = true) : (b = false)
		assert(a&&b)
	end

	#....
end

=begin
describe "Test Chat App: Helper functions tests" do
	#....
end
=end