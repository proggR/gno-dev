package dao

import (
	"std"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/identity"
)

// TODO: ideally instead of the Struct, identityRegistry should store interface type? noodle
type DAO struct {	
	Identity *identity.OrganizedOrganizationalIdentity
	daoRegistry *DAORegistry
	memberMeta avl.Tree
	supportedProposals avl.Tree	
	proposalIdx uint64
	proposals avl.Tree
	submissionIdx uint64
	submissions avl.Tree	
	execNonce uint64
	executions avl.Tree	
}

// PUBLIC

func (d *DAO) Call(execIdx_ uint64, funcName_ string, values_ []interface{}) bool {
	_state, _exists := d.executions.Get(string(execIdx_))
	//TODO: improve. wouldn't actually prevent anything malicious atm
	if !_exists || execIdx_ != d.execNonce || bool(_state) {
		panic("Invalid Execution Index. Call Rejected.")
	}

	// These are the supported "Self" executable subjects
	// All other ProposalTypes should handle necessary subject switching via SubjectParser
	_exec := string(execIdx_)
	switch funcName_ {
	case "federate":
		d.executions.Set(_exec,true)
		return d.federate(identity.IDString(values_[0]))
	case "defederate":
		d.executions.Set(_exec,true)
		return d.defederate(identity.IDString(values_[0]))
	case "federatedVote":
		d.executions.Set(_exec,true)
		return d.federatedVote(identity.IDString(values_[0]),int8(values_[1]))
	case "addProposalType":
		panic("Not yet implemented")
	case "removeProposalType":
		panic("Not yet implemented")
	default:
		panic(ufmt.Sprintf("Unsupported function called: %s",funcName_))
	}	
}

func (d *DAO) Executor(propIdx_ uint64, delta_ *ProposalDelta) bool {
	_prop := d.ProposalAtIndex(propIdx_)
	_state := _prop.State()
	if _state != ProposalState("ACCEPTED") {
		panic("Proposal not accepted. Execution terminated.")
	}	

	//TODO: switch to dao-level registry of executable types
	switch delta_.Type() {
	case ProposalType("Self"):		
		d.execNonce++
		d.executions.Set(string(d.execNonce), false)
		d.execute(d.execNonce, delta_, SelfSubjectParser, SelfValueParser)
	default:
		panic("Unsupported Proposal Type. Execution Rejected.")
	}

	_mm, _ := d.memberMeta.Get(string(_prop.Proposer()))
	_mm.(* MemberMeta).TickExecutions()

	return true
}

// Returns the DAO's IDString
func (d *DAO) ID() identity.IDString { return d.Identity.Get() }

// Joins the DAO (must be a valid `identity`)
func (d *DAO) Join(identifier_ identity.IDString) bool { 
	_joined := d.Identity.Join(identifier_) 
	// MemberMeta will be retained between leaves/returns
	d.memberMetaInit(identifier_)	
	return _joined
}

// Leaves the DAO (must be a valid `identity` and already a DAO member)
func (d *DAO) Leave(identifier_ identity.IDString) bool { return d.Identity.Leave(identifier_) }
	
// Returns membership status in the DAO
func (d *DAO) Membership(identifier_ identity.IDString) bool { return d.Identity.Membership(identifier_) }

// Returns membership status in the DAO
func (d *DAO) TotalMembers() uint64 { return uint64(d.Identity.TotalMembers()) }

// Creates a proposal to the DAO (must be a member)
func (d *DAO) Propose(identifier_ identity.IDString, type_ ProposalType, subject_ string, value_ []interface{}) uint64 {
	d.enforceMember(identifier_)		
	_deltaSubject := NewSelfSubject(d, subject_)
	_deltaValue := NewSelfValue(value_)

	d.proposalIdx++
	_delta := NewProposalDelta(type_, _deltaSubject, _deltaValue)		
	_proposal := NewProposal(d, d.proposalIdx, identifier_, _delta)		
	
	_mm, _ := d.memberMeta.Get(string(identifier_))
	_mm.(* MemberMeta).TickProposals()
	d.proposals.Set(string(d.proposalIdx),_proposal)	
	
	return d.proposalIdx
}

// Creates a submission to the DAO (must be a member)
func (d *DAO) Submit(identifier_ identity.IDString, type_ SubmissionType, subject_ string, value_ []interface{}) uint64 {
	d.enforceMember(identifier_)	
	//TODO: noodle on how to improve subject/value and what may differ between proposal/submissions	
	_payloadSubject := NewSelfSubject(d, subject_)
	_payloadValue := NewSelfValue(value_)

	d.submissionIdx++
	_payload := NewSubmissionPayload(type_, _payloadSubject, _payloadValue)		
	_submission := NewSubmission(d, d.submissionIdx, identifier_, _payload)

	_mm, _ := d.memberMeta.Get(string(identifier_))
	_mm.(* MemberMeta).TickSubmissions()
	d.submissions.Set(string(d.submissionIdx),_submission)	

	return d.submissionIdx
}

// Returns the MemberMeta struct for a given identifier
func (d *DAO) MemberMeta(identifier_ identity.IDString) * MemberMeta {	
	_m, _exists := d.memberMeta.Get(string(identifier_))
	if !_exists {
		panic("Invalid member identifier")
	}
	return _m.(* MemberMeta)
}

