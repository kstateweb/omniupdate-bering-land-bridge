#!/usr/local/bin/perl -w

use strict;
use File::Find ();
use File::Path qw(make_path);
use Cwd;

my $transformCommand = "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe";
my $transformPcfXslt = "C:/Users/neil/Documents/GitHub/omniupdate-bering-land-bridge/convert-pcf.xsl";
my $transformPropertiesXslt = "C:/Users/neil/Documents/GitHub/omniupdate-bering-land-bridge/convert-properties.xsl";
my $current_dir = Cwd::cwd();
my $datadir = "C:/omniupdate-bering-land-bridge-data/about";
my $inputdir = "$datadir/input";
my $outputdir = "$datadir/output";

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



# Old file looks like:

# <?xml version="1.0" encoding="utf-8"?>
# <?pcf-stylesheet site="ksu-resources" path="/xsl/properties.xsl" extension="inc" ?>
# <!DOCTYPE document SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd">

# <directory>
#    <!-- com.omniupdate.properties -->
#    <parameter name="title" type="text" group="Everyone" prompt="Breadcrumb" alt="Name for this folder's breadcrumb">...breadcrumb...</parameter>
#    <!-- /com.omniupdate.properties -->
# </directory>

# new file looks like:

# <?xml version="1.0" encoding="utf-8"?>
# <?pcf-stylesheet site="ksu-resources" path="/xsl/properties.xsl" extension="inc" ?>
# <!DOCTYPE document SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd">

# <directory xmlns:ouc="http://omniupdate.com/XSL/Variables">
#    <ouc:properties>
#       <parameter name="breadcrumb" type="text" group="Everyone" prompt="Breadcrumb" alt="Name for this folder's breadcrumb">...breadcrumb...</parameter>
#    </ouc:properties>

#     <content>
#       <ouc:div label="fakecontent" group="Everyone" button="707">Use page properties to edit this page.</ouc:div>
#    </content>
# </directory>


sub updatePCF {
   my($inputfile, $outputfile) = @_;
   my($rc);
   my $xslt = $transformPcfXslt;

   if ($inputfile =~ /properties.pcf$/) {
      $xslt = $transformPropertiesXslt;
   }

   my $cmd = qq("$transformCommand" "-s:$inputfile" "-xsl:$xslt" "-o:$outputfile" -opt:0 2>&1);
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

   my $outputfilepath = $filepath;
   $outputfilepath =~ s/${inputdir}/$outputdir/;

   # open(FILE, "<$filename") || die "Unable to open file: $!\n";
   # undef $/;
   # $file = <FILE>;
   # close(FILE);

   $newfile = updatePCF($filepath, $outputfilepath);

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

   print "Processing $relativefilename\n";
   

   # Skip .html and .inc files
   if ($filename =~ /\.(html|inc)$/) {
      print "   skipping unsupported file type: $filename\n"; 
      return;
   }

   # Skip any file that has "banner-slider-config" in the name.
   if ($filename =~ /banner-slider-config/) {
      print "   skipping banner-slider-config file\n"; 
      return;
   }

   # Skip any file that has "horizontal-menu" in the name.
   if ($filename =~ /horizontal-menu/) {
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
   print "   copied.\n";

}



# Traverse desired filesystems

File::Find::find({wanted => \&wanted}, $inputdir);

print "\n\nTotal pages: $files_total\n";
# print "Files unparsable: $files_parseerror\n";
# print "Files updated: $files_updated\n";
# print "Files unchanged: $files_unchanged\n";
exit;
