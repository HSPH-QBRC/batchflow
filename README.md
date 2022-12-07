# Batchflow

Terraform plan for creating a managed AWS Batch environment, in preparation for use with Nextflow. There is nothing specific to Nextflow in the infrastructure, however.

Note that this branch places the Batch-spawned EC2 instances in a public subnet within your VPC. Other branches in the repo might do this differently-- see those instructions. 


## Setup

- Install [AWS CLI](https://aws.amazon.com/cli/) and [Terraform](https://www.terraform.io/)
- Configure the AWS CLI:
    ```shell
    aws configure --profile <NAME>
    export AWS_PROFILE=<NAME>
    ```

**Changes to make (before `terraform init` or `apply`)**:

- Change the name of the bucket where we store the Terraform state in `main.tf`. Note that this *cannot* be a variable, so you must change it to an *existing* S3 bucket you own.
- Copy `terraform.tfvars.tmpl` to `terraform.tfvars` and fill in the AMI and name of the storage bucket variables.
    - If you wish to use Nextflow, check the section below regarding creation of a custom AMI. If not, you can use any ECS-compatible AMI.
- (Optional) Change/alter tags and/or AWS region in `main.tf`.
- (Optional) Change the min/max number of vCPUs in `batch.tf`. This affects the size of the instances that can created.
- (Optional) Change the `instance_type` list in `batch.tf` to restrict the choices of EC2 instance types. [See AWS docs](https://docs.aws.amazon.com/batch/latest/userguide/compute_environment_parameters.html) (namely parameter `instanceTypes` under the "Compute resources" heading)
- (Optional) If your Batch compute environment is configured such that you will start an exceptional number of EC2 instances, you might need to change the VPC and subnet CIDR blocks to accommodate more machines.

**Finally**
- Run `terraform init`
- Run `terraform apply`



## To work with Nextflow (before `terraform apply`)

Nextflow requires the AWS cli to be installed on the ephemeral batch instances. To that end, we must first create a suitable AMI, from which we can create the EC2 instances. We do this once prior to executing the Terraform plan.

The instructions below were based on [https://www.nextflow.io/docs/latest/aws.html#custom-ami](https://www.nextflow.io/docs/latest/aws.html#custom-ami)

**Instructions**
- Start a new EC2 instance based on an ECS-optimized Amazon Linux2 AMI. This comes with Docker pre-installed. 
    - At the time of this writing the ID for one such AMI was named "Amazon Linux AMI 2.0.20221115 x86_64 ECS HVM GP2". It was found by searching "ECS" in the search box on the launch page. Look for those based on Amazon Linux 2, not 1; AWS docs recommend using only Amazon Linux 2-based ECS-optimized AMIs, so that case is not covered here.
    - The default root volume size (at time of writing) is 30GB. You might choose to increase the size of that volume to something sufficiently large.
        - One consideration for this lies in the specification of the number of vCPUs in the Batch compute environment (see the `aws_batch_compute_environment` resource in  `batch.tf`) and the vCPU + RAM requirements of your jobs (a `process` in nextflow parlance). These parameters (roughly) determine how AWS Batch chooses to allocate jobs on EC2 instances. 
        For example, let's say you ask for 8 processes/jobs, each of which requires 6 vCPUs and 16GB RAM. If your environment is configured to permit 96 vCPUs and you have *not* restricted the instance types, Batch might choose to start a m4.16xlarge EC2 instance (64vCPU, 256GB RAM). Then, Batch will try to run all 8 jobs on that single EC2 instance, each in its own container. Hence, you will need sufficient disk space to accommodate all 8 of those jobs. If these are, e.g. alignments, you need space for 8 genome indexes, etc. (there is no mechanism for sharing a single index). So choose disk size accordingly.
    - You will need SSH access, so you might also choose to associate this new VM with a new or existing key-pair.
- SSH into the new instance after startup.
- [Install the AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) on the instance. Note that the nextflow docs perform an installation based on miniconda (which installs a 1.x version of AWS cli). However, the official installation docs work as well, and you get the most recent version. Note the path to the tool (e.g. `/usr/local/bin/aws`) which can be customized during the installation process.

- Create an AMI based off this instance (using console or other method of choice). Note the custom AMI ID which is supplied in your `terraform.tfvars`.

