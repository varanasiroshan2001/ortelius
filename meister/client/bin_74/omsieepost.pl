###### Above this line is generated by om ######

# omsieepost.pl Version 1.0
#
# Openmake MKS Source Integrity post command utility
#
# Catalyst Systems Corporation          June 19, 2003
#
#-- Perl wrapper to SIEE commands that plugs into 
#   Openmake build tool

=head1 OMSIEEPOST.PL

=head1 LOCATION

program files/openmake6/bin

=head1 DESCRIPTION

omsieepost.pl is a perl script that "plugs-in" to bldmake.exe and om.exe
via the {-ap, -ac, -ar} command line flags. This script executes after
the executable runs, and has access to certain Openmake-specific
information.

This command will read the Openmake Bill of Material report, and determine
which files to label. It will then use the 'si addlabel' command to label
the files.

=head1 ARGUMENTS

The following arguments can be placed in the configuration file.

Unlike the actual siee commands, there must be a space between the
switch and its argument

=over 2

=item -U <user> : 

User ID

=item -P <password> :

User password

=item -l <label> : 

Label to apply to files used in the build. If <label> is of the
form <str>"%DATE", the label will have YYMMDD appended to it.
So <label> = BUILD_%DATE% => BUILD_030429.

=back

=head1 STRUCTURE

The execution of this script is as follows:

 1. parse the command line flags
 2. Parse the Bill of Materials report for a list of files 
    to label
 3. Use the si addlabel command to add the label to all members
    in the BOM report
 
=head1 FUTURE WORK

It would be useful if this routine could check in built files from the
build directory. Unsure how to proceed with that, given that we may need
a snapshot of the build directory from a 'pre' script that says what was
present before the build took place.

=cut
 
#=====================================
#-- use declarations
use Openmake::PrePost;
use Openmake::Log;
use Getopt::Long;

#-- Openmake Variables
our $RC = 0;
my @argvl = @ARGV;

#-- global variables
our $SCMLabelCmd  = "si addlabel --batch";
our $SCMMemberCmd = "si memberinfo --batch";
our ( $Project, $SandboxLocation, $BuildSandbox,
      $Revision, $User, $Password, $Label,
      $StepDescription, $SCMCmdLine,  );
$Project = '';
$SandboxLocation = '';
$Revision = '';
$BuildSandbox = 0;
$User = '';
$Password = '';
$SCMCmdLine = "";

#-- Get the arguments from the command line
#
&Getopt::Long::Configure("bundling","pass_through"); 
&GetOptions( "U=s" => \$User,
             "P=s" => \$Password,
             "l=s" => \$Label
           );
          
#-- create any necessary changes to the $Label
if ( $Label =~ s/%DATE$// )
{
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time); 
 $year -= 100; 
 $Label = sprintf ( "%s%2.2d%2.2d%2.2d", $Label, $year, $mon+1, $mday);
}
           
#-- determine user and password to pass to si
if ( $User && $Password )
{
 my $siuserpass = " --user=$User --password=\"$Password\" ";
 $SCMLabelCmd  .= $siuserpass;
 $SCMMemberCmd .= $siuserpass;
}
else
{
 $RC = 1;
 #-- use omlogger
 $StepDescription = "OMSIEEPOST: Must specify user and password\n";
 &omlogger("Intermediate",$StepDescription,"FAILED",$StepDescription,$SCMCmdLine,"","",$RC, $StepDescription);
 goto EndOfScript;
}

#-- parse the BillOfMaterials
unless ( -e $OMBOMRPT )
{
 $StepDescription = "Error: omsieepost: Cannot find OMBOMRPT $OMBOMRPT\n";
 &omlogger("Intermediate",$StepDescription,"FAILED",$StepDescription,"","","",1, $StepDescription);
 goto EndOfScript;
}
my $ombom = Openmake::ParseBOM->new($OMBOMRPT);

#-- get list of files in BOM
my @files = $ombom->getFiles;

#-- print logging info
$StepDescription = "OMSIEEPOST: Executing si addlabel --label=\"$Label\"\n";
&omlogger("Intermediate",$StepDescription,"","","","","",0,$StepDescription);

#-- loop over files, find revision info and archive info
foreach my $file ( @files )
{
 my $vertool = $ombom->getVersionInfo( $file);
 $vertool =~ s/^\s+//;
 $vertool =~ s/\s+$//;
 
 #-- split this up.
 my @temp = split /\s+/, $vertool;
 my ( $project, $rev, $author, @labels );
 
 #-- join the first items up until we reach the .pj
 $_ = "";
 while ( $_ !~ /\.pj$/ && @temp )
 {
  $_ = shift @temp;
  $project .= "$_";
  $project .= " " unless ( $_ =~ /\.pj$/ );
 }
 $rev = shift @temp;
 $author = shift @temp;
 @labels = @temp;
 
 $file =~ s/\\/\//g;
 if ( $rev )
 {

  my $member = &SIGetMember( $file);
 
  #-- label this revision
  $SCMCmdLine = $SCMLabelCmd . " --project=\"$project\" --revision=\"$rev\" --label=\"$Label\" \"$member\"";
  $SCMCmdLine .= " 2>&1";

  my @out = `$SCMCmdLine`;
  $RC = $?;
  $StepDescription = "\t$file";
  if ( $RC ) 
  {
   omlogger("Intermediate",$StepDescription,"ERROR:","ERROR: $StepDescription failed!",$SCMCmdLine,"","",$RC,"", "$StepDescription failed!", @out);
  }
  else
  {
   omlogger("Intermediate",$StepDescription,"ERROR:","$StepDescription succeeded.",$SCMCmdLine,"","",$RC,$StepDescription);
  }
 }
}

EndOfScript:
$RC;

sub SIGetMember
{
 #-- determine sandbox for this guy
 my $file = shift;
 
 my $scm = $SCMMemberCmd . "\"$file\" 2>&1";
 my @out = `$scm`;
 my $line = join "", @out;
 $line =~ /\s*Sandbox Name:\s+(.+?\.pj)\s+/ ;
 my $sandbox = $1;
 $line =~ /\s*Member Name:\s*(.+)/ ;
 my $member = $1;

 $member =~ s/\\/\//g;
 $sandbox =~ s/\\/\//g;
 
 my @temp = split "/", $sandbox;
 pop @temp;
 my $sandboxpath = ( join "/", @temp ) . "/";
 my $esbp = $sandboxpath;
 $esbp =~ s|\/|\\\/|g;
 $member =~ s/^$esbp//;
 
 return $member;
}