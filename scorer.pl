# Assignment 3 scorer.pl
# CMSC 416
# Due: Mon Mar. 12, 2018
# Program Summary:
#   A program that calculates the accuracy of part-of-speech tagged
#   text given the text and a gold standard to compare it against.
# Algorithm:
#   Reads the POS-tagged text and the gold standard key and compares
#   them word by word to see where the tagged text differs. Uses a
#   double hash to keep track of how many times each possible tag
#   is tagged as every other tag (i.e. how many times NN was tagged
#   as NN, how many times they were tagged as JJ, how many times they
#   were tagged as VB, etc.). Uses that data to create a confusion matrix
#   showing all tags and how often they were tagged correctly.
# Usage Format:
#   perl scorer.pl tagged.txt key.txt

use Text::SimpleTable::AutoWidth;

sub println { print "@_"."\n" }

# Function to open an input file and 
# return an array of the tokens delimited
# by spaces and newlines
sub processInputFile($) {
    my $file = @_[0];
    if(open(my $fh, "<:encoding(UTF-8)", $file)){
        my $text = do { local $/; <$fh> }; # Read in the entire file as a string
        $text =~ s/[\[\]]//g;
        chomp $text;
        return split(/[\s\n]+/, $text);
        close $file;
    } else {
        die "Error opening file '$file'";
    }
}

if(0+@ARGV < 2){
    die "At least 2 arguments required";
}

# Get filenames from command line args
my $inputFile = shift @ARGV;
my $keyFile = shift @ARGV;

if(!(-f $inputFile)){
    die "Input file '$inputFile' does not exist";
}
if(!(-f $keyFile)){
    die "Key file '$keyFile' does not exist";
}

# Process input files
my @input = processInputFile($inputFile);
my @key = processInputFile($keyFile);

my $correct = 0;
my $total = 0;

# A double hash such that each %predictions{someTag} contains a hash
# of every tag to how often someTag was predicted as tag
# i.e. in an ideal situation:
#       $predictions{NN}{NN} = 50
#       $predictions{NN}{VB} = 0
my %predictions;

for(my $i = 0; $i < 0+@input; $i++){
    # For each word, get its predicted tag from the input file
    # and its actual tag from the key file
    my $inputTag = (split(/(?<!\\)\//, $input[$i]))[1];
    my $keyTag = (split(/(?<!\\)\//, $key[$i]))[1];
    # Disregard multiple tags like RB|NN (take only the first)
    $inputTag =~ s/^(.*)\|.*/$1/;
    $keyTag =~ s/^(.*)\|.*/$1/;
    
    $predictions{$keyTag}{$inputTag}++;

    if($inputTag eq $keyTag){
        $correct++;
    }
    $total++;
}

# Set up title bar of table with all possible tags
my @title = keys %predictions;
unshift @title, "";
my $table = Text::SimpleTable::AutoWidth->new(max_width => 1000000, captions => [@title]);

# For each tag, assemble a table row by reading from
# %predictions to see how often that tag was predicted
# as every other tag
for my $actual (keys %predictions){
    my @row = ($actual);
    for my $pred (keys %predictions){
        if(exists $predictions{$actual}{$pred}){
            push @row, $predictions{$actual}{$pred};
        }
        else{
            push @row, 0;
        }
    }
    $table->row(@row);
}

print $table->draw();
println "CORRECT: ".$correct;
println "TOTAL: ".$total;
println "ACCURACY: ".(($correct / $total) * 100)."%";