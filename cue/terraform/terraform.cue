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

	_ref: {...}
    _res: {...}

	out: {
		tf: resource: (input.resource): (input.id): {
			input.tf
			_inst: "\(input.resource).\(input.id)"
            _res
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

    _res: {...}

	out: {
		tf: data: (input.data): (input.id): {
            _res
			input.tf
			_inst: "data.\(input.data).\(input.id)"
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
	input="terraform": {
		_resources: {...}
	}

	for _, res in input._resources {
		res.out.tf
	}
}
