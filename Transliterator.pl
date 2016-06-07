
use strict;
use warnings;
#use locale;

if (!@ARGV) {
	die "No input.";
}

my $name = $ARGV[2];
$name =~ s/ /_/;



my $rootdir; 
BEGIN { $rootdir = $ARGV[0];}
use lib "$rootdir/lib";
my $tmpdir = $ARGV[1];
use Transliterator::HTMLFactory;
my $debug = ();
$debug = $ARGV[3] if (defined $ARGV[3]);

open(IN2, ">$tmpdir/SEEINPUT.txt");
print IN2 "IN: $name ROOT: $rootdir TMP: $tmpdir\n";

open(IN3, ">$tmpdir/SEEINPUT2.txt");

open(TEST, ">>$tmpdir/TEST.out");

my $type = 'P';
if ($name =~ /_LOC$/) {
         $type = 'L';
         $name =~ s/_LOC$//;
}
if ($name =~ /_OTH$/) {
    $type = 'O';
    $name =~ s/_OTH$//;
}

##In array duwen, elk stukje first char uppercasen, indien stukje zelfde als vorige: weggooien --BEGIN
print STDERR "NAME1: $name\n";
my @NAME = split /_/, $name;
$name = ();
my $prevnaam = '';
foreach my $naam (@NAME){
  if ($type !~ /O/){
    if (($naam !~ /-/) and ($naam !~ /\./)){
      $naam = lc($naam);
    }
  $naam = ucfirst($naam);
  }
  if ($prevnaam !~ /$naam/){
  $name .= $naam . '_';
  }
$prevnaam = $naam;
}
$name =~ s/_$//;
print STDERR "NAME2: $name\n";
##In array duwen, elk stukje first char uppercasen, indien stukje zelfde als vorige: weggooien --END

my @chars = ("A".."Z", "a".."z", "0..9");

# Generate random filename
my $input = '';
for my $i (1..8) {
	$input .= $chars[rand(@chars)];
}
my $input2 = '';
for my $i (1..8) {
    $input2 .= $chars[rand(@chars)];
}
#my $input3 = '';
#for my $i (1..8) {
#    $input3 .= $chars[rand(@chars)];
#}
print IN2 "IN2: $name TYPE: $type\n";
close IN2;

