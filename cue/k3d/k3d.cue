package k3d

import "github.com/Puddinghat/cuetest/cue/terraform"

#Provider: terraform.#Provider & {
	in: {
		name:    "k3d"
		source:  "pvotal-tech/k3d"
		version: "0.0.6"
	}
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
