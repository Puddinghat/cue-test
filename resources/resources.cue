package resources

import (
	"github.com/Puddinghat/cuetest/cue/docker"
	"github.com/Puddinghat/cuetest/cue/terraform"
	"github.com/Puddinghat/cuetest/cue/compounds"
	"github.com/Puddinghat/cuetest/cue/kubernetes"
	"github.com/Puddinghat/cuetest/cue/vault"
	"github.com/Puddinghat/cuetest/cue/secrets"
)

test: #Root & {#parameters: rootdir: "test"}

#Root: {
	#parameters: {
		rootdir: string
	}

	providers: terraform.#CueOutput & {
		#resources: {
			dockerProvider: docker.#Provider
			k3dProv: kubernetes.#k3dProvider
			vaultProv: vault.#Provider
			tlsProv: secrets.#Provider
			helmProv: kubernetes.#HelmProvider
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

			cluster: kubernetes.#Cluster & {
				in: {
					name:    "test-cluster"
					config: {
						network: echo.ref.name
					}
				}
			}

			clusterCredentials: cluster.lib.kubeConfig
			vaultInst: vault.#Instance & {
				in: {
					name: "dev-vault"
					network: echo.ref.name
				}
			}
			vaultProv: vault.#ProviderFromConfig & {
				in: {
					config: vaultInst.lib.config
				}
			}
			sshKey: secrets.#PrivateKey & {
				in: {
					id: "gitkey"
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
					public_keys: [sshKey.ref.public_key_ssh]
				}
			}
		}
	}
}