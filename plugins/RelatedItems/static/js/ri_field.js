$(function(){
    var show_preview = $.cookie('ri_show_preview');
    if (show_preview) {
        console.log('show preview!');
    }
    else {
        console.log('don\'t show preview');
    }
    $('#ri_show_preview').click(function(){
        show_preview =  $('#ri_show_preview').attr('checked');
        console.log(show_preview);
        $('.ri_preview').toggle(show_preview);
        $.cookie('ri_show_preview', show_preview);
    });
    $('input[name="<mt:var name="field_name">"]').keypress(function(event){
        console.log('keypress: ' + event.which);
        if (!show_preview) {
            return;
        }
        if (this.value != '') {
            var val = this.value;
            // normalize the tags value
            var tags = val.split(',').map(function(str){ return $.trim(str)})
            tagsstr = tags.join(',');
            console.log(tags);
            var ri_url = '/~steve/mt-pro/mt-search.cgi?__mode=ri_list_related_items&tags='+tagsstr+'&type=entry&count=3&blog_id='+blog_id;
            console.log(ri_url);
            $('.ri_preview').load(ri_url);
            $('.ri_preview').show();
        }
        else {
            $('.ri_preview').hide();
            $('.ri_preview').html('');
        }
    });
});