package dao

import (
	"std"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/identity"
)


// TODO: ideally instead of the Struct, identityRegistry should store interface type? noodle
type DAO struct {
	admin std.Address
	identityRegistry *identity.IdentityRegistry
	proposalIdx uint64
	proposals avl.Tree
    members avl.Tree
}

func NewDAO(admin_ std.Address, registry_ *identity.IdentityRegistry) *DAO{	
	enforceIdentity(registry_, admin_)	

	return &DAO{
		admin: admin_, 
		identityRegistry: registry_,
		proposalIdx: 0,
		proposals: avl.Tree{},
		members: avl.Tree{},
	}
}

// Joins the DAO (must be a valid `citizen`)
func (d *DAO) Join(address_ std.Address) bool {
	enforceIdentity(d.identityRegistry, address_)
	addressStr := string(address_)
	if d.members.Has(addressStr) {
		return false
	}
	d.members.Set(addressStr,true)
	return true 
}
	
// Leaves the DAO (must be a valid `citizen` and already a DAO member)
func (d *DAO) Leave(address_ std.Address) bool {
	addressStr := string(address_)
	if !d.members.Has(addressStr) {
		return false
	}
	d.members.Remove(addressStr)
	return true 
}
	
// Returns membership status in the DAO
func (d *DAO) Membership(address_ std.Address) bool {
	addressStr := string(address_)
	return  d.members.Has(addressStr)	
}

// Returns membership status in the DAO
func (d *DAO) TotalMembers() uint64 { return uint64(d.members.Size()) }

// Creates a proposal from the DAO (must be `admin`)
func (d *DAO) Propose(proposer_ std.Address, value_ uint64) uint64 {
	d.enforceAdmin(proposer_)
	
	d.proposalIdx++
	_proposal := NewProposal(d, d.proposalIdx, proposer_, value_)
	d.proposals.Set(string(d.proposalIdx),_proposal)
	
	return d.proposalIdx
}

// Resolves a proposal at a given index (must be `admin`)
func (d *DAO) ProposalResolve(caller_ std.Address, propId_ uint64) int8 {
	d.enforceAdmin(caller_)	
	_proposal := d.getProposal(propId_)
	return _proposal.Resolve()
}

// Returns a Proposal for a given index, or panics if invalid index
func (d *DAO) ProposalAtIndex(idx_ uint64) *Proposal { return d.getProposal(idx_) }

// Returns most recent Proposal, or panics if none created
func (d *DAO) CurrentProposal() *Proposal { return d.getProposal(d.proposalIdx)	}

func (d *DAO) getProposal(idx_ uint64) *Proposal {
	_proposal, _exists := d.proposals.Get(string(idx_))
	if !_exists {
		panic("Invalid Proposal Identifier")
	}

	return _proposal.(* Proposal)
}

func (d *DAO) enforceAdmin(caller_ std.Address) {
	if caller_ != d.admin {
		panic("Must be admin")
	}	
}

func enforceIdentity(registry_ *identity.IdentityRegistry, caller_ std.Address) {
	// identified := registry_.Identified(caller_)
	// if !identified {
	// 	panic("Must register identity first")
	// }
}