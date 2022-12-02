# Batchflow

Terraform plan for creating a managed AWS Batch environment, in preparation for use with Nextflow. There is nothing specific to Nextflow in the infrastructure, however.



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

**Finally**
- Run `terraform init`
- Run `terraform apply`



## To work with Nextflow

Nextflow requires the AWS cli to be installed on the ephemeral batch instances. To that end, we must first create a suitable AMI, from which we can create the EC2 instances. We do this once prior to executing the Terraform plan.

The instructions below were copied from here: [https://staphb.org/resources/2020-04-29-nextflow_batch.html](https://staphb.org/resources/2020-04-29-nextflow_batch.html)

**Instructions**
- Start a new EC2 instance based on an ECS-optimized Amazon Linux AMI. This comes with Docker pre-installed. 
    - At the time of this writing the ID for one such AMI was `ami-0998e1c357491b7b6` (amzn-ami-2018.03.20221115-amazon-ecs-optimized).
    - You might choose to increase the size of the non-root EBS volume. At the time of writing this defaulted to 22GiB. 
    - You will need SSH access, so you might also choose to associate this new VM with a key-pair.
- SSH into the new instance after startup
- Increase the size of the Docker device size. You can see the original size by inspecting the output of `docker info | grep "Base Device Size"`. We can adjust this by running 

    ```
    docker daemon --storage-opt dm.basesize=100GB
    ```
    where the size,  `100GB` here, is determined by the size of the EBS volume above.
- Install the AWS cli:

    ```
    curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -p /home/ec2-user/miniconda
    /home/ec2-user/miniconda/bin/conda install -c conda-forge awscli
    /home/ec2-user/miniconda/bin/aws --version
    ```

    Note the path of the install for the cli: `/home/ec2-user/miniconda/bin/aws`
- Create an AMI based off this instance (using console or other method of choice). Note the custom AMI ID.

