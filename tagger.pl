# Assignment 3
# CMSC 416
# Due: Mon Mar. 12, 2018
# Program Summary:
#   
# Algorithm:
#   
# Usage Format:
#   
# Rules:
#   Base Accuracy: 47976 / 56824 = 84.42911%
#   With Rule 1: 48002 / 56824 = 84.47487%
#   With Rule 2: 48353 / 56824 = 85.09257%
#   With Rule 3: 49006 / 56824 = 86.24173%
#   With Rule 4: 49019 / 56824 = 86.26461%
#   With Rule 5: 46994 / 56824 = 82.70097%

use Data::Dumper;

sub println { print "@_"."\n" }

if(0+@ARGV < 2){
    die "At least 2 arguments required";
}

my $train = shift @ARGV;
my $test = shift @ARGV;

if(!(-f $train)){
    die "Training file '$train' does not exist";
}
if(!(-f $test)){
    die "Test file '$test' does not exist";
}

my %tags;

if(open(my $fh, "<:encoding(UTF-8)", $train)){
    my $text = do { local $/; <$fh> }; # Read in the entire file as a string
    close $fh;
    chomp $text;
    $text =~ s/[\[\]]//g; # Remove phrase boundaries

    my @rules = split(/\s+/, $text);
    my %tokens = {};

    # For each word/tag pair in the training set,
    # increment %tokens{word}{tag}
    foreach my $rule (@rules){
        my @split = split(/(?<!\\)\//, $rule);
        $split[1] =~ s/^(.+)\|.*/\1/;
        $tokens{$split[0]}{$split[1]}++;
    }

    # Once word/tag frequencies are set up,
    # map each word to its most frequent tag
    # in the global variable %tags
    foreach my $token (keys %tokens){
        my $max = (keys %{$tokens{$token}})[0];
        foreach my $tag (keys %tokens{$token}){
            if($tokens{$token}{$tag} > $tokens{$token}{$max}){
                $max = $tag;
            }
        }
        $tags{$token} = $max;
    }
} else {
    die "Error opening training file '$train'";
}

if(open(my $fh, "<:encoding(UTF-8)", $test)){
    my $text = do { local $/; <$fh> }; # Read in the entire file as a string
    close $fh;

    my @tokens = split(/\s+/, $text);

    # For each token that's not a phrase boundary bracket,
    # add a / followed by its most likely tag
    my $flag = 0;
    foreach my $token (@tokens){
        if($token =~ /^\[$/){
            if($flag != 0){
                $flag = 0;
                print $token." ";
            }
            else{
                print "\n".$token." ";
            }
        }
        elsif($token =~ /^\]$/){
            $flag = 1;
            print $token."\n";
        }
        else{
            $flag = 0;
            if($token =~ /[Mm]ost/){
                # Rule 1: "most" should be an RBS
                # (It was getting predicted as JJS)
                $token =~ s/(.*)/$1."\/RBS"/e;
            }
            elsif($token =~ /^\d+([\.:]\d+)?$/){
                # Rule 2: Numbers & times should be CD
                # (Sometimes getting NN)
                $token =~ s/(.*)/$1."\/CD"/e;
            }
            elsif($tags{$token} == "NN" && $token =~ /^[A-Z][A-Za-z]+/){
                # Rule 3: NN's that start with a capital are NNP
                # (Often getting NN)
                $token =~ s/(.*)/$1."\/NNP"/e;
            }
            elsif($tags{$token} == "NN" && $token =~ /-/){
                # Rule 4: NN's with a hyphen are actually JJ
                $token =~ s/(.*)/$1."\/JJ"/e;
            }
            elsif($tags{$token} == "NN" && $token =~ /s$/){
                # Rule 5: NN's that end in an 's' are actually NNS
                $token =~ s/(.*)/$1."\/NNS"/e;
            }
            elsif(exists $tags{$token}){
                $token =~ s/(.*)/$1."\/".$tags{$1}/e;
            } else { # If tag wasn't present in training data, assume NN
                $token =~ s/(.*)/$1."\/NN"/e;
            }
            print $token." ";
        }
    }
} else {
    die "Error opening training file '$train'";
}