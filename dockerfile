FROM microsoft/dotnet:1.0.1-sdk-projectjson
COPY . /app
WORKDIR /app/__NAME__.Web

RUN dotnet restore ../__NAME__.DataLayer/project.json
RUN dotnet restore ../__NAME__.BusinessLayer/project.json
RUN ["dotnet", "restore"]
RUN ["dotnet", "build"]

EXPOSE 5000/tcp
ENV ASPNETCORE_URLS http://*:5000

ENTRYPOINT ["dotnet", "run", "--server.urls", "http://0.0.0.0:5000"]
