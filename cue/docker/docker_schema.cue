package docker

import (
	"strconv"
	
	"github.com/Puddinghat/cuetest/cue/base"
	"github.com/Puddinghat/cuetest/cue/terraform"
)

#Provider: terraform.#Provider & {
	in: {
		name:    "docker"
		source:  "kreuzwerker/docker"
		version: "2.23.0"
	}
}

#ContainerNetwork: [Name=_]: {
	name: string | *Name
	aliases?: [string, ...]
	ipv4_address?: string
}

#Mounts: [Target=_]: {
	source?:   string
	target:    string | *Target
	type:      "bind" | "volume" | "tmpfs"
	read_only: bool | *false
}

#TmpfsMount: {
	#Mounts
	[Target=_]: {
		target:    string | *Target
		type:      "tmpfs"
		read_only: false
	}
}

#BindMount: {
	#Mounts
	[Target=_]: {
		target: string | *Target
		source: string
		type:   "bind"
	}
}

#VolumeMount: {
	#Mounts
	[Target=_]: {
		target: string | *Target
		source: string
		type:   "volume"
	}
}

#Ports: [Port=_]: {
	#port:    string | *Port
	internal: strconv.ParseInt(#port, 10, 16)
	external: number | *internal
	protocol: "tcp" | "udp" | *"tcp"
}

#Upload: [File=_]: {
	{content?: string} | {content_base64?: string} | {source?: string}
	file:            string | *File
	content?:        string
	content_base64?: string
	source?:         string
	executable:      bool | *false
	source_hash?:    string
}

#Container: {
	terraform.#Resource
	input="in": {
		name:      string
		image:     string
		id:        name
		hostname?: string
		resource:  "docker_container"
		networks:  #ContainerNetwork
		mounts:    #Mounts
		ports:     #Ports
		uploads:   #Upload
		env:       base.#EnvVariables
	}

	ref: {
		name: "${docker_container.\(input.name).name}"
	}

	res: {
		name:              input.name
		image:             input.image
		networks_advanced: (base.#StructToArray & {in: {struct: input.networks}}).out
		mounts:            (base.#StructToArray & {in: {struct: input.mounts}}).out
		ports:             (base.#StructToArray & {in: {struct: input.ports}}).out
		upload:            (base.#StructToArray & {in: {struct: input.uploads}}).out
		env:               (base.#StructToEnv & {in:            input.env}).out
		if input.hostname != _|_ {
			hostname: input.hostname
		}
	}
}

#Network: {
	terraform.#Resource
	input="in": {
		name:     string
		id:       name
		resource: "docker_network"
		driver:   "bridge" | "host" | "overlay" | "macvlan" | *"bridge"
	}

	res: {
		name:   input.name
		driver: input.driver
	}

	ref: {
		name: "${docker_network.\(input.name).name}"
	}
}

#Volume: {
	terraform.#Resource
	input="in": {
		name:     string
		id:       name
		resource: "docker_volume"
	}

	res: {
		name: input.name
	}

	ref: {
		#MountTarget: {
			#target:   string
			(#target): #VolumeMount & {
				source: "${docker_volume.\(input.name).name}"
			}
		}

		id:   "${docker_volume.\(input.name).id}"
		name: "${docker_volume.\(input.name).name}"
	}
}
