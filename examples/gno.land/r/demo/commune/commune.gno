package commune

import (
	"std"
	"strings"

	"gno.land/p/demo/dao"
	"gno.land/p/demo/ufmt"
	"gno.land/r/demo/citizen"
)

var (	
	admin std.Address = "g138j0um48nm4ppcz0tr6az4qu3yjwjl3l6ntqdx" // TODO: helper to change admin
	commune *dao.DAO 
)

func init() {
	commune = dao.NewDAO(admin,citizen.Registry())	
	commune.Join(admin)
}


// Joins the DAO (must be a valid `identity`)
func Join() bool {
	_caller := std.GetOrigCaller()
	return commune.Join(_caller)
}

// Leaves the DAO (must be a valid `identity` and already a DAO member)
func Leave() bool {
	_caller := std.GetOrigCaller()
	return commune.Leave(_caller)
}

// Returns DAO membership status for an account
func Member(address_ std.Address) bool { return commune.Membership(address_) }

// Creates a proposal from the DAO (must be `admin`)
func ProposeChange(value_ uint64) uint64 {
	_caller := std.GetOrigCaller()
	enforceAdmin(_caller)
	return commune.Propose(_caller, value_)
}

// Votes on a Proposal at a given `idx_`
func Vote(idx_ uint64, vote_ int8) bool {
	_caller := std.GetOrigCaller()
	if !commune.Membership(_caller) {
		panic("Must be a registered member to vote")
	}

	_prop := commune.ProposalAtIndex(idx_)
	return _prop.Vote(_caller, vote_)
}

// Fetches the changed value of a Proposal at `idx_`
func ProposalValue(idx_ uint64) uint64 {
	_caller := std.GetOrigCaller()
	if !commune.Membership(_caller) {
		panic("Must be a registered member to see value")
	}

	_prop := commune.ProposalAtIndex(idx_)
	return _prop.Value()
}

// Resolves a proposal and returns final vote (must be `admin`)
func ProposalResolve(propId_ uint64) int8 {
	_caller := std.GetOrigCaller()
	enforceAdmin(_caller)
	return commune.ProposalResolve(_caller, propId_)
}

func enforceAdmin(caller_ std.Address) {
	if caller_ != admin {
		panic("Must be admin")
	}	
}