// Resolves a proposal at a given index (must be `admin`)
func (d *DAO) ProposalResolve(identifier_ identity.IDString, propId_ uint64) int8 {	
	d.enforceAdmin(identifier_)		
	_proposal := d.getProposal(propId_)	
	return _proposal.Resolve()
}

// Returns a Proposal for a given index, or panics if invalid index
func (d *DAO) ProposalAtIndex(idx_ uint64) *Proposal { return d.getProposal(idx_) }

// Returns most recent Proposal, or panics if none created
func (d *DAO) CurrentProposal() *Proposal { return d.getProposal(d.proposalIdx)	}

// Returns a Submission for a given index, or panics if invalid index
func (d *DAO) SubmissionAtIndex(idx_ uint64) *Submission { return d.getSubmission(idx_) }

// Adds a new ProposalType (must be `admin`) (not implemented)
func (d *DAO) AddProposalType(identifier_ identity.IDString, type_ ProposalType, subject_ SubjectParser, value_ ValueParser) bool {
	d.enforceAdmin(identifier_)
	return d.addProposalType(type_, subject_, value_)
}

// Removes a ProposalType (must be `admin`) (not implemented)
func (d *DAO) RemoveProposalType(identifier_ identity.IDString, type_ ProposalType) bool {
	d.enforceAdmin(identifier_)
	return d.removeProposalType(type_)
}

// Federates with another DAO (must be `admin`)
func (d *DAO) Federate(identifier_ identity.IDString, orgIdentifier_ identity.IDString) bool {
	d.enforceAdmin(identifier_)
	return d.federate(orgIdentifier_)
}

// Defederates with another DAO (must be `admin`)
func (d *DAO) Defederate(identifier_ identity.IDString, orgIdentifier_ identity.IDString) bool {
	d.enforceAdmin(identifier_)
	return d.defederate(orgIdentifier_)
}

// Casts a vote from the DAO to another DAO (must be `admin`)
func (d *DAO) FederatedVote(identifier_ identity.IDString, orgIdentifier_ identity.IDString, vote_ int8) bool {
	d.enforceAdmin(identifier_)
	return d.federatedVote(orgIdentifier_, vote_)	
}




// PRIVATE

func (d *DAO) memberMetaInit(identifier_ identity.IDString) {	
	_idStr := string(identifier_)
	if !d.memberMeta.Has(_idStr) {	
		_mm := NewMemberMeta()	
		d.memberMeta.Set(_idStr,_mm)
	}
}

func (d *DAO) execute(execIdx_ uint64, delta_ *ProposalDelta, subParser_ SubjectParser, valParser_ ValueParser) bool {	
	_callable := Callable(delta_.Subject())
	_subject := subParser_(_callable)
	_values := valParser_(Valued(delta_.Value()))
	return _callable.Call(execIdx_, _values)
}


func (d *DAO) getSubmission(idx_ uint64) *Submission {
	_submission, _exists := d.submissions.Get(string(idx_))
	if !_exists {
		panic(ufmt.Sprintf("Invalid Proposal Identifier: %d",idx_))
	}

	return _submission.(* Submission)
}

func (d *DAO) getProposal(idx_ uint64) *Proposal {
	_proposal, _exists := d.proposals.Get(string(idx_))
	if !_exists {
		panic(ufmt.Sprintf("Invalid Proposal Identifier: %d",idx_))
	}

	return _proposal.(* Proposal)
}

func (d *DAO) addProposalType(type_ ProposalType, subject_ SubjectParser, value_ ValueParser) bool {
	// add type to supportedProposalTypes tree
	// map type to subject parser	
	// map type to value parser	
	return true
}

func (d *DAO) removeProposalType(type_ ProposalType) bool {
	// remove type to supportedProposalTypes tree
	// unmap type from subject parser	
	// unmap type from value parser	
	return true
}

func (d *DAO) federate(orgIdentifier_ identity.IDString) bool {
	_dao := d.daoRegistry.DAO(orgIdentifier_)
	return _dao.Join(d.ID())
}

func (d *DAO) defederate(orgIdentifier_ identity.IDString) bool {
	_dao := d.daoRegistry.DAO(orgIdentifier_)
	return _dao.Leave(d.ID())
}

func (d *DAO) federatedVote(orgIdentifier_ identity.IDString, vote_ int8) bool {
	_dao := d.daoRegistry.DAO(orgIdentifier_)
	_proposal := _dao.CurrentProposal()

	return _proposal.Vote(d.ID(), vote_)
}


// UTILITY/ "MODIFIERS"

func (d *DAO) enforceAdmin(identifier_ identity.IDString) {
	_account := d.Identity.Registry().Identity(identifier_).Account()

	if _account != d.Identity.Account() {
		panic(ufmt.Sprintf("Must be admin: %s",string(d.Identity.Account())))
	}	
}

func (d *DAO) enforceMember(identifier_ identity.IDString) {	
	_member := d.Membership(identifier_)
	if !_member {
		panic(ufmt.Sprintf("Must be admin: %s",string(d.Identity.Account())))
	}	
}