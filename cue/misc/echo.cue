package misc

import (
    "github.com/Puddinghat/cuetest/cue/base"
	"github.com/Puddinghat/cuetest/cue/docker"
)

#Echotest: {
	base.#Compound

	input="in": {
		name:         string
		network_name: string
		ref:          bool | *true
	}

	_deps: {
		container: docker.#DockerContainer & {
			in: {
				name:  input.name
				image: "ealen/echo-server"
				networks: [
					if input.ref {
						name: "${docker_network.\(input.network_name).name}"
					},
					if !input.ref {
						name: input.network_name
					},
				]
			}
		}
	}
}

#EchoNetwork: {
	base.#Compound

	input="in": {
		name:         string
		network_name: string
	}

	_deps: {
		echoContainer: #Echotest & {
			in: {
				name:         "echo1_" + (input.name)
				network_name: input.network_name
			}
		}
		echoNetwork: docker.#DockerNetwork & {
			in: {
				name: input.network_name
			}
		}
	}
}
