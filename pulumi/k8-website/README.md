# Kubernetes Website Deployment with Pulumi

A comprehensive guide to deploying containerized applications to Kubernetes using Pulumi and TypeScript.
This uses the docs from [Pulumi](https://www.pulumi.com/docs/iac/get-started/kubernetes/create-component/) to create a custom component for deploying a website to k8s.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [How This Project Was Created](#how-this-project-was-created)
- [How It Works](#how-it-works)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Cleanup](#cleanup)
- [Learning Resources](#learning-resources)

## Overview

This project demonstrates how to use Pulumi to deploy an NGINX web application to Kubernetes. It showcases:

- **Infrastructure as Code (IaC)**: Define Kubernetes resources using TypeScript
- **Reusable Components**: Create custom Pulumi components for common patterns
- **Configuration Management**: Use Pulumi's configuration system for environment-specific settings
- **Type Safety**: Leverage TypeScript for better development experience

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Node.js** (v18 or later)
   ```bash
   node --version
   ```

2. **Pulumi CLI**
   ```bash
   curl -fsSL https://get.pulumi.com | sh
   pulumi version
   ```

3. **kubectl** (Kubernetes CLI)
   ```bash
   kubectl version --client
   ```

4. **Access to a Kubernetes cluster**
   - Local: [Minikube](https://minikube.sigs.k8s.io/), [kind](https://kind.sigs.k8s.io/), or [Docker Desktop](https://www.docker.com/products/docker-desktop)
   - Cloud: GKE, EKS, AKS, or any managed Kubernetes service

5. **Pulumi Account** (free tier available)
   - Sign up at [https://app.pulumi.com](https://app.pulumi.com)

## Project Structure

```
k8-website/
├── index.ts              # Main entry point
├── website.ts            # Custom Pulumi component
├── website_types.ts      # TypeScript interfaces
├── package.json          # Node.js dependencies
├── tsconfig.json         # TypeScript configuration
├── Pulumi.yaml           # Pulumi project metadata
└── Pulumi.dev.yaml       # Stack-specific configuration
```

### File Descriptions

- **`index.ts`**: Orchestrates the deployment by reading configuration and creating resources
- **`website.ts`**: Defines a reusable `KubernetesNginxService` component
- **`website_types.ts`**: Type definitions for deployment and service configurations
- **`Pulumi.yaml`**: Project-level settings (name, runtime, description)
- **`Pulumi.dev.yaml`**: Environment-specific configuration (dev stack)

## How This Project Was Created

### Step 1: Initialize a New Pulumi Project

```bash
# Create project directory
mkdir k8-website
cd k8-website

# Initialize Pulumi project
pulumi new kubernetes-typescript
```

During initialization, you'll be prompted for:
- Project name: `k8-website`
- Project description: `A minimal Kubernetes TypeScript Pulumi program`
- Stack name: `dev`

### Step 2: Install Dependencies

The `pulumi new` command automatically installs dependencies, but you can manually install them:

```bash
npm install
```

Dependencies include:
- `@pulumi/pulumi`: Core Pulumi SDK
- `@pulumi/kubernetes`: Kubernetes provider for Pulumi
- `typescript`: TypeScript compiler
- `@types/node`: Node.js type definitions

### Step 3: Create Type Definitions

Create `website_types.ts` to define configuration interfaces:

```typescript
interface Deployment {
    name: string;
    image: string;
    replicas: number;
}

interface Service {
    name: string;
    type: string; // ClusterIP or LoadBalancer
    port: number;
    targetPort: number;
}

export { Deployment, Service };
```

### Step 4: Build the Custom Component

Create `website.ts` with a reusable component that encapsulates:
- Kubernetes Deployment (manages pods)
- Kubernetes Service (exposes the deployment)

This component follows Pulumi's ComponentResource pattern for creating reusable infrastructure abstractions.

### Step 5: Create the Main Program

In `index.ts`, tie everything together:
1. Read configuration values
2. Instantiate the custom component
3. Export outputs (IP address, deployment name)

### Step 6: Configure the Stack

Set configuration values for the `dev` stack:

```bash
pulumi config set appName nginx
pulumi config set deployment '{"name":"webapp","image":"nginx","replicas":1}' --path
pulumi config set service '{"name":"webapp","type":"ClusterIP","port":80,"targetPort":80}' --path
```

These values are stored in `Pulumi.dev.yaml`.

## How It Works

### Architecture Flow

1. **Configuration Loading**: Pulumi reads `Pulumi.dev.yaml` for stack-specific settings
2. **Component Instantiation**: The `KubernetesNginxService` component is created
3. **Resource Creation**: 
   - A Kubernetes Deployment is created with the specified image and replicas
   - A Kubernetes Service is created to expose the deployment
4. **Output Registration**: The service IP and deployment name are exported

### Component Resource Pattern

The `KubernetesNginxService` class extends `pulumi.ComponentResource`:

```typescript
export class KubernetesNginxService extends pulumi.ComponentResource {
    public readonly ip: pulumi.Output<string>;
    public readonly name: pulumi.Output<string>;
    
    constructor(name: string, args: KubernetesNginxServiceArgs, opts?: pulumi.ComponentResourceOptions) {
        super("k8-website:index:KubernetesNginxService", name, args, opts);
        // Create Deployment and Service
        // Register outputs
    }
}
```

**Benefits**:
- Encapsulation of related resources
- Reusability across projects
- Logical grouping in Pulumi state
- Simplified testing and maintenance

### Kubernetes Resources Created

#### 1. Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
```

#### 2. Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: nginx
```

## Getting Started

### 1. Clone or Create the Project

```bash
# If cloning
git clone <repository-url>
cd k8-website

# If creating from scratch, follow "How This Project Was Created"
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Kubernetes Context

Ensure your `kubectl` is configured to point to your target cluster:

```bash
# View current context
kubectl config current-context

# List available contexts
kubectl config get-contexts

# Switch context if needed
kubectl config use-context <context-name>
```

### 4. Login to Pulumi

```bash
pulumi login
```

This connects to Pulumi's state management backend (cloud or self-hosted).

### 5. Select or Create a Stack

```bash
# List existing stacks
pulumi stack ls

# Select the dev stack
pulumi stack select dev

# Or create a new stack
pulumi stack init staging
```

## Configuration

### View Current Configuration

```bash
pulumi config
```

### Modify Configuration

#### Change Application Name
```bash
pulumi config set appName my-app
```

#### Update Deployment Settings
```bash
pulumi config set deployment '{"name":"my-deployment","image":"nginx:1.21","replicas":3}' --path
```

#### Change Service Type to LoadBalancer
```bash
pulumi config set service '{"name":"my-service","type":"LoadBalancer","port":80,"targetPort":80}' --path
```

### Configuration Options

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `appName` | string | Application label | `nginx`, `webapp` |
| `deployment.name` | string | Deployment resource name | `webapp` |
| `deployment.image` | string | Container image | `nginx:1.21` |
| `deployment.replicas` | number | Number of pod replicas | `1`, `3`, `5` |
| `service.name` | string | Service resource name | `webapp-svc` |
| `service.type` | string | Service type | `ClusterIP`, `LoadBalancer` |
| `service.port` | number | Service port | `80`, `8080` |
| `service.targetPort` | number | Container port | `80`, `8080` |

## Deployment

### Preview Changes

Before deploying, preview what Pulumi will create:

```bash
pulumi preview
```

This shows:
- Resources to be created (+)
- Resources to be updated (~)
- Resources to be deleted (-)

### Deploy the Stack

```bash
pulumi up
```

You'll see:
1. A preview of changes
2. A prompt to confirm: `yes` to proceed
3. Progress as resources are created
4. Outputs (IP address, deployment name)

Example output:
```
Updating (dev)

View Live: https://app.pulumi.com/...

     Type                                          Name              Status
 +   pulumi:pulumi:Stack                          k8-website-dev    created
 +   └─ k8-website:index:KubernetesNginxService  my-nginx          created
 +      ├─ kubernetes:apps/v1:Deployment         webapp            created
 +      └─ kubernetes:core/v1:Service            webapp            created

Outputs:
    deploymentName: "webapp-xxxxx"
    ip            : "10.96.xxx.xxx"

Resources:
    + 4 created

Duration: 15s
```

### Verify Deployment

```bash
# Check pods
kubectl get pods

# Check deployments
kubectl get deployments

# Check services
kubectl get services

# Get detailed information
kubectl describe deployment webapp
```

### Access the Application

#### For ClusterIP Service (default)
```bash
# Port forward to access locally
kubectl port-forward service/webapp 8080:80

# Access in browser
open http://localhost:8080
```

#### For LoadBalancer Service
```bash
# Get the external IP
pulumi stack output ip

# Access in browser (may take a few minutes for IP assignment)
open http://<external-ip>
```

## Cleanup

### Destroy Resources

Remove all resources created by Pulumi:

```bash
pulumi destroy
```

Confirm with `yes` when prompted.

### Remove Stack

```bash
pulumi stack rm dev
```

### Verify Cleanup

```bash
kubectl get all -l app=nginx
```

Should return no resources.

## Learning Resources

### Key Concepts Demonstrated

1. **Pulumi Stacks**: Environment isolation (dev, staging, prod)
2. **Configuration Management**: Stack-specific settings
3. **Component Resources**: Reusable infrastructure abstractions
4. **Outputs**: Exposing resource properties
5. **Type Safety**: TypeScript interfaces for configuration

### Extending This Project

#### Add Multiple Environments

```bash
# Create production stack
pulumi stack init prod

# Configure production
pulumi config set appName nginx-prod
pulumi config set deployment '{"name":"webapp-prod","image":"nginx:1.21","replicas":5}' --path
pulumi config set service '{"name":"webapp-prod","type":"LoadBalancer","port":80,"targetPort":80}' --path

# Deploy to production
pulumi up
```

#### Add Ingress Resource

Extend `website.ts` to include Kubernetes Ingress for domain-based routing.

#### Add ConfigMaps and Secrets

Store application configuration and sensitive data.

#### Add Health Checks

Configure liveness and readiness probes in the deployment spec.

#### Add Resource Limits

Set CPU and memory limits for containers.

### Useful Pulumi Commands

```bash
# View stack outputs
pulumi stack output

# View specific output
pulumi stack output ip

# Export stack state
pulumi stack export > stack.json

# Import stack state
pulumi stack import < stack.json

# View resource details
pulumi stack graph

# Refresh state from actual infrastructure
pulumi refresh
```

### Additional Resources

- [Pulumi Documentation](https://www.pulumi.com/docs/)
- [Pulumi Kubernetes Provider](https://www.pulumi.com/registry/packages/kubernetes/)
- [Pulumi Examples](https://github.com/pulumi/examples)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

## Troubleshooting

### Common Issues

#### 1. Kubernetes Context Not Set
```
Error: unable to load Kubernetes client configuration
```
**Solution**: Configure kubectl with `kubectl config use-context <context-name>`

#### 2. Pulumi Not Logged In
```
Error: not logged in
```
**Solution**: Run `pulumi login`

#### 3. Port Already in Use
```
Error: bind: address already in use
```
**Solution**: Use a different port for port-forwarding or kill the process using the port

#### 4. Image Pull Errors
```
Error: ErrImagePull
```
**Solution**: Verify the image name and ensure the cluster can access the registry

#### 5. Insufficient Permissions
```
Error: forbidden: User cannot create resource
```
**Solution**: Ensure your Kubernetes user has appropriate RBAC permissions

### Debug Mode

Run Pulumi with verbose logging:

```bash
pulumi up --logtostderr -v=9
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is provided as-is for educational purposes.

---

**Happy Learning with Pulumi! 🚀**

