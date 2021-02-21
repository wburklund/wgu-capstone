FROM amazonlinux:2

RUN amazon-linux-extras install rust1
RUN yum install zip

ADD entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
