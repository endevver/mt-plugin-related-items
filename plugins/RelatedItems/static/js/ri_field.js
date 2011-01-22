var toid;

// load the preview based on the tags entered.
function get_preview (tags) {
    if (tags != '') {
        var val = tags;
        // normalize the tags value
        var tags = val.split(',').map(function(str){ return $.trim(str)})
        tagsstr = tags.join(',');
        console.log(tags);
        var ri_url = '/~steve/mt-pro/mt-search.cgi?__mode=ri_list_related_items&tags='+tagsstr+'&type=entry&count=3&blog_id='+blog_id;
        console.log(ri_url);
        $('.ri_preview').load(ri_url);
        $('.ri_preview').show(0);
    }
    else {
        $('.ri_preview').hide(0);
        $('.ri_preview').html('');
    }
}

$(function(){
    var show_preview = $.cookie('ri_show_preview');
    $('#ri_show_preview').click(function(){
        show_preview =  $('#ri_show_preview').attr('checked');
        console.log(show_preview);
        $('.ri_preview').toggle(show_preview);
        $.cookie('ri_show_preview', show_preview);
    });
    $('input[name='+field_name+']').keyup(function(e){
        console.log('keyup: ' + e.which);
        if (!show_preview) {
            return;
        }
        if (toid) {
            clearTimeout(toid);
        }
        toid = setTimeout('get_preview(\''+this.value+'\')', 750);
    })
});