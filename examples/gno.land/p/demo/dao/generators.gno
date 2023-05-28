package dao

import (
	"std"
	"math"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/identity"		
)

func NewDAO(admin_ std.Address, idRegistry_ *identity.IdentityRegistry, daoRegistry_ *DAORegistry) *DAO{	
	_orgID := idRegistry_.Identify(identity.IDType("organization"), admin_)	
	_org := idRegistry_.Organization(_orgID)
	
	_id := idRegistry_.OrganicID(admin_)
	_mm := avl.Tree{}
	_mm.Set(string(_id),NewMemberMeta())
	
	return &DAO{
		Identity: _org,
		daoRegistry: daoRegistry_,
		memberMeta: _mm,
		proposalIdx: 0,
		proposals: avl.Tree{},
		submissionIdx: 0,
		submissions: avl.Tree{},
		execNonce: 0,
		executions: avl.Tree{},
	}	
}

func NewMemberMeta() * MemberMeta {
	return &MemberMeta{
		proposalCount:0,
		submissionCount:0,
		proposalVoteCount:0,
		submissionEngagementCount:0,
		proposalExecutionCount: 0,
	}
}

func NewDAORegistry(admin_ std.Address) *DAORegistry {
	return &DAORegistry{
		admin: admin_, 
		daos: avl.Tree{},
	}
}

func NewProposalDelta(type_ ProposalType, subject_ interface{}, values_ interface{}) *ProposalDelta {	
	if type_ != ProposalType("Self") {
		// TODO: remove/accept DAO to check types?
		panic("Unsupported delta type")
	}

	return &ProposalDelta {
		proposalType: type_,
		proposalSubject: subject_, 
		proposalValue: values_,
	}
}

func NewVotingSession() *VotingSession{
	return &VotingSession{
		voters: avl.Tree{},	
		yays:0, 
		nays:0,
		undecideds:0,
	}
	
}

func NewProposal(dao_ *DAO, proposalIdx_ uint64, proposer_ identity.IDString, delta_ *ProposalDelta) *Proposal {	
	//TODO: roll fsm package
	_state := ProposalState("OPEN")
	_session := NewVotingSession()
	_sessions := avl.Tree{}
	_sessions.Set(string(0), _session)
	return &Proposal{
		id: proposalIdx_,
		dao: dao_,
		proposer: proposer_,
		state: _state,
		threshold: float64(2 / 3),
		quorum: float64(1),
		proposalDelta: delta_,
		voterNonces: avl.Tree{},
		votingSessions: _sessions,
		nonce: 0,
	}
}

func NewSubmissionPayload(type_ SubmissionType, subject_ interface{}, values_ interface{}) *SubmissionPayload {	
	return &SubmissionPayload {
		submissionType: type_,
		submissionSubject: subject_, 
		submissionValue: values_,
	}
}

func NewSubmission(dao_ *DAO, proposalIdx_ uint64, submitter_ identity.IDString, payload_ *SubmissionPayload) *Submission {	
	//TODO: roll fsm package
	_state := SubmissionState("SUBMITTED")
	_voters := avl.Tree{}
	_voters.Set(string(submitter_), true)
	return &Submission{
		id: proposalIdx_,
		dao: dao_,
		submitter: submitter_,
		state: _state,
		submissionPayload: payload_,
		voters: _voters,
		positive: 1,
		negative: 0,
		neutral: 0,
	}
}




// ProposalType Related Generators

func NewSelfSubject(dao_ *DAO, subject_ string) interface{} {	
	return SelfSubject{PS:PS{dao:dao_, subject:subject_}}
}

func NewSelfValue(values_ []interface{}) interface{} {	
	return SelfValue{PV:PV{values: values_}}
}