package identity

import (
	"std"
	"gno.land/p/demo/rand"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
)

type Identity struct {	
	account std.Address
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

type OrganizedIdentity struct {	
	Identity
	organizations avl.Tree	
}

type OrganizedOrganicIdentity struct {	
	OrganizedIdentity	
}

type OrganizedOrganizationalIdentity struct {	
	OrganizedIdentity	
}

func genUUID(type_ string, address_ std.Address) IDString {
	// 	return uuid.New()
	_bytes1 := []byte(string(address_))
	_bytes2 := []byte(string(type_))
	_seed := 0

		
    for i := 0; i < 4; i++ {
        _seed = _seed << 8
        _seed += int(_bytes2[i])

    }		
    for i := 0; i < 4; i++ {
        _seed = _seed << 8
        _seed += int(_bytes1[i])

    }

	// TODO: look into proper UUID
	_r := rand.FromSeed(int64(_seed))
	_uuid := ufmt.Sprintf("%d-%d-%d-%d-%d", _r.Int63(), _r.Int63(), _r.Int63(), _r.Int63(), _r.Int63())

	return IDString(_uuid)
}

func NewOrganicIdentity(registry_ *IdentityRegistry, address_ std.Address) *OrganicIdentity {
	_uuid := genUUID("peep",address_)
	return &OrganicIdentity{
		Identity: Identity{
			account: address_,
			idRegistry: registry_,
			idString: _uuid, 
			idType: IDType("organic"),
			metaData: avl.Tree{},
		},
		verificationLevel: 0,
	}
}

func NewOrganizationalIdentity(registry_ *IdentityRegistry, address_ std.Address) *OrganizationalIdentity {
	_uuid := genUUID("ogre",address_)
	return &OrganizationalIdentity{
		Identity: Identity{
			account: address_,
			idRegistry: registry_,
			idString: _uuid, 
			idType: "organization",
			metaData: avl.Tree{},
		},
		members: avl.Tree{},
	}
}

// Returns the UUID of an Identity 
func (i *Identity) Account() std.Address { return i.account }

// Returns the instance (weird but haxx for interface{} for now)
func (i *Identity) Self() *Identity { return i }

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

// Joins the Organization (must be a valid `identity`)
func (o *OrganizationalIdentity) Join(identifier_ IDString) bool {
	// enforceIdentity(o.idRegistry, identifier_)
	_idStr := string(identifier_)
	if o.members.Has(_idStr) {
		return false
	}
	o.members.Set(_idStr,true)
	return true 
}
	
// Leaves the Organization (must be a valid `identity` and already a Organization member)
func (o *OrganizationalIdentity) Leave(identifier_ IDString) bool {
	_idStr := string(identifier_)
	if !o.members.Has(_idStr) {
		return false
	}
	o.members.Remove(_idStr)
	return true 
}
	
// Returns membership status in the Organization
func (o *OrganizationalIdentity) Membership(identifier_ IDString) bool { return  o.members.Has(string(identifier_))	}

// Returns count of members
func (o *OrganizationalIdentity) TotalMembers() uint64  { return uint64(o.members.Size()) }

// ORGANIZED IDENTITY

//Returns membership status of id in a given organization 
func (oi *OrganizedIdentity) MemberOf(orgIdentifier_ IDString) bool {

}

//Tracks joined organization as part of Organic Identity
func (oi *OrganizedIdentity) JoinedOrg(orgIdentifier_ IDString) bool {

}
	
//Tracks left organization as part of Organic Identity
func (oi *OrganizedIdentity) LeftOrg(orgIdentifier_ IDString) bool {

}

func enforceIdentity(registry_ *IdentityRegistry, caller_ IDString) {
	// identified := registry_.Identified(caller_)
	// if !identified {
	// 	panic("Must register identity first")
	// }
}