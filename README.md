# Related Items

Provide a tags field that allows users to relate entries or assets (or any Taggable objects) to the current entry.

## Setup

* Create a new "Related Items Tags" Custom field in the blog or at the System level
* Select the object for the custom field (entry, page, etc)
* Give the field a name (ie: "Documentation Pages")
* Select the type of objects that will be related through this field (entry, page, etc)
* Give the field a basename (ie: "related_documentation_pages")
* Give the field a tag name (ie: "EntryDocumentationPages")
* Save the field

On the edit entry screen:

* Under "Display options", select "Documentation Pages" to display the field
* Enter some tags in the field.
* Save the entry

## Tag Usage

In the Entry archive template, or Entry Summary template, add template code to list the related objects:

    <mt:ifnonempty name="EntryDocumentationPages"> <!-- checks for tags in the field -->
        <mt:RelatedItems 
            basename="related_documentation_pages"
            lastn="3"
            blog_id="3">
            
        </mt:RelatedItems
    </mt:ifnonempty>
