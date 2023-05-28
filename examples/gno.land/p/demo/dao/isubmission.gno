package dao

import (
	"std"
	"gno.land/p/demo/identity"	
)

type SubmissionType string 
type SubmissionState string 

type Submitted interface {

	// Returns the Proposal ID
    ID() uint64

	// Returns the DAO a Proposal belongs to. 
    DAO() *DAO	

	// Returns the current state
    State() SubmissionState	

    // Votes on a proposal (must be DAO `member`)
	Vote(voter_ identity.IDString, vote_ int8) bool
}

type Submitable interface {
	// Returns the `proposalType`. 
	Type() SubmissionType	

	// Returns the `proposalSubject`. 
	Subject() interface{}	

	// Returns the `proposalValue`. 
	Value() interface{}		
}

// Emitted when `admin` calls `Start`.
type SubmissionCreated struct {
	submissionId  uint64
}

// Emitted when citizen casts a `Vote`.
type SubmissionVoted struct {
	submissionId uint64
	voter identity.IDString
}
