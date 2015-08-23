$(document).ready(function(){
	$('#load-file').click(function(){
        var jqxhr = $.getJSON("uploads/"+$('#files').val(), function(data){
			$.ajax({
				dataType: "json",
	    		type: "GET",
				url: "/home/import",
				data: {file: data},

				success: function(data){
					$("#message").hide();
					if(data.control == 0){
			        	$("#message").html('<p class ="alert alert-success" role="alert">Recipe list loaded successfully</p>').show(1000);
			        	window.setTimeout(function(){ window.location = '/'; }, 1500 );
					}
					if (data.control == 1)
			        	$("#message").html('<p class ="alert alert-danger" role="alert">Error reading file</p>').show(1000);
					return false;
				},

				error: function(xhr){
					console.log(xhr.status);
		    		console.log(xhr.statusText);
		    	}
		    });
        });
        jqxhr.fail(function() {
    		$("#message").hide();
    		$("#message").html('<p class ="alert alert-danger" role="alert">Error reading file</p>').show(1000);
  		})
	});
});