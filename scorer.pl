use Text::Table;
use Data::Dumper;

sub println { print "@_"."\n" }

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

my $inputFile = shift @ARGV;
my $keyFile = shift @ARGV;

if(!(-f $inputFile)){
    die "Input file '$inputFile' does not exist";
}
if(!(-f $keyFile)){
    die "Key file '$keyFile' does not exist";
}

my @input = processInputFile($inputFile);
my @key = processInputFile($keyFile);

my $correct = 0;
my $total = 0;

my %predictions;

for(my $i = 0; $i < 0+@input; $i++){
    my $inputTag = (split(/(?<!\\)\//, $input[$i]))[1];
    my $keyTag = (split(/(?<!\\)\//, $key[$i]))[1];
    $inputTag =~ s/^(.*)\|.*/$1/;
    $keyTag =~ s/^(.*)\|.*/$1/;
    
    $predictions{$keyTag}{$inputTag}++;

    if($inputTag eq $keyTag){
        $correct++;
    }
    $total++;
}

my @title = keys %predictions;
unshift @title, "a";
my $table = Text::Table->new(@title);

for my $actual (keys %predictions){
    my @row = ($actual);
    for my $pred (keys %predictions){
        if(exists $predictions{$actual}{$pred}){
            # println $predictions{$actual}{$pred};
            push @row, $predictions{$actual}{$pred};
        }
        else{
            # println "AAAAAAAAAAAAAAAAAAAA";
            push @row, 0;
        }
    }
    # println @row;
    $table->add(@row);
}

print $table->table();
println "CORRECT: ".$correct;
println "TOTAL: ".$total;
println (($correct / $total) * 100)."%";