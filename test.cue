package cuetest

import (
	"github.com/Puddinghat/cuetest/cue/docker"
	"github.com/Puddinghat/cuetest/cue/terraform"
	"github.com/Puddinghat/cuetest/cue/misc"
)

init: {
	tf: terraform.#Output & {
		res=#resources: {
			dockerProvider: terraform.#Provider & {
				in: {
					name:    "docker"
					source:  "kreuzwerker/docker"
					version: "2.23.0"
				}
			}
			echo: docker.#Network & {
				in: {
					name: "foo1"
				}
			}

			test: misc.#Echotest & {
				in: {
					name:         "echo"
					network_name: res.echo.ref.name
				}
			}}
	}
}
