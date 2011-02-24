/*
timout id:
we don't want to hit the server on every keystroke so we start a 3/4 sec timer.
each keystroke resets the timer. if you stop typing for 3/4 sec, it fetches the preview results.
*/
var toids = {};

RIDEBUG=false;

function _debug(msg) {
    if (RIDEBUG && console) {
        console.log(msg);
    }
}

// load the preview based on the tags entered.
function get_preview (source_type, source_id, field_name, preview_id, type, blog_id, tags, count) {
    _debug("get_preview -- getting preview for field: " + field_name + " id: " + preview_id + " type: " + tags + " blog_id: " + blog_id + " tags: " + tags);
            
    if (tags) {
        var val = tags;
        // normalize the tags value
        var tags = val.split(',').map(function(str){ return $.trim(str)})
        tagsstr = tags.join(',');

        // blog_id and type are set in the page
        var ri_url = ScriptURI + '?__mode=ri_list_related_items&_type='+source_type+'&id='+source_id+'&tags='+tagsstr+'&basename='+field_name+'&type='+type+'&count='+count+'&blog_id='+blog_id;
        $(preview_id + " .preview_pane").load(ri_url, function(){
			_debug('loaded, showing ' + preview_id);
            $(preview_id).show();
        });
    }
}

function show_preview(switch_id){
    return $(switch_id).attr('checked');
}

function setup_ri_field ( source_type, source_id, field_name, preview_switch_id, preview_id, type, blog_id, count ) {
    _debug("setup_preview_switch -- preview_switch_id: " + preview_switch_id);
    _debug("setup_preview_switch -- field_name: " + field_name);

    if (blog_id==0) {
        url = window.location.href;
        m = /blog_id=(\d+)/(url);
        if (m[1]) {
            blog_id = m[1]; 
        }
    }

    _debug("setup auto complete -- field_name: " + field_name);
    $('input[name='+field_name+']').keyup(function(e){
        _debug("autocomplete -- keyup: " + e.which);

        if (toids[field_name]) {
            clearTimeout(toids[field_name]);
        }
		var args = [source_type, source_id, field_name, preview_id, type, blog_id, this.value, count];
        toids[field_name] = setTimeout('get_preview(\''+args.join('\',\'')+'\')', 750);
    });
}

RI_SCRIPT_LOADED=true;