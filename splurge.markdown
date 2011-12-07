# SPLURGE: Scholars Portal Library Usage-based Recommendation Engine

## Goal

Collect usage data from OCUL members and build a recommendation engine that can be integrated into any members catalogue. Make the anonymized data available under an open license so members and others can better assess and understand collection usage in Ontario, and make the software available under the GNU Public License so anyone can use it.

## Hackfest

There will be a one-day SPLURGE hackfest on Friday 17 February 2012 on the seventh floor of Heaslip House at Ryerson University.  It is open to 

For details, please contact the organizers, William Denton <wdenton@yorku.ca> (Web Librarian, York University) and Cameron Metcalf <cmetcalf@uottawa.ca> (Head, Library Systems Division, University of Ottawa).

## Background

This project is based on a [JISC](http://www.jisc.ac.uk/) project called [MOSAIC (Making Our Shared Activity Information Count)](http://sero.co.uk/jisc-mosaic-documents.html). The documents there describe what they did, and our plan is based on that:

* [MOSAIC Data Collection: A Guide](http://sero.co.uk/assets/090514%20MOSAIC%20data%20collection%20-%20A%20guide%20v01.pdf)
* [MOSAIC Final Report](http://sero.co.uk/mosaic/100322_MOSAIC_Final_Report_v7_FINAL.pdf) (and [Appendices](http://sero.co.uk/mosaic/100212%20MOSAIC%20Final%20Report%20Appendices%20FINAL.pdf))
* Also [MOSAIC Demonstration Links](http://sero.co.uk/mosaic/091012-MOSAIC-Demonstration-Links.doc), from a software contest they ran to find new, interesting uses for their data. The examples here go beyond 
the Recommendation Engine idea, but are worth looking at to see other 
possible future directions.)

The JISC project grew out of work done by Dave Pattern (Library Systems Manager) and others at the University of Huddersfield. They made usage data available under an Open Data Commons License.

* [Data](http://library.hud.ac.uk/data/usagedata/)
* [README](http://library.hud.ac.uk/data/usagedata/_readme.html)
* Pattern explains things in [Free book usage data from the University of Huddersfield](http://www.daveyp.com/blog/archives/528)

# Data gathering

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
<td>Level 2 use data enables recommendations like borrowers of this item also borrowed, and borrowers of this item previously borrowed/went on to borrow.</td>
</tr>
</tbody>
</table>

We would collect use data at Level 0.

## Data extraction

Scholars Portal will give template XML files, with instructions, to member libraries, who will pull the necessary data from their systems. Because there are several different ILSes involved, the necessary database or report commands will vary, but once done for one ILS they can be shared with other users of the same system.

!!! TODO Expand with actual examples

## Data formats

Following the MOSAIC lead (as described in the [README](http://library.hud.ac.uk/data/usagedata/_readme.html) from their [script repository](http://library.hud.ac.uk/data/usagedata/)), we will collect item file and yearly transaction files from libraries.

All files are stored with tab-separated values.

### Item file: items.txt

FIELDS:

* item ID
* ISBN(s)
* title
* author(s)
* publisher
* publication year
* persistent URL

SAMPLE:

    123  0415972531  Music & copyright  L. Marshall  Wiley    2004 http://libcat.hud.ac.uk/123
    234  0415969298  Songwriting tips   N. Skilbeck  Phaidon  1997 http://libcat.hud.ac.uk/234

* The item ID is whatever ID you want to use to identify a library book. It must match the item ID contained in the item file.
* The ISBN(s) are one (or more) ISBNs, separated by a | pipe character where more than one ISBN is linked to the item (e.g. 0415966744|0415966752).
* The title is the title of the book.
* The author(s) are one (or more) names, separated by a | pipe character where more than one name is present (e.g. John Smith|Julie Johnson).
* The publisher and publication year are the name of the publishing company and the year of publication.
* The persistent URL is the web address the item can be found at (e.g. on your library catalogue).

### Transaction files: transaction.YYYY.txt

FIELDS:

* timestamp
* item ID
* user ID

SAMPLE:

     1222646400    114784    67890
     1225756800    103828    67890
     1225756800    62580     76543

* The timestamp is in Unix time format (i.e. the number of seconds since 1st Jan 1970 UTC). It is used to calculate the day the transaction occurred on.
* The user ID is whatever ID you want to use to identify an individual library user. It will be converted to a MD5 hash value before the data is submitted to MOSAIC. It must match the user ID contained in the user file.
* The item ID is whatever ID you want to use to identify a library book. It must match the item ID contained in the item file.

The basic usage data to be gathered is:

* Item title
* ISBN
* Number of copies
* URL of item in catalogue
* Loan history, giving number of initial circulations per year over the last 10 years (or fewer, if 10 years of data is not available)

The basic also-borrowed data to be gathered for each item (A) is a list of other items (B) that shows:

* how many times A was borrowed before B
* how many times A and B were borrowed together
* how many times A was borrowed after B
* how many times B was borrowed in total

Scholars Portal will aggregate the data from the different libraries, and make the data openly available.

# Privacy

No identifying information will be connected to the usage data. It is completely anonymous.

# Data storage

The data will be stored using the same format as Huddersfield used in their data release (see [http://library.hud.ac.uk/data/usagedata/_readme.html](http://library.hud.ac.uk/data/usagedata/_readme.html)):

* circulation\_data.xml contains aggregate usage information for individual titles
* suggestion\_data.xml contains people who borrowed X also borrowed Y relations
* schools.xml is a lookup file listing OCUL members and ID numbers
* courses.xml is a lookup file listing course codes and ID numbers

!!!! TODO Expand

# Recommendation Engine

!!! TODO Write up what is known about how this can work, from MOSAIC and what Tim Spalding said

When the Recommendation Engine is given an ISBN or other ID number it will suggest a list of related items, using an algorithm based on the also-borrowed data and the usage data.

[suggest algorithm? Also use LibraryThing data? We can get it from Tim Spalding.]

# Implementation as a web service

The Recommendation Engine will have web-based API available at Scholars Portal. Ideally a library will be able to insert one line of Javascript into its HTML template to make the recommendations appear.

