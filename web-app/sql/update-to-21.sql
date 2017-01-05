ALTER TABLE name_status
  ADD COLUMN deprecated BOOLEAN DEFAULT FALSE NOT NULL;

DROP VIEW public.accepted_name_vw;
CREATE VIEW public.accepted_name_vw AS
  SELECT
    accepted.id,
    accepted.simple_name,
    accepted.full_name,
    accepted.full_name_html,
    tree_node.type_uri_id_part AS type_code,
    instance.id                AS instance_id,
    tree_node.id               AS tree_node_id,
    0                          AS accepted_id,
    '' :: CHARACTER VARYING    AS accepted_full_name,
    accepted.name_status_id,
    instance.reference_id,
    accepted.name_rank_id,
    accepted.sort_name,
    0                          AS synonym_type_id,
    0                          AS synonym_ref_id,
    0                          AS citer_instance_id,
    0                          AS cites_instance_id,
    '' :: CHARACTER VARYING    AS cites_instance_type_name,
    FALSE                      AS cites_misapplied,
    0                          AS citer_ref_year,
    0                          AS cites_cites_id,
    0                          AS cites_cites_ref_id,
    0                          AS cites_cites_ref_year
  FROM name accepted
    JOIN instance ON accepted.id = instance.name_id
    JOIN tree_node ON accepted.id = tree_node.name_id
    JOIN tree_arrangement ta ON tree_node.tree_arrangement_id = ta.id
  WHERE ta.label :: TEXT = (((SELECT shard_config.value
                              FROM shard_config
                              WHERE shard_config.name :: TEXT = 'tree label' :: TEXT)) :: TEXT)
        AND tree_node.next_node_id IS NULL
        AND tree_node.checked_in_at_id IS NOT NULL
        AND instance.id = tree_node.instance_id;

DROP VIEW public.accepted_synonym_vw;
CREATE VIEW public.accepted_synonym_vw AS
  SELECT
    name_as_syn.id,
    name_as_syn.simple_name,
    name_as_syn.full_name,
    name_as_syn.full_name_html,
    'synonym' :: CHARACTER VARYING AS type_code,
    citer.id                       AS instance_id,
    tree_node.id                   AS tree_node_id,
    citer_name.id                  AS accepted_id,
    citer_name.full_name           AS accepted_full_name,
    name_as_syn.name_status_id,
    0                              AS reference_id,
    name_as_syn.name_rank_id,
    name_as_syn.sort_name,
    cites.instance_type_id         AS synonym_type_id,
    cites.reference_id             AS synonym_ref_id,
    citer.id                       AS citer_instance_id,
    cites.id                       AS cites_instance_id,
    cites_instance_type.name       AS cites_instance_type_name,
    cites_instance_type.misapplied AS cites_misapplied,
    citer_ref.year                 AS citer_ref_year,
    cites_cites.id                 AS cites_cites_id,
    cites_cites.reference_id       AS cites_cites_ref_id,
    cites_cites_ref.year           AS cites_cites_ref_year
  FROM name name_as_syn
    JOIN instance cites ON name_as_syn.id = cites.name_id
    JOIN instance_type cites_instance_type ON cites.instance_type_id = cites_instance_type.id
    JOIN reference cites_ref ON cites.reference_id = cites_ref.id
    JOIN instance citer ON cites.cited_by_id = citer.id
    JOIN reference citer_ref ON citer.reference_id = citer_ref.id
    JOIN name citer_name ON citer.name_id = citer_name.id
    JOIN tree_node ON citer_name.id = tree_node.name_id
    JOIN tree_arrangement ta ON tree_node.tree_arrangement_id = ta.id
    JOIN instance cites_cites ON cites.cites_id = cites_cites.id
    JOIN reference cites_cites_ref ON cites_cites.reference_id = cites_cites_ref.id
  WHERE ta.label :: TEXT = (((SELECT shard_config.value
                              FROM shard_config
                              WHERE shard_config.name :: TEXT = 'tree label' :: TEXT)) :: TEXT)
        AND tree_node.next_node_id IS NULL
        AND tree_node.checked_in_at_id IS NOT NULL
        AND tree_node.instance_id = citer.id;

-- update grants
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_arrangement TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_link TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_node TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_uri_ns TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON name_tree_path TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON id_mapper TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON author TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON delayed_jobs TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON external_ref TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON help_topic TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON instance TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON instance_type TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON instance_note TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON instance_note_key TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON language TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON locale TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON name TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON name_category TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON name_group TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON name_part TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON name_rank TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON name_status TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON name_type TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON namespace TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON nomenclatural_event_type TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON ref_author_role TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON ref_type TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON reference TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON user_query TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON notification TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON name_tag TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON name_tag_name TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON comment TO ${webUserName};
GRANT SELECT, UPDATE ON nsl_global_seq TO ${webUserName};
GRANT SELECT, UPDATE ON hibernate_sequence TO ${webUserName};
GRANT SELECT ON shard_config TO ${webUserName};

