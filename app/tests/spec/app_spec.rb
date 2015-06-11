# -*- coding: utf-8 -*-

require_relative '../app.rb'
require_relative '../helper/helpers.rb'
ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'rubygems'
require 'rspec'
# require 'test/unit'
# require 'rspec/expectations'

include Rack::Test::Methods
include Test::Unit::Assertions
include AppHelpers

describe "Spec test name" do

	def app
		Sinatra::Application
	end

	it "Spec test" do
		# code
	end

end