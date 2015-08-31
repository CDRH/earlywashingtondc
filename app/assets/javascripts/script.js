/* Javascript File */

$(document).ready(function(){
    $("a[rel^='prettyPhoto']").prettyPhoto({
    social_tools: false,
    theme: 'pp_default',
    show_title: true,
    deeplinking: false,
    overlay_gallery: false,
    slideshow: false
    });
  });
  

  $(document).ready(function() {
    $("#metadata_toggle").on("click", function() {
      var toggler = $(this);
      var metadata = $("#more_metadata");
      metadata.slideToggle("slow", function() {
        label = metadata.is(":hidden") ? 'View more metadata' : 'View less metadata';
        toggler.text(label);
      });
    });
  });
  
  $(document).ready(function() {
  $('.pagination .disabled a, .pagination .active a').on('click', function(e) {
    e.preventDefault();
});
});
  
