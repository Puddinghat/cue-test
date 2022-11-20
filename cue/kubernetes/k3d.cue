package kubernetes

import (
	"github.com/Puddinghat/cuetest/cue/terraform"
)

#k3dProvider: terraform.#Provider & {
	in: {
		name:    "k3d"
		source:  "pvotal-tech/k3d"
		version: "0.0.6"
	}
}

#KubeConfigClientCert: {
	host: string
    client_certificate: string
    client_key: string
    cluster_ca_certificate: string
}

#KubeConfigConfigPaths: {
	config_paths: [...string]
}

#K3dCluster: {
	terraform.#Resource
	input="in": {
		config: #SimpleConfig & {
			name: input.name
		}
		name:     string
		resource: "k3d_cluster"
		id:       name
		refs: {
			client_certificate: path: "credentials[0].client_certificate"
			client_key: path: "credentials[0].client_key"
			cluster_ca_certificate: path: "credentials[0].cluster_ca_certificate"
			host: path: "credentials[0].host"
			raw: path: "credentials[0].raw"
			id: path: "id"
		}
	}

	inst: "\(input.resource).\(input.id)"
	res: {
		input.config
	}

	ref: {...}

	lib: {
		refCredentials: #KubeConfigClientCert & {
			host: ref.host
			client_certificate: ref.client_certificate
			client_key: ref.client_key
			cluster_ca_certificate: ref.cluster_ca_certificate
		}
		kubeConfig: terraform.#Output & {
			"in": {
				id:    "kubeconfig_\(input.name)"
				value: ref.raw
				sensitive: true
			}
		}
	}
}
