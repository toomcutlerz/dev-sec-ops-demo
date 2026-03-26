FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore as distinct layers
COPY ["src/DevSecOpsDemo.Api/DevSecOpsDemo.Api.csproj", "DevSecOpsDemo.Api/"]
RUN dotnet restore "DevSecOpsDemo.Api/DevSecOpsDemo.Api.csproj"

# Copy everything else and build
COPY ["src/DevSecOpsDemo.Api/", "DevSecOpsDemo.Api/"]
WORKDIR "/src/DevSecOpsDemo.Api"
RUN dotnet build "DevSecOpsDemo.Api.csproj" -c Release -o /app/build

# Publish
FROM build AS publish
RUN dotnet publish "DevSecOpsDemo.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Expose port and configure ASP.NET Core specifically for Cloud Run (defaults to 8080)
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

USER $APP_UID
ENTRYPOINT ["dotnet", "DevSecOpsDemo.Api.dll"]
