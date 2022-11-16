package docker

import (
    "github.com/Puddinghat/cuetest/cue/terraform"
)

#ContainerNetwork: {
	name: string
	aliases?: [string, ...]
	ipv4_address?: string
}

#Mounts: {
    source: string
    read_only: bool | *false
}

#Ports: {
    required: number
    external: number | *required
    protocol: "tcp" | "udp" | *"tcp"
}

#Upload: {
    {content?: string} | {content_base64?: string} | {source?: string}
    file: string
    content?: string
    content_base64?: string
    source?: string
    executable: bool | *false
    source_hash?: string
}

#Container: {
	terraform.#Resource
	in: {
		name:     string
		image:    string
		id:       name
        hostname?: string
		resource: "docker_container"
		networks?: [...#ContainerNetwork]
        mounts?: [...#Mounts]
        ports?: [...#Ports]
        upload?: [...#Upload]
	}

	ref: {
		name: "${docker_container.\(in.name).name}"
	}

    res: {
        name:              in.name
        image:             in.image
        if in.networks != _|_ {
            networks_advanced: in.networks
        }
        if in.hostname != _|_ {
            hostname: in.hostname
        }
        if in.mounts != _|_ {
            mounts: in.mounts
        }
        if in.ports != _|_ {
            ports: in.ports
        }
        if in.upload != _|_ {
            upload: in.upload
        }
    }
}

#Network: {
	terraform.#Resource
	in: {
		name:     string
		id:       name
		resource: "docker_network"
		driver:   "bridge" | "host" | "overlay" | "macvlan" | *"bridge"
	}

    res: {
        name:   in.name
        driver: in.driver
    }

	ref: {
		name: "${docker_network.\(in.name).name}"
	}
}

#Volume: {
	terraform.#Resource
	in: {
		name:     string
		id:       name
		resource: "docker_volume"
	}

    res: {
        name:   in.name
    }

	ref: {
		id: "${docker_volume.\(in.name).id}"
        name: "${docker_volume.\(in.name).name}"
	}
}
