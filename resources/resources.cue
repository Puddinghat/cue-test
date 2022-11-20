package resources

import (
	"github.com/Puddinghat/cuetest/cue/docker"
	"github.com/Puddinghat/cuetest/cue/terraform"
	"github.com/Puddinghat/cuetest/cue/compounds"
	"github.com/Puddinghat/cuetest/cue/kubernetes"
	"github.com/Puddinghat/cuetest/cue/vault"
	"github.com/Puddinghat/cuetest/cue/secrets"
	"github.com/Puddinghat/cuetest/cue/argocd"
)

test: #Root & {
	#parameters: {
		rootdir: "test"
	}
}

#Root: {
	#parameters: {
		rootdir: string
	}

	providers: terraform.#CueOutput & {
		#resources: {
			dockerProvider: docker.#Provider
			k3dProv:        kubernetes.#k3dProvider
			vaultProv:      vault.#Provider
			tlsProv:        secrets.#Provider
			helmProv:       kubernetes.#HelmProvider
			kubeProv:       kubernetes.#KubernetesProvider
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

			cluster: kubernetes.#K3dCluster & {
				in: {
					name: "test-cluster"
					config: {
						network: echo.ref.name
					}
				}
			}

			clusterCredentials: cluster.lib.kubeConfig
			vaultInst:          vault.#Instance & {
				in: {
					name:    "dev-vault"
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
						keys:     #parameters.rootdir + "/cue-test/keys"
						keysHost: #parameters.rootdir + "/cue-test/keys-host"
						repos:    #parameters.rootdir
					}
					public_keys: [sshKey.ref.public_key_ssh]
				}
			}
			helmProv: kubernetes.#HelmProvider & {
				in: {
					kubeconfig: cluster.lib.refCredentials
				}
			}
			argoInstance: argocd.#Instance & {
				in: {
					name: "argo"
				}
			}

			kubeProv: kubernetes.#KubernetesProvider & {
				in: {
					kubeconfig: cluster.lib.refCredentials
				}
			}

			argoProject: argocd.#Project & {
				in: {
					name:      "dev"
					namespace: "argocd"
				}
			}

			argoRepoCreds: argocd.#SSHGitRepoCredentials & {
				in: {
					name:      "local-git-creds"
					namespace: "argocd"
					url:       argocd.#GitUrl & {
						in: {
							host: gitServer.ref.containerName
							path: "cue-test"
						}
					}
					privateKey: sshKey.ref.secret_key_ssh
				}
			}

			
		}
	}
}
