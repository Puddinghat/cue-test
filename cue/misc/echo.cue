package misc

import (
	"github.com/Puddinghat/cuetest/cue/docker"
	"github.com/Puddinghat/cuetest/cue/base"
)

#Echotest: {
	base.#Compound

	input="in": {
		name:         string
		network_name: string
		ref:          bool | *true
	}

	ref: {
		if input.ref {
			name: "${docker_network.\(input.network_name).name}"
		}
		if !input.ref {
			name: input.network_name
		}
	}

	deps: {
		container: docker.#Container & {
			in: {
				name:  input.name
				image: "ealen/echo-server"
				networks: {
					if input.ref {
						"${docker_network.\(input.network_name).name}": _
					},
					if !input.ref {
						(input.network_name): _
					},
				}
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

	deps: {
		echoContainer: #Echotest & {
			in: {
				name:         "echo1_" + (input.name)
				network_name: input.network_name
			}
		}
		echoNetwork: docker.#Network & {
			in: {
				name: input.network_name
			}
		}
	}
}
