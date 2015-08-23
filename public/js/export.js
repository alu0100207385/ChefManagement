$(document).ready(function(){
	$('#create-file').click(function(){
		if ($('#file-name').val() == ""){
			$('#message').hide();
			$('#message').html('<p class ="alert alert-danger" role="alert">Type a file name</p>').show(1000);
			return false;
		}
		if (CheckString($('#file-name').val()) == true){
			$('#message').hide();
			$('#message').html('<p class ="alert alert-danger" role="alert">Invalid name. String cannot contain illegal characters.</p>').show(1000);
		}
		else{
			$('#message').hide();
			$.ajax({
				type: "GET",
				url: "/home/export",
					data: {name: $('#file-name').val()},
					success: function(data){
						$('#message').hide();
						if(data.control == 0){
							$('#message').html('<p class ="alert alert-success" role="alert">File created successfully</p>').show(1000);
							window.setTimeout(function(){
								var url = '/uploads/'+$('#file-name').val()+'.json';
								var $a = $('<a />', {
			  						'href': url,
			  						'download': $('#file-name').val()+'.json',
			  						'text': "click"
								}).hide().appendTo("body")[0].click();
							}, 2000 );
						}
						else
							$('#message').html('<p class ="alert alert-danger" role="alert">Error creating file</p>').show(1000);
						return false;
				},

				error: function(xhr){
					console.log(xhr.status);
					console.log(xhr.statusText);
				}
			});
		}
	});
});
