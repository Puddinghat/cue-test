package terraform

#TFDefinition: {
	depends_on?: [...string]
}

#Resource: {
	input="in": {
		tf:       #TFDefinition
		resource: string
		id:       string
	}

	ref: {...}
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
	input="in": {
		tf:   #TFDefinition
		data: string
		id:   string
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
	input="in": {
		name:    string
		source:  string
		version: string
		options: {...} | *{}
	}

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
	#resources: {
		...
	}

	for _, res in #resources {
		res.out.tf
	}
}
