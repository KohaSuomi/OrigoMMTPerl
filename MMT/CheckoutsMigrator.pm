package MMT::CheckoutsMigrator;

use Modern::Perl;

use YAML::XS;

use MMT::Repository::AuthoritiesRepository;
use MMT::Repository::ArrayRepository;
use MMT::Util::Common;
use MMT::Util::CSVStreamer;
use MMT::Objects::Checkout;

my $startTime = time();

=head CheckoutsMigrator

=head SYNOPSIS

=cut

sub new {
    my ($class, $params) = @_;
    my $self = {};
    bless $self, $class;

    my $config = $CFG::CFG;

    $self->{verbose} = 0 unless $params->{verbose} || $config->{verbose};
    $self->{_config} = $config;

    return $self;
}

sub run {
    my ($self) = @_;

    print "\n\n".MMT::Util::Common::printTime($startTime)." CheckoutsMigrator - Starting\n\n";

    open(my $objOut, ">:encoding(utf8)", $CFG::CFG->{targetDataDirectory}."Laina.migrateme") or die "$!";
    my $csvStreamer = MMT::Util::CSVStreamer->new($CFG::CFG->{origoValidatedBaseDir}."Laina.csv",
                                                  '<');

    while (my $row = $csvStreamer->next()) {
        print MMT::Util::Common::printTime($startTime)." CheckoutsMigrator - ".($csvStreamer->{i}+1)."\n" if $csvStreamer->{i} % 1000 == 999;
        my $object = MMT::Objects::Checkout->constructor($self, $row);

        print $objOut $object->toString()."\n";
        $object->DESTROY(); #Prevent memory leaking.
    }
    $csvStreamer->close();
    close($objOut);

    print "\n\n".MMT::Util::Common::printTime($startTime)." CheckoutsMigrator - Complete\n\n";
}

1;