package dao

import (
	"std"
	"gno.land/p/demo/identity"	
)
type IDAO interface {
	
    // Joins the DAO (must be a valid `identity`)
	Join(identifier_ identity.IDString) bool
	
    // Leaves the DAO (must be a valid `identity` and already a DAO member)
    Leave(identifier_ identity.IDString) bool
	
    // Returns membership status in the DAO
    Membership(identifier_ identity.IDString) bool

	// Returns count of members
	TotalMembers() uint64

	// Returns the DAO's IDString
	ID() identity.IDString

	// Creates a submission to the DAO (must be member)
	Submit(identifier_ identity.IDString, type_ SubmissionType, subject_ string, value_ []interface{})

	// Fetchs the Submission at a given `idx_`
	SubmissionAtIndex(idx_ uint64) *Submission

	// Creates a proposal to the DAO (must be `admin`)
	Propose(identifier_ identity.IDString, type_ ProposalType, subject_ string, value_ []interface{}) uint64

	// Fetchs the Proposal at a given `idx_`
	ProposalAtIndex(idx_ uint64) *Proposal

	// Fetchs the most recent Proposal
	CurrentProposal() *Proposal

	// Resolves a proposal and returns final vote (must be `admin`)
	ProposalResolve(identifier_ identity.IDString, propId_ uint64) int8

	// Executes a proposal using Subject/Value parsers on ProposalDelta
	Executor(propIdx_ uint64, delta_ *ProposalDelta) bool

	// Calls a function by string name, allowing Executing proposals to interact with DAO
	Call(execIdx_ uint64, funcName_ string, values_ []interface{}) bool

	// Returns the MemberMeta struct for a given identifier
	MemberMeta(identifier_ identity.IDString) * MemberMeta

	// DAO-Of-DAO hooks, each with a corresponding private function, public ones being locked to admin
	Federate(identifier_ identity.IDString, orgIdentifier_ identity.IDString) bool
	Defederate(identifier_ identity.IDString, orgIdentifier_ identity.IDString) bool
	FederatedVote(identifier_ identity.IDString, orgIdentifier_ identity.IDString, vote_ int8) bool

	// Unimplemented Add/Remove proposal type hooks (submission types will need the same)
	AddProposalType(identifier_ identity.IDString, type_ ProposalType, subject_ SubjectParser, value_ ValueParser)
	RemoveProposalType(identifier_ identity.IDString, type_ ProposalType) bool
}


// Emitted when `citizen` successfully calls `Join`.
type JoinedDAO struct {
	member  identity.IDString
}

// Emitted when `citizen` successfully calls `Leave`.
type LeftDAO struct {
	member   identity.IDString
}