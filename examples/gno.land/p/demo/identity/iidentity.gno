package identity

import (
	"std"
)

type IDString string 
type IDType string 

type IIdentity interface {	
    
	// Returns the identity
	Self() *Identity 

	// Returns the account of an Identity 
	Account() std.Address

	// Returns the UUID of an Identity 
	Get() string
    
	// Returns the Type of an Identity (ie: Organic, Organizational, Infrastructure, etc)
	Type() string

	// Stores a value at a key for an identity
	Store(key_ string, value_ interface{}) bool

	// Returns a value by key for an identity
	Value(key_ string) interface{}
}

type IOrganicIdentity interface {	
	//Returns the verification level of an identity (to be defined, basically KYC/AML)
	VerificationLevel() uint64	
}

type IOrganizedEntity interface {		

	//Returns membership status of id in a given organization 
	MemberOf(orgIdentifier_ IDString) bool

	//Tracks joined organization as part of Organic Identity
	JoinedOrg(orgIdentifier_ IDString) bool
	
	//Tracks left organization as part of Organic Identity
	LeftOrg(orgIdentifier_ IDString) bool

	// Returns count of organizations
	TotalOrgs() uint64
	//Return array string of organization IDs (to noodle on...)
	// Organizations(identifier_ IDString) []string
}

type IOrganizationalIdentity interface {	    

    // Joins the Organization (must be a valid `identity`)
	Join(identifier_ IDString) bool
	
    // Leaves the Organization (must be a valid `identity` and already a Organization member)
    Leave(identifier_ IDString) bool
	
    // Returns membership status in the Organization
    Membership(identifier_ IDString) bool

	// Returns count of members
	TotalMembers() uint64
}