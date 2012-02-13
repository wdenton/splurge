-- Rough approach
--   Uses the normalized / mangled titles/authors/publishers
--   aou.parent_ou: 105 = LUSYS, 106 = WINDSYS
--   Persistent URL is lame but better than pointing at the JSPAC;
--   - need to find out what this is actually used for
COPY (SELECT DISTINCT acp.id, array_to_string(rsr.isbn, '|') AS isbns, rsr.title,
    rsr.author, rsr.publisher, rsr.pubdate,
    'http://laurentian.concat.ca/opac/extras/supercat/retrieve/marcxml-full/record/' || rsr.id AS "Persistent URL"
    FROM asset.copy acp
        INNER JOIN asset.call_number acn ON acn.id = acp.call_number
        INNER JOIN reporter.materialized_simple_record rsr ON rsr.id = acn.record
        INNER JOIN action.circulation acirc ON acirc.target_copy = acp.id
        INNER JOIN actor.org_unit aou ON aou.id = acirc.circ_lib
    WHERE acirc.xact_start > NOW() - '1 year'::interval
        AND aou.parent_ou IN (105, 106)
        AND array_to_string(rsr.isbn, '') != ''
) TO '/tmp/conifer.items.txt' NULL '';

-- Create a table of randomized values for user IDs
DROP TABLE IF EXISTS scratchpad.random_user_id;
CREATE TABLE scratchpad.random_user_id (id BIGINT, rand_id TEXT);
INSERT INTO scratchpad.random_user_id (id, rand_id) SELECT au.id, md5(random()::text || md5(random()::text)) FROM actor.usr au;
CREATE INDEX CONCURRENTLY ON scratchpad.random_user_id(id);

-- Gets the raw transaction data with randomized user IDs
COPY (SELECT DISTINCT EXTRACT(epoch FROM acirc.xact_start) AS "timestamp", acp.id AS "Item ID", scruid.rand_id AS "User ID"
    FROM action.circulation acirc
        INNER JOIN asset.copy acp ON acp.id = acirc.target_copy
        INNER JOIN asset.call_number acn ON acn.id = acp.call_number
        INNER JOIN reporter.materialized_simple_record rsr ON rsr.id = acn.record
        INNER JOIN actor.org_unit aou ON aou.id = acirc.circ_lib
        INNER JOIN scratchpad.random_user_id scruid ON scruid.id = acirc.usr
    WHERE acirc.xact_start > NOW() - '1 year'::interval
        AND aou.parent_ou IN (105, 106)
        AND array_to_string(rsr.isbn, '') != ''
        ORDER BY 1 DESC
) TO '/tmp/conifer.transactions.txt' NULL '';
