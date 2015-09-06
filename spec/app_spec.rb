# -*- coding: utf-8 -*-
require 'coveralls'
Coveralls.wear!

require_relative './../app/controllers/app.rb'
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'rubygems'
require 'rspec'
require 'test/unit'

include Rack::Test::Methods
include Test::Unit::Assertions
include AppHelpers

describe "Test App: Get Methods" do

	def app
    	MyApp
	end


end
