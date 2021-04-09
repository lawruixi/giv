function validate_form(){
    var password = document.forms[0]["password_textfield"].value;
    if(password == ""){
        document.forms[0]["password_textfield"].classList.add("is-invalid");
        return false;
    }
}

function remove_invalid_name(){
    document.forms[0]["password_textfield"].classList.remove("is-invalid");

}
