{
	"apiVersion": "v1",
	"kind": "Template",
	"metadata": {
		"name": "hazelcast",
		"annotations": {
			"description": "deployment template for Hazelcast",
			"tags": "hazelcast, imdg, datagrid, inmemory, kvstore, nosql, java",
			"iconClass": "icon-java"
		}
	},

	"labels": {
		"template": "hazelcast-template"
	},

	"objects": [{
		"apiVersion": "v1",
		"kind": "ReplicationController",
		"metadata": {
			"generateName": "hazelcast-rc-${DEPLOYMENT_NAME}-"
		},
		"spec": {
			"replicas": 1,
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
						"name": "${DEPLOYMENT_NAME}",
						"env": [{
							"name": "HZ_MEMBERS",
							"value": "${HZ_MEMBERS},${IP_NODE}:${PORT_EXPOSE}"
						}, {
							"name": "HZ_PUBLIC_ADDRESS",
							"value": "${IP_NODE}:${PORT_EXPOSE}"
						}, {
							"name": "HZ_GROUP_NAME",
							"value": "${HZ_GROUP_NAME}"
						}, {
							"name": "HZ_GROUP_PASSWORD",
							"value": "${HZ_GROUP_PASSWORD}"
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
			"name": "${DEPLOYMENT_NAME}"
		},
		"spec": {
			"type": "NodePort",
			"selector": {
				"name": "hazelcast-node-${DEPLOYMENT_NAME}"
			},
			"ports": [{
				"port": 5701,
				"protocol": "TCP",
				"nodePort": "${PORT_EXPOSE}"
			}]
		}
	}],

	"parameters": [{
		"name": "DEPLOYMENT_NAME",
		"description": "Defines the base name of this deployment unit",
		"required": true
	},{
		"name": "PORT_EXPOSE",
		"description": "Post to Expose (default: 30000-32767)",
		"value": "30210",
		"required": true
	}, {
		"name": "IP_NODE",
		"description": "Ip or DnsName to Expose",
		"value": "10.1.2.4",
		"required": true
	},{
		"name": "IMAGE_PATH",
		"description": "Image Name Full Path",
		"value": "172.30.248.237:5000/hazelcast/scb-hazelcast",
		"required": true
	},  {
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
		"name": "HZ_MEMBERS",
		"description": "Defines initial member of cluster",
		"value": "10.1.2.1:5701",
		"required": true
	}]
}