# Save input
#А-Я,а-я
if (($name =~ /[A-Za-z]/) and ($name =~ /[А-Яа-я]/)){
  ##Print ERROR MESSAGE saying one cannot mix Latin and Cyrillic scripts in the input
  $name = 'INVALID';
}
elsif ($name =~ /[A-Za-z]/){
open(IN, ">$tmpdir/$input2.txt");

	## On-Russische letters 
	## ' en " eruit filteren 
	$name =~ s/(['\‘\’\ʹ\"\“\”])e/ye/gi;
	$name =~ s/(['\‘\’\ʹ\"\“\”])ia/ia/gi;
	$name =~ s/(['\‘\’\ʹ\"\“\”])iu/iu/gi;
	$name =~ s/(['\‘\’\ʹ\"\“\”])i/yi/gi;
	$name =~ s/(['\‘\’\ʹ\"\“\”])o/yo/gi;
	$name =~ s/['\‘\’\ʹ\"\“\”]//g;
		
	## tc > ts; maffe paspoorttransliteratie voor ц opvangen; testen op h vanwege combinatie тч (tch)
	$name =~ s/(t|T)c([^h|^H]|$|[-\/,. ])/$1s$2/g;
	$name =~ s/(t|T)C([^h|^H]|$|[-\/,. ])/$1S$2/g;

## Suffixen fixen
## OP 22 DECEMBER HIERONDER skyi/skiy_kii/kyi/kiy_khii/khyi/khiy TOEGEVOEGD
## OP 29 DECEMBER ский_кий > skий_kий (zo min mogelijk nu al translitereren; ging fout bij Выучейский)
$name =~ s/(sky|skii|skyi|skiy)($|[-\/_ ])/skий$2/gi; ## Mikhailovsky_Mikhailovskii (niet: Mikhailovski_maar die gaat toch al redelijk goed)
$name =~ s/(ky|kii|kyi|kiy)($|[-\/_ ])/kий$2/gi; ## Blizky 
$name =~ s/(khy|khii|khyi|khiy)($|[-\/_ ])/khий$2/gi; ## Vetkhy

## De y en de i: wel of geen й?
$name =~ s/([aeiou])(y|i)([bvgdzklmnprstfch])/$1й$3/gi; ## Maydan_Maidan_Mikhail_Novorossiisk/Novorossiysk
$name =~ s/([bvgdzklmnprstfch])(ia)(^$|[^-\/_ ])/$1я$3/gi; ## Viazemsky (maar niet: Akademia; voor gevallen als Daria wordt later gecorrigeerd)
$name =~ s/([bvgdzklmnprstfch])(iu)(^$|[^-\/_ ])/$1ю$3/gi; ## Liudmila

## TOEGEVOEGD OP 22 DECEMBER
$name =~ s/(Zv)я(d)/$1ia$2/gi; ## Zvяd > Zviad (handmatige uitzondering op bovengenoemde vervanging)
$name =~ s/(D)я(n)/$1ia$2/gi; ## Dяn > Dian (handmatige uitzondering op bovengenoemde vervanging)
$name =~ s/(p)ю(s)/$1iu$2/gi; ## (Gip)pюs > (Gip)pius (handmatige uitzondering op bovengenoemde vervanging)

## EINDE TOEGEVOEGD OP 22 DECEMBER

## N.B. Voor valide leenwoorden met иа (диафрагма) en иу (радиус) wordt niet gecorrigeerd.
## N.B. Ook Aliona > Алёна wordt niet meegenomen.

## Dit moet Maiya_Mayya_Maiia > Maja bewerkstelligen. Idem: Nayyem_Naiyem > Najem
$name =~ s/([aeiou])(i|y)(ia|ya)/$1я/gi; 
$name =~ s/([aeiou])(i|y)(iu|yu)/$1ю/gi; 
$name =~ s/([aeiou])(i|y)(ie|ye)/$1е/gi; 
$name =~ s/([aeiou])(i|y)(io|yo)/$1ё/gi; 

## TOEGEVOEGD OP 24 DECEMBER: ya_ye_yu
$name =~ s/([aeiou])(ia|ya)/$1я/gi; 
$name =~ s/([aeiou])(ie|ye)/$1е/gi; 
$name =~ s/([aeiou])(iu|yu)/$1ю/gi; 
## EINDE TOEGEVOEGD OP 24 DECEMBER

## TOEGEVOEGD OP 30 NOVEMBER
$name =~ s/yye/ые/gi; ## Novye_...
## EINDE TOEGEVOEGD OP 30 NOVEMBER
## AANGESCHERPT OP 29 DECEMBER
$name =~ s/([A-Z_-z])ye($|[-\/_ ])/$1ые$2/gi; ## Novye_..._maar wel A.Ye. Yegorov > A.Je. Jegorov
$name =~ s/(yy|yi)($|[-\/_ ])/ый$2/gi; ## Novyy_Novyi

## HIER VERWIJDERD OP 25 DECEMBER_ACHTERAAN ANDERS TOEGEVOEGD; leverde een probleem op met Piskaryev_dat Piskarjev werd i.p.v. Piskarjov
##$name =~ s/([bvgdzklmnprstfch])y([ei])/$1ь$2/gi; ## Vasilyevich_Ilyich_...

$name =~ s/([aeiou])y($|[-\/_ ])/$1й$2/gi; ## Aleksey_Novoy
$name =~ s/([aeou])i($|[-\/_ ])/$1й$2/gi; ## Aleksei_Novoi (niet: Partii)

## TOEGEVOEGD OP 29 DECEMBER – Voor Iurii e.d.
$name =~ s/(^|[ -\/\.])Iu/$1Ю/gi;
$name =~ s/(^|[ -\/\.])Ia/$1Я/gi;
$name =~ s/(^|[ -\/\.])Ie/$1Е/gi;
#$name =~ s/(^|[ -\/\.])Io/$1Ё/gi; ##Flagged out 20160603
## TOEGEVOEGD OP 29 DECEMBER – Voor Iurii e.d.

print IN "$name\n";
close IN;
}
else {
    open(IN, ">$tmpdir/deaccent.txt");

###Volgende bevatten nog sporen van Javascriptcode van Pepijn en kunnen dus anders dan bedoeld werken!! Let op de komma in de letterklassen. Negeert '^' vooraan de klasse elk element ervan?
    
    $name =~ s/(^|[ -_\/])(Алена)([^А-Я,а-я]|$|[ -_\/,.])/$1Алёна$3/gi;
    $name =~ s/(^|[ -_\/])(Артем)([^и,ь]|$|[ -_\/,.])/$1Артём$3/gi;
    $name =~ s/(^|[ -_\/])(Матрена)([^А-Я,а-я]|$|[ -_\/,.])/$1Матрёна$3/gi;
    $name =~ s/(^|[ -_\/])(Петр)([^А-Я,а-я]|$|[ -_\/,.])/$1Пётр$3/gi;
    $name =~ s/(^|[ -_\/])(Парфен)([^А-Я,а-я]|$|[ -_\/,.])/$1Парфён$3/gi;
    $name =~ s/(^|[ -_\/])(Фекла)([^А-Я,а-я]|$|[ -_\/,.])/$1Фёкла$3/gi;
    $name =~ s/(^|[ -_\/])(Флена)([^А-Я,а-я]|$|[ -_\/,.])/$1Флёна$3/gi;
    $name =~ s/(^|[ -_\/])(Семен)([^А-Я,а-я]|$|[ -_\/,.])/$1Семён$3/gi;
    $name =~ s/(^|[ -_\/])(Федор)/$1Фёдор/gi;
    $name =~ s/(^|[ -_\/])(Соловьев)([А-Я,а-я]|$|[ -_\/,.])/$1Соловьёв$3/gi;
    $name =~ s/(^|[ -_\/])(Семенов)([А-Я,а-я]|$|[ -_\/,.])/$1Семёнов$3/gi;
    $name =~ s/(^|[ -_\/])(Воробьев)([А-Я,а-я]|$|[ -_\/,.])/$1Воробьёв$3/gi;
    $name =~ s/(^|[ -_\/])(Федоров)([А-Я,а-я]|$|[ -_\/,.])/$1Фёдоров$3/gi;
    $name =~ s/(^|[ -_\/])(Киселев)([А-Я,а-я]|$|[ -_\/,.])/$1Киселёв$3/gi;
    $name =~ s/(^|[ -_\/])(Ковалев)([А-Я,а-я]|$|[ -_\/,.])/$1Ковалёв$3/gi;
    $name =~ s/(^|[ -_\/])(Королев)([А-Я,а-я]|$|[ -_\/,.])/$1Королёв$3/gi;
    $name =~ s/(^|[ -_\/])(Пономарев)([А-Я,а-я]|$|[ -_\/,.])/$1Пономарёв$3/gi;
    $name =~ s/(^|[ -_\/])(Журавлев)([А-Я,а-я]|$|[ -_\/,.])/$1Журавлёв$3/gi;
    $name =~ s/(^|[ -_\/])(Аксенов)([А-Я,а-я]|$|[ -_\/,.],)/$1Аксёнов$3/gi;
    $name =~ s/(^|[ -_\/])(Селезнев)([А-Я,а-я]|$|[ -_\/,.])/$1Селезнёв$3/gi;
    $name =~ s/(^|[ -_\/])(Горбачев)([А-Я,а-я]|$|[ -_\/,.])/$1Горбачёв$3/gi;
    $name =~ s/(^|[ -_\/])(Муравьев)([А-Я,а-я]|$|[ -_\/,.])/$1Муравьёв$3/gi;
    $name =~ s/(^|[ -_\/])(Бобылев)([А-Я,а-я]|$|[ -_\/,.])/$1Бобылёв$3/gi;
    $name =~ s/(^|[ -_\/])(Белозеров)([А-Я,а-я]|$|[ -_\/,.])/$1Белозёров$3/gi;
    $name =~ s/(^|[ -_\/])(Лихачев)([А-Я,а-я]|$|[ -_\/,.])/$1Лихачёв$3/gi;
    $name =~ s/(^|[ -_\/])(Фомичев)([А-Я,а-я]|$|[ -_\/,.])/$1Фомичёв$3/gi;
    $name =~ s/(^|[ -_\/])(Пискарев)([А-Я,а-я]|$|[ -_\/,.])/$1Пискарёв$3/gi;
    $name =~ s/(^|[ -_\/])(Слепнев)([А-Я,а-я]|$|[ -_\/,.])/$1Слепнёв$3/gi;
    $name =~ s/(^|[ -_\/])(Хрущев)([А-Я,а-я]|$|[ -_\/,.])/$1Хрущёв$3/gi;
    $name =~ s/(^|[ -_\/])(Еременко)([А-Я,а-я]|$|[ -_\/,.])/$1Ерёменко$3/gi;
    $name =~ s/(^|[ -_\/])(Пугачев)([А-Я,а-я]|$|[ -_\/,.])/$1Пугачёв$3/gi;
    $name =~ s/(Аксенка)([^А-Я,а-я]|$|[ -_\/,.])/Аксёнка$2/gi;
    $name =~ s/(Алека)([^А-Я,а-я]|$|[ -_\/,.])/Алёка$2/gi;
    $name =~ s/(Аленя)([^А-Я,а-я]|$|[ -_\/,.])/Алёня$2/gi;
    $name =~ s/(Алеха)([^А-Я,а-я]|$|[ -_\/,.])/Алёха$2/gi;
    $name =~ s/(Алеша)([^А-Я,а-я]|$|[ -_\/,.])/Алёша$2/gi;
    $name =~ s/(Аленка)([^А-Я,а-я]|$|[ -_\/,.])/Алёнка$2/gi;
    $name =~ s/(Артема)([^А-Я,а-я]|$|[ -_\/,.])/Артёма$2/gi;
    $name =~ s/(Артемка)([^А-Я,а-я]|$|[ -_\/,.])/Артёмка$2/gi;
    $name =~ s/(Артемчик)([^А-Я,а-я]|$|[ -_\/,.])/Артёмчик$2/gi;
    $name =~ s/(Артеша)([^А-Я,а-я]|$|[ -_\/,.])/Артёша$2/gi;
    $name =~ s/(Валена)([^А-Я,а-я]|$|[ -_\/,.])/Валёна$2/gi;
    $name =~ s/(Васена)([^А-Я,а-я]|$|[ -_\/,.])/Васёна$2/gi;
    $name =~ s/(Васеня)([^А-Я,а-я]|$|[ -_\/,.])/Васёня$2/gi;
    $name =~ s/(Василек)([^А-Я,а-я]|$|[ -_\/,.])/Василёк$2/gi;
    $name =~ s/(Витеша)([^А-Я,а-я]|$|[ -_\/,.])/Витёша$2/gi;
    $name =~ s/(Галек)([^А-Я,а-я]|$|[ -_\/,.])/Галёк$2/gi;
    $name =~ s/(Галека)([^А-Я,а-я]|$|[ -_\/,.])/Галёка$2/gi;
    $name =~ s/(Данек)([^А-Я,а-я]|$|[ -_\/,.])/Данёк$2/gi;
    $name =~ s/(Дарена)([^А-Я,а-я]|$|[ -_\/,.])/Дарёна$2/gi;
    $name =~ s/(Дареха)([^А-Я,а-я]|$|[ -_\/,.])/Дарёха$2/gi;
    $name =~ s/(Дареша)([^А-Я,а-я]|$|[ -_\/,.])/Дарёша$2/gi;
    $name =~ s/(Дема)([^А-Я,а-я]|$|[ -_\/,.])/Дёма$2/gi;
    $name =~ s/(Ерема)([^А-Я,а-я]|$|[ -_\/,.])/Ерёма$2/gi;
    $name =~ s/(Ела)([^А-Я,а-я]|$|[ -_\/,.])/Ёла$2/gi;
    $name =~ s/(Звездочка)([^А-Я,а-я]|$|[ -_\/,.])/Звёздочка$2/gi;
    $name =~ s/(Игорек)([^А-Я,а-я]|$|[ -_\/,.])/Игорёк$2/gi;
    $name =~ s/(Катена)([^А-Я,а-я]|$|[ -_\/,.])/Катёна$2/gi;
    $name =~ s/(Клена)([^А-Я,а-я]|$|[ -_\/,.])/Клёна$2/gi;
    $name =~ s/(Кленя)([^А-Я,а-я]|$|[ -_\/,.])/Клёня$2/gi;
    $name =~ s/(Клепа)([^А-Я,а-я]|$|[ -_\/,.])/Клёпа$2/gi;
    $name =~ s/(Ксена)([^А-Я,а-я]|$|[ -_\/,.])/Ксёна$2/gi;
    $name =~ s/(Кузена)([^А-Я,а-я]|$|[ -_\/,.])/Кузёна$2/gi;
    $name =~ s/(Лева)([^А-Я,а-я]|$|[ -_\/,.])/Лёва$2/gi;
    $name =~ s/(Лека)([^А-Я,а-я]|$|[ -_\/,.])/Лёка$2/gi;
    $name =~ s/(Лекса)([^А-Я,а-я]|$|[ -_\/,.])/Лёкса$2/gi;
    $name =~ s/(Лекся)([^А-Я,а-я]|$|[ -_\/,.])/Лёкся$2/gi;
    $name =~ s/(Леля)([^А-Я,а-я]|$|[ -_\/,.])/Лёля$2/gi;
    $name =~ s/(Леня)([^А-Я,а-я]|$|[ -_\/,.])/Лёня$2/gi;
    $name =~ s/(Лера)([^А-Я,а-я]|$|[ -_\/,.])/Лёра$2/gi;
    $name =~ s/(Леся)([^А-Я,а-я]|$|[ -_\/,.])/Лёся$2/gi;
    $name =~ s/(Леха)([^А-Я,а-я]|$|[ -_\/,.])/Лёха$2/gi;
    $name =~ s/(Леша)([^А-Я,а-я]|$|[ -_\/,.])/Лёша$2/gi;
    $name =~ s/(Матренка)([^А-Я,а-я]|$|[ -_\/,.])/Матрёнка$2/gi;
    $name =~ s/(Матреха)([^А-Я,а-я]|$|[ -_\/,.])/Матрёха$2/gi;
    $name =~ s/(Матреша)([^А-Я,а-я]|$|[ -_\/,.])/Матрёша$2/gi;
    $name =~ s/(Мелеха)([^А-Я,а-я]|$|[ -_\/,.])/Мелёха$2/gi;
    $name =~ s/(Мелеша)([^А-Я,а-я]|$|[ -_\/,.])/Мелёша$2/gi;
    $name =~ s/(Надена)([^А-Я,а-я]|$|[ -_\/,.])/Надёна$2/gi;
    $name =~ s/(Надеха)([^А-Я,а-я]|$|[ -_\/,.])/Надёха$2/gi;
    $name =~ s/(Настена)([^А-Я,а-я]|$|[ -_\/,.])/Настёна$2/gi;
    $name =~ s/(Настеха)([^А-Я,а-я]|$|[ -_\/,.])/Настёха$2/gi;
    $name =~ s/(Нема)([^А-Я,а-я]|$|[ -_\/,.])/Нёма$2/gi;
    $name =~ s/(Нефедка)([^А-Я,а-я]|$|[ -_\/,.])/Нефёдка$2/gi;
    $name =~ s/(Олена)([^А-Я,а-я]|$|[ -_\/,.])/Олёна$2/gi;
    $name =~ s/(Панферка)([^А-Я,а-я]|$|[ -_\/,.])/Панфёрка$2/gi;
    $name =~ s/(Парменка)([^А-Я,а-я]|$|[ -_\/,.])/Пармёнка$2/gi;
    $name =~ s/(Пармеха)([^А-Я,а-я]|$|[ -_\/,.])/Пармёха$2/gi;
    $name =~ s/(Пармеша)([^А-Я,а-я]|$|[ -_\/,.])/Пармёша$2/gi;
    $name =~ s/(Парфенка)([^А-Я,а-я]|$|[ -_\/,.])/Парфёнка$2/gi;
    $name =~ s/(Парфеха)([^А-Я,а-я]|$|[ -_\/,.])/Парфёха$2/gi;
    $name =~ s/(Петеха)([^А-Я,а-я]|$|[ -_\/,.])/Петёха$2/gi;
    $name =~ s/(Петеша)([^А-Я,а-я]|$|[ -_\/,.])/Петёша$2/gi;
    $name =~ s/(Селиверстка)([^А-Я,а-я]|$|[ -_\/,.])/Селивёрстка$2/gi;
    $name =~ s/(Сема)([^А-Я,а-я]|$|[ -_\/,.])/Сёма$2/gi;
    $name =~ s/(Семенка)([^А-Я,а-я]|$|[ -_\/,.])/Семёнка$2/gi;
    $name =~ s/(Сережа)([^А-Я,а-я]|$|[ -_\/,.])/Серёжа$2/gi;
    $name =~ s/(Сереня)([^А-Я,а-я]|$|[ -_\/,.])/Серёня$2/gi;
    $name =~ s/(Сильверстка)([^А-Я,а-я]|$|[ -_\/,.])/Сильвёрстка$2/gi;
    $name =~ s/(Степа)([^А-Я,а-я]|$|[ -_\/,.])/Стёпа$2/gi;
    $name =~ s/(Тена)([^А-Я,а-я]|$|[ -_\/,.])/Тёна$2/gi;
    $name =~ s/(Тереня)([^А-Я,а-я]|$|[ -_\/,.])/Терёня$2/gi;
    $name =~ s/(Тереха)([^А-Я,а-я]|$|[ -_\/,.])/Терёха$2/gi;
    $name =~ s/(Тереша)([^А-Я,а-я]|$|[ -_\/,.])/Терёша$2/gi;
    $name =~ s/(Теша)([^А-Я,а-я]|$|[ -_\/,.])/Тёша$2/gi;
    $name =~ s/(Федорка)([^А-Я,а-я]|$|[ -_\/,.])/Фёдорка$2/gi;
    $name =~ s/(Феклушка)([^А-Я,а-я]|$|[ -_\/,.])/Фёклушка$2/gi;
    $name =~ s/(Фефелка)([^А-Я,а-я]|$|[ -_\/,.])/Фефёлка$2/gi;
    $name =~ s/(Фленка)([^А-Я,а-я]|$|[ -_\/,.])/Флёнка$2/gi;
    $name =~ s/(Христена)([^А-Я,а-я]|$|[ -_\/,.])/Христёна$2/gi;
    $name =~ s/(Христеня)([^А-Я,а-я]|$|[ -_\/,.])/Христёня$2/gi;
    $name =~ s/(Шурена)([^А-Я,а-я]|$|[ -_\/,.])/Шурёна$2/gi;
    
    print IN "$name\n";
    close IN;
`$rootdir/Accent.flex <$tmpdir/deaccent.txt >$tmpdir/$input.txt`;     
}

# Read Taalunie file
my %TU = ();
open (TU, "$rootdir/taalunie.tsv");
while (my $tu = <TU>) {
    chomp $tu;
    my @TU = split '\t', $tu;
    $TU{$TU[0]} = $TU[1];
}
close TU;

# Initialize generator
my $generator = Transliterator::HTMLFactory->new(\%TU, $type);
#my $generator = Transliterator::HTMLFactory->new(%TU, $type);
my @output = ();
#if ($debug =~ /D/){
my @debug = ();
my $nlpop = ();
my $eng = ();
my $germanpop = ();
my $effe = ();
#}

# Run all transliterators and add output to generator
if ($name =~ /[A-Za-z]/){
  if ($name =~ /^INVALID$/){
  ##Print ERROR MESSAGE saying one cannot mix Latin and Cyrillic scripts in the input
  #$generator->addOutput('populair', $nlpop);
    #push @output, $generator->addOutput('populair', '<span class="na_field">Invalid Input: Please do not mix Latin and Cyrillic scripts in the input.</span>');
    push @output, $generator->addOutput('populair', '<span class="na_field">Ongeldige Input: Gelieve de Latijnse en Cyrillische scripts niet te mengen in de input.</span>');
  }
  else {    
    open(IN3, ">$tmpdir/$input.txt");
    `$rootdir/ENG-RUS.flex <$tmpdir/$input2.txt >$tmpdir/SEEINPUT2.txt`;
    open(INNEW, "$tmpdir/SEEINPUT2.txt");
	while (my $in2 = <INNEW>) {
	    #print STDERR "IN2a: $name >> $in2";
	    ##Als een naam op Е niet met Ye wordt getranslitereerd (Evgeny), dan hier fixen
		## mannennamen
	    #$in2 =~ s/(^|[ -_\/])Е(вген|вграф|вдок|влам|влог|вмен|все|вст|втих|вфим|гор|лизар|лисе|лист|ллиди|мель|пифан|реме|рми|рмол|роф|фим|фрем)/$1Э$2/gi;
	    $in2 =~ s/^Е(вген|вграф|вдок|влам|влог|вмен|все|вст|втих|вфим|гор|лизар|лисе|лист|ллиди|мель|пифан|реме|рми|рмол|роф|фим|фрем)/ЙЕ$1/gi;
	    $in2 =~ s/([ -_\/])Е(вген|вграф|вдок|влам|влог|вмен|все|вст|втих|вфим|гор|лизар|лисе|лист|ллиди|мель|пифан|реме|рми|рмол|роф|фим|фрем)/$1ЙЕ$2/gi;
	    ## vrouwennamen
	    #$in2 =~ s/(^|[ -_\/])Е(ва|вангел|влали|вламп|впрак|встол|вфроси|катер|лен|лизавет|ликони|пистим|фросин)/$1Э$2/gi;
	    $in2 =~ s/^Е(ва|вангел|влали|вламп|впрак|встол|вфроси|катер|лен|лизавет|ликони|пистим|фросин)/ЙЕ$1/gi;
	    $in2 =~ s/([ -_\/])Е(ва|вангел|влали|вламп|впрак|встол|вфроси|катер|лен|лизавет|ликони|пистим|фросин)/$1ЙЕ$2/gi;
	    ## achternamen; bron http://gufo.me/fam_a#abc
	    #$in2 =~ s/(^|[ -_\/])Е(вге|вгр|вда|вдо|вкл|вла|вле|вло|вме|впа|впл|впс|вре|все|вси|вст|всю|вте|вти|втр|вту|втю|втя|ган|гер|гин|гол|гон|гор|гош|гун|два|дем|дов|дом|жев|жик|жко|жов|зер|кат|кди|ким|кот|лаг|лан|лат|лах|лдо|леа|лем|лен|лео|лес|леф|лец|лиз|лик|лин|лис|лих|лиш|лки|лох|лпа|лпи|лук|лух|лче|лчи|лши|лм|лф|лц|лч|лш|ля|лют|ляк|ман|мел|мел|мцо|мча|мша|мяш|нак|ник|нох|нтал|нк|нют|нюш|оах|пан|пеш|пиф|пих|пиш|пищ|рак|ран|рас|рах|раш|рга|ргин|рго|рем|рил|рин|рих|рки|рко|рлы|рма|рми|рмо|рму|рог|рон|роп|ротид|роф|рох|рош|руш|рхо|рша|рши|ршо|рыг|рык|рюх|рюш|сау|саф|сен|син|сип|сич|скин|стигн|стиф|ськи|сько|фан|фим|фиш|фре|фро|фте|чеи|чме|шко|шур)/$1Э$2/gi;
	    $in2 =~ s/^Е(вге|вгр|вда|вдо|вкл|вла|вле|вло|вме|впа|впл|впс|вре|все|вси|вст|всю|вте|вти|втр|вту|втю|втя|ган|гер|гин|гол|гон|гор|гош|гун|два|дем|дов|дом|жев|жик|жко|жов|зер|кат|кди|ким|кот|лаг|лан|лат|лах|лдо|леа|лем|лен|лео|лес|леф|лец|лиз|лик|лин|лис|лих|лиш|лки|лох|лпа|лпи|лук|лух|лче|лчи|лши|лм|лф|лц|лч|лш|ля|лют|ляк|ман|мел|мцо|мча|мша|мяш|нак|ник|нох|нтал|нк|нют|нюш|оах|пан|пеш|пиф|пих|пиш|пищ|рак|ран|рас|рах|раш|рга|ргин|рго|рем|рил|рин|рих|рки|рко|рлы|рма|рми|рмо|рму|рог|рон|роп|ротид|роф|рох|рош|руш|рхо|рша|рши|ршо|рыг|рык|рюх|рюш|сау|саф|сен|син|сип|сич|скин|стигн|стиф|ськи|сько|фан|фим|фиш|фре|фро|фте|чеи|чме|шко|шур)/ЙЕ$1/gi;
	    $in2 =~ s/([ -_\/])Е(вге|вгр|вда|вдо|вкл|вла|вле|вло|вме|впа|впл|впс|вре|все|вси|вст|всю|вте|вти|втр|вту|втю|втя|ган|гер|гин|гол|гон|гор|гош|гун|два|дем|дов|дом|жев|жик|жко|жов|зер|кат|кди|ким|кот|лаг|лан|лат|лах|лдо|леа|лем|лен|лео|лес|леф|лец|лиз|лик|лин|лис|лих|лиш|лки|лох|лпа|лпи|лук|лух|лче|лчи|лши|лм|лф|лц|лч|лш|ля|лют|ляк|ман|мел|мцо|мча|мша|мяш|нак|ник|нох|нтал|нк|нют|нюш|оах|пан|пеш|пиф|пих|пиш|пищ|рак|ран|рас|рах|раш|рга|ргин|рго|рем|рил|рин|рих|рки|рко|рлы|рма|рми|рмо|рму|рог|рон|роп|ротид|роф|рох|рош|руш|рхо|рша|рши|ршо|рыг|рык|рюх|рюш|сау|саф|сен|син|сип|сич|скин|стигн|стиф|ськи|сько|фан|фим|фиш|фре|фро|фте|чеи|чме|шко|шур)/$1ЙЕ$2/gi;

##NEW MRE 2016-06-06
#	// Zachte adjectieven op -ний
#	// AANGEPAST OP 22 DECEMBER: samengevoegd, en alternatieve uitgangen toegevoegd: ook type Nizhnii en Nizhnyi wordt nu meegenomen
#	// Verdubbeling van deze regel moet vanwege de spatiematch aan het begin én het eind.
#	engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(^|[ -\/])(ближн|верхн|весенн|вечерн|внешн|внутренн|горн|давн|далн|долн|древн|задн|зимн|искренн|крайн|летн|#лишн|нижн|осенн|передн|поздн|последн|прежн|ранн|син|сосдедн|средн|сторонн|утренн)(ы|ый|ии)($|[ -\/,.])/gi, "$1$2ий$4");
	    #	engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(^|[ -\/])(ближн|верхн|весенн|вечерн|внешн|внутренн|горн|давн|далн|долн|древн|задн|зимн|искренн|крайн|летн|#лишн|нижн|осенн|передн|поздн|последн|прежн|ранн|син|сосдедн|средн|сторонн|утренн)(ы|ый|ии)($|[ -\/,.])/gi, "$1$2ий$4");

	    $in2 =~ s/([ -_\/])(ближн|верхн|весенн|вечерн|внешн|внутренн|горн|давн|далн|долн|древн|задн|зимн|искренн|крайн|летн|лишн|нижн|осенн|передн|поздн|последн|прежн|ранн|син|сосдедн|средн|сторонн|утренн)(ы|ый|ии)($|[ -_\/,.])/$1$2ий$4/gi;
	    $in2 =~ s/([ -_\/])(ближн|верхн|весенн|вечерн|внешн|внутренн|горн|давн|далн|долн|древн|задн|зимн|искренн|крайн|летн|лишн|нижн|осенн|передн|поздн|последн|прежн|ранн|син|сосдедн|средн|сторонн|утренн)(а)/$1$2я/gi;

	    $in2 =~ s/([бвгдзжйклмнпрстфхцчшщ])ы(ев)/1ь$2/gi;
	    $in2 =~ s/([бвгдзжйклмнпрстфхцчшщ])ы(и[чн])/$1ь$2/gi;

	    $in2 =~ s/(Нижне)е(токский)/$1э$2/gi;
	    $in2 =~ s/(У)е(лен)/$1э$2/gi;

#	// TOEGEVOEGD OP 22 DECEMBER: voor de zekerheid ook vrouwelijke vormen als Nizhnaya gefixt: > Nizhnyaya
#	engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(^|[ -\/])(ближн|верхн|весенн|вечерн|внешн|внутренн|горн|давн|далн|долн|древн|задн|зимн|искренн|крайн|летн|#лишн|нижн|осенн|передн|поздн|последн|прежн|ранн|син|сосдедн|средн|сторонн|утренн)(а)/gi, "$1$2я");

#	// TOEGEVOEGD OP 25 DECEMBER
#
#	engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/([бвгдзжйклмнпрстфхцчшщ])ы(ев)/gi, "$1ь$2"); // , Vasilyevna
#	engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/([бвгдзжйклмнпрстфхцчшщ])ы(и[чн])/gi, "$1ь$2"); // Ilyich, Ilyino...
#
#	// HANDMATIGE UITZONDERINGEN
#	engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(Нижне)(е)(токский)/gi, "$1э$3"); // Нижнеэтокский
#	engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(У)(е)(лен)/gi, "$1э$3"); // Уэлен
##NEW MRE 2016-06-06
	    
	    ##NEW - mre
    $in2 =~ s/(^|[ -_\/])(Алена)([^А-Я,а-я]|$|[ -_\/,.])/$1Алёна$3/gi;
    $in2 =~ s/(^|[ -_\/])(Артем)([^и]|$|[ -_\/,.])/$1Артём$3/gi;
    $in2 =~ s/(^|[ -_\/])(Матрена)([^А-Я,а-я]|$|[ -_\/,.])/$1Матрёна$3/gi;
    $in2 =~ s/(^|[ -_\/])(Петр)([^А-Я,а-я]|$|[ -_\/,.])/$1Пётр$3/gi;
    $in2 =~ s/(^|[ -_\/])(Парфен)([^А-Я,а-я]|$|[ -_\/,.])/$1Парфён$3/gi;
    $in2 =~ s/(^|[ -_\/])(Фекла)([^А-Я,а-я]|$|[ -_\/,.])/$1Фёкла$3/gi;
    $in2 =~ s/(^|[ -_\/])(Флена)([^А-Я,а-я]|$|[ -_\/,.])/$1Флёна$3/gi;
    $in2 =~ s/(^|[ -_\/])(Семен)([^А-Я,а-я]|$|[ -_\/,.])/$1Семён$3/gi;
    $in2 =~ s/(^|[ -_\/])(Федор)/$1Фёдор/gi;
    $in2 =~ s/(^|[ -_\/])(Соловьев)([А-Я,а-я]|$|[ -_\/,.])/$1Соловьёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Семенов)([А-Я,а-я]|$|[ -_\/,.])/$1Семёнов$3/gi;
    $in2 =~ s/(^|[ -_\/])(Воробьев)([А-Я,а-я]|$|[ -_\/,.])/$1Воробьёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Федоров)([А-Я,а-я]|$|[ -_\/,.])/$1Фёдоров$3/gi;
    $in2 =~ s/(^|[ -_\/])(Киселев)([А-Я,а-я]|$|[ -_\/,.])/$1Киселёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Ковалев)([А-Я,а-я]|$|[ -_\/,.])/$1Ковалёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Королев)([А-Я,а-я]|$|[ -_\/,.])/$1Королёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Пономарев)([А-Я,а-я]|$|[ -_\/,.])/$1Пономарёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Журавлев)([А-Я,а-я]|$|[ -_\/,.])/$1Журавлёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Аксенов)([А-Я,а-я]|$|[ -_\/,.],)/$1Аксёнов$3/gi;
    $in2 =~ s/(^|[ -_\/])(Селезнев)([А-Я,а-я]|$|[ -_\/,.])/$1Селезнёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Горбачев)([А-Я,а-я]|$|[ -_\/,.])/$1Горбачёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Муравьев)([А-Я,а-я]|$|[ -_\/,.])/$1Муравьёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Бобылев)([А-Я,а-я]|$|[ -_\/,.])/$1Бобылёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Белозеров)([А-Я,а-я]|$|[ -_\/,.])/$1Белозёров$3/gi;
    $in2 =~ s/(^|[ -_\/])(Лихачев)([А-Я,а-я]|$|[ -_\/,.])/$1Лихачёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Фомичев)([А-Я,а-я]|$|[ -_\/,.])/$1Фомичёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Пискарев)([А-Я,а-я]|$|[ -_\/,.])/$1Пискарёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Слепнев)([А-Я,а-я]|$|[ -_\/,.])/$1Слепнёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Хрущев)([А-Я,а-я]|$|[ -_\/,.])/$1Хрущёв$3/gi;
    $in2 =~ s/(^|[ -_\/])(Еременко)([А-Я,а-я]|$|[ -_\/,.])/$1Ерёменко$3/gi;
    $in2 =~ s/(^|[ -_\/])(Пугачев)([А-Я,а-я]|$|[ -_\/,.])/$1Пугачёв$3/gi;
        $in2 =~ s/(Аксенка)([^А-Я,а-я]|$|[ -_\/,.])/Аксёнка$2/gi;
    $in2 =~ s/(Алека)([^А-Я,а-я]|$|[ -_\/,.])/Алёка$2/gi;
    $in2 =~ s/(Аленя)([^А-Я,а-я]|$|[ -_\/,.])/Алёня$2/gi;
    $in2 =~ s/(Алеха)([^А-Я,а-я]|$|[ -_\/,.])/Алёха$2/gi;
    $in2 =~ s/(Алеша)([^А-Я,а-я]|$|[ -_\/,.])/Алёша$2/gi;
    $in2 =~ s/(Аленка)([^А-Я,а-я]|$|[ -_\/,.])/Алёнка$2/gi;
    $in2 =~ s/(Артема)([^А-Я,а-я]|$|[ -_\/,.])/Артёма$2/gi;
    $in2 =~ s/(Артемка)([^А-Я,а-я]|$|[ -_\/,.])/Артёмка$2/gi;
    $in2 =~ s/(Артемчик)([^А-Я,а-я]|$|[ -_\/,.])/Артёмчик$2/gi;
    $in2 =~ s/(Артеша)([^А-Я,а-я]|$|[ -_\/,.])/Артёша$2/gi;
    $in2 =~ s/(Валена)([^А-Я,а-я]|$|[ -_\/,.])/Валёна$2/gi;
    $in2 =~ s/(Васена)([^А-Я,а-я]|$|[ -_\/,.])/Васёна$2/gi;
    $in2 =~ s/(Васеня)([^А-Я,а-я]|$|[ -_\/,.])/Васёня$2/gi;
    $in2 =~ s/(Василек)([^А-Я,а-я]|$|[ -_\/,.])/Василёк$2/gi;
    $in2 =~ s/(Витеша)([^А-Я,а-я]|$|[ -_\/,.])/Витёша$2/gi;
    $in2 =~ s/(Галек)([^А-Я,а-я]|$|[ -_\/,.])/Галёк$2/gi;
    $in2 =~ s/(Галека)([^А-Я,а-я]|$|[ -_\/,.])/Галёка$2/gi;
    $in2 =~ s/(Данек)([^А-Я,а-я]|$|[ -_\/,.])/Данёк$2/gi;
    $in2 =~ s/(Дарена)([^А-Я,а-я]|$|[ -_\/,.])/Дарёна$2/gi;
    $in2 =~ s/(Дареха)([^А-Я,а-я]|$|[ -_\/,.])/Дарёха$2/gi;
    $in2 =~ s/(Дареша)([^А-Я,а-я]|$|[ -_\/,.])/Дарёша$2/gi;
    $in2 =~ s/(Дема)([^А-Я,а-я]|$|[ -_\/,.])/Дёма$2/gi;
    $in2 =~ s/(Ерема)([^А-Я,а-я]|$|[ -_\/,.])/Ерёма$2/gi;
    $in2 =~ s/(Ела)([^А-Я,а-я]|$|[ -_\/,.])/Ёла$2/gi;
    $in2 =~ s/(Звездочка)([^А-Я,а-я]|$|[ -_\/,.])/Звёздочка$2/gi;
    $in2 =~ s/(Игорек)([^А-Я,а-я]|$|[ -_\/,.])/Игорёк$2/gi;
    $in2 =~ s/(Катена)([^А-Я,а-я]|$|[ -_\/,.])/Катёна$2/gi;
    $in2 =~ s/(Клена)([^А-Я,а-я]|$|[ -_\/,.])/Клёна$2/gi;
    $in2 =~ s/(Кленя)([^А-Я,а-я]|$|[ -_\/,.])/Клёня$2/gi;
    $in2 =~ s/(Клепа)([^А-Я,а-я]|$|[ -_\/,.])/Клёпа$2/gi;
    $in2 =~ s/(Ксена)([^А-Я,а-я]|$|[ -_\/,.])/Ксёна$2/gi;
    $in2 =~ s/(Кузена)([^А-Я,а-я]|$|[ -_\/,.])/Кузёна$2/gi;
    $in2 =~ s/(Лева)([^А-Я,а-я]|$|[ -_\/,.])/Лёва$2/gi;
    $in2 =~ s/(Лека)([^А-Я,а-я]|$|[ -_\/,.])/Лёка$2/gi;
    $in2 =~ s/(Лекса)([^А-Я,а-я]|$|[ -_\/,.])/Лёкса$2/gi;
    $in2 =~ s/(Лекся)([^А-Я,а-я]|$|[ -_\/,.])/Лёкся$2/gi;
    $in2 =~ s/(Леля)([^А-Я,а-я]|$|[ -_\/,.])/Лёля$2/gi;
    $in2 =~ s/(Леня)([^А-Я,а-я]|$|[ -_\/,.])/Лёня$2/gi;
    $in2 =~ s/(Лера)([^А-Я,а-я]|$|[ -_\/,.])/Лёра$2/gi;
    $in2 =~ s/(Леся)([^А-Я,а-я]|$|[ -_\/,.])/Лёся$2/gi;
    $in2 =~ s/(Леха)([^А-Я,а-я]|$|[ -_\/,.])/Лёха$2/gi;
    $in2 =~ s/(Леша)([^А-Я,а-я]|$|[ -_\/,.])/Лёша$2/gi;
        $in2 =~ s/(Матренка)([^А-Я,а-я]|$|[ -_\/,.])/Матрёнка$2/gi;
    $in2 =~ s/(Матреха)([^А-Я,а-я]|$|[ -_\/,.])/Матрёха$2/gi;
    $in2 =~ s/(Матреша)([^А-Я,а-я]|$|[ -_\/,.])/Матрёша$2/gi;
    $in2 =~ s/(Мелеха)([^А-Я,а-я]|$|[ -_\/,.])/Мелёха$2/gi;
    $in2 =~ s/(Мелеша)([^А-Я,а-я]|$|[ -_\/,.])/Мелёша$2/gi;
    $in2 =~ s/(Надена)([^А-Я,а-я]|$|[ -_\/,.])/Надёна$2/gi;
    $in2 =~ s/(Надеха)([^А-Я,а-я]|$|[ -_\/,.])/Надёха$2/gi;
    $in2 =~ s/(Настена)([^А-Я,а-я]|$|[ -_\/,.])/Настёна$2/gi;
    $in2 =~ s/(Настеха)([^А-Я,а-я]|$|[ -_\/,.])/Настёха$2/gi;
    $in2 =~ s/(Нема)([^А-Я,а-я]|$|[ -_\/,.])/Нёма$2/gi;
    $in2 =~ s/(Нефедка)([^А-Я,а-я]|$|[ -_\/,.])/Нефёдка$2/gi;
    $in2 =~ s/(Олена)([^А-Я,а-я]|$|[ -_\/,.])/Олёна$2/gi;
    $in2 =~ s/(Панферка)([^А-Я,а-я]|$|[ -_\/,.])/Панфёрка$2/gi;
    $in2 =~ s/(Парменка)([^А-Я,а-я]|$|[ -_\/,.])/Пармёнка$2/gi;
    $in2 =~ s/(Пармеха)([^А-Я,а-я]|$|[ -_\/,.])/Пармёха$2/gi;
    $in2 =~ s/(Пармеша)([^А-Я,а-я]|$|[ -_\/,.])/Пармёша$2/gi;
    $in2 =~ s/(Парфенка)([^А-Я,а-я]|$|[ -_\/,.])/Парфёнка$2/gi;
    $in2 =~ s/(Парфеха)([^А-Я,а-я]|$|[ -_\/,.])/Парфёха$2/gi;
    $in2 =~ s/(Петеха)([^А-Я,а-я]|$|[ -_\/,.])/Петёха$2/gi;
    $in2 =~ s/(Петеша)([^А-Я,а-я]|$|[ -_\/,.])/Петёша$2/gi;
    $in2 =~ s/(Селиверстка)([^А-Я,а-я]|$|[ -_\/,.])/Селивёрстка$2/gi;
    $in2 =~ s/(Сема)([^А-Я,а-я]|$|[ -_\/,.])/Сёма$2/gi;
    $in2 =~ s/(Семенка)([^А-Я,а-я]|$|[ -_\/,.])/Семёнка$2/gi;
    $in2 =~ s/(Сережа)([^А-Я,а-я]|$|[ -_\/,.])/Серёжа$2/gi;
    $in2 =~ s/(Сереня)([^А-Я,а-я]|$|[ -_\/,.])/Серёня$2/gi;
    $in2 =~ s/(Сильверстка)([^А-Я,а-я]|$|[ -_\/,.])/Сильвёрстка$2/gi;
    $in2 =~ s/(Степа)([^А-Я,а-я]|$|[ -_\/,.])/Стёпа$2/gi;
    $in2 =~ s/(Тена)([^А-Я,а-я]|$|[ -_\/,.])/Тёна$2/gi;
    $in2 =~ s/(Тереня)([^А-Я,а-я]|$|[ -_\/,.])/Терёня$2/gi;
    $in2 =~ s/(Тереха)([^А-Я,а-я]|$|[ -_\/,.])/Терёха$2/gi;
    $in2 =~ s/(Тереша)([^А-Я,а-я]|$|[ -_\/,.])/Терёша$2/gi;
    $in2 =~ s/(Теша)([^А-Я,а-я]|$|[ -_\/,.])/Тёша$2/gi;
    $in2 =~ s/(Федорка)([^А-Я,а-я]|$|[ -_\/,.])/Фёдорка$2/gi;
    $in2 =~ s/(Феклушка)([^А-Я,а-я]|$|[ -_\/,.])/Фёклушка$2/gi;
    $in2 =~ s/(Фефелка)([^А-Я,а-я]|$|[ -_\/,.])/Фефёлка$2/gi;
    $in2 =~ s/(Фленка)([^А-Я,а-я]|$|[ -_\/,.])/Флёнка$2/gi;
    $in2 =~ s/(Христена)([^А-Я,а-я]|$|[ -_\/,.])/Христёна$2/gi;
    $in2 =~ s/(Христеня)([^А-Я,а-я]|$|[ -_\/,.])/Христёня$2/gi;
    $in2 =~ s/(Шурена)([^А-Я,а-я]|$|[ -_\/,.])/Шурёна$2/gi;
	    ##NEW - mre
    ##Added 20160603 MRE
            #engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(^|[ -\/])Чернышев($|[-\/,. ]|[аеоыу])/gi, "$1Чернышёв$2"); // Afwijkend, want het is wel Чернышевский
    $in2 =~ s/(^|[ -\/])Чернышев($|[-\/,. ]|[аеоыу])/$1Чернышёв$2/gi;
	    
    #Евгеневич
    #$in2 =~ s/(^|[ -_\/])(Анатол|Аркад|Арсен|Артем|Васил|Валер|Витал|Геннад|Георг|Григор|Евген|Юр)(ев|иев)/$1$2ьев/g; ##MRE 20160503
	    $in2 =~ s/(Анатол|Аркад|Арсен|Артем|Васил|Валер|Витал|Геннад|Григор|Евген|Юр)ев/$1йев/g; ##MRE 20160503 201600603 Георг| verwijderd
	    $in2 =~ s/(Анатол|Аркад|Арсен|Артем|Васил|Валер|Витал|Геннад|Григор|Евген|Юр)иев/$1йев/g; ##MRE 20160503 201600603 Георг| verwijderd

	    #Анатол|Аркад|Арсен|Артем|Васил|Валер|Витал|Геннад|Григор|Евген|Юр
	    
	    ## Individuele namen fixen
		#engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/Александер/gi, "Александр"); // Alexander, Aleksander, ...
		#engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(^|[ -\/])Михайл($|[-\/,. ])/gi, "$1Михаил$2");
         	#engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(^|[ -\/])Тчай/gi, "$1Чай");// Tchai(kovsky)
		#engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(^|[ -\/])Венями/gi, "$1Вениами");// Вениамин
		#engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(^|[ -\/])Ил(ич)/gi, "$1Иль$2");// Ilich > Ильич
		#engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/([А-Я,a-я])(в)(ев|ева|еве|еву|евым|евых|евыми|евой)($|[-\/,. ])/gi, "$1$2ь$3$4"); // Solovyev

	    $in2 =~ s/Александер/Александр/gi;
	    $in2 =~ s/(^|[ -\/])Михайл($|[-\/,. ])/$1Михаил$2/gi;
	    $in2 =~ s/(^|[ -\/])Тчай/$1Чай/gi;
	    $in2 =~ s/(^|[ -\/])Венями/$1Вениами/gi;
	    $in2 =~ s/(^|[ -\/])Ил(ич)/$1Иль$2/gi;

	    ##Added 201600603 MRE
            #engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(Д)(жулет)/gi, "$1жульет"); // Джульетта
            #engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(Г)(аврийл)/gi, "$1авриил"); // Гавриил
            #engels_cyrillisch_uitvoer = engels_cyrillisch_uitvoer.replace(/(Д)(анийл)/gi, "$1аниил"); // Даниил
            #$in2 =~ s/(^|[ -\/])//gi;
	    $in2 =~ s/Джулет/Джульет/gi; 
	    $in2 =~ s/Гаврийл/Гавриил/gi;
	    $in2 =~ s/Данийл/Даниил/gi;
	    
	    $in2 =~ s/([А-Я,a-я])(в)(ев|ева|еве|еву|евым|евых|евыми|евой)($|[-\/,. ])/$1$2ь$3$4/gi;
	    
	    ## э's in woorden fixen
	    $in2 =~ s/^е(то|ти)/э$1/;
            $in2 =~ s/([ -\/])е(то|ти)/$1э$2/;
	    
	    $in2 =~ s/аеро/аэро/;
	    $in2 =~ s/груент/груэнт/;
	    $in2 =~ s/дуел/дуэл/;
	    $in2 =~ s/маест/g, "маэст/;
	    $in2 =~ s/поети/поэти/;
	    $in2 =~ s/поетому/поэтому/;
	    $in2 =~ s/уенд/уэнд/;
	    $in2 =~ s/евакуа/эвакуа/;
	    $in2 =~ s/еволю/эволю/;
	    $in2 =~ s/евф/эвф/;
	    $in2 =~ s/егали/эгали/;
	    $in2 =~ s/егои/эгои/;
	    $in2 =~ s/егоц/эгоц/;
	    $in2 =~ s/екв/экв/;
	    $in2 =~ s/(^|[ -\/])екс/экс/;
	    $in2 =~ s/(^|[ -\/])екз/экз/;
	    $in2 =~ s/екипаж/экипаж/;
	    $in2 =~ s/економ/эконом/;
	    $in2 =~ s/екран/экран/;
	    $in2 =~ s/еласт/эласт/;
	    $in2 =~ s/електр/электр/;
	    $in2 =~ s/елемент/элемент/;
	    $in2 =~ s/елимин/элимин/;
	    $in2 =~ s/емигр/эмигр/;
	    $in2 =~ s/емоци/эмоци/;
	    $in2 =~ s/емулс/эмулс/;
	    $in2 =~ s/енерг/энерг/;
	    $in2 =~ s/енци/энци/;
	    $in2 =~ s/епидем/эпидеми/;
	    $in2 =~ s/ессенц/эссенц/;
	    $in2 =~ s/естет/эстет/;
	    $in2 =~ s/етаж/этаж/;
	    $in2 =~ s/етимо/этимо/;
	    $in2 =~ s/етно/этно/;
	    $in2 =~ s/етюд/этюд/;
	    $in2 =~ s/еффект/эффект/;
	    $in2 =~ s/еффиц/эффиц/;


	    my $effe = $in2;
	    chomp $effe;
	    #print STDERR "IN2b: $name >> $effe INPUT: $input.txt\n";
	    print IN3 "$in2";
    }
    close INNEW;
    close IN3; 
    close IN;
  
