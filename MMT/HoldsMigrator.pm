package MMT::HoldsMigrator;

use Modern::Perl;

use MMT::Util::Common;
use MMT::Util::CSVStreamer;
use MMT::Objects::Hold;

my $startTime = time();

=head HoldsMigrator

=head SYNOPSIS

=cut

sub new {
    my ($class, $params) = @_;
    my $self = {};
    bless $self, $class;

    my $config = $CFG::CFG;

    $self->{verbose} = 0 unless $params->{verbose} || $config->{verbose};
    $self->{_config} = $config;

    $self->{repositories}->{Varausrivi} = MMT::Repository::ArrayRepository->createRepository({filename => $config->{origoValidatedBaseDir}.'Varausrivi.csv', ioOp => '<', pkColumn => 0});

    return $self;
}

sub run {
    my ($self) = @_;

    print "\n\n".MMT::Util::Common::printTime($startTime)." HoldsMigrator - Starting\n\n";

    open(my $objOut, ">:encoding(utf8)", $CFG::CFG->{targetDataDirectory}."Varaus.migrateme") or die "$!";
    my $csvStreamer = MMT::Util::CSVStreamer->new($CFG::CFG->{origoValidatedBaseDir}."Varaus.csv",
                                                  '<');

    while (my $row = $csvStreamer->next()) {
        print MMT::Util::Common::printTime($startTime)." HoldsMigrator - ".($csvStreamer->{i}+1)."\n" if $csvStreamer->{i} % 1000 == 999;
        my $object = MMT::Objects::Hold->constructor($self, $row);

        print $objOut $object->toString()."\n";
        $object->DESTROY(); #Prevent memory leaking.
    }
    $csvStreamer->close();
    close($objOut);

    print "\n\n".MMT::Util::Common::printTime($startTime)." HoldsMigrator - Complete\n\n";
}

1;
