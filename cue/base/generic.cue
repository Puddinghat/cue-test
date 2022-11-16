package base

#Compound: {
	in: {...}
	deps: {...}
	for _, resources in deps {
		out: resources.out
	}
}
