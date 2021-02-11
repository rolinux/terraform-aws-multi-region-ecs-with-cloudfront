# Terraform AWS Multi-Region ECS Cluster with CloudFront failover CDN 

This repository started as an interview Terraform exercise/challenge with the following requirements:

```markdown
# Cloud Deployment and Hosting

## Background:

You have been asked to create a website for a modern company that has recently migrated
their entire infrastructure to AWS. They want you to demonstrate a basic website with some text
and an image, hosted and managed using modern standards and practices in AWS.

You can create your own application, or use open source or community software. The proof of
concept is to demonstrate hosting, managing, and scaling an enterprise-ready system. This is
not about website content or UI.

## Requirements:

* Deliver the tooling to set up an application which displays a web page with text and an
image in AWS. (AWS free-tier is fine)
* Provide and document a mechanism for scaling the service and delivering the content to
a larger audience.
* Source code should be provided via a publicly accessible Github repository.
* Provide basic documentation to run the application along with any other documentation
you think is appropriate.
* Be prepared to explain your choices.

## Extra Mile Bonus (**not** a requirement)
In addition to the above, time permitting, consider the following suggestions for taking your
implementation a step further.

* Monitoring/Alerting
* Security
* Automation
* Network diagrams
```

## Architecture decisions:

* initial read of the requirements pointed me to a fully static website and for a strictly static website a S3 static website (with or without multi-region and with or without CloudFront) was easy, scalable and very secure. Dynamic content can be added with help of CloudFront to point dynamic to different Origin like Amazon API Gateway or another endpoint.

* use of EKS might have been overkill for the design

* use of auto scaling groups EC2 instances might have been too much of a classic way to designing solutions with own challenges of securing and autoscaling

* as the interviewing company already uses ECS and due to my confort with containers the decision was made to use **Amazon Elastic Container Service (Amazon ECS)**

* to help with deployment I created 2 container images with the content from inside `containers` folder and push them to Amazon Public ECR. One container is tagged as `v1` and second one for use for **canary** deployment is tagges as `v2`

* the decision process went next into making sure that the setup can work even if the primary region has an outage so the terraform was setup with a module and set to create ECS clusters, services and task in both `us-east-1` region (primary) and `eu-west-1` region (failover) and setup CloudFront to failover if primary region is not working

* we can use **canary** deployments with options in Terraform to allow turning it **on** and **off** and set the percentage of traffic to go **canary** service and tasks

* CloudFront exposes HTTPS even if the backend doesn't with using the AWS Certificate Manager free certificate

* we added a Security Group to the ALB to allow port 80 traffic from Internet


## Diagram:

![Diagram](/draw.io/multi_region_ecs.png?raw=true "Diagram")

## How to use it

* git clone repo

* change variables

* `terraform init`

* `terraform plan` and provide the ARN for the certificate

* scale by changing `desired_count` in the `ecs.tf` in the main page - can be done independently per region

* change canary version by changing the `image_tag_canary` variable

* change canary percentage of traffic using the `canary_percentage` variable

## Potential improvements:

* separate the `desired_count` between `current` service and `canary` service

* add monitoring and automation to scale the number of tasks inside a service based on load
