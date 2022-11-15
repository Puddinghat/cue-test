package teleport

#TeleportContainer: {
	#Compound
	input="in": {
		name:    string
		version: string | *"11.0.1"
		network: string
	}
	dep="_deps": {
		container: #DockerContainer & {
			in: {
				name:  "teleport_" + (input.name)
				image: "public.ecr.aws/gravitational/teleport:" + (input.version)
                hostname: "localhost"
				networks: [
					{
						name: input.network
					},
				]
			}
		}
	}

    _ref: {
        container: dep._ref
    }
}
