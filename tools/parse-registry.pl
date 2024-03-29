#!/usr/bin/perl -w
use strict;

#
# USAGE
# 1. Download registries (in CSV format) from https://www.iana.org/assignments/media-types/media-types.xhtml
#    (only once, these files will be used later to update mime_enum):
#       * application
#       * audio
#       * font
#       * image
#       * message
#       * model
#       * multipart
#       * text
#       * video
#
# 2. Execute (only once):
# $ dos2unix data/*.csv
#
# 3. Execute (if parse-registry.pl was modified, but *.csv files are "original"):
# $ parse-registry.pl
#
# ATTENTION!
# DO NOT USE THIS SCRIPT AGAIN TO REGENERATE mime_enum WITH UPDATED DATA (new
#  *.csv downloaded from www.iana.org)
#

my @csv_sources = (
      'application.csv'
    , 'audio.csv'
    , 'font.csv'
    , 'image.csv'
    , 'message.csv'
    , 'model.csv'
    , 'multipart.csv'
    , 'text.csv'
    , 'video.csv'
);

# -- Constants --
my $base_indent = '    ';

sub print_fix_script_warn
{
    my $filename = shift or die;
    my $lineno = shift or die;
    my $msg = shift or die;

    if ($lineno > 0) {
        warn "ERROR: ${msg} at $filename:$lineno: FIX THIS SCRIPT\n";
    } else {
        warn "ERROR: ${msg}: FIX THIS SCRIPT\n";
    }
}

sub indent
{
    my $n = shift or die;
    my $r = '';

    for (1..$n) {
        $r .= $base_indent;
    }

    return $r;
}

# -- Patterns --
my $name_pattern      = '[\w\d\.\-\+]+';
my $template_pattern  = '[\w\d\-\+/\.]*'; # Can be empty
my $reference_pattern = '.+';

my %indices = (
      application => [10000, 10000]
    , audio       => [20000, 20000]
    , font        => [30000, 30000]
    , image       => [40000, 40000]
    , message     => [50000, 50000]
    , model       => [60000, 60000]
    , multipart   => [70000, 70000]
    , text        => [80000, 80000]
    , video       => [90000, 90000]
);

# Do not use external dependencies (e.g. use POSIX qw(strftime))
my @now = localtime;
my $current_year = 1900 + $now[5];
my $current_date = sprintf("%04d.%02d.%02d", $current_year, 1 + $now[4], $now[3]);

open MIME_ENUM_HPP, ">", '../include/pfs/mime_enum.hpp' or die $!;
open MIME_ENUM_CPP, ">", '../src/mime_enum.cpp' or die $!;

print MIME_ENUM_HPP<<"END_OF_PREAMBLE";
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) ${current_year} Vladislav Trifochkin
//
// AUTOMATICALLY GENERATED BY parse-registry.pl
//
// This file is part of `mime-lib`.
//
// Changelog:
//      ${current_date} Initially generated.
////////////////////////////////////////////////////////////////////////////////
#pragma once
#include <cstdint>
#include <string>

