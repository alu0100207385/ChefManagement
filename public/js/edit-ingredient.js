$(document).ready(function(){
	$('#update-ingredient').hide();
	$('#quantity-op').val('weight');
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

	$('#cancel-ingredient').click(function(){
		$('#message2').hide();
		ClearIngredient();
		$('#save-ingredient').show();
		$('#update-ingredient').hide();
	});

	$('#save-ingredient').click(function(){
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

		$.ajax({
    		type: "POST",
			url: "/home/"+ClearSpace($('#recipe-name').val())+"/add-ingredient",
      		data: {ing_name: $('#ingredient-name').val(), ing_cost: $('#ing-cost').val(), ing_unity_cost: "€/"+$('#unity').text(), quantity_op: $('#quantity-op option:selected').text(), n_quantity: $('#n-quantity').val(), weight_un: $("#weight-un option:selected").text(), volume_un: $("#volume-un option:selected").text(),ing_decrease: $("#decrease").val(), recipe_name: $('#recipe-name').val()},

      		success: function(data){
      			if(data.control == 0){
	  				$("#message2").hide();
		        	$("#message2").html('<p class ="alert alert-success" role="alert">'+$('#ingredient-name').val()+' has been added</p>').show(1000);
		        	$('#recipe_cost').val(data.recipe_cost);
		        	$("#recipe_cost_ration").val(data.ration_cost);
		        	var quant = ($('#n-quantity').val()*$('#ing-cost').val());
		        	$('#ing-list tr:last').after('<tr id='+ClearSpace($('#ingredient-name').val())+'><td>'+$('#ingredient-name').val()+'</td><td>'+$('#n-quantity').val()+" "+$('#unity').text()+'</td><td>'+$('#ing-cost').val()+" €/"+$('#unity').text()+'</td><td>'+quant+'</td><td><a href="javascript:ConfirmDelete('+"'"+ClearSpace($('#ingredient-name').val())+"'"+')"><i class="fa fa-trash-o"></i></a></td><td><a href="javascript:EditIngredient('+"'"+ClearSpace($('#ingredient-name').val())+"'"+')"><i class="fa fa-pencil-square-o"></i></a></td></tr>').show(1000);
		        	ClearIngredient();
		        	$('#recipe_cost').val(data.cost);
		        	$('#recipe_cost_ration').val(data.ration_cost);
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


function ConfirmDelete(ing_name){
	if (confirm('Are you sure?')){
		var url = "/home/delete-ingredient/"+ClearSpace(ing_name);
		$.ajax({
			type: "POST",
			url: url,
  			data: {ing_name: ing_name, recipe_name: $('#recipe-name').val()},

  			success: function(data){
  				if (data.control == 0){
  					$("#"+ing_name+"").hide(1000);
  					$("#"+ing_name+"").remove();
  				   	$('#recipe_cost').val(data.cost);
	        		$('#recipe_cost_ration').val(data.ration_cost);
	        		return false;
  				}
  				else{
  					$("#message2").hide();
		        	$("#message2").html('<p class ="alert alert-danger" role="alert">Error</p>').show(1000);
		        	return false;
  				}
  			},
  			error: function(xhr){
				console.log(xhr.status);
    			console.log(xhr.statusText);
    		}
    	});
	}
}


function EditIngredient(ing_name){
	$.ajax({
	type: "GET",
	url: "/home/edit-ingredient/"+ClearSpace(ing_name),
		data: {recipe_name: $('#recipe-name').val()},

		success: function(data){
			switch (data.control){
				case 'weight':
					$('#quantity-op').val('weight');
					$('#n-quantity').val(data.weight);
					$('#weight-un').val(data.weight_un);
					$('#weight-un').show();
					$('#unity').text($('#weight-un').val());
					$('#volume-un').hide();
					$('#quantity-un').hide();
					$("#n-quantity").attr('step',0.01);
				break;
				case 'volume':
					$('#quantity-op').val('volume');
					$('#n-quantity').val(data.volume);
					$('#volume-un').val(data.volume_un);
					$('#weight-un').hide();
					$('#volume-un').show();
					$('#unity').text($('#volume-un').val());
					$('#quantity-un').hide();
					$("#n-quantity").attr('step',0.01);
				break;
				case 'quantity':
					$('#quantity-op').val('quantity');
					$('#n-quantity').val(data.quantity);
					$('#quantity-un').show();
					$('#unity').text('u');
					$('#weight-un').hide();
					$('#volume-un').hide();
					$('#quantity-un').show();
					$("#n-quantity").attr('step',0);
				break;
			}
			$('#old-name').val(ing_name);
			$('#ingredient-name').val(ing_name.replace(/-/g," "));
			$('#ing-cost').val(data.cost);
			$('#decrease').val(data.decrease);
			$('#save-ingredient').hide(1000);
			$('#update-ingredient').show(1000);
		},

		error: function(xhr){
			console.log(xhr.status);
			console.log(xhr.statusText);
		}
	});
}

$('#update-ingredient').click(function(){
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

	$.ajax({
		type: "POST",
		url: "/home/edit-ingredient/"+ClearSpace($('#old-name').val()),
		data: {recipe_name: $('#recipe-name').val(), new_name: $('#ingredient-name').val(), /*old_name: $('#old-name').val(),*/ cost: $('#ing-cost').val(), unity_cost: "€/"+$('#unity').text(), quantity_op: $('#quantity-op option:selected').text(), n_quantity: $('#n-quantity').val(), weight_un: $("#weight-un option:selected").text(), volume_un: $("#volume-un option:selected").text(), decrease: $("#decrease").val()},

		success: function(data){
			alert(data.name);
			if (data.control == 0){
				ClearIngredient();
				$('#save-ingredient').show();
				$('#update-ingredient').hide();
				$("#message2").hide();
		        $("#message2").html('<p class ="alert alert-success" role="alert">Ingredient update</p>').show(1000);
		        $("#"+$('#old-name').val()+"").hide(1000);
  				$("#"+$('#old-name').val()+"").remove();
  				switch (data.control2){
  					case 'weight':
  					  	var quant = data.weight;
  					  	var un = data.weight_un;
  					break;
  					case 'volume':
  						var quant = data.volume;
  						var un = data.volume_un;
  					break;
  					case 'quantity':
  						var quant = data.quantity;
  						var un = 'u';
  					break;
  				}
  				window.location = window.location.href+'#message2';
  				$('#ing-list tr:last').after('<tr id='+data.name+'><td>'+data.name+'</td><td>'+quant+" "+un+'</td><td>'+data.cost+" "+data.unity_cost+'</td><td>'+Math.round((quant *data.cost)*100)/100+'</td><td><a href="javascript:ConfirmDelete('+"'"+data.name+"'"+')"><i class="fa fa-trash-o"></i></a></td><td><a href="javascript:EditIngredient('+"'"+data.name+"'"+')"><i class="fa fa-pencil-square-o"></i></a></td></tr>').show(1000);
				$('#recipe_cost').val(data.rec_cost);
	        	$('#recipe_cost_ration').val(data.rec_ration_cost);
		        return false;
			}
			if (data.control == 2){
				$("#message2").hide();
		        $("#message2").html('<p class ="alert alert-danger" role="alert">Ingredient name is in use</p>').show(1000);
		        window.location = window.location.href+'#message2';
		        return false;
			}
			else{
				$("#message2").hide();
		        $("#message2").html('<p class ="alert alert-danger" role="alert">Error update</p>').show(1000);
		        window.location = window.location.href+'#message2';
		        return false;
			}
		},

		error: function(xhr){
			console.log(xhr.status);
			console.log(xhr.statusText);
		}
	});
});
