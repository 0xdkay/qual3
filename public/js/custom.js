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
            $('#login-data').html(data);
            $('#login-data').css("color","red");
        }
    });
    return false;
}

function resetCheck(pw, pw_confirm) 
{
    if (pw.value != pw_confirm.value) {
        pw.focus();
        $('#reset-data').html("Please confirm your password correctly.");
        $('#reset-data').css("color","red");
    } else {
        $.post('reset', {
            'pw': pw.value,
            'pw_confirm': pw_confirm.value,
        }, function(data) {
            if(data=='true') {
                $('#reset-data').html("");
                location.href = "/";
            } else {
                $('#reset-data').html(data);
                $('#reset-data').css("color","red");
            }
        });
    }
    return false;
}

function recoveryCheck(email)
{
    $.post('recovery', {
        'mail': email.value
    }, function(data) {
        if(data=='true') {
            $('#recovery-data').html("");
            location.href = "/";
        } else {
            $('#recovery-data').html(data);
            $('#recovery-data').css("color","red");
        }
    });
    return false;
}

function registerCheck(form)
{
    if (form.pw.value != form.pw_confirm.value) {
        form.pw.focus();
        $('#register-data').html("Please confirm your password correctly.");
        $('#register-data').css("color","red");
    } else {
        $.post('register', {
            'id' : form.id.value,
            'pw' : form.pw.value,
            'pw_confirm' : form.pw_confirm.value,
            'name' : form.name.value,
            'sno' : form.sno.value,
            'mail' : form.mail.value,
            'key' : form.key.value,
        }, function(data) {
            if(data=='true') {
                $('#register-data').html("");
                location.href = "/";
            } else {
                $('#register-data').html(data);
                $('#register-data').css("color","red");
            }
        });
    }
    return false;
}

