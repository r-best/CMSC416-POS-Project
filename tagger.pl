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
    foreach my $token (@tokens){
        if($token =~ /^\[$/){
            print "\n".$token." ";
        }
        elsif($token =~ /^\]$/){
            print $token."\n";
        }
        else{
            if(exists $tags{$token}){
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