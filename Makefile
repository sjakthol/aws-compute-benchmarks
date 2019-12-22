# Mapping from long region names to shorter ones that is to be
# used in the stack names
AWS_ap-northeast-1_PREFIX = an1
AWS_ap-northeast-2_PREFIX = an2
AWS_ap-south-1_PREFIX = as1
AWS_ap-southeast-1_PREFIX = as1
AWS_ap-southeast-2_PREFIX = as2
AWS_ca-central-1_PREFIX = cc1
AWS_eu-central-1_PREFIX = ec1
AWS_eu-north-1_PREFIX = en1
AWS_eu-west-1_PREFIX = ew1
AWS_eu-west-2_PREFIX = ew2
AWS_eu-west-3_PREFIX = ew3
AWS_sa-east-1_PREFIX = se1
AWS_us-east-1_PREFIX = ue1
AWS_us-east-2_PREFIX = ue2
AWS_us-west-1_PREFIX = uw1
AWS_us-west-2_PREFIX = uw2

# Some defaults
AWS ?= aws
AWS_REGION ?= eu-west-1
AWS_ACCOUNT_ID = $(eval AWS_ACCOUNT_ID := $(shell $(AWS_CMD) sts get-caller-identity --query Account --output text))$(AWS_ACCOUNT_ID)

AWS_CMD := $(AWS) --region $(AWS_REGION)

STACK_REGION_PREFIX := $(AWS_$(AWS_REGION)_PREFIX)-compute-benchmarks

TAGS ?= Deployment=$(STACK_REGION_PREFIX)

define stack_template =


deploy-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation package \
		--template-file $(1) \
		--s3-bucket $(AWS_ACCOUNT_ID)-$(AWS_REGION)-build-resources \
		--s3-prefix $(STACK_REGION_PREFIX) \
		--output-template-file $(1).packaged

	$(AWS_CMD) cloudformation deploy \
		--stack-name $(STACK_REGION_PREFIX)-$(basename $(notdir $(1))) \
		--tags $(TAGS) \
		--template-file $(1).packaged \
		--capabilities CAPABILITY_NAMED_IAM

delete-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation delete-stack \
		--stack-name $(STACK_REGION_PREFIX)-$(basename $(notdir $(1)))


endef

$(foreach template, $(wildcard stacks/*.yaml), $(eval $(call stack_template,$(template))))

DOCKER = docker

login:
	$(AWS_CMD) ecr get-login --no-include-email | bash

build:
	$(DOCKER) build -t benchmark .

tag: build
	$(DOCKER) tag benchmark $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/benchmark

push: tag
	$(DOCKER) push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/benchmark

lambda-invoke:
	$(AWS_CMD) lambda invoke --function-name $(STACK_REGION_PREFIX)-lambda-function --invocation-type Event /dev/null
