package Transliterator::JSONFactory;

use strict;
use warnings;
use JSON;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw(generateJSON);
$VERSION   = '0.01';

sub new {
	my $class = shift;
	my $TU    = shift;
	my $type  = shift;
	my $self  = {
		output => {},
		error  => {},
		TU     => $TU,
		type   => $type
	};
	bless $self, $class;
	return $self;
}

sub addError {
	my ( $self, $label, $output ) = @_;
	chomp $output;
	${ $self->{error} }{$label} = $output;
}

sub addOutput {
	my ( $self, $label, $output ) = @_;
	chomp $output;
	my %TU = %{ $self->{TU} };
	if ( $label eq 'wetenschappelijk' && exists $TU{$output} ) {
		${ $self->{output} }{'taalunie'} = $TU{$output};
	}
	elsif ( $label eq 'populair-duits' && $output =~ /[aeiouy]s[aeiouy]/i ) {
		$output =~ s/([aeiouy])s([aeiouy])/$1ss$2/ig
		  if ( $output !~ /Nowosibirsk/ );  ##Kan hier 'Nowosibirsk' uitsluiten.
	}
	${ $self->{output} }{$label} = $output;
}

sub getOutput {
	my ( $self, $label ) = @_;
	if ( exists ${ $self->{output} }{$label} ) {
		return ${ $self->{output} }{$label};
	}
	return '';
}

sub generateJSON {
	my ($self) = @_;
	my %output = ();
	$output{'type'} = $self->{type};
	$output{'recommended'} = $self->getVakAdvies();
	$output{'other'} = [];
	push @{$output{'other'}}, $self->getVakWereld();
	push @{$output{'other'}}, $self->getVakWetenschappelijk();
	push @{$output{'other'}}, $self->getVakKaarten() if ( $self->{type} eq 'L' );
	push @{$output{'other'}}, $self->getVakBibliotheken();
	push @{$output{'other'}}, $self->getVakPaspoorten() if ( ( $self->{type} ne 'L' ) and ( $self->{type} ne 'O' ) );
	push @{$output{'other'}}, $self->getVakGegevensuitwisseling();
	return encode_json \%output;
}

sub generateField {
	my ($id, $label, $value, $bullet, $external_link, $is_main) = @_;
	my $hash = { 'id' => $id, 'value' => $value, 'main' => $is_main };
	if (length($label) > 0) {
		$$hash{'label'} = $label;
	}
	if (length($bullet) > 0) {
		$$hash{'bullet'} = $bullet;
	}
	if (length($external_link) > 0) {
		$$hash{'external_link'} = $external_link;
	}
	return $hash;
}

sub getVakAdvies {
	my ($self) = @_;

	my ( $populair, $taalunie, $wiki ) = (
		$self->getOutput('populair'),
		$self->getOutput('taalunie'),
		$self->getOutput('wikipedia')
	);
	
	my $use_taalunie = ( length($taalunie) > 0 && $self->{type} eq 'L' ) ? 1 : 0;
	
	my %group = ();
	$group{'img'} = ($use_taalunie == 1) ? 'nederlands-taalunie1.png' : 'afbeeldingen/nederlands.png';
	$group{'fields'} = [];
	push @{$group{'fields'}}, ($use_taalunie == 1) ? [$self->generateField('nederlands','',$taalunie,'','','true'),$self->generateField('nederlands','',$populair,'','','true')] : [$self->generateField('nederlands','',$populair,'','','true')];
	push @{$group{'fields'}}, [$self->generateField('taalunie','',$taalunie,'','','false')] if $use_taalunie == 0 && length($taalunie) > 0;
	push @{$group{'fields'}}, [$self->generateField('wikipedia','',$wiki,'','','false')] if $use_taalunie == 0 && length($wiki) > 0;
	if ( $self->{type} eq 'L' ) {
		$group{'google_maps'} = ($use_taalunie == 1) ? $taalunie : $populair;
	}
	
	return \%group;
}

sub getVakWereld {
	my ($self) = @_;
	my $engels = $self->getOutput('populair-engels');
	my $group = {
		'img' => 'wereldbol-vlaggen.jpg',
		'fields' => [
			[$self->generateField('engels','',$engels,'','','false')],
			[$self->generateField('duits','',$self->getOutput('populair-duits'),'','','false')]
		]
	};
	my $bgn = $self->getOutput('BGN-PCGN-simpel');
	push @{$$group{'fields'}{'engels'}}, $bgn unless $engels eq $bgn;
	return $group;
}

