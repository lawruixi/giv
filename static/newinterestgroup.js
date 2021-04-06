function filter_results(){
    var divs = document.getElementsByClassName("interest-group-div");
    var ps = document.getElementsByClassName("interest-group-p");
    var buttons = document.getElementsByClassName("interest-group-btn");
    var query = document.getElementById("interest_group_name").value;

    for(var i = 0; i < divs.length; i++){
        divs[i].style.display = "flex";
        ps[i].style.display = "flex";
        buttons[i].style.display = "flex";
    }

    for(var i = 0; i < divs.length; i++){
        if(ps[i].textContent.toLowerCase().search(query.toLowerCase()) == -1){
            divs[i].style.display = "none";
            ps[i].style.display = "none";
            buttons[i].style.display = "none";
        }
    }
}
