package Catalyst::View::Vega::Lite;
use strict;
use warnings;
use utf8;
use 5.008_005;

use Moose;
use Types::Standard qw< :types >;
use namespace::autoclean;

=encoding utf-8

=head1 NAME

Catalyst::View::Vega::Lite - A Catalyst view for pre-processing Vega-Lite specs

=head1 DESCRIPTION

A subclass of L<Catalyst::View::Vega> intended for Vega-Lite specs which can
only have a single dataset.

See L<Catalyst::View::Vega> for more information.

=cut

extends 'Catalyst::View::Vega';

=head1 METHODS

All the methods of L<Catalyst::View::Vega> are available, and differences are
documented below.

=head2 bind_data

Takes a single value, either a reference of a string.  References are
serialized and inlined as the C<values> dataset property.  Strings are
serialized as the C<url> property, which allows you to dynamically reference
external datasets.  See L<Vega-Lite's documentation on dataset properties|https://vega.github.io/vega-lite/docs/data.html>
for more details on the properties themselves.

Note that Vega-Lite expects the C<values> property to be an array, although this
view does not enforce that.  Make sure your references are arrayrefs or objects
that serialize to an arrayref.

Returns nothing.

=head2 unbind_data

Deletes the bound data in the view object.  Returns the now unbound data, if
any.

=cut

has _data => (
    is      => 'rw',
    isa     => Maybe[ Ref | Str ],
    default => sub { undef },
);

sub bind_data {
    my $self = shift;
    $self->_data($_[0])
        if @_;
    return;
}

sub unbind_data {
    my $self = shift;
    my $data = $self->_data;
    $self->_data(undef);
    return $data;
}

sub process_spec {
    my $self = shift;
    my $spec = $self->read_specfile;
    my $data = $self->_data;

    # Inject bound data into the Vega-Lite spec either as URLs or inline values
    $spec->{data} = { (ref($data) ? 'values' : 'url') => $data }
        if defined $data;

    return $spec;
}

1;
__END__

=head1 AUTHOR

Thomas Sibley E<lt>trsibley@uw.eduE<gt>

=head1 COPYRIGHT

Copyright 2017- by the University of Washington

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
