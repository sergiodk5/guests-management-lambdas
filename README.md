# Guests Management Lambdas

This project is a serverless application for managing guests using AWS Lambda and DynamoDB. It provides CRUD operations for guest records, such as creating, retrieving, updating, and deleting guests. The application is built using AWS SAM (Serverless Application Model).

## Features

- Create new guest records with associated participants.
- Retrieve all guest records.
- Update existing guest records.
- Delete guest records.
- Built using AWS Lambda and DynamoDB.

## Prerequisites

Before you begin, ensure you have the following tools installed:

- [AWS CLI](https://aws.amazon.com/cli/) - Command-line interface for AWS services.
- [AWS SAM CLI](https://aws.amazon.com/serverless/sam/) - Command-line interface for building and deploying serverless applications.
- [Docker](https://www.docker.com/) - Required for local testing and development.
- [Ruby](https://www.ruby-lang.org/) - Required to run the application locally.
- [Bundler](https://bundler.io/) - For managing Ruby dependencies.

## Setup

### Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/yourusername/guests-management-lambdas.git
cd guests-management-lambdas
```

### Install Dependencies

Use Bundler to install the Ruby dependencies:

```bash
bundle install
```
or save gems in the project
```bash
bundle install --path vendor/bundle
```

### Environment Configuration

Create a `.env` file in the project root to set up your local environment variables. This file will not be committed to version control:

```plaintext
DYNAMODB_ENDPOINT=http://host.docker.internal:8000
AWS_REGION=us-west-2
AWS_ACCESS_KEY_ID=fakeMyKeyId
AWS_SECRET_ACCESS_KEY=fakeSecretAccessKey
```

### SAM Configuration

1. Copy the example SAM configuration file:

```bash
cp samconfig.example.toml samconfig.toml
```

2. Edit `samconfig.toml` to set your values:
```toml
version = 0.1

[default.deploy]
region = "eu-central-1"
stack_name = "guests-management-lambdas"
s3_bucket = "guests-management-deployment-artifacts"
capabilities = "CAPABILITY_IAM"
```

3. Save the changes.

### Running Locally

**Start DynamoDB Locally**

To test the application locally, you can use the AWS DynamoDB Docker image:

1. Download the image (more info [here](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html))
```bash
docker pull amazon/dynamodb-local
```
2. Create a dynamoDB instance
```bash
docker run -d -p 8000:8000 --name dynamodb-local -v $(pwd)/dynamodb-data:/home/dynamodblocal/data amazon/dynamodb-local -jar DynamoDBLocal.jar -sharedDb -dbPath /home/dynamodblocal/data
```

3. Create a table
```bash
   aws dynamodb create-table --table-name Guests \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --endpoint-url http://localhost:8000 \
    --region us-west-2
```

**Build lambdas with SAM**
```bash
sam build
```

**Start the SAM API**
```bash
sam local start-api
```

**Test the Endpoints**
You can use tools like Postman or `curl` to test the API endpoints:

- Create a Guest:
```bash
curl -X POST http://localhost:3000/guests \
  -H "Content-Type: application/json" \
  -d '{"guest":{"fullName":"John Doe","attending":true,"participants":[{"fullName":"Jane Doe","minor":false}]}}'
```
- Get All Guests:
```bash
curl -X GET http://localhost:3000/guests
```

- Update a Guest:
```bash
curl -X PUT http://localhost:3000/guests/{id} \
  -H "Content-Type: application/json" \
  -d '{"guest":{"fullName":"Jane Doe","attending":false,"participants":[{"fullName":"Jack Doe","minor":true}]}}'
```

- Delete a Guest:
```bash
curl -X DELETE http://localhost:3000/guests/{id}
```

### Deployment

To deploy the application to AWS, run the following command:

```bash
sam deploy
```

Or specify a different configuration file:
```bash
sam deploy --config-file samconfig-dev.toml
```

### Deploying Infrastructure

This project uses AWS CloudFormation to manage infrastructure as code. To set up the necessary resources for this application, follow these steps:

**Deploy S3 Bucket**
1. Navigate to the infrastructure directory:
```bash
cd infrastructure
```
2. Deploy the S3 bucket using AWS CloudFormation:
```bash
aws cloudformation deploy --template-file deployment-bucket-template.yaml --stack-name guests-management-deployment-stack --region eu-central-1
```
This command will create an S3 bucket for storing application artifacts.

3. Monitor the deployment in the [AWS CloudFormation Console](https://console.aws.amazon.com/cloudformation).

4. Verify that the bucket was created in the [S3 Console](href="https://s3.console.aws.amazon.com/s3/").

### Clean Up
To delete the infrastructure, run:

```bash
aws cloudformation delete-stack --stack-name guests-management-deployment-stack --region eu-central-1
```

## License
This project is licensed under the MIT License - see the [LICENSE](https://opensource.org/license/mit) file for details.

