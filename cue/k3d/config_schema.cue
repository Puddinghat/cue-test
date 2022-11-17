package k3d

#VolumeWithNodeFilters: {
	destination: string
	source?: string
	node_filters?: [...string]
}

#PortWithNodeFilters: {
	container_port: number
	host?: string
	host_port?: number
	protocol?: string
	node_filters?: [...string]
}

#EnvVarWithNodeFilters: {
	key: string
	nodeFilters?: [...string]
	value?: string
}

#K3sArgWithNodeFilters: {
	arg?: string
	node_filters?: [...string]
}

#SimpleConfigRegistryCreateConfig: {
	name?:     string
	host?:     string
	hostPort?: string
	image?:    string
}

#SimpleConfigOptionsK3dLoadbalancer: {
	configOverrides?: [...string]
}

// SimpleConfig describes the toplevel k3d configuration file.
#SimpleConfig: {
	name:     string
	agents?:  int
	image?:   string
	k3d?: {
		disable_load_balancer?: bool
		disable_image_volume?:  bool
	}
	k3s?: {
		extra_args?: [...#K3sArgWithNodeFilters]
	}
	env?: [...#EnvVarWithNodeFilters]
	kube_api?: {
		host?:      string
		host_ip?:   string
		host_port?: string
	}
	kubeconfig?: {
		switch_current_context?:    bool
		update_default_kubeconfig?: bool
	}
	label?: [
		{
			key: string
			node_filters?: [...string]
			value?: string
		},
	]
	network?: string
	port?: [...#PortWithNodeFilters]
	registries?: {
		use?: [...string]
		create?: null | #SimpleConfigRegistryCreateConfig
		config?: string
	}
	runtime: {
		gpu_request?:    string
		servers_memory?: string
		agents_memory?:  string
	}
	servers?: int
	token?:   string
	volume?: [...#VolumeWithNodeFilters]
	...
}
