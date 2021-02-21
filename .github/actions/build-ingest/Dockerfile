FROM mcr.microsoft.com/dotnet/sdk:3.1-buster

VOLUME [ "/artifacts" ]

RUN apt-get update
RUN apt-get install -y zip

ADD entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
