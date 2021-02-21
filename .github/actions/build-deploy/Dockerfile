FROM amazonlinux:2

RUN amazon-linux-extras install golang1.11
RUN yum install -y zip

ADD entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
