##Moet tweede lijst inlezen. Eerst checken of deze versie 25 nog zelfde is als op Black!!

##Creating the alphabet and charconfus files:
##mre@black:/opensonar/NUTICCL/URL$ /exp/sloot/usr/local/bin/TICCL-lexstat --LD=0 --clip=1000 JRCnames.LexicalSenses.3cols.UTF8.3.OnlyWithSenseIDs.NamesOnlyOnePerLine.txt
##done reading
##created outputfile JRCnames.LexicalSenses.3cols.UTF8.3.OnlyWithSenseIDs.NamesOnlyOnePerLine.txt.lc.chars with 103 lowercase characters.
#done!

##Zie 50/51 verputst alles?!?!?!
##We set the binmode to UTF-8 for STDOUT and STDERR--BEGIN
#binmode(STDOUT, ":utf8");
#binmode(STDERR, ":utf8");
##We set the binmode to UTF-8 for STDOUT and STDERR--END

use Getopt::Std;

# OPTIONS
getopts('a:b:c:d:e:f:i:j:k:l:m:n:o:p:q:r:s:t:');

#print STDERR "TICCL_OPTS: a: $opt_a b: $opt_b c: $opt_c d: $opt_d e: $opt_e f: $opt_f g: $opt_g h: $opt_h i: $opt_i j: $opt_j k: $opt_k l: $opt_l m: $opt_m n: $opt_n o: $opt_o p: $opt_p q: $opt_q r: $opt_r s: $opt_s t: $opt_t u: $opt_u v: $opt_v w: $opt_w x: $opt_x y: $opt_y z: $opt_z\n";
print STDERR "TICCL_OPTS: a: $opt_a b: $opt_b c: $opt_c d: $opt_d e: $opt_e f: $opt_f g: $opt_g h: $opt_h i: $opt_i j: $opt_j k: $opt_k l: $opt_l m: $opt_m n: $opt_n o: $opt_o p: $opt_p q: $opt_q r: $opt_r s: $opt_s t: $opt_t\n";

$ROOTDIR = $opt_a;
$TOOLDIR = $opt_b;
$INPUTDIR = $opt_c;
$OUTPUTDIR = $opt_d;
$alph = $opt_e;
$charconfus = $opt_f;
#$anahash = $opt_g;
#$frqlist = $opt_h;
$Nameslist = $opt_i;
$Nameslist2 = $opt_j;
$prefix = $opt_k;
$LD = $opt_l;
$rank = $opt_m;
$artifrq = $opt_n;
$mode = $opt_o;
$threads = $opt_p;
$lang = $opt_q;
$interlang = $opt_r;
$targetlang = $opt_s;
$inputlist = $opt_t; 

if ($TOOLDIR =~ /^N$/){
$TOOLDIR = ();
}

$tocorpusfoci = $OUTPUTDIR . $prefix . '.toanahash.tsv';  ##Was bij onze testen file met anagramwaarden voor de fociwoorden. Moet 1 string zijn die nog moet omgezet worden door TICCL-anahash!! De anagramwaarde moet naar een bestandje waarnaar $corpusfoci verwijst

open(FOCI, ">$tocorpusfoci") || die "Could not at all open $tocorpusfoci: $!\n";

open(I, $inputlist) || die "Couldn't open $inputlist: $!\n";
while ($listinput = <I>) {
     $originput = $listinput;
     chomp $listinput;
     $listinput =~ s/ +/_/g;
     
     open(IN, ">$OUTPUTDIR/deaccent.txt");
     print IN "$listinput\n";

     $listinput = `$ROOTDIR/Accent.flex <$OUTPUTDIR/deaccent.txt`;

     print IN "2: $listinput\n";

     chomp $listinput;
     $query = $listinput; 
     $listinput =~ s/$/\t1/g;

     print FOCI "$listinput"; 
     print IN "3: $listinput Q: $query\n";
     close IN;
   }
close FOCI;

$out = $prefix;
$confuslist = $out;

##Moeten hier de 2 nieuwe lijsten inlezen, die van artifrq voorzien. Dan het focuswoord behandelen (input zou gewoon een naam of lijstje namen moeten zijn die dan freq = 1 krijgen). Deze nieuwe frq- en anahashlijsten gaat dan naar indexerNT.
##Nu eerst file met Names + IDs + Country gepast inlezen. Info names splitsen over samenstellende strings names en cumuleren!
##Info wordt nu nog niet uitgesplitst!!

