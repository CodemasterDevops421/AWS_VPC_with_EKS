# EKS Cluster Setup using Terraform

This repository contains Terraform code for setting up an Amazon Elastic Kubernetes Service (EKS) cluster on AWS. The Terraform configuration files in this repository automate the provisioning of the necessary infrastructure resources, including the EKS cluster, worker nodes, VPC, and security groups.

## Prerequisites

Before you begin, ensure that you have the following prerequisites in place:

1. AWS account credentials with appropriate permissions to create EKS clusters, IAM roles, and other required resources.
2. Terraform installed on your local machine. You can download Terraform from the official website (https://www.terraform.io/downloads.html) and follow the installation instructions.

## Getting Started

To set up the EKS cluster using Terraform, follow these steps:

1. Clone this repository to your local machine.
2. Configure your AWS credentials by setting the AWS access key and secret key as environment variables or using the AWS CLI (`aws configure`).
3. Modify the variables.tf file in the `eks` and `sg_eks` directories to customize your cluster configuration, such as VPC settings, subnet IDs, and security group rules.
4. Initialize Terraform by running `terraform init` in each directory to download the necessary provider plugins.
5. Run `terraform apply` to create the EKS cluster, worker nodes, VPC, and security groups. Review the planned changes and confirm by typing "yes" when prompted.
6. Wait for Terraform to provision the resources. This process may take several minutes.
7. Once the provisioning is complete, Terraform will display the outputs, including the EKS cluster endpoint for accessing the Kubernetes API.

## Accessing the EKS Cluster

To interact with the EKS cluster, you can use the Kubernetes command-line tool (`kubectl`). Configure `kubectl` to connect to the EKS cluster by following these steps:

1. Install `kubectl` on your local machine by downloading it from the official Kubernetes website or using a package manager.
2. Retrieve the cluster's endpoint and authentication details by running `terraform output` in the `eks` directory.
3. Set the cluster configuration in `kubectl` using the obtained details by running `kubectl config set-cluster <cluster-name> --server=<endpoint>` and `kubectl config set-credentials <cluster-name> --token=<authentication-token>`.
4. Set the current context to the EKS cluster by running `kubectl config use-context <cluster-name>`.
5. Verify your connection to the cluster by running `kubectl get nodes` and confirming that the worker nodes are listed.

## Cleaning Up

To destroy the EKS cluster and associated resources created by Terraform, run `terraform destroy` in each directory. Review the planned actions and confirm by typing "yes" when prompted. This will remove all the provisioned resources from your AWS account.

**Note:** Destroying the resources is irreversible, and it will delete all data stored within the cluster. Make sure to back up any important data before proceeding.

## Contributing

Contributions to this project are welcome! If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This code is released under the [MIT License](LICENSE).

