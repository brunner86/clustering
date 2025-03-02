#!/usr/bin/env perl
use strict;
use Data::Dumper;

my $fileName = "/home/joey/Dropbox/college/cse5243/featureVector.csv";
open( my $fh, '<', $fileName ) or die "Can't open $fileName: $!";

my %topicIdHash = ();

my $firstline = <$fh>;  # Skip the title line

while (my $line = <$fh>)
{
    my @lineStrings = split ',', $line;
    # skip entries without topic
    if (@lineStrings[1] eq "")
    {
        next;
    }
    else
    {
        my $currentId = @lineStrings[0];
        my @currentTopics = split /\|/, @lineStrings[1];
        $topicIdHash{$currentId} = @currentTopics[0];
    }
}

sub generateLev()
{
    my @sortedHashes;
    foreach my $id (sort {$a<=>$b} keys %topicIdHash)
    {
        my $rowString = $topicIdHash{$id};
        push (@sortedHashes, {$id => $rowString});
    }

    # Open the new levenshtein distance file
    open(my $fh, '>', "lev.txt") or die "Could not open file 'lev.txt' $!";
    my $i = 0;
    warn Dumper scalar localtime;
    foreach my $outterHash (@sortedHashes)
    {
        my $outterKey = (keys %$outterHash)[0];

        my $outterString = $outterHash->{$outterKey};
        print $fh "$outterKey,";

        foreach my $innerHash (@sortedHashes)
        {
            my $innerKey = (keys %$innerHash)[0];
            my $innerString = $innerHash->{$innerKey};
            my $levDistance = levenshtein($outterString, $innerString);
            print $fh "$levDistance,"
        }
        print $fh "\n";

        if ($i % 1000 == 0)
        {
            warn Dumper $outterKey;
            warn Dumper scalar localtime;
        }
        $i++;
    }
    warn Dumper scalar localtime;
    close $fh;
}

##############################################################################################################
# The following code comes from
# http://www.perlmonks.org/?node=Levenshtein%20distance%3A%20calculating%20similarity%20of%20strings


# Return the Levenshtein distance (also called Edit distance) 
# between two strings
#
# The Levenshtein distance (LD) is a measure of similarity between two
# strings, denoted here by s1 and s2. The distance is the number of
# deletions, insertions or substitutions required to transform s1 into
# s2. The greater the distance, the more different the strings are.
#
# The algorithm employs a promimity matrix, which denotes the 
# distances between substrings of the two given strings. Read the 
# embedded comments for more info. If you want a deep understanding 
# of the algorithm, printthe matrix for some test strings 
# and study it
#
# The beauty of this system is that nothing is magical - the distance
# is intuitively understandable by humans
#
# The distance is named after the Russian scientist Vladimir
# Levenshtein, who devised the algorithm in 1965
#
sub levenshtein
{
    # $s1 and $s2 are the two strings
    # $len1 and $len2 are their respective lengths
    #
    my ($s1, $s2) = @_;
    my ($len1, $len2) = (length $s1, length $s2);

    # If one of the strings is empty, the distance is the length
    # of the other string
    #
    return $len2 if ($len1 == 0);
    return $len1 if ($len2 == 0);

    my %mat;

    # Init the distance matrix
    #
    # The first row to 0..$len1
    # The first column to 0..$len2
    # The rest to 0
    #
    # The first row and column are initialized so to denote distance
    # from the empty string
    #
    for (my $i = 0; $i <= $len1; ++$i)
    {
        for (my $j = 0; $j <= $len2; ++$j)
        {
            $mat{$i}{$j} = 0;
            $mat{0}{$j} = $j;
        }

        $mat{$i}{0} = $i;
    }

    # Some char-by-char processing is ahead, so prepare
    # array of chars from the strings
    #
    my @ar1 = split(//, $s1);
    my @ar2 = split(//, $s2);

    for (my $i = 1; $i <= $len1; ++$i)
    {
        for (my $j = 1; $j <= $len2; ++$j)
        {
            # Set the cost to 1 iff the ith char of $s1
            # equals the jth of $s2
            # 
            # Denotes a substitution cost. When the char are equal
            # there is no need to substitute, so the cost is 0
            #
            my $cost = ($ar1[$i-1] eq $ar2[$j-1]) ? 0 : 1;

            # Cell $mat{$i}{$j} equals the minimum of:
            #
            # - The cell immediately above plus 1
            # - The cell immediately to the left plus 1
            # - The cell diagonally above and to the left + the cost
            #
            # We can either insert a new char, delete a char of
            # substitute an existing char (with an associated cost)
            #
            $mat{$i}{$j} = min([$mat{$i-1}{$j} + 1,
                                $mat{$i}{$j-1} + 1,
                                $mat{$i-1}{$j-1} + $cost]);
        }
    }

    # Finally, the distance equals the rightmost bottom cell
    # of the matrix
    #
    # Note that $mat{$x}{$y} denotes the distance between the 
    # substrings 1..$x and 1..$y
    #
    return $mat{$len1}{$len2};
}

# minimal element of a list
#
sub min
{
    my @list = @{$_[0]};
    my $min = $list[0];

    foreach my $i (@list)
    {
        $min = $i if ($i < $min);
    }

    return $min;
}
