package base

#TFDefinition: {
	depends_on?: [...string]
}

#TerraformResource: {
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

#TerraformData: {
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

#TerraformProvider: {
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

#TerraformOutput: {
	input="terraform": {
		_resources: {...}
	}

	for _, res in input._resources {
		res.out.tf
	}
}
