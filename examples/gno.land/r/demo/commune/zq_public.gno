package commune

import (
	"std"
	"strings"

	"gno.land/p/demo/identity"
	"gno.land/p/demo/dao"
	"gno.land/p/demo/ufmt"
)

// Queries that don't consider Caller/ID of caller

// Returns DAO membership status for an account
func TotalMembers(orgIdentifier_ identity.IDString) uint64 { 
	return daoRegistry.DAO(orgIdentifier_).TotalMembers()
}

// Returns DAO membership status for an account
func Member(orgIdentifier_ identity.IDString, identifier_ identity.IDString) bool { 
	return daoRegistry.DAO(orgIdentifier_).Membership(identifier_) 
}

// Fetches the changed value of a Proposal at `idx_`
func Proposal(orgIdentifier_ identity.IDString, idx_ uint64) *dao.Proposal  {
	return daoRegistry.DAO(orgIdentifier_).ProposalAtIndex(idx_)
}
// Fetches the changed value of a Proposal at `idx_`
func ProposalDelta(orgIdentifier_ identity.IDString, idx_ uint64) *dao.ProposalDelta {
	_prop := daoRegistry.DAO(orgIdentifier_).ProposalAtIndex(idx_)
	return _prop.Delta()
}
