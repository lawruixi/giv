function filter_results(){
    var checkboxes = document.getElementsByClassName("btn-check");
    var labels = document.getElementsByClassName("checkbox-label");
    var query = document.getElementById("username").value;

    for(var i = 0; i < checkboxes.length; i++){
        checkboxes[i].style.display = "inline-block";
        labels[i].style.display = "inline-block";
    }

    for(var i = 0; i < checkboxes.length; i++){
        if(checkboxes[i].id.slice(9).toLowerCase().search(query.toLowerCase()) == -1){
            checkboxes[i].style.display = "none";
            labels[i].style.display = "none";
        }
    }
}

function validate_form(){
    var chat_name = document.forms[0]["name"].value;
    if(chat_name == ""){
        document.forms[0]["name"].classList.add("is-invalid");
        return false;
    }
}

function remove_invalid_name(){
    document.forms[0]["name"].classList.remove("is-invalid");
}
