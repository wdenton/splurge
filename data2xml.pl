#!/usr/bin/perl -w


#######################################
###                                 ###
###       JISC MOSAIC PROJECT       ###
###                                 ###
#######################################
###                                 ###
###  Convert book transaction data  ###
###   into suitable XML structure   ###
###                                 ###
###       v0.9.1 - 12/Jun/2009      ###
###                                 ###
###   This code is CCO licenced!    ###
###                                 ###
#######################################



    use strict;
    use HTML::Entities qw( encode_entities_numeric );
    use Digest::MD5 qw( md5_hex );



########################
###  MAIN VARIABLES  ###
########################

### RANDOM STRING, USED TO ENSURE USER ID [5.4] IS SUITABLY SCRAMBLED - CHANGE TO WHATEVER YOU WANT!

    my $salt = 'askljdlkasjd lksldk jasldkj aslkdj laskjd lasjd laskjd alsdg weudfgwe ufgerufgy pwe hiweurh wierh';



### NAME OF YOUR INSTITUION [6.2.2]...

    my $institution = "University of Huddersfield";



### ACADEMIC YEAR THAT THE RECORDS RELATE TO [6.2.2]...

    my $academicYear = $ARGV[0] || 2008;



### COURSE CODE TYPE [6.2.4] (ucas OR jacs)...

    my $courseCodeType = lc("ucas");



### DATA LEVEL (1 or 2)...

    my $level = $ARGV[1] || 2;



### RECORDS PER XML FILE (0 means unlimited)...

    my $recordsPerFile = $ARGV[2] || 0;



### DEBUG MESSAGES (1=ON, 0=OFF)...

    my $debug = 1;




#########################
###  OTHER VARIABLES  ###
#########################

    my %MD5hashes   = ( );     # TEMP HASH TO STORE USER MD5 HASHES
    my %courses     = ( );     # DETAILS OF COURSES
    my %users       = ( );     # DETAILS OF USERS
    my %items       = ( );     # DETAILS OF ITEMS
    my %exclude     = ( );     # USERS, ITEMS, COURSES, ETC TO EXCLUDE FROM THE XML OUTPUT
    my $now         = time;    # WHAT TIME IS IT NOW?
    my $recordCount = 0;       # RECORD COUNTER
    my $fileCount   = 1;       # FILE COUNTER

    my $nextYear = $academicYear + 1;   # FIX FOR v0.9.1


######################
###  READ IN DATA  ###
######################

    open( IN, "users.$academicYear.txt" ) || die "unable to open users.$academicYear.txt file";
    while( <IN> )
    {
        chomp;
        my( $id, $data ) = split( /\t/, $_, 2 );
        $users{$id} = $data;
    }
    close( IN );

    open( IN, "items.txt" ) || die "unable to open items.txt";
    while( <IN> )
    {
        chomp;
        my( $id, $data ) = split( /\t/, $_, 2 );
        $items{$id} = $data;
    }
    close( IN );

    open( IN, "courses.txt" ) || die "unable to open courses.txt";
    while( <IN> )
    {
        chomp;
        my( $id, $data ) = split( /\t/, $_, 2 );
        $courses{$id} = $data;
    }
    close( IN );

    open( IN, "exclude.$academicYear.txt" );
    while( <IN> )
    {
        chomp;
        my( $type, $data, undef ) = split( /\t/, $_, 3 );
        $exclude{"$type:$data"} = 1;
    }
    close( IN );



####################
###  DEBUG FILE  ###
####################

    if( $debug )
    {
	open( DEBUG, ">debug.$now.txt" );
    }



### OPEN XML FILE FOR OUTPUT...

    open(OUT,">mosaic.$academicYear.level$level.$now.".substr("0000000$fileCount",-7).".xml");
    print OUT startXML( );

    print qq(generating level $level data for year $academicYear...\n);