GRANT SELECT ON accepted_name_vw TO ${webUserName};
GRANT SELECT ON accepted_synonym_vw TO ${webUserName};
GRANT SELECT ON name_detail_synonyms_vw TO ${webUserName};
GRANT SELECT ON name_details_vw TO ${webUserName};
GRANT SELECT ON name_detail_commons_vw TO ${webUserName};
GRANT SELECT ON name_or_synonym_vw TO ${webUserName};

-- NSL-2045: support for profile data on trees.

-- the primary keys on these rows are not used as fkeys anywhere else, and so is ok to drop
DROP TABLE IF EXISTS tree_value_uri;

CREATE TABLE tree_value_uri (
  id                  INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version        INT8 DEFAULT 0                         NOT NULL,
  deprecated          BOOLEAN DEFAULT FALSE                  NOT NULL,
  description         VARCHAR(2048),
  is_multi_valued     BOOLEAN DEFAULT FALSE                  NOT NULL,
  is_resource         BOOLEAN DEFAULT FALSE                  NOT NULL,
  label               VARCHAR(20)                            NOT NULL,
  link_uri_id_part    VARCHAR(255)                           NOT NULL,
  link_uri_ns_part_id INT8                                   NOT NULL,
  node_uri_id_part    VARCHAR(255)                           NOT NULL,
  node_uri_ns_part_id INT8                                   NOT NULL,
  root_id             INT8                                   NOT NULL,
  sort_order          INT4                                   NOT NULL,
  title               VARCHAR(50)                            NOT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX link_uri_index
  ON tree_value_uri (link_uri_id_part, link_uri_ns_part_id, root_id);

CREATE INDEX node_uri_index
  ON tree_value_uri (node_uri_id_part, node_uri_ns_part_id, root_id);

CREATE INDEX by_root_id
  ON tree_value_uri (root_id);

ALTER TABLE IF EXISTS tree_value_uri
  ADD CONSTRAINT FK_ds3bc89iy6q3ts4ts85mqiys
FOREIGN KEY (link_uri_ns_part_id)
REFERENCES tree_uri_ns;

ALTER TABLE IF EXISTS tree_value_uri
  ADD CONSTRAINT FK_djkn41tin6shkjuut9nam9xvn
FOREIGN KEY (node_uri_ns_part_id)
REFERENCES tree_uri_ns;

ALTER TABLE IF EXISTS tree_value_uri
  ADD CONSTRAINT FK_nw785lqesvg8ntfaper0tw2vs
FOREIGN KEY (root_id)
REFERENCES tree_arrangement;

INSERT INTO TREE_VALUE_URI (
  root_id,
  link_uri_ns_part_id,
  link_uri_id_part,
  node_uri_ns_part_id,
  node_uri_id_part,
  label, title, is_multi_valued, is_resource, sort_order
)
VALUES (
  (SELECT id
   FROM tree_arrangement
   WHERE label = '${classificationTreeName}'),
  (SELECT id
   FROM tree_uri_ns
   WHERE label = 'apc-voc'), 'distribution',
  (SELECT id
   FROM tree_uri_ns
   WHERE label = 'apc-voc'), 'distributionstring',
  'apc-distribution', 'APC Distribution',
  FALSE, FALSE, 1
);

INSERT INTO TREE_VALUE_URI (
  root_id,
  link_uri_ns_part_id,
  link_uri_id_part,
  node_uri_ns_part_id,
  node_uri_id_part,
  label, title, is_multi_valued, is_resource, sort_order
) VALUES (
  (SELECT id
   FROM tree_arrangement
   WHERE label = '${classificationTreeName}'),
  (SELECT id
   FROM tree_uri_ns
   WHERE label = 'apc-voc'), 'comment',
  (SELECT id
   FROM tree_uri_ns
   WHERE label = 'xs'), 'string',
  'apc-comment',
  'APC Comment',
  FALSE, FALSE, 1
);

GRANT SELECT, INSERT, UPDATE, DELETE ON tree_value_uri TO ${webUserName};
GRANT SELECT ON tree_value_uri TO read_only;

-- a name may appear only once as a current name in any tree
-- this makes our trees less general ... but matches how we use them these days
ALTER TABLE tree_node
  ADD CONSTRAINT current_name_only_once
EXCLUDE (tree_arrangement_id with =, name_id with = )
WHERE (name_id is not null and replaced_at_id is null);

-- NSL-2033 add columns to shard_config
-- these have to be done prior to auto update because it uses shard config
-- alter table shard_config add column deprecated boolean default false not null;
-- alter table shard_config add column use_notes varchar(255);

update shard_config set deprecated = true where name = 'tree label';
update shard_config set use_notes = 'deprecated, please use classification tree key' where name = 'tree label';
update shard_config set deprecated = true where name = 'classification tree label';
update shard_config set use_notes = 'deprecated, please use classification tree key' where name = 'classification tree label';

insert into shard_config (name, value, use_notes)
  (select 'classification tree key', value, 'Used in sql join to the tree arrangement table on the label column for the accepted classification.'
   from shard_config WHERE name = 'classification tree label' );

CREATE VIEW public.workspace_value_vw as
SELECT name_node_link.id name_node_link_id,
       name_node.id name_node_id,
       instance.id instance_id,
       name_sub_link.type_uri_id_part,
       name_sub_link.type_uri_ns_part_id,
       workspace.id workspace_id,
       name_sub_link.type_uri_id_part name_sub_link_type_uri_id,
       name_sub_link_value.link_uri_id_part name_sub_link_value_link_uri_id_part,
       name_sub_link.type_uri_id_part field_name,
       value_node.literal,
       value_node.literal field_value,
       name_node.name_id name_id,
       name_sub_link_value.label value_label,
       value_node.id value_node_id,
       name_sub_link_value.sort_order
from tree_link name_node_link
     inner join tree_node name_node
     on name_node_link.subnode_id = name_node.id
     inner join instance
     on name_node.instance_id = instance.id
     inner join tree_link name_sub_link
     on name_node.id = name_sub_link.supernode_id
     inner join tree_value_uri name_sub_link_value
     on name_sub_link.type_uri_id_part = name_sub_link_value.link_uri_id_part
     inner join tree_arrangement workspace
     on name_node.tree_arrangement_id = workspace.id
     inner join tree_node value_node
     on name_sub_link.subnode_id = value_node.id
;

CREATE VIEW public.workspace_instance_value_vw as
SELECT workspace.id workspace_id,
       instance.id instance_id,
       tree_node.tree_arrangement_id,
       tree_node.id tree_node_id,
       tree_link.id tree_link_id,
       workspace.title workspace_title,
       tree_uri_ns.label tree_uri_ns_label,
       tree_link.type_uri_id_part tree_link_type_uri_id_part,
       base.label base_label,
       base_value.id base_value_uri_id,
       base_value.link_uri_ns_part_id base_link_uri_ns_part,
       link_value.link_uri_ns_part_id link_uri_ns_part,
       link_value.id link_value_uri_id,
       base_ns.title,
       tree_link.subnode_id,
       value_node.type_uri_id_part,
       link_value.link_uri_id_part link_uri_id_part,
       base_value.link_uri_id_part base_link_uri_id_part,
       value_node.literal
  from instance
 inner join tree_node
    on instance.id = tree_node.instance_id
 inner join tree_link
    on tree_node.id = tree_link.supernode_id
 inner join tree_value_uri link_value
    on tree_link.type_uri_id_part = link_value.link_uri_id_part
 inner join tree_uri_ns
    on tree_link.type_uri_ns_part_id = tree_uri_ns.id
 inner join tree_arrangement workspace
    on tree_node.tree_arrangement_id = workspace.id
 inner join tree_arrangement base
    on workspace.base_arrangement_id = base.id
 inner join tree_value_uri base_value
    on base.id = base_value.root_id
 inner join tree_uri_ns base_ns
    on base_value.node_uri_ns_part_id = base_ns.id
 inner join tree_node value_node
    on tree_link.subnode_id = value_node.id
 where link_value.link_uri_id_part = base_value.link_uri_id_part
;

CREATE
    OR REPLACE view public.workspace_value_namespace_vw as
SELECT workspace.id "workspace_id", workspace.title "workspace_title",
       base.label "base_tree_label", value.label "value_label",
       value.link_uri_id_part "value_link_uri_id_part",
       value.node_uri_id_part "value_node_uri_id_part",
       value.node_uri_ns_part_id "Value_node_uri_ns_part_id",
       value.title "value_title",
       node_namespace.description "node_namespace_description",
       node_namespace.id_mapper_namespace_id "node_namespace_id_mapper_namespace_id",
       node_namespace.id_mapper_system "node_namespace_id_mapper_system",
       node_namespace.label "node_namespace_label",
       node_namespace.owner_uri_id_part "node_namespace_owner_uri_id_part",
       node_namespace.owner_uri_ns_part_id "node_namespace_owner_uri_ns_part_id",
       node_namespace.title "node_namespace_title",
       node_namespace.uri "node_namespace_uri",
       link_namespace.description "link_namespace_description",
       link_namespace.id_mapper_namespace_id "link_namespace_id_mapper_namespace_id",
       link_namespace.id_mapper_system "link_namespace_id_mapper_system",
       link_namespace.label "link_namespace_label",
       link_namespace.owner_uri_id_part "link_namespace_owner_uri_id_part",
       link_namespace.owner_uri_ns_part_id "link_namespace_owner_uri_ns_part_id",
       link_namespace.title "link_namespace_title",
       link_namespace.uri "link_namespace_uri"
  from tree_arrangement workspace
 inner join tree_arrangement base
    on workspace.base_arrangement_id = base.id
 inner join tree_value_uri value
    on base.id = value.root_id
 inner join tree_uri_ns node_namespace
    on value.node_uri_ns_part_id = node_namespace.id
 inner join tree_uri_ns link_namespace
    on value.link_uri_ns_part_id = link_namespace.id
;

-- version
UPDATE db_version
SET version = 21
WHERE id = 1;
