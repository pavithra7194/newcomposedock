FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_16.x  | bash -
RUN apt-get -y install nodejs

COPY . ./
RUN dotnet restore

RUN dotnet build "dotnet6.csproj" -c Release

RUN dotnet publish "dotnet6.csproj" -c Release -o publish


FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base

COPY --from=build /app/publish /app
WORKDIR /app

ENV ASPNETCORE_URLS http://*:5000
ENV DOTNET_USER_HOME /app/data
ENV DOTNET_RUNNING_IN_CONTAINER true

RUN groupadd -r dotnet && useradd -r -g dotnet dotnet
RUN chown -R dotnet:dotnet /app

USER dotnet

EXPOSE 5000
ENTRYPOINT ["dotnet", "dotnet6.dll"]
