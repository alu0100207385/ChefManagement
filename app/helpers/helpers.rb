module AppHelpers
	require 'mail'

	config = YAML.load_file 'app/config/config.yml'
	username = config['email_username']
	password = config['email_password']
	options = { :address              => "smtp.gmail.com",
	            :port                 => 587,
	            :domain               => 'your.host.name',
	            :user_name            => username,#'<username>',
	            :password             => password,#'<password>',
	            :authentication       => 'plain',
	            :enable_starttls_auto => true  }
	Mail.defaults do
	  delivery_method :smtp, options
	end

	#Tras el registro exitoso se envia confirmacion de los datos de la cuenta creada
	def account_information (usu, pass, email, msg)
		Mail.deliver do
		       to email
		     from 'correo_ejemplo@correo.com'
	 content_type 'text/plain; charset=UTF-8'
		  subject msg
		     body "Your account, \n \tUsername: #{usu}\n \tPassword: "+"#{pass}\n \tEmail: #{email}"
	 	end
	end

	def recovery_account (email, usu, pass)
		Mail.deliver do
		       to email
		     from 'correo_ejemplo@correo.com'
	 content_type 'text/plain; charset=UTF-8'
		  subject 'ChefManagement: Recovery account'
		     body "Dear #{usu},\n This is your password: "+"#{pass}"
	 	end
	end
=begin
		mail = Mail.new do
	  		from    'correo_ejemplo@correo.com'
	  		to      email
	  		content_type 'text/plain; charset=UTF-8'
	  		subject 'ChefManagement: Recovery account'
	  		body    "Dear #{usu}\n This is your password: #{pass}"
  		end
  		mail.deliver
	end
=end
end
