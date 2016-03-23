#!/usr/bin/env python
#-*- coding:utf-8 -*-

###############################################################
# CLAM: Computational Linguistics Application Mediator
# -- Settings --
#       by Maarten van Gompel (proycon)
#       http://ilk.uvt.nl/~mvgompel
#       Induction for Linguistic Knowledge Research Group
#       Universiteit van Tilburg
#
#       Licensed under GPLv3
#
###############################################################
#import os
#language = os.environ['language']

from clam.common.parameters import *
from clam.common.formats import *
from clam.common.converters import *
from clam.common.viewers import *
from clam.common.data import *
from clam.common.digestauth import pwhash
from os import uname
import sys
REQUIRE_VERSION = 0.9
import os
#The System ID, a short alphanumeric identifier for internal use only
SYSTEM_ID = "TranscriptionApp"

#DEBUG = True

#System name, the way the system is presented to the world
SYSTEM_NAME = "A Transcriptor for Proper Names"

#An informative description for this system:
#SYSTEM_DESCRIPTION = "This is an intermediate prototype for the transcription system we develop in an NWO 'Kiem' project at Radboud University, The Netherlands, coordinated by Prof. Dr. Nicoline van der Sijs. This system offers transcription facilities for Cyrillic to Dutch as well as fuzzy database look-up facilities for personal names in the JRC Names collection and place names from GeoNames."ö
#SYSTEM_DESCRIPTION = "Dit transcriptiesysteem voor namen werd in een NWO 'Kiem' project ontworpen aan de Radboud Universiteit, onder leiding van Prof.dr. Nicoline van der Sijs. Dit systeem biedt 'Vlug Omzetten' op basis van regelgebaseerde transcriptie van het Russisch naar het Nederlands, het Engels en het Duits en andere omzettingen voor specifieke doeleinden. Het systeem biedt ook fuzzy en metadata gebaseerd opzoeken van anderstalige varianten voor persoons- en plaatsnamen in grote databanken van JRC-Names en Geonames als 'Uitgebreid Zoeken'. Vlug omzetten gebeurt onmiddellijk, het uitgebreid opzoeken vraagt een paar minuten."
SYSTEM_DESCRIPTION = "De Transcriptor geeft Russische persoonsnamen, aardrijkskundige aanduidingen en woorden weer in de schrijfwijze die voor het Nederlandse taalgebied aanbevolen is. Klik op Info voor meer informatie."

hostname = uname()[1]
if hostname == 'ticclops.uvt.nl' or hostname == 'black.uvt.nl':
    HOST = 'ticclops.uvt.nl'
#The root directory for CLAM, all project files, (input & output) and
#pre-installed corpora will be stored here. Set to an absolute path:
    ROOT = '/opensonar/TransApp/'
    URLPREFIX = 'transapp'
    #BASEDIR = '/exp2/mre/ticclops/'
    BASEDIR = '/opensonar/TransApp/'
else:
    #FOR ANY OTHER HOST!
    HOST = 'localhost'
    PORT = 8080
    BASEDIR = '/path/to/ticclops/'
    raise Exception("Write a configuration for your host!")
#########################################################################################################
#########################################################################################################

#Users and passwords
USERS = None #no user authentication
#USERS = { 'username': pwhash('username', SYSTEM_ID, 'secret') } #Using pwhash and plaintext password in code is not secure!!
#Do you want all projects to be public to all users? Otherwise projects are
#private and only open to their owners and users explictly granted access.
PROJECTS_PUBLIC = False

#Amount of free memory required prior to starting a new process (in MB!), Free Memory + Cached (without swap!)
REQUIREMEMORY = 10

#Maximum load average at which processes are still started (first number reported by 'uptime')
#MAXLOADAVG = 1.0
#language = os.environ['language']

# ======== WEB-APPLICATION STYLING =============

#Choose a style (has to be defined as a CSS file in style/ )
#STYLE = 'classic'
STYLE = 'ticclops'

ACTIONS = [
    Action(id='Transliterate',name="Transliterator",
           description="Transliterate a Cyrillic name",command="perl /opensonar/TransApp/Transliterator.pl $PARAMETERS",
           mimetype="text/plain",
           parameters=[
               StringParameter(id='x',name="Input"),
#               IntegerParameter(id='y',name="Value 2"),
               ])
    ]


# ======== ENABLED FORMATS ===========

#Here you can specify an extra formats module
CUSTOM_FORMATS_MODULE = None

INTERFACEOPTIONS = "preselectinputtemplate" # use the first as default (.txt)

PROFILES = [
    Profile(
        InputTemplate('textinput', PlainTextFormat, 'Plain-Text Input',
            StaticParameter(id='encoding',name='Encoding',description='The character encoding of the file', value='utf-8'),
            #acceptarchive=True,
            filename='input.txt',
            #multi=True,
        ),
        #lexiconinputtemplate,  #variable containing the input template defined earlier
        OutputTemplate('ranked', PlainTextFormat, 'Variant Output',
           SetMetaField('encoding','utf-8'),
           filename='output.txt',
           unique=True,
        ),
    ),
]
#The system command. It is recommended you set this to small wrapper
#script around your actual system. Full shell syntax is supported. Using
#absolute paths is preferred. The current working directory will be
#set to the project directory.
#
#You can make use of the following special variables,
#which will be automatically set by CLAM:
#     $INPUTDIRECTORY  - The directory where input files are uploaded.
#     $OUTPUTDIRECTORY - The directory where the system should output
#                        its output files.
#     $STATUSFILE      - Filename of the .status file where the system
#                        should output status messages.
#     $CONFFILE        - Filename of the clam.xml file describing the
#                        system and chosen configuration.
#     $USERNAME        - The username of the currently logged in user
#                        (set to "anonymous" if there is none)
#     $PARAMETERS      - List of chosen parameters, using the specified flags
#

