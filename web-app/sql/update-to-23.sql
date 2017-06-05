-- NSL-2280 Add unsourced instance types
INSERT INTO public.instance_type (id, lock_version, citing, deprecated, doubtful, misapplied, name, nomenclatural, primary_instance, pro_parte, protologue, relationship, secondary_instance, sort_order, standalone, synonym, taxonomic, unsourced, description_html, rdf_id, has_label, of_label, bidirectional) VALUES (nextval('nsl_global_seq'), 0, true, false, false, true, 'unsourced misapplied', false, false, false, false, true, false, 400, false, false, false, true, '(description of <b>unsourced misapplied</b>)', 'unsourced-misapplied', 'misapplication', 'misapplied to', false);
INSERT INTO public.instance_type (id, lock_version, citing, deprecated, doubtful, misapplied, name, nomenclatural, primary_instance, pro_parte, protologue, relationship, secondary_instance, sort_order, standalone, synonym, taxonomic, unsourced, description_html, rdf_id, has_label, of_label, bidirectional) VALUES (nextval('nsl_global_seq'), 0, true, false, false, true, 'unsourced pro parte misapplied', false, false, true, false, true, false, 70, false, false, false, true, '(description of <b>unsourced pro parte misapplied</b>)', 'unsourced-pro-parte-misapplied', 'pro parte misapplication', 'pro parte misapplied to', false);
INSERT INTO public.instance_type (id, lock_version, citing, deprecated, doubtful, misapplied, name, nomenclatural, primary_instance, pro_parte, protologue, relationship, secondary_instance, sort_order, standalone, synonym, taxonomic, unsourced, description_html, rdf_id, has_label, of_label, bidirectional) VALUES (nextval('nsl_global_seq'), 0, true, false, true, true, 'unsourced doubtful misapplied', false, false, false, false, true, false, 80, false, false, false, true, '(description of <b>unsourced doubtful misapplied</b>)', 'unsourced-doubtful-misapplied', 'doubtful misapplication', 'doubtful misapplied to', false);
INSERT INTO public.instance_type (id, lock_version, citing, deprecated, doubtful, misapplied, name, nomenclatural, primary_instance, pro_parte, protologue, relationship, secondary_instance, sort_order, standalone, synonym, taxonomic, unsourced, description_html, rdf_id, has_label, of_label, bidirectional) VALUES (nextval('nsl_global_seq'), 0, true, false, true, true, 'unsourced doubtful pro parte misapplied', false, false, false, false, true, false, 90, false, false, false, true, '(description of <b>unsourced doubtful pro parte misapplied</b>)', 'unsourced-doubtful-pro-parte-misapplied', 'doubtful pro parte misapplication', 'doubtful pro parte misapplied to', false);

-- NSL-2228 add vernacular name
update name_type set sort_order = sort_order + 1 where sort_order > 15;

--NSL-2341 add use verbatim rank to name ranks so they can be specified in name construction
alter table name_rank add COLUMN use_verbatim_rank boolean default false not null;

-- version
UPDATE db_version
SET version = 23
WHERE id = 1;

