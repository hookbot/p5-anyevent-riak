package AnyEvent::Riak;

# ABSTRACT: AnyEvent ProtocolBuffers Riak Client

use 5.012;
use strict;
use warnings;
use AnyEvent::Riak::PBC;
use Types::Standard -types;
use Carp;
require bytes;
use Moo;

use AnyEvent::Handle;

my $message_codes = {
  RpbErrorResp => 0,
  RpbPingReq => 1,
  RpbPingResp => 2,
  RpbGetClientIdReq => 3,
  RpbGetClientIdResp => 4,
  RpbSetClientIdReq => 5,
  RpbSetClientIdResp => 6,
  RpbGetServerInfoReq => 7,
  RpbGetServerInfoResp => 8,
  RpbGetReq => 9,
  RpbGetResp => 10,
  RpbPutReq => 11,
  RpbPutResp => 12,
  RpbDelReq => 13,
  RpbDelResp => 14,
  RpbListBucketsReq => 15,
  RpbListBucketsResp => 16,
  RpbListKeysReq => 17,
  RpbListKeysResp => 18,
  RpbGetBucketReq => 19,
  RpbGetBucketResp => 20,
  RpbSetBucketReq => 21,
  RpbSetBucketResp => 22,
  RpbMapRedReq => 23,
  RpbMapRedResp => 24,
  RpbIndexReq => 25,
  RpbIndexResp => 26,
  RpbSearchQueryReq => 27,
  RbpSearchQueryResp => 28,
  RpbResetBucketReq => 29,
  RpbResetBucketResp => 30,
  RpbGetBucketTypeReq => 31,
  RpbSetBucketTypeResp => 32,
  RpbCSBucketReq => 40,
  RpbCSUpdateReq => 41,
  RpbCounterUpdateReq => 50,
  RpbCounterUpdateResp => 51,
  RpbCounterGetReq => 52,
  RpbCounterGetResp => 53,
  RpbYokozunaIndexGetReq => 54,
  RpbYokozunaIndexGetResp => 55,
  RpbYokozunaIndexPutReq => 56,
  RpbYokozunaIndexPutResp => 57,
  RpbYokozunaSchemaGetReq => 58,
  RpbYokozunaSchemaGetResp => 59,
  RpbYokozunaSchemaPutReq => 60,
  DtFetchReq => 80,
  DtFetchResp => 81,
  DtUpdateReq => 82,
  DtUpdateResp => 83,
  RpbAuthReq => 253,
  RpbAuthResp => 254,
  RpbStartTls => 255,
};

=head1 SYNOPSIS

  use AnyEvent::Riak;
  my $cv1 = AE::cv;
  my $client = AnyEvent::Riak->new(
    on_connect       => sub { $cv1->send },
    on_connect_error => sub { $cv1->croak($_[1])},
  );

  my $cv2
  $client->put({ bucket  => 'bucket_name',
                 key     => 'key_name',
                 content => { value => 'plip',
                              content_type => 'text/plain',
                            },
               },
               sub {
                   my ($result, $error) = @_;
                   $error and $cv2->croak(
                     sprintf("error %d: %s",
                     @{$error}{qw(error_code error_message)})
                   );
                   $cv2->send($result);
               });

  my $put_result = $cv2->recv();

  my $cv3 = AE::cv;
  $client->get({ bucket => 'bucket_name',
                 key => 'key_name',
               },
               sub {
                   my ($result, $error) = @_;
                   $error and $cv3->croak(
                     sprintf("error %d: %s",
                     @{$error}{qw(error_code error_message)})
                   );
                   $cv3->send($result);
               });

  my $get_result = $cv3->recv();

=head1 DOCUMENTATION

The exhaustive documentation, is to be found here:

L<AnyEvent::Riak::Documentation>

=attr host => $hostname

Str, Required. Riak IP or hostname. Default to 127.0.0.1

=attr port => $port_number

Int, Required. Port of the PBC interface. Default to 8087

=attr on_connect => $cb->($handle, $host, $port, $retry->())

CodeRef, required. Executed on connection. Check out
L<AnyEvent::Handle#on_connect-cb--handle-host-port-retry>

=attr on_connect_error => $cb->($handle, $message)

CodeRef, required. Executed when the connection could not be established. Check out
L<AnyEvent::Handle#on_connect_error-cb--handle-message>

=attr connect_timeout => $fractional_seconds

Float, Default 5. Timeout for connection operation, in seconds. Set to 0 for no timeout.

=attr timeout => $fractional_seconds

Float, Default 5. Timeout for read/write operation, in seconds. Set to 0 for no timeout.

=attr no_delay => <boolean>

Boolean, Default 0. If set to a true value, TCP_NODELAY will be enabled on the
socket, which means deactivating Nagle's algorithm. Use only if you know what
you're doing.