if ($mode =~ /JRC/){
##Inlezen eerste lijst. Opslaan welke talen ingelezen werden!! Hebben wel Arabisch en Turks, maar bv. geen Grieks (el)!!
##Formaat:
##mre@black:/opensonar/NUTICCL/URL$ head -n 3 LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt
##الدكتور@ar@occ1004660@6
##قائد_اللواء@ar@occ1008425@9
##الشيخ@ar@occ1024696@6
open(K, $Nameslist) || die "Couldn't open $Nameslist: $!\n";
while ($list1 = <K>) {
     chomp $list1;
     @LIST1 = split '@', $list1;
     #print STDERR "LISTpost: @LIST1\n";
     if (@LIST1[0] !~ /^\s*$/){
     $JRCnames{@LIST1[0]}{@LIST1[2]}{@LIST1[1]} += @LIST1[3];  ##Interessanter om de namen te accumuleren voor een bepaalde taal, maar dan niet zoekbaar op naam! Tweede hash maken daarvoor?
     $langseen{@LIST1[1]}++;
@LISTB = split '_', @LIST1[0];
     foreach $listitem1 (@LISTB){
       if ($listitem1 !~ /^\s*$/){
     $JRCnames{$listitem1}{@LIST1[2]}{@LIST1[1]} += @LIST1[3]; ##Houdt niet alle items bij, voor eoa reden alleen voornaam? Haakje stond verkeerd!!!
     }
     }
@LISTB = ();
   }
}

foreach $langcode (sort keys %langseen){
print STDERR "LANGSEEN: $langcode $langseen{$langcode}\n";
}
##Inlezen tweede lijst. Niet inlezen deze waarvan de taal reeds voorkwam in de eerste lijst!!
##Formaat: 
##mre@black:/opensonar/NUTICCL/URL$ head -n 5 LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt
##Slivia_Berlusconija@sense7@sl
##Mohammed_El-Baradei@sense2461@fr
##Abu_Bakar_Ba@sense1998@nl
open(L, $Nameslist2) || die "Couldn't open $Nameslist2: $!\n";
while ($list = <L>) {
     chomp $list;
     @LIST = split '@', $list;
     #print STDERR "LISTpost: @LIST\n";
     if (!defined ($langseen{@LIST[2]})){
     $langseen{@LIST1[2]}++;
     if (@LIST[0] !~ /^\s*$/){
     $JRCnames{@LIST[0]}{@LIST[1]}{@LIST[2]} += 1;  ##Interessanter om de namen te accumuleren voor een bepaalde taal, maar dan niet zoekbaar op naam! Tweede hash maken daarvoor?
@LIST2 = split '_', @LIST[0];
     foreach $listitem (@LIST2){
       if ($listitem !~ /^\s*$/){
     $JRCnames{$listitem}{@LIST[1]}{@LIST[2]} += 1; ##Houdt niet alle items bij, voor eoa reden alleen voornaam? Haakje stond verkeerd!!!
     }
   }
@LIST2 = ();
}
   }
}
}
else {
##We read in GeoNames, two lists too.
##martin@martin-desktop:~/GeoNames$ head -n 3 cities1000.txt 
##3039154	El Tarter	El Tarter	Ehl Tarter,Эл Тартер	42.57952	1.65362	P	PPL	AD		02				1052		1721	Europe/Andorra	2012-11-03
##3039163	Sant Julià de Lòria	Sant Julia de Loria	San Julia,San Julià,Sant Julia de Loria,Sant Julià de Lòria,Sant-Zhulija-de-Lorija,sheng hu li ya-de luo li ya,Сант-Жулия-де-Лория,サン・ジュリア・デ・ロリア教区,圣胡利娅-德洛里亚,圣胡利娅－德洛里亚	42.46372	1.49129	P	PPLA	AD		06				8022		921	Europe/Andorra	2013-11-23
##3039604	Pas de la Casa	Pas de la Casa	Pas de la Kasa,Пас де ла Каса	42.54277	1.73361	P	PPL	AD		03				2363	2050	2106	Europe/Andorra	2008-06-09
##martin@martin-desktop:~/GeoNames$
open(K, $Nameslist) || die "Couldn't open $Nameslist: $!\n";
while ($list1 = <K>) {
     chomp $list1;
     @LIST1 = split '\t', $list1;
     #print STDERR "LISTpost: @LIST1\n";

     if (@LIST1[0] !~ /^\s*$/){
      if (@LIST1[14] > 0){
      $GEOfrq{@LIST1[0]} = @LIST1[14];
      $JRCnames{@LIST1[1]}{@LIST1[0]}{'en'} = @LIST1[14];
      }
      else {
      $GEOfrq{@LIST1[0]} = 1;
      $JRCnames{@LIST1[1]}{@LIST1[0]}{'en'} = 1;
      }
     #$JRCnames{@LIST1[1]}{@LIST1[0]}{'en'} = @LIST1[14];  ##Interessanter om de namen te accumuleren voor een bepaalde taal, maar dan niet zoekbaar op naam! Tweede hash maken daarvoor?
     #$JRCnames{@LIST1[1]}{@LIST1[0]}{'en'} = 1;
     $langseen{'en'}++;
#@LIST1[1] =~ s/ /_/g;
#@LISTB = split '_', @LIST1[1];
#     foreach $listitem1 (@LISTB){
#       if ($listitem1 !~ /^\s*$/){
#     $JRCnames{$listitem1}{@LIST1[0]}{'en'} = @LIST1[14]; ##Houdt niet alle items bij, voor eoa reden alleen voornaam? Haakje stond verkeerd!!!
#     }
#     }
#@LISTB = ();
   }
}

foreach $langcode (sort keys %langseen){
print STDERR "LANGSEENGeoNames: $langcode $langseen{$langcode}\n";
}
##Inlezen tweede lijst. Niet inlezen deze waarvan de taal reeds voorkwam in de eerste lijst!!
##Formaat: 
##martin@martin-desktop:~/GeoNames$ head -n 3 alternateNames.txt
##3556001	1	fa	Kūh-e Zardar				
##3556002	3	fa	Zamīn Sūkhteh				
##2488123	4	fa	رودخانه زاکلی				
##martin@martin-desktop:~/GeoNames$
open(L, $Nameslist2) || die "Couldn't open $Nameslist2: $!\n";
VERDER: while ($list = <L>) {
     chomp $list;
     @LIST = split '\t', $list;
     #print STDERR "LISTpost: @LIST\n";
     #if (!defined ($langseen{@LIST[2]})){

       if (@LIST[4] =~ /1/){
       $type = 1;
       $type1++;
       }
       elsif (@LIST[5] =~ /1/){
       $type = 2;
       $type2++;
       }
       elsif (@LIST[6] =~ /1/){
       $type = 3;
       $type3++;
       }
       elsif (@LIST[7] =~ /1/){
       $type = 4;
       $type4++;
       }
       else {
       $type = 0;
       $type0++;
       }

##Wat verder met $type??
##Post 125: zoiets als if $type == 1 dan frq van @LIST1 ipv +1!!
##Zetten nu de taal van lijst op 'en'. Misschien beter op iets distinctiefs waarlangs we de frq (inwonersaantal) kunnen doorgeven aan de canonieke vorm??

     if (@LIST[2] !~ /^\s*$/){
       if (@LIST[2] =~ /^link$/){
       $URL{@LIST[1]} = @LIST[3];
       goto VERDER;
       }
       if (@LIST[2] =~ /^post$/){
       $POST{@LIST[1]} = @LIST[3];
       goto VERDER;
       }
       else {
       $langseen{@LIST[2]}++;
       #}

##Dit klopt niet. URL- en POST-gevallen moeten niet verder meegenomen worden! : Opgelost met ##to else langseen 117
       if (($type =~ /1/) or ($type =~ /0/)){  ##Verzamel hier alleen de canonieke vormen. Beter niet doen, maar wel bij weergeven voorkeur geven aan deze? 120: Nu ook die zonder type-aanduiding!
     if (@LIST[3] !~ /^\s*$/){
	 @LIST[3] =~ s/ /_/g;
	 if ($type =~ /1/){
	     if ($GEOfrq{@LIST[1]} > 1){
         $JRCnames{@LIST[3]}{@LIST[1]}{@LIST[2]} = $GEOfrq{@LIST[1]};
	     }
	     else {
         $JRCnames{@LIST[3]}{@LIST[1]}{@LIST[2]} = 500;
             }
         }
         else {   
         $JRCnames{@LIST[3]}{@LIST[1]}{@LIST[2]} += 1;  ##Interessanter om de namen te accumuleren voor een bepaalde taal, maar dan niet zoekbaar op naam! Tweede hash maken daarvoor?
         }
##Hierboven de var type toevoegen voor canonical, slang, historical, etc.

#@LIST2 = split '_', @LIST[3];
#     foreach $listitem (@LIST2){
#       if ($listitem !~ /^\s*$/){
#     $JRCnames{$listitem}{@LIST[1]}{@LIST[2]} += 1; ##Houdt niet alle items bij, voor eoa reden alleen voornaam? Haakje stond verkeerd!!!
#     }
#   }
#@LIST2 = ();
}

     } ##TEST op type

     } ##to else langseen
   }
}
}

