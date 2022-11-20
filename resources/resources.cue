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
		branch: "test"
	}
}

#Root: {
	#parameters: {
		rootdir: string
		branch: string
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
			sshHostKey: secrets.#PrivateKey & {
				in: {
					id: "hostkey"
				}
			}
			gitServer: compounds.#GitServer & {
				in: {
					name:    "cuetest"
					network: echo.ref.name
					mounts: {
						keys:     #parameters.rootdir + "/cue-test/keys"
						repos:    #parameters.rootdir
					}
					public_keys: [sshKey.ref.public_key_ssh]
					host_key: {
						compounds.#HostKey & {
							PrivateKey: sshHostKey.ref.secret_key_ssh
    						PublicKey: sshHostKey.ref.public_key_ssh
						}
					}
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

			let gitUrl =  argocd.#GitUrl & {
				in: {
					host: gitServer.ref.containerName
					path: "/git/repos/cue-test"
				}
			}

			argoRepoCreds: argocd.#SSHGitRepoCredentials & {
				in: {
					name:      "local-git-creds"
					namespace: "argocd"
					url:       gitUrl
					privateKey: sshKey.ref.secret_key_ssh
				}
			}

			argoKnownHosts: argocd.#SSHRepoKnownHosts & {
				in: {
        			namespace: "argocd"
        			known_hosts: [
						argocd.#KnownHosts & {
							url: gitServer.ref.containerName
							publickey: sshHostKey.ref.public_key_ssh
					}]
				}
			}

			testApp: argocd.#GitApplication & {
				in: {
					name:      "test"
					namespace: "argocd"
					project:  argoProject
					repoURL:        gitUrl	
					branch: #parameters.branch
					path: 			"argocd"
					destination: {
						namespace: "test"
					}
				}
			}
		}
	}
}
