function filter_results(){
    var checkboxes = document.getElementsByClassName("btn-check");
    var labels = document.getElementsByClassName("checkbox-label");
    var query = document.getElementById("username").value;

    var follow_div = document.getElementsByClassName("follow-div");
    var follow_p = document.getElementsByClassName("follow-p");

    for(var i = 0; i < checkboxes.length; i++){
        checkboxes[i].style.display = "inline-block";
        labels[i].style.display = "inline-block";
        follow_div[i].style.display = "flex";
        follow_p[i].style.display = "block";
    }

    for(var i = 0; i < checkboxes.length; i++){
        if(checkboxes[i].id.slice(9).toLowerCase().search(query.toLowerCase()) == -1){
            checkboxes[i].style.display = "none";
            labels[i].style.display = "none";
            follow_div[i].style.display = "none";
            follow_p[i].style.display = "none";
        }
    }
}

