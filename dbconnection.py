import ConfigParser
from sqlalchemy import *
from sqlalchemy.orm import *
from sqlalchemy.exc import *
import pdb
import sys
from six import string_types
import os
galaxy_root = os.path.abspath( os.path.join( os.path.dirname( __file__ ), os.pardir ) )
sys.path.insert( 1, os.path.join( galaxy_root, 'lib' ) )

from galaxy.model import *
from galaxy.model.mapping import init
from galaxy.model.orm.scripts import get_config
import argparse
parser = argparse.ArgumentParser(description="Handler id")
parser.add_argument('-handler','--handler', help="Handler id")
args = parser.parse_args()

config_file = "/home/ubuntu/galaxy/config/galaxy.ini"
config = ConfigParser.ConfigParser()
config.read(config_file)

#Get database connection
dburl = config.get('app:main','database_connection')
sa_session = init( '/tmp/', dburl).context
result = sa_session.query(galaxy.model.Job).get(int('1'))

#Get all jobs that are in one of the following states: new, queued, running, upload
jobsNEW = sa_session.query(galaxy.model.Job).filter(galaxy.model.Job.state == 'new')
jobsQUEUED = sa_session.query(galaxy.model.Job).filter(galaxy.model.Job.state == 'queued')
jobsRUNNING = sa_session.query(galaxy.model.Job).filter(galaxy.model.Job.state == 'running')
jobsUPLOAD = sa_session.query(galaxy.model.Job).filter(galaxy.model.Job.state == 'upload')
jobsOK = sa_session.query(galaxy.model.Job).filter(galaxy.model.Job.state == 'ok')

resultOK = sa_session.execute(jobsOK)
resultNEW = sa_session.execute(jobsNEW)
resultQUEUED = sa_session.execute(jobsQUEUED)
resultRUNNING = sa_session.execute(jobsRUNNING)
resultUPLOAD = sa_session.execute(jobsUPLOAD)

#For the specified handler, check if there is a job in one of the following states: new, queued, running, upload
handler = args.handler
flagNew = False
for job in resultNEW:
	if job.items()[-1][-1] == handler:
		flagNew = True

flagQueued = False
for job in resultQUEUED:
	if job.items()[-1][-1] == handler:
		flagQueued = True

flagRunning = False
for job in resultRUNNING:
	if job.items()[-1][-1] == handler:
		flagRunning = True

flagUpload = False
for job in resultUPLOAD:
	if job.items()[-1][-1] == handler:
		flagUpload = True

if flagNew or flagQueued or flagRunning or flagUpload:
	print True		
else:
	print False
	
