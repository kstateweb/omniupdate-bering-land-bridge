#!/usr/local/bin/perl -w

# This is the start of the site conversion process.
# you will very likely need to change paths to various files below.

use strict;
use File::Find ();
use File::Path qw(make_path);
use Cwd;

my $transformCommand = "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe";
my $transformQueuedPcfXslt = "convert-queued-pcfs.xsl";
my $transformPcfXslt = "convert-pcf.xsl";
my $transformPropertiesXslt = "convert-properties.xsl";
my $current_dir = Cwd::cwd();
my $datadir = "C:/omniupdate-bering-land-bridge-data/about";
my $inputdir = "$datadir/input";
my $outputdir = "$datadir/output";
my @pcfqueue = ();

my $files_total = 0;
my $files_updated = 0;
my $files_parseerror = 0;
my $files_unchanged = 0;

# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;


sub wanted;


# sub updatePCF {
#    my($inputfile, $outputfile) = @_;
#    my($rc);
#    my $xslt = $transformPcfXslt;

#    if ($inputfile =~ /properties.pcf$/) {
#       $xslt = $transformPropertiesXslt;
#    }

#    my $cmd = qq("$transformCommand" "-s:$inputfile" "-xsl:$xslt" "-o:$outputfile" -opt:0 2>&1);
#    # print "Running $cmd\n";
#    $rc = system($cmd);

#    if ($rc) {
#       print "   Error return from transform: $rc\n";
#    }
   
# }


sub queuePCF {
   my($displayname, $inputfile, $outputfile) = @_;

   push(@pcfqueue, "<file><displayname>$displayname</displayname><input>$inputfile</input><output>$outputfile</output></file>");
}



sub updateQueuedPCFs {
   my(@queue) = @_;
   my $rc;
   my $xslt = $transformQueuedPcfXslt;
   my $queuefile = "temp/queued-pcfs.xml";

   print "Pass 2 -- convert PCF files\n";

   open QUEUE, ">$queuefile" || die "Unable to open '$queuefile': $!\n";
   print QUEUE "<files>\n";
   print QUEUE join("\n", @pcfqueue);
   print QUEUE "</files>\n";
   close QUEUE;

   my $cmd = qq("$transformCommand" "-s:$queuefile" "-xsl:$xslt" 2>&1);
   # print "Running $cmd\n";
   $rc = system($cmd);

   if ($rc) {
      print "   Error return from transform: $rc\n";
   }
   
}

sub do1File {

   my($filepath) = @_;
   my($file, $newfile, $odir);

   # print "\n\nProcessing $filepath\n";
   $files_total++;

   my $displayname = $filepath;
   $displayname =~ s/${inputdir}//;

   my $outputfilepath = $filepath;
   $outputfilepath =~ s/${inputdir}/$outputdir/;

   # open(FILE, "<$filename") || die "Unable to open file: $!\n";
   # undef $/;
   # $file = <FILE>;
   # close(FILE);

   $newfile = queuePCF($displayname, $filepath, $outputfilepath);

}

sub wanted {
   my $filename = $_;

   # Skip ksu-resources, OMNI-INF, OMNI-RESOURCES, and potentially any future OMNI-whatever
   if ($filename =~ /^(OMNI-|ksu-resources)/) {
      print "Pruning internal folder $filename\n";
      $File::Find::prune = 1;
      return;
   }

   if (! (-f $File::Find::name)) {
      return;
   }

   my $relativefilename = $File::Find::name;
   $relativefilename =~ s/${inputdir}//;

   

   # Skip .html and .inc files
   if ($filename =~ /\.(html|inc)$/) {
      print "Processing $relativefilename\n";
      print "   skipping unsupported file type: $filename\n"; 
      return;
   }

   # Skip any file that has "banner-slider-config" in the name.
   if ($filename =~ /banner-slider-config/) {
      print "Processing $relativefilename\n";
      print "   skipping banner-slider-config file\n"; 
      return;
   }

   # Skip any file that has "horizontal-menu" in the name.
   if ($filename =~ /horizontal-menu/) {
      print "Processing $relativefilename\n";
      print "   skipping horizontal-menu file\n"; 
      return;
   }

   # Process .pcf files
   if ($filename =~ /\.(pcf)$/) {
      # print "   converted.\n"; 

      do1File($File::Find::name);
      return;
   }

   # Everything else gets copied
   print "Processing $relativefilename\n";
   print "   ignored for now.\n";

}


print "Pass 1 -- unused files\n\n";

# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, $inputdir);
print "\n\n";

# Run all the queued PCF files
updateQueuedPCFs(@pcfqueue);

print "\n\nTotal pages: $files_total\n";
# print "Files unparsable: $files_parseerror\n";
# print "Files updated: $files_updated\n";
# print "Files unchanged: $files_unchanged\n";
exit;
