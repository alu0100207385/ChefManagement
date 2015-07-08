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
	property :cost, Float, :default => 0			#Costo del plato (venta). El coste de producción se puede sacar por cáculo.
	property :ration_cost, Float, :default => 0		#Costo por ración
	property :nration, Integer, :required => true	#Numero de raciones
	property :instructions, Text					#Preparación
	property :username, String 						#Autor de la receta
	#property :other, Recipe
	#property :avatar

#belongs_to :parent, self, :key => true
	#belongs_to :parent, self, :required => false
	#belongs_to :parent, self, :auto_validations => false
#has n, :children, self, :child_key => [:parent_id] 
	has n, :ingredients 
	#has n, :comments
end
class Ingredient
	include DataMapper::Resource

	property :id, Serial, :key => true
	property :name, String,:required => true		#Nombre del ingrediente
	property :cost, Float, :required => true 		#costo por unidad (cantidad/peso/volumen)
	property :unity_cost, String
	property :quantity, Integer						#Solo puede 
	property :weight, Float							#estar activo
	property :weight_un, String
	property :volume, Float							#uno de los 3 campos
	property :volume_un, String
	property :decrease, Float, :default => 0		#merma del ingrediente por produccion
	#property :avatar

	belongs_to :recipe
end


=begin
class Ingredient
	include DataMapper::Resource

	property :id, Serial, :key => true
	property :name, String,:required => true		#Nombre del ingrediente
	property :cost, Float, :required => true 		#costo por unidad (cantidad/peso/volumen)
	property :unity_cost, String
	#property :avatar

	belongs_to :recipe
	has n, :lots
end


class Lot
	include DataMapper::Resource
	
	property :id, Serial
	property :quantity, Integer					#Solo puede 
	property :weight, Float						#estar activo
	property :volume, Float						#uno de los 3 campos
	property :decrease, Float 					#merma del ingrediente por produccion

	belongs_to :ingredient
	#belongs_to :recipe
end
=end
=begin
class Comment
	include DataMapper::Resource
	
	property :recipe_name, String, :key => true 	#elegir campo para asociar, id o nombre de la receta
	property :username, String, :required => true	#Persona que hace el comentario
	property :content, Text
	property :score, Integer

	belongs_to :recipe
end
http://datamapper.org/docs/associations.html
=end
