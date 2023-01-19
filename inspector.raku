#!/usr/bin/env raku

use v6;
use Archive::Libarchive;
use Archive::Libarchive::Constants;
use Identity::Utils;

# What does this script do?
# This script recursively searches for tarball files in Raku's REA repository
# to find the newest tarball for each distribution. Next, the newest tarball for each
# distribution is searched for any outdated file extensions, namely:
# .t, .pm, .pm6

# How to run this script?
# Clone https://github.com/Raku/REA repository
# Add this script to the top of the repo and execute it


my $dir = 'archive';
my @dirs = $dir.IO;
my %tarballs;
my $count;
my @leg_ext = qw ( t pm p6 pod6 pod pm6 );
while @dirs {
    my $d = @dirs.pop;
    for dir($d, test => { "$d/$_".IO.d && $_ ~~ $*SPEC.curupdir }) -> $path {
        my $newest = 0.Version;
        my $newest_file = '';

        # find the newest tarball file
        for dir($path, test => { "$path/$_".IO.f } ) -> $file {
            next if !ver($file.Str);
            CONTROL {
                when CX::Warn { say $path; say $file; .resume };
            }
            if ver($file.Str).Version > $newest {
                $newest = ver($file.Str).Version;
                $newest_file = $file;
            }
        }

        # search the tarball file's entries for old file extensions
        if $newest_file {
            # id any tarballs that can't be proceseed for whatever reason
            CONTROL {
                when CX::Warn { say $newest_file; .resume };
            }
            my Archive::Libarchive $a .= new: operation => LibarchiveRead, file => $newest_file.Str;
            my Archive::Libarchive::Entry $entry .= new;

            while $a.next-header($entry) {
                $a.data-skip;
                my $path = $entry.pathname;
                next if is-dir($entry.filetype);
                for @leg_ext -> $ext {
                    if %tarballs{$newest_file}{$ext}:!exists && $path ~~ / \.$ext $ / {
                        %tarballs{$newest_file}{$ext} = 1;
                    }
                }
            }
            $a.close;
        }
        @dirs.push: $path;
    }
}

my %ext;
for %tarballs.keys.sort -> $k {
    say $k;
    for @leg_ext -> $ext {
        %ext{$ext}++ if %tarballs{$k}{$ext};
    }
}
say "total: " ~ %tarballs.keys.elems;
for @leg_ext -> $ext {
    say "$ext: " ~ %ext{$ext};
}