#COMMAND = BASEDIR + "TransApp-wrapper.pl $DATAFILE $STATUSFILE $OUTPUTDIRECTORY " + BASEDIR
COMMAND = BASEDIR +  "TransApp-wrapper.pl $PARAMETERS " + BASEDIR + " $INPUTDIRECTORY $OUTPUTDIRECTORY $STATUSFILE $PROJECT"
#COMMAND = BASEDIR +  "TransApp-wrapper.pl"

#The parameters are subdivided into several groups. In the form of a list of (groupname, parameters) tuples. The parameters are a list of instances from common/parameters.py

PARAMETERS = [
        ('Search Person Names or Place Names', [
            ChoiceParameter('name','Persons or Places?','Search JRC Names or GeoNames',choices=[('JRC','JRC Names'),('GEO','GeoNames')], paramflag='-N')
    ]),
    ('Intermediate Language Selection', [
        ChoiceParameter('lang','Language?','Which interlanguage?', choices=[('ru','Russian [ru]'),('ar','Arabic [ar]'),('be','Belarusian [be]'),('bs','Bosnian [bs]'),('bg','Bulgarian [bg]'),('cs','Czech [cs]'),('cy','Welsh [cy]'),('da','Danish [da]'),('de','German [de]'),('el','Modern Greek (1453-) [el]'),('en','English [en]'),('eo','Esperanto [eo]'),('et','Estonian [et]'),('eu','Basque [eu]'),('fa','Persian [fa]'),('fi','Finnish [fi]'),('fr','French [fr]'),('ga','Irish [ga]'),('sh','Serbo-Croatian [sh]'),('he','Hebrew [he]'),('hr','Croatian [hr]'),('hu','Hungarian [hu]'),('hy','Armenian [hy]'),('id','Indonesian [id]'),('is','Icelandic [is]'),('it','Italian [it]'),('jv','Javanese [jv]'),('ja','Japanese [ja]'),('ka','Georgian [ka]'),('kk','Kazakh [kk]'),('km','Central Khmer [km]'),('lo','Lao [lo]'),('la','Latin [la]'),('lv','Latvian [lv]'),('lt','Lithuanian [lt]'),('ml','Malayalam [ml]'),('mk','Macedonian [mk]'),('mt','Maltese [mt]'),('mn','Mongolian [mn]'),('my','Burmese [my]'),('ne','Nepali [ne]'),('nl','Dutch [nl]'),('no','Norwegian [no]'),('pl','Polish [pl]'),('pt','Portuguese [pt]'),('ro','Romanian [ro]'),('sk','Slovak [sk]'),('sl','Slovenian [sl]'),('es','Spanish [es]'),('sr','Serbian [sr]'),('sv','Swedish [sv]'),('th','Thai [th]'),('tk','Turkmen [tk]'),('tr','Turkish [tr]'),('uk','Ukrainian [uk]'),('uz','Uzbek [uz]'),('vi','Vietnamese [vi]'),('zh','Chinese [zh]')], nospace=True,paramflag='-I')
    ]),
    ('Target Language Selection', [
        ChoiceParameter('lang2','Language?','Which target language?', choices=[('nl','Dutch [nl]'),('ar','Arabic [ar]'),('be','Belarusian [be]'),('bs','Bosnian [bs]'),('bg','Bulgarian [bg]'),('cs','Czech [cs]'),('cy','Welsh [cy]'),('da','Danish [da]'),('de','German [de]'),('el','Modern Greek (1453-) [el]'),('en','English [en]'),('eo','Esperanto [eo]'),('et','Estonian [et]'),('eu','Basque [eu]'),('fa','Persian [fa]'),('fi','Finnish [fi]'),('fr','French [fr]'),('ga','Irish [ga]'),('sh','Serbo-Croatian [sh]'),('he','Hebrew [he]'),('hr','Croatian [hr]'),('hu','Hungarian [hu]'),('hy','Armenian [hy]'),('id','Indonesian [id]'),('is','Icelandic [is]'),('it','Italian [it]'),('jv','Javanese [jv]'),('ja','Japanese [ja]'),('ka','Georgian [ka]'),('kk','Kazakh [kk]'),('km','Central Khmer [km]'),('lo','Lao [lo]'),('la','Latin [la]'),('lv','Latvian [lv]'),('lt','Lithuanian [lt]'),('ml','Malayalam [ml]'),('mk','Macedonian [mk]'),('mt','Maltese [mt]'),('mn','Mongolian [mn]'),('my','Burmese [my]'),('ne','Nepali [ne]'),('no','Norwegian [no]'),('pl','Polish [pl]'),('pt','Portuguese [pt]'),('ro','Romanian [ro]'),('ru','Russian [ru]'),('sk','Slovak [sk]'),('sl','Slovenian [sl]'),('es','Spanish [es]'),('sr','Serbian [sr]'),('sv','Swedish [sv]'),('th','Thai [th]'),('tk','Turkmen [tk]'),('tr','Turkish [tr]'),('uk','Ukrainian [uk]'),('uz','Uzbek [uz]'),('vi','Vietnamese [vi]'),('zh','Chinese [zh]')], nospace=True,paramflag='-T')
    ]),
    
]
