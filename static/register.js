function validate_form(){
    var isValid = true;
    var message = "";

    var re="/^[^\s@]+@[^\s@]+$/"
    var email = document.forms[0]["email"].value;
    if(email == ""){
        document.forms[0]["email"].classList.add("is-invalid");
        var isValid = false;
        message += "Email cannot be empty.\n"
    }
    else if(!email.match(re)){
        document.forms[0]["email"].classList.add("is-invalid");
        var isValid = false;
        message += "Not valid email address.";
    }

    var username = document.forms[0]["username"].value;
    re = /^[a-z0-9_]+$/i
    if(username == ""){
        document.forms[0]["username"].classList.add("is-invalid");
        var isValid = false;
        message += "Username cannot be empty.\n"
    }
    else if(!username.match(re)){
        document.forms[0]["username"].classList.add("is-invalid");
        var isValid = false;
        message += "Username can only contain alphanumeric characters and the underscore (_) character.\n"
    }

    var password = document.forms[0]["password"].value;
    if(password == ""){
        document.forms[0]["password"].classList.add("is-invalid");
        var isValid = false;
        message += "Password cannot be empty.\n"
    }
    
    message_p = document.getElementById("messages");
    message_p.innerHTML = message;
    return isValid;
}

function remove_invalid_email(){
    document.forms[0]["email"].classList.remove("is-invalid");
}
function remove_invalid_name(){
    document.forms[0]["username"].classList.remove("is-invalid");
}
function remove_invalid_password(){
    document.forms[0]["password"].classList.remove("is-invalid");

}
