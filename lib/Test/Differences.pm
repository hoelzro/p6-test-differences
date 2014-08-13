use v6;
use Algorithm::LCS;
use Test;

module Test::Differences:vers<0.1.0>:auth<hoelzro> {
    my class Formatter {
        has @.got;
        has @.expected;

        has $!max-index-length;
        has $!max-got-length;
        has $!max-expected-length;

        submethod BUILD(:@!got, :@!expected) {
            $!max-index-length    = [max] ((0 .. max(@!got.end, @!expected.end))».Str».chars, 'Index'.chars);
            $!max-got-length      = [max] (@!got».Str».chars, 'Got'.chars);
            $!max-expected-length = [max] (@!got».Str».chars, 'Expected'.chars);
        }

        method !print-separator {
            diag('|' ~ join('+', ($!max-index-length, $!max-got-length, $!max-index-length, $!max-expected-length).map({ '-' x $_ + 2 })) ~ '|')
        }

        method !print-row($one, $two, $three, $four) {
            diag(sprintf("| %{$!max-index-length}s | %{$!max-got-length}s | %{$!max-index-length}s | %{$!max-expected-length}s |", $one, $two, $three, $four));
        }

        method print-preface {
            self!print-separator;
            self!print-row('Index', 'Got', 'Index', 'Expected');
            self!print-separator;
        }
        method print-epilogue {
            self!print-separator;
        }
        method print-equal($got-index, $expected-index) {
        }
        method print-nequal($got-index, $expected-index) {
            self!print-row($got-index // '', $got-index.defined ?? @.got[$got-index] !! '', $expected-index // '', $expected-index.defined ?? @.expected[$expected-index] !! '');
        }
    }

    # XXX test level
    our sub eq-or-diff(@got, @expected, Str $reason?, Int :$start-index = 0) is export {
        my $formatter = Formatter.new(
            :@got,
            :@expected,
        );
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

        $formatter.print-preface;
        while $lcs-index      < @lcs ||
              $got-index      < @got ||
              $expected-index < @expected {

            my $head          = @lcs[$lcs-index];
            my $got-head      = @got[$got-index];
            my $expected-head = @expected[$expected-index];

            if &compare($head, $got-head) && &compare($head, $expected-head) {
                $formatter.print-equal($got-index, $expected-index);
                $_++ for $lcs-index, $got-index, $expected-index;
            } else {
                my Int $deleted;
                my Int $added;

                if !&compare($head, $expected-head) {
                    $deleted = $expected-index;
                    $expected-index++;
                }
                if !&compare($head, $got-head) {
                    $added = $got-index;
                    $got-index++;
                }

                $formatter.print-nequal($added, $deleted);
            }
        }
        $formatter.print-epilogue;

        False
    }
}