##############################
###  PROCESS TRANSACTIONS  ###
##############################

    open( IN, "transactions.$academicYear.txt" );
    while( <IN> )
    {
        chomp;
        my( $time, $item, $user ) = split( /\t/ );


### CHECK FOR USER/ITEM EXCLUSIONS...

        if( $exclude{"user:$user"} || $exclude{"item:$item"} )
        {
            debugMessage( "excluding transaction $time/$item/$user" );
            next;
        }


### DATE OF USE IS A REQUIRED FIELD FOR LEVEL 2 DATA...

        if( !$time && $level == 2 )
        {
            debugMessage( "no time given for transaction item: $item user: $user" );
            next;
        }


### RESOURCE DATA IS A REQUIRED FIELD [6.2.3]...

        unless( $items{$item} )
        {
            debugMessage( "no item data for $item" );
            next;
        }


### USER CONTEXT DATA IS A REQUIRED FIELD [6.2.4]...

        unless( $users{$user} )
        {
            debugMessage( "no user data for $user" );
            next;
        }



### PARSE ITEM AND USER DATA

        my( $isbn, $title, $author, $publisher, $pubyear, $url ) = split( /\t/, $items{$item} );
        my( $courseID, $progLevel ) = split( /\t/, $users{$user} );



### CHECK FOR COURSE EXCLUSIONS...

        if( $exclude{"course:$courseID"} )
        {
            debugMessage( "excluding transaction for course $courseID" );
            next;
        }


### CHECK FOR PROGRESSION LEVEL EXCLUSIONS...

        if( $exclude{"prog:$progLevel"} )
        {
            debugMessage( "excluding transaction for progression level $progLevel" );
            next;
        }


### CHECK FOR COURSE+PROGRESSION LEVEL EXCLUSIONS...

        if( $exclude{"coprog:$courseID|$progLevel"} )
        {
            debugMessage( "excluding transaction for course/progression level $courseID/$progLevel" );
            next;
        }


### ISBN (Global ID) IS A REQUIRED FIELD [6.2.3]...

        unless( $isbn )
        {
            debugMessage( "no ISBN data for item $item" );
            next;
        }


### TITLE IS A REQUIRED FIELD [6.2.3]...

        unless( $title )
        {
            debugMessage( "no title data for item $item" );
            next;
        }


### PROG LEVEL IS A REQUIRED FIELD [6.2.4]...

        unless( $progLevel )
        {
            debugMessage( "no $progLevel data for user $user" );
            next;
        }



        my $courseTitle = '';
        my $courseCodes = '';

        if( defined( $courses{$courseID} ) )
        {
            ( $courseTitle, $courseCodes ) = split( /\t/, $courses{$courseID} );
        }


### [6.2.1] - START A NEW useRecord...

        print OUT qq(<useRecord>\n);


### [6.2.2] - INSTUTION DATA, ETC...

        print OUT qq(<from>\n);
        print OUT xml( 'institution', $institution );
        print OUT xml( 'academicYear', "$academicYear/$nextYear" );

        {
            my( $sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst ) = localtime( $now );
            $year += 1900;
            $mon++;

            print OUT qq(<extractedOn>\n);
            print OUT xml( 'year', $year );
            print OUT xml( 'month', $mon );
            print OUT xml( 'day', $mday );
            print OUT qq(</extractedOn>\n);
        }

        print OUT xml( 'source', 'LMS' );
        print OUT qq(</from>\n);


### [6.2.3] - RESOURCE DATA...

        print OUT qq(<resource>\n);
        print OUT xml( 'media', 'book' );

        my @isbns = split(/\|/, $isbn);
        if( scalar(@isbns) > 1 )
        {
            print OUT qq(<globalIDCollection>\n);
            foreach ( @isbns ) { print OUT xml( 'globalID', $_, qq(type="ISBN") ) }
            print OUT qq(</globalIDCollection>\n);

        }
        else { print OUT xml( 'globalID', $isbn, qq(type="ISBN") ) }


        if( $author )
        {
            my @authors = split(/\|/,$author);
            print OUT xml( 'author', $authors[0] );
        }
        else { print OUT qq(<author />\n) }


        print OUT xml( 'title', $title );

        print OUT xml( 'localID', $item );

        if( $url ) { print OUT xml( 'catalogueURL', $url ) }

        if( $publisher ) { print OUT xml( 'publisher', $publisher ) }

        if( $pubyear )   { print OUT xml( 'published', $pubyear ) }


        print OUT qq(</resource>\n);


### [6.2.4] - USER CONTEXT DATA...

        print OUT qq(<context>\n);


        if( $level == 2 )
        {
            print OUT xml( 'user', genHash($user) );

            my( $sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst ) = localtime( $time );
            $year += 1900;
            $mon++;

            print OUT qq(<useDate>\n);
            print OUT xml( 'year', $year );
            print OUT xml( 'month', $mon );
            print OUT xml( 'day', $mday );
            print OUT qq(</useDate>\n);
        }

        if( $courseCodes )
        {
            my @cc = split( /\|/, $courseCodes );

            if( scalar(@cc) > 1 )
            {
                print OUT qq(<courseCodeCollection>\n);

                foreach ( @cc )
                {
                    print OUT xml( 'courseCode', $_, qq(type="$courseCodeType") );
                }
                print OUT qq(</courseCodeCollection>\n);
            }
            else { print OUT xml( 'courseCode', $cc[0], qq(type="$courseCodeType") ) }

        }

        if( $courseTitle ) { print OUT xml( 'courseName', $courseTitle ) }

        if( $progLevel )   { print OUT xml( 'progression', $progLevel ) }


        print OUT qq(</context>\n);
        print OUT qq(</useRecord>\n);


        $recordCount++;
        if( $recordCount == $recordsPerFile )
        {
            print OUT endXML( );
            close( OUT );

            $recordCount = 0;
            $fileCount++;

            open(OUT,">mosaic.$academicYear.level$level.$now.".substr("0000000$fileCount",-7).".xml");
            print OUT startXML( );
        }

    }

    print OUT endXML( );
    close( OUT );



