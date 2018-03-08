use Text::Table;

sub println { print "@_"."\n" }

sub processInputFile($) {
    my $file = @_[0];
    if(open(my $fh, "<:encoding(UTF-8)", $file)){
        my $text = do { local $/; <$fh> }; # Read in the entire file as a string
        chomp $text;
        $text =~ s/[\[\]]//g;
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

my @input;
my @key;

my $correct = 0;
my $total = 0;

@input = processInputFile($inputFile);
@key = processInputFile($keyFile);

my $table = Text::Table->new();

for(my $i = 0; $i < 0+@input; $i++){
    my $inputTag = (split(/\//, $input[$i]))[1];
    my $keyTag = (split(/\//, $key[$i]))[1];

    if($inputTag eq $keyTag){
        $correct++;
    }
    $total++;
}
println "CORRECT: ".$correct;
println "TOTAL: ".$total;
println ($correct / $total)."%";