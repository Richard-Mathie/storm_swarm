FROM ricmathie/storm
MAINTAINER ricmathie

RUN apt-get update && apt-get install -y gcc \
    build-essential \
    git \
    python-dev

RUN apt-get install -y libev4 libev-dev
RUN apt-get install -y python-numpy python-scipy python-scikits-learn
RUN rm -rf /var/lib/apt/lists/*

RUN pip install streamparse lz4 cassandra-driver kafka-python virtualenv
RUN pip install lru-dict ciso8601 ujson gevent flask flask-cqlalchemy 
RUN pip install python-dateutil pytz
