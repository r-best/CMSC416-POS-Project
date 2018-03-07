sub println { print "@_"."\n" }

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

my $correct = 0;
my $total = 0;

if(open(my $fhI, "<:encoding(UTF-8)", $inputFile)){
    if(open(my $fhK, "<:encoding(UTF-8)", $keyFile)){
        my $inputText = do { local $/; <$fhI> }; # Read in the entire file as a string
        my $keyText = do { local $/; <$fhK> }; # Read in the entire file as a string
        
        my @inputTokens = split(/[\s\n]+/, $inputText);
        my @keyTokens = split(/[\s\n]+/, $keyText);

        for(my $i = 0; $i < 0+@inputTokens; $i++){
            my $inputTag = (split(/\//, $inputTokens[$i]))[1];
            my $keyTag = (split(/\//, $keyTokens[$i]))[1];

            if($inputTag eq $keyTag){
                $correct++;
            }
            $total++;
        }
        println "CORRECT: ".$correct;
        println "TOTAL: ".$total;
        println ($correct / $total)."%";
    } else {
        die "Error opening key file '$keyFile'";
    }
} else {
    die "Error opening input file '$inputFile'";
}