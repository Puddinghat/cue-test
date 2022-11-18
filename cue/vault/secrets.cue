package vault

import (
    "strings"
    "github.com/Puddinghat/cuetest/cue/terraform"
)

#Mount: {
    terraform.#Resource
    input="in": {
        resource: "vault_mount"
        path: string
        id: strings.Replace(path, "/", "_", -1)
        type: string
    }

    res: {
        path: input.path
        type: input.type
    }

    ref: {
        path: "\(input.resource).\(input.id).path"
    }
}