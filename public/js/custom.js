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

function showProb(pno)
{
    $.post('chal/show', {
        'pno' : pno
    }, function(data) {
        if(data=='wrong') {
            $('#showprob-data').html(data);
            $('#showprob-data').css("color","red");
        } else {
            $('#showprob-data').hide();
            var prob = $.parseJSON(data);
            $('#prob_name').html(prob.name + " - " + prob.title + " (solved by " + prob.solved + ")");
            $('input[name="pno"]').val(prob.pno);
            $('#prob_body').html(prob.body);
            $('input[name="auth"]').val("");
            if(prob.file) {
                $('#prob_file').show();
                $('#prob_file').val(prob.file);
                $('#prob_file').click(function(e) {
                    e.preventDefault();
                    window.location.href="download/"+prob.category+"/"+prob.file;
                });
            } else {
                $('#prob_file').hide();
            }
            location.href="#show_problem"
        }
    });
}

function checkAuth(pno, auth)
{
    $.post('chal/auth', {
        'pno' : pno.value,
        'auth' : auth.value
    }, function(data) {
        $('#showprob-data').show();
        $('#showprob-data').html(data);
        if(data=='true') {
            $('#showprob-data').css("color", "green");
            window.location.href="#chal";
            location.reload();
        } else {
            $('#showprob-data').css("color", "red");
        }
    });
    return false;
}

function modifyProb(pno)
{
    $.get('chal/modify/'+pno.value, function(data) {
        if(data=='wrong') {
            $('#modifyprob-data').html(data);
            $('#modifyprob-data').css("color","red");
        } else {
            $('#modifyprob-data').hide();
            var prob = $.parseJSON(data);
            $('#mod_pno').val(prob.pno);
            $('#mod_category').val(prob.category);
            $('#mod_title').val(prob.title);
            $('#mod_author').val(prob.author);
            $('#mod_body').val(prob.body);
            $('#mod_auth').val(prob.auth);
            $('#mod_score').val(prob.score);
            $('#mod_date').val(prob.ldate);
            if (prob.file) {
                $('#cfile_div').show();
                $('#cur_file').val("Current File: " + prob.file);
            } else {
                $('#cfile_div').hide();
            }
            location.href="#modify_problem"
        }
    });
}

function deleteProb(pno)
{
    if (confirm("Do you really want to delete?") == true){    //확인
        $.post('chal/delete', {
            'pno' : pno.value
        }, function(data) {
            if(data=='true') {
                window.location.hash = "#chal";
                location.reload();
            } else {
                $('#showprob-data').show();
                $('#showprob-data').html(data);
                $('#showprob-data').css("color", "red");
            }
        });
    } else {   //취소
            return;
    }
}

function deleteFile(pno)
{
    if (confirm("Do you really want to delete?") == true){
        $.post('chal/delete_file', {
            'pno' : pno.value
        }, function(data) {
            if(data=='true') {
                $('#cfile_div').hide();
            } else {
                $('#modifyprob-data').show();
                $('#modifyprob-data').html(data);
                $('#modifyprob-data').css("color", "red");
            }
        });
    }
}

function removeNotice(no)
{
    if (confirm("Do you really want to delete?") == true){
        $.post('notice/delete', {
            'no' : no
        }, function(data) {
            if(data=='true') {
                window.location.hash = "#notice";
                location.reload();
            } else {
                $('#notice-data').show();
                $('#notice-data').html(data);
                $('#notice-data').css("color", "red");
            }
        });
    }
}

function modifyNotice(no)
{
    var notices = $('div[class="item"]');
    var target;
    notices.each(function() {
        if($(this).find('div[class="item-no"]').html() == no) {
            target = $(this);
            return;
        }
    });
    if(target) {
        $('input[name="no"]').val(no);
        $('#not_title').val(target.find('.item-title').html());
        $('#not_body').html(target.find('.item-body').html());
        $('#not_author').val(target.find('.item-author').html());
        file = target.find('.item-file').html();
        if(file) {
            $('#not_cfile_div').show();
            $('#not_cur_file').val(file);
        } else {
            $('#not_cfile_div').hide();
        }
        location.href = "#modify_notice";
    }
}

function deleteNoticeFile(no)
{
    if (confirm("Do you really want to delete?") == true){
        $.post('notice/delete_file', {
            'no' : no.value
        }, function(data) {
            if(data=='true') {
                window.location.href = "#notice"
                location.reload();
            } else {
                $('#modifynotice-data').show();
                $('#modifynotice-data').html(data);
                $('#modifynotice-data').css("color", "red");
            }
        });
    }
}

function refreshWindow()
{
    location.reload();
}

setTimeout('refreshWindow()', 300 * 1000);
