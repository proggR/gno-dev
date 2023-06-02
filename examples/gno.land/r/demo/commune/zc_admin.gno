package commune

import (
	"std"
	"strings"

	"gno.land/p/demo/identity"
	"gno.land/p/demo/dao"
	"gno.land/p/demo/ufmt"
)

// Commands using Caller to get ID

// Resolves a proposal and returns final vote (must be `admin`)
func ProposalResolve(orgIdentifier_ identity.IDString, propId_ uint64) int8 {	
	_adminID := enforceAdmin(orgIdentifier_)
	return daoRegistry.DAO(orgIdentifier_).ProposalResolve(_adminID, propId_)
}

// Resolves a proposal and returns final vote (must be `admin`)
func Federate(orgIdentifier_ identity.IDString, assocIdentifier_ identity.IDString) bool {	
	_adminID := enforceAdmin(orgIdentifier_)
	return daoRegistry.DAO(orgIdentifier_).Federate(_adminID, assocIdentifier_)
}

// Resolves a proposal and returns final vote (must be `admin`)
func Defederate(orgIdentifier_ identity.IDString, assocIdentifier_ identity.IDString) bool {	
	_adminID := enforceAdmin(orgIdentifier_)
	return daoRegistry.DAO(orgIdentifier_).Defederate(_adminID, assocIdentifier_)
}

// Resolves a proposal and returns final vote (must be `admin`)
func FederatedVote(orgIdentifier_ identity.IDString, assocIdentifier_ identity.IDString, vote_ int8) bool {	
	_adminID := enforceAdmin(orgIdentifier_)
	return daoRegistry.DAO(orgIdentifier_).FederatedVote(_adminID, assocIdentifier_, vote_)
}


// Commands with ID passed as first param

// Resolves a proposal and returns final vote (must be `admin`)
func IDProposalResolve(identifier_ identity.IDString, orgIdentifier_ identity.IDString, propId_ uint64) int8 {
	enforceAdminID(orgIdentifier_, identifier_)
	return daoRegistry.DAO(orgIdentifier_).ProposalResolve(identifier_, propId_)
}
