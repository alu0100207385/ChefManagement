class User
	include DataMapper::Resource

	property :id, Serial
	property :username, String, :required => true
	property :email, String, :required => true
	property :password, BCryptHash
	property :network, String
end


class Recipe 
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :required => true
	property :cost, Float, :required => true #Costo de producción
	property :username, String

	belongs_to :recipe
end

class Ingredients
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
	property :quantity, Integer
	property :weight, Float
	property :volume, Float
	propoerty :decrease, Float #merma del ingrediente por produccion

	property :cost, Float, :required => true #costo por unidad (cantidad/peso/volume)

	belongs_to :recipe
end

=begin
class Dish
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
	property :cost, Float, :required => true #Costo de producción
#por racion
#relacion plato-nraciones

	belongs_to :recipe  ##CONSULTAR: todos los usu disponen del mismo banco de datos o puede agregar platos y recetas?
end
=end
