package Transliterator::HTMLFactory;

use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw(generateHTML);
$VERSION   = '0.01';

sub new {
	my $class = shift;
	my $TU    = shift;
	my $type  = shift;
	my $self  = {
		output => {},
		TU     => $TU,
		type   => $type
	};
	bless $self, $class;
	return $self;
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

sub generateHTML {
	my ($self) = @_;
	my @output = ('<div class="row" id="resultaten">');
	if ( length( $self->getOutput('ENG-RUS') ) > 0 ) {
		push @output,
		  '<div class="panel"><p>' . $self->getOutput('ENG-RUS') . '</p></div>';
	}
	else {
		push @output, $self->getVakAdvies();
		push @output, $self->getVakWereld();
		push @output, $self->getVakWetenschappelijk();
		if ( $self->{type} eq 'L' ) {
			push @output, $self->getVakKaarten();
		}
		push @output, $self->getVakBibliotheken();
		if ( ( $self->{type} ne 'L' ) and ( $self->{type} ne 'O' ) ) {
			push @output, $self->getVakPaspoorten();
		}
		push @output, $self->getVakGegevensuitwisseling();
	}
	push @output, '</div>';
	return join( '', @output );
}

sub getVakAdvies {
	my ($self) = @_;

	my ( $populair, $taalunie, $wiki ) = (
		$self->getOutput('populair'),
		$self->getOutput('taalunie'),
		$self->getOutput('wikipedia')
	);
	my $advies = $populair;

	my $lengthTU = length($taalunie);
	my $img      = 'afbeeldingen/nederlands.png';
	if ( length($taalunie) > 0 && $self->{type} eq 'L' ) {
		$advies = $taalunie;
		$wiki   = $taalunie;
		$img    = 'afbeeldingen/nederlands-taalunie1.png';
	}

	my $html =
'<div class="panel"><div class="row"><div class="col-xs-6 text-right" data-toggle="tooltip" data-tooltip-id="nederlands" data-placement="left"><img class="advies logo" src="'
	  . $img . '">';

	#	Dit zit nu in het logo hierboven ingebakken, dus niet meer nodig.
	#	if (length($taalunie) > 0 && $self->{type} eq 'L') {
	#	    $html .= '<img src="afbeeldingen/taalunie.png" class="taalunie-sub">';
	#	}

	$html .=
'</div><div class="col-xs-6" data-toggle="tooltip" data-tooltip-id="nederlands" data-placement="left"><h3>'
	  . $advies . '</h3>';
	if ( $advies ne $populair ) {
		$html .= '<h4>(' . $populair . ')</h4>';
	}
	$html .= '</div>';

	if ( $advies ne $taalunie && length($taalunie) > 0 ) {
		$html .=
'<div class="col-xs-6"><img class="taalunie logo" src="afbeeldingen/taalunie.png"></div>';
		$html .= '<div class="col-xs-6">' . $taalunie . '</div>';
	}

	if ( $advies ne $wiki && length($wiki) > 0 ) {
		$html .=
'<div class="col-xs-6"><img class="wikipedia logo" src="afbeeldingen/wikipediasmall.png"></div>';
		$html .= '<div class="col-xs-6">' . $wiki . '</div>';
	}
	if ( ( $advies !~ /Invalid/ ) and ( $advies !~ /Ongeldige/ ) ) {
		$html .=
'<div class="col-xs-12 text-center search">[ <a href="https://www.google.nl/#q='
		  . $advies
		  . '&nfpr=1" target=_blank">Google</a> ]&nbsp;&nbsp;[ <a href="https://nl.wikipedia.org/wiki/Speciaal:Zoeken?search='
		  . $wiki
		  . '" target=_blank">Wikipedia</a> ]';
	}
	if ( $self->{type} eq 'L' ) {
		$html .=
		    '&nbsp;&nbsp;[ <a href="https://www.google.com/maps?oi=map&q='
		  . $advies
		  . '" target=_blank">Google Maps</a> ]';
	}

	$html .= '</div></div></div>';

	return $html;
}

sub getVakWereld {
	my ($self) = @_;
	my $html =
'<div class="panel panel-default"><div class="row"><div class="col-xs-3 col-sm-2 col-md-1"><img class="logo" src="afbeeldingen/wereldbol-vlaggen.jpg" /></div>

		<div class="col-xs-9 col-sm-10 col-md-11"><div class="output-group" data-toggle="tooltip" data-tooltip-id="engels" data-placement="left"><img class="bullet-logo" src="afbeeldingen/engels.jpg" /><p>'
	  . $self->getOutput('populair-engels') . '</p>';

	if ( $self->getOutput('populair-engels') ne
		$self->getOutput('BGN-PCGN-simpel') )
	{
		$html .= '<p>BGN-PCGN (simple): '
		  . $self->getOutput('BGN-PCGN-simpel') . '</p>';
	}
	$html .=
'</div><div class="output-group" data-toggle="tooltip" data-tooltip-id="duits" data-placement="left"><img class="bullet-logo" src="afbeeldingen/duits.jpg" /><p>'
	  . $self->getOutput('populair-duits')
	  . '</p></div></div></div></div>';

	return $html;
}

sub getVakWetenschappelijk {
	my ($self) = @_;
	if ( $self->getOutput('wetenschappelijk') !~ /Not applicable/ ) {
		my $html =
'<div class="panel panel-default"><div class="row"><div class="col-xs-3 col-sm-2 col-md-1"><img class="logo" src="afbeeldingen/wetenschap.png" /></div>
		<div class="col-xs-9 col-sm-10 col-md-11"><div class="output-group main" data-toggle="tooltip" data-tooltip-id="wetenschappelijk1" data-placement="left"><p>'
		  . $self->getOutput('wetenschappelijk')
		  . '</p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="ALA-LC" data-placement="left"><p>ALA-LC: '
		  . $self->getOutput('ALA-LC')
		  . '</p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="ALA-LC-simpel" data-placement="left"><p>ALA-LC (simple): '
		  . $self->getOutput('ALA-LC-simpel')
		  . '</p></div>
	</div></div></div>';
		return $html;
	}
}

sub getVakKaarten {
	my ($self) = @_;
	if ( $self->getOutput('GOST-1983') !~ /Not applicable/ ) {
		my $html =
'<div class="panel panel-default"><div class="row"><div class="col-xs-3 col-sm-2 col-md-1"><img class="logo" src="afbeeldingen/kaart-rusland.jpg" /></div>
		<div class="col-xs-9 col-sm-10 col-md-11"><div class="output-group" data-toggle="tooltip" data-tooltip-id="GOST-1983" data-placement="left"><img class="bullet-logo" src="afbeeldingen/vn.jpg" /><p>'
		  . $self->getOutput('GOST-1983')
		  . '</p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="taalunie" data-placement="left"><img class="bullet-logo" src="afbeeldingen/taalunie.png" /><p>'
		  . $self->getOutput('taalunie')
		  . '</p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="BGN-PCGN" data-placement="left"><img class="bullet-logo" src="afbeeldingen/bgn-pcgn.png" /><p>'
		  . $self->getOutput('BGN-PCGN')
		  . '</p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="GOST-2004" data-placement="left"><img class="bullet-logo" src="afbeeldingen/verkeersbord.jpg" /><p>'
		  . $self->getOutput('GOST-2004')
		  . '</p></div>
	</div></div></div>';
		return $html;
	}
}

sub getVakBibliotheken {
	my ($self) = @_;
	if ( $self->getOutput('wetenschappelijk') !~ /Not applicable/ ) {
		my $html =
'<div class="panel panel-default"><div class="row"><div class="col-xs-3 col-sm-2 col-md-1"><img class="logo" src="afbeeldingen/bibliotheek.jpg" /></div>
		<div class="col-xs-9 col-sm-10 col-md-11"><div class="output-group" data-toggle="tooltip" data-tooltip-id="wetenschappelijk2" data-placement="left"><img class="bullet-logo" src="afbeeldingen/kb-nl.jpg" />
		<p>'
		  . $self->getOutput('wetenschappelijk')
		  . ' <a href="http://opc4.kb.nl/DB=1/SET=3/TTL=1/CMD?ACT=SRCHA&IKT=1016&SRT=YOP&TRM='
		  . $self->getOutput('wetenschappelijk')
		  . '" target="_blank"><img class="external-link" src="afbeeldingen/externe-link.png" /></a></p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="ALA-LC" data-placement="left"><img class="bullet-logo" src="afbeeldingen/loc.jpg" />
		<p>'
		  . $self->getOutput('ALA-LC')
		  . ' <a href="http://catalog.loc.gov/vwebv/search?searchArg='
		  . $self->getOutput('ALA-LC')
		  . '&searchCode=GKEY%5E*&searchType=0&recCount=25&sk=en_US" target="_blank"><img class="external-link" src="afbeeldingen/externe-link.png" /></a></p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="british-standard-ALA-LC" data-placement="left"><img class="bullet-logo" src="afbeeldingen/bl.jpg" />';
		if (
			$self->getOutput('british-standard') ne $self->getOutput('ALA-LC') )
		{
			$html .=
			    '<p>&lt; 1975: '
			  . $self->getOutput('british-standard')
			  . ' <a href="http://explore.bl.uk/primo_library/libweb/action/search.do?dscnt=1&tab=local_tab&vl(freeText0)='
			  . $self->getOutput('british-standard')
			  . '&fn=search&vid=BLVU1&mode=Basic" target="_blank"><img class="external-link" src="afbeeldingen/externe-link.png" /></a></p>
		<p>&gt; 1975: '
			  . $self->getOutput('ALA-LC')
			  . ' <a href="http://explore.bl.uk/primo_library/libweb/action/search.do?dscnt=1&tab=local_tab&vl(freeText0)='
			  . $self->getOutput('ALA-LC')
			  . '&fn=search&vid=BLVU1&mode=Basic" target="_blank"><img class="external-link" src="afbeeldingen/externe-link.png" /></a></p>';
		}
		else {
			$html .= '<p>'
			  . $self->getOutput('ALA-LC')
			  . ' <a href="http://explore.bl.uk/primo_library/libweb/action/search.do?dscnt=1&tab=local_tab&vl(freeText0)='
			  . $self->getOutput('ALA-LC')
			  . '&fn=search&vid=BLVU1&mode=Basic" target="_blank"><img class="external-link" src="afbeeldingen/externe-link.png" /></a></p>';
		}
		$html .= '</div></div></div></div>';

		return $html;
	}
}

sub getVakPaspoorten {
	my ($self) = @_;
	if ( $self->getOutput('ICAO') !~ /Not applicable/ ) {
		my $html =
'<div class="panel panel-default"><div class="row"><div class="col-xs-3 col-sm-2 col-md-1"><img class="logo" src="afbeeldingen/paspoort.jpg" /></div>
		<div class="col-xs-9 col-sm-10 col-md-11"><div class="output-group main" data-toggle="tooltip" data-tooltip-id="ICAO" data-placement="left"><p>'
		  . $self->getOutput('ICAO')
		  . '</p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="GOST_R_52535.1-2006" data-placement="left"><p>2010-2013: '
		  . $self->getOutput('GOST_R_52535.1-2006')
		  . '</p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="paspoort-1997-2010" data-placement="left"><p>1997-2010: '
		  . $self->getOutput('paspoort-1997-2010')
		  . '</p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="paspoort-ussr" data-placement="left"><p>&lt; 1997: '
		  . $self->getOutput('paspoort-ussr')
		  . '</p></div>
		<div class="output-group" data-toggle="tooltip" data-tooltip-id="rijbewijs" data-placement="left"><p>Driver\'s License: '
		  . $self->getOutput('rijbewijs')
		  . '</p></div>
	</div></div></div>';

		return $html;
	}
}

sub getVakGegevensuitwisseling {
	my ($self) = @_;
	if ( $self->getOutput('GOST-2000b') !~ /Not applicable/ ) {
		my $html =
'<div class="panel panel-default"><div class="row"><div class="col-xs-3 col-sm-2 col-md-1"><img class="logo" src="afbeeldingen/gegevensuitwisseling.jpg" /></div>
<div class="col-xs-9 col-sm-10 col-md-11"><div class="output-group main"></div>
<div class="output-group" data-toggle="tooltip" data-tooltip-id="GOST-2000a" data-placement="left"><p>ISO 9:1995 - GOST.7.79-2000 (system A): '
		  . $self->getOutput('ISO9-1995')
		  . '</p></div>
<div class="output-group" data-toggle="tooltip" data-tooltip-id="GOST-2000b" data-placement="left"><p>ISO 9:1995 - GOST 7.79-2000 (system B): '
		  . $self->getOutput('GOST-2000b')
		  . '</p></div>
</div></div></div>';

		return $html;
	}
}

1;
__END__
