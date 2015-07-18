class User
	include DataMapper::Resource

	property :username, String, :key => true
	property :email, String, :key => true
	property :password, BCryptHash
	property :network, String						#Red social que uso para el registro si procede
	#property :avatar
end


class Recipe 
	include DataMapper::Resource

	property :name, String, :key => true			#Nombre de la receta
	property :cost, Float, :default => 0.0			#Costo del plato (venta). El coste de producción se puede sacar por cáculo.
	property :ration_cost, Float, :default => 0.0	#Costo por ración
	property :nration, Integer, :required => true	#Numero de raciones
	property :instructions, Text					#Preparación
	property :username, String 						#Autor de la receta
	#property :avatar
	property :pos, Flag[:incoming, :first, :second, :third, :single, :afters, :other]	#entrante, primer plato, segundo plato, plato único, postre
	property :type, Enum[:snack, :homemade_food, :tapas, :fast_food, :tasting, :other]	#snack, comida casera, tapas, comida rapida, degustación
	property :nivel, Enum[:very_easy, :easy, :medium, :hard, :very_hard]
	property :production_time, String				#Tiempo de producción de la receta
	property :vegan, Boolean, :default => false		#Indica si es un plato apto para vegetarianos
	property :warning, String							#Aviso alérgicos
	property :origin, String						#País originario de la receta

	#property :score, Integer
	#property :create_at, DateTime
	#property :edit_date, DateTime

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
	property :decrease, Float, :default => 0.0		#merma del ingrediente por produccion
	#property :avatar

	belongs_to :recipe
end


=begin
class Comment
	include DataMapper::Resource
	
	property :id, Serial
	property :username, String, :required => true	#Persona que hace el comentario
	property :posted, DateTime
	property :content, Text

	belongs_to :recipe
end
#more info : http://datamapper.org/docs/associations.html
=end
