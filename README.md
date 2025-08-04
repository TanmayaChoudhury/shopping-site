# Shopping Site Microservices Platform

This project is a cloud-native shopping site built with Python microservices, orchestrated using Kubernetes, and provisioned with Terraform. It demonstrates a modern, scalable, and modular e-commerce architecture.

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Infrastructure as Code (Terraform)](#infrastructure-as-code-terraform)
- [Kubernetes Manifests](#kubernetes-manifests)
- [CI/CD & Deployment](#cicd--deployment)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [License](#license)

---

## Architecture Overview
- **Kubernetes**: All workloads are containerized and deployed to a Kubernetes cluster for orchestration and scaling.
- **Terraform**: Infrastructure (AKS, Key Vault, Service Principals, etc.) is provisioned and managed using Terraform modules.
- **CI/CD & Monitoring**: Automated build, deployment, and monitoring pipelines are defined in the `Deployment/` directory. Monitoring is also enabled for the website using these CI/CD pipelines.

## Technologies Used
- **Docker**: Containerization
- **Kubernetes (k8s)**: Orchestration and deployment
- **Terraform**: Infrastructure as Code (IaC)
- **Azure AKS**: Managed Kubernetes cluster (example cloud provider)
- **CI/CD**: GitHub Actions or Azure Pipelines (YAML workflows)

## Project Structure
```
Deployment/           # CI/CD and monitoring pipelines (YAML)
Infra-Provisioning/   # Terraform scripts for infra lifecycle
k8s/                  # Kubernetes manifests for all workloads and monitoring
modules/              # Terraform modules (AKS, Key Vault, etc.)
Terraform/            # Root Terraform configuration
```



## Infrastructure as Code (Terraform)
- **Terraform/**: Main configuration, providers, variables, and outputs
- **modules/**: Reusable modules for AKS, Key Vault, and Service Principals
- **Infra-Provisioning/**: Scripts to create and destroy infrastructure

## Kubernetes Manifests
- **k8s/**: Contains all deployment, service, configmap, secret, and ingress YAMLs for workloads and monitoring

## CI/CD & Deployment
- **Deployment/**: Contains YAML files for build, deploy, and monitoring pipelines
- Example: `Build.yml`, `Deploy.yml`, `Monitoring.yml`

## Getting Started
1. **Provision Infrastructure**
   - Configure variables in `Terraform/terraform.tfvars`
   - Run Terraform scripts in `Infra-Provisioning/`
2. **Build & Push Docker Images**
   - Build images for your workloads
   - Push to your container registry
3. **Deploy to Kubernetes**
   - Apply manifests in `k8s/` to your cluster
4. **Access the Application**
   - Use the configured ingress or service endpoint

## Contributing
Contributions are welcome! Please open issues or pull requests for improvements or bug fixes.

## License
This project is licensed under the MIT License.
