package cuetest

import (
    "github.com/Puddinghat/cue-test/base"
    "github.com/Puddinghat/cue-test/docker"
)

init: {
	tf: #TerraformOutput & {
		terraform: _resources: {
			docker: #TerraformProvider & {
				in: {
					name:    "docker"
					source:  "kreuzwerker/docker"
					version: "2.23.0"
				}
			}
			echo: #DockerNetwork & {
				in: {
					name:         "foo1"
				}
			}
		}
	}
}
