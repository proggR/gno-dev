package dao

import (
	"std"
	"gno.land/p/demo/identity"	
)

type LegislatureKey string 

type Legislated interface {

	// Stores the value stored at a given key (with identifier for perms checks)
    Store(identifier_ identity.IDString, key_ LegislatureKey, value_ *interface{}) bool

	// Returns the value stored at a given key (with identifier for perms checks)
    Value(identifier_ identity.IDString, key_ LegislatureKey) interface{}	
		
}

type Legalized interface {	
	Previous() LegislatureKey
	Enact() LegislatureKey
	Repeal() LegislatureKey
}


// Emitted when `Resolve` of `Proposal` completed.
// type ProposalResolved struct {
// 	proposalId uint64
// 	finalVote   uint8
// }