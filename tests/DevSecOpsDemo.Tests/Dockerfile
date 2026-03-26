FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 5146

ENV ASPNETCORE_URLS=http://+:5146

USER app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["tests/DevSecOpsDemo.Tests/DevSecOpsDemo.Tests.csproj", "tests/DevSecOpsDemo.Tests/"]
RUN dotnet restore "tests/DevSecOpsDemo.Tests/DevSecOpsDemo.Tests.csproj"
COPY . .
WORKDIR "/src/tests/DevSecOpsDemo.Tests"
RUN dotnet build "DevSecOpsDemo.Tests.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "DevSecOpsDemo.Tests.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DevSecOpsDemo.Tests.dll"]
