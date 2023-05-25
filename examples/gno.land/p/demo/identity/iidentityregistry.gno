package identity

import (
	"std"
)

type IIdentityRegistry interface {	
	// Registers an Identity to address
	Identify(type_ IDType, address_ std.Address) IDString

	// Returns authorization for an address to call on behalf of identity
	Authed(account_ std.Address, identifier_ IDString) bool

	// Confirms valid identity
	Identified(identifier_ IDString) bool

	// Returns Identity for valid identifier
	Identity(identifier_ IDString) *Identity

	// Returns the Organic IDString for a calling account
	OrganicID(account_ std.Address) IDString	

	// Returns OrganicIdentity for valid organic identifier
	Organic(identifier_ IDString) *OrganicIdentity

	// Returns the Organization IDString for a calling account
	OrganizationID(account_ std.Address) IDString

	// Returns OrganizationalIdentity for valid organization identifier
	Organization(identifier_ IDString) *OrganizationalIdentity

	// Returns OrganizedEntity for valid organization identifier
	Organized(identifier_ IDString) *OrganizedEntity
}


// Emitted when `identity` successfully calls `Identify`.
type AccountIdentified struct {
	identity  std.Address
}


