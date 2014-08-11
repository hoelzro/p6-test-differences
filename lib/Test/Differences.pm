use v6;
use Algorithm::LCS;
use Test;

module Test::Differences:vers<0.1.0>:auth<hoelzro> {
    # XXX test level
    our sub eq-or-diff(@got, @expected, Str $reason?, Int :$start-index = 0) is export {
        my &compare = &infix:<eqv>;
        my @lcs = lcs(@got, @expected, :&compare);

        if +@lcs == +@got {
            pass $reason;
            return True;
        }
        flunk $reason;

        my $lcs-index      = 0;
        my $got-index      = 0;
        my $expected-index = 0;

        while $lcs-index      < @lcs ||
              $got-index      < @got ||
              $expected-index < @expected {

            my $head          = @lcs[$lcs-index];
            my $got-head      = @got[$got-index];
            my $expected-head = @expected[$expected-index];

            if &compare($head, $got-head) && &compare($head, $expected-head) {
                diag("\@got[$got-index] and \@expected[$expected-index] are equal");
                $_++ for $lcs-index, $got-index, $expected-index;
            } else {
                if !&compare($head, $expected-head) {
                    diag("deleted \@expected[$expected-index]");
                    $expected-index++;
                }
                if !&compare($head, $got-head) {
                    diag("added \@got[$got-index]");
                    $got-index++;
                }
            }
        }

        False
    }
}
