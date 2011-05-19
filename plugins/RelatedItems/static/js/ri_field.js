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
    _debug("get_preview -- getting preview for field: " + field_name + " id: " + preview_id + " type: " + type + " blog_id: " + blog_id + " tags: " + tags);

    // Strip any leading or trailing whitespace from the supplied tags. The
    // user may enter leading or trailing spaces and we don't want them to
    // matter. More important, however, is that if the field consists of
    // nothing but a space, we don't want to trigger a preview because it'll
    // surely fail.
    tags = $.trim(tags);

    if (tags) {
        var val = tags;
        // normalize the tags value
        var tags = val.split(/\s*,\s*/).map(function(str){ return str.replace(' ','') })
        tagsstr = tags.join(',');

        // Craft the AJAX request URL. blog_id and type are set in the page
        var ri_url = ScriptURI + '?__mode=ri_list_related_items'
        + '&_type=' + source_type
        + '&id=' + source_id
        + '&tags=' + tagsstr
        + '&basename=' + field_name 
        + '&type=' + type
        + '&count=' + count
        + '&blog_id=' + blog_id;

        // Submit the request and display the results in the Preview area.
        $(preview_id + " .preview_pane").load(ri_url, function(){
            _debug('loaded, showing ' + preview_id);
            $(preview_id).show();
        });
    }
    
    // No tags were supplied, so the user is probably trying to clear the 
    // field. Delete all of the contents stuff.
    else {
        if (source_id) {
            $(preview_id + " .preview_pane").html(
                'Nothing to preview. Enter comma-separated tags to search '
                + 'for a matching ' + type + '.'
            );
        }
        else {
            $(preview_id + " .preview_pane").html(
                'This ' + type + ' must be saved before a preview can be'
                + ' provided.'
            );
        }
    }
}

function show_preview(switch_id){
    return $(switch_id).attr('checked');
}

// Prep the preview text field to be used: set the blog_id variable, and add
// the trigger to monitor the text input field for new tags.
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
    $('input[name='+field_name+']').bind('keyup', function(e){
        _debug("autocomplete -- keyup: " + e.which);

        if (toids[field_name]) {
            clearTimeout(toids[field_name]);
        }
        var args = [source_type, source_id, field_name, preview_id, type, blog_id, this.value, count];
        
        // Use setTimeout to give a 750 msec delay. This way the field isn't
        // constantly trying to retrieve matches and it gives the user a
        // little time to keep typing and therefore avoiding partial tag
        // searches.
        toids[field_name] = setTimeout('get_preview(\''+args.join('\',\'')+'\')', 750);
    });
    
    // After the field is properly initialized and if there are any existing
    // tags entered, try to find a matching object to display.
    get_preview( 
        source_type, 
        source_id, 
        field_name, 
        preview_id, 
        type, 
        blog_id, 
        $('#'+field_name).val(), 
        count
    );
}

RI_SCRIPT_LOADED=true;