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
	prefs = {
	  :download => {
	    :prompt_for_download => false, 
	    :default_directory => "/usr/local/bin/chromedriver"
	  }
	}
	@browser = Selenium::WebDriver.for :chrome, :prefs => prefs
=end


describe "#1. Test Chat App: Check pages and links" do

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

	it "#1.1. I can access welcome page" do
		control = false
		if (@browser.find_element(:id,"facebook-btn").text == "Sign In Facebook") and (@browser.find_element(:id,"google-btn").text == "Sign In Google+")
			control = true
		end
		assert_equal(control, true)
	end

	it "#1.2. I can access register page" do
		@browser.find_element(:id,"register").click
		@browser.manage.timeouts.implicit_wait = 3
		assert_equal("http://localhost:9292/register", @browser.current_url)
	end

	it "#1.3. I can activate register button" do
		@browser.find_element(:id,"register").click
		@browser.manage.timeouts.implicit_wait = 3
		@browser.find_element(:id,"accept_terms").click
		assert(@browser.find_element(:id, "reg").enabled?, "Register button button should be activated")
	end

	#....
end

##################################################################################################
=begin
describe "#2. Test Chat App: User create and login" do
	
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


	it "#2.1. I can log in & log out" do
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

##################################################################################################

describe "#3. Test Chat App: Check felper functions" do

	it "#3.1. Function: GetIds" do
		assert_equal(GetIds("recipe-name_username"),["recipe-name","username"])
	end

	it "#3.2. Function: calculator (equal)" do
		assert_equal(5, calculator(5, 3, 3))
	end

	it "#3.3. Function: calculator (not equal)" do
		assert_not_equal(3, calculator(3, 3, 2))
	end

	it "#3.4. Function: GenerateNewRecipeName" do
		cad = GenerateNewRecipeName("rice")
		a = cad.include? "rice"
		if (cad.size == 8)
			b = true
		else
			b = false
		end
		assert(a&&b)
	end

	it "#3.5. Function: to_bool" do
		a = to_bool("true")
		b = to_bool("false")
		assert(a&&!b)
	end

	#....
end


##################################################################################################

describe "#4. Test Chat App: I can browse in the application" do

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
		@browser.find_element(:id,"username").send_keys(@user.username)
		@browser.find_element(:id,"pass").send_keys("1234")
		@browser.manage.timeouts.implicit_wait = 3
		@browser.find_element(:id,"enter").click
		sleep(1)
	end

	after :all do
		@browser.manage.timeouts.implicit_wait = 2
		@browser.find_element(:id,"logout").click
		@browser.manage.timeouts.implicit_wait = 2
		@browser.quit
		@user.destroy
		sleep(2)
	end

	it "#4.1. I can acces to recipe list" do
		assert_equal(@browser.find_element(:id,"section-title").text, "Recipe list")
	end

	it "#4.2. I can acces to recipe calculator" do
		@browser.find_element(:id,"calculator").click
		@browser.manage.timeouts.implicit_wait = 3
		assert_equal(@browser.find_element(:id,"section-title").text, "Recipe calculator")
	end

	it "#4.3. I can acces to new recipe" do
		@browser.find_element(:id,"make-recipe").click
		@browser.manage.timeouts.implicit_wait = 3
		assert_equal(@browser.find_element(:id,"section-title").text, "New recipe")
	end

	it "#4.4. I can acces to recipe import" do
		@browser.find_element(:id,"import-recipe").click
		@browser.manage.timeouts.implicit_wait = 3
		assert_equal(@browser.find_element(:id,"section-title").text, "Import recipe")
	end

	it "#4.5. I can acces to recipe export" do
		@browser.find_element(:id,"export-recipe").click
		@browser.manage.timeouts.implicit_wait = 3
		assert(@browser.find_element(:id,"section-title").text, "Export recipe")
	end

end

##################################################################################################

describe "#5. Test Chat App: Recipes" do
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
		@browser.find_element(:id,"username").send_keys(@user.username)
		@browser.find_element(:id,"pass").send_keys("1234")
		@browser.manage.timeouts.implicit_wait = 3
		@browser.find_element(:id,"enter").click
		sleep(1)
	end

	after :all do
		@browser.manage.timeouts.implicit_wait = 2
		@browser.find_element(:id,"logout").click
		@browser.manage.timeouts.implicit_wait = 2
		@browser.quit
		@user.destroy
		sleep(2)
	end

	it "#5.1. I can create a new recipe" do
		@browser.find_element(:id,"make-recipe").click
		@browser.manage.timeouts.implicit_wait = 3
		@browser.find_element(:id,"recipe-name").send_keys("new recipe name")
		@browser.manage.timeouts.implicit_wait = 2
		@browser.find_element(:id,"save-recipe").click
		sleep(2)
		recipe = Recipe.first(:name => "new recipe name", :username => @user.username)
		if !recipe.is_a? NilClass
			a = true
			recipe.destroy
		else
			a = false;
		end
		assert(a)
	end
end
=end