package terraform

import "github.com/Puddinghat/cuetest/cue/base"

#TFDefinition: {
	depends_on?: [...string]
}

#Schema: {
	base.#Base
	inst: string
	out: {
		tf: {
			...
		}
	}
}

#Ref: {
	[Name=_]: {
		path: string
	}
}

#Resource: {
	#Schema
	input="in": {
		tf:       #TFDefinition
		resource: string
		id:       string
		refs: #Ref
	}

	ref: {
		for name, reference in input.refs {
			(name): "${\(input.resource).\(input.id).\(reference.path)}"
		}
	}

    res: {...}
	inst: "\(input.resource).\(input.id)"

	out: {
		tf: resource: (input.resource): (input.id): {
			input.tf
            res
			...
		}
	}
}

#Data: {
	#Schema
	input="in": {
		tf:   #TFDefinition
		data: string
		id:   string
		refs: #Ref
	}

	ref: {
		for name, reference in input.refs {
			(name): "${data.\(input.resource).\(input.id).\(reference.path)}"
		}
	}

    res: {...}
	inst: "data.\(input.data).\(input.id)"

	out: {
		tf: data: (input.data): (input.id): {
            res
			input.tf
			...
		}
	}
}

#Provider: {
	#Schema
	input="in": {
		name:    string
		source:  string
		version: string
		options: {...} | *{}
	}

	inst: input.name

	out: {
		tf: {
			terraform: required_providers: (input.name): {
				source:  input.source
				version: input.version
			}

			provider: (input.name): {
				input.options
			}
		}
	}
}

#Output: {
	#Schema
	input="in": {
		tf:   #TFDefinition
		value: string
		id:   string
		sensitive: bool | *false
	}

	inst: "output.\(input.id)"

	out: {
		tf: output: (input.id): {
            value: input.value
			sensitive: input.sensitive
			input.tf
			...
		}
	}
}

#CueOutput: {
	#resources: {
		[_]: {
			base.#Base
			...
			}
	}

	for _, res in #resources {
		res.out.tf
	}
}
