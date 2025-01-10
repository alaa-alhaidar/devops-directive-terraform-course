# IAM Roles:
An IAM role is an AWS identity with specific permissions. Roles are used to grant 
permissions to entities that need them, such as EC2 instances, Lambda functions, 
or other AWS services.

# IAM Policies:
Definition: Policies are documents that define permissions. They specify what actions are allowed or denied for a particular AWS service.
Types: AWS provides managed policies (like AmazonS3FullAccess) that are pre-defined and maintained by AWS. You can also create custom policies tailored to your specific needs.

# Step args example
args = [
  "spark-submit",
  "--class", "com.Join",                      # Specify the main class
  "--master", "yarn",                         # Use YARN as the cluster manager
  "--deploy-mode", "cluster",                 # Deploy in cluster mode
  "--driver-memory", "5g",                    # Set driver memory to 5GB
  "--driver-cores", "4",                      # Use 4 cores for the driver
  "--num-executors", "36",                    # Number of executors
  "--executor-memory", "4g",                  # Set executor memory to 4GB
  "--executor-cores", "2",                    # Use 2 cores per executor
  "--conf", "spark.memory.fraction=0.4",      # Set memory fraction
  "--conf", "spark.shuffle.memoryFraction=0.5", # Set shuffle memory fraction
  "--conf", "spark.shuffle.file.buffer=64k",  # Set shuffle file buffer size
  "s3://alaa.data.tuberlin/custom-jar-name_scala2.12-0.1.jar"  # Path to your JAR file in S3
]

# Why You Need aws_iam_instance_profile
Assigning Permissions to EC2 Instances:

The aws_iam_instance_profile resource creates an instance profile that links an IAM role to EC2 instances. This profile is then associated with the EC2 instances in your EMR cluster, allowing them to assume the permissions granted by the role.
EMR Cluster Configuration:

When setting up an EMR cluster, you specify the instance profile for the EC2 instances in the ec2_attributes block. This tells EMR which IAM role the EC2 instances should use.