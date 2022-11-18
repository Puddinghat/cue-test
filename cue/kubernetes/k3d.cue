package kubernetes

import (
	"encoding/yaml"
	"github.com/Puddinghat/cuetest/cue/terraform"
)

#k3dProvider: terraform.#Provider & {
	in: {
		name:    "k3d"
		source:  "pvotal-tech/k3d"
		version: "0.0.6"
	}
}

#HelmProvider: terraform.#Provider & {
	in: {
		name:    "helm"
		source:  "hashicorp/helm"
		version: "2.7.1"
		#kubeConfig?: #KubeConfigConfigPaths | #KubeConfigClientCert
		if #kubeConfig != _|_ {
			options: kubernetes: #kubeConfig
		}
	}
}

#HelmTerraform: {
	terraform.#Resource
	input="in": {
		name: string
		chart: string
		repository: string
		version: string
		namespace: string
		wait: bool | *false
		values: {}
		create_namespace: bool | *true
		resource: "helm_release"
		id:       name
	}

	res: {
		name: input.name
		chart: input.chart
		repository: input.repository
		version: input.version
		namespace: input.namespace
		wait: input.wait
		values: [yaml.Marshal(input.values)]
		create_namespace: input.create_namespace
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

#Cluster: {
	terraform.#Resource
	input="in": {
		config: #SimpleConfig & {
			name: input.name
		}
		name:     string
		resource: "k3d_cluster"
		id:       name
	}

	inst: "\(input.resource).\(input.id)"
	res: {
		input.config
	}

	ref: {
		id: "${\(inst).id}"
		credentials: {
			client_certificate:     "${\(inst).credentials[0].client_certificate}"
			client_key:             "${\(inst).credentials[0].client_key}"
			cluster_ca_certificate: "${\(inst).credentials[0].cluster_ca_certificate}"
			host:                   "${\(inst).credentials[0].host}"
			raw:                    "${\(inst).credentials[0].raw}"
		}
	}

	lib: {
		kubeConfig: terraform.#Output & {
			"in": {
				id:    "kubeconfig_\(input.name)"
				value: ref.credentials.raw
				sensitive: true
			}
		}
	}
}
