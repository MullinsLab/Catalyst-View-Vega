# NAME

Catalyst::View::Vega - A Catalyst view for pre-processing Vega specs

# SYNOPSIS

    # In YourApplication.pm
    #
    YourApplication->config(
        'View::Vega' => {
            path => YourApplication->path_to("root/vega")->stringify,
        }
    );

    # In a controller action
    #
    my $vega = $c->view('Vega');
    $vega->specfile('patient-chart.json');
    $vega->bind_data({
        "patient"     => [{
            id   => $patient->id,
            name => $patient->name,
        }],
        "medications" => [ $meds->all ],
        "samples"     => [ $samples->all ],
    });
    $c->detach($vega);

# DESCRIPTION

This class lets you bind data to the datasets declared in a
[Vega](https://vega.github.io/vega/) spec and output the spec with the bound
data inlined.  This is useful for inlining data dynamically without using a
templating library.  Inlining data reduces request overhead and creates
standalone Vega specs which can be rendered as easily offline as they are
online.

A new instance of this view is created for each request, so it is safe to set
attributes and use the view's API in multiple controllers or actions.  Each new
view instance is based on the application's global instance of the view so that
initial attribute values are from your application config.

# ATTRIBUTES

## json

Read-only.  Object with `encode` and `decode` methods for reading and writing
JSON.  Defaults to:

    JSON::MaybeXS->new->utf8->convert_blessed->canonical->pretty

You can either set this at application start time via ["config" in Catalyst](https://metacpan.org/pod/Catalyst#config):

    YourApplication->config(
        'View::Vega' => {
            json => ...
        }
    );

or pass it in during the request-specific object construction:

    my $vega = $c->view("Vega", json => ...);

## path

Read-only.  Filesystem path under which ["specfile"](#specfile)s are located.  Usually set
by your application's config file or via ["config" in Catalyst](https://metacpan.org/pod/Catalyst#config), e.g.:

    YourApplication->config(
        'View::Vega' => {
            path => YourApplication->path_to("root/vega")->stringify,
        }
    );

## specfile

Read-write.  A file relative to ["path"](#path) which contains the Vega spec to
process.  Usually set in your controller's actions.

# METHODS

## bind\_data

Takes a hashref or list of key-value pairs and merges them into the view
object's dataset bindings.

Keys should be dataset names which match those in the Vega ["specfile"](#specfile).  Any
existing binding in this view for a given dataset name is overwritten.

Values may be either references or strings.  References are serialized and
inlined as the `values` dataset property.  Strings are serialized as the
`url` property, which allows you to dynamically reference external datasets.
See [Vega's documentation on dataset properties](https://github.com/vega/vega/wiki/Data#data-properties)
for more details on the properties themselves.

Note that Vega expects the `values` property to be an array, although this
view does not enforce that.  Make sure your references are arrayrefs or objects
that serialize to an arrayref.

Returns nothing.

## unbind\_data

Takes a dataset name as the sole argument and deletes any data bound in the
view object for that dataset.  Returns the now unbound data, if any.

## process\_spec

Returns the Vega specification as a Perl data structure, with bound data
inlined into the spec.

## process

Sets up up a JSON response using the results of ["process\_spec"](#process_spec).  You should
usually call this implicitly via ["detach" in Catalyst](https://metacpan.org/pod/Catalyst#detach) using the idiom:

    my $vega = $c->view("Vega");
    ...
    $c->detach($vega);

This is the most "viewish" part of this class.

# AUTHOR

Thomas Sibley <trsibley@uw.edu>

# THANKS

Thanks to Evan Silberman <silby@uw.edu> for suggesting dynamic inlining
of datasets.

# COPYRIGHT

Copyright 2016- by the University of Washington

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

- [Vega data specs](https://github.com/vega/vega/wiki/Data)
- [Vega documentation](https://github.com/vega/vega/wiki/Documentation)
- [Vega](https://vega.github.io/vega/)
