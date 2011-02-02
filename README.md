# Related Items Overview

Related Items provides a custom field that allows users to relate entries or assets (or any Taggable objects) to the current entry by way of a set of tags. After adding the custom field to a blog, a set of tags can be entered in the field. In blog templates, the RelatedItems block tag can be used to pull in the related entries, pages, or assets in an object loop to be rendered in the template.

For example, a site may want to link a documentation page to blog posts about that are related to the subject being documented, and to realted file uploadeds as well. With a "Related Items" field on Page, configured to relate Entries, the Page template can load related blog posts and render the list along with the Page content. Another "Related Items" field configured to relate Assets (files) would allow the Page template to load related file uploads and display them.

## Prerequisites

* [Config Assitant](https://github.com/openmelody/mt-plugin-configassistant)

## Installation

To install this plugin follow the instructions found here:

<http://tinyurl.com/easy-plugin-install>

## Configuration

Related Items can be configured at the Blog level. Visit Tools > Plugins to find Related Items, then click Settings.

**Related Items Count** is the default number of items that will be returned for a given field if not overridden in the template tag.

## Use

### Add a new Related Items field

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

On the edit entry screen:

* Under **Display Options**, select "Documentation Pages" to display the field
* Enter some tags in the field.
* Save the entry

## Template Tags

Related Items provides one template tag, the block tag **RelatedItems**. This tag creates on object loop of the related items, and provides the normal meta loop variables as well (\_\_first\_\_, \_\_last\_\_, \_\_even\_\_, \_\_odd\_\_, \_\_counter\_\_). The tags has one required argument: *basename*. This should be set to the basename of the field you want to list related items for. Additionally the tag accepts both *blog_id* and *lastn* arguments. Setting *blog_id* will tell the tag to pull related items from a different blog from the one currently in context. Setting *lastn* will limit the returned results to this number. By default, the tag will return the number set in the plugin settings (defaults to 5).

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
