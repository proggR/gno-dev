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
	Identity(identifier_ IDString) IIdentity

	// Returns the Organic IDString for a calling account
	OrganicID(account_ std.Address) IDString	

	// Returns OrganicIdentity for valid organic identifier
	Organic(identifier_ IDString) *OrganizedOrganicIdentity

	// Returns the Organization IDString for a calling account
	OrganizationID(account_ std.Address) IDString

	// Returns OrganizationalIdentity for valid organization identifier
	Organization(identifier_ IDString) *OrganizedOrganizationalIdentity

	// Returns OrganizedEntity for valid organization identifier
	Organized(identifier_ IDString) Organized
}


// Emitted when `identity` successfully calls `Identify`.
type AccountIdentified struct {
	identity  std.Address
}


