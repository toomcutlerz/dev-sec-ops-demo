# DevSecOps Demo Project

This is a demonstration project showcasing an enterprise-grade DevSecOps pipeline using GitHub Actions, a .NET 10 Web API backend, and deployment to Google Cloud Run with comprehensive security scanning.

## Features

- **Backend**: .NET 10 Web API with OpenAPI/Swagger documentation.
- **Testing**: xUnit test project for unit testing.
- **Containerization**: Multi-stage Dockerfile optimized for production and Cloud Run.
- **CI/CD Pipeline**: Fully automated GitHub Actions workflow including:
  - Application build and unit testing.
  - **SAST (Static Application Security Testing)**: SonarCloud for code quality and vulnerability detection.
  - **SCA (Software Composition Analysis)**: Snyk for dependency vulnerability scanning.
  - Image building and pushing to Google Artifact Registry (GAR).
  - Deployment to Google Cloud Run (Authenticated Service).
  - **DAST (Dynamic Application Security Testing)**: OWASP ZAP scanning against the deployed Cloud Run service using a dynamic Bearer token.

## Prerequisites

To run this project and its pipeline, you will need:

1. **.NET 10 SDK**: Installed locally for development.
2. **Docker**: For building and running the containerized application locally.
3. **Accounts**:
   - [GitHub](https://github.com/) (for hosting the repo and running Actions).
   - [SonarCloud](https://sonarcloud.io/) (for code quality scanning).
   - [Snyk](https://snyk.io/) (for dependency scanning).
   - [Google Cloud Platform](https://console.cloud.google.com/) (for Artifact Registry and Cloud Run).

## GitHub Repository Secrets

Configure the following secrets in your GitHub repository before running the action:

| Secret Name        | Description |
| ------------------ | ----------- |
| `SONAR_TOKEN`      | Token generated from your SonarCloud account. |
| `SNYK_TOKEN`       | Token generated from your Snyk account. |
| `GCP_PROJECT_ID`   | Your Google Cloud Project ID. |
| `GCP_CREDENTIALS`  | Raw JSON string of your Google Cloud Service Account key. This account needs `Artifact Registry Writer` and `Cloud Run Admin` roles. |
| `GITHUB_TOKEN`     | (Automatically provided by GitHub Actions) Used for SonarCloud PR decoration. |

## Running Locally

### Using .NET CLI

1. **Restore dependencies**:
   ```bash
   dotnet restore
   ```

2. **Build the application**:
   ```bash
   dotnet build
   ```

3. **Run Unit Tests**:
   ```bash
   dotnet test
   ```

4. **Run the API**:
   ```bash
   cd src/DevSecOpsDemo.Api
   dotnet run
   ```
   Navigate to `http://localhost:<port>/swagger` to view the OpenAPI documentation.

### Using Docker

1. **Build the Docker Image**:
   ```bash
   docker build -t devsecops-api .
   ```

2. **Run the Docker Container**:
   ```bash
   docker run -p 8080:8080 devsecops-api
   ```
   Navigate to `http://localhost:8080/swagger` to view the OpenAPI documentation.

## Pipeline Stages Breakdown

The GitHub Actions workflow (`.github/workflows/devsecops-pipeline.yml`) is split into the following main jobs:

1. **build-and-test**: 
   - Checks out the code.
   - Sets up .NET 10.
   - Restores, builds, and runs unit tests.
2. **sonarcloud-scan**:
   - Executes SonarCloud for code quality analysis.
3. **snyk-scan**:
   - Executes Snyk to scan dependencies for vulnerabilities.
4. **build-and-push-docker**: (Runs only on `main` branch after `build-and-test`, `sonarcloud-scan`, and `snyk-scan` pass)
   - Authenticates to Google Cloud via Service Account.
   - Configures Docker for Google Artifact Registry.
   - Builds and pushes the Docker image.
5. **deploy-to-cloud-run**: (Runs only on `main` branch after `build-and-push-docker` passes)
   - Authenticates to Google Cloud via Service Account.
   - Deploys the image to Google Cloud Run as a secure (authenticated) service.
   - Generates an ID token and runs an OWASP ZAP Baseline scan against the deployed service's Swagger endpoint.