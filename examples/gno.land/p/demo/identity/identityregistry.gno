package identity

import (
	"std"
	"gno.land/p/demo/avl"
)

type IdentityRegistry struct {	
	admin std.Address
    identities avl.Tree
}

func NewIdentityRegistry(admin_ std.Address) *IdentityRegistry {
	return &IdentityRegistry{
		admin: admin_, 
		identities: avl.Tree{},
	}
	// _identityRegistry := initRegistry(admin_)
	// _identityRegistry.Identify(admin_)
	// return _identityRegistry
}

func initRegistry(admin_ std.Address) *IdentityRegistry {
	
}

// Identifies an address as an `Identity`
func (ir *IdentityRegistry) Identify(address_ std.Address) bool {
	if ir.identities.Has(string(address_)) {
		return false
	}
	ir.identities.Set(string(address_),true)
	return true 
}

// Returns identity status of address
func (ir *IdentityRegistry) Identified(address_ std.Address) bool {
	identity, err := ir.identities.Get(string(address_))
	if err != nil {
		return false
	}
	return true
}