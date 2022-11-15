package cuetest

import (
    "github.com/Puddinghat/cuetest/cue/base"
    "github.com/Puddinghat/cuetest/cue/docker"
)


// some kind of bug?
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
			dockerProvider: base.#TerraformProvider & {
				in: {
					name:    "docker"
					source:  "kreuzwerker/docker"
					version: "2.23.0"
				}
			}
			echo: docker.#DockerNetwork & {
				in: {
					name:         "foo1"
				}
			}
		}
	}
}
