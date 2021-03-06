package au.org.biodiversity.nsl

/**
 * A uri that may be used as a value node in a tree.
 * The main purpose of this class is to generate picklists.
 * Created by pmurray on 17/11/16.
 */
class ValueNodeUri {
    Arrangement root
    UriNs linkUriNsPart
    String linkUriIdPart
    UriNs nodeUriNsPart
    String nodeUriIdPart

    String label
    String title
    String description

    int sortOrder = 0

    boolean isMultiValued = false
    boolean isResource = false
    boolean deprecated = false

    static belongsTo = [
            root         : Arrangement,
            linkUriNsPart: UriNs,
            nodeUriNsPart: UriNs
    ]

    static mapping = {
        datasource 'nsl'
        table 'tree_value_uri'
        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultvalue: 0
        isMultiValued defaultvalue: false
        isResource defaultvalue: false
        deprecated defaultvalue: false

        root index: 'by_root_id,link_uri_index,node_uri_index'
        linkUriNsPart index: 'link_uri_index'
        linkUriIdPart index: 'link_uri_index'
        nodeUriNsPart index: 'node_uri_index'
        nodeUriIdPart index: 'node_uri_index'
    }

    static constraints = {
        root nullable: false
        linkUriNsPart nullable: false
        linkUriIdPart nullable: false
        nodeUriNsPart nullable: false
        nodeUriIdPart nullable: false
        label nullable: false, maxSize: 20
        title nullable: false, maxSize: 50
        description nullable: true, maxSize: 2048
        // don't need nullable constraints
        // for columns mapped to primitive types
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        ValueNodeUri that = (ValueNodeUri) o

        if (deprecated != that.deprecated) return false
        if (isMultiValued != that.isMultiValued) return false
        if (isResource != that.isResource) return false
        if (sortOrder != that.sortOrder) return false
        if (description != that.description) return false
        if (id != that.id) return false
        if (label != that.label) return false
        if (linkUriIdPart != that.linkUriIdPart) return false
        if (nodeUriIdPart != that.nodeUriIdPart) return false
        if (root != that.root) return false
        if (title != that.title) return false

        return true
    }

    int hashCode() {
        int result
        result = root.hashCode()
        result = 31 * result + linkUriIdPart.hashCode()
        result = 31 * result + nodeUriIdPart.hashCode()
        result = 31 * result + label.hashCode()
        result = 31 * result + title.hashCode()
        result = 31 * result + (description != null ? description.hashCode() : 0)
        result = 31 * result + sortOrder
        result = 31 * result + (isMultiValued ? 1 : 0)
        result = 31 * result + (isResource ? 1 : 0)
        result = 31 * result + (deprecated ? 1 : 0)
        result = 31 * result + (id != null ? id.hashCode() : 0)
        return result
    }

}



