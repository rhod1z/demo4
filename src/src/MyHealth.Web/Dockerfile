FROM rhod3rz/aspnetcore:1.0.4 AS base
# FROM sriramdasbalaji/aspnetcore1.0:1.0.4 AS base
WORKDIR /app
EXPOSE 80

FROM rhod3rz/aspnetcore-build:1.0-2.0 AS build
# FROM sriramdasbalaji/aspnetcore-build:1.0-2.0 AS build
USER root
WORKDIR /src
# Copy source files; ensure src/myhealth.web/appsettings.json is updated with sql connection string first.
COPY ./src/. .
RUN dotnet restore ./MHC_ASPNetCore.sln
RUN dotnet build   ./MHC_ASPNetCore.sln -c Release -o /app/build

FROM build AS publish
RUN dotnet publish ./MHC_ASPNetCore.sln -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyHealth.Web.dll"]
