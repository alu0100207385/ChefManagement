$(document).ready(function(){
	$('#calculate').click(function(){
		if ($('#calc-recipe').val() != 'none'){
		var aux = GetIds(ClearSpace($('#calc-recipe').val()));

		$.ajax({
			type: "GET",
			url: '/home/calculate',
  			data: {recipe_name: aux[0], recipe_username: aux[1], nrations: $('#calc-rations').val()},

  			success: function(data){
  				if (data.control == 0){
  					console.log(data);
  					console.log(data.recipe_name);
  					console.log(data.ing);
  					console.log(data.rec2);
  					$('#calc-result').hide();
  					$('#calc-result').html('<h3>'+data.recipe_name+' for '+$('#calc-rations').val()+' people</h3>'+'\
  						<table style="width:100%">\
  							<thead><tr><th>Ingredient</th><th>Quantity</th><th>Price(€)</th><th>Subtotal(€)</th></tr></thead>\
  							<tbody>\
  								<tr><td>'+data.ing[0]+'</td></tr>\
  								<tr><td>TOTAL</td></tr>\
  							</tbody>\
  						</table>');
  					$('#calc-result').show(1500);
  				}
 
  			},
  			error: function(xhr){
				console.log(xhr.status);
    			console.log(xhr.statusText);
    		}
    	});
		}
	});
});
