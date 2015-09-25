package MMT::BibliosMigrator;

use Modern::Perl;

use YAML::XS;

use MMT::Repository::AuthoritiesRepository;
use MMT::Repository::MarcRepository;
use MMT::Biblios::MarcRepair;
use MMT::Util::MARCXMLReader;
use MMT::Util::Common;
use MMT::MARC::Printer;


my %available001; #Collect available component parent ID's here so we can verify that 773$w points somewhere.
my %linking773w; #Collect component part record id's and their parent references here.
my $startTime = time();

=head BibliosMigrator

=head SYNOPSIS

Merges data outside the MARC record to the MARC record. Validates link relations.
Extracts markers needed for Items migration.

=cut

sub new {
    my ($class, $params) = @_;
    my $self = {};
    bless $self, $class;

    my $config = $CFG::CFG;

    $self->{verbose} = 0 unless $params->{verbose} || $config->{verbose};
    $self->{_config} = $config;

    $self->{repositories}->{Teos} = MMT::Repository::AuthoritiesRepository->createRepository(filePath => $CFG::CFG->{origoValidatedBaseDir}.'/Teos.csv',
                                                                        pk => 0,
                                                                        columns => [1,'itype',2,'mod',5,'add']);
    $self->{repositories}->{MarcRepository} = MMT::Repository::MarcRepository->createRepository('>'); #Open the repo for writing

    return $self;
}

sub run {
    my ($self) = @_;

    print "\n\n".MMT::Util::Common::printTime($startTime)." BibliosMigrator - Starting\n\n";
    MMT::MARC::Printer::startCollection();

    my $i = 0;
    my $count = 0;
    while (my $record = $self->nextXML()) {
        $i++;
        next if ($CFG::CFG->{Biblios}->{skip} && $CFG::CFG->{Biblios}->{skip} >= $i);
        last if ($CFG::CFG->{Biblios}->{count} && $CFG::CFG->{Biblios}->{count} >= $count);

        print MMT::Util::Common::printTime($startTime)." BibliosMigrator - ".($i+1)."\n" if $i % 1000 == 999;
        $self->handleRecord($i, $record);
        if (MMT::Biblios::MarcRepair::run($record)) {
            MMT::MARC::Printer::writeRecord($record);
        }
        $self->{repositories}->{MarcRepository}->put($record);
        $record->DESTROY(); #Prevent memory leaking.
        $count++;
    }
    MMT::MARC::Printer::endCollection();

    $self->validateLinkRelations();
    print "\n\n".MMT::Util::Common::printTime($startTime)." BibliosMigrator - Complete\n\n";
}

sub nextXML {
    my ($self) = @_;

    unless($self->{marcxmlReader}) {
        $self->{marcxmlReader} = MMT::Util::MARCXMLReader->new({sourceFile => $self->{_config}->{origoValidatedBaseDir}.
                                                                              $self->{_config}->{Biblios}->{UsemarconTarget}
                                                            });
    }
    return $self->{marcxmlReader}->next();
}

sub handleRecord {
    my ($self, $i, $record) = @_;

    my $id = $record->getUnrepeatableSubfield('001','a');
    unless ($id) {
        warn "No Field 001 for Record number $i\n";
        return undef;
    }
    $id = $id->content();

    #Save Record's ID and possible linking targets, so we can validate them.
    $available001{$id} = 1;
    if (my $cParentId = $record->getComponentParentDocid()) {
        $linking773w{$id} = $cParentId;
    }

    my $repoEntry = $self->{repositories}->{Teos}->fetch($id);
    if ($repoEntry) {
        my $lastModificationDate = $self->{repositories}->{Teos}->fetch($id, undef, 'mod');
        my $addDate = $self->{repositories}->{Teos}->fetch($id, undef, 'add');
        my $itemType = $self->{repositories}->{Teos}->fetch($id, undef, 'itype');

        $record->materialType($itemType);
        $record->dateReceived($addDate);
        $record->modTime($lastModificationDate);
    }
    else {
        print "    for Record '".$record->docId()."'\n";
    }
}

sub validateLinkRelations {
    my ($self) = @_;

    print "\n\n".MMT::Util::Common::printTime($startTime)." BibliosMigrator - Validating link relations\n\n";
    while (my ($componentPartId, $componentParentId) = each(%linking773w)) {
        unless($available001{$componentParentId}) {
            print "Component part '$componentPartId' doesn't have a component parent!\n"
        }
    }
}
1;
