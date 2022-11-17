package resources

import (
	"github.com/Puddinghat/cuetest/cue/docker"
	"github.com/Puddinghat/cuetest/cue/terraform"
	"github.com/Puddinghat/cuetest/cue/compounds"
	"github.com/Puddinghat/cuetest/cue/k3d"
)

#Root: {
	#parameters: {
		rootdir: string
	}

	providers: terraform.#CueOutput & {
		#resources: {
			dockerProvider: docker.#Provider
			k3dProv: k3d.#Provider
		}
	}
	tf: terraform.#CueOutput & {
		#resources: {
			providers.#resources
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
						keys: #parameters.rootdir + "/cue-test/keys"
						keysHost: #parameters.rootdir + "/cue-test/keys-host"
						repos: #parameters.rootdir
					}
				}
			}

			cluster: k3d.#Cluster & {
				in: {
					name:    "test-cluster"
					config: {
						network: echo.ref.name
					}
				}
			}

			clusterCredentials: cluster.lib.kubeConfig
		}
	}
}