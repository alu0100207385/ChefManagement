class User
	include DataMapper::Resource

	property :id, Serial
	property :username, String, :required => true
	property :email, String, :required => true
	property :password, BCryptHash
	property :network, String
end
=begin
#class Recipes ##CONSULTAR

#merma

class Dish
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
	property :cost, Float, :required => true #Costo de producción
#por racion
#relacion plato-nraciones

	belongs_to :recipes  ##CONSULTAR: todos los usu disponen del mismo banco de datos o puede agregar platos y recetas?
end

class Ingredients
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
	property :quantity, Integer
	property :weight, Float
	property :volume, Float
	propoerty :merma, Float #merma del ingrediente por produccion

	property :cost, Float, :required => true #costo por unidad (cantidad/peso/volume)

	belongs_to :dish
end
=end
