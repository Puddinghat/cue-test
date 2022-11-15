package docker

import (
    "github.com/Puddinghat/cuetest/cue/base"
)

#DockerContainerNetwork: {
	name: string
	aliases?: [string, ...]
	ipv4_address?: string
}

#DockerMounts: {
    source: string
    read_only: bool | *false
}

#DockerPorts: {
    required: number
    external: number | *required
    protocol: "tcp" | "udp" | *"tcp"
}

#DockerUpload: {
    {content?: string} | {content_base64?: string} | {source?: string}
    file: string
    content?: string
    content_base64?: string
    source?: string
    executable: bool | *false
    source_hash?: string
}

#DockerContainer: {
	base.#TerraformResource
	in: {
		name:     string
		image:    string
		id:       name
        hostname?: string
		resource: "docker_container"
		networks?: [...#DockerContainerNetwork]
        mounts?: [...#DockerMounts]
        ports?: [...#DockerPorts]
        upload?: [...#DockerUpload]
	}

	_ref: {
		name: "${docker_container.\(in.name).name}"
	}

    _res: {
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

#DockerNetwork: {
	base.#TerraformResource
	in: {
		name:     string
		id:       name
		resource: "docker_network"
		driver:   "bridge" | "host" | "overlay" | "macvlan" | *"bridge"
	}

    _res: {
        name:   in.name
        driver: in.driver
    }

	_ref: {
		name: "${docker_network.\(in.name).name}"
	}
}

#DockerVolume: {
	base.#TerraformResource
	in: {
		name:     string
		id:       name
		resource: "docker_volume"
	}

    _res: {
        name:   in.name
    }

	_ref: {
		id: "${docker_volume.\(in.name).id}"
        name: "${docker_volume.\(in.name).name}"
	}
}
