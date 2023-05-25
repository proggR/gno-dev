package dao

import (
	"std"
	"gno.land/p/demo/identity"	
)

type IDAO interface {
	
    // // Joins the DAO (must be a valid `identity`)
	// Join(address_ std.Address) bool
	
    // // Leaves the DAO (must be a valid `identity` and already a DAO member)
    // Leave(address_ std.Address) bool
	
    // // Returns membership status in the DAO
    // Membership(address_ std.Address) bool

	// // Returns count of members
	// TotalMembers() uint64

	// Creates a proposal from the DAO (must be `admin`)
	ID() identity.IDString

	// Creates a proposal from the DAO (must be `admin`)
	Propose(identifier_ identity.IDString, value_ uint64) uint64

	// Fetchs the Proposal at a given `idx_`
	ProposalAtIndex(idx_ uint64) *Proposal

	// Fetchs the most recent Proposal
	CurrentProposal() *Proposal

	// Resolves a proposal and returns final vote (must be `admin`)
	ProposalResolve(identifier_ identity.IDString, propId_ uint64) int8
}


// Emitted when `citizen` successfully calls `Join`.
type Joined struct {
	member  identity.IDString
}

// Emitted when `citizen` successfully calls `Leave`.
type Left struct {
	member   identity.IDString
}