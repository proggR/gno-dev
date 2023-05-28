package dao

import (
	"std"
	"gno.land/p/demo/identity"	
)

type ProposalType string 
type SessionID string 
type SessionStatus string 
type ProposalState string 

type Proposed interface {

	// Returns the Proposal ID
    ID() uint64

	// Returns the DAO a Proposal belongs to. 
    DAO() *DAO	

	// Returns the current state
    State() ProposalState	

    // Votes on a proposal (must be DAO `member`)
	Vote(voter_ identity.IDString, vote_ int8) bool
	
    // Ends a proposal and returns final vote (must be DAO `admin`)
    Resolve() int8	
	
	Nonce() uint64
}

type Executable interface {
	// Returns the `proposalType`. 
	Type() ProposalType	

	// Returns the `proposalSubject`. 
	Subject() interface{}	

	// Returns the `proposalValue`. 
	Value() interface{}	

	// Exec, taking in proposal reference for access to DAO
	Exec(proposal_ *Proposal) bool	
}



//TODO: noodle on more. add discussion tracking? or bail and tuck into proposal?
type Sessionable interface {
	ID() SessionID
	Expires() uint64
	Status() SessionStatus
	Previous() SessionID
	AgendaAdd() uint64 
	AgendaAt() *Proposal
	AgendaRem() bool
	AgendaCount() uint64
}

// Emitted when `admin` calls `Start`.
type ProposalCreated struct {
	proposalId  uint64
}

// Emitted when citizen casts a `Vote`.
type ProposalVoted struct {
	proposalId uint64
	voter identity.IDString
}

// Emitted when `Resolve` of `Proposal` completed.
type ProposalResolved struct {
	proposalId uint64
	finalVote   uint8
}