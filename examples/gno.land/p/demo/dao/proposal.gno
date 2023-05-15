package dao

import (
	"std"
	"math"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
)

type Proposal struct {
	id uint64
	dao *DAO
	proposer std.Address
	proposalValue uint64
	voters avl.Tree	
    yays uint64 
	nays uint64
	undecideds uint64
}

func NewProposal(dao_ *DAO, proposalIdx_ uint64, proposer_ std.Address, value_ uint64) *Proposal{	
	return &Proposal{
		id: proposalIdx_,
		dao: dao_,
		proposer: proposer_,
		proposalValue: value_, 
		voters: avl.Tree{},
		yays: 0, 
		nays: 0, 
		undecideds: 0,
	}
}

func (p *Proposal) Value() uint64 { return p.proposalValue }

// Casts Vote for the proposal
func (p *Proposal) Vote(voter_ std.Address, vote_ int8) bool {
	if !p.dao.Membership(voter_){
		panic("Must be a member to vote.")
	}
	_voterStr := string(voter_)
	if p.voters.Has(_voterStr) {
		panic("Vote already cast. Can only vote once per-Proposal.")
	}
	if vote_ < -1 || vote_ > 1 {
		panic("Invalid vote value.")
	}	
	p.voters.Set(_voterStr,true)

	switch vote_ {
		case -1:
			p.nays++
		case 1:
			p.yays++
		default:		
			p.undecideds++
	}

	return true
}

// Stops the proposal, returning the final vote (balanced ternary)
func (p *Proposal) Resolve() int8 {
	_totalVotes := (p.yays + p.nays + p.undecideds).(uint64)
	if _totalVotes != p.voters.Size() {
		panic(ufmt.Sprintf("Vote/Voter count mismatch. Votes: %d; Voters: %d",_totalVotes, p.voters.Size()))
	}
	
	_holdRound := math.Ceil((float64(_totalVotes) * 2 / 3))
	_threshhold := uint64(_holdRound)
	// panic(ufmt.Sprintf("PANICKING; Yays: %d, Nays: %d, Undecideds: %d", p.yays, p.nays, p.undecideds))
	// panic(ufmt.Sprintf("PANICKING; Total: %d, HoldRound: %f; Int: %d",_totalVotes, _holdRound, _threshhold))
	// TODO: implement %f in ufmt and test that with it ^

	// no votes = fails
	if _totalVotes == 0 {
		return -1
	}	
	// missing votes = undecided
	if _totalVotes < p.dao.TotalMembers() {
		return 0	
	}

	// return value if 2/3 threshhold is met, otherwise undecided
	if p.yays >= _threshhold {
		return 1
	} else if p.nays >= _threshhold {
		return -1
	} else {
		return 0
	}
}