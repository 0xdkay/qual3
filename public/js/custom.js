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

function recoveryCheck(email)
{
    $.post('recovery', {
        'email': email.value
    }, function(data) {
        if(data=='true') {
            $('#login-data').html("");
            location.href = "/";
        } else {
            $('#login-data').html("Something got WrongWrong id - password combination.");
            $('#login-data').css("color","red");
        }
    });
    return false;
}

function registerCheck(id, pw, pw_confirm, key)
{
    $.post('register', {
        'email': email.value
    }, function(data) {
        if(data=='true') {
            $('#login-data').html("");
            location.href = "/";
        } else {
            $('#login-data').html("Something got WrongWrong id - password combination.");
            $('#login-data').css("color","red");
        }
    });
    return false;
}

