package vault

import (
    "github.com/Puddinghat/cuetest/cue/terraform"
)

#SSHMount: {
    #Mount
    "in": {
        type: "ssh"
    }
}

#SSHCA: {
    terraform.#Resource
    input="in": {
        resource: "vault_ssh_secret_backend_ca"
        backend: string
        generate_signing_key: bool | *true
        public_key?: string
        private_key?: string
    }
    res: {
        backend: input.backend
        generate_signing_key: input.generate_signing_key
        if input.public_key != "_|_" {
            public_key: input.public_key
        }
        if input.private_key != "_|_" {
            private_key: input.private_key
        }
    }
    ref: {
        backend: "\(input.resource).\(input.id).backend"
    }
}

#SSHRole: {
    terraform.#Resource
    input="in": {
        name: string
        backend: string
        key_type: "otp" | "dynamic" | "ca" | *"ca"
        if key_type == "ca" {
            ssh_ca: #SSHCA
            depends_on: [ssh_ca.inst]
        }
        allowed_users?: string
        default_user?: string
        cidr_list?: string
        id: name
        resource: "vault_ssh_secret_backend_role"
    }

    res: {
        name: input.name
        backend: input.backend
        key_type: input.key_type
        if input.allowed_users != "_|_" {
            allowed_users?: input.allowed_users
        }
        if input.default_user != "_|_" {
            default_user?: input.default_user
        }
        if input.cidr_list != "_|_" {
            cidr_list?: input.cidr_list
        }
    }
}