# Related Items

Provide an tags field that allows users to relate entries or assets (or any Taggable objects) to the current entry.

## Tag Usage

    <mt:ifnonempty name="CustomFieldTagName">
        <mt:RelatedItems 
            basename="related_documentation_entries"
            count="3"
            template="template module name" />
    </mt:ifnonempty>
