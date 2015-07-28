$(document).ready(function(){
	$('#quantity-un').hide();
	$('#weight-un').show();
	$('#volume-un').hide();
	$('#quantity-op').change(function(){
		switch ($("#quantity-op option:selected").text()){
			case 'Quantity':
				$('#quantity-un').show();
				$('#unity').html('u').show();
				$('#weight-un').hide();
				$('#volume-un').hide();
				$("#n-quantity").attr('step',0);
			break;
			case 'Weight':
				$('#quantity-un').hide();
				$('#weight-un').show();
				$('#weight-un').val('kg');
				$('#unity').html('kg').show();
				$('#volume-un').hide();
				$("#n-quantity").attr('step',0.01);
			break;
			case 'Volume':
				$('#quantity-un').hide();
				$('#weight-un').hide();
				$('#volume-un').show();
				$('#volume-un').val('l');
				$('#unity').html('l').show();
				$("#n-quantity").attr('step',0.01);
			break;
		}
	});

	$('#weight-un').change(function(){
		switch ($("#weight-un option:selected").text()){
			case 'kg':
				$('#unity').html('kg').show();
			break;
			case 'gr':
				$('#unity').html('gr').show();
			break;
		}
	});

	$('#volume-un').change(function(){
		switch ($("#volume-un option:selected").text()){
			case 'l':
				$('#unity').html('l').show();
			break;
			case 'cl':
				$('#unity').html('cl').show();
			break;
			case 'ml':
				$('#unity').html('ml').show();
			break;
		}
	});


	$('#save-ingredient, #save-finish').click(function(){
		if ($('#ingredient-name').val() == ""){
			$("#message2").hide();
			$("#message2").html('<p class ="alert alert-danger" role="alert">Type the  ingredient name</p>').show(1000);
			return false;
		}
		if ($('#ing-cost').val() == ""){
			$("#message2").hide();
			$("#message2").html('<p class ="alert alert-danger" role="alert">Type the ingredient cost</p>').show(1000);
			return false;
		}
		if ($('#n-quantity').val() == ""){
			$("#message2").hide();
			$("#message2").html('<p class ="alert alert-danger" role="alert">Type quantity</p>').show(1000);
			return false;
		}
		if ($('#ing-cost').val() == ""){
			$("#message2").hide();
			$("#message2").html('<p class ="alert alert-danger" role="alert">Type ingredient cost</p>').show(1000);
			return false;
		}

		var ins = CKEDITOR.instances['instructions'].getData();
		var finished = false;
		if ( $(this).attr('id') == "save-finish" )
			finished = true;

		$.ajax({
    		type: "POST",
			url: "/home/new-ingredient",
      		data: {ing_name: $('#ingredient-name').val(), ing_cost: $('#ing-cost').val(), ing_unity_cost: "€/"+$('#unity').text(),/*$("#coin option:selected").text()+'/'+$("#unity option:selected").text()*/ quantity_op: $('#quantity-op option:selected').text(), n_quantity: $('#n-quantity').val(), weight_un: $("#weight-un option:selected").text(), volume_un: $("#volume-un option:selected").text(),ing_decrease: $("#decrease").val(), instructions: ins, recipe_name: $('#recipe-name').val()},

      		success: function(data){
      			if(data.control == 0){
	  				$("#message2").hide();
		        	$("#message2").html('<p class ="alert alert-success" role="alert">'+$('#ingredient-name').val()+' has been added</p>').show(1000);
		        	$('#current-recipe').html($('#current-recipe').html() + " + " + $('#ingredient-name').val() + "<br>").show(1000);
		        	ClearIngredient();
		        	$('#recipe_cost').val(data.cost);
		        	$('#recipe_cost_ration').val(data.ration_cost);
		        	//Actualizamos la lista de recetas en home
		        	var table = $('#recipe-list-tb').DataTable();
		        	//var n = ($('#recipe-list-tb tr').length) - 2;
		        	var n = $('#recipe-name').val()+"_"+data.user;
		        	console.log(n);
		        	if (data.vegan == true)
		        		vegan = "YES";
		        	else
		        		vegan = "NO";
		        	//n= uede ser n fil o ID
					table.row( 0 ).data([ $('#recipe-name').val(), $('#n-rations').val() , data.cost, data.ration_cost, data.nivel, data.time, vegan, data.user ]);
      				if (finished == true)
      					window.setTimeout(function(){window.location = '/home';}, 2000 );
		        	return false;
      			}
      			if(data.control == 1){
	  				$("#message2").hide();
		        	$("#message2").html('<p class ="alert alert-danger" role="alert">This ingredient already exists in the recipe</p>').show(1000);
		        	return false;
      			}
      		},

      		error: function(xhr){
				console.log(xhr.status);
	    		console.log(xhr.statusText);
	    	}
	    });
	});
});