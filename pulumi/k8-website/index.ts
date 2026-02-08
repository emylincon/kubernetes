import * as pulumi from "@pulumi/pulumi";
import { Deployment, Service } from "./website_types";

// Import from our new component module:
import { KubernetesNginxService } from "./website";

// Read the configuration value:
const config = new pulumi.Config();
let appName = config.require("appName");
let deployConfig = <Deployment>config.requireObject("deployment");
let serviceConfig = <Service>config.requireObject("service");

// Create an instance of our component:
const nginx = new KubernetesNginxService("my-nginx", {
    appName: appName,
    service: serviceConfig,
    deployment: deployConfig
});

// And export its autoassigned IP:
export const ip = nginx.ip;
export const deploymentName = nginx.name;