###NLD
      $nlpop = `$rootdir/RU-NL.populair.flex <$tmpdir/$input.txt`;
      chomp $nlpop;
  
      #$nlpop =~ s/ij$/i/i;
      #$nlpop =~ s/yj$/i/i;
      #$nlpop =~ s/j$/i/i;
      #$nlpop =~ s/ii$/i/i;
      #$nlpop =~ s/y(a|e|o)/j$1/i;

  $nlpop =~ s/aè/aë/g;
  $nlpop =~ s/Aè/Aë/g;
  $nlpop =~ s/AÈ/AË/g;
  $nlpop =~ s/aÈ/aë/g;

  $nlpop =~ s/oeè/oeë/g;
  $nlpop =~ s/Oeè/Oeë/g;
  $nlpop =~ s/OEÈ/OEË/g;
  $nlpop =~ s/oeÈ/oeë/g;

  $nlpop =~ s/oee/oeë/g;
  $nlpop =~ s/Oee/Oeë/g;
  $nlpop =~ s/OEE/OEË/g;
  $nlpop =~ s/oeE/oeë/g;
  
  $nlpop =~ s/oè/oë/g;
  $nlpop =~ s/Oè/Oë/g;
  $nlpop =~ s/OÈ/OË/g;
  $nlpop =~ s/oÈ/oë/g;

  $nlpop =~ s/eè/еë/g;
  $nlpop =~ s/Eè/Еë/g;
  $nlpop =~ s/EÈ/ЕË/g;
  $nlpop =~ s/eÈ/еë/g;

  $nlpop =~ s/èè/еë/g;
  $nlpop =~ s/Èè/Еë/g;
  $nlpop =~ s/ÈÈ/ЕË/g;
  $nlpop =~ s/èÈ/еë/g;

  $nlpop =~ s/iè/ië/g;
  $nlpop =~ s/Iè/Ië/g;
  $nlpop =~ s/IÈ/IË/g;
  $nlpop =~ s/iÈ/ië/g;

  $nlpop =~ s/yè/yë/g;
  $nlpop =~ s/Yè/Yë/g;
  $nlpop =~ s/YÈ/YË/g;
  $nlpop =~ s/yÈ/yë/g;

  $nlpop =~ s/è/e/g;
  $nlpop =~ s/È/E/g;

  $nlpop =~ s/IJE/IË/g;
  $nlpop =~ s/ije/ië/g;
  $nlpop =~ s/iJE/ië/g;
  $nlpop =~ s/IJe/Ië/g;
  $nlpop =~ s/iJe/ië/g;

  $nlpop =~ s/IJ/I/g;
  $nlpop =~ s/ij/i/g;
  $nlpop =~ s/Ij/i/g;
  $nlpop =~ s/iJ/i/g;
  $nlpop =~ s/iy/i/g;
  #$nlpop =~ s/jj/j/g;
  #$nlpop =~ s/Jj/J/g;
  #$nlpop =~ s/jJ/j/g;

  $nlpop =~ s/(YJ)([^A-Z,a-z]|$|,|\.)/Y$2/g;
  $nlpop =~ s/(yj)([^A-Z,a-z]|$|,|\.)/y$2/g;
  $nlpop =~ s/(Yj)([^A-Z,a-z]|$|,|\.)/Y$2/g;
  $nlpop =~ s/(yJ)([^A-Z,a-z]|$|,|\.)/y$2/g;

  $nlpop =~ s/ooe/oöe/g;
  $nlpop =~ s/Ooe/Oöe/g;
  $nlpop =~ s/oOE/oöe/g;
  $nlpop =~ s/O-OE/OÖE/g;

  $nlpop =~ s/oe$/oje/i;
  $nlpop =~ s/oe_/oje_/i;

  $nlpop =~ s/eev/ejev/i;
  $nlpop =~ s/rev$/rjev/i;
  $nlpop =~ s/iev$/iëv/i;
  $nlpop =~ s/asev$/asjev/i;
  $nlpop =~ s/rev_/rjev_/i;
  $nlpop =~ s/iev_/iëv_/i;
  $nlpop =~ s/oviëv$/ovjov/i; ##20160503
  $nlpop =~ s/oviëv_/ovjov_/i; ##20160503
  $nlpop =~ s/asev_/asjev_/i;
  $nlpop =~ s/Ilitsj/Iljitsj/i;
  $nlpop =~ s/Ilyitsj/Iljitsj/i;
  $nlpop =~ s/Aleksander/Aleksandr/;
  $nlpop =~ s/aev$/ajev/i;
  $nlpop =~ s/aev_/ajev_/i;
  $nlpop =~ s/E\./Je\./i;
  $nlpop =~ s/lev$/ljev/i;
  $nlpop =~ s/jonov$/ionov/i;
  $nlpop =~ s/vilj$/vili/i;
  $nlpop =~ s/Genrj/Genri/i;
  $nlpop =~ s/ovljev$/ovlev/i;
  $nlpop =~ s/lev_/ljev_/i;
  $nlpop =~ s/oevski$/ojevski/i;
  $nlpop =~ s/-soje/-Soe/i;
  $nlpop =~ s/jj/j/i;
  $nlpop =~ s/potsjtalon/potsjtaljon/;  

  $nlpop =~ s/ij$/i/i;
  $nlpop =~ s/y$/i/i;
  $nlpop =~ s/yj$/y/i;
  #$nlpop =~ s/j$/i/i;
  $nlpop =~ s/ti$/ty/i; 
  $nlpop =~ s/ii$/i/i;
  $nlpop =~ s/ij_/i_/i;
  $nlpop =~ s/y_/i_/i;
  $nlpop =~ s/yj_/y_/i;
  #$nlpop =~ s/j_/i_/i;
  #$nlpop =~ s/y_/i_/i; 
    $nlpop =~ s/ii_/i_/i;
    $nlpop =~ s/ni$/ny/i; 
    $nlpop =~ s/Jevgeny$/Jevgeni/i; ##20160503
    $nlpop =~ s/Jevgeny_/Jevgeni_/i; ##20160503
  $nlpop =~ s/ti_/ty_/i;

  $nlpop =~ s/y(a|e|o)/j$1/gi;
  $nlpop =~ s/i(a|e|o)/j$1/gi;

  $nlpop =~ s/ija/ia/g;
  
  $nlpop =~ s/JJ/J/g;
  $nlpop =~ s/jj/j/g;
  $nlpop =~ s/Jj/J/g;
  $nlpop =~ s/jJ/j/g;

  $nlpop =~ s/^([jy])/\u$1/;
  $nlpop =~ s/_([jy])/_\u$1/g;  

    $nlpop =~ s/ai/aj/g;
    
    $nlpop =~ s/Ksenja/Ksenia/g;
    $nlpop =~ s/Zvjad/Zviad/g;
    $nlpop =~ s/Gamsachoerdja/Gamsachoerdia/g;
    $nlpop =~ s/Illarjonov/Illarionov/g;
    $nlpop =~ s/Gippjoes/Gippioes/g;
    $nlpop =~ s/Venjamin/Veniamin/g;
    #$nlpop =~ s/Natalja_Aleksejevna/Natalia_Aleksejevna/g;
    $nlpop =~ s/Djana/Diana/;

    $nlpop =~ s/Vjoetsjejski/Vyoetsjejski/g;

    $nlpop =~ s/Tjoekit/Tyoekit/g;
    $nlpop =~ s/Sjekpeer/Sjekpеër/g;
    $nlpop =~ s/Oen/Oën/g;
    
    $nlpop =~ s/([Oo])eë/$1ejo/g;
    #Oeëlen >< Oejolen [-]
    $nlpop =~ s/Oejolen/Oeëlen/g;

    $nlpop =~ s/Victor/Viktor/g;
    $nlpop =~ s/Naem/Najem/g;
    $nlpop =~ s/atsjev$/atsjov/g;
    $nlpop =~ s/atsjev_/atsjov_/g;
    $nlpop =~ s/oejk/oeyk/g;
    $nlpop =~ s/Dzje/Dzjo/g;
    $nlpop =~ s/Je\.V\./Jo\.V\./g;
    
    $nlpop =~ s/Natalja_Aleksejevna_Narotsjnitskaja/Natalia_Aleksejevna_Narotsjnitskaja/;

    $nlpop =~ s/yj/j/gi; ##MRE 20160429
    $nlpop =~ s/Petr$/Pjotr/gi; ##MRE 20160429
    $nlpop =~ s/Fedor$/Fjodor/gi; ##MRE 20160429
    $nlpop =~ s/Petr_/Pjotr_/gi; ##MRE 20160429
    $nlpop =~ s/Fedor_/Fjodor_/gi; ##MRE 20160429
  #Novyje_Boety >< Novje_Boety [-]
    $nlpop =~ s/Novje/Novyje/i;
    
        #Ksenia_Ljapina >< Ksenja_Ljapina [-]
	#Zviad_Gamsachoerdia >< Zvjad_Gamsachoerdja [-]
	#Andrej_Illarionov >< Andrej_Illarjonov [-]
	#Diana_Mnatsakanjan >< Djana_Mnatsakanjan [-]
	#Aljosja_Gippioes >< Aljosja_Gippjoes [-]
	#Veniamin_Illarionov >< Venjamin_Illarjonov [-]
	#Natalia_Aleksejevna_Narotsjnitskaja >< Natalja_Aleksejevna_Narotsjnitskaja [-]
	#Vyoetsjejski >< Vjoetsjeiski [-]
	#Tyoekit >< Tjoekit [-]
	#Sjekpеër >< Sjekpeer [-]
	#Oën-Soe >< Oen-Soe [-]

        #Natalja_Aleksejevna >< Natalia_Aleksejevna [-]
	#Diana_Mnatsakanjan >< Djana_Mnatsakanjan [-]
    
  #$nlpop =~ s/^E/Je/g;  
  #$nlpop =~ s/@/E/g;
  #$nlpop =~ s/_Je/_@/g;
  #$nlpop =~ s/_E/_Je/g;
  #$nlpop =~ s/_@/_E/g;  
  
   $nlpop =~ s/_/ /g if ($debug !~ /D/);
   $generator->addOutput('populair', $nlpop);    