##IETS gaat niet echt lekker met de 'frq' voor GeoNames plaatsnamen. We baseren deze op het inwonersaantal. Dat is gelinkt aan de *Engelse* 'canonieke' naam. Moeten kijken of we dat kunnen 'doorlinken' aan de 'geattesteerde' canonieke naam, i.e. $type = 1 !!

foreach $langcode (sort keys %langseen){
print STDERR "LANGSEEN2: $langcode $langseen{$langcode}\n";
}

print STDERR "TYPES: 0: $type0 1: $type1 2: $type2 3: $type3 4: $type4\n";

##We name and open the tsv file
$tsv = $OUTPUTDIR . $prefix . '.tsv';
open (TSV, ">$tsv");
#binmode(TSV, ":utf8");

##Hier de geaccumuleerde lijsten printen naar file. Die dan straks oppakken met TICCL-anahash en $artifrq erbij voegen
##Print %JRCnames to verify!!
foreach $JRCname (sort keys %JRCnames) {
##Hier iets doen voor exact matches met query!! I.e. $name vullen zonder heel TICCL te runnen (want LDcalc geeft exacte matches toch niet terug!!)
$checkJRCname = $JRCname;
$checkJRCname =~ s/[\\|\||\(|\)|\[|\{|\^|\*|\+|\?|\.|,|!|:|;|\"|~|`|'|‘|’]+//g;
$queryNorm = $query;
$queryNorm =~ s/[\\|\||\(|\)|\[|\{|\^|\*|\+|\?|\.|,|!|:|;|\"|~|`|'|‘|’]+//g;
  if ($queryNorm =~ /^$checkJRCname$/){
  $nameexact = $query;
  print STDERR "HAVEEXACTMATCH: $query <<>> $checkJRCname\n";
  }

foreach $ID (keys %{ $JRCnames{$JRCname} }) {
foreach $lang (keys %{ $JRCnames{$JRCname}{$ID} }) {
#print STDERR "HASH1: $JRCname, $ID, $lang: $JRCnames{$JRCname}{$ID}{$lang}\n";
##Hier naar frqlist *tsv schrijven. Moet straks door anahash opgenomen worden.
 print TSV  "$JRCname\t$JRCnames{$JRCname}{$ID}{$lang}\n";
}
}
}
 close TSV;
##Aanpassen zodat de nieuwe frqlist opgenomen wordt. $tocorpusfoci blijft input. Aanpassen zodat de input alleen naam/namen hoeft te zijn!
##We calculate the anagram value for the input in $tocorpusfoci
print STDERR "RUN_TICCL-anahash: $tocorpusfoci\n";
#`$TOOLDIR/TICCL-anahash --alph $alph --artifrq 100000000000 $tocorpusfoci`;
`$TOOLDIR/TICCL-anahash --alph $alph --background $tsv --artifrq $artifrq $tocorpusfoci`;
##/exp/sloot/usr/local/bin/TICCL-anahash --alph JRCnames.LexicalSenses.3cols.UTF8.14.OnlyWithSenseIDs.NamesOnlyOnePerLine.txt.lc.chars --artifrq 2 input.lst

##We use indexerNT
##$corpusfoci hier moet een bestand zijn?!?
#$frqlist = $tsv;
$frqlist = $tocorpusfoci . '.merged';
$corpusfoci = $tocorpusfoci . '.corpusfoci';
$anahash = $tocorpusfoci . '.anahash';

##Check op corpusfoci om te zien of het geen veelvoud van ongedefinieerde karakters is (plus evt. punctuatie)--Begin
##Is een mogelijkheid met 'modulo'. Maar vast veel duurder dan de anagram hash check hieronder.
##Check op corpusfoci om te zien of het geen veelvoud van ongedefinieerde karakters is (plus evt. punctuatie)--End

##------
##sub factorial {     
##my ($num) = @_;
##return(1) if ($num <= 1);
##return($num*factorial($num-1));
##}
##print factorial(6)
##-------

open(V, $corpusfoci) || die "Couldn't HERE L306 open $corpusfoci: $!\n";
while ($value = <V>) {
     chomp $value;
$$anaInput = $value;
}
$anaPunct = 10000000000;
$divisor = 10510100501;

$check = $anaInput % $divisor;

if (($check != 0) and ($check != $anaPunct)){
print STDERR "RUN_TICCL-indexerNT: input: $anahash > $charconfus > $corpusfoci > $confuslist\n";
`$TOOLDIR/TICCL-indexerNT -t $threads --hash $anahash --charconf $charconfus --foci $corpusfoci -o $confuslist`;

print STDERR "RUN_TICCL-LDcalc: $out > $confuslist.indexNT > $anahash > $frqlist > $alph > $LD > $threads > $artifrq > $out.ldcalc\n";
`$TOOLDIR/TICCL-LDcalc --index $confuslist.indexNT --hash $anahash --clean $frqlist --alph $alph --LD $LD -t $threads --artifrq $artifrq -o $out.ldcalc`;

$outranked = $out . '.ranked';
print STDERR "RUN_TICCL-rank1: $out OUTRANKED: $outranked\n";
#`$TOOLDIR/TICCL-rank -t $threads --alph $alph --charconf $charconfus -o $outranked --debugfile $out.debug.ranked --artifrq $artifrq --clip $rank --skipcols=10,11 $out.ldcalc 2>$out.RANKartifrq.stderr`;
`$TOOLDIR/TICCL-rank -t $threads --alph $alph --charconf $charconfus -o $outranked --debugfile $out.debug.ranked --artifrq $artifrq --clip $rank --skipcols=10,11 $out.ldcalc`;

##Parse TICCL output
open(T, $outranked) || die "Couldn't open OUTRANKED $outranked: $!\n";
while ($ticclout = <T>) {
     chomp $ticclout;
     @TICCLOUT = split '#', $ticclout;
     #$seenticcl{@TICCLOUT[2]}++;
$seenticcl{@TICCLOUT[2]} += @TICCLOUT[3];
##Hier werden alleen voorkomens van een naamvariant als CC geteld. Wellicht beter de CCs te ranken volgens corpusfrequentie!!
}
foreach $nameseen (sort { $seenticcl{$b} <=> $seenticcl{$a} } keys %seenticcl){
push @NAMESSEEN, $nameseen;
}

##Nu in hash %JRCnames de ID ophalen
$name = shift @NAMESSEEN;
print STDERR "NAME: $name ARRAY: @NAMESSEEN\n";
}
else {
print STDERR "WILLNOTRUN_TICCL-indexerNT: input: $anahash > $charconfus > $corpusfoci > $confuslist CHECK: $check\n";
}

if (($name =~ /^$/) and ($nameexact !~ /^$/)){
$name = $nameexact;
}

print STDERR "NAME2: >>$name<< ARRAY: @NAMESSEEN >><< >>$nameexact<<\n";

if (($name =~ /^$/) and (($interlang =~ /ru/) or ($targetlang =~ /ru/))){  ##Name = leeg?????
#if (($interlang =~ /ru/) or ($targetlang =~ /ru/)){
print STDERR "NONAMEFOUND: >>$name<<\n";
##Do automatic transcription only
$flx = $OUTPUTDIR . '/' . $prefix . '.flx';
#$flx = $prefix . '.flx';
print STDERR "NONAMEFOUND2: >>$name<< FLEX: $flx\n";
open (FLX, ">$flx");
print FLX "$originput\n";
close FLX;
`$ROOTDIR/RU-NL.populair.flex <$flx >$flx.out`;
print STDOUT "<FONT COLOR=\"\#910a22\">Your Query:</FONT>\n\n\t\t\t<h>$originput<\h>\n";
print STDOUT "\n<FONT COLOR=\"\#910a22\">Corpus name versions for interlingua:</FONT> $interlang\n\n\tNeither the query nor any variants occur in our database of names.\n";
print STDOUT "\n<FONT COLOR=\"\#910a22\">Automatic transcription for target language:</FONT> $targetlang\n\n";
open (FLXout, "$flx.out");
while ($transcrip = <FLXout>) {
print STDOUT "\t\t\t$transcrip\n";
}
exit;
}

undef %seenticcl;
@NAMESSEEN = ();
#$langfrqnow = ();
##Print %JRCnames to verify!!
foreach $JRCname (sort keys %JRCnames) {
if ($JRCname =~ /$name/){ ##MOET KUNNEN DIENEN OM DE SEARCH TE NARROWEN!!
print STDERR "JRCNAME: $JRCname\n";
foreach $ID (keys %{ $JRCnames{$JRCname} }) {
print STDERR "JRCNAMEID: $JRCname ID: $ID\n";
#foreach $lang (keys %{ $JRCnames{$JRCname}{$ID} }) {
foreach $lang (sort { $b <=> $a } keys %{ $JRCnames{$JRCname}{$ID} }) {
print STDERR "JRCNAMEIDLANG: $JRCname ID: $ID L: $lang\n"; 
#  foreach $langfrq (keys %{ $JRCnames{$JRCname}{$ID}{$lang} }){
$langfrq = $JRCnames{$JRCname}{$ID}{$lang};
print STDERR "JRCNAMEIDLANGLANGFRQ: $JRCname ID: $ID L: $lang LF: $langfrq ALL: >$JRCnames{$JRCname}{$ID}{$lang}<\n";
$NameID{$ID} += $langfrq;
#if ($langfrq > $langfrqnow){
#$langfrqnow = $langfrq;
#$NameID{$ID}{$langfrq} = $JRCname;
#}#}
}}
}}

##DE DRIE ID VERSIES PRINTEN EN KIJKEN WAT ER MEE KAN!
#print STDERR "DEDRIE: NameID: $NameID >> $langfrqnow P: $prevID >> $prevlangfrq PP: $prev2ID >> $prev2langfrq\n";
##KLOPT NOG NIET!! CF. de printout.
$count = ();
foreach $NameID (sort { $NameID{$b} <=> $NameID{$a} } keys %NameID){
print STDERR "SEEID: $NameID >> $NameID{$NameID}\n";
#foreach $seeLANG (keys %{ $NameID{$seeID} }){
#print STDERR "SEEIDLANG: $seeID L: $seeLANG\n";
#foreach $seeLANGFRQ (sort { $b <=> $a } keys %{ $NameID{$seeID} }){
$count++;
if ($count < 4){
#print STDERR "SEEIDLANGFRQ: $seeID LF: $seeLANGFRQ NameID: $NameID{$seeID}{$seeLANGFRQ}\n";
#}
#}
#}

##Print %JRCnames to verify!!
foreach $JRCname (sort keys %JRCnames) {
foreach $ID (keys %{ $JRCnames{$JRCname} }) {
#if ($JRCname =~ /$name/){
#$NameID = $ID;
#}
foreach $lang (keys %{ $JRCnames{$JRCname}{$ID} }) { 
 #print STDERR "HASH: $JRCname, $ID, $lang: $JRCnames{$JRCname}{$ID}\n";
 if ($NameID =~ /^$ID$/){
   if ($interlang =~ /$lang/){
 print STDERR "HASHINTER: $JRCname, $ID, $lang: $JRCnames{$JRCname}{$ID}{$lang}\n";
   #$NamesInter{$ID} .= $JRCname . '#';
$frqI = $JRCnames{$JRCname}{$ID}{$lang};
 if (defined ($NamesInter{$ID}{$frqI})){
$NamesInter{$ID}{$frqI} .= ' || ' . $JRCname;
 }
 else {
$NamesInter{$ID}{$frqI} = $JRCname;
 }
}
   if ($targetlang =~ /$lang/){
 print STDERR "HASHTARGET: $JRCname, $ID, $lang: $JRCnames{$JRCname}{$ID}{$lang}\n";
   #$NamesTarget{$ID} .= $JRCname . '#';
$frqT = $JRCnames{$JRCname}{$ID}{$lang};
 if (defined ($NamesTarget{$ID}{$frqT})){
$NamesTarget{$ID}{$frqT} .= ' || ' . $JRCname;
 }
 else {
#$NamesTarget{$ID}{$frqT} .= $JRCname . '#';
$NamesTarget{$ID}{$frqT} = $JRCname;
 }
}
}
}
}
}

$interlangUC = uc($interlang);
$targetlangUC = uc($targetlang);

print STDOUT "<FONT COLOR=\"\#910a22\">Your Query:</FONT>\n\n\t\t\t<h>$originput<\h>\n";


foreach $interName (sort keys %NamesInter){
print STDERR "IN1: $interName\n";
##We name and open the flex file
if ($interlang =~ /ru/){
$flx = $prefix . '.flx';
open (FLX, ">$flx");
#binmode(FLX, ":utf8");
}
##<FONT COLOR="######">text</FONT>
##<FONT COLOR="#269ABC">text</FONT>
print STDOUT "\n<FONT COLOR=\"\#910a22\">Corpus name versions for interlingua:</FONT> $interlang\n\n";
#print STDOUT "\tIdentifier:\tFrequency:\tName variant:\n\n";
#print STDOUT "\tName variant:\tIdentifier:\tFrequency:\n\n";
$tel = ();
#foreach $frq  (sort { $NamesInter{$interName}{$b} <=> $NamesInter{$interName}{$a} } keys %{ $NamesInter{$interName} }){
foreach $frq  (sort { $b <=> $a } keys %{ $NamesInter{$interName} }){
print STDERR "IN2: $interName FRQ: $frq $NamesInter{$interName}{$frq}\n";
    if ($originput =~ / /){  ##Hoe sorteren op bigram of niet??
	if ($NamesInter{$interName}{$frq} =~ /[-_]/){
$tel++;
if ($tel < 4){
$NamesInter{$interName}{$frq} =~ s/_/ /g;
print STDERR "$interlangUC: $interName >> $frq >> $NamesInter{$interName}{$frq}\n";
print STDOUT "\t\t$NamesInter{$interName}{$frq}&emsp;<FONT COLOR=\"\#269ABC\">Identifier:</FONT> $interName\t<FONT COLOR=\"\#269ABC\">Frequency:</FONT> $frq\n\n";
if ($interlang =~ /ru/){
print FLX "$NamesInter{$interName}{$frq}\n";
}
}
    }
else {
  if (($interlang =~ /zh/) or ($interlang =~ /he/)){
$tel++;
if ($tel < 4){
$NamesInter{$interName}{$frq} =~ s/_/ /g;
print STDERR "$interlangUC: $interName >> $frq >> $NamesInter{$interName}{$frq}\n";
print STDOUT "\t\t$NamesInter{$interName}{$frq}&emsp;<FONT COLOR=\"\#269ABC\">Identifier:</FONT> $interName\t<FONT COLOR=\"\#269ABC\">Frequency:</FONT> $frq\n\n";
if ($interlang =~ /ru/){
print FLX "$NamesInter{$interName}{$frq}\n";
}
}
}
}
}
else {
$tel++;
if ($tel < 4){
$NamesInter{$interName}{$frq} =~ s/_/ /g;
print STDERR "$interlangUC: $interName >> $frq >> $NamesInter{$interName}{$frq}\n";
print STDOUT "\t\t$NamesInter{$interName}{$frq}&emsp;<FONT COLOR=\"\#269ABC\">Identifier:</FONT> $interName\t<FONT COLOR=\"\#269ABC\">Frequency:</FONT> $frq\n\n";
if ($interlang =~ /ru/){
print FLX "$NamesInter{$interName}{$frq}\n";
}
}
}
}
if ($interlang =~ /ru/){
`$ROOTDIR/RU-NL.populair.flex <$flx >$flx.out`;
print STDOUT "\n<FONT COLOR=\"\#910a22\">Automatic transcriptions for target language:</FONT> $targetlang\n\n";
open (FLXout, "$flx.out");
while ($transcrip = <FLXout>) {
print STDOUT "\t\t\t\t$transcrip\n";
}
}
#for $tofreq (sort { $b <=> $a } keys %tofrqsort){
#($F, $N) = split '@', $tofrqsort{$tofreq};
#print STDERR "RUSsorted: >$tofreq<\t$F\t$N\n";
#}
}


foreach $targetName (sort keys %NamesTarget){
print STDERR "TN1: $targetName\n";
print STDOUT "\n<FONT COLOR=\"\#910a22\">Corpus versions target language:</FONT> $targetlang\n\n";
#print STDOUT "\tName variant:\tIdentifier:\tFrequency:\n\n";
$tel2 = ();
foreach $frq2  (sort { $b <=> $a } keys %{ $NamesTarget{$targetName} }){
print STDERR "TN2: $targetName FRQ2: $frq2 $NamesTarget{$targetName}{$frq2}\n";
    if ($originput =~ / /){  ##Hoe sorteren op bigram of niet??
	if ($NamesTarget{$targetName}{$frq2} =~ /[-_]/){
$tel2++;
if ($tel2 < 4){
$NamesTarget{$targetName}{$frq2} =~ s/_/ /g;
print STDERR "$targetlangUC: $targetName >> $frq2 >> $NamesTarget{$targetName}{$frq2}\n";
print STDOUT "\t\t$NamesTarget{$targetName}{$frq2}&emsp;<FONT COLOR=\"\#269ABC\">Identifier:</FONT> $targetName\t<FONT COLOR=\"\#269ABC\">Frequency:</FONT> $frq2\n\n";
if ($mode =~ /GEO/){
print STDOUT "<FONT COLOR=\"\#269ABC\">URL Wikipedia:</FONT>\n\n\t\t\t$URL{$targetName}\n";
}

}
}
    else {
      if (($targetlang =~ /zh/) or ($targetlang =~ /he/)){
$tel2++;
if ($tel2 < 4){
$NamesTarget{$targetName}{$frq2} =~ s/_/ /g;
print STDERR "$targetlangUC: $targetName >> $frq2 >> $NamesTarget{$targetName}{$frq2}\n";
print STDOUT "\t\t$NamesTarget{$targetName}{$frq2}&emsp;<FONT COLOR=\"\#269ABC\">Identifier:</FONT> $targetName\t<FONT COLOR=\"\#269ABC\">Frequency:</FONT> $frq2\n\n";
if ($mode =~ /GEO/){
print STDOUT "<FONT COLOR=\"\#269ABC\">URL Wikipedia:</FONT>\n\n\t\t\t$URL{$targetName}\n";
}

}
}
}
}
    else {
$tel2++;
if ($tel2 < 4){
$NamesTarget{$targetName}{$frq2} =~ s/_/ /g;
print STDERR "$targetlangUC: $targetName >> $frq2 >> $NamesTarget{$targetName}{$frq2}\n";
print STDOUT "\t\t$NamesTarget{$targetName}{$frq2}&emsp;<FONT COLOR=\"\#269ABC\">Identifier:</FONT> $targetName\t<FONT COLOR=\"\#269ABC\">Frequency:</FONT> $frq2\n\n";
if ($mode =~ /GEO/){
print STDOUT "<FONT COLOR=\"\#269ABC\">URL Wikipedia:</FONT>\n\n\t\t\t$URL{$targetName}\n";
}

}
}
}
#print STDOUT "\t\t<FONT COLOR=\"\#269ABC\">_________________________________________________</FONT>\n";
}
undef %NamesTarget;
undef %NamesInter;
if ($interlang =~ /ru/){
`rm $flx`;
}
}

$teller++;
if ($teller == 4){
exit;
}
else {
print STDOUT "\t\t<FONT COLOR=\"\#910a22\">_________________________________________________</FONT>\n";
}
} #to foreach NameID
##Bij laatste testen verschenen de nl corpusversies niet??
##Nog niet zeker nu dat de tweede lijst info uit de eerste niet overschrijft. Cf. testen met Wladymir Ljenin.

##TO DO: - iets zinnigs doen met die 'occ' info
## - bekijken waar de duurste onderdelen zitten en hoe die best goedkoper gemaakt kunnen worden. Enerzijds mogelijk combinaties te maken, anderzijds voorberekening en in servermodus aanbieden mogelijk.

## Vooraf: het systeem is agnostisch tov van talen en mogelijke taalcombinaties wat betreft de informatie uit de JRC Names. In tegenstelling tot eerder hebben we geen talen verwijderd (zelfs al kunnen we zelf niks met de scripts, zelfs al betreft het in een aantal gevallen RTL scripts (Arabisch, Hebreeuws, etc.).

## Vooraf 2: het systeem vraagt momenteel per persoonsnaam de volgende info: naam, taal, identifier en corpusfrequentie. JRC Names wordt hierbij beschouwd als een corpus. Corpusfrequenties worden momenteel echter slechts voor 23 van de aanwezige talen verzameld. We hebben wel de naam, taal en identifier opgenomen voor de talen waarvoor geen frequenties beschikbaar zijn.

## Scenario's:
## 1/ De gebruiker ontmoet een hem onbekende naam in een Reuters persbericht. Hij geeft als interlangua 'ru' op en vraagt om de transcriptie in het Nederlands. Het systeem zoekt fuzzy naar de meest frequente naam die slechts maximaal met zoveel letters verschilt. Het neemt dan de meest frequente vormen van die naam op basis van de identifier ervan uit de originele taal. Indien deze Russisch is, geeft het deze vormen terug en geeft meteen de op basis van een automaat naar het Nederlands getranscribeerde varianten terug. Het systeem zoekt eveneens op basis van de identifiers de meest frequent voorkomende Nederlandse versies van de naam en geeft deze terug. (Probleem: de meest frequente Russische naamsvarianten kunnen makkelijk de genitiefvormen zijn. Bv. voor Alexander Solzhenitsyn (courante Engels vorm). Mogelijke oplossing: soort gender-detector bouwen op basis van de voorkomende naamvalsvormen. Cf. verschil Alexander en Natalia Solzhenitsyn).

##Query: Salzhenitsyn
##Remark: more common English transcription: 'Solzhenitsyn'. Edit distance = 1
##Current command-line: mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.92.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST92.1 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r ru -s nl -t input1.Salzhenitsyn.txt >TEST92.1.stdout 2>TEST92.1.stderr
##Output: http://ticclops.uvt.nl/TEST92.1.stdout

##Opmerking: Het systeem zoekt steeds eerst fuzzy. Het is best mogelijk dat de Reutersversie van de naam niet perfect voldoet aan eventuele transcriptieregels voor bv. het Engels. De gebruiker hoeft door het fuzzy zoeken niet te specificeren volgens welke evt. transcriptieregels (bv. Engels, Franse of Duitse) hij denkt zijn input gevormd is. Enkel voor het Russisch Cyrillisch is echter momenteel een automaat beschikbaar. Deze geeft de beste transcriptie volgens een bepaalde regelset. De output hiervan kan verschillen van de meest courante variant gehanteerd in de pers, het geeft bv. 'Aleksandr' i.p.v. 'Alexander' voor Nobelprijswinnaar (??) Solzjenitsyn. (mogelijk dit straks in de interface te highlighten??).

##Opmerking2: Het systeem reageert anders naargelang een voornaam, achternaam dan wel de combinatie ingevoerd wordt. (wat bij eveneens patroniemen?). Bij de bigramcombinatie zal het systeem hits op alleen voor- of achternaam niet teruggeven, evt. wel trigrammen met ook nog een patroniem. Zoek je enkel op de achternaam Poutine (Frans vorm voor Poetin (nl), dan produceert het systeem hits op zowel Vladimir als Ljoudmilla Poetin (nl). Deze hebben een andere identifier en er wordt een apart outputrapport geproduceerd voor beide. (Nog niet getest...!! Zoek je op een vorm voor de voornaam Vladimir, dan is het de bedoeling zo je de nl transcriptie via ru opvraagt, dat je de top van de frequentieljst van de meest in de media voorkomende personen met deze voornaam gepresenteerd krijgt.)

##Query: Wladymir
##Current command-line:  mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.92.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST92.2 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r ru -s nl -t input2.Wladymir.txt >TEST92.2.stdout 2>TEST92.2.stderr
##Output: http://ticclops.uvt.nl/TEST92.2.stdout

##Query: Poutine (Franse versie voor Poetin)
##Remark: This also retrieves Ljoudmila Poutina (Lyudmila Aleksandrovna Putina is the ex-wife of the Russian President and former Prime Minister Vladimir Putin. Wikipedia). Check: we get no hits on the Dutch Corpus.
##Current command-line: mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.92.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST92.3 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r ru -s nl -t input3.Poutine.txt >TEST92.3.stdout 2>TEST92.3.stderr
##Output: http://ticclops.uvt.nl/TEST92.3.stdout

##Opmerking3: Vindt het systeem geen op de query Russisch Cyrillische gelijkende naam dan krijgt de gebruiker momenteel niets terug ??!! (Mogelijk: ergens anders gaan zoeken? Wikipedia? Voorbeeld: De naam Tsjaikovski heeft varianten in de JRC Names databank, maar de Russisch Cyrillische vorm ontbreekt. Nota bene: het is zeer moeilijk voor een ljst van 1,7 miljoen items in het zeer brede gamma aan talen en scripts in te schatten hoe goed de coverage is. Mogelijk in te bouwen: dynamisch overzicht van aantal talen en per taal aanwezige naamsvarianten, statistieken over gemiddeld aantal varianten (evt. per taal?) per onderscheiden persoon/instantie, etc.) 

##Query: Tchaykovski
##Remark: No real output, no Cyrillic version of the name in the JRC Names database!! Need to check why 2 'hits', apparently, but no Dutch output either.
##Current command-line: mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.92.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST92.4 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r ru -s nl -t input4.Tchaykovski.txt >TEST92.4.stdout 2>TEST92.4.stderr
##Output: http://ticclops.uvt.nl/TEST92.4.stdout

##Query: Tsjaikovski
##Remark: No real output. No real solution for now.
##Current command-line: mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.92.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST92.5 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r ru -s nl -t input5.Tsjaikovski.txt >TEST92.5.stdout 2>TEST92.5.stderr
##Output: http://ticclops.uvt.nl/TEST92.5.stdout

##Opmerking4: Vindt het systeem geen op de reeds Russisch Cyrillische query gelijkende varianten dan krijgt de gebruiker de volgens de regels aanbevolen transcriptie terug.

##Query: Пётр Ильи́ч Чайко́вский (Name plucked from Wikipedia)
##Remark: Note the stress marks on the vowels! The automaton correctly deals with these.
##Current command-line: mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.94.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST94.6 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r ru -s nl -t input6.Пётр_Ильи́ч_Чайко́вский.txt >TEST94.6.stdout 2>TEST94.6.stderr &
##Output: http://ticclops.uvt.nl/TEST92.6.stdout

##Query: Пётр Ильич Чайковский
##Current command-line: mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.94.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST94.7 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r ru -s nl -t input7.Пётр_Ильич_Чайковский.txt >TEST94.7.stdout 2>TEST94.7.stderr &
##Output: http://ticclops.uvt.nl/TEST92.7.stdout

## 2/ De gebruiker kent een naam van horen zeggen. Tikt iets dat er zo goed mogelijk op gelijkt gegeven zijn moedertaal. De naam wordt fuzzy gezocht en teruggegeven in de gewenste taal, bv. de taal die de gebruiker veronderstelt de originele te zijn. (Mogelijk op basis van evt. andere info de originele ook terug te geven, met vermelding bron).

##Query: Barak
##Command-line: mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.100.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST100.8 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r zh -s nl -t input8.Barak.lst >TEST100.8.stdout 2>TEST100.8.stderr &
##Output: http://ticclops.uvt.nl/TEST100.9.stdout

## 3/ De gebruiker wil de naam zien in zijn originele vorm en/of script. Casus: je gaat op reis in China en je wilt weten hoe Mao eruitziet in Chinese karakters. Dit kan aangevuld worden met output in een andere taal. Casus: een journalist wenst na te gaan hoe een Chinese naam in Spanje gespeld wordt om dan op het Spaanse web te kunnen zoeken naar vindplaatsen ervoor. Bijvoorbeeld om te bestuderen hoe men in de jaren '50 in Spanje sprak over Mao.

##Query: Mao Zhedong
##Remark: There are actually 2 versions for this name in the JRC Names database, in Chinese, a traditional and a simplified version. Both have frequency = 2. Only one is output, currently. Need to look into that.
##Command-line: mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.95.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST95.9 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r zh -s es -t input9.MaoZhedong.lst >TEST95.9.stdout 2>TEST95.9.stderr &
##Output: http://ticclops.uvt.nl/TEST95.9.stdout

#Query: Mao
##Remark: This did not work at all with the previous versions of the script. We have now added 'exact matching'. The second and third matches returned are not yet in fact the more frequent ones. It is now either exact match or fuzzy match. Probably better to have/try both.
##Command-line: perl /opensonar/NUTICCL/URL/toTranscrApp.100.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST100.10 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r zh -s nl -t input10.Mao.lst >TEST100.10.stdout 2>TEST100.10.stderr &
##Output: http://ticclops.uvt.nl/TEST100.10.stdout

##Query: Osama Bin Laden
##Remark: Check: the 'Your query' line gets printed too often! This command line asked for Arabian as 'interlanguage' and for Russian as 'target language'.
##Current command-line: mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.95.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST95.11 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r ar -s ru -t input11.Osama_Bin_Laden.lst >TEST95.11.stdout 2>TEST95.11.stderr &
##Output: http://ticclops.uvt.nl/TEST95.11.stdout

#Query: Osama Bin Laden
##Remark: Check: the 'Your query' line gets printed too often! This command line asked for Arabian as 'interlanguage' and for Hebrew as 'target language'. Nothing for Hebrew is returned, while we have a form in the JRC Names database!
## mre@black:/opensonar/NUTICCL/URL$ grep '@sense28@' LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt |grep '@he'
## אוסאמה_בן_לאדן@sense28@he
##Need to solve this!
##Current command-line: mre@black:/opensonar/NUTICCL/URL$ perl /opensonar/NUTICCL/URL/toTranscrApp.101.pl -b /exp/sloot/usr/local/bin/ -c /opensonar/NUTICCL/URL -d /opensonar/NUTICCL/URL/OUT -e /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f /opensonar/NUTICCL/URL/15/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i /opensonar/NUTICCL/URL/LISTS/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j /opensonar/NUTICCL/URL/LISTS/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k TEST101.11 -l 4 -m 5 -n 100000000000 -o M -p 10 -q en -r ar -s he -t input11.Osama_Bin_Laden.lst >TEST101.11.stdout 2>TEST101.11.stderr &
##Output: http://ticclops.uvt.nl/TEST101.11.stdout


##INDEXERNT:
##mre@black:/opensonar/NUTICCL/URL$ /exp/sloot/usr/local/bin/TICCL-indexerNT --hash /opensonar/NUTICCL/URL/JRCnames.LexicalSenses.3cols.UTF8.14.OyWithSenseIDs.FullNamesOnlyandNamesOnlyOnePerLine.tsv.2.clean.anahash --charconf /opensonar/NUTICCL/URL/JRCnames.LexicalSenses.3cols.UTF8.14.OnlyWithSenseIDs.NamesOnlyOnePerLine.txt.clip2000.ld2.charconfus --foci testcorrect.foci --low 4 -o testcorrect.out
##reading anagram hash values
##read 984611 anagram hash values
##skipped 7193 out-of-band hash values
##read 1 foci values
##read 6683685 character confusion values
##max value = 421812174848

##LDCALC:
##mre@black:/opensonar/NUTICCL/URL$ /exp/sloot/usr/local/bin/TICCL-LDcalc --index testcorrect.out.indexNT --hash /opensonar/NUTICCL/URL/JRCnames.LexicalSenses.3cols.UTF8.14.OyWithSenseIDs.FullNamesOnlyandNamesOnlyOnePerLine.tsv.2.clean.anahash --clean /opensonar/NUTICCL/URL/JRCnames.LexicalSenses.3cols.UTF8.14.OyWithSenseIDs.FullNamesOnlyandNamesOnlyOnePerLine.tsv.2.clean --alph /opensonar/NUTICCL/URL/JRCnames.LexicalSenses.3cols.UTF8.14.OnlyWithSenseIDs.NamesOnlyOnePerLine.txt.lc.chars --LD 4 --artifrq=100000000000 -o testcorrect.out.LD4
##reading alphabet.
##read 372540 words with frequencies
##skipped 725901 n-grams
##read 991804 hash values
#Done

##RANK:
##mre@black:/opensonar/NUTICCL/URL$ /exp/sloot/usr/local/bin/TICCL-rank --alph /opensonar/NUTICCL/URL/JRCnames.LexicalSenses.3cols.UTF8.14.OnlyWithSenseIDs.NamesOnlyOnePerLine.txt.lc.chars --charconf /opensonar/NUTICCL/URL/JRCnames.LexicalSenses.3cols.UTF8.14.OnlyWithSenseIDs.NamesOnlyOnePerLine.txt.clip2000.ld2.charconfus -t 1 testcorrect.out.LD4.ldcalc 
##reading alphabet.
##start indexing input and determining KWC counts.
##Done indexing
##reading lexstat file /opensonar/NUTICCL/URL/JRCnames.LexicalSenses.3cols.UTF8.14.OnlyWithSenseIDs.NamesOnlyOnePerLine.txt.clip2000.ld2.charconfus and extracting pairs.
##Start the work, with 17 iterations on 1 thread(s).
##results in testcorrect.out.LD4.ldcalc.ranked
