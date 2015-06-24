class User
	include DataMapper::Resource

	property :id, Serial
	property :username, String, :required => true
	property :email, String, :required => true
	property :password, BCryptHash
	#property :network, String
end

class Meal
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
	property :cost, Float, :required => true #Costo de producción

	belongs_to :user  ##CONSULTAR: todos los usu disponen del mismo banco de datos o puede agregar platos y recetas?
end

class Ingredients
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
	property :quantity, Integer
	property :weight, Float
	property :volume, Float

	property :cost, Float, :required => true #costo por unidad (cantidad/peso/volume)

	belongs_to :meal
end

#class Recipes ##CONSULTAR