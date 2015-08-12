$(document).ready(function(){

	$("#cancel").click(function(){
		$('#message').hide();
		$('#calculator-view').hide();
		$('#make').hide();
		$('#import').hide();
		$('#export').hide();
		$('#current-recipe').hide();
		$('#section-title').html('<h3>Recipe list</h3><hr>');
		$('#show').show();
		return false;
	});
		
	$("#save-recipe").click(function(){
		$('#inputId').prop('readonly', false);
		$('#nration').val($('#n-rations').val()); //Numero de raciones
		$('#inputId').prop('readonly', true);

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
		$.ajax({
    		type: "POST",
			url: "/home/new-recipe",
      		data: {recipe_name: $('#recipe-name').val(), nration: $('#n-rations').val(), order: $('#pos').val(), type: $('#type').val(), nivel: $('#nivel').val(), time: $('#h').val()+"'"+$('#m').val()+"''", vegan: $('#vegan').val(), allergens: $('#allergens').val(), origin: $('#country').val()},

      		success: function(data){
				$("#message").hide();
      			if(data.control == 0){
		        	$("#message").html('<p class ="alert alert-success" role="alert">Recipe created successfully</p>').show(1000);
		        	$("#recipe-buttons").hide();
		        	ClearIngredient();
					$('#ingredient').show(1500);
					$('#recipe-name').prop('readonly', true);
					$('#n-rations').prop('readonly', true);
					$('.fila').hide(1000);
					$('#avatar').hide(1000);
					$('#accordion').show(1500);
					$('#current-recipe').html("<h4>"+$('#recipe-name').val()+"</h4>").show(1500);
					//Actualizamos la tabla de recetas -> home
					//var table = $('#recipe-list-tb').DataTable();
					//table.row.add([$('#recipe-name').val(), $('#n-rations').val(), $('#recipe_cost').val(), $('#recipe_cost_ration').val(), $('#nivel').val(), $('#h').val()+"'"+$('#m').val()+"''", $('#vegan').val(), data.user]).draw();
					
					var rowIndex = $('#recipe-list-tb').dataTable().fnAddData([$('#recipe-name').val(), $('#n-rations').val(), "0.0", "0.0", $('#nivel').val(), $('#h').val()+"'"+$('#m').val()+"''", $('#vegan').val(), data.user]);
					var row = $('#recipe-list-tb').dataTable().fnGetNodes(rowIndex);
					$(row).attr('id', $('#recipe-name').val()+"_"+data.user);
      			}
      			if(data.control == 1)
		        	$("#message").html('<p class ="alert alert-danger" role="alert">This recipe name already exists</p>').show(1000);
		        return false;
      		},

      		error: function(xhr){
				console.log(xhr.status);
	    		console.log(xhr.statusText);
	    	}
	    });
	});
});