# -*- coding: utf-8 -*-
require 'coveralls'
Coveralls.wear!

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'rubygems'
require 'rspec'
require 'test/unit'
require_relative "./../helpers/helpers.rb"

include Rack::Test::Methods
include Test::Unit::Assertions
include AppHelpers

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
