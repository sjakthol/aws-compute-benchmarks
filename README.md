Benchmarks for Amazon EC2, AWS Fargate and AWS Lambda.

## Features

* Benchmark single-CPU performance of Amazon EC2, AWS Fargate and AWS Lambda environments.

## Results

Here are some results from a benchmark executed in eu-west-1 region on 2019-12-22.

| Compute Option | Result (ops/s)¹ |
|----------------|-----------------|
| EC2 - c5.large | 139.8           |
| EC2 - r5.large | 120.6           |
| EC2 - m5.large | 120.3           |
| EC2 - c4.large | 119.5           |
| Fargate²       | 117.7           |
| Lambda³        | 112.5           |
| EC2 - r4.large | 102.0           |
| EC2 - m4.large | 101.7           |

Footnotes:
1. Operations per second. Higher is better (see below for methodology)
2. Fargate Runtime with 1 vCPU & 2,048 MB of memory
3. Lambda Runtime with 1 vCPU equivalent of compute power (1,972 MB)

## Running Benchmarks

### Prerequisites

You must have the following setup to be able to run these benchmarks:
* AWS credentials with admin level privileges
* AWS account with VPC and Subnets from [sjakthol/aws-account-infra](https://github.com/sjakthol/aws-account-infra).
* Docker

Once setup, you can deploy the benchmark infra (ECR registry) by running

```bash
make deploy-infra
```

in this directory. Once the ECR registry has been created, you'll need to build the Docker image
used for benchmarks:

```bash
make login build tag push
```

### Running Benchmarks

You can execute benchmarks as follows:

* AWS Lambda Benchmark:
  * Deploy: `make deploy-lambda`
  * Execute: `make lambda-invoke`
* AWS Fargate Benchmark
  * Deploy: `make deploy-fargate`
  * Execute: Executed automatically as ECS Service. Executes continuously until deleted (or manually scaled to 0).
* Amazon EC2
  * Deploy: `make deploy-ec2`
  * Execute: Executed automatically. Instance terminated after execution.

The benchmark results can be found from Amazon CloudWatch Log Groups with similar names.

### Cleaning up

Execute the following commands to clean up the relevant resources (also destroys log groups with
results):

```bash
make delete-lambda
make delete-fargate
make delete-ec2
make delete-infra # NOTE: ECR registry must be cleaned manually before deleting the infra.
```

## Methodology

### CPU Performance

The raw, single thread CPU performance is measured with a Node.js application. The application
computes PBKDF2 hashes in a loop and measures the number of hashes computed per second (the
higher the better). Each run lasts for 15 seconds. The code is available in `benchmark/` directory.