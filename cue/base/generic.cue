package base

#Compound: {
	in: {...}
	deps: {...}
	for _, resources in deps {
		out: resources.out
	}
}

#StructToArray: {
	in: {
		struct: {...}
	}
	out: [for _, res in in.struct {res}]
}

#EnvVariables: {
	[Name=_]: string
}

#StructToEnv: {
	in: #EnvVariables
	out: [for name, val in in {(name)+"="+(val)}]
}