namespace mime {

// Media Types
// [Media Types](https://www.iana.org/assignments/media-types/media-types.xhtml)
enum class mime_enum: std::int32_t
{
      unknown = 0
END_OF_PREAMBLE

print MIME_ENUM_CPP<<"END_OF_PREAMBLE";
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) ${current_year} Vladislav Trifochkin
//
// AUTOMATICALLY GENERATED BY parse-registry.pl
//
// This file is part of `mime-lib`.
//
// Changelog:
//      ${current_date} Initially generated.
////////////////////////////////////////////////////////////////////////////////
#include "pfs/mime_enum.hpp"
#include <unordered_map>

// NOTES
// 1. https://en.wikipedia.org/wiki/ICO_(file_format)
//    While the IANA-registered MIME type for ICO files is image/vnd.microsoft.icon,
//    it was submitted to IANA in 2003 by a third party and is not recognised by
//    Microsoft software, which uses image/x-icon or image/ico instead.
//    Erroneous types image/ico, image/icon, text/ico and application/ico have
//    also been seen in use.

namespace mime {

struct mime_data
{
    std::string text;
};

static std::unordered_map<mime_enum, mime_data> const MIME_DATA = {
      { mime_enum::unknown, mime_data{""} }
END_OF_PREAMBLE

for(my $i = 0; $i <= $#csv_sources; $i++) {
    open FILE , "<", 'data/' . $csv_sources[$i] or die $!;

    my $default_registry = "";

    if ( $csv_sources[$i] =~ /(\w+)\.csv$/) {
        $default_registry = $1;
    } else {
        print_fix_script_warn($csv_sources[$i], -1
            , "Unsupported file name (registry): ".$csv_sources[$i]);
        exit 1;
    }

    if (! exists $indices{$default_registry}) {
        print_fix_script_warn($csv_sources[$i], -1
            , "Unsupported registry (based on file name): ".$csv_sources[$i]);
        exit 1;
    }

    my $lineno = 0;

    # Skip first line
    <FILE>;
    ++$lineno;

    # Add empty line separator
    print MIME_ENUM_HPP "\n";

    while (<FILE>) {
        chomp;
        ++$lineno;

        /^($name_pattern),(${template_pattern}),(${reference_pattern})$/ and do {
            my $registry  = "";
            my $name      = $1;
            my $template  = $2;
            my $text      = $template;
            my $reference = $3;

            $name =~ s/[\.\-\+]/_/g;
            $template =~ s/\//__/g;
            $template =~ s/[\-\+\.]/_/g;

            if ($template eq '') {
                $template = $default_registry . '__' . $name;
            }

            if ($text eq '') {
                $text = $default_registry . '/' . $name;
            }

            if ($template =~ /^(\w+)__/) {
                $registry = $1;
            } else {
                print_fix_script_warn($csv_sources[$i], $lineno, "Bad template: registry recognition failure");
                warn "$_\n";
                last;
            }

            if (! exists $indices{$registry}) {
                print_fix_script_warn($csv_sources[$i], $lineno, "Unsupported registry");
                warn "$_\n";
                last;
            }

            print MIME_ENUM_HPP
                  indent(1)
                , ', ' , $template, " = "
                , $indices{$registry}[1]++
                , "\n";

            print MIME_ENUM_CPP
                  indent(1)
                , ', { mime_enum::', $template, qq[, mime_data{"${text}"} }]
                , "\n";

            next;
        };

        # OBSOLETE or OBSOLETED
        /OBSOLETE/ and do {
            next;
        };

        /DEPRECATED/ and do {
            next;
        };

        print_fix_script_warn($csv_sources[$i], $lineno, "Unrecognized line");
        warn "$_\n";
        last;
    }
}

# There is no some MIME types in IANA papers, so add them here
print MIME_ENUM_HPP<<"END_OF_POSTAMBLE";

    //
    // There is no some MIME types in IANA papers, so add them here
    //
    , application__x_dosexec = @{[$indices{'application'}[1]++]}

    , audio__wav = @{[$indices{'audio'}[1]++]}

    // Default MIME used as a fallback value
    , fallback = application__octet_stream
}; // mime_enum

/**
 * Converts mime enum to string.
 */
std::string const & to_string (mime_enum m);

END_OF_POSTAMBLE

print MIME_ENUM_CPP<<"END_OF_POSTAMBLE";

    , { mime_enum::application__x_dosexec, mime_data{"application/x-dosexec"} }
    , { mime_enum::audio__wav, mime_data{"audio/wav"} }
}; // MIME_DATA

std::string const & to_string (mime_enum m)
{
    static std::string const __bad;
    auto pos = MIME_DATA.find(m);
    return pos != MIME_DATA.end() ? pos->second.text : __bad;
}

} // namespace mime
END_OF_POSTAMBLE

for (keys %indices) {
    my $registry = $_;
    my $low_limit = $indices{$registry}[0];
    my $hi_limit  = $indices{$registry}[1];

print MIME_ENUM_HPP<<"END_OF_POSTAMBLE";

inline bool is_${registry} (mime_enum m) noexcept
{
    return static_cast<int>(m) >= ${low_limit}
        && static_cast<int>(m) < ${hi_limit};
}
END_OF_POSTAMBLE
}

print MIME_ENUM_HPP<<"END_OF_POSTAMBLE";

inline bool is_valid (mime_enum m) noexcept
{
    return is_application(m)
        || is_audio(m)
        || is_font(m)
        || is_image(m)
        || is_message(m)
        || is_model(m)
        || is_multipart(m)
        || is_text(m)
        || is_video(m);
}

} // namespace mime
END_OF_POSTAMBLE

0;
