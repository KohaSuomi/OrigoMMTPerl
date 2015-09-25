package MMT::Repository::MarcRepository;

use Modern::Perl;

use MMT::Repository::ArrayRepository;

use base qw(MMT::Repository::ArrayRepository);

my $filename = "TranslationTables/MarcRepository.csv";
sub createRepository {
    my ($class, $ioOp) = @_;
    return $class->SUPER::createRepository({filename => $filename, ioOp => $ioOp});
}

sub prepareData {
    my ($self, $r) = @_;

    my $pk = $r->docId;

    my $signum = $r->signum();
    my $materialType = $r->materialType();

    $signum = 'NO SIGNUM' if !(defined($signum));
    $materialType = 'NO ITYPE' if !(defined($materialType));

    return [$pk, $signum, $materialType];
}