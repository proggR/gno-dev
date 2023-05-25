package dao

import (
	"std"
	"gno.land/p/demo/identity"		
)

type IDAORegistry interface {	
	// Registers a DAO to address
	Form(address_ std.Address, registry_ *identity.IdentityRegistry) identity.IDString

	// Returns authorization for an address to call on behalf of identity
	Authed(identifier_ identity.IDString, orgdentifier_ identity.IDString) bool

	// Returns OrganicIdentity for valid organic identifier
	DAO(identifier_ identity.IDString) *DAO
}
