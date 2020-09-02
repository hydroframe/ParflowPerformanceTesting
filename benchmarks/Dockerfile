FROM parflow/parflow:latest

RUN yum install -y python3 time

RUN pip3 install -y pymongo pandas numpy dnspython

WORKDIR /data

ENTRYPOINT ["tclsh"]
