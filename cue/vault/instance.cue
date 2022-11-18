package vault

import (
    "strconv"
    "github.com/Puddinghat/cuetest/cue/docker"
    "github.com/Puddinghat/cuetest/cue/base"
    "github.com/Puddinghat/cuetest/cue/terraform"
)

#VaultConfig: {
    scheme: "http" | "https"
    host: string
    port: number
    addr: "\(scheme)://\(host):\(strconv.FormatInt(port, 10))"
}

#Instance: {
    base.#Compound
    input="in": {
        name: string
        dev: bool | *true
        port: number | *8200
        network: string
    }

    let devToken = "testtoken"

    deps: {
        vaultImage: docker.#Image & {
            in: {
                name: "vault"
            }
        }
        vaultContainer: docker.#Container & {
            in: {
                name:      input.name
		        image:     vaultImage
                network:    input.network
                env: {
                    if input.dev {
                        "VAULT_DEV_ROOT_TOKEN_ID": devToken
                    }
                }
                ports: {
                    (strconv.FormatInt(input.port, 10)): _
                }
            }
        }
    }

    lib: {
        token: string
        if input.dev {
            token: devToken
        }
        config: #VaultConfig & {
            scheme: "http"
            host: "127.0.0.1"
            port: input.port
        }
    }
}

#Provider: {
    terraform.#Provider
    in: {
        name:    "vault"
		source:  "hashicorp/vault"
		version: string | *"3.11.0"
		options: {
            address?: string
            token?: string
        }
    }
}

#ProviderFromConfig: #Provider & {
    in: {
        config: #VaultConfig
        options: {
            address: config.addr
        }
    }
}

