window.onload = function(){
    function submitOnShiftEnter(event){
        if(event.which === 13 && !event.shiftKey){
            event.target.form.dispatchEvent(new Event("submit", {cancelable: true}));
            event.preventDefault();
        }
    }

    //document.getElementById("message_textarea").addEventListener("keypress", submitOnShiftEnter);
}
