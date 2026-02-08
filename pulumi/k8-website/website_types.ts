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
