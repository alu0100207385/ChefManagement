module AppHelpers
	require 'mail'

	config = YAML.load_file 'app/config/config.yml'
	username = config['email_username']
	password = config['email_password']
	options = { :address              => "smtp.gmail.com",
	            :port                 => 587,
	            :domain               => 'http://localhost:4567/', #'your.host.name',
	            :user_name            => username,#'usu0100@gmail.com',#'<username>',
	            :password             => password,#'proyecto2015',#'<password>',
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
end