sub getVakWetenschappelijk {
	my ($self) = @_;
	my $wetenschappelijk = $self->getOutput('wetenschappelijk');
	return if length($wetenschappelijk) == 0;
	return {
#		TODO: change img to id and rename images to match id (all images same format)
		'img' => 'wetenschap.png',
		'fields' => {
			'wetenschappelijk1' => [$self->generateField('wetenschappelijk1','',$wetenschappelijk,'','','true')],
			'ALA-LC' => [$self->generateField('ALA-LC','ALA-LC',$self->getOutput('ALA-LC'),'','','false')],
			'ALA-LC-simpel' => [$self->generateField('ALA-LC-simpel','ALA-LC (simple)',$self->getOutput('ALA-LC-simpel'),'','','false')]
		}
	};
}

sub getVakKaarten {
	my ($self) = @_;
	my $gost = $self->getOutput('GOST-1983');
	return if length($gost) == 0;
	return {
		'img' => 'kaart-rusland.jpg',
		'fields' => [
			[$self->generateField('GOST-1983','',$gost,'vn.jpg','','false')],
			[$self->generateField('taalunie','',$self->getOutput('taalunie'),'taalunie.png','','false')],
			[$self->generateField('BGN-PCGN','',$self->getOutput('BGN-PCGN'),'bgn-pcgn.png','','false')],
			[$self->generateField('GOST-2004','',$self->getOutput('GOST-2004'),'verkeersbord.jpg','','false')]
		]
	};
}

sub getVakBibliotheken {
	my ($self) = @_;
	my $wetenschappelijk = $self->getOutput('wetenschappelijk');
	return if length($wetenschappelijk) == 0;
	my $ala = $self->getOutput('ALA-LC');
	my $group = {
		'img' => 'bibliotheek.jpg',
		'fields' => [
			[$self->generateField('wetenschappelijk2','',$wetenschappelijk,'kb-nl.jpg','http://opc4.kb.nl/DB=1/SET=3/TTL=1/CMD?ACT=SRCHA&IKT=1016&SRT=YOP&TRM=' . $wetenschappelijk,'false')],
			[$self->generateField('ALA-LC','',$ala,'loc.jpg','http://catalog.loc.gov/vwebv/search?searchArg=' . $ala,'false')]
		]
	};
	my $bs = $self->getOutput('british-standard');
	if ($bs eq $ala) {
		push @{$$group{'fields'}}, [$self->generateField('british-standard-ALA-LC','',$ala,'bl.jpg','http://explore.bl.uk/primo_library/libweb/action/search.do?dscnt=1&tab=local_tab&vl(freeText0)=' . $ala,'false')];
	} else {
		push @{$$group{'fields'}}, [
			$self->generateField('british-standard-ALA-LC','&lt; 1975',$bs,'bl.jpg','http://explore.bl.uk/primo_library/libweb/action/search.do?dscnt=1&tab=local_tab&vl(freeText0)=' . $bs,'false'),
			$self->generateField('british-standard-ALA-LC','&gt; 1975',$ala,'bl.jpg','http://explore.bl.uk/primo_library/libweb/action/search.do?dscnt=1&tab=local_tab&vl(freeText0)=' . $ala,'false')
		];
	}
	return $group;
}

sub getVakPaspoorten {
	my ($self) = @_;
	my $icao = $self->getOutput('ICAO');
	return if (length($icao) == 0);
	return {
		'img' => 'paspoort.jpg',
		'fields' => [
			[$self->generateField('ICAO','',$icao,'','','true')],
			[$self->generateField('GOST_R_52535.1-2006','2010-2013',$self->getOutput('GOST_R_52535.1-2006'),'','','false')],
			[$self->generateField('paspoort-1997-2010','1997-2010',$self->getOutput('paspoort-1997-2010'),'','','false')],
			[$self->generateField('paspoort-ussr','&lt; 1997',$self->getOutput('paspoort-ussr'),'','','false')],
			[$self->generateField('rijbewijs','Driver\'s License',$self->getOutput('rijbewijs'),'','','false')]
		]
	};
}

sub getVakGegevensuitwisseling {
	my ($self) = @_;
	my $gost = $self->getOutput('GOST-2000b');
	return if length($gost) == 0;
	return {
		'img' => 'gegevensuitwisseling.jpg',
		'fields' => [
			[$self->generateField('GOST-2000a','ISO 9:1995 - GOST.7.79-2000 (system A)',$self->getOutput('ISO9-1995'),'','','false')],
			[$self->generateField('GOST-2000b','ISO 9:1995 - GOST 7.79-2000 (system B)',$gost,'','','false')]
		]
	};
}

1;
__END__
