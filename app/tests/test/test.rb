# -*- coding: utf-8 -*-
require_relative '../app.rb'
require 'test/unit'
require 'minitest/autorun'
require 'rack/test'
require 'rubygems'

include Rack::Test::Methods

def app
	Sinatra::Application
end

describe "Test Chat App: Check pages and links" do

	before :all do
		# previous install to run tests
	end

	after :all do
		# closing processes tests
	end

	it "##function test" do
		#code
	end
end