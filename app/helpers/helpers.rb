module AppHelpers
	require 'mail'

	config = YAML.load_file 'app/config/config.yml'
	username = config['email_username']
	password = config['email_password']
	options = { :address              => "smtp.gmail.com",
	            :port                 => 587,
	            #:domain               => 'gmail.com',#'http://localhost:4567/', #'your.host.name',
	            :user_name            => username,#'<username>',
	            :password             => password,#'<password>',
	            :authentication       => 'plain',
	            :enable_starttls_auto => true  }
	Mail.defaults do
	  delivery_method :smtp, options
	end

	#Tras el registro exitoso se envia confirmacion de los datos de la cuenta creada, tb se usa para generar nueva pass
	def account_information (usu, pass, email, msg)
		Mail.deliver do
		       to email
		     from 'usu0100@gmail.com'
	 content_type 'text/plain; charset=UTF-8'
		  subject msg
		     body "Your account, \n \tUsername: #{usu}\n \tPassword: "+"#{pass}\n \tEmail: #{email}"
	 	end
	end

	def merma (n, lost) #lost = porcentaje de perdida
		return n - (n * lost)/100
	end

	#Esta funcion recibe una cadena y devuelve un array [name,username]
	#Usada para obtener id fila de la tabla lista de recetas.
	def GetIds (cad)
		return [cad[0..(cad.index('_')-1)], cad[(cad.index('_')+1)..cad.size]]
	end

	#Esta funcion calcula el nuevo precio de una receta segun el numero de comensales
	def calculator(cost, nplatos, nplatos2)
		if (nplatos2 != nplatos)
			return ((nplatos2 * cost)/nplatos)
		else
			return cost
		end
	end

	#Cuando un usuario se da de baja sus recetas quedan almacenadas, para ello se genera un nuevo username
	def GenerateChefUsername()
		n = (rand(0..9999)).to_s
		while (n.size < 4)
			n = "0"+n
		end
		return "Chef"+n
	end
end