####################
###  DEBUG FILE  ###
####################

    if( $debug )
    {
	close( DEBUG );
    }






##########################
###  MISC SUBROUTINES  ###
##########################


### ENSURE XML CONTENT IS ENCODED CORRECTLY...

    sub encode
    {
        my $str = shift;
        $str = encode_entities_numeric( $str );
        $str =~ s/([\x7f-\x{ffffff}])/'&#'.ord($1).';'/ge;

        $str =~ s/\&\#x27\;/\'/g;
        $str =~ s/\&\#x22\;/\&quot\;/g;
        $str =~ s/\&\#x26\;/\&amp\;/g;

        return( $str );
    }



### CONVERT USER ID TO A HASH...

    sub genHash
    {
        my $str = shift;

        if( $MD5hashes{$str} ) { return( $MD5hashes{$str} ) }

        my $digest = md5_hex( md5_hex($str.$salt) );
        $MD5hashes{$str} = $digest;
        return($digest);
    }



### GENERATE SOME XML...

    sub xml
    {
        my $tag  = shift;
        my $data = shift;
        my $ex   = shift;

        my $ret  = '';

        if( $ex ) { $ret = qq(<$tag $ex>).encode($data).qq(</$tag>\n) }
        else      { $ret = qq(<$tag>).encode($data).qq(</$tag>\n) }

        return( $ret );
    }


### START XML OUTPUT...

    sub startXML
    {
        my $comment = "<!-- level $level data dump for $institution, started at ".localtime($now)." -->";
        return qq(<?xml version="1.0" encoding="UTF-8" ?>\n$comment\n<useRecordCollection>\n);
    }



### END XML OUTPUT...

    sub endXML
    {
        return qq(</useRecordCollection>);
    }



### DEBUG...

    sub debugMessage
    {
	my $message = shift;

	if( $debug )
	{
	    print DEBUG localtime(time)."\t$message\n";
	}
    }
1;