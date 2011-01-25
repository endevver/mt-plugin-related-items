
/* 
timout id:
we don't want to hit the server on every keystroke so we start a 3/4 sec timer.
each keystroke resets the timer. if you stop typing for 3/4 sec, it fetches the preview results.
*/
var toid;

// load the preview based on the tags entered.
function get_preview (tags) {
    if (tags != '') {
        var val = tags;
        // normalize the tags value
        var tags = val.split(',').map(function(str){ return $.trim(str)})
        tagsstr = tags.join(',');

        // blog_id and type are set in the page
        var ri_url = '/~steve/mt-pro/mt-search.cgi?__mode=ri_list_related_items&tags='+tagsstr+'&type='+type+'&count=3&blog_id='+blog_id;
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
        $('.ri_preview').toggle(show_preview);
        $.cookie('ri_show_preview', show_preview);

        if (show_preview) {
            get_preview($('input[name='+field_name+']').get(0).value);
        }
    });
    $('input[name='+field_name+']').keyup(function(e){
        if (!show_preview) {
            return;
        }
        if (toid) {
            clearTimeout(toid);
        }
        toid = setTimeout('get_preview(\''+this.value+'\')', 750);
    })
});