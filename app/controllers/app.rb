# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra/base'
require 'sinatra/flash'

class App < Sinatra::Base

	#Sets paths
	set :root, File.dirname(__FILE__)
	set :views, File.dirname(__FILE__) + "/../views"
	set :public_folder, File.dirname(__FILE__) + "/../../public"

	#Set layout
	configure do
	  set :erb, :layout => :'layouts/layout'
	end

	#Root
	get '/' do
		erb :index
	end

	#Error
	get '/failure' do
		flash[:notice] = %Q{<h3>Error</h3> &#60; <a href="/">Back</a> }
	end

	#To run by Sinatra
	run! if __FILE__ == $0

end
