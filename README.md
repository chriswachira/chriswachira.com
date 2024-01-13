# [chriswachira.com](https://chriswachira.com)

This repo holds the project files for building my portfolio website. The website has been built using:

- Hugo web framework with the [Hugo Profile theme](https://hugo-profile.netlify.app/)
- Terraform for building infrastructure on Amazon Web Services. See the [Infrastructure](#infrastructure) section below.
- Github Actions for CI/CD

## Hugo Profile
This theme eases building a portfolio website as most elements of the website are configured in the `config.yaml` file.

The deployable website i.e. the `public/` directory is then generated on the fly and pushed to a public Amazon S3 bucket using GitHub Actions workflow when a pull request is merged.

## Infrastructure
The website is deployed to a public Amazon S3 bucket that is the origin of a CloudFront distribution. Everything has been built using Terraform (see the `terraform/` directory).

* **Terraform** - This Github repo has been integrated with Terraform Cloud to manage the state for the AWS infrastructure this website runs on. On creating a pull request, the Terraform code is checked for formatting and validated using a GitHub Actions workflow and a Terraform plan is triggered on Terraform Cloud.

* **AWS** - The website files are stored on an S3 bucket which serves as the origin of a CloudFront distribution. The *chriswachira.com* domain's DNS is managed using Route53, where an alias A record is mapped to the CloudFront's distribution domain name.

![Website's infrastructure on AWS](/assets/infrastructure.png)

## Contributing
Anyone is welcome to improve or fix any aspect of this project!