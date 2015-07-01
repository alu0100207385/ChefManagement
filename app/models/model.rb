class User
	include DataMapper::Resource

	property :id, Serial
	property :username, String, :required => true
	property :email, String, :required => true
	property :password, BCryptHash
	property :network, String						#Red social que uso para el registro si procede
	#property :avatar
end


class Recipe 
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :required => true		#Nombre de la receta
	property :cost, Float 							#Costo del plato (venta). El coste de producción se puede sacar por cáculo.
	property :ration_cost, Float					#Costo por ración
	property :nration, Integer, :required => true	#Numero de raciones
	property :instructions, Text					#Preparación
	property :username, String 						#Autor de la receta
	#property :avatar

	belongs_to :recipe
end

class Ingredients
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true	#Nombre del ingrediente
	property :quantity, Integer
	property :weight, Float
	property :volume, Float
	property :decrease, Float 					#merma del ingrediente por produccion
	property :cost, Float, :required => true 	#costo por unidad (cantidad/peso/volumen)
	#property :avatar

	belongs_to :recipe
end

=begin
class Comment
	include DataMapper::Resource
	#elegir campo para asociar, id o nombre de la receta
	property :username, String, :required => true	#Persona que hace el comentario
	property :note, Text
	property :score, Integer

	belongs_to :recipe
end

=end
