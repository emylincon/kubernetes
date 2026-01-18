from kubernetes import client, config, watch
import os
from time import sleep


def create_configmap(namespace, name, data):
    core_v1_api = client.CoreV1Api()

    configmap = client.V1ConfigMap(
        metadata=client.V1ObjectMeta(namespace=namespace, name=name), data=data
    )

    # Check if configmap already exists
    try:
        core_v1_api.read_namespaced_config_map(name=name, namespace=namespace)
        print(f"ConfigMap '{name}' already exists in namespace '{namespace}'")
        return
    except client.exceptions.ApiException as e:
        if e.status != 404:
            raise
        # ConfigMap doesn't exist, proceed with creation

    core_v1_api.create_namespaced_config_map(namespace=namespace, body=configmap)


def update_configmap(namespace, name, data):
    core_v1_api = client.CoreV1Api()

    configmap = client.V1ConfigMap(
        metadata=client.V1ObjectMeta(namespace=namespace, name=name), data=data
    )

    # Check if configmap exists before updating
    try:
        core_v1_api.read_namespaced_config_map(name=name, namespace=namespace)
        core_v1_api.patch_namespaced_config_map(
            name=name, namespace=namespace, body=configmap
        )
        print(f"ConfigMap '{name}' updated in namespace '{namespace}'")
    except client.exceptions.ApiException as e:
        if e.status == 404:
            print(
                f"ConfigMap '{name}' not found in namespace '{namespace}', cannot update"
            )
        else:
            raise


def delete_configmap(namespace, name):
    core_v1_api = client.CoreV1Api()
    core_v1_api.delete_namespaced_config_map(name=name, namespace=namespace)


def main():
    CONFIG_TYPE = os.getenv("CONFIG_TYPE", "local")  # local or incluster
    if CONFIG_TYPE == "incluster":
        config.load_incluster_config()  # Use in-cluster configuration
    else:
        config.load_kube_config()
    print(f"Loaded config for CONGIG_TYPE='{CONFIG_TYPE}'")
    api_instance = client.CustomObjectsApi()
    group = "emeka.com"  # Update to the correct API group
    version = "v1"  # Update to the correct API version
    namespace = os.getenv(
        "NAMESPACE", "default"
    )  # Assuming custom resource is in default namespace
    plural = (
        "customconfigmaps"  # Update to the correct plural form of your custom resource
    )
    WAITING_FOR_CRD = False
    while True:
        # Check if the custom resource definition exists
        try:
            api_instance.list_namespaced_custom_object(
                group=group,
                version=version,
                namespace=namespace,
                plural=plural,
                limit=1,
            )
            print(
                f"Custom resource '{plural}' found in namespace '{namespace}', continuing..."
            )
            break
        except client.exceptions.ApiException as e:
            if e.status == 404:
                if not WAITING_FOR_CRD:
                    print(
                        f"Custom resource '{plural}' not found in namespace '{namespace}'"
                    )
                    print("Waiting for CRD to be created...")
                    WAITING_FOR_CRD = True
                sleep(10)
                continue
            else:
                print(f"Error checking custom resource: {e}")
                raise

    print(
        f"Watching for events on custom resource '{plural}' in namespace '{namespace}'"
    )

    # Watch for events on custom resource
    resource_version = ""
    while True:
        stream = watch.Watch().stream(
            api_instance.list_namespaced_custom_object,
            group,
            version,
            namespace,
            plural,
            resource_version=resource_version,
        )

        for event in stream:
            custom_resource = event["object"]
            event_type = event["type"]

            # Extract custom resource name
            resource_name = custom_resource["metadata"]["name"]

            # Extract key-value pairs from the custom resource spec
            resource_data = custom_resource.get("spec", {})
            print("-" * 50)
            print(f"Resource data: {resource_data}")
            print(f"Event type: {event_type}")
            print(f"Resource name: {resource_name}")
            print(f"Resource version: {custom_resource['metadata']['resourceVersion']}")

            # Handle events of type ADDED (resource created)
            if event_type == "ADDED":
                create_configmap(
                    namespace=namespace, name=resource_name, data=resource_data
                )
            # Handle events of type DELETED (resource deleted)
            elif event_type == "DELETED":
                delete_configmap(namespace=namespace, name=resource_name)
            # Handle events of type MODIFIED (resource updated)
            elif event_type == "MODIFIED":
                update_configmap(
                    namespace=namespace, name=resource_name, data=resource_data
                )

            # Update resource_version to resume watching from the last event
            resource_version = custom_resource["metadata"]["resourceVersion"]


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("Exiting...")
    except Exception as e:
        print(f"Exception Error: {e}")
