import ConfigParser
from sqlalchemy import *
from sqlalchemy.orm import *
from sqlalchemy.exc import *
import pdb
#from sqlalchemy import create_engine, MetaData, Table
#from sqlalchemy.orm import scoped_session, sessionmaker
import sys
from six import string_types
import os
galaxy_root = os.path.abspath( os.path.join( os.path.dirname( __file__ ), os.pardir ) )
sys.path.insert( 1, os.path.join( galaxy_root, 'lib' ) )

#sys.path.append("/home/ubuntu/galaxy/lib/")
from galaxy.model import *
from galaxy.model.mapping import init
from galaxy.model.orm.scripts import get_config
#from galaxy.util import bunch
#sys.path.append("/home/ubuntu/galaxy/lib/galaxy/util")
#import bunch
#sys.path.append("/home/ubuntu/galaxy/lib/galaxy/")
#sys.path.append("/home/ubuntu/galaxy/lib/")
#import galaxy.model

#model = bunch.Bunch()
config_file = "/home/ubuntu/galaxy/config/galaxy.ini"
config = ConfigParser.ConfigParser()
config.read(config_file)

dburl = config.get('app:main','database_connection')
sa_session = init( '/tmp/', dburl).context
result = sa_session.query(galaxy.model.Job).get(int('1'))
#cutoff_time = 10000
#jobs = sa_session.query(galaxy.model.Job) \
#                               .filter( and_( galaxy.model.Job.table.c.update_time < cutoff_time, 
#                                              or_(galaxy.model.Job.state == galaxy.model.Job.states.NEW,
#                                                    galaxy.model.Job.state == galaxy.model.Job.states == QUEUED,
#                                                    galaxy.model.Job.state == galaxy.model.Job.states.RUNNING, 
#	                                            galaxy.model.Job.state == galaxy.model.Job.states.UPLOAD ) ) )  
#print sa_session.query(galaxy.model.Job).get
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

#print str(resultOK.job_handler)
#for job in resultOK:
	#pdb.set_trace()
#	print str(job.items()[-1][-1])
#	break

handler = 'handler0'
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

#engine = create_engine( dburl )
#metadata = MetaData( engine )
#sa_session = scoped_session( sessionmaker( bind=engine, autoflush=False, autocommit=True ) )
#model.Job = galaxy.model.Job
#print dir(galaxy.model.Job)
#model.Job.table = Table("job", metadata, autoload=True)
#print dir(model.Job)
#table = sa_session.query(model.Job).get('1')

	
