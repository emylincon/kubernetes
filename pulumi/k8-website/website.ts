import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

import { Deployment, Service } from "./website_types";

// Arguments for the Kubernetes NGINX service component.
export interface KubernetesNginxServiceArgs {
    appName: string;
    service: Service;
    deployment: Deployment;
}

// A component that encapsulates creating a Kubernetes NGINX deployment and service.
export class KubernetesNginxService extends pulumi.ComponentResource {
    public readonly ip: pulumi.Output<string>; // the service ip.
    public readonly name: pulumi.Output<string>; // the deployment name.

    constructor(name: string, args: KubernetesNginxServiceArgs, opts?: pulumi.ComponentResourceOptions) {
        super("k8-website:index:KubernetesNginxService", name, args, opts);

        const appLabels = { app: args.appName };
        const deployment = new k8s.apps.v1.Deployment(args.deployment.name, {
            spec: {
                selector: { matchLabels: appLabels },
                replicas: args.deployment.replicas,
                template: {
                    metadata: { labels: appLabels },
                    spec: { containers: [{ name: args.appName, image: args.deployment.image }] }
                }
            }
        }, { parent: this });

        // Allocate an IP to the Deployment.
        const frontend = new k8s.core.v1.Service(args.service.name, {
            metadata: { labels: deployment.spec.template.metadata.labels },
            spec: {
                type: args.service.type,
                ports: [{ port: args.service.port, targetPort: args.service.targetPort, protocol: "TCP" }],
                selector: appLabels
            }
        });

        // When "done", this will print the public IP.
        this.ip = args.service.type === "ClusterIP"
            ? frontend.spec.clusterIP
            : frontend.status.loadBalancer.apply(
                (lb) => lb.ingress[0].ip || lb.ingress[0].hostname
            );

        this.name = deployment.metadata.name;
        this.registerOutputs({
            name: deployment.metadata.name,
            ip: this.ip
        }); // Signal component completion.
    }
}
