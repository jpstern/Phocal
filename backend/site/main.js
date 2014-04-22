

$(document).ready(function() {

    $(".nav a").click(function(e) {
        e.preventDefault();

        var id = $(this).attr("href")
        console.log(id)
        showPane(id);
    });

    function showPane(id) {
        // hide all sections
        $("section").hide();

        // show home screen right away
        $(id).show();
    }

    showPane("#home");

});
