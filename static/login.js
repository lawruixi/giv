function validate_form(){
    var isValid = true;

    var username = document.forms[0]["username"].value;
    re = /^[a-z0-9_]+$/i
    if(username == ""){
        document.forms[0]["username"].classList.add("is-invalid");
        var isValid = false;
    }
    else if(!username.match(re)){
        document.forms[0]["username"].classList.add("is-invalid");
        var isValid = false;
    }

    var password = document.forms[0]["password"].value;
    if(password == ""){
        document.forms[0]["password"].classList.add("is-invalid");
        var isValid = false;
    }
    
    return isValid;
}

function remove_invalid_name(){
    document.forms[0]["username"].classList.remove("is-invalid");
}

function remove_invalid_password(){
    document.forms[0]["password"].classList.remove("is-invalid");
}
