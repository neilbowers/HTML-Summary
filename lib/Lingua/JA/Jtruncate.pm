package Lingua::JA::Jtruncate;

#------------------------------------------------------------------------------
#
# Start of POD
#
#------------------------------------------------------------------------------

=head1 NAME

Lingua::JA::Jtruncate - module to truncate Japanese encoded text.

=head1 SYNOPSIS

    use Lingua::JA::Jtruncate qw( jtruncate );
    $truncated_jtext = jtruncate( $jtext, $length );

=head1 DESCRIPTION

The jtruncate function truncates text to a length $length less than bytes. It
is designed to cope with Japanese text which has been encoded using one of the
standard encoding schemes - EUC, JIS, and Shift-JIS. It uses the
Lingua::JA::Jcode module to detect what encoding is being used. If the text is
none of the above Japanese encodings, the text is just truncated using substr.
If it is detected as Japanese text, it tries to truncate the text as well as
possible without breaking the multi-byte encoding.  It does this by detecting
the character encoding of the text, and recursively deleting Japanese (possibly
multi-byte) characters from the end of the text until it is underneath the
length specified. It should work for EUC, JIS and Shift-JIS encodings.

=head1 SEE ALSO

L<Lingua::JA::Jcode>

=head1 AUTHOR

Ave Wrigley E<lt>wrigley@cre.canon.co.ukE<gt>

=head1 COPYRIGHT

Copyright (c) 1997 Canon Research Centre Europe (CRE). All rights reserved.
This script and any associated documentation or files cannot be distributed
outside of CRE without express prior permission from CRE.

=cut

#------------------------------------------------------------------------------
#
# End of POD
#
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
#
# Pragmas
#
#------------------------------------------------------------------------------

require 5.004;
use strict;

#==============================================================================
#
# Modules
#
#==============================================================================

use Lingua::JA::Jcode;
require Exporter;

#==============================================================================
#
# Public globals
#
#==============================================================================

use vars qw( 
    $VERSION 
    @ISA 
    @EXPORT_OK 
    %euc_code_set
    %sjis_code_set
    %jis_code_set
    %char_re
);

$VERSION = '0.001';
@ISA = qw( Exporter );
@EXPORT_OK = qw( jtruncate );

%euc_code_set = (
    ASCII_JIS_ROMAN     => '[\x00-\x7f]',
    JIS_X_0208_1997     => '[\xa1-\xfe][\xa1-\xfe]',
    HALF_WIDTH_KATAKANA => '\x8e[\xa0-\xdf]',
    JIS_X_0212_1990     => '\x8f[\xa1-\xfe][\xa1-\xfe]',
);

%sjis_code_set = (
    ASCII_JIS_ROMAN     => '[\x21-\x7e]',
    HALF_WIDTH_KATAKANA => '[\xa1-\xdf]',
    TWO_BYTE_CHAR       => '[\x81-\x9f\xe0-\xef][\x40-\x7e\x80-\xfc]',
);

%jis_code_set = (
    TWO_BYTE_ESC        => 
        '(?:' .
        join( '|',
            '\x1b\x24\x40',
            '\x1b\x24\x42',
            '\x1b\x26\x40\x1b\x24\x42',
            '\x1b\x24\x28\x44',
        ) .
        ')'
    ,
    TWO_BYTE_CHAR       => '(?:[\x21-\x7e][\x21-\x7e])',
    ONE_BYTE_ESC        => '(?:\x1b\x28[\x4a\x48\x42\x49])',
    ONE_BYTE_CHAR       =>
        '(?:' .
        join( '|', 
            '[\x21-\x5f]',                      # JIS7 Half width katakana
            '\x0f[\xa1-\xdf]*\x0e',             # JIS8 Half width katakana
            '[\x21-\x7e]',                      # ASCII / JIS-Roman
        ) .
        ')'
);

%char_re = (
    'euc'       => '(?:' . join( '|', values %euc_code_set ) . ')',
    'sjis'      => '(?:' . join( '|', values %sjis_code_set ) . ')',
    'jis'       => '(?:' . join( '|', values %jis_code_set ) . ')',
);

#==============================================================================
#
# Public exported functions
#
#==============================================================================

#------------------------------------------------------------------------------
#
# jtruncate( $text, $length )
#
# truncate a string safely (i.e. don't break japanese encoding)
#
#------------------------------------------------------------------------------

sub jtruncate
{
    my $text            = shift;
    my $length          = shift;

    # sanity checks

    return '' if $length == 0;
    return undef if not defined $length;
    return undef if $length < 0;
    return $text if length( $text ) <= $length;

    my $orig_text = $text;
    my $encoding = Lingua::JA::Jcode::getcode( \$text );
    if ( not defined $encoding or $encoding !~ /^(?:euc|s?jis)$/ )
    {
        # not euc/sjis/jis - just use substr
        return substr( $text, 0, $length );
    }

    # JIS encoding uses escape sequences to shift in and out of single-byte /
    # multi-byte  modes. If the truncation process leaves the text ending in
    # multi-byte mode, we need to add the single-byte escape sequence.
    # Therefore, we truncate 3 more bytes than necessary just in case from a
    # JIS encoded string, so we have room to add the escape sequence if
    # necessary, without going over the $length limit

    $length -= 3 if $encoding eq 'jis'; 
    while( length( $text ) > $length )
    {
        unless ( $text =~ s!$char_re{ $encoding }$!!o )
        {
            # regex failed - to avoid a potential infinite loop, just use
            # substr to truncate the text. This is probably not Japanese text
            # in any case!
            return substr( $orig_text, 0, $length );
        }
    }
    # If this is JIS, and it ends in multi-byte mode, whack single-byte escape
    # sequence on the end
    $text .= "\x1b\x28\x42" if 
        $encoding eq 'jis' and 
        $text =~ /$jis_code_set{ TWO_BYTE_CHAR }$/
    ;
    return $text;
}

#==============================================================================
#
# Return true
#
#==============================================================================

1;
