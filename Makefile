# AWS=~/.local/bin/aws
AWS=aws

upload:
	$(AWS) s3 sync --acl public-read $(S3ROOT)/masui.org s3://masui.org

download:
	$(AWS) s3 sync s3://masui.org $(S3ROOT)/masui.org
