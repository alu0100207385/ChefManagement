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
  					var total = 0.0;
  					$('#calc-result').hide();
  					$('#calc-instructions').hide();
  					var out = "";
  					out += '<h3>'+data.recipe_name+' for '+$('#calc-rations').val()+' people</h3>'+'\
  						<table class="ing-list">\
  							<thead><tr><th>Ingredient</th><th>Quantity</th><th>Price(€)</th><th>Subtotal(€)</th></tr></thead>\
  							<tbody>';
  					for (var i = 0; i < data.ing.length; i++){
  						var subtotal = Math.round((data.ing[i][1] * data.ing[i][3]) * 100) / 100;
  						out += '<tr><td>'+data.ing[i][0]+'</td><td>'+data.ing[i][1]+' '+data.ing[i][2]+'</td><td>'+data.ing[i][3]+'</td><td>'+subtotal+'</td></tr>';
  						total += subtotal;
  					}
  					for (var i = 0; i < data.rec2.length; i++){
              var link = 'home/recipe/'+ClearSpace(data.rec2[i][0])+"_"+ClearSpace(data.rec2[i][1]);
  						out += '<tr><td><a href="'+link+'">'+data.rec2[i][0]+'</a></td><td>'+$('#calc-rations').val()+' (p)</td><td>'+data.rec2[i][2]+'</td><td>'+data.rec2[i][2]+'</td></tr>';
  						total += data.rec2[i][2];
  					}
  					out += '<tr style="background-color:#e5e5e5; font-weight: bold;"><td>TOTAL</td><td></td><td></td><td>'+(Math.round(total * 100) / 100)+'</td></tr>';
  					out += '</tbody></table>';
  					$('#calc-result').html(out).show(1500);
  					$('#calc-instructions').html('<hr><h3>Instructions</h3>'+data.instructions).show(2500);
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
