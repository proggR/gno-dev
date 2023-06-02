package dao

import (
	"std"
	"math"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/identity"		
)

type ProposalDelta struct {
	proposalType ProposalType
	proposalSubject interface{}
	proposalValue interface{}
}

type VotingSession struct {
	voters avl.Tree	
    yays uint64 
	nays uint64
	undecideds uint64
}

type Proposal struct {
	id uint64
	dao *DAO
	proposer identity.IDString
	state ProposalState
	threshold float64
	quorum float64
	proposalDelta *ProposalDelta
	voterNonces avl.Tree 
	votingSessions avl.Tree
	nonce uint64
	result int8
}

// PROPOSAL

func (p *Proposal) ID() uint64 { return p.id }

func (p *Proposal) Proposer() identity.IDString { return p.proposer }

func (p *Proposal) DAO() *DAO { return p.dao }

func (p *Proposal) State() ProposalState { return p.state }

func (p *Proposal) Delta() *ProposalDelta { return p.proposalDelta }

func (p *Proposal) Nonce() uint64 { return p.nonce }

func (p *Proposal) Result() int8 { return p.result }

func (p *Proposal) Exec() bool { 
	return p.DAO().Executor(p.id, p.proposalDelta)
}

// Casts Vote for the proposal
func (p *Proposal) Vote(voter_ identity.IDString, vote_ int8) bool {
	
	if !p.dao.Membership(voter_){
		panic("Must be a member to vote.")
	}
	if p.state != ProposalState("OPEN") {
		panic("Proposal is no longer open; Voting ended.")
	}
	_s, _exists := p.votingSessions.Get(string(p.nonce))
	if !_exists {
		panic("Invalid session?")
	}
	_session := _s.(*VotingSession)
	_voterStr := string(voter_)
	if _session.voters.Has(_voterStr) {
		panic("Vote already cast. Can only vote once per-Proposal.")
	}
	if vote_ < -1 || vote_ > 1 {
		panic("Invalid vote value.")
	}	


	_voterNonce, _exists := p.voterNonces.Get(_voterStr)
	if !_exists {
		p.voterNonces.Set(_voterStr, 1)
	}else {
		_ticked := uint64(_voterNonce)+1
		p.voterNonces.Set(_voterStr, _ticked)
	}

	_session.voters.Set(_voterStr,true)
	p.weightedVote(_session, voter_, vote_)
	// p.DAO().TickProposalVotes(voter_)
	
	return true
}

func (p *Proposal) weightedVote(session_ *VotingSession, voter_ identity.IDString, vote_ int8) {
	//TODO: incorporate per-identity weighting with reputation/proposal bonding accounting
	switch vote_ {
	case -1:
		session_.nays++
	case 1:
		session_.yays++
	default:		
		session_.undecideds++
	}
}

// Resolves the proposal, returning the final vote (balanced ternary)
// Executes if accepted, ticks nonce if 0
func (p *Proposal) Resolve() int8 {
	_results := p.voteResult()	
	if _results == 1 {		
		p.state = ProposalState("ACCEPTED")
		p.Exec()	
	} else if _results == -1 {
		p.state = ProposalState("REJECTED")		
	} else {
		p.nonceTick()
	}	
	p.result = _results
	return _results
}

//TODO: once votes mapped to nonce, create new "session" 
func (p *Proposal) nonceTick() {
	p.nonce++		
	_session := NewVotingSession()
	p.votingSessions.Set(string(p.nonce), _session)
}

func (p *Proposal) voteResult() int8 {
	_s, _exists := p.votingSessions.Get(string(p.nonce))
	if !_exists {
		panic("Invalid session?")
	}	
	_session := _s.(*VotingSession)

	_totalVotes := (_session.yays + _session.nays + _session.undecideds).(uint64)
	if _totalVotes != _session.voters.Size() {
		panic(ufmt.Sprintf("Vote/Voter count mismatch. Votes: %d; Voters: %d",_totalVotes, _session.voters.Size()))
	}
	
	_holdRound := math.Ceil((float64(_totalVotes) * 2 / 3))
	_threshold := uint64(_holdRound)

	// no votes = fails
	if _totalVotes == 0 {
		return -1
	}	
	// missing votes = undecided
	if _totalVotes < p.dao.TotalMembers() {
		return 0	
	}

	// return value if 2/3 threshhold is met, otherwise undecided
	if _session.yays >= _threshold {
		return 1
	} else if _session.nays >= _threshold {
		return -1
	} else {
		return 0
	}
}


// PROPOSAL DELTA

func (pd *ProposalDelta) Type() ProposalType { return pd.proposalType }

func (pd *ProposalDelta) Subject() *interface{} { return &pd.proposalSubject }

func (pd *ProposalDelta) Value() *interface{} { return &pd.proposalValue }
