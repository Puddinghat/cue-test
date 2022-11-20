package compounds

import (
    "github.com/Puddinghat/cuetest/cue/base"
	"github.com/Puddinghat/cuetest/cue/docker"
)

#HostKey: {
    PrivateKey: string
    PublicKey: string
}

// docker container from https://github.com/6arms1leg/git-ssh-docker
#GitServer: {
	base.#Compound
	input="in": {
        depends_on: [...]
		name:    string
		version: string | *"1.1.1"
		network: string
        mounts: {
            keys: string
            repos: string
        }
        public_keys: [...string]
        host_key: #HostKey
	}
	dep="deps": {
        gitImage: docker.#Image & {
            in: {
                depends_on: input.depends_on
                name: "git-ssh:" + (input.version)
            }
        }
		container: docker.#Container & {
			in: {
				name:  "gitserver_" + (input.name)
				image: gitImage
				networks: (input.network): _
                ports: "22": external: 2222
                mounts: {
                    docker.#BindMount & {
                        "/git/keys": source: input.mounts.keys
                    }
                    docker.#BindMount & {
                        "/git/repos": source: input.mounts.repos
                    }
                }
                env: {
						"PUID": "1000"
						"PGID": "1000"
					}
                for id, pubkey in input.public_keys {
                    uploads: "/git/keys-extra/pubkey_\(id).pub": {
                        content: pubkey
                    }
                }
                uploads: "/git/keys-host/ssh_host_ed25519_key": {
                    content: input.host_key.PrivateKey
                } 
                uploads: "/git/keys-host/ssh_host_ed25519_key.pub": {
                    content: input.host_key.PublicKey
                } 
			}
		}
	}

    ref: {
        containerName: dep.container.ref.name
    }
}
