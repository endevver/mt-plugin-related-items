# Related Items Overview

Related Items provides a custom field that allows users to relate the current object to any Taggable object. Said differently, with this custom field you can relate a system object (Entry, Page, Category, Folder, or User) to Taggable objects: assets, entries, and pages.

After creating a Related Items custom field, a tag or tags can be entered in the field. The resulting matches are displayed in a "preview" area to help ensure the correct tag or tags were entered.

For example, a site may want to link a documentation page to blog posts that are related to the subject being documented. With a Related Items custom field on Pages, configured to relate Entries, the Page template can load related blog posts and render the list along with the Page content. Another Related Items custom field configured to relate Assets (files) would allow the Page template to load related Assets and display them.

## Prerequisites

* Movable Type Professional
* [Config Assistant](https://github.com/openmelody/mt-plugin-configassistant/downloads)

## Installation

To install this plugin follow the instructions found here:

<http://tinyurl.com/easy-plugin-install>

## Configuration

Related Items can be configured at the Blog level. Visit Tools > Plugins to find Related Items, then click Settings.

The **Show a Preview** option is enabled by default and will display tag matches.

**Related Items Count** is the number of items returned in the preview area. Use this setting to ensure you don't accidentally grab thousands of items, for example. (The total number of found items is shown in the preview area if it exceeds the Count value set here.)

## Use

### Add a new Related Items field

Create a Related Items custom field as you would any other custom field:

* Go to Preferences > Custom Fields in your blog or from the system overview (fields defined at the System level will be available to all blogs).
* Click "New field"
* Related Items Tags" Custom field in the blog or at the System level
* Set the **System Object** for the field (Entry, Page, etc). This is the type of object you want the target items to be related to.
* Give the field a **Name** (ie: "Documentation Pages") and optionally a **Description**
* Set the **Type** of the field to "Related Items Tags"
* Set **Relate Items of Type** to the type of objects that will be related through this field (entry, page, etc)
* If this will be a required field, set **Required**. 
* Give the field a **Basename** (ie: "related_documentation_pages"). This is important (as well as required) as this is the name you will use to tell the template tag which field to draw related items based on.
* Give the field a **Template Tag** name (ie: "EntryDocumentationPages")
* Save the field

On the Edit Entry (or Edit Page) screen:

* Under **Display Options**, select "Documentation Pages" to display the field
* Enter some tags in the field.
* Save the entry

## Template Tags

Related Items provides one template tag, the block tag **RelatedItems**. This tag creates on object loop of the related items, and provides the normal meta loop variables as well (\_\_first\_\_, \_\_last\_\_, \_\_even\_\_, \_\_odd\_\_, \_\_counter\_\_). The tags has one required argument: `basename`. This should be set to the basename of the field you want to list related items for. Additionally the tag accepts both `blog_id` and `lastn` arguments. Setting `blog_id` will tell the tag to pull related items from a different blog from the one currently in context. Setting `lastn` will limit the returned results to this number. By default, the tag will return the number set in the plugin settings (defaults to 5).

### Example

In the Entry archive template, or Entry Summary template, add template code to list the related objects:

    <mt:ifnonempty name="EntryDocumentationPages"> <!-- checks for tags in the field -->
        <ul>
        <mt:RelatedItems 
            basename="related_documentation_pages"
            lastn="3"
            blog_id="3">
            <li><a href="<mt:PagePermalink />"><mt:PageTitle /></a></li>
        </mt:RelatedItems
        </ul>
    </mt:ifnonempty>

## Acknowledgements

This plugin was commissioned by Endevver to Steve Ivy of Wallrazer. Endevver is proud to be partners with Wallrazer. <http://wallrazer.com>

## License

This plugin is licensed under the same terms as Perl itself.

## Copyright

Copyright 2011, [Endevver, LLC](http://endevver.com). All rights reserved.
