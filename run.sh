time perl tagger.pl training/pos-train.txt training/pos-test.txt > pos-test-with-tags.txt
head -100 pos-test-with-tags.txt
perl scorer.pl pos-test-with-tags.txt training/pos-test-key.txt > pos-tagging-report.txt
cat pos-tagging-report.txt