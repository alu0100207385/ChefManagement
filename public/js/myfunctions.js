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
	n = cad.indexOf("&");
	return [cad.slice(0,n), cad.slice(n+1,cad.length)]
}