#!/usr/bin/env perl

=pod

=head1 Using the script for convert URL list for Squid ACL whitelist
#===============================================================================
#
#         FILE: convert_url.pl
#
#        USAGE: ./convert_url.pl  
#
#  DESCRIPTION: Convert URL list for Squid ACL whitelist 
#
#      OPTIONS: ---
# REQUIREMENTS: Perl v5.14+.
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Vladislav Sapunov. 
# ORGANIZATION: 
#      VERSION: 1.0.0
#      CREATED: 05.12.2024 22:48:36
#     REVISION: ---
#  INFORMATION: Instead of this script, you can use a Perl one-liner:
#                $ cat ~/in_url >> ~/in_url_archive && cat ~/in_url | \
#                	perl -nE "s/\./\\\./g; print;" | \
#					perl -nE "s/https\:\/\/www\\\./(\^\|\\.\)/g; print;" | \
#					perl -nE "s/https\:\/\//\(\^\|\\.\)/g; print;" | \
#					perl -nE "s/http\:\/\/www\\./\(\^\|\\.\)/g; print;" | \
#                   perl -nE "s/http\:\/\//\(\^\|\\.\)/g; print;" | \
#                   perl -nE "s/\/.*//g; print;" | \
#                   perl -nE "s/^\s*$//g; print;" >> \
#                  	/etc/squid/acllist/url_allow_whitelist.lst
#                $ squid -k check
#				 $ service squid reload
#                $ cp url_allow_whitelist.lst url_allow_whitelist_<date>.lst
#
#===============================================================================
=cut

use strict;
use warnings;
use v5.14;
use utf8;

# Input files
my $inUrl        = 'in_url';
my $inUrlArchive = 'in_url_archive';

# Result outFile for ACL whitelist
my $outFile = 'url_allow_whitelist.lst';

sub copy_in_url_to_archive() {

    # Open source inFile for reading
    open( FHR, '<', $inUrl ) or die "Couldn't Open file $inUrl" . "$!\n";

    # Open inUrlArchive for writing
    open( FHW, '>>', $inUrlArchive )
      or die "Couldn't Open file $outFile" . "$!\n";

    while ( my $str = <FHR> ) {
        $str =~ s/^\s+//;
        if ( $str =~ m/^[A-Za-z0-9]/ ) {
            chomp($str);
            say FHW $str;
        }
    }

    # Close the filehandles
    close(FHR) or die "$!\n";
    close(FHW) or die "$!\n";
}

sub convert_url() {

    # Open source inFile for reading
    open( FHR, '<', $inUrl ) or die "Couldn't Open file $inUrl" . "$!\n";

    # Open result outFile for writing
    open( FHW, '>>', $outFile ) or die "Couldn't Open file $outFile" . "$!\n";

    my @urlList = <FHR>;
    foreach my $url (@urlList) {
        chomp($url);
        $url =~ s/\./\\\./;
        $url =~ s/https\:\/\/www\\\./(\^\|\\.\)/;
        $url =~ s/https\:\/\//\(\^\|\\.\)/;
        $url =~ s/http\:\/\/www\\./\(\^\|\\.\)/;
        $url =~ s/http\:\/\//\(\^\|\\.\)/;
        $url =~ s/\/.*//;
        $url =~ s/^\s*$//;

        if ( $url =~ m/^\(\^\|\\\.\)/ ) {
            say FHW $url;
        }
    }

    # Close the filehandles
    close(FHR) or die "$!\n";
    close(FHW) or die "$!\n";
}

sub squid_reload() {
    system("squid -k check")       or die "$!\n";
    system("service squid reload") or die "$!\n";
}

&copy_in_url_to_archive and say "Copy to file in_url_to_archive successfully";
&convert_url            and say "URL conversion completed successfully";
&squid_reload and say "Squid reloaded successfully";

