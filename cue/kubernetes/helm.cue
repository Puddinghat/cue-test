package kubernetes

import (
	"encoding/yaml"
	"github.com/Puddinghat/cuetest/cue/terraform"
)

#HelmProvider: {
    terraform.#Provider
	in: {
		name:    "helm"
		source:  "hashicorp/helm"
		version: "2.7.1"
		kubeconfig?: #KubeConfigConfigPaths | #KubeConfigClientCert
		if in.kubeconfig != _|_ {
			options: kubernetes: kubeconfig
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

