package dao

import (
	"std"
	"math"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/identity"		
)

type SubmissionPayload struct {
	submissionType SubmissionType
	submissionSubject interface{}
	submissionValue interface{}
}

type Submission struct {
	id uint64
	dao *DAO
	submitter identity.IDString
	state SubmissionState
	submissionPayload *SubmissionPayload
	voters avl.Tree	
    positive uint64 
	negative uint64
	neutral uint64
}

// SUBMISSION

func (s *Submission) ID() uint64 { return s.id }

func (s *Submission) DAO() *DAO { return s.dao }

func (s *Submission) State() SubmissionState { return s.state }

// Casts Vote for the submission
func (s *Submission) Vote(voter_ identity.IDString, vote_ int8) bool {
	if !s.dao.Membership(voter_){
		panic("Must be a member to vote.")
	}
	if s.state != SubmissionState("SUBMITTED") {
		panic("Proposal is no longer open; Voting ended.")
	}
	_voterStr := string(voter_)
	if s.voters.Has(_voterStr) {
		panic("Vote already cast. Can only vote once per-Proposal.")
	}
	if vote_ < -1 || vote_ > 1 {
		panic("Invalid vote value.")
	}	

	s.voters.Set(_voterStr,true)
	s.weightedVote(voter_, vote_)
	s.DAO().TickSubmissionVotes(voter_)
	return true
}

func (s *Submission) weightedVote(voter_ identity.IDString, vote_ int8) {
	//TODO: incorporate per-identity weighting with reputation/proposal bonding accounting
	switch vote_ {
	case -1:
		s.negative++
	case 1:
		s.positive++
	default:		
		s.neutral++
	}
}

// PROPOSAL DELTA

func (sp *SubmissionPayload) Type() SubmissionType { return sp.submissionType }

func (sp *SubmissionPayload) Subject() *interface{} { return &sp.submissionSubject }

func (sp *SubmissionPayload) Value() *interface{} { return &sp.submissionValue }








// JUNK TEMPORARILY SAVED IN CASE "ACCEPTANCE" MECHANISM ADDED

//TODO: noodle on "acceptance" oriented voting layer, like proposals
// type SubmissionSession struct {
// 	voters avl.Tree	
//     yays uint64 
// 	nays uint64
// 	undecideds uint64
// }

// Resolves the proposal, returning the final vote (balanced ternary)
// Executes if accepted, ticks nonce if 0
// func (s *Submission) Resolve() int8 {
// 	_results := s.voteResult()
// 	// panic(ufmt.Sprintf("Words %t", _results == -1))
// 	if _results == 1 {		
// 		s.state = ProposalState("ACCEPTED")
// 		s.Exec()	
// 	} else if _results == -1 {
// 		s.state = ProposalState("REJECTED")		
// 	} else {
// 		s.nonceTick()
// 	}	
// 	return _results
// }

//TODO: once votes mapped to nonce, create new "session" 
// func (s *Submission) nonceTick() {
// 	s.nonce++		
// 	_session := NewVotingSession()
// 	s.votingSessions.Set(string(s.nonce), _session)
// }

// func (p *Proposal) voteResult() int8 {
// 	_s, _exists := p.votingSessions.Get(string(p.nonce))
// 	if !_exists {
// 		panic("Invalid session?")
// 	}	
// 	_session := _s.(*VotingSession)

// 	_totalVotes := (_session.yays + _session.nays + _session.undecideds).(uint64)
// 	if _totalVotes != _session.voters.Size() {
// 		panic(ufmt.Sprintf("Vote/Voter count mismatch. Votes: %d; Voters: %d",_totalVotes, _session.voters.Size()))
// 	}
	
// 	_holdRound := math.Ceil((float64(_totalVotes) * 2 / 3))
// 	_threshold := uint64(_holdRound)
// 	// panic(ufmt.Sprintf("PANICKING; Yays: %d, Nays: %d, Undecideds: %d", p.yays, p.nays, p.undecideds))
// 	// panic(ufmt.Sprintf("PANICKING; Total: %d, HoldRound: %f; Int: %d",_totalVotes, _holdRound, _threshold))
// 	// TODO: implement %f in ufmt and test that with it ^

// 	// no votes = fails
// 	if _totalVotes == 0 {
// 		return -1
// 	}	
// 	// missing votes = undecided
// 	if _totalVotes < p.dao.TotalMembers() {
// 		return 0	
// 	}

// 	// return value if 2/3 threshhold is met, otherwise undecided
// 	if _session.yays >= _threshold {
// 		return 1
// 	} else if _session.nays >= _threshold {
// 		return -1
// 	} else {
// 		return 0
// 	}
// }