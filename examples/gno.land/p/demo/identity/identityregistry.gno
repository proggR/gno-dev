package identity

import (
	"std"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
	// "github.com/google/uuid"
	// "reflect"
)

type IdentityRegistry struct {	
	admin std.Address
    identities avl.Tree
    organicAccounts avl.Tree
    organizationalAccounts avl.Tree
}

func NewIdentityRegistry(admin_ std.Address) *IdentityRegistry {
	return &IdentityRegistry{
		admin: admin_, 
		identities: avl.Tree{},
		organicAccounts: avl.Tree{},
		organizationalAccounts: avl.Tree{},
	}
	// _identityRegistry := initRegistry(admin_)
	// _identityRegistry.Identify(admin_)
	// return _identityRegistry
}

func initRegistry(admin_ std.Address) *IdentityRegistry {
	
}

// Identifies an address as an `Identity` (ie: creates a new Identity)
func (ir *IdentityRegistry) Identify(type_ IDType, address_ std.Address) IDString {
	_addressStr := string(address_)
	switch _type := string(type_) ; _type {
	case "organic":
		if ir.organicAccounts.Has(_addressStr) {
			panic("Address already organic identity")
		}
		_identity := NewOrganicIdentity(ir,address_)
		_identifier := _identity.Identity.Get()
		ir.identities.Set(string(_identifier),_identity)
		ir.organicAccounts.Set(_addressStr,_identifier)		
		return _identifier
	case "organization":
		if ir.organizationalAccounts.Has(_addressStr) {
			panic("Address already organization identity")
		}
		_identity := NewOrganizationalIdentity(ir,address_)
		_identifier := _identity.Identity.Get()
		ir.identities.Set(string(_identifier),_identity)
		ir.organizationalAccounts.Set(_addressStr,_identifier)
		return _identifier
	default:
		panic("Unsupported type")
	}
}


// Returns authorization for an address to call on behalf of identity
func (ir *IdentityRegistry) Authed(account_ std.Address, identifier_ IDString) bool {
	// _identity := ir.Identity(identifier_)
	_identity, _exists := ir.identities.Get(string(identifier_)) 
	 
	if !_exists {
		panic("Identity does not exist")
	}

	if IIdentity(_identity).Account() != account_ {
		return false
	}
	return true
}

// Identifies an address as an `Identity`
func (ir *IdentityRegistry) Identity(identifier_ IDString) *Identity {
	 _identity, _exists := ir.identities.Get(string(identifier_)) 
	 
	if !_exists {
		panic("Identity does not exist")
	}
	
	_id := _identity.(*Identity)
	return _id //_identity.Identity.(IIdentity).Self()
}

// Returns the Organic IDString for a calling account
func (ir *IdentityRegistry) OrganicID(account_ std.Address) IDString {
	 _id, _idExists := ir.organicAccounts.Get(string(account_)) 
	 
	if !_idExists {
		panic("Organic identity does not exist for account")
	}
	return _id.(IDString) 
}

// Identifies an address as an `Identity`
func (ir *IdentityRegistry) Organic(identifier_ IDString) *OrganicIdentity {
	 _identity, _idExists := ir.identities.Get(string(identifier_)) 
	 
	if !_idExists {
		panic("Identity does not exist")
	}
	
	_id := _identity.(IIdentity)
	_organic, _organicExists := ir.organicAccounts.Get(string(_id.Account())) 
	_idType := ufmt.Sprintf("%T", _identity)	// TODO: look into proper reflection package
	if !_organicExists || _id.Type() != "organic" || _idType != "OrganicIdentity" {
		panic("Identity is not Organic")
	}
	
	return _identity.(*OrganicIdentity)
}

// Returns the Organization IDString for a calling account
func (ir *IdentityRegistry) OrganizationID(account_ std.Address) IDString {
	_id, _idExists := ir.organizationalAccounts.Get(string(account_)) 
	
   if !_idExists {
	   panic("Organization identity does not exist for account")
   }
   return _id.(IDString) 
}

// Identifies an address as an `Identity`
func (ir *IdentityRegistry) Organization(identifier_ IDString) *OrganizationalIdentity {
	 _identity, _idExists := ir.identities.Get(string(identifier_)) 
	 
	if !_idExists {
		panic("Identity does not exist")
	}

	_id := _identity.(IIdentity)
	_organization, _organizationExists := ir.organizationalAccounts.Get(string(_id.Account())) 
	_idType := ufmt.Sprintf("%T", _identity)
	if !_organizationExists || _id.Type() != "organic" || _idType != "OrganizationalIdentity" {
		panic("Identity is not Organizational")
	}
	
	return _identity.(*OrganizationalIdentity)
}

// // Returns identity status of address
// func (ir *IdentityRegistry) Identities(address_ std.Address) bool {
// 	_identity, _exists := ir.identities.Get(string(address_))
// 	if !_exists {
// 		return false
// 	}
// 	return true
// }