function filter_results_add(){
    var checkboxes = document.getElementsByClassName("btn-check-add");
    var labels = document.getElementsByClassName("checkbox-label-add");
    var query = document.getElementById("username-add").value;

    for(var i = 0; i < checkboxes.length; i++){
        checkboxes[i].style.display = "inline-block";
        labels[i].style.display = "inline-block";
    }

    for(var i = 0; i < checkboxes.length; i++){
        if(checkboxes[i].id.slice(9).toLowerCase().search(query.toLowerCase()) == -1){
            checkboxes[i].style.display = "none";
            labels[i].style.display = "none"; }
    }
}

function filter_results_manage(){
    var checkboxes_m = document.getElementsByClassName("btn-check-moderator");
    var labels_m = document.getElementsByClassName("checkbox-label-moderator");

    var checkboxes_r = document.getElementsByClassName("btn-check-remove");
    var labels_r = document.getElementsByClassName("checkbox-label-remove");

    var manage_p = document.getElementsByClassName("manage-p");
    var manage_users_div = document.getElementsByClassName("manage-users-div");

    var query = document.getElementById("username-manage").value;

    for(var i = 0; i < checkboxes_m.length; i++){
        checkboxes_m[i].style.display = "inline-block";
        labels_m[i].style.display = "inline-block";
        checkboxes_r[i].style.display = "inline-block";
        labels_r[i].style.display = "inline-block";
        manage_p[i].style.display = "block";
        manage_users_div[i].style.display = "flex";
    }

    for(var i = 0; i < checkboxes_m.length; i++){
        if(checkboxes_m[i].id.slice(11).toLowerCase().search(query.toLowerCase()) == -1){
            checkboxes_m[i].style.display = "none";
            labels_m[i].style.display = "none";
            checkboxes_r[i].style.display = "none";
            labels_r[i].style.display = "none";
            manage_p[i].style.display = "none";
            manage_users_div[i].style.display = "none";
        }
    }
}

window.onload = function(){
    var checkboxes_m = document.getElementsByClassName("btn-check-moderator");
    var checkboxes_r = document.getElementsByClassName("btn-check-remove");

    for(var i = 0; i < checkboxes_m.length; i++){
        checkboxes_m[i].addEventListener('change', function(){
            if(this.checked){
                var checkbox_r = document.getElementById("btncheck_r_" + this.id.slice(11))
                checkbox_r.checked = false;
            }
        });
        checkboxes_r[i].addEventListener('change', function(){
            if(this.checked){
                var checkbox_m = document.getElementById("btncheck_m_" + this.id.slice(11))
                checkbox_m.checked = false;
            }
        });
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
