Evergreen Level 0 Data Extract
==============================

Horribly simple approach, good enough for demonstration purposes for getting
data to build a recommendation engine. Just plain old SQL to run against the
Evergreen database.

You will need to update:

1. Institution IDs from which you want to extract data (we're assuming
   a hierarchy where a parent institution contains the children from
   which you want data)
2. Output file names to something not so hardcoded.
