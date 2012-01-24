# SPLURGE: Scholars Portal Library Usage-based Recommendation Engine

Amazon.ca has a "customers who bought this item also bought" feature that recommends things to you that you might be interested in.  LibraryThing has it too: the recommendations for [What's Bred in the Bone](https://www.librarything.com/work/4872560) by Robertson Davies include books by Margaret Laurence, Carol Shields, Michael Ondaatje, Peter Ackroyd, John Fowles, and David Lodge, as well as other Davies works.

Library catalogues don't have any such feature, but they should. And libraries are sitting on the circulation and usage data that makes it possible.  ([BiblioCommons](http://www.bibliocommons.com/) does have a Similar Titles feature, but it's a closed commercial product aimed at public libraries, and anyway the titles are added by hand.)

SPLURGE will collect usage data from OCUL members and build a recommendation engine that can be integrated into any member's catalogue.  The code will be made available under the GNU Public License and the data will be made available under an open data license.

## Hackfest on Friday 17 February 2012 at Ryerson University

There will be a one-day SPLURGE hackfest on Friday 17 February 2012 on the seventh floor of Heaslip House at Ryerson University in Toronto.  It is open to anyone in an [OCUL](http://www.ocul.on.ca/) library.  No breakfast or lunch will be provided, but there are many coffee shops, restaurants and pubs nearby. The night before the hackfest there will be a dinner in Toronto for everyone in town.

__Everyone coming to the hackfest should bring at least six months of usage data from their library.__ See Data Collection below for more details.

Guest wifi accounts will be available, but if your university is part of the [eduroam](http://www.canarie.ca/en/caf/members) network then you can use it.  Please make any necessary arrangements in advance.

For details, please contact the organizers, [William Denton](http://www.miskatonic.org/) (<wdenton@yorku.ca> and [@wdenton](http://twitter.com/wdenton)) (Web Librarian, York University) and Cameron Metcalf (<cmetcalf@uottawa.ca> and [@podeas](http://twitter.com/podeas)) (Head, Library Systems Division, University of Ottawa).

## Background

We plan to implement in Ontario something close to the [JISC](http://www.jisc.ac.uk/) project called [MOSAIC (Making Our Shared Activity Information Count)](http://sero.co.uk/jisc-mosaic-documents.html). The documents there describe what they did, and our plan is based on that.

* [MOSAIC Data Collection: A Guide](http://sero.co.uk/assets/090514%20MOSAIC%20data%20collection%20-%20A%20guide%20v01.pdf)
* [MOSAIC Final Report](http://sero.co.uk/mosaic/100322_MOSAIC_Final_Report_v7_FINAL.pdf) (and [Appendices](http://sero.co.uk/mosaic/100212%20MOSAIC%20Final%20Report%20Appendices%20FINAL.pdf))
* Also [MOSAIC Demonstration Links](http://sero.co.uk/mosaic/091012-MOSAIC-Demonstration-Links.doc), from a software contest they ran to find new, interesting uses for their data. The examples here go beyond 
the Recommendation Engine idea, but are worth looking at to see other 
possible future directions.)

The [JISC MOSAIC wiki](http://library.hud.ac.uk/wikis/mosaic/index.php/Main_Page) has code and data examples.

The JISC project grew out of work done by Dave Pattern (Library Systems Manager) and others at the University of Huddersfield. They made usage data available under an Open Data Commons License.

* [Data](http://library.hud.ac.uk/data/usagedata/)
* [README](http://library.hud.ac.uk/data/usagedata/_readme.html)
* Pattern explains things in [Free book usage data from the University of Huddersfield](http://www.daveyp.com/blog/archives/528)

In March 2011 Dave Pattern's summarized it all in [Sliding Down the Long Tail](http://www.daveyp.com/blog/archives/1453).

# Data gathering

Scholars Portal will aggregate the data from the different libraries, and make the (anonymous) results openly available.

## Data levels

MOSAIC set out three levels of usage data in the [Final Report](http://sero.co.uk/mosaic/100322_MOSAIC_Final_Report_v7_FINAL.pdf) (p 40):

> We refer to library circulation (loan & renewal) information as use data. Use 
> data contains one use record per item borrowed. Sets of use records may 
> have different amounts of information in each record, according to the 
> data level that applies to all the records in the set.

<table>
<thead>
<tr>
<th>Level</th>
<th>Description</th>
<th>Use</th>
</tr>
</thead>
<tbody>
<tr>
<td>Level 0</td>
<td>Level 0 use records contain where and when the loan was made and the item borrowed.</td>
<td>Level 0 use data can be used to indicate popular loan items in the participating library.</td>
</tr>
<tr>
<td>Level 1</td>
<td>Level 1 records are as for level 0, but also with borrower context information, indicating borrower type (staff or student), and course and progression level (for students).</td>
<td>Level 1 use data can be used to see, via facets, for a given search, what was borrowed in one or more of: a particular institution, a particular course, a particular progression level (or by staff), and in a particular academic year.</td>
</tr>
<tr>
<td>Level 2</td>
<td>Level 2 records are as for level 0, but also with an anonymised user ID</td>
<td>Level 2 use data enables recommendations like "borrowers of this item also borrowed," and "borrowers of this item previously borrowed/went on to borrow."</td>
</tr>
</tbody>
</table>

We would collect use data at Level 0.

## Data collection

To build SPLURGE, and to work on it at the hackfest, we need some good sample data. __Everyone coming should bring at least six months of usage data from their library.__  We can store the data on Scholars Portal servers (location to be determined).

We need to make it as easy as possible for people to pull the data from their systems. Because there are several different ILSes used across the province, the necessary database or report commands will vary, but once done for one ILS they can be shared with other users of the same system. MOSAIC's [existing code for SirsiDynix Horizon](http://library.hud.ac.uk/wikis/mosaic/index.php/Code_for_SirsiDynix_Horizon) may be useful.  Any code written can be added to this repository.

We will use two of the data files described in the [MOSAIC data file formats](http://library.hud.ac.uk/data/MOSAIC/scripts/_readme.html):

* `items.txt`
* `transaction.YYYY.txt`

Because we are working at Level 0 and not connecting users and courses, we don't need `users.YYYY.txt` or `courses.txt`.

### items.txt

Fields:

    item ID    (mandatory)
    ISBN(s)    (mandatory)
    title      (mandatory)
    author(s)
    publisher
    publication year
    persistent URL

Sample:

    123 → 0415972531 → Music & copyright → L. Marshall → Wiley   → 2004 → http://libcat.hud.ac.uk/123
    234 → 0415969298 → Songwriting tips  → N. Skilbeck → Phaidon → 1997 → http://libcat.hud.ac.uk/234

* The item ID is whatever ID you want to use to identify a library book. It must match the item ID contained in the item file.
* The ISBN(s) are one (or more) ISBNs, separated by a | pipe character where more than one ISBN is linked to the item (e.g. 0415966744|0415966752).
* The title is the title of the book.
* The author(s) are one (or more) names, separated by a | pipe character where more than one name is present (e.g. John Smith|Julie Johnson).
* The publisher and publication year are the name of the publishing company and the year of publication.
* The persistent URL is the web address the item can be found at (e.g. on your library catalogue). 

### transactions.YYYY.txt

Fields:

    timestamp (mandatory)
    item ID   (mandatory)
    user ID   (mandatory)

Sample:

    1222646400  →  114784  →  67890
    1225756800  →  103828  →  67890
    1225756800  →  62580   →  76543

* The timestamp is in Unix time format (i.e. the number of seconds since 1st Jan 1970 UTC). It is used to calculate the day the transaction occurred on.
* The user ID is whatever ID you want to use to identify an individual library user. It will be converted to a MD5 hash value before the data is submitted to MOSAIC. It must match the user ID contained in the user file.
* The item ID is whatever ID you want to use to identify a library book. It must match the item ID contained in the item file. 

# Data storage

The data will be stored as XML using the same format as Huddersfield used in their data release (see the [usage data README](http://library.hud.ac.uk/data/usagedata/_readme.html)):

* `circulation_data.xml` contains aggregate usage information for individual titles
* `suggestion_data.xml` contains people who borrowed X also borrowed Y relations

[data2xml.pl](data2xml.pl) (as taken from MOSAIC's code) will convert the library-generated data into richer XML that we will use for the work, as describe in the [usage data README](http://library.hud.ac.uk/data/usagedata/_readme.html) from their [script repository](http://library.hud.ac.uk/data/usagedata/)).

# Building SPLURGE

The purpose of the hackfest is to build the code to make the Recommendation Wngine work. When the Recommendation Engine is given an ISBN or other ID number it will suggest a list of related items.

Pattern's [Sliding Down the Long Tail](http://www.daveyp.com/blog/archives/1453) describes the logic we'll need to follow.

Tim Spalding implemented a similar feature at [LibraryThing](http://librarything.com/). When asked on Twitter how it worked, he said [The best code is just statistics](https://mobile.twitter.com/librarythingtim/status/126478695828434944) and [Given random distribution how many of book X would you expect? How many did you find?](https://mobile.twitter.com/librarythingtim/status/126480811817046016).

In conversation, both Pattern and Spalding mentioned the _Harry Potter effect_: some books are so popular with everyone that they need to be damped down.  Everyone reading Freud or Ferlinghetti, Feynman or Foucault, is probably also reading J.K. Rowling, but that doesn't mean _Harry Potter and the Goblet of Fire_ should be recommended to people looking at _Totem and Taboo_ or _Madness and Civilization_.

## Implementation as a web service

The Recommendation Engine will have web-based API available at Scholars Portal. Ideally a library will be able to insert one line of Javascript into its HTML template to make the recommendations appear.

# Systems and tools that might be useful

* [Apache Mahout](https://mahout.apache.org/)
* [Melvyl Recommender Project](http://www.cdlib.org/services/publishing/tools/xtf/melvyl_recommender/index.html) at California Digital Library

# Possible future directions

Moving data collection to Level 1 and involving course information.

# Open data and anonymity

All of the anonymized data will be made freely available under an open license. 

No identifying information will be connected to the usage data. It will be completely anonymous.


