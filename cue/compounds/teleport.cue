package compounds

import (
    "github.com/Puddinghat/cuetest/cue/base"
	"github.com/Puddinghat/cuetest/cue/docker"
)

#TeleportContainer: {
	base.#Compound
	input="in": {
		name:    string
		version: string | *"11.0.1"
		network: string
	}
	dep="_deps": {
		teleportImage: docker.#Image & {
            in: {
                name: "public.ecr.aws/gravitational/teleport:" + (input.version)
            }
        }
		container: docker.#Container & {
			in: {
				name:  "teleport_" + (input.name)
				image: teleportImage
                hostname: "localhost"
				networks: (input.network): _
			}
		}
	}

    ref: {
        container: dep.container.ref
    }
}
