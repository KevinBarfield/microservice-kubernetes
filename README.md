Microservice Kubernetes Order Processing Application
=====================

Overview
--------

This project creates a complete micro service demo system in Docker
containers. The services are implemented in Java using Spring and
Spring Cloud.



It uses four docker microservices:
- `Apache` homepage and proxy
- `Order` to process orders.
- `Customer` to handle customer data.
- `Catalog` to handle the items in the catalog.

# Components

Apache HTTP Load Balancer
------------------------

Apache HTTP is used to provide the web page of the demo at
port 8080. It also forwards HTTP requests to the microservices. This
is not really necessary as each service has its own port on the
Minikube host but it provides a single point of entry for the whole system.
Apache HTTP is configured as a reverse proxy for this.
Load balancing is left to Kubernetes.

To configure this Apache HTTP needs to get all registered services from
Kubernetes. It just uses DNS for that.

Please refer to the subdirectory [microservice-kubernetes-demo/apache](microservice-kubernetes-demo/apache/) to see how this works.


Java Services
-------------------

The microservices are:

- [microservice-kubernetes-demo-catalog](microservice-kubernetes-demo/microservice-kubernetes-demo-catalog) is the application to take care of items.
- [microservice-kubernetes-demo-customer](microservice-kubernetes-demo/microservice-kubernetes-demo-customer) is responsible for customers.
- [microservice-kubernetes-demo-order](microservice-kubernetes-demo/microservice-kubernetes-demo-order) does order processing. It uses
  microservice-kubernetes-demo-catalog and microservice-kubernetes-demo-customer.

The microservices use REST to communicate to each other.
See e.g. [CatalogClient](microservice-kubernetes-demo/microservice-kubernetes-demo-order/src/main/java/com/ewolff/microservice/order/clients/CatalogClient.java) .
The hostname is configurable to allow tests with stubs.
The default is `catalog` which works with Kubernetes.
Other microservices are found using Kubernetes built-in DNS.
Kubernetes does the load balancing on the IP level.

# Install/Prepare to run the demo 

### AWS

