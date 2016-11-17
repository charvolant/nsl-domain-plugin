DROP VIEW IF EXISTS public.accepted_name_vw;
CREATE VIEW public.accepted_name_vw AS
SELECT accepted.id,
    accepted.simple_name,
    accepted.full_name,
    accepted.full_name_html,
    tree_node.type_uri_id_part AS type_code,
    instance.id AS instance_id,
    tree_node.id AS tree_node_id,
    0 AS accepted_id,
    ''::character varying AS accepted_full_name,
    accepted.name_status_id,
    instance.reference_id,
    accepted.name_rank_id,
    accepted.sort_name,
    0 AS synonym_type_id,
    0 AS synonym_ref_id,
    0 AS citer_instance_id,
    0 AS cites_instance_id,
    ''::character varying AS cites_instance_type_name,
    false AS cites_misapplied,
    0 AS citer_ref_year,
    0 AS cites_cites_id,
    0 AS cites_cites_ref_id,
    0 AS cites_cites_ref_year
   FROM name accepted
     JOIN instance ON accepted.id = instance.name_id
     JOIN tree_node ON accepted.id = tree_node.name_id
     JOIN tree_arrangement ta ON tree_node.tree_arrangement_id = ta.id
  WHERE ta.label::text = ((( SELECT shard_config.value
           FROM shard_config
          WHERE shard_config.name::text = 'tree label'::text))::text)
    AND tree_node.next_node_id IS NULL
    AND tree_node.checked_in_at_id IS NOT NULL
    AND instance.id = tree_node.instance_id;

DROP VIEW IF EXISTS public.accepted_synonym_vw;
CREATE VIEW public.accepted_synonym_vw AS
 SELECT name_as_syn.id,
    name_as_syn.simple_name,
    name_as_syn.full_name,
    name_as_syn.full_name_html,
    'synonym'::character varying AS type_code,
    citer.id AS instance_id,
    tree_node.id AS tree_node_id,
    citer_name.id AS accepted_id,
    citer_name.full_name AS accepted_full_name,
    name_as_syn.name_status_id,
    0 AS reference_id,
    name_as_syn.name_rank_id,
    name_as_syn.sort_name,
    cites.instance_type_id AS synonym_type_id,
    cites.reference_id AS synonym_ref_id,
    citer.id AS citer_instance_id,
    cites.id AS cites_instance_id,
    cites_instance_type.name AS cites_instance_type_name,
    cites_instance_type.misapplied AS cites_misapplied,
    citer_ref.year AS citer_ref_year,
    cites_cites.id AS cites_cites_id,
    cites_cites.reference_id AS cites_cites_ref_id,
    cites_cites_ref.year AS cites_cites_ref_year
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
  WHERE ta.label::text = ((( SELECT shard_config.value
           FROM shard_config
          WHERE shard_config.name::text = 'tree label'::text))::text)
  AND tree_node.next_node_id IS NULL
  AND tree_node.checked_in_at_id IS NOT NULL
  AND tree_node.instance_id = citer.id;


DROP VIEW IF EXISTS public.name_detail_commons_vw;
CREATE VIEW public.name_detail_commons_vw AS
SELECT instance.cited_by_id,
    ((ity.name::text || ':'::text) || name.full_name_html::text) ||
        CASE
            WHEN ns.nom_illeg OR ns.nom_inval THEN ns.name
            ELSE ''::character varying
        END::text AS entry,
    instance.id,
    instance.cites_id,
    ity.name AS instance_type_name,
    ity.sort_order AS instance_type_sort_order,
    name.full_name,
    name.full_name_html,
    ns.name,
    instance.name_id,
    instance.id AS instance_id,
    instance.cited_by_id AS name_detail_id
   FROM instance
     JOIN name ON instance.name_id = name.id
     JOIN instance_type ity ON ity.id = instance.instance_type_id
     JOIN name_status ns ON ns.id = name.name_status_id
  WHERE ity.name::text = ANY (ARRAY['common name'::character varying::text, 'vernacular name'::character varying::text]);


