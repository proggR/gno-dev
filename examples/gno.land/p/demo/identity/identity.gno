package identity

import (
	"std"
	// "math/rand"
	// "crypto/rand"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
)

type Identity struct {	
	account std.Address
	admin IDString
	idRegistry *IdentityRegistry
	idString IDString
	idType IDType	
    metaData avl.Tree
}

type OrganicIdentity struct {	
	Identity
	verificationLevel uint64
}

type OrganizationalIdentity struct {	
	Identity
	members avl.Tree
}

type OrganizedEntity struct {	
	organizations avl.Tree	
}

type OrganizedOrganicIdentity struct {	
	OrganizedEntity
	OrganicIdentity	
}

type OrganizedOrganizationalIdentity struct {	
	OrganizedEntity	
	OrganizationalIdentity
}

func genUUID(type_ string, address_ std.Address) IDString {
	_uuid := type_+string(address_)
	// TODO: update to use crypto/rand... not sure how this worked before...
	// _bytes1 := []byte(string(address_))
	// _bytes2 := []byte(string(type_))
	// _seed := 0

		
    // for i := 0; i < 4; i++ {
    //     _seed = _seed << 8
    //     _seed += int(_bytes2[i])

    // }		
    // for i := 0; i < 4; i++ {
    //     _seed = _seed << 8
    //     _seed += int(_bytes1[i])

    // }

	// // TODO: look into proper UUID
	// _r := rand.FromSeed(int64(_seed))
	// _uuid := ufmt.Sprintf("%d-%d-%d-%d-%d", _r.Int63(), _r.Int63(), _r.Int63(), _r.Int63(), _r.Int63())

	return IDString(_uuid)
}

func NewOrganicIdentity(registry_ *IdentityRegistry, address_ std.Address) *OrganizedOrganicIdentity {
	_uuid := genUUID("peep",address_)
	return &OrganizedOrganicIdentity{
		OrganizedEntity:OrganizedEntity{
			organizations: avl.Tree{},
		},
		OrganicIdentity:OrganicIdentity{
			Identity: Identity{
				account: address_,
				idRegistry: registry_,
				idString: _uuid, 
				idType: IDType("organic"),
				metaData: avl.Tree{},
			},
			verificationLevel: 0,
		},
	}
}

func NewOrganizationalIdentity(registry_ *IdentityRegistry, address_ std.Address) *OrganizedOrganizationalIdentity {
	_uuid := genUUID("ogre",address_)
	return &OrganizedOrganizationalIdentity{
		OrganizedEntity: OrganizedEntity{
			organizations: avl.Tree{},
		},
		OrganizationalIdentity:OrganizationalIdentity{
			Identity: Identity{
				account: address_,
				idRegistry: registry_,
				idString: _uuid, 
				idType: "organization",
				metaData: avl.Tree{},
			},
			members: avl.Tree{},
		},
	}
}

// BASE IDENTITY

// Returns the UUID of an Identity 
func (i *Identity) Registry() *IdentityRegistry { return i.idRegistry }

// Returns the UUID of an Identity 
func (i *Identity) Account() std.Address { return i.account }

// Returns the UUID of an Identity 
func (i *Identity) Get() IDString { return i.idString }

// Returns the Type of an Identity (ie: Organic, Organizational, Infrastructure, etc)
func (i *Identity) Type() IDType { return i.idType }

// Stores a value at a key for an identity
func (i *Identity) Store(key_ string, value_ interface{}) bool {
	i.metaData.Set(key_, value_)
	return true
}

// Returns a value by key for an identity
func (i *Identity) Value(key_ string) interface{} {
	_value, _exists := i.metaData.Get(key_)
	if !_exists { panic("Key not defined") } //grawss
	return _value
}

// ORGANIC IDENTITY

//Returns the verification level of an identity (to be defined, basically KYC/AML)
func (p *OrganicIdentity) VerificationLevel() uint64 { return p.verificationLevel }

// ORGANIZATIONAL IDENTITY


// Returns the UUID of an Identity 
// func (o *OrganizationalIdentity) Admin() IDString { return o.admin }

// Joins the Organization (must be a valid `identity`)
func (o *OrganizationalIdentity) Join(identifier_ IDString) bool {
	// enforceIdentity(o.idRegistry, identifier_)
	_idStr := string(identifier_)
	_joiner := (o.Identity.idRegistry).Organized(identifier_)

	if o.members.Has(_idStr) {
		return false
	}
	o.members.Set(_idStr,true)	
	_joiner.JoinedOrg(o.Identity.Get())
	return true 
}
	
// Leaves the Organization (must be a valid `identity` and already a Organization member)
func (o *OrganizationalIdentity) Leave(identifier_ IDString) bool {
	_idStr := string(identifier_)
	_joiner := (o.Identity.idRegistry).Organized(identifier_)	

	if !o.members.Has(_idStr) {
		return false
	}
	o.members.Remove(_idStr)
	_joiner.LeftOrg(o.Identity.Get())
	return true 
}
	
// Returns membership status in the Organization
func (o *OrganizationalIdentity) Membership(identifier_ IDString) bool { return  o.members.Has(string(identifier_))	}

// Returns count of members
func (o *OrganizationalIdentity) TotalMembers() uint64  { return uint64(o.members.Size()) }

// ORGANIZED IDENTITY

//Returns total number of organizations belonged to by an identity
func (oi *OrganizedEntity) TotalOrgs() uint64 { return uint64(oi.organizations.Size()) }

//Returns membership status of id in a given organization 
func (oi *OrganizedEntity) MemberOf(orgIdentifier_ IDString) bool { return oi.organizations.Has(string(orgIdentifier_)) }

//Tracks joined organization as part of Organic Identity
func (oi *OrganizedEntity) JoinedOrg(orgIdentifier_ IDString) bool { 
	oi.organizations.Set(string(orgIdentifier_),true) 
	return true
}
	
//Tracks left organization as part of Organic Identity
func (oi *OrganizedEntity) LeftOrg(orgIdentifier_ IDString) bool {
	_orgId := string(orgIdentifier_)
	if !oi.organizations.Has(_orgId) {
		return false
	}
	oi.organizations.Remove(_orgId)
	return true
}

func enforceIdentity(registry_ *IdentityRegistry, caller_ IDString) {
	_identified := registry_.Identified(caller_)
	if !_identified {
		panic("Must register identity first")
	}
}