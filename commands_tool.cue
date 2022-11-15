package cuetest

import (
	"tool/file"
	"encoding/json"
)

command: tfbuild: {

	tffile: {
		file: *"terraform.tf.json" | string @tag(file)
	}

	jsonfile: file.Create & {
		filename: tffile.file
		contents: json.Indent(json.Marshal(init.tf), "", "\t")
	}
}
