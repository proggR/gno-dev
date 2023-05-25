package dao

import (
	"std"
	"gno.land/p/demo/identity"	
)

type IProposal interface {

	// Returns the `proposalValue`. Currently just a uint64 value
    Value() uint64	

    // Votes on a proposal (must be DAO `member`)
	Vote(voter_ identity.IDString, vote_ int8) bool
	
    // Ends a proposal and returns final vote (must be DAO `admin`)
    Resolve() int8	
}


// Emitted when `admin` calls `Start`.
type ProposalCreated struct {
	proposalId  uint64
}

// Emitted when citizen casts a `Vote`.
type Voted struct {
	proposalId uint64
	voter identity.IDString
}

// Emitted when `Resolve` of `Proposal` completed.
type ProposalResolved struct {
	proposalId uint64
	finalVote   uint8
}