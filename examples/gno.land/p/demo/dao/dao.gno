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
	proposalIdx uint64
	proposals avl.Tree
}

func NewDAO(admin_ std.Address, idRegistry_ *identity.IdentityRegistry, daoRegistry_ *DAORegistry) *DAO{	
	// enforceIdentity(registry_, admin_)
	_orgID := idRegistry_.Identify(identity.IDType("organization"), admin_)	
	_identity := idRegistry_.Organization(_orgID)
	return &DAO{
		Identity: _identity,
		daoRegistry: daoRegistry_,
		proposalIdx: 0,
		proposals: avl.Tree{},
	}
}

// Joins the DAO (must be a valid `citizen`)
func (d *DAO) ID() identity.IDString { return d.Identity.Get() }

// Joins the DAO (must be a valid `citizen`)
func (d *DAO) Join(identifier_ identity.IDString) bool { return d.Identity.Join(identifier_) }
	
// Leaves the DAO (must be a valid `citizen` and already a DAO member)
func (d *DAO) Leave(identifier_ identity.IDString) bool { return d.Identity.Leave(identifier_) }
	
// Returns membership status in the DAO
func (d *DAO) Membership(identifier_ identity.IDString) bool { return d.Identity.Membership(identifier_) }

// Returns membership status in the DAO
func (d *DAO) TotalMembers() uint64 { return uint64(d.Identity.TotalMembers()) }

// Creates a proposal from the DAO (must be `admin`)
func (d *DAO) Federate(identifier_ identity.IDString, orgIdentifier_ identity.IDString) bool {
	d.enforceAdmin(identifier_)
	_dao := d.daoRegistry.DAO(orgIdentifier_)
	// _org := .idRegistry.Organization(orgIdentifier_)
	return _dao.Join(d.ID())
}

// Creates a proposal from the DAO (must be `admin`)
func (d *DAO) FederatedVote(identifier_ identity.IDString, orgIdentifier_ identity.IDString, vote_ int8) bool {
	d.enforceAdmin(identifier_)
	_dao := d.daoRegistry.DAO(orgIdentifier_)
	_proposal := _dao.CurrentProposal()

	return _proposal.Vote(d.ID(), vote_)
}

// Creates a proposal from the DAO (must be `admin`)
func (d *DAO) Propose(identifier_ identity.IDString, value_ uint64) uint64 {
	d.enforceAdmin(identifier_)
	
	d.proposalIdx++
	_proposal := NewProposal(d, d.proposalIdx, identifier_, value_)
	d.proposals.Set(string(d.proposalIdx),_proposal)
	
	return d.proposalIdx
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

func (d *DAO) getProposal(idx_ uint64) *Proposal {
	_proposal, _exists := d.proposals.Get(string(idx_))
	if !_exists {
		panic("Invalid Proposal Identifier")
	}

	return _proposal.(* Proposal)
}

func (d *DAO) enforceAdmin(identifier_ identity.IDString) {
	_account := d.Identity.Registry().Identity(identifier_).Account()

	if _account != d.Identity.Account() {
		panic(ufmt.Sprintf("Must be admin: %s",string(d.Identity.Account())))
	}	
}

func enforceIdentity(registry_ *identity.IdentityRegistry, identifier_ identity.IDString) {
	// identified := registry_.Identified(caller_)
	// if !identified {
	// 	panic("Must register identity first")
	// }
}