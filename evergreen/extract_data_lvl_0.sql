-- Rough approach
--   Uses the normalized / mangled titles/authors/publishers
--   aou.parent_ou: 105 = LUSYS, 106 = WINDSYS
--   Persistent URL is lame but better than pointing at the JSPAC;
--   - need to find out what this is actually used for

COPY (SELECT acp.id, array_to_string(rsr.isbn, '|') AS isbns, rsr.title, rsr.author, rsr.publisher, rsr.pubdate, 'http://laurentian.concat.ca/opac/extras/supercat/retrieve/marcxml-full/record/' || rsr.id AS "Persistent URL"
    FROM asset.copy acp
        INNER JOIN asset.call_number acn ON acn.id = acp.call_number
        INNER JOIN reporter.materialized_simple_record rsr ON rsr.id = acn.record
        INNER JOIN action.circulation acirc ON acirc.target_copy = acp.id
        INNER JOIN actor.org_unit aou ON aou.id = acirc.circ_lib
    WHERE acirc.xact_start < NOW() - '1 year'::interval
        AND aou.parent_ou IN (105, 106)
) TO '/tmp/items_conifer.txt' NULL '';

-- Gets the raw transaction data
-- "Randomizes" the user ID with MD5 hex digest
COPY (SELECT EXTRACT(epoch FROM acirc.xact_start) AS "timestamp", acp.id AS "Item ID", md5(md5(extract(epoch FROM NOW())::text) || au.id::text) AS "User ID"
    FROM action.circulation acirc
        INNER JOIN asset.copy acp ON acp.id = acirc.target_copy
        INNER JOIN actor.usr au ON au.id = acirc.usr
        INNER JOIN actor.org_unit aou ON aou.id = acirc.circ_lib
    WHERE acirc.xact_start < NOW() - '1 year'::interval
        AND aou.parent_ou IN (105, 106)
        ORDER BY 1 DESC
        LIMIT 10
) TO '/tmp/transactions_conifer.txt' NULL '';
