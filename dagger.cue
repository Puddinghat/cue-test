package cuetest

import (
	"dagger.io/dagger"

	"dagger.io/dagger/core"
	"encoding/json"
	"universe.dagger.io/docker"
	"universe.dagger.io/alpine"
	"github.com/Puddinghat/cuetest/resources"
)

dagger.#Plan & {
	client: {
		filesystem: ".": {
			read: contents: dagger.#FS
			write: {
				contents: actions.createTf.write.output
			}
		}
		filesystem: "plan": {
			write: {
				path:     "build/tf.plan"
				contents: actions.terraformPlan.plan.export.files["tf.plan"]
			}
		}
		filesystem: "apply": {
			write: {
				path:     "build/terraform.tfstate"
				contents: actions.terraformApply.apply.export.files["terraform.tfstate"]
			}
		}
		filesystem: "destroy": {
			write: {
				path:     "build/terraform.tfstate"
				contents: actions.terraformDestroy.destroy.export.files["terraform.tfstate"]
			}
		}
		network: "unix:///var/run/docker.sock": connect: dagger.#Socket
	}
	actions: {
		terraformPrepare: {
			write: core.#WriteFile & {
				input:    dagger.#Scratch & {}
				path:     "terraform.tf.json"
				contents: json.Indent(json.Marshal(resources.init.tf), "", "\t")
			}

			image: alpine.#Build & {
				packages: {
					"docker-cli": {}
					"terraform": {}
				}
			}

			_set: docker.#Set & {
				input: image.output
				config: {
					workdir: "/build"
				}
			}

			copy: docker.#Copy & {
				input:    _set.output
				contents: write.output
				source:   "terraform.tf.json"
				dest:     "terraform.tf.json"
			}

			tfInit: docker.#Run & {
				input:   copy.output
				workdir: "/build"
				command: {
					name: "terraform"
					args: ["init"]
				}
			}
		}
		terraformPlan: {
			state: core.#Source & {
				path: "build"
				include: ["terraform.tfstate"]
			}

			copy: docker.#Copy & {
				input:    terraformPrepare.tfInit.output
				contents: state.output
				source:   "terraform.tfstate"
				dest:     "terraform.tfstate"
			}

			plan: docker.#Run & {
				input:  copy.output
				always: true
				mounts: docker: {
					dest:     "/var/run/docker.sock"
					contents: client.network["unix:///var/run/docker.sock"].connect
				}
				workdir: "/build"
				export: {
					files: {
						"tf.plan": _
					}
				}
				command: {
					name: "terraform"
					args: ["plan", "-out=tf.plan", "-state=terraform.tfstate"]
				}
			}
		}
		terraformApply: {
			state: core.#Source & {
				path: "build"
				include: ["terraform.tfstate", "tf.plan"]
			}
			copy: docker.#Copy & {
				input:    terraformPrepare.tfInit.output
				contents: state.output
				include: ["terraform.tfstate", "tf.plan"]
				source: "."
				dest:   "."
			}
			apply: docker.#Run & {
				input: terraformPlan.plan.output
				mounts: docker: {
					dest:     "/var/run/docker.sock"
					contents: client.network["unix:///var/run/docker.sock"].connect
				}
				always:  true
				workdir: "/build"
				export: {
					files: {
						"terraform.tfstate": _
					}
				}
				command: {
					name: "terraform"
					args: ["apply", "-auto-approve", "-state=terraform.tfstate", "tf.plan"]
				}
			}
		}
		terraformDestroy: {
			state: core.#Source & {
				path: "build"
				include: ["terraform.tfstate", "tf.plan"]
			}
			copy: docker.#Copy & {
				input:    terraformPrepare.tfInit.output
				contents: state.output
				include: ["terraform.tfstate", "tf.plan"]
				source: "."
				dest:   "."
			}
			destroy: docker.#Run & {
				input: copy.output
				mounts: docker: {
					dest:     "/var/run/docker.sock"
					contents: client.network["unix:///var/run/docker.sock"].connect
				}
				workdir: "/build"
				export: {
					files: {
						"terraform.tfstate": _
					}
				}
				always: true
				command: {
					name: "terraform"
					args: ["destroy", "-auto-approve", "-state=terraform.tfstate"]
				}
			}
		}
		createTf: {
			write: core.#WriteFile & {
				input:    client.filesystem["."].read.contents
				path:     "build/terraform.tf.json"
				contents: json.Indent(json.Marshal(resources.init.tf), "", "\t")
			}
		}
	}
}
