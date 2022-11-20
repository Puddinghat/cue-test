package secrets

import (
	"github.com/Puddinghat/cuetest/cue/terraform"
)

#Provider: {
    terraform.#Provider
    in: {
        name:    "tls"
		source:  "hashicorp/tls"
		version: "4.0.4"
    }
}

#PrivateKey: {
    terraform.#Resource
    input="in": {
        id: string
        resource: "tls_private_key"
        algorithm: "RSA" | "ECDSA" | "ED25519" | *"ED25519"
        refs: {
            secret_key_ssh: path: "private_key_openssh"
            public_key_ssh: path: "public_key_openssh"
        }
    }

    res: {
        algorithm: input.algorithm
    }
}