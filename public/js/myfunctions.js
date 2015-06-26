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
