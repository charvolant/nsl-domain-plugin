package au.org.biodiversity.nsl

class TreeVersionElement {

    TreeVersionElement parent
    TreeElement treeElement
    TreeVersion treeVersion
    Long taxonId

    String treePath
    String namePath
    Integer depth = 0
    String elementLink
    String taxonLink

    static belongsTo = [TreeVersion, TreeElement]

    static mapping = {
        datasource 'nsl'
        id generator: 'assigned', name: 'elementLink', type: 'string'
        version false

        elementLink sqlType: 'Text', index: 'tree_version_element_link_index'
        parent sqlType: 'Text', index: 'tree_version_element_parent_index'
        taxonLink sqlType: 'Text', index: 'tree_version_element_taxon_link_index'
        treeElement index: 'tree_version_element_element_index'
        treeVersion index: 'tree_version_element_version_index'
        taxonId index: 'tree_version_element_taxon_id_index'
        treePath sqlType: 'Text', index: "tree_path_index"
        namePath sqlType: 'Text', index: "tree_name_path_index"
        depth defaultValue: 0
    }

    static constraints = {

    }

    String toString() {
        "TreeVersionElement ${treeElement?.simpleName} v: ${treeVersion?.id} e:${treeElement?.id} ($elementLink) t: $taxonId"
    }
}
