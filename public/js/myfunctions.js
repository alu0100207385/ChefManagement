$(document).ready(function(){
	$("#enter").click(function(){
    var data = {username: $('#username').val(), password: $('#pass').val()}
    //console.log(data);

    $.ajax({
		url: '/login',
      	type: 'post',
      	dataType: 'json',
      	data: data,

      	success: function(data){
      		console.log(data);
      		console.log(data.control);
        	if(data.control == 1){
		        $("#message").hide();
		        $("#message").html('<p class ="alert alert-danger" role="alert">User does not exist.</p>');
		        $("#message").show(1000);
        	}
	        if(data.control == 2){
	          $("#message").hide();
	          $("#message").html('<p class="alert alert-danger" role="alert">Password incorrect.</p>');
	          $("#message").show(1000);
	        }
        	if(data.control == 0){
          		window.location= '/home';
        	}
		},
		error: function(data){
			console.log(data);
      		console.log(data.control);
    		console.log('failure');
		}
		});
	});
});


function showPassword() {
    var key_attr = $('#pass').attr('type');
    
    if(key_attr != 'text') {
        
        $('.checkbox').addClass('show');
        $('#pass').attr('type', 'text');
        
    } else {
        
        $('.checkbox').removeClass('show');
        $('#pass').attr('type', 'password');      
    }
}
