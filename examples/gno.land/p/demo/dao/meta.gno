package dao

import (
	"std"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/identity"
)

type MemberMeta struct {
	proposalCount uint64
	submissionCount uint64
	proposalVoteCount uint64
	submissionEngagementCount uint64
	proposalExecutionCount uint64
}

func (m *MemberMeta) TickProposals(){
	m.proposalCount++
}

func (m *MemberMeta) TickSubmissions(){
	m.submissionCount++
}

func (m *MemberMeta) TickExecutions(){
	m.proposalExecutionCount++
}

func (m *MemberMeta) TickProposalVotes(){
	m.proposalVoteCount++
}

func (m *MemberMeta) TickSubmissionVotes(){
	m.submissionEngagementCount++
}

//TODO: reconsider how votes work to better enforce only valid calls made
func (d *DAO) TickProposalVotes(voter_ identity.IDString) {
	_mm, _ := d.memberMeta.Get(string(voter_))
	_mm.(* MemberMeta).TickProposalVotes()
}

func (d *DAO) TickSubmissionVotes(voter_ identity.IDString) {
	_mm, _ := d.memberMeta.Get(string(voter_))
	_mm.(* MemberMeta).TickSubmissionVotes()
}