=cut

has host                => ( is => 'ro', isa => Str,  default => sub { '127.0.0.1'} );
has port                => ( is => 'ro', isa => Int,  default => sub { 8087 } );
has on_connect          => ( is => 'ro', isa => CodeRef,  required => 1 );
has on_connect_error    => ( is => 'ro', isa => CodeRef,  required => 1 );
has connect_timeout     => ( is => 'ro',                 isa => Num,  default  => sub {5} );
has timeout             => ( is => 'ro',                 isa => Num,  default  => sub {5} );
has no_delay            => ( is => 'ro',                 isa => Bool, default  => sub {0} );

has _handle => ( is => 'ro', lazy => 1, clearer => 1, builder => sub {
    my ($self) = @_;
    my ($host, $port) = ($self->host, $self->port);

    my $on_connect = $self->on_connect;
    my $on_connect_error = $self->on_connect_error;
    my $c_timeout = $self->connect_timeout;
    my $no_delay = $self->no_delay;

    AnyEvent::Handle->new (
      connect  => [$host, $port],
      no_delay => $no_delay,
      on_connect => $on_connect,
      on_connect_error => $on_connect_error,
      on_prepare => sub { $c_timeout },
      on_error => sub { my ($handle, $fatal, $message) = @_;
                        croak "Panic: no special on_error has been set yet! error: $message"; },
    );

});


sub BUILD {
    my ($self) = @_;
    $self->_handle();
}

=method $client->close($cb)

This method will wait until everything has been written to the connection, then
close the connection, and then calls the callback without parameters. Use this
to properly close the connection, before destroying the client instance.

=cut

sub close {
    my ($self, $callback) = @_;
    defined $callback && ref($callback) eq 'CODE'
      or croak "last parameter must be a CoderRef callback";
    $self->_handle->on_drain( sub { shutdown($_[0]{fh}, 1); $self->_clear_handle(); $callback->(); } )
}

### Deal with common, general case, Riak commands
our $AUTOLOAD;

sub AUTOLOAD {
  my $command = $AUTOLOAD;
  $command =~ s/.*://;

  my $request_name  = 'Rpb' . ucfirst(_to_camel($command)) . 'Req';
  my $response_name = 'Rpb' . ucfirst(_to_camel($command)) . 'Resp';
  my $request_code  = $message_codes->{$request_name};
  my $response_code = $message_codes->{$response_name};
  defined $request_code && defined $response_code
    or croak "unknown method '$command'";

  my $method = sub { shift->_run_cmd($request_name, $request_code, $response_name, $response_code, @_) };

  # Save this method for future calls
  no strict 'refs';
  *$AUTOLOAD = $method;

  goto $method;
}

sub _run_cmd {
    my $callback = pop;
    defined $callback && ref($callback) eq 'CODE'
      or croak "last parameter must be a CoderRef callback";
    my ( $self, $request_name, $request_code, $response_name, $expected_response_code, $args ) = @_;

    my $body = '';
    if (defined $args) {
        eval { $body = "$request_name"->encode($args); 1 }
          or return $callback->(undef, { error_code => -1, error_message => $@ });
    };

    my $handle = $self->_handle;

    $handle->on_error(sub {
        my ($handle, $fatal, $message) = @_;
        $fatal or $handle->destroy(); # force destroy even if non fatal
        $callback->(undef, { error_code => $!,
                             error_message => $message }) });

    $handle->on_timeout(sub { $callback->(undef, { error_code => -1,
                                                   error_message => 'timeout' }) });
    $handle->push_write(  pack('N', bytes::length($body) + 1)
                        . pack('c', $request_code) . $body
                       );

    $handle->timeout_reset;
    $handle->timeout($self->timeout);
    $handle->push_read( chunk => 4, sub {
         my $len = unpack "N", $_[1];
         $handle->timeout_reset;
         $_[0]->unshift_read( chunk => $len, sub {
             my ( $response_code, $response_body ) = unpack( 'c a*', $_[1] );
             $handle->timeout(0);

             if ($response_code == $message_codes->{RpbErrorResp}) {
                 my $decoded_message = RpbErrorResp->decode($response_body);
                 return $callback->(undef, { error_code => $decoded_message->errcode,
                                             error_message => $decoded_message->errmsg });
             }

             if ($response_code != $expected_response_code) {
                 return $callback->(undef, {
                   error_code => -2,
                   error_message =>   "wrong response (got: '$response_code', "
                                    . "expected: '$expected_response_code')" });
             }

             my ($ret, $more_to_come) = ( 1, );
             my $result = $response_name->decode($response_body);
             return $callback->($result);
         });
     });

}

sub _to_camel {
    $_[0] =~ s/_([a-z])/uc($1)/rge;
}

1;
