#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;
use Test::Benchmark qw(is_fastest);

use Benchmark qw(timethese cmpthese);
use Guard qw(scope_guard);
use IO::Capture::Stderr;
use IO::Capture::Stdout;
use String::Random qw(random_regex);

# Some benchmark results from my old laptop:
#
#                    Rate  regex_inline     regex_sub    substr_sub substr_inline
# regex_inline  4241158/s            --           -1%           -3%           -3%
# regex_sub     4287402/s            1%            --           -2%           -2%
# substr_sub    4369067/s            3%            2%            --           -0%
# substr_inline 4389971/s            4%            2%            0%            --

sub with_stderr_and_stdout_as_diag_and_note(&) {
    my ($code) = @_;

    my $stderr_capture = IO::Capture::Stderr->new;
    my $stdout_capture = IO::Capture::Stdout->new;

    $stderr_capture->start;
    $stdout_capture->start;

    scope_guard {
        $stderr_capture->stop;
        $stdout_capture->stop;

        while (my $line = $stderr_capture->read) {
            chomp $line;

            diag $line;
        }

        while (my $line = $stdout_capture->read) {
            chomp $line;

            note $line;
        }
    };

    return $code->();
}

sub t_regex {
    my $word = "  $_[0]  ";

    return map { /(...)/g }
        map {
            substr $word, $_
        } 0 .. 2
}

sub t_substr {
    my $word = "  $_[0]  ";
    
    return map {
        substr $word, $_, 3
    } 0 .. length($word) - 3;
}

my @words = map { random_regex(q{\w{12}}) } 0..1_000_000;

my $timethese_output = with_stderr_and_stdout_as_diag_and_note {
    timethese(-5, {
        regex_sub     => 'my @a = map { [ t_regex $_  ] } @words',
        substr_sub    => 'my @a = map { [ t_substr $_ ] } @words',
        regex_inline  => 'my @a = map {
                my $word = "  $_  ";

                [
                    map { /(...)/g }
                        map {
                            substr $word, $_
                        } 0 .. 2
                ]
            } @words',
        substr_inline => 'my @a = map {
                my $word = "  $_  ";
                
                [
                    map {
                        substr $word, $_, 3
                    } 0 .. length($word) - 3
                ]
            } @words',
    });
};

is_fastest('substr_inline', undef, $timethese_output,
    'The substr_inline trigram generator algorithm is the fastest');

with_stderr_and_stdout_as_diag_and_note {
    cmpthese($timethese_output);
};

done_testing;
