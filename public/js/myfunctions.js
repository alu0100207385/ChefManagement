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
/*
function BackgroundSlider(){
	var path = '../resources/background/'
	var img = new Array()
	img[0] = path+'01.jpg'
	img[1] = path+'02.jpg'
	img[2] = path+'03.jpg'

	for (var i = 0; i < img.length; i++) {
		window.setTimeout(function() {$('#welcome').css("background-image", "url("+img[0]+")")},2000)
		window.setTimeout(function() {$('#welcome').css("background-image", "url("+img[1]+")")},2000)
	};
}*/