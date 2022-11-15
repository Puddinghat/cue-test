package cuetest

import (
    "github.com/Puddinghat/cuetest/cue/docker"
	tfcue "github.com/Puddinghat/cuetest/cue/terraform"
)

// some kind of bug? This evaluates like this normally, but not when it is in the base package
#TerraformOutput: {
	input="terraform": {
		_resources: {...}
	}

	for _, res in input._resources {
		res.out.tf
	}
}

init: {
	tf: #TerraformOutput & {
		terraform: _resources: {
			dockerProvider: tfcue.#Provider & {
				in: {
					name:    "docker"
					source:  "kreuzwerker/docker"
					version: "2.23.0"
				}
			}
			echo: docker.#Network & {
				in: {
					name:         "foo1"
				}
			}
		}
	}
}
