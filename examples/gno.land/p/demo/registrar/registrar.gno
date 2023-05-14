package registrar

import (
	"std"
	"strings"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
)

type Registrar struct{
	domainMappings avl.Tree
}



func Init() *Registrar {
	return &Registrar{
		domainMappings: avl.Tree{},
	}
}

func (r *Registrar) Register(domain string, dest string) bool{
	if r.domainMappings.Has(domain) {
		return false
	}
	r.domainMappings.Set(domain,dest)
	return true
}

func (r *Registrar) Resolve(domain string) string{
	dest, found := r.domainMappings.Get(domain)
	if !found {
		return "DOMAIN UNREGISTERED"
	}
	return dest.(string)
}

func (r *Registrar) RenderHome() string {
	str := ""
	str += ufmt.Sprintf("* **Known registrations**: %d\n", r.domainMappings.Size())
	return str
}