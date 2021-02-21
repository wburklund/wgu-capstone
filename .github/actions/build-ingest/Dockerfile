FROM mcr.microsoft.com/dotnet/sdk:3.1-buster

RUN apt install zip

ADD entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
