
import os
import sys

print '-' * 100
print '#' * 10, 'config spark at startup'

spark_home = os.environ.get('SPARK_HOME', None)

if not spark_home:
    raise ValueError('SPARK_HOME environment variable is not set')
else:
    print 'spark home at : ', spark_home

    sys.path.insert(0, os.path.join(spark_home, 'python'))
    sys.path.insert(0, os.path.join(spark_home, 'python/lib/py4j-0.9-src.zip'))
    # execfile(os.path.join(spark_home, 'python/pyspark/shell.py'))

print '-' * 100
