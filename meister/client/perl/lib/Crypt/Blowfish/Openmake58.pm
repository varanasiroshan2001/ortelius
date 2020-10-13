# This file was automatically generated by SWIG
package Crypt::Blowfish::Openmake58;
require Exporter;
require DynaLoader;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
@ISA = qw(Exporter DynaLoader);


package Crypt::Blowfish::Openmake58c;
bootstrap Crypt::Blowfish::Openmake58;

package Crypt::Blowfish::Openmake58;

#-- Items to export into callers namespace by default
@EXPORT =	qw();

#-- Other items we are prepared to export if requested
@EXPORT_OK =	qw(
	blocksize keysize min_keysize max_keysize
	new encrypt decrypt
);

$VERSION = '1.00';

# ---------- BASE METHODS -------------

use strict;
use Carp;

sub usage
{
 my ($package, $filename, $line, $subr) = caller(1);
	$Carp::CarpLevel = 2;
	croak "Usage: $subr(@_)"; 
}

sub blocksize   {  8; } # /* byte my shiny metal.. */
sub keysize     {  0; } # /* we'll leave this at 8 .. for now.  expect change. */
sub min_keysize {  8; }
sub max_keysize { 56; }  

sub new
{
	my $type = shift; my $self = {}; bless $self, $type;
 my $key = shift;
 my $len = length($key);
 #-- keysize is ignored
 Crypt::Blowfish::Openmake58::omInitializeBlowfish( );

	$self;
}

sub encrypt
{
	usage("encrypt data[8 bytes]") unless @_ == 2;

	my $self = shift;
	my $data = shift;

 my $return = ' 'x8;
 Crypt::Blowfish::Openmake58::omcipher( 0, $data, $return );
 return $return;
}

sub decrypt
{
	my $self = shift;
	my $data = shift;

 my $return = ' 'x8;
 Crypt::Blowfish::Openmake58::omcipher( 1, $data, $return );
 return $return;
}

#--- Generated by SWIG

sub TIEHASH {
    my ($classname,$obj) = @_;
    return bless $obj, $classname;
}

sub CLEAR { }

sub FIRSTKEY { }

sub NEXTKEY { }

sub FETCH {
    my ($self,$field) = @_;
    my $member_func = "swig_${field}_get";
    $self->$member_func();
}

sub STORE {
    my ($self,$field,$newval) = @_;
    my $member_func = "swig_${field}_set";
    $self->$member_func($newval);
}

sub this {
    my $ptr = shift;
    return tied(%$ptr);
}


# ------- FUNCTION WRAPPERS --------

package Crypt::Blowfish::Openmake58;

*omInitializeBlowfish = *Crypt::Blowfish::Openmake58c::omInitializeBlowfish;
*omcipher = *Crypt::Blowfish::Openmake58c::omcipher;
*F = *Crypt::Blowfish::Openmake58c::F;
*Blowfish_encipher = *Crypt::Blowfish::Openmake58c::Blowfish_encipher;
*Blowfish_decipher = *Crypt::Blowfish::Openmake58c::Blowfish_decipher;

# ------- VARIABLE STUBS --------

package Crypt::Blowfish::Openmake58;

*MAXKEYBYTES = *Crypt::Blowfish::Openmake58c::MAXKEYBYTES;
*big_endian = *Crypt::Blowfish::Openmake58c::big_endian;
1;
