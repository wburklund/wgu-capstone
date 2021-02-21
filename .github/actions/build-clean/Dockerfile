FROM amazonlinux:2

RUN amazon-linux-extras install rust1
RUN yum install -y openssl-devel zip

ADD entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
