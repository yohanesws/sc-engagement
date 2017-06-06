{
	"apiVersion": "v1",
	"kind": "Template",
	"metadata": {
		"name": "hazelcast-ocp",
		"annotations": {
			"description": "Openshift internal deployment template for Hazelcast",
			"tags": "hazelcast, imdg, datagrid, inmemory, kvstore, nosql, java",
			"iconClass": "icon-java"
		}
	},

	"labels": {
		"template": "hazelcast-openshift-template"
	},

	"objects": [{
		"apiVersion": "v1",
		"kind": "ReplicationController",
		"metadata": {
			"generateName": "hazelcast-rc-${DEPLOYMENT_NAME}-"
		},
		"spec": {
			"replicas": 3,
			"selector": {
				"name": "hazelcast-node-${DEPLOYMENT_NAME}"
			},
			"template": {
				"metadata": {
					"name": "hazelcast-node",
					"generateName": "hazelcast-node-${DEPLOYMENT_NAME}-",
					"labels": {
						"name": "hazelcast-node-${DEPLOYMENT_NAME}"
					}
				},
				"spec": {
					"containers": [{
						"image": "${IMAGE_PATH}:${IMAGE_VERSION}",
						"name": "${IMAGE_NAME}",
						"env": [{
							"name": "HAZELCAST_KUBERNETES_SERVICE_DNS",
							"value": "${SERVICE_NAME}.${NAMESPACE}.svc.${KUBERNETES_SERVICE_DOMAIN}"
						}, {
							"name": "HAZELCAST_KUBERNETES_SERVICE_NAME",
							"value": "${SERVICE_NAME}"
						}, {
							"name": "HAZELCAST_KUBERNETES_NAMESPACE",
							"value": "${NAMESPACE}"
						}, {
							"name": "HAZELCAST_KUBERNETES_SERVICE_DNS_IP_TYPE",
							"value": "IPV4"
						}, {
							"name": "HZ_GROUP_NAME",
							"value": "${HZ_GROUP_NAME}"
						}, {
							"name": "HZ_GROUP_PASSWORD",
							"value": "${HZ_GROUP_PASSWORD}"
						}, {
							"name": "HAZELCAST_KUBERNETES_OTHER_MEMBER",
							"value": "${OTHER_MEMBER}"
						}],
						"ports": [{
							"containerPort": 5701,
							"protocol": "TCP"
						}]
					}]
				}
			},
			"triggers": {
				"type": "ImageChange"
			}
		}
	}, {
		"apiVersion": "v1",
		"kind": "Service",
		"metadata": {
			"name": "${SERVICE_NAME}"
		},
		"spec": {
			"type": "ClusterIP",
			"clusterIP": "None",
			"selector": {
				"name": "hazelcast-node-${DEPLOYMENT_NAME}"
			},
			"ports": [{
				"port": 5701,
				"protocol": "TCP"
			}]
		}
	}],

	"parameters": [{
		"name": "DEPLOYMENT_NAME",
		"description": "Defines the base name of this deployment unit",
		"required": true
	}, {
		"name": "IMAGE_PATH",
		"description": "Image Name Full Path",
		"value": "172.30.248.237:5000/hazelcast/scb-hazelcast",
		"required": true
	}, {
		"name": "IMAGE_NAME",
		"description": "Image Name for Label.",
		"value": "scb-hazelcast",
		"required": true
	}, {
		"name": "IMAGE_VERSION",
		"description": "Image Version.",
		"value": "latest",
		"required": true
	},{
		"name": "HZ_GROUP_NAME",
		"description": "hazelcast Group name",
		"value": "dev",
		"required": true
	}, {
		"name": "HZ_GROUP_PASSWORD",
		"description": "hazelcast Group password",
		"value": "dev-password",
		"required": true
	}, {
		"name": "SERVICE_NAME",
		"description": "Defines the service name of the POD to lookup of Kubernetes.",
		"required": true
	}, {
		"name": "NAMESPACE",
		"description": "Defines the namespace of the application POD of Kubernetes.",
		"required": true
	}, {
		"name": "KUBERNETES_SERVICE_DOMAIN",
		"description": "Defines the domain part of a kubernetes dns lookup.",
		"value": "cluster.local",
		"required": true
	}, {
		"name": "OTHER_MEMBER",
		"description": "Defines the domain part of a kubernetes dns lookup.",
		"required": false
	}]
}
