package resources

import (
	"github.com/Puddinghat/cuetest/cue/docker"
	"github.com/Puddinghat/cuetest/cue/terraform"
	"github.com/Puddinghat/cuetest/cue/compounds"
)

//TODO: this is #pwd/.. or wherever you want to create the gitrepo
#test: string

init: {
	tf: terraform.#Output & {
		#resources: {
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

			gitServer: compounds.#GitServer & {
				in: {
					name:    "cuetest"
					network: echo.ref.name
					mounts: {
						keys: #test + "/cue-test/keys"
						keysHost: #test + "/cue-test/keys-host"
						repos: #test
					}
				}
			}
		}
	}
}
