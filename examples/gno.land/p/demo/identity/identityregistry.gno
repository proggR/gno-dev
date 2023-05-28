package identity

import (
	"std"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
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
		_selfID, _exists := ir.organicAccounts.Get(_addressStr)
		if !_exists {
			panic("Must have personal identity to create organization")
		}		
		
		_identity := NewOrganizationalIdentity(ir,address_)
		_identifier := _identity.Identity.Get()
		
		ir.identities.Set(string(_identifier),_identity)
		ir.organizationalAccounts.Set(_addressStr,_identifier)
		_identity.Join(IDString(_selfID))
		
		return _identifier
	default:
		panic("Unsupported type")
	}
}


// Returns authorization for an address to call on behalf of identity
func (ir *IdentityRegistry) Authed(account_ std.Address, identifier_ IDString) bool {
	_identity := ir.Identity(identifier_)
	return _identity.Account() == account_ 
}

// Confirms valid identity
func (ir *IdentityRegistry) Identified(identifier_ IDString) bool { return ir.identities.Has(string(identifier_)) }

// Returns the IIdentity of an identity for an ID
func (ir *IdentityRegistry) Identity(identifier_ IDString) IIdentity {
	 _identity, _exists := ir.identities.Get(string(identifier_)) 
	 
	if !_exists {
		panic("Identity does not exist")
	}	
	
	return IIdentity(_identity)
}

// Returns the Organic IDString for a calling account
func (ir *IdentityRegistry) OrganicID(account_ std.Address) IDString {
	 _id, _exists := ir.organicAccounts.Get(string(account_)) 
	 
	if !_exists {
		panic("Organic identity does not exist for account")
	}

	return _id.(IDString) 
}

// Returns the Organic struct for an ID (if valid and organic)
func (ir *IdentityRegistry) Organic(identifier_ IDString) *OrganizedOrganicIdentity {
	 _identity, _exists := ir.identities.Get(string(identifier_)) 
	 
	if !_exists {
		panic("Identity does not exist")
	}
	
	_id := _identity.(IIdentity)
	_organic, _organicExists := ir.organicAccounts.Get(string(_id.Account())) 
	
	// TODO: look into proper reflection package
	if !_organicExists || _id.Type() != "organic" {
		panic("Identity is not Organic")
	}
	
	return _identity.(*OrganizedOrganicIdentity)
}

// Returns the Organization IDString for a calling account
func (ir *IdentityRegistry) OrganizationID(account_ std.Address) IDString {
	_id, _exists := ir.organizationalAccounts.Get(string(account_)) 
	
   if !_exists {
	   panic("Organization identity does not exist for account")
   }
   return _id.(IDString) 
}

// Returns the Organization struct for an ID (if valid and organic)
func (ir *IdentityRegistry) Organization(identifier_ IDString) *OrganizedOrganizationalIdentity {
	 _identity, _exists := ir.identities.Get(string(identifier_)) 
	 
	if !_exists {
		panic("Identity does not exist")
	}

	_id := IIdentity(_identity)
	_organization, _organizationExists := ir.organizationalAccounts.Get(string(_id.Account())) 

	if !_organizationExists || _id.Type() != "organization" {
		panic(ufmt.Sprintf("Identity is not Organizational: %s",string(_id.Type())))
	}
	
	return _identity.(*OrganizedOrganizationalIdentity)
}

// Returns an Organized identity for an ID (if valid)
func (ir *IdentityRegistry) Organized(identifier_ IDString) Organized {
	 _identity, _exists := ir.identities.Get(string(identifier_)) 
	 
	if !_exists {
		panic("Identity does not exist")
	}

	return Organized(_identity)
}