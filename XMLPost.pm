#******************************************************************************
#*           
#*                         Gellyfish Software                  
#*                                                       
#*
#******************************************************************************
#*
#*          PROGRAM      :   CGI::XMLPost
#*
#*          AUTHOR       :   JNS
#*
#*          DESCRIPTION  :   Specialized POST only CGI library for XML
#*
#*****************************************************************************
#*
#*          $Log: XMLPost.pm,v $
#*          Revision 1.2  2002/05/26 12:59:15  gellyfish
#*          Version updated to CPAN
#*
#*          Revision 1.1.1.1  2002/05/26 12:54:36  gellyfish
#*          Import version prior to uploading
#*
#*
#*
#*****************************************************************************/ 

package CGI::XMLPost;

use strict;

use Carp;

use vars qw($VERSION);

($VERSION) = q$Revision: 1.2 $ =~ /([\d.]+)/;

# Ripped off from CGI.pm

use vars qw($CRLF);

my $EBCDIC = "\t" ne "\011";

if ($^O eq 'VMS') 
{
  $CRLF = "\n";
} 
elsif ($EBCDIC) 
{
  $CRLF= "\r\n";
} 
else 
{
  $CRLF = "\015\012";
}

=head1 NAME

CGI::XMLPost - receive XML file as an HTTP POST

=head1 SYNOPSIS

   use CGI::XMLPost;

   my $xmlpost = CGI::XMLPost->new();

   my $xml = $xmlpost->data();

   # ... do something with $xml

=head1 DESCRIPTION

CGI::XMLPost is a lightweight module for receiving XML documents in the
body of an HTTP request.  It provides some utility methods that make it
easier to work in a CGI environment without requiring any further modules.

=head1 METHODS


=over 4

=cut


=item new

This is the constructor of the class.  If it succeeds in reading the POST
data correct it will return a a blessed object - otherwise undef.

The arguments are in the form of a hash reference - the keys are :

=over 2

=item strict

If this is set to a true value then the HTTP request method and content type
are checked.  If the first is not POST and the second does not match 'xml$'
then the method will return undef.

=back

=cut

sub new
{
   my ( $proto, $args ) = @_;

   my $class = ref($proto) || $proto;

   
   my $self = bless {}, $class;

   if ( $args->{strict} )
   {
      if ( $self->request_method() ne 'POST' or $self->content_type !~ /xml$/ )
      {
         return undef;
      }
   }

   my $cl = $self->content_length();

   if ( read( STDIN, $self->{_data}, $cl) == $cl )
   {
      return $self;
   }
}

=item content_type

Returns the content type of the HTTP request.

=cut

sub content_type
{
    my ( $self ) = @_;

    return $ENV{CONTENT_TYPE};
}

=item request_method

Returns the request method of the HTTP request.

=cut

sub request_method
{
   my ( $self ) = @_;

   return $ENV{REQUEST_METHOD};
}


=item content_length

Returns the content length of the request.

=cut

sub content_length
{
   my ( $self ) = @_;

   return $ENV{CONTENT_LENGTH};
}

=item data

Returns the data as read from the body of the HTTP request.

=cut

sub data
{
   my ( $self ) = @_;

   return $self->{_data};
}

=item header

Returns a header suitable to be used in an HTTP response.  The arguments are
in the form of key/value pairs - valid keys are :

=over 2

=item status

The HTTP status code to be returned - the default is 200 (OK).

=item type

The content type of the response - the default is 'application/xml'.

=back

=cut

sub header
{
   my ( $self, %args ) = @_;

   my @header;

   $self->{status} = $args{status} || 200;

   push @header, "Status: $self->{status}";

   $self->{type} = $args{type}   || 'application/xml';

   push @header, "Content-Type: $self->{type}";   

   my $header = join $CRLF, @header;

   $header .= $CRLF x 2;

   return $header;

}

my %status_codes = (
                     200 => "OK",
                     405 => "Method Not Allowed",
                     415 => "Unsupported Media Type",
                     400 => "Bad Request",
                    );

=item response

Returns a string that is suitable to be sent in the body of the response.
The default is to return an XML string of the form :

       <?xml version="1" encoding="iso-8859-1"?>
       <Response>
         <Code>$status</Code>
         <Text>$text</Text>
       </Response>
   
Where $status is the status code used in the header as described above and
$text is the desciptive text for that status.  If a different text is required
this can be supplied with the argument key 'text'.

=cut

sub response
{
   my ( $self, %args ) = @_;

   my $status = $self->{status} || 200;
   my $text = $args{text} || $status_codes{$status};

   my $type = $self->{type} || 'application/xml';

   my $response;

   if ( $type =~ /xml$/i )
   {
     $response =<<EOX;
<?xml version="1" encoding="iso-8859-1"?>
<Response>
  <Code>$status</Code>
  <Text>$text</Text>
</Response>
EOX
   }
   else
   {
     $response = $text;
   }   
   return $response;
}

=item remote_address

Remotes the address of the remote peer if it is known.

=cut

sub remote_address
{
    my ( $self ) = @_;
    return $ENV{REMOTE_ADDRESS};
}

1;
__END__

=back

=head1 AUTHOR

Jonathan Stowe <jns@gellyfish.com>

=head1 SEE ALSO

CGI

=head1 LICENSE

Please see the README file in the source distribution for the licence of this
module.

=cut

