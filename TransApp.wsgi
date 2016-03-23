#!/usr/bin/env python
#-*- coding:utf-8 -*-

###############################################################
# CLAM: Computational Linguistics Application Mediator
# -- WSGI script for launching CLAM (from within a webserver) --
#       by Maarten van Gompel (proycon)
#       http://proycon.github.io/clam
#
#       Copy and adapt this script for your particular service!
#
#       Licensed under GPLv3
#
###############################################################


import sys
import os

WEBSERVICEDIR = '/opensonar/TransApp/' #this is the directory that contains your service configuration file
sys.path.append(WEBSERVICEDIR)
os.environ['PYTHONPATH'] = WEBSERVICEDIR

import TransApp_apache #** import your configuration module here! **
import clam.clamservice
application = clam.clamservice.run_wsgi(TransApp_apache) #** pass your module to CLAM **
