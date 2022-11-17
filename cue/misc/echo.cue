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
		echoImage: docker.#Image & {
            in: {
                name: "ealen/echo-server"
            }
        }
		container: docker.#Container & {
			in: {
				name:  input.name
				image: echoImage
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
