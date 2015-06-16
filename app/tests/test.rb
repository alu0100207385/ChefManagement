# -*- coding: utf-8 -*-
require_relative '../controllers/app.rb'
require 'test/unit'
require 'minitest/autorun'
require 'rack/test'
require 'selenium-webdriver'
require 'rubygems'

include Rack::Test::Methods

def app
   Sinatra::Application
end

describe "Test Chat App: Check pages and links" do
   
	before :all do
		@browser = Selenium::WebDriver.for :firefox
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

end