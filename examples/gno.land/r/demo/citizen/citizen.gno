package citizen

import (
	"std"
	"strings"

	"gno.land/p/demo/identity"
	"gno.land/p/demo/ufmt"
)

var (
	identityRegistry   *identity.IdentityRegistry
	admin std.Address = "g138j0um48nm4ppcz0tr6az4qu3yjwjl3l6ntqdx" // TODO: helper to change admin
	adminID identity.IDString
	organicType identity.IDType = "organic"	
	organizationType identity.IDType = "organization"	
)

func init() {
	identityRegistry = identity.NewIdentityRegistry(admin)
	adminID = identityRegistry.Identify(organicType,admin)
}

// Returns the identityRegistry. Feels janky and wrong. Circle back
// func Registry() *identity.IdentityRegistry { return identityRegistry }

func ID(type_ identity.IDType, account_ std.Address) identity.IDString {
	if type_ == organicType {
		return identityRegistry.OrganicID(account_)
	} else if type_ == organizationType {
		return identityRegistry.OrganizationID(account_)
	}
	
	panic("Unsupported ID type")	
}

func Reveal(type_ identity.IDType, identifier_ identity.IDString ) std.Address {
	if type_ == organicType {
		return identityRegistry.Organic(identifier_).Account()
	} else if type_ == organizationType {
		return identityRegistry.Organization(identifier_).Account()
	}
	
	panic("Unsupported ID type")	
}

// Returns Citizen Identity registration status for IDString (ie: confirms valid)
func Citizenship(identifier_ identity.IDString) bool { return identityRegistry.Identified(identifier_) }

// Registers an Citizen Identity to address
func Naturalize() identity.IDString {
	_caller := std.GetOrigCaller()
	return identityRegistry.Identify(organicType, _caller)
}

// Registers an Organization Identity to address
func Organize() identity.IDString {
	_caller := std.GetOrigCaller()
	return identityRegistry.Identify(organizationType, _caller)
}

// Returns an Organization 
func Organic(identifier_ identity.IDString) *identity.OrganizedOrganicIdentity {
	return identityRegistry.Organic(identifier_)
}

// Returns an Organization 
func Organization(identifier_ identity.IDString) *identity.OrganizedOrganizationalIdentity {
	return identityRegistry.Organization(identifier_)
}
	