##ENG
      $eng = `$rootdir/RU-EN.populair-engels.flex <$tmpdir/$input.txt`;
      chomp $eng;  
      #$eng =~ s/yy/y/i;
    $eng =~ s/^YE/Ye/;
    $eng =~ s/_YE/_Ye/;
    $eng =~ s/yye/ye/g;
    $eng =~ s/Afanasev/Afanasyev/g;
    $eng =~ s/Vasilev/Vasilyev/g;
    $eng =~ s/otski$/otsky/g;
    $eng =~ s/E\./Ye\./g;
    $eng =~ s/Rimskiy/Rimsky/g;
    $eng =~ s/orev$/oryev/g;
    $eng =~ s/exper/eksper/g;
    $eng =~ s/Alexeyev/Alekseyev/g;
    $eng =~ s/Oeye/Ue/g;
    $eng =~ s/eye/ee/g;
    $eng =~ s/Oye/Oe/g;
    $eng =~ s/Alekseevna/Alekseyevna/g;
    $eng =~ s/^Yeka_/Eka_/g;
    $eng =~ s/Yeka$/Eka/g;
    $eng =~ s/Yelkhan/Elkhan/g;
    $eng =~ s/Yelvira/Elvira/g;
    $eng =~ s/Gorki/Gorky/g;
    
        #Natalia_Alekseyevna >< Natalia_Alekseevna [-]
	#Eka_Zguladze >< Yeka_Zguladze [-]
	#Elkhan_Polukhov >< Yelkhan_Polukhov [-]
	#Elvira_Khasyanova >< Yelvira_Khasyanova [-]
	#Maxim_Gorky >< Maxim_Gorki [-]
	#Nataliya_Alekseyevna_Narochnitskaya >< Nataliya_Alekseevna_Narochnitskaya [-]

      $eng =~ s/_/ /g if ($debug !~ /D/);
      push @output, $generator->addOutput('populair-engels', $eng);

    ###GER

    open(RUS, "$tmpdir/$input.txt");    
    my $namerus = <RUS>; 
    close RUS;
    
      $germanpop = `$rootdir/RU-DE.populair-duits.flex <$tmpdir/$input.txt`;
      chomp $germanpop;
      #$ger =~ s/yi$/i/i;
      #$ger =~ s/yj/j/i;
      #$ger =~ s/y(a|o)/j$1/i;
    $germanpop =~ s/Ks|KS/X/g;
    $germanpop =~ s/kS|ks/x/g;
    $germanpop =~ s/([aeiouy])s([aeiouy])/$1ss$2/gi if ($namerus !~ /[аеёиоуыэюя]з[аеёиоуыэюя]/); ##HERE
    $germanpop =~ s/Wasili/Wassili/; ##Waarom nodig?
    $germanpop =~ s/(ss)(ibir)/s$2/gi;
    $germanpop =~ s/(nowo)(ss)([aeiouy])/$1s$3/gi;
    $germanpop =~ s/(lesso)(ss)([aeiouy])/$1s$3/gi;
    $germanpop =~ s/(krasno)(ss)([aeiouy])/$1s$3/gi;
    $germanpop =~ s/(weliko)(ss)([aeiouy])/$1s$3/gi;
    $germanpop =~ s/(malo)(ss)([aeiouy])/$1s$3/gi;
    $germanpop =~ s/yi/y/gi;
    $germanpop =~ s/y$/i/g;
    $germanpop =~ s/y_/i_/g;
    $germanpop =~ s/skoyje/skoje/g;
    $germanpop =~ s/ia/ja/g;
    $germanpop =~ s/rew$/rjew/;
    $germanpop =~ s/assew$/asjew/;
    $germanpop =~ s/sjow$/schow/;
    $germanpop =~ s/E\./Je./;
    $germanpop =~ s/Dzj/Dsch/;
    $germanpop =~ s/Ilytsch/Iljitsch/;
    $germanpop =~ s/ilew$/iljew/;
    $germanpop =~ s/ossero/osero/;
    $germanpop =~ s/novo$/nowo/;
    $germanpop =~ s/potschtalon/potschtaljon/;
    $germanpop =~ s/egodnja/ewodnja/;
    $germanpop =~ s/Alexander/Alexandr/;
    $germanpop =~ s/Magnizkaja/Magnitskaja/;
    $germanpop =~ s/Podgorni/Podgorny/;
    $germanpop =~ s/Wasili/Wassili/;
    $germanpop =~ s/Nawalni/Nawalny/;
    $germanpop =~ s/Swjad/Swiad/;
    $germanpop =~ s/Gamsachurdja/Gamsachurdia/;
    $germanpop =~ s/Naijem/Naiem/;
    $germanpop =~ s/Djana/Diana/;
    $germanpop =~ s/Wenjamin/Weniamin/;
    $germanpop =~ s/Wjutscheiski/Wyutscheiski/;
    $germanpop =~ s/Tjukit/Tyukit /;
    $germanpop =~ s/Schekpejer/Schekpeer/;
    $germanpop =~ s/rossiysk/rossisk/;
    $germanpop =~ s/Oejelen/Uelen/;
    $germanpop =~ s/Buti$/Buty/;
    $germanpop =~ s/Mussiykongiykote/Mussikongikote/;
    $germanpop =~ s/^Ojen/Oen/;
    $germanpop =~ s/mnogoljudni/mnogoljudny/;
    $germanpop =~ s/wesnuschtschati/wesnuschtschaty/;
    $germanpop =~ s/agenztwo/agentstwo/;
    $germanpop =~ s/è/e/;
    
        #Natalja_Magnitskaja >< Natalja_Magnizkaja [-]
	#Nikolai_Podgorny >< Nikolai_Podgorni [-]
	#Wassili_Kusnezow >< Wasili_Kusnezow [-]
	#Alexei_Nawalny >< Alexei_Nawalni [-]
	#Swiad_Gamsachurdia >< Swjad_Gamsachurdja [-]
	#Mustafa_Naiem >< Mustafa_Naijem [-]
	#Diana_Mnazakanjan >< Djana_Mnazakanjan [-]
	#Weniamin_Illarionow >< Wenjamin_Illarionow [-]
	#Wyutscheiski >< Wjutscheiski [-]
	#Tyukit >< Tjukit [-]
	#Schekpeer >< Schekpejer [-]
	#Noworossisk >< Noworossiysk [-]
	#Uelen >< Oejelen [-]
	#Nowyje_Buty >< Nowyje_Buti [-]
	#Mussikjongikote >< Mussiykjongiykote [-]
	#Oen-Su >< Ojen-Su [-]
	#mnogoljudny >< mnogoljudni [-]
	#wesnuschtschaty >< wesnuschtschati [-]
	#agentstwo >< agenztwo [-]

      $germanpop =~ s/_/ /g if ($debug !~ /D/);   
      push @output, $generator->addOutput('populair-duits', $germanpop);  

      if ($debug =~ /D/){
      push @debug, $nlpop;
      push @debug, $eng;  
      push @debug, $germanpop;
      print TEST "@debug\n";
      }

                push @output, $generator->addOutput('ALA-LC', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('ALA-LC-simpel', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('wetenschappelijk', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('BGN-PCGN', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('BGN-PCGN-simpel', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('british-standard', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('GOST-1983', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('GOST-2000b', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('GOST-2004', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('GOST_R_52535.1-2006', '<span class="na_field">Not applicable</span>');
        	push @output, $generator->addOutput('ICAO', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('ISO9-1995', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('paspoort-1997-2010', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('paspoort-ussr', '<span class="na_field">Not applicable</span>');
	        push @output, $generator->addOutput('rijbewijs', '<span class="na_field">Not applicable</span>');
	
}} else {
    my $nlpop = `$rootdir/RU-NL.populair.flex <$tmpdir/$input.txt`;
    $nlpop =~ s/aè/aë/g;
    $nlpop =~ s/Aè/Aë/g;
    $nlpop =~ s/AÈ/AË/g;
    $nlpop =~ s/aÈ/aë/g;

    $nlpop =~ s/oeè/oeë/g;
    $nlpop =~ s/Oeè/Oeë/g;
    $nlpop =~ s/OEÈ/OEË/g;
    $nlpop =~ s/oeÈ/oeë/g;

    $nlpop =~ s/oè/oë/g;
    $nlpop =~ s/Oè/Oë/g;
    $nlpop =~ s/OÈ/OË/g;
    $nlpop =~ s/oÈ/oë/g;

    $nlpop =~ s/eè/еë/g;
    $nlpop =~ s/Eè/Еë/g;
    $nlpop =~ s/EÈ/ЕË/g;
    $nlpop =~ s/eÈ/еë/g;

    $nlpop =~ s/èè/еë/g;
    $nlpop =~ s/Èè/Еë/g;
    $nlpop =~ s/ÈÈ/ЕË/g;
    $nlpop =~ s/èÈ/еë/g;
    
    $nlpop =~ s/iè/ië/g;
    $nlpop =~ s/Iè/Ië/g;
    $nlpop =~ s/IÈ/IË/g;
    $nlpop =~ s/iÈ/ië/g;

    $nlpop =~ s/yè/yë/g;
    $nlpop =~ s/Yè/Yë/g;
    $nlpop =~ s/YÈ/YË/g;
    $nlpop =~ s/yÈ/yë/g;

    $nlpop =~ s/IJE/IË/g;
    $nlpop =~ s/ije/ië/g;
    $nlpop =~ s/iJE/ië/g;
    $nlpop =~ s/IJe/Ië/g;
    $nlpop =~ s/iJe/ië/g;

    $nlpop =~ s/IJ/I/g;
    $nlpop =~ s/ij/i/g;
    $nlpop =~ s/Ij/i/g;
    $nlpop =~ s/iJ/i/g;

    $nlpop =~ s/JJ/J/g;
    $nlpop =~ s/jj/j/g;
    $nlpop =~ s/Jj/J/g;
    $nlpop =~ s/jJ/j/g;

    $nlpop =~ s/(YJ)([^A-Z,a-z]|$|,|\.)/Y$2/g;
    $nlpop =~ s/(yj)([^A-Z,a-z]|$|,|\.)/y$2/g;
    $nlpop =~ s/(Yj)([^A-Z,a-z]|$|,|\.)/Y$2/g;
    $nlpop =~ s/(yJ)([^A-Z,a-z]|$|,|\.)/y$2/g;

    $nlpop =~ s/ooe/oöe/g;
    $nlpop =~ s/Ooe/Oöe/g;
    $nlpop =~ s/oOE/oöe/g;
    $nlpop =~ s/O-OE/OÖE/g;

    $nlpop =~ s/oe$/oje/i;
    $nlpop =~ s/oe_/oje_/i;

    $nlpop =~ s/Novye/Novyje/;

    $nlpop =~ s/eev/ejev/i;
    $nlpop =~ s/rev$/rjev/i;
    $nlpop =~ s/iev$/iëv/i;
    $nlpop =~ s/asev$/asjev/i;
    $nlpop =~ s/rev_/rjev_/i;
    $nlpop =~ s/iev_/iëv_/i;
    $nlpop =~ s/asev_/asjev_/i;
    $nlpop =~ s/Ilitsj/Iljitsj/i;
    $nlpop =~ s/aev$/ajev/i;
    $nlpop =~ s/aev_/ajev_/i;
    $nlpop =~ s/E\./Je\./i;
    $nlpop =~ s/^E/Je/; ##NEW
    $nlpop =~ s/_E/_Je/; ##NEW

    $nlpop =~ s/è/e/g; ##MOVED
    $nlpop =~ s/È/E/g; ##MOVED

    $nlpop =~ s/lev$/ljev/i;

    $nlpop =~ s/ovljev$/ovlev/i;

    $nlpop =~ s/lev_/ljev_/i;
    $nlpop =~ s/toevski/tojevski/i;
    $nlpop =~ s/-soje/-Soe/i;
    $nlpop =~ s/jj/j/i; 
    $nlpop =~ s/potsjtalon/potsjtaljon/;

    #Sergej_Jakovlev >< Sergej_Jakovljev [-]
    #Novyje_Boety >< Novye_Boety [-]

    $nlpop =~ s/_/ /g if ($debug !~ /D/);
    push @output, $generator->addOutput('populair', "$nlpop");    

    my $wiki = `$rootdir/RU-NL.wikipedia.flex <$tmpdir/$input.txt`;
    $wiki =~ s/aè/aë/g;
    $wiki =~ s/Aè/Aë/g;
    $wiki =~ s/AÈ/AË/g;
    $wiki =~ s/aÈ/aë/g;

    $wiki =~ s/oeè/oeë/g;
    $wiki =~ s/Oeè/Oeë/g;
    $wiki =~ s/OEÈ/OEË/g;
    $wiki =~ s/oeÈ/oeë/g;

    $wiki =~ s/oè/oë/g;
    $wiki =~ s/Oè/Oë/g;
    $wiki =~ s/OÈ/OË/g;
    $wiki =~ s/oÈ/oë/g;

    $wiki =~ s/eè/еë/g;
    $wiki =~ s/Eè/Еë/g;
    $wiki =~ s/EÈ/ЕË/g;
    $wiki =~ s/eÈ/еë/g;

    $wiki =~ s/èè/еë/g;
    $wiki =~ s/Èè/Еë/g;
    $wiki =~ s/ÈÈ/ЕË/g;
    $wiki =~ s/èÈ/еë/g;

    $wiki =~ s/iè/ië/g;
    $wiki =~ s/Iè/Ië/g;
    $wiki =~ s/IÈ/IË/g;
    $wiki =~ s/iÈ/ië/g;

    $wiki =~ s/yè/yë/g;
    $wiki =~ s/Yè/Yë/g;
    $wiki =~ s/YÈ/YË/g;
    $wiki =~ s/yÈ/yë/g;

    $wiki =~ s/è/e/g;
    $wiki =~ s/È/E/g;

	$wiki =~ s/(IJ)([^A-Z,a-z]|$|,)/I$2/g;
	$wiki =~ s/(ij)([^A-Z,a-z]|$|,)/i$2/g;
	$wiki =~ s/(Ij)([^A-Z,a-z]|$|,)/I$2/g;
	$wiki =~ s/(iJ)([^A-Z,a-z]|$|,)/i$2/g;
	$wiki =~ s/(ij)(\S)/iej$2/g;
	$wiki =~ s/(IJ)(\S)/IEJ$2/g;
	$wiki =~ s/(Ij)(\S)/Iej$2/g;
	$wiki =~ s/(iJ)(\S)/iej$2/g;
	$wiki =~ s/IJ/I/g;
	$wiki =~ s/ij/i/g;
	$wiki =~ s/Ij/i/g;
	$wiki =~ s/iJ/i/g;
	$wiki =~ s/JJ/J/g;
	$wiki =~ s/jj/j/g;
	$wiki =~ s/Jj/J/g;
	$wiki =~ s/jJ/j/g;
	$wiki =~ s/(YJ)([^A-Z,a-z]|$|,|\.)/Y$2/g;
	$wiki =~ s/(yj)([^A-Z,a-z]|$|,|\.)/y$2/g;
	$wiki =~ s/(Yj)([^A-Z,a-z]|$|,|\.)/Y$2/g;
	$wiki =~ s/(yJ)([^A-Z,a-z]|$|,|\.)/y$2/g;
	$wiki =~ s/oeoe/uu/g;
	$wiki =~ s/OEoe/Uu/g;
	$wiki =~ s/oeOE/uu/g;
	$wiki =~ s/OEOE/UU/g;
	$wiki =~ s/ooe/o-oe/g;
	$wiki =~ s/Ooe/O-oe/g;
	$wiki =~ s/oOE/o-oe/g;
        $wiki =~ s/O-OE/O-Oe/g;

        #Igor_Grigorjev >< Igor_Grigorev [-]
	#Vasili_Piskarjov >< Vasili_Piskarev [-]
	#Andrej_Slepnjov >< Andrej_Slepnev [-]
	#Dmitri_Afanasjev >< Dmitri_Afanasev [-]
	#Jevgeni_Jevtoesjenkov >< Jevgeni_Evtoesjenkov [-]
	#Vladimir_Iljitsj_Lenin >< Vladimir_Ilitsj_Lenin [-]
	#A.Je._Jegorov >< A.E._Jegorov [-]
	#A.Je._Podjatsjev >< A.E._Podjatsjev [-]
	#Jo.V._Vasiljev >< Jo.V._Vasilev [-]
	#Moesiejkjongiejkote >< Moesiejkongiejkote [-]
	#potsjtaljon >< potsjtalon [-]
    
    $wiki =~ s/orev$/orjev/g;
    $wiki =~ s/orev_/orjev_/g;
    $wiki =~ s/Piskarev/Piskarjov/g;
    $wiki =~ s/Slepnev/Slepnjov/g;
    $wiki =~ s/Afanasev/Afanasjev/g;
    $wiki =~ s/Evtoesj/Jevtoesj/g;
    $wiki =~ s/Ilitsj/Iljitsj/g;
    $wiki =~ s/E\./Je\./g;
    $wiki =~ s/ilev$/iljev/g;
    $wiki =~ s/ilev_/iljev_/g;
    $wiki =~ s/potsjtalon/potsjtaljon/;

        $wiki =~ s/_/ /g if ($debug !~ /D/);
	push @output, $generator->addOutput('wikipedia', "$wiki");

	my $englishpop = `$rootdir/RU-EN.populair-engels.flex <$tmpdir/$input.txt`;

        #Arkady_Gaidar >< Arkady_Gaydar [-]
	#Igor_Grigoryev >< Igor_Grigorev [-]
	#Andrei_Zaitsev >< Andrei_Zaytsev [-]
	#Vasily_Piskaryov >< Vasily_Piskarev [-]
	#Andrei_Slepnyov >< Andrei_Slepnev [-]
	#Dmitry_Afanasyev >< Dmitry_Afanasev [-]
	#Yevgeny_Yevtushenkov >< Yevgeny_Evtushenkov [-]
	#Mustafa_Naiyem >< Mustafa_Nayem [-]
	#Pyotr_Chaikovsky >< Pyotr_Chaykovsky [-]
	#Yo.V._Vasilyev >< Yo.V._Vasilev [-]
	#Boris_Mikhailovsky >< Boris_Mikhaylovsky [-]
	#Maiya_Ivanovna >< Mayya_Ivanovna [-]
	#Nikolai_Rimsky-Korsakov >< Nikolai_Rimskiy-Korsakov [-]
	#Vyucheisky >< Vyucheysky [-]
	#Novye_Buty >< Novyye_Buty [-]
	#Musiykyongiykote >< Musiykongiykote [-]
	#Kuiyogan >< Kuyyogan [-]
	#khimichesky_eksperiment >< khimichesky_experiment [-]

	$englishpop =~ s/(Aleksandr)([^A-Za-z]|$|,|_)/Alexander$2/gi;
    $englishpop =~ s/Aleksandr/Alexandr/gi;
    $englishpop =~ s/Alexandr/Alexander/gi;
    $englishpop =~ s/(Aleksei)([^A-Z,a-z]|$|,|_)/Alexei$2/gi;
    $englishpop =~ s/(Alexeyevn)/Alekseyevn/gi;
    $englishpop =~ s/experiment/eksperiment/g;
    $englishpop =~ s/Mayya/Maiya/g;
    $englishpop =~ s/Vasilev/Vasilyev/g;
    $englishpop =~ s/Afanasev/Afanasyev/g;
    $englishpop =~ s/Naiem/Naiyem/g;
    $englishpop =~ s/Rimskiy/Rimsky/g;
    $englishpop =~ s/Novyye/Novye/g;
    $englishpop =~ s/Kuyyogan/Kuiyogan/g;
        $englishpop =~ s/Maksim/Maxim/gi;
	$englishpop =~ s/Gorbachyov/Gorbachev/gi;
    $englishpop =~ s/Khrushchyov/Khrushchev/gi;
    $englishpop =~ s/E\./Ye\./g;
    $englishpop =~ s/Evtu/Yevtu/g;

        #Mustafa_Naiyem >< Mustafa_Naiem [-]
	#Novorossiysk >< Novorossysk [-]
	#Musiykongiykote >< Musykongykote [-]
    
    $englishpop =~ s/rossysk/rossiysk/g; ##NEW
    $englishpop =~ s/Musykongykote/Musiykongiykote/g; ##NEW

        #Igor_Grigoryev >< Igor_Grigorev [-]
	#Vasily_Piskaryov >< Vasily_Piskarev [-]
	#Andrei_Slepnyov >< Andrei_Slepnev [-]

    $englishpop =~ s/orev$/oryev/;
    $englishpop =~ s/orev_/oryev/;
    $englishpop =~ s/Piskarev/Piskaryov/;
    $englishpop =~ s/Slepnev/Slepnyov/;

        $englishpop =~ s/_/ /g if ($debug !~ /D/);
        push @output, $generator->addOutput('populair-engels', "$englishpop");
	
        my $germanpop = `$rootdir/RU-DE.populair-duits.flex <$tmpdir/$input.txt`;

	$germanpop =~ s/Ks|KS/X/g;
        $germanpop =~ s/kS|ks/x/g;
        $germanpop =~ s/([aeiouy])s([aeiouy])/$1ss$2/gi if ($name !~ /[аеёиоуыэюя]з[аеёиоуыэюя]/); ##HERE
        $germanpop =~ s/Wasili/Wassili/; ##Waarom nodig?
	$germanpop =~ s/(ss)(ibir)/s$2/gi;
	$germanpop =~ s/(nowo)(ss)([aeiouy])/$1s$3/gi;
	$germanpop =~ s/(lesso)(ss)([aeiouy])/$1s$3/gi;
	$germanpop =~ s/(krasno)(ss)([aeiouy])/$1s$3/gi;
	$germanpop =~ s/(weliko)(ss)([aeiouy])/$1s$3/gi;
	$germanpop =~ s/(malo)(ss)([aeiouy])/$1s$3/gi;
        $germanpop =~ s/yi/y/gi;
    $germanpop =~ s/rew$/rjew/;
    $germanpop =~ s/assew$/asjew/;
    $germanpop =~ s/sjow$/schow/;
    $germanpop =~ s/E\./Je./;
    $germanpop =~ s/^E/Je/; ##NEW
    $germanpop =~ s/_E/_Je/; ##NEW

    $germanpop =~ s/è/e/g; ##MOVED
    $germanpop =~ s/È/E/g; ##MOVED

    $germanpop =~ s/Dzj/Dsch/;
    $germanpop =~ s/Ilitsch/Iljitsch/;
    $germanpop =~ s/ilew$/iljew/;
    $germanpop =~ s/ossero/osero/;
    $germanpop =~ s/novo$/nowo/;
    $germanpop =~ s/potschtalon/potschtaljon/;
    $germanpop =~ s/egodnja/ewodnja/;

    ##RESTFOUTEN:
        #Wladimir_Gussew >< Wladimir_Gusjew [-]
	#Sergei_Jakowlew >< Sergei_Jakowljew [-]
	#Mussikjongikote >< Mussikongikote [-]

        $germanpop =~ s/_/ /g if ($debug !~ /D/);
	push @output, $generator->addOutput('populair-duits', "$germanpop");

    my $ALA = `$rootdir/RU-EN.ALA-LC.flex <$tmpdir/$input.txt`;
        $ALA =~ s/_/ /g if ($debug !~ /D/);
        push @output, $generator->addOutput('ALA-LC', "$ALA"); 

    my $ALAs = `$rootdir/RU-EN.ALA-LC-simpel.flex <$tmpdir/$input.txt`;
        $ALAs =~ s/_/ /g if ($debug !~ /D/);
	push @output, $generator->addOutput('ALA-LC-simpel', "$ALAs");

    my $science = `$rootdir/RU-EN.wetenschappelijk.flex <$tmpdir/$input.txt`;
        $science =~ s/_/ /g if ($debug !~ /D/);
        push @output, $generator->addOutput('wetenschappelijk', "$science");

        my $BGN = `$rootdir/RU-EN.BGN-PCGN.flex <$tmpdir/$input.txt`;
        
        #Natal’ya_Alekseyevna >< Natal’ya_Alekseevna [-]
	#Igor’_Grigor’yev >< Igor’_Grigor’ev [-]
	#Kirill_Dmitriyev >< Kirill_Dmitriev [-]
	#Vasiliy_Piskarëv >< Vasiliy_Piskarev [-]
	#Andrey_Slepnëv >< Andrey_Slepnev [-]
	#Dmitriy_Afanas’yev >< Dmitriy_Afanas’ev [-]
	#Mustafa_Nayyem >< Mustafa_Nayem [-]
	#Valentin_Bubayev >< Valentin_Bubaev [-]
	#Fëdor_Dostoyevskiy >< Fëdor_Dostoevskiy [-]
	#Yë.V._Vasil’yev >< Ë.V._Vasil’ev [-]
	#Nataliya_Alekseyevna_Narochnitskaya >< Nataliya_Alekseevna_Narochnitskaya [-]
	#Uyyëg >< Uëg [-]
	#Onezhskoye_ozero >< Onezhskoe_ozero [-]
	#Chudskoye_ozero >< Chudskoe_ozero [-]
	#Novyye_Buty >< Novye_Buty [-]
        #Kuyyëgan >< Kuyëgan [-]

        #Yë.V._Vasil’yev >< Ë.V._Vasil’yev [-]
	#Uyyëg >< Uëg [-]
        
    $BGN =~ s/([aeiou])ev/$1yev/;
    $BGN =~ s/skoe_/skoye_/;
    $BGN =~ s/skoe$/skoye/;
    $BGN =~ s/ovye/ovyye/;
    $BGN =~ s/Kuyëgan/Kuyyëgan/;
    $BGN =~ s/Nayem/Nayyem/;
    $BGN =~ s/Ë\./Yë\./;
    $BGN =~ s/E\./Ye\./; ##NEW
    $BGN =~s/Uëg/Uyyëg/;
    
    $BGN =~ s/_/ /g if ($debug !~ /D/);
    push @output, $generator->addOutput('BGN-PCGN', "$BGN");

        my $BGNs = `$rootdir/RU-EN.BGN-PCGN-simpel.flex <$tmpdir/$input.txt`;

        #Kseniya_Lyapina >< Ksenya_Lyapina [-]
	#Nataliya_Alekseyevna_Narochnitskaya >< Natalya_Alekseyevna_Narochnitskaya [-]

    $BGNs =~ s/ya_/ja_/; ##NEW  
    $BGNs =~ s/iy/y/gi; ## if ($BGNs !~ /iya$/); ##ADAPTED
    $BGNs =~ s/yy/y/gi;
    $BGNs =~ s/yi/y/gi;
    $BGNs =~ s/([aeiou])ev/$1yev/;
    #$BGNs =~ s/yev$/ev/i;
    #$BGNs =~ s/ev$/yev/i; ##Vorige uitgevlagd en deze niet: precies eendere score met tegengestelde set 'fouten' op development set!!
    #$BGNs =~ s/Alekseevna/Alekseyevna/;
    $BGNs =~ s/skoe_/skoye_/;
    $BGNs =~ s/skoe$/skoye/;
    $BGNs =~ s/ovye/ovyye/;
    $BGNs =~ s/Dzhy/Dzh/;
    $BGNs =~ s/Nayyem/Nayem/;
    $BGNs =~ s/rossysk/rossiysk/;
    $BGNs =~ s/Novyye/Novye/;
    $BGNs =~ s/E\./Ye\./; ##NEW 

    $BGNs =~ s/ja_/ya_/; ##NEW
    $BGNs =~ s/yya_/ya_/; ##NEW
    #$BGNs =~ s/Natalya/Nataliya/; ##NEW
    $BGNs =~ s/chyov$/chev/; ##NEW
    $BGNs =~ s/Musykongykote/Musiykongiykote/; ##NEW
    
        #Kseniya_Lyapina >< Ksenya_Lyapina [-]
	#Arkady_Bashlachev >< Arkady_Bashlachyov [-]
	#Nataliya_Alekseyevna_Narochnitskaya >< Natalya_Alekseyevna_Narochnitskaya [-]
	#Musiykongiykote >< Musykongykote [-]

        $BGNs =~ s/_/ /g if ($debug !~ /D/);
        push @output, $generator->addOutput('BGN-PCGN-simpel', "$BGNs");
	
    my $brit = `$rootdir/RU-EN.british-standard.flex <$tmpdir/$input.txt`;
        $brit =~ s/_/ /g if ($debug !~ /D/);
        push @output, $generator->addOutput('british-standard', "$brit"); 

    my $gost83 = `$rootdir/RU-EN.GOST-1983.flex <$tmpdir/$input.txt`;
        $gost83 =~ s/_/ /g if ($debug !~ /D/);
        push @output, $generator->addOutput('GOST-1983', "$gost83");		     
	
        my $gost = `$rootdir/RU-EN.GOST-2000b.flex <$tmpdir/$input.txt`;
	$gost =~ s/(CZ)([IEYJ,ieyj])/C$2/g;
	$gost =~ s/(Cz)([IEYJ,ieyj])/C$2/g;
    $gost =~ s/(cz)([ieyj,ieyj])/c$2/g;
        $gost =~ s/_/ /g if ($debug !~ /D/);
	push @output, $generator->addOutput('GOST-2000b', "$gost");

	my $gost04 = `$rootdir/RU-EN.GOST-2004.flex <$tmpdir/$input.txt`;
        $gost04 =~ s/Dzhy/Dzh/;
    $gost04 =~ s/([aeiou'’])ev/$1yev/;
    $gost04 =~ s/skoe$/skoye/;
    $gost04 =~ s/skoe_/skoye_/;
    $gost04 =~ s/vye$/vyye/;
    $gost04 =~ s/vye_/vyye_/;
    $gost04 =~ s/Ye\./Yo\./;
    $gost04 =~ s/Uyeg/Uyog/;
    $gost04 =~ s/E\./Ye\./;
    $gost04 =~ s/chyev$/chev/;
    $gost04 =~ s/chyev_/chev_/;

        $gost04 =~ s/_/ /g if ($debug !~ /D/);
	push @output, $generator->addOutput('GOST-2004', "$gost04");

    my $gost06 = `$rootdir/RU-EN.GOST_R_52535.1-2006.flex <$tmpdir/$input.txt`;
        $gost06 =~ s/_/ /g if ($debug !~ /D/);
        push @output, $generator->addOutput('GOST_R_52535.1-2006', "$gost06");

        my $ICAO = `$rootdir/RU-EN.ICAO.flex <$tmpdir/$input.txt`;
        $ICAO =~ s/IA/Ia/g;
        $ICAO =~ s/IU/Iu/g;
        $ICAO =~ s/_/ /g if ($debug !~ /D/);
	push @output, $generator->addOutput('ICAO', "$ICAO");

	my $iso = `$rootdir/RU-EN.ISO9-1995.flex <$tmpdir/$input.txt`;
        $iso =~ s/_/ /g if ($debug !~ /D/);
        push @output, $generator->addOutput('ISO9-1995', "$iso");

	my $pp2010 = `$rootdir/RU-EN.paspoort-1997-2010.flex <$tmpdir/$input.txt`;

	$pp2010 =~ s/(iy)([^A-Z,a-z]|$|,)/y$2/gi;
        $pp2010 =~ s/'ev/yev/;
        $pp2010 =~ s/Agaf'ya/Agafia/gi;
	$pp2010 =~ s/Akulina/Akoulina/gi;
	$pp2010 =~ s/(Aleksandr)([^A-Z,a-z]|$|,)/Alexander$2/gi;
	$pp2010 =~ s/Aleksandrov/Alexandrov/gi;
	$pp2010 =~ s/Alekse/Alexe/gi;
	$pp2010 =~ s/Anastasiya/Anastasia/gi;
	$pp2010 =~ s/Vyacheslav/Viacheslav/gi;
	$pp2010 =~ s/Viktoriya/Victoria/gi;
	$pp2010 =~ s/Viktor/Victor/gi;
	$pp2010 =~ s/Dar'ya/Daria/gi;
	$pp2010 =~ s/Evdokiya/Evdokia/gi;
	$pp2010 =~ s/Efrosin'ya/Efrosinia/gi;
	$pp2010 =~ s/Emel'yan/Emelian/gi;
	$pp2010 =~ s/Il'ya/Ilya/gi;
	$pp2010 =~ s/Ul'yana/Uliana/gi;
	$pp2010 =~ s/Filipp/Philipp/gi;
	$pp2010 =~ s/Kseniya/Ksenia/gi;
	$pp2010 =~ s/Kuz'ma/Kuzma/gi;
	$pp2010 =~ s/Lidiya/Lidia/gi;
	$pp2010 =~ s/Lyubov'/Liubov/gi;
	$pp2010 =~ s/Lyudmila/Liudmila/gi;
	$pp2010 =~ s/Maksim/Maxim/gi;
	$pp2010 =~ s/Mariya/Maria/gi;
	$pp2010 =~ s/Nadezhda/Nadezda/gi;
	$pp2010 =~ s/Natal'ya/Natalia/gi;
	$pp2010 =~ s/Oksana/Oxana/gi;
	$pp2010 =~ s/Ol'ga/Olga/gi;
	$pp2010 =~ s/Praskov'ya/Praskovia/gi;
	$pp2010 =~ s/Tat'yana/Tatiana/gi;
	$pp2010 =~ s/Fedos'ya/Fedosia/gi;
	$pp2010 =~ s/Yuliya/Yulia/gi;
	$pp2010 =~ s/Yakov/Iakov/gi;


    
        $pp2010 =~ s/yy/y/g;

        $pp2010 =~ s/Maya/Mayya/g; ##NEW

        $pp2010 =~ s/_/ /g if ($debug !~ /D/);
	push @output, $generator->addOutput('paspoort-1997-2010', "$pp2010");

    my $ppUSSR = `$rootdir/RU-EN.paspoort-ussr.flex <$tmpdir/$input.txt`;
    
        #Igor_Grigoriev >< Igor_Grigorev [-]
	#Victor_Kozlov >< Viktor_Kozlov [-]
	#Victor_Gouminski >< Viktor_Gouminski [-]
	#Dmitri_Afanassiev >< Dmitri_Afanassev [-]
	#E.V._Vassiliev >< E.V._Vassilev [-]
              $ppUSSR =~ s/ii$/i/gi;
              $ppUSSR =~ s/ii_/i_/gi;
              $ppUSSR =~ s/ii-/i-/gi;
              $ppUSSR =~ s/^Ks/X/;
              $ppUSSR =~ s/ks/x/g;
              $ppUSSR =~ s/([a|e|i|o|u|y])s([a|e|i|o|u|y])/$1ss$2/gi;
    $ppUSSR =~ s/Ge/Gue/g;
    $ppUSSR =~ s/ge/gue/g;
    $ppUSSR =~ s/Gi/Gui/g;
    $ppUSSR =~ s/gi/gui/g;
              $ppUSSR =~ s/Alexandr$/Alexandre/;
              $ppUSSR =~ s/Alexandr_/Alexandre_/;
              $ppUSSR =~ s/Valentin$/Valentine/;
    $ppUSSR =~ s/Valentin_/Valentine_/;
    $ppUSSR =~ s/Viktor/Victor/g;
    $ppUSSR =~ s/Afanassev/Afanassiev/g;
    $ppUSSR =~ s/Grigorev/Grigoriev/;
    $ppUSSR =~ s/Vassilev/Vassiliev/g;

    $ppUSSR =~ s/_/ /g if ($debug !~ /D/);
    push @output, $generator->addOutput('paspoort-ussr', "$ppUSSR");

    my $rij = `$rootdir/RU-EN.rijbewijs.flex <$tmpdir/$input.txt`;
    $rij =~ s/([aeiou'’])ev/$1yev/;
    $rij =~ s/skoe$/skoye/;
    $rij =~ s/skoe_/skoye_/;
    $rij =~ s/vye$/vyye/;
    $rij =~ s/vye_/vyye_/;
    $rij =~ s/Ye\./Yo\./;
    $rij =~ s/Uyeg/Uyog/;
    $rij =~ s/E\./Ye\./;
    $rij =~ s/chyev$/chev/;
    $rij =~ s/chyev_/chev_/;
    ##ABOVE NEW
        $rij =~ s/E\./Ye\./g;
        $rij =~ s/Il’ich/Il’yich/g;
        $rij =~ s/Dzhy/Dzh/g;

	#Vladimir_Il’yich_Lenin >< Vladimir_Il’ich_Lenin [-]
	#Arkadiy_Bashlachev >< Arkadiy_Bashlachyev [-]
	#Yo.V._Vasil’ev >< Ye.V._Vasil’ev [-]
	#Uyog >< Uyeg [-]
	#Dzhesyumel >< Dzhyesyumel [-]

        $rij =~ s/_/ /g if ($debug !~ /D/);
	push @output, $generator->addOutput('rijbewijs', "$rij");

    if ($debug =~ /D/){
        chomp $nlpop;
	push @debug, $nlpop;
	chomp $wiki;
	push @debug, $wiki;
	chomp $englishpop;
	push @debug, $englishpop;
	chomp $germanpop;
	push @debug, $germanpop;
	chomp $ALA;
	push @debug, $ALA;
        chomp $ALAs;
	push @debug, $ALAs;
	chomp $science;
	push @debug, $science;
	chomp $BGN;
	push @debug, $BGN;
	chomp $BGNs;
	push @debug, $BGNs;
	chomp $brit;
	push @debug, $brit;
	chomp $gost83;
	push @debug, $gost83;
	chomp $gost;
	push @debug, $gost;
        chomp $gost04;
	push @debug, $gost04;
        chomp $gost06;
	push @debug, $gost06;
	chomp $ICAO;
	push @debug, $ICAO;
        chomp $iso;
	push @debug, $iso;
	chomp $pp2010;
	push @debug, $pp2010;
        chomp $ppUSSR;
	push @debug, $ppUSSR;
        chomp $rij;
	push @debug, $rij;

	print TEST "@debug\n";
     }
}
# Generate and print final output
print $generator->generateHTML();

# Delete input file
#unlink("$input.txt");
#unlink("$input2.txt");
