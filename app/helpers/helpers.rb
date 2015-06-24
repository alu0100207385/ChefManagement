module AppHelpers
	require 'mail'

	def recovery_account (mail) #correo proporcionado
		mail = Mail.new do
  		from    'usu0100@gmail.com'
  		to      mail
  		subject 'ChefManagement: Recovery account'
  		body    "Prueba de envio"
	end

end
