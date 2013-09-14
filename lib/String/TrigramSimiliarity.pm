package String::TrigramSimilarity;

# missing features:
#  * imitating String::Trigram behaviour when encountering repeated trigrams or doing it properly
#  * n-grams ?
# features that may or may not be implemented - they may ruin performance:
#  * any mangling of the base or the string to be matched
#   * these should be done by the user (eg. in a wrapper lib), otherwise the extra check for the param takes precious time if not used - or maybe by using function pointers to different ->_trigrams() implementations (or using code generation)
#   * these are often subject to locale specific settings.. grey area
#   * examples in String::Trigram:
#       * ignoring case
#       * removing non-whitespace
# ideas:
#  * experiment with (benchmark) code generation (ie. inlining the ->_trigrams() calls)

use 5.10.0;

use Moo;
use namespace::autoclean;

use List::Util qw(min);
use Scalar::Util qw(looks_like_number);

=head1 NAME

String::TrigramSimilarity - 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS


=head1 DESCRIPTION

=head1 METHODS

=cut

=head2 

=cut

has min_similarity => (
    is          => 'rw',
    isa         => sub { looks_like_number $_ && $_ >= 0 },
    required    => 1,
);

has warp => (
    is          => 'rw',
    isa         => sub { looks_like_number $_ },
    default     => 1,
);

has _words_by_trigram => (
    is          => 'rw',
    default     => sub { +{} },
);

has _num_trigrams_of_word => (
    is          => 'rw',
    default     => sub { +{} },
);

sub BUILD {
    my ($self, $arg) = (shift, @_);

    my $words_by_trigram = $self->_words_by_trigram;
    my $num_trigrams_of_word = $self->_num_trigrams_of_word;

    foreach my $word ( @{ $arg->{base} } ) {
        my @trigrams = $self->_trigrams($word);

        foreach my $trigram (@trigrams) {
            $words_by_trigram->{$trigram}->{$word}++;
            $num_trigrams_of_word->{$word} = scalar @trigrams;
        }
    }
}

sub search {
    my ($self, $search_word) = (shift, @_);
    
    #FIXME there's a String::Trigram bug (IMHO) - if both words contain the same trigram multiple times, we should count as many common trigrams as the word with the lesser amount of trigram-repetitions has (so instead of @trigrams, we should use a %trigrams where keys are keywords, values are the number of repetitions of that trigra in the given word; then $candidates{$word} += min($count, $trigrams{$word}) )

    my %trigrams;
    my $num_trigrams;
    foreach my $trigram ( $self->_trigrams($search_word) ) {
        $trigrams{$trigram}++;
        $num_trigrams++;
    }

    my $words_by_trigram = $self->_words_by_trigram;

    my %candidates;
    while ( my ($trigram, $num_occurrences) = each %trigrams ) {
        while (
            my ($word, $count) = each %{ $words_by_trigram->{$trigram} }
        ) {
            $candidates{$word} += min($count, $num_occurrences);
        }
    }

    my $min_similarity = $self->min_similarity;
    my $warp = $self->warp;
    my $num_trigrams_of_word = $self->_num_trigrams_of_word;

    my %matches;
    while ( my ($word, $num_common_trigrams) = each %candidates ) {
        my $total_trigrams = $num_trigrams + $num_trigrams_of_word->{$word}
            - $num_common_trigrams;

        my $similarity = 1 -
            (($total_trigrams - $num_common_trigrams) / $total_trigrams)
                ** $warp;

        if ($similarity > $min_similarity) {
            $matches{$word} = $similarity;
        }
    }

    return \%matches;
}

sub _trigrams {
    return map {
        /(...)/g
    }
        map {
            substr "  $_[1]  ", $_
        } 0 .. 2;
}

=head1 SEE ALSO

L<String::Trigram>

=head1 AUTHOR

Norbert Buchmuller, C<< <norbi at nix.hu> >>

=head1 TODO

=over

=item *

=back

=head1 BUGS

Please report any bugs or feature requests to
C<bug-string-trigramsimilarity at rt.cpan.org>, or through the web
interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=String-TrigramSimilarity>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc String::TrigramSimilarity

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=String-TrigramSimilarity>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/String-TrigramSimilarity>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/String-TrigramSimilarity>

=item * Search CPAN

L<http://search.cpan.org/dist/String-TrigramSimilarity/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2013 Norbert Buchmuller, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of String::TrigramSimilarity
