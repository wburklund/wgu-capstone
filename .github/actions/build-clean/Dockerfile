FROM amazonlinux:2

RUN amazon-linux-extras install rust1
RUN yum install -y openssl openssl-devel openssl11 zip

ADD entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