### Install the AWS CLI and AWSexport credentials 
[AWS CLI Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

[AWS Export Credentials](https://github.com/benkehoe/aws-export-credentials)

### Login to AWS and set credientials
#### Option 1 - Individual/Personal AWS Account
1. Use your AWS account
2. Create an AWS IAM user - Note this user will need some IAM permissions including roles, policies, OpenID

### Configure the AWS CLI
[AWS CLI configure Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

```
% aws --version
aws-cli/2.11.5 Python/3.11.2 Darwin/22.3.0 exe/x86_64 prompt/off
```

```
% aws sts get-caller-identity
{
    "UserId": "YYA4ZRSAMPLE6IDAGV2YP",
    "Account": "378929636692",
    "Arn": "arn:aws:iam::378929636692:user/dockerbisson"
}
```
#### Option 2: AWS SSO with profile
0. Setup (one time only)
Make sure there are not credientials in the .aws/credientials file
Configure the SSO session
```
aws sso configure
```
1. Clear prior AWS credentials from env:
```
for var in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN AWS_PROFILE export AWS_CREDENTIAL_EXPIRATION; do eval unset $var ; done
```
2. SSO Login with profile:
```
aws sso login --profile yourProfile
```
3. Export new credentials to env:
```
eval $(aws-export-credentials --profile yourProfile --env-export)
```
NOTE: SSO credentials have timed expirations.  To renew your credentials, first sign out then repeat steps above:
```
aws sso logout
```


### Tools to install on new laptop
1. Install brew: 
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
2. Install helm: `brew install helm`
3. Install jq: `brew install jq`

### Terraform Cloud

1. [Create account](https://app.terraform.io/signup/account)
2. Create an org - use the org name in the terraform.tf file
3. [Terraform variables with AWS credentials](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-create-variable-set)

### Terraform local

From the top level of the repo

1. `brew install terraform` (first time install only  )
2. Set the AWS region in the `variables.tf` file 
2. `terraform init`
3. `terraform plan`
4. `time terraform apply -auto-approve`

### kubectl config

Set `kubectl` config ([more details](https://repost.aws/knowledge-center/eks-cluster-connection)):
Note: Make sure the region matches and is one you can use.
Individual Account:
```
aws eks --region us-east-1 update-kubeconfig --name demo-eks-tp
```
Profile Account:
```
aws --profile yourProfile eks update-kubeconfig --region us-east-1 --name demo-eks-tp
```

The `region` and `name` values match those in the `variables.tf` and `main.tf` files.

### Build the images
1. Log in to your Docker Hub account by entering `docker login` on the command
line.
2.  Set the environment variable `DOCKER_ACCOUNT` to the name of the account and verify it with echo.
```
export DOCKER_ACCOUNT=your account
echo $DOCKER_ACCOUNT
```

3. Building locally (and push for x86). Run `docker-build.sh` in the directory
`microservice-kubernetes-demo`. It compiles the Java source and builds the images locally by default.  
```
./docker-build.sh 
```
If you use the "push" command, it will also upload them to Docker Hub using your account.
```
./docker-build.sh push
```

3a. If you are running on arm64 (apple silicon) and want to push x86 images, you will need to compile locally then push images to hub using buildx.  Change to the directory `microservice-kubernetes-demo` and run the following command.  NOTE: This does not build images locally, only remotely.
```
./docker-buildx.sh
```
### Deploy to EKS
The `./kubernetes-deploy.sh` script will deploy the images located in your account on docker hub.  Run this in the directory
`microservice-kubernetes-demo` :

```
[~/microservice-kubernetes/microservice-kubernetes-demo]./kubernetes-deploy.sh
deployment "apache" created
service "apache" exposed
deployment "catalog" created
service "catalog" exposed
deployment "customer" created
service "customer" exposed
deployment "order" created
service "order" exposed
```

Confirm the services are running using `kubectl`
```
kubectl get all
```
### Confirm the app is running in EKS (may take a minute or two for the app to be running).  Once it is running, use the command below to open a browser tab to the application

```
open "http://$(kubectl get service -o json | jq -r '.items[0].status.loadBalancer.ingress[].hostname')"
```

### Browser setup (optional, can use preview URL instead)
1. Install the mod header extension for chrome

### Telepresence extension setup (required for GUI or spec intercepts)
1. Open Docker Desktop
2. Install telepresence extension

### REQUIRED if you are going to demo the intercept spec method
1. Update the kubernetes context in the yaml file that you plan to use (apache-intercept.yaml, catalog-order-intercept.yaml, or order-intercept.yaml) files in the microservice-kubernetes directory - get it from kubectl
```
kubectl config current-context
```


# Demo Execution

## Sections
### Front End Intercept
### Back End Intercept (single service)
### Back End Intercept (multiple services)

---
## WARNING:
I have seen intermittent errors when loading the telepresence sidecar traffic agents onto the kubernetes pods.  Once the sidecars are loaded, the intercepts seem to be stable.  
I would HIGHLY recommend running the intercepts for each pod that you want to demo before the meeting to ensure the pods are working properly.  You can check this by looking at the pods through kubectl to ensure they are running, and by checking the demo app functionality

## Front End Intercept
Show the app running in EKS, show the homepage is missing the logo and has two links with the same name

### Update the index.html page to add the telepresence logo and change the link text for the second catalog link and build the image
1. cd to the microservice-kubernetes-demo/apache directory
2. Open the index.html file
3. Add the telepresence logo image (changes are bolded)
```
<body>
```
  **`<img src="images/telepresence-for-docker.svg"/>`**
```
	<h1>Order Processing</h1>
```
4. change the second catalog link in index.html and save(changes have ** around them)
```
				<a href="/catalog/searchForm.html">**Search** Catalog</a>
```
5. Run `docker build --tag=microservice-kubernetes-demo-apache .`

## IMPORTANT - the Spec, GUI and CLI telepresence intercept options are separate.  You can do each of them, but you need to make sure the intercept is down before switching between them.  Please make sure you click the "disconnect/leave" icon when you are switching between these options

### (spec option only)Docker desktop and telepresence create intercept

1. Open Docker Desktop
2. Go to the telepresence extension
3. Select "Get Started" - the Select Cluster for Telepresence Connection Dialog will appear
4. The kubeconfig context should show the aws cluster
5. Select "Install telepresence on this cluster" only if this is the first connection since building the cluster
6. Select the down arrow next to the connect button, upload intercept spec should display
7. Select the apache-intercept.yaml file in the microservice-kubernetes-demo folder
8. Telepresence will start the intercept with the image specified in the intercept file
9. There may be a warning message show up in a pop up from the container, you can ignore this and close it

### (GUI option only) Docker desktop and telepresence setup 

1. Open Docker Desktop
2. Go to the telepresence extension
3. Select "Get Started" - the Select Cluster for Telepresence Connection Dialog will appear
4. The kubeconfig context should show the aws cluster
5. Select "Install telepresence on this cluster" only if this is the first connection since building the cluster
6. Select connect
7. The default namespace should pop 
3. The four services service should be listed
4. Click Intercept next to the Apache service
5. A dialog appears for the Intercept
6. Make sure the target docker image is microservice-kubernetes-demo-apache:latest
7. Both the Service Port Number and the Target Port Number are 80
8. Leave the other settings
9. Click Create Intercept
10. There may be a warning message show up in a pop up from the container, you can ignore this and close it

### (CLI option only) Telepresence connect and creating the intercept 

1. Type `telepresence intercept --docker apache --port 80:80 --docker-run -- -it --rm microservice-kubernetes-demo-apache:latest`

### Show the container running(optional)
1. Go to the containers tab
2. Show there is a `tp-apache` or `intercept-apache` container running
3. Explain that the telepresence extension runs this container when the intercept starts based on the image you specify
4. Also note there is another container running that is the telepresence daemon.

### Showing the intercept
Option 1: HTTP headers
1. Copy the request header string shown in the current running intercepts (or on the terminal page)
2. Put the `x-telepresence-intercept-id` in the name field in mod header
3. Put the rest (minus the colon after id) into the value field and make sure the green check is there
4. Refresh the order processing homepage page to see the new image and link text
5. Turn off the header and show the unchanged page

Option 2: Preview URL
1. Click the preview URL link (or copy from the terminal page), put it in a new tab, and show the updated page
2. Refresh the original tab to show the unchanged page

### (GUI) Stop the intercept
1. Click stop intercept
2. (optional) show the local container has stopped as well
3. You may need to click the "leave" icon in the upper right to get back to the connect/startpage in the telepresence extension - there may also be a warning message, you can ignore it.

### (CLI) Stop the intercept
1. type 'telepresence leave' (note this may not be required if you control C the telepresence command)

---


## Back End Demo (Single Service)
1. Show the app running in EKS, go to the orders page - there are no orders.
2. Create an order, add a line with a quantity, and hit submit.
3. Click list to see the order
4. Click delete next to the order
5. Get an error that the method is not allowed

### Update the Java code to fix the error and build the image
1. cd to the microservice-kubernetes-demo/microservice-kubernetes-demo-order/src/main/java/com/ewolff/microservice/order/logic directory
2. Open the OrderController.java file
3. Update the method that has "DELETE" in it to POST(change in **)
```
	@RequestMapping(value = "/{id}", method = RequestMethod.**POST**)
	public ModelAndView post(@PathVariable("id") long id) {
		orderRepository.deleteById(id);
```
4.  save the file
5. cd up to the microservices-kubernetes-demo directory
5. Run `./docker-build.sh` to recompile and build the image (local only)

## IMPORTANT - the Spec, GUI and CLI telepresence intercept options are separate.  You can do each of them, but you need to make sure the intercept is down before switching between them.

### (spec option only)Docker desktop and telepresence create intercept

1. Open Docker Desktop
2. Go to the telepresence extension
3. Select "Get Started" - the Select Cluster for Telepresence Connection Dialog will appear
4. The kubeconfig context should show the aws cluster
5. Select "Install telepresence on this cluster" only if this is the first connection since building the cluster
6. Select the down arrow next to the connect button, upload intercept spec should display
7. Select the order-intercept.yaml file in the microservice-kubernetes folder
8. Telepresence will start the intercept with the image specified in the intercept file

### (GUI option only) Docker desktop and telepresence setup 

1. Open Docker Desktop
2. Go to the telepresence extension
3. Select "Get Started" - the Select Cluster for Telepresence Connection Dialog will appear
4. The kubeconfig context should show the aws cluster
5. Select "Install telepresence on this cluster" only if this is the first connection since building the cluster
6. Select connect
7. The default namespace should pop 
3. The four services service should be listed
4. Click Intercept next to the Order service
5. A dialog appears for the Intercept
6. Make sure the target docker image is microservice-kubernetes-demo-order:latest
7. Target Port Number is 8080
8. Leave the other settings
9. Click Create Intercept

### (CLI option only) Telepresence connect and creating the intercept 

1. Type `telepresence intercept --docker order --port 8080:8080 --docker-run -- -it --rm microservice-kubernetes-demo-order:latest`
Note: you will get logging from the Java service, just scroll up to the telepresence output you need

### Show the container running(optional)
1. Go to the containers tab
2. Show there is a `tp-order` container running
3. Explain that the telepresence extension runs this container when the intercept starts based on the image you specify
4. Also note there is another container running that is the telepresence daemon.

### Showing the intercept
HTTP headers
1. Copy the request header string shown in the current running intercepts (or on the terminal page)
2. Put the `x-telepresence-intercept-id` in the name field in mod header
3. Put the rest (minus the colon after id) into the value field and make sure the green check is there
4. Go to the orders list - see there are no orders now because the order service has no permament storage
5. Create an order, add a line with a quantity, and hit submit.
6. Click list to see the order
7. Click delete next to the order
8. Delete successful
9. Click list to see the order is gone
10. Turn off header and click list to see original order is there, still can't delete it

### (GUI) Stop the intercept
1. Click stop intercept
2. (optional) show the local container has stopped as well

### (CLI) Stop the intercept
1. type 'telepresence leave'

## Back End Demo (Multiple Service - spec option only)
1. Show the app running in EKS, go to the catalog page
2. Show that the price field has no $ and only one decimal point
3. Go to the orders page
4. If there are no orders then create an order, add a line with a quantity, and hit submit
5. Click list to see the order
6. Show that the price field has no $ and only one decimal point

### Update the Java code to fix the error and build the image
1. Go to the microservice-kubernetes-demo/microservice-kubernetes-demo-catalog/src/main/resources/templates directory
2. Open the itemlist.html file
3. Update the line for item price to use the numbers currency format (shown below)
```
					<td th:text="${#numbers.formatCurrency(item.price)}">42.0</td>
```
4.  save the file
5. Go to the microservice-kubernetes-demo/microservice-kubernetes-demo-order/src/main/resources/templates directory
6. Open the orderlist.html file
7. Update the line for item price to use the numbers currency format (shown below)
```
		<td th:text="${#numbers.formatCurrency(order.totalPrice(@catalogClient))}">42.0</td>
```
8.  save the file

### Docker desktop and telepresence create intercept

1. Open Docker Desktop
2. Go to the telepresence extension
3. Select "Get Started" - the Select Cluster for Telepresence Connection Dialog will appear
4. The kubeconfig context should show the aws cluster
5. Select "Install telepresence on this cluster" only if this is the first connection since building the cluster
6. Select the down arrow next to the connect button, upload intercept spec should display
7. Select the intercept-catalog-order.yaml file in the microservice-kubernetes folder
8. Telepresence will start the intercept with the images specified in the intercept file

### Show the container running(optional)
1. Go to the containers tab
2. Show there is both a `tp-catalog` and a `tp-order` container running
3. Explain that the telepresence extension runs both these containers when the intercept starts based on the image you specify
4. Also note there is another container running that is the telepresence daemon.

### Showing the intercept
HTTP headers
1. Copy the request header string shown in the current running intercepts (or on the terminal page)
2. Put the `x-intercept-id` in the name field in mod header
3. Put the rest (minus the colon after id) into the value field and make sure the green check is there
4. Go to the catalog list - show the prices are now formatted properly
5. Go to the order list - see there are no orders now because the order service has no permament storage
5. Create an order, add a line with a quantity, and hit submit.
6. Click list to see the order
7. Show the prices are now formatted properly
8. Turn off header and show both prices are back to being incorrectly formatted

### (GUI) Stop the intercept
1. Click stop intercept
2. (optional) show the local container has stopped as well

# Demo cleanup

### Change the app back

Either revert the changes manually, or use git (warning this will remove any config changes you have made in the app as well as the code changes)
```
git reset –hard
git clean -fxd
```

### Remove the deployed services
1. cd to the microservices-kubernetes-demo directory
2. To remove all services and deployments run `kubernetes-remove.sh`:

```
[~/microservice-kubernetes/microservice-kubernetes-demo]./kubernetes-remove.sh 
service "apache" deleted
service "catalog" deleted
service "customer" deleted
service "order" deleted
deployment "apache" deleted
deployment "catalog" deleted
deployment "customer" deleted
deployment "order" deleted
```
### Verify the app is deleted (only the generic kubernetes service should remain)
```
kubectl get all 
```
### Change the kubectl context back to Docker desktop

1. type `kubectl config use-context docker-desktop`

### Deleting the infrastructure from AWS

From the top-level of the repo

1. `terraform destroy -auto-approve`
2. Manually delete any load balancers associated with the cluster [in the web console](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#LoadBalancers)
3. Manually delete the VPC associated with the cluster [in the web console](https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1)
4. `terraform destroy -auto-approve` again

### Clearing DNS cache

If needed...

```
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```