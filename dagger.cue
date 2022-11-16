package cuetest

import (
	"dagger.io/dagger"

	"dagger.io/dagger/core"
	"encoding/json"
	"universe.dagger.io/docker"
	"universe.dagger.io/alpine"
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
				path: "build"
				contents: actions.terraformPlan.plan.export.directories["/build"]
			}
		}
		filesystem: "apply": {
			write: {
				path: "build"
				contents: actions.terraformApply.apply.export.directories["/build"]
			}
		}
		filesystem: "destroy": {
			write: {
				path: "build/"
				contents: actions.terraformDestroy.destroy.export.directories["/build"]
			}
		}
		network: "unix:///var/run/docker.sock": connect: dagger.#Socket
	}
	actions: {
		terraformPrepare: {
			write: core.#WriteFile & {
				input:    dagger.#Scratch & {}
				path:     "terraform.tf.json"
				contents: json.Indent(json.Marshal(init.tf), "", "\t")
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
				input: copy.output
				mounts: docker: {
					dest:     "/var/run/docker.sock"
					contents: client.network["unix:///var/run/docker.sock"].connect
				}
				workdir: "/build"
				export: {
					directories: {
						"/build": _
					}
				}
				command: {
					name: "terraform"
					args: ["plan", "-out=/build/tf.plan", "-state=/build/terraform.tfstate"]
				}
			}
		}
		terraformApply: {
			state: core.#Source & {
				path: "build"
				include: ["terraform.tfstate","tf.plan"]
			}
			copy: docker.#Copy & {
				input:    terraformPrepare.tfInit.output
				contents: state.output
				include: ["terraform.tfstate","tf.plan"]
				source:   "."
				dest:     "build/"
			}
			apply: docker.#Run & {
				input: copy.output
				mounts: docker: {
					dest:     "/var/run/docker.sock"
					contents: client.network["unix:///var/run/docker.sock"].connect
				}
				workdir: "/build"
				export: {
					directories: {
						"/build": _
					}
				}
				command: {
					name: "terraform"
					args: ["apply","-auto-approve","-state=build/terraform.tfstate","build/tf.plan"]
				}
			}
		}
		terraformDestroy: {
			state: core.#Source & {
				path: "build"
				include: ["terraform.tfstate","tf.plan"]
			}
			copy: docker.#Copy & {
				input:    terraformPrepare.tfInit.output
				contents: state.output
				include: ["terraform.tfstate","tf.plan"]
				source:   "."
				dest:     "build/"
			}
			destroy: docker.#Run & {
				input: copy.output
				mounts: docker: {
					dest:     "/var/run/docker.sock"
					contents: client.network["unix:///var/run/docker.sock"].connect
				}
				workdir: "/build"
				export: {
					directories: {
						"/build": _
					}
				}
				command: {
					name: "terraform"
					args: ["destroy","-auto-approve","-state=build/terraform.tfstate"]
				}
			}
		}
		createTf: {
			write: core.#WriteFile & {
				input:    client.filesystem["."].read.contents
				path:     "build/terraform.tf.json"
				contents: json.Indent(json.Marshal(init.tf), "", "\t")
			}
		}
	}
}
