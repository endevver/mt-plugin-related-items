# Related Items Overview

Related Items provides a custom field type that allows users to relate the
current object to any Taggable object. Said differently, with this custom
field you can relate a system object (Entry, Page, Category, Folder, or User)
to Taggable objects: assets, entries, and pages.

For example, a Related Items custom field configured to relate Assets to Pages
would allow the published Page to display related Assets.

Use the Related Items custom field by entering a tag or tags in the field. The
resulting matches are displayed in a "preview" area to help ensure the correct
match was found.


## Prerequisites

* Movable Type Professional
* [Config Assistant](https://github.com/openmelody/mt-plugin-configassistant/downloads)

## Installation

To install this plugin follow the instructions found here:

<http://tinyurl.com/easy-plugin-install>

## Configuration

Related Items can be configured at the Blog level. Visit Tools > Plugins to
find Related Items, then click Settings.

The **Show a Preview** option is enabled by default and will display tag
matches.

**Related Items Count** is the number of items returned in the preview area.
Use this setting to ensure you don't accidentally grab thousands of items, for
example. (The total number of found items is shown in the preview area if it
exceeds the Count value set here.)

If you want to use a Related Items field in your theme, specify
`related_items_tags` as the "type" in the field definition.

## Use

Create a Related Items custom field as you would any other custom field:

* Go to Preferences > Custom Fields in your blog or from the system overview 
  (fields defined at the System level will be available to all blogs).
* Click "New field"
* Set the *System Object* for the field (Entry, Page, etc). This is the type 
  of object you want the target items to be related to.
* Give the field a *Name* (ie: "Documentation Pages") and optionally a 
  *Description.*
* Set the *Type* of the field to "Related Items Tags."
* Set *Relate Items of Type* to the type of objects that will be related 
  through this field (entry, page, etc).
* If this will be a required field, set *Required*.
* Note the field *basename* and *template tag* for later use.
* Save the field.

On the Edit Entry (or Edit Page) screen:

* In the upper-right select *Display Options,* select your new Related Items 
  field to make the field visible.
* Enter some tags in the field and see the preview appear.
* Save the entry.

## Template Tags

Related Items provides one template tag, the block tag `RelatedItems`. This
tag creates on object loop of the related items, and provides the normal meta
loop variables as well (`__first__`, `__last__`, `__even__`, `__odd__`,
`__counter__`). The tags has one required argument: `basename`. This should be
set to the basename of the field you want to list related items for.
Additionally the tag accepts both `blog_id` and `lastn` arguments. Setting
`blog_id` will tell the tag to pull related items from a different blog from
the one currently in context. Setting `lastn` will limit the returned results
to this number. By default, the tag will return the number set in the plugin
settings (defaults to 5).

### Example

In this example, a Related Items field was created for Entries, relating to
Assets. The tag `EntryDataRelatedAssets` and the basename
`entry_data_related_assets` was created for this field. In the entry template
this code could be used to generate a list of Assets related to the Entry:

    <mt:IfNonEmpty tag="EntryDataRelatedAssets">
        <ul>
        <mt:RelatedItems basename="entry_data_related_assets">
            <li><a href="<mt:AssetURL>"><mt:AssetLabel></a></li>
        </mt:RelatedItems
        </ul>
    </mt:IfNonEmpty>

## Acknowledgements

This plugin was commissioned by Endevver to Steve Ivy of Wallrazer. Endevver
is proud to be partners with Wallrazer. <http://wallrazer.com>

## License

This plugin is licensed under the same terms as Perl itself.

## Copyright

Copyright 2011, [Endevver, LLC](http://endevver.com). All rights reserved.
