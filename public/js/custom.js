function loginCheck(id, pw) 
{
	$.post('login', {
		'id': id.value,
	'pw': pw.value,
	}, function(data) {
		if(data=='true') {
			$('#login-data').html("");
			location.href = "/";
		} else {
			$('#login-data').html("Wrong id - password combination.");
			$('#login-data').css("color","red");
		}
	});
	return false;
}

