package argocd

import (
	"encoding/yaml"
	"github.com/Puddinghat/cuetest/cue/kubernetes"
)

#Instance: {
	kubernetes.#HelmTerraform
	"in": {
		name:       string
		namespace:  string | *"argocd"
		chart:      "argo-cd"
		repository: "https://argoproj.github.io/argo-helm"
		version:    string | *"5.13.9"
		wait:       true
		values: {
			dex: enabled:            false
			applicationSet: enabled: false
			notifications: enabled:  false
		}
		resource: "helm_release"
	}
}

#ProjectRole: {
	name:         string
	description?: string
	policies: [...string]
	groups: [...string]
}

#SyncOptions: {
	input="in": {
		Validate:               bool | *false
		CreateNamespace:        bool | *true
		PrunePropagationPolicy: *"foreground" | "background" | "orphan"
		PruneLast:              bool | *true
	}
	out: [ for key, value in input {"\(key)=\(value)"}]
}

#Retry: {
	limit: int | *5
	backoff: {
		duration: *"5s" | string
		factor:      *2 | int
		maxDuration: *"3m" | string
	}
}

#SyncPolicy: {
	automated: {
		prune:      bool | *true
		selfHeal:   bool | *true
		allowEmpty: bool | *false
	}
	#syncOpts:   #SyncOptions
	syncOptions: (#syncOpts).out
	retry:       #Retry
}

#HelmApplication: {
	#Application
	input="in": {
		name:      string
		namespace: string
		project:   #Project
		metadata: {
			labels: {...}
			annotations: {...}
			finalizers: ["resources-finalizer.argocd.argoproj.io"]
		}
		spec: {
			project: input.project.ref.name
			source: {
				repoURL:        string
				targetRevision: string
				chart:          string
				helm: {
					#values: {...}
					values: yaml.Marshal(#values)
				}
			}
			destination: {
				server:    string | *"https://kubernetes.default.svc"
				namespace: string | *input.namespace
			}
			syncPolicy: #SyncPolicy
		}
	}
}

#GitApplication: {
	#Application
	input="in": {
		name:      string
		namespace: string
		project:   #Project
		metadata: {
			labels: {...}
			annotations: {...}
			finalizers: ["resources-finalizer.argocd.argoproj.io"]
		}
		repoURL:        #GitUrl
		branch: string
		path: 			string
	}

	res: {
		manifest: {
				spec: {
					source: {
						repoURL:        input.repoURL.out
						targetRevision: input.branch
						path: 			input.path
					}
			}
		}
	}
}

#Application: {
	kubernetes.#Manifest
	input="in": {
		name:      string
		namespace: string
		project:   #Project
		metadata: {
			labels: {...}
			annotations: {...}
			finalizers: ["resources-finalizer.argocd.argoproj.io"]
		}
		source: {
			...
		}
		destination: {
			server:    string | *"https://kubernetes.default.svc"
			namespace: string | *input.namespace
		}
		syncPolicy: #SyncPolicy
		kind:       "Application"
		apiVersion: "argoproj.io/v1alpha1"
	}

	res: {
		manifest: {
				spec: {
					project: input.project.ref.name
					source: input.source
					destination: input.destination
					syncPolicy: #SyncPolicy
			}
		}
	}
}

#ProjectDestination: {
	namespace: string
	server:    string
}

#Project: {
	kubernetes.#Manifest
	"in": {
		name:      string
		namespace: string
		metadata: {
			labels: {...}
			annotations: {...}
			finalizers: ["resources-finalizer.argocd.argoproj.io"]
		}
		kind:       "AppProject"
		apiVersion: "argoproj.io/v1alpha1"
		spec: {
			description?: string
			sourceRepos:  [...string] | *["*"]
			destinations: [...#ProjectDestination] | *[{
				namespace: "*"
				server:    "*"
			}]
			roles: [...#ProjectRole]
		}
	}
}

#GitUrl: {
    in: {
        // git@github.com:argoproj/my-private-repository
        user: *"git" | string
        host: string
        path: string
    }

    out: "\(in.user)@\(in.host):\(in.path)"
}

#SSHGitRepoCredentials: {
	kubernetes.#Secret
	input="in": {
		name:       string
		namespace:  string
		url:        #GitUrl
		privateKey: string
		metadata: {
            labels: {...}
            annotations: {...}
        }
	}

	res: {
		metadata: {
			name:      input.name
			namespace: input.namespace
			labels: {
				input.metadata.labels
				"argocd.argoproj.io/secret-type": "repository"
			}
		}
		data: {
			type:          "git"
			url:           input.url.out
			sshPrivateKey: input.privateKey
		}
	}
}