DROP VIEW IF EXISTS public.name_detail_synonyms_vw;
CREATE VIEW public.name_detail_synonyms_vw AS
  SELECT
    instance.cited_by_id,
    ((((ity.name) :: TEXT || ':' :: TEXT) || (name.full_name_html) :: TEXT) || (
      CASE
      WHEN (ns.nom_illeg OR ns.nom_inval)
        THEN ns.name
      ELSE '' :: CHARACTER VARYING
      END) :: TEXT)      AS entry,
    instance.id,
    instance.cites_id,
    ity.name             AS instance_type_name,
    ity.sort_order       AS instance_type_sort_order,
    name.full_name,
    name.full_name_html,
    ns.name,
    instance.name_id,
    instance.id          AS instance_id,
    instance.cited_by_id AS name_detail_id
  FROM (((instance
    JOIN NAME ON ((instance.name_id = NAME.id)))
          JOIN instance_type ity ON ((ity.id = instance.instance_type_id)))
    JOIN name_status ns ON ((ns.id = name.name_status_id)));

DROP VIEW IF EXISTS public.name_details_vw;
CREATE VIEW public.name_details_vw AS
  SELECT
    n.id,
    n.full_name,
    n.simple_name,
    s.name            AS status_name,
    r.name            AS rank_name,
    r.visible_in_name AS rank_visible_in_name,
    r.sort_order      AS rank_sort_order,
    t.name            AS type_name,
    t.scientific      AS type_scientific,
    t.cultivar        AS type_cultivar,
    i.id              AS instance_id,
    ref.year          AS reference_year,
    ref.id            AS reference_id,
    ref.citation_html AS reference_citation_html,
    ity.name          AS instance_type_name,
    ity.id            AS instance_type_id,
    ity.primary_instance,
    ity.standalone    AS instance_standalone,
    sty.standalone    AS synonym_standalone,
    sty.name          AS synonym_type_name,
    i.page,
    i.page_qualifier,
    i.cited_by_id,
    i.cites_id,
    CASE ity.primary_instance
    WHEN TRUE
      THEN 'A' :: TEXT
    ELSE 'B' :: TEXT
    END               AS primary_instance_first,
    sname.full_name   AS synonym_full_name,
    author.name       AS author_name,
    n.id              AS name_id,
    n.sort_name,
    ((((ref.citation_html) :: TEXT || ': ' :: TEXT) || (COALESCE(i.page, '' :: CHARACTER VARYING)) :: TEXT) ||
     CASE ity.primary_instance
     WHEN TRUE
       THEN ((' [' :: TEXT || (ity.name) :: TEXT) || ']' :: TEXT)
     ELSE '' :: TEXT
     END)             AS entry
  FROM ((((((((((NAME n
                      JOIN name_status s ON ((n.name_status_id = s.id)))
                 JOIN name_rank r ON ((n.name_rank_id = r.id)))
                JOIN name_type t ON ((n.name_type_id = t.id)))
               JOIN instance i ON ((n.id = i.name_id)))
              JOIN instance_type ity ON ((i.instance_type_id = ity.id)))
             JOIN reference REF ON ((i.reference_id = REF.id)))
            LEFT JOIN author ON ((REF.author_id = author.id)))
           LEFT JOIN instance syn ON ((syn.cited_by_id = i.id)))
          LEFT JOIN instance_type sty ON ((syn.instance_type_id = sty.id)))
    LEFT JOIN name sname ON ((syn.name_id = sname.id)))
  WHERE (n.duplicate_of_id IS NULL);

DROP VIEW IF EXISTS public.name_or_synonym_vw;
CREATE VIEW public.name_or_synonym_vw AS
  SELECT
    0                       AS id,
    '' :: CHARACTER VARYING AS simple_name,
    '' :: CHARACTER VARYING AS full_name,
    '' :: CHARACTER VARYING AS type_code,
    0                       AS instance_id,
    0                       AS tree_node_id,
    0                       AS accepted_id,
    '' :: CHARACTER VARYING AS accepted_full_name,
    0                       AS name_status_id,
    0                       AS reference_id,
    0                       AS name_rank_id,
    '' :: CHARACTER VARYING AS sort_name
  FROM name
  WHERE (1 = 0);
