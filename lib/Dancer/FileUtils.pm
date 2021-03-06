package Dancer::FileUtils;

use strict;
use warnings;

use File::Basename ();
use File::Spec;
use Carp;
use Cwd 'realpath';

use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw(path dirname read_file_content read_glob_content open_file);

# Undo UNC special-casing catfile-voodoo on cygwin in the next three functions
sub d_catfile {
    my $root = shift;
    $root =~ s{^[/\\]+([/\\])}{$1};
    File::Spec->catfile($root, @_);
}
sub d_catdir {
    my $root = shift;
    $root =~ s{^[/\\]+([/\\])}{$1};
    File::Spec->catdir($root, @_);
}
sub d_canonpath {
    my $root = shift;
    $root =~ s{^[/\\]+([/\\])}{$1};
    File::Spec->canonpath($root, @_);
}

sub path { d_catfile(@_) }

sub path_no_verify {
    my @nodes = @_;
    my $path = '';

    # [0->?] path(must exist),[last] file(maybe exists)
    if($#nodes > 0) {
        $path = realpath(d_catdir(@nodes[0 .. ($#nodes - 1)])).'/';
    } elsif(not File::Spec->file_name_is_absolute($nodes[0])) {
        $path = Cwd::cwd.'/';
    }
    $path .= d_canonpath($nodes[$#nodes]);
    return $path;
}

sub dirname { File::Basename::dirname(@_) }

sub open_file {
    my ($mode, $filename) = @_;
    require Dancer::Config;
    my $charset = Dancer::Config::setting('charset');
    length($charset || '')
      and $mode .= ":encoding($charset)";
    open(my $fh, $mode, $filename)
      or croak "$! while opening '$filename' using mode '$mode'";
    return $fh;
}

sub read_file_content {
    my ($file) = @_;
    my $fh;

    if ($file) {
        $fh = open_file('<', $file);

        return wantarray ? read_glob_content($fh) : scalar read_glob_content($fh);
    }
    else {
        return;
    }
}

sub read_glob_content {
    my ($fh) = @_;

    # we don't want to do that as we'll encode the stuff later
    # binmode $fh;

    my @content = <$fh>;
    close $fh;

    return wantarray ? @content : join("", @content);
}

'Dancer::FileUtils';

__END__

=pod

=head1 NAME

Dancer::FileUtils - helper providing file utilities

=head1 SYNOPSIS

    use Dancer::FileUtils qw/path read_file_content/;

    my $content = read_file_content( path( 'folder', 'folder', 'file' ) );
    my @content = read_file_content( path( 'folder', 'folder', 'file' ) );

=head1 DESCRIPTION

Dancer::FileUtils includes a few file related utilities related that Dancer
uses internally. Developers may use it instead of writing their own
file reading subroutines or using additional modules.

=head1 SUBROUTINES/METHODS

=head2 open_file

    use Dancer::FileUtils 'open_file';
    my $fh = open_file('<', $file) or die $message;

Calls open and returns a filehandle. Takes in account the 'charset' setting to
open the file in the proper encoding.

=head2 path

    use Dancer::FileUtils 'path';

    my $path = path( 'folder', 'folder', 'filename');

Provides comfortable path resolving, internally using L<File::Spec>.

=head2 dirname

    use Dancer::FileUtils 'dirname';

    my $dir = dirname($path);

Exposes L<File::Basename>'s I<dirname>, to allow fetching a directory name from
a path.

=head2 read_file_content

    use Dancer::FileUtils 'read_file_content';

    my $content = read_file_content($file);
    my @content = read_file_content($file);

Returns either the content of a file (whose filename is the input), I<undef>
if the file could not be opened.

In array context it returns each line (as defined by $/) as a seperate element
Scalar context returns the entire contents of the file.

=head2 read_glob_content

    use Dancer::FileUtils 'read_glob_content';

    open my $fh, '<', $file or die "$!\n";
    my $content = read_glob_content($fh);
    my @content = read_glob_content($fh);

Same as I<read_file_content>, only it accepts a file handle.

Returns the content and B<closes the file handle>.

=head1 EXPORT

Nothing by default. You can provide a list of subroutines to import.

=head1 AUTHOR

Alexis Sukrieh

=head1 LICENSE AND COPYRIGHT

Copyright 2009-2010 Alexis Sukrieh.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

