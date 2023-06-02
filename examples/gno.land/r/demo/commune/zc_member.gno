package commune

import (
	"std"
	"strings"

	"gno.land/p/demo/identity"
	"gno.land/p/demo/dao"
	"gno.land/p/demo/ufmt"
)

// Commands using Caller to get ID

// Leaves the DAO (must be a valid `identity` and already a DAO member)
func Leave(orgIdentifier_ identity.IDString) bool {
	_id := organicCaller()
	return daoRegistry.DAO(orgIdentifier_).Leave(_id)
}

// Creates a proposal from the DAO (must be `admin`)
func ProposeChange(orgIdentifier_ identity.IDString, type_ dao.ProposalType, subject_ string, values_ string) uint64 {
	_values := strings.Split(values_, ",")
	_id := organicCaller()
	return daoRegistry.DAO(orgIdentifier_).Propose(_id, type_, subject_, _values)		
}

// Votes on a Proposal at a given `idx_`
func Vote(orgIdentifier_ identity.IDString, idx_ uint64, vote_ int8) bool {
	_id := organicCaller()
	_dao := daoRegistry.DAO(orgIdentifier_)
	if !_dao.Membership(_id) {
		panic("Must be a registered member to vote")
	}

	return _dao.ProposalAtIndex(idx_).Vote(_id, vote_)
}


// Commands with ID passed as first param

// Leaves the DAO (must be a valid `identity` and already a DAO member)
func IDLeave(identifier_ identity.IDString, orgIdentifier_ identity.IDString) bool {
	enforceCallerID(identifier_)
	return daoRegistry.DAO(orgIdentifier_).Leave(identifier_)
}

// Creates a proposal from the DAO (must be `admin`)
func IDProposeChange(identifier_ identity.IDString, orgIdentifier_ identity.IDString, value_ uint64) uint64 {
	enforceCallerID(identifier_)
	return 0//daoRegistry.DAO(orgIdentifier_).Propose(identifier_, value_)
}

// Votes on a Proposal at a given `idx_`
func IDVote(identifier_ identity.IDString, orgIdentifier_ identity.IDString, idx_ uint64, vote_ int8) bool {
	enforceCallerID(identifier_)
	_dao := daoRegistry.DAO(orgIdentifier_)
	if !_dao.Membership(identifier_) {
		panic("Must be a registered member to vote")
	}

	return _dao.ProposalAtIndex(idx_).Vote(identifier_, vote_)
}