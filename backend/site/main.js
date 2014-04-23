

$(document).ready(function() {

    showPane(document.location.hash);

    $("a").click(function(e) {
        var id = $(this).attr("href");
        if (id[0] == "#") {
            e.preventDefault();
            showPane(id);
        }
    });

    function showPane(id) {
        if(!id) id = "#home";

        // hide all sections
        $("section").hide();

        // show home screen right away
        $(id).show();

        document.location.hash = id;
        $("body").scrollTop(0);
    }
});
