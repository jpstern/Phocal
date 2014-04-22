

$(document).ready(function() {

    $("a").click(function(e) {
        var id = $(this).attr("href");
        if (id[0] == "#") {
            e.preventDefault();
            showPane(id);
        }
    });

    function showPane(id) {
        // hide all sections
        $("section").hide();

        // show home screen right away
        $(id).show();
    }

    showPane("#home");

});
