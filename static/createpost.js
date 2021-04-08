function validate_form(){
    var post_title = document.forms[0]["title"].value;
    if(post_title == ""){
        document.forms[0]["title"].classList.add("is-invalid");
        return false;
    }
}

function remove_invalid_title(){
    document.forms[0]["title"].classList.remove("is-invalid");
}
