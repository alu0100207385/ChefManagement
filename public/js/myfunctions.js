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

function isEmpty(str) {
   	return !str.replace(/^\s+/g, '').length; // boolean (`true` if field is empty)
}

function ClearRecipe(){
	$('#recipe-name').val(''); $('#recipe-name').prop('readonly', false);
	$('#n-rations').val(1); $('#n-rations').prop('readonly', false);
	$('#recipe_cost').val(''); $('#recipe_cost_ration').val('');
	$('#pos').val("single");
	$('#type').val("other");
	$('#nivel').val("medium");
	$('#h').val(''); $('#m').val('');
	$('#vegan').val("no");
	$('#allergens').val('');
	$('#country').val('');
	CKEDITOR.instances['instructions'].setData('');			
}

function ClearIngredient(){
	$('#ingredient-name').val('');
	$('#ing-cost').val('');
	$("#n-quantity").val('');
	$("#decrease").val(0.0);
	$('#quantity-op').val("weight");
	$('#weight-un').val("kg");
	$('#unity').text("kg");
	$('#quantity-un').hide();
	$('#weight-un').show();
	$('#volume-un').hide();
}

function ClearSpace(cad){
	return cad.replace(/\s/g, "-");
}

function Redirect(base, cad){
	window.location = base+ClearSpace(cad);
}

function GetIds(cad){
	n = cad.indexOf("_");
	return [cad.slice(0,n), cad.slice(n+1,cad.length)]
}

function CheckString(cad){
	//if(/^[a-zA-Z0-9- ]*$/.test(cad) == false)
	//if (cad.indexOf(/^[a-zA-Z0-9- ]*$/) == -1)
	if (cad.match(/[_\W0-9]/))
		return true;
	else
		return false;
}


function ConfirmDeleteIngRec(rec_name){
	var aux = GetIds(rec_name);
	var aux2 = GetIds(aux[1]);

	if (confirm('Delete '+aux[0]+'. Are you sure?')){
		var url = "/home/delete-ing-rec/"+ClearSpace(rec_name);
		$.ajax({
			type: "POST",
			url: url,
  			data: {rec_name: aux[0], rec_username: aux2[0], price: aux2[1], original_recipe: $('#recipe-name').val()},

  			success: function(data){
  				if (data.control == 0){
  					$("#"+ClearSpace(aux[0])+"").hide(1000);
  					console.log(ClearSpace(aux[0]));
  					$("#"+ClearSpace(aux[0])+"").remove();
  				   	$('#recipe_cost').val(data.cost);
	        		$('#recipe_cost_ration').val(data.ration_cost);
	        		$("#message2").html('<p class ="alert alert-success" role="alert">'+rec_name+' removed</p>').show(1000);
  				}
  				else{
  					$("#message2").hide();
		        	$("#message2").html('<p class ="alert alert-danger" role="alert">Error</p>').show(1000);
  				}
		        return false;
  			},
  			error: function(xhr){
				console.log(xhr.status);
    			console.log(xhr.statusText);
    		}
    	});
	}
}