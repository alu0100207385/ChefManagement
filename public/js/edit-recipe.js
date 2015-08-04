$(document).ready(function(){
	$('#publish').click(function(){
		alert("Warning: This recipe will be public. You cannot change it later. Click 'Modify' to accept changes");
	});

	$("#message").hide();
	$("#message2").hide();
	CKEDITOR.instances['instructions'].setData($('#instructions2').text());

	$("#modify-recipe1, #modify-recipe2").click(function(){
		var entrada = false;
		if ($('#recipe-name').val() == ""){
			$('#label-name').css("color", "red");
			entrada = true;
		}
		else
			$('#label-name').css("color", "inherit");
		if ( ($('#n-rations').val() == "") || ($('#n-rations').val() < 1) ){
			$('#rations').css("color", "red");
			entrada = true;
		}
		else
			$('#rations').css("color", "inherit");
		if (entrada == true) {
			$("#message").hide();
			$("#message").html('<p class ="alert alert-danger" role="alert">Check fields</p>').show(1000);
			entrada = false;
			return false;
		}
		else
			$("#message").hide();
		if ($('#h').val() == "")
			$('#h').val(0);
		if ($('#m').val() == "")
			$('#m').val(0);

		var ins = CKEDITOR.instances['instructions'].getData();

		$.ajax({
    		type: "POST",
			url: "/home/edit-recipe/"+ClearSpace($('#recipe-name').val()),
      		data: {recipe_name: $('#recipe-name').val(), nration: $('#n-rations').val(), order: $('#pos').val(), type: $('#type').val(), nivel: $('#nivel').val(), time: $('#h').val()+"'"+$('#m').val()+"''", vegan: $('#vegan').val(), allergens: $('#allergens').val(), origin: $('#country').val(), instructions: ins},

      		success: function(data){
      			if(data.control == 0){
					window.location = window.location.href+'#';
					$("#message").hide();
		        	$("#message").html('<p class ="alert alert-success" role="alert">Recipe has been modified</p>').show(1000);
      				window.setTimeout(function(){window.location = '/home/recipe/'+ClearSpace($('#recipe-name').val())+"_"+ClearSpace(data.user);}, 2000 );
      				}
      			if(data.control == -1)
					window.location = '/';
      		},

      		error: function(xhr){
				console.log(xhr.status);
	    		console.log(xhr.statusText);
	    	}
	    });
	});
});
