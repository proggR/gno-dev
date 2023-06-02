package dao

 import (
 	"std"
 	"testing"
	 "gno.land/p/demo/identity"	
 )

 func TestDAO(t *testing.T) {
 	const admin std.Address = "g138j0um48nm4ppcz0tr6az4qu3yjwjl3l6ntqdx"
 	const gnoadmin std.Address = "g1us8428u2a5satrlxzagqqa5m6vmuze025anjlj"
 	const manfred std.Address = "g1u7y667z64x2h7vc6fmpcprgey4ck233jaww9zq"

 	type BooleanTest struct {
 		name    string
 		response bool
 		fn      func() bool
 	}

 	// walk through creating organic and org ids, asserting only one of each per person
 	{

		const _organicType identity.IDType = "organic"
		// const _organizationType IDType ="organization"

 		std.TestSetOrigCaller(admin)
		_ir := identity.NewIdentityRegistry(admin)
		_dr := NewDAORegistry(admin)
		
		_adminID := _ir.Identify(_organicType, admin)		
		t.Logf("Admin created Organic Identity: %s", string(_adminID))		
		_selfAuth := _ir.Authed(admin, _adminID)		
		if _selfAuth {
			t.Logf("Admin authed for organic self")
		} else {
			 t.Errorf("Organic Self Auth Failed")
		}
		
		_adminDAOID := _dr.Form(admin,_ir)
		_adminDAO := _dr.DAO(_adminDAOID)


		// _adminOrgID := _ir.Identify(_organizationType, admin)
		// t.Logf("Admin created Organizational Identity: %s", string(_adminOrgID))
		
		// _selfOrgAuth := _ir.Authed(admin, _adminOrgID)		
		// if _selfOrgAuth {
		// 	t.Logf("Admin authed for self org")
		// } else {
		// 	 t.Errorf("Self Org Auth Failed")
		// }

		// _admin := _ir.Organized(_adminID)
		_adminDAOMembership := _adminDAO.Membership(_adminID)		
		_adminMemberOf := _ir.MemberOf(_adminDAOID,_adminID)		
		
		if _adminDAOMembership {
			t.Logf("Admin self DAO membership")
		} else {
			 t.Errorf("Self DAO Membership Failed")
		}
		if _adminMemberOf {
			t.Logf("Admin member of their self DAO")
		} else {
			 t.Errorf("Self DAO Member of Failed")
		}
		_preCount := _adminDAO.TotalMembers()
		t.Logf("Admin DAO member count: %d",_preCount)
		std.TestSetOrigCaller(gnoadmin)
		
		_gnoadminID := _ir.Identify(_organicType, gnoadmin)		
		t.Logf("Gnoadmin created Organic Identity: %s", string(_gnoadminID))

		std.TestSetOrigCaller(manfred)
		_manfredID := _ir.Identify(_organicType, manfred)		
		t.Logf("Manfred created Organic Identity: %s", string(_manfredID))

		_gnoadminDAOID := _dr.Form(gnoadmin,_ir)
		_gnoadminDAO := _dr.DAO(_gnoadminDAOID)

		_manfredDAOID := _dr.Form(manfred,_ir)
		_manfredDAO := _dr.DAO(_manfredDAOID)

		// DAO JOINS
		// _gnoadminJoined := _gnoadminDAO.Federate(_gnoadminID, _adminDAOID)
		// t.Logf("Gnoadmin Joined Admin DAO: %t", _gnoadminJoined)
		
		_manfredJoined := _manfredDAO.Federate(_manfredID, _adminDAOID)
		t.Logf("Manfred Joined Admin DAO: %t", _manfredJoined)
		
		// ORGANIC JOINS

		// _gnoadminJoined := _adminDAO.Join(_gnoadminID)
		// t.Logf("Gnoadmin Joined Admin DAO: %t", _gnoadminJoined)
		
		// _manfredJoined := _adminDAO.Join(_manfredID)
		// t.Logf("Manfred Joined Admin DAO: %t", _manfredJoined)
		

		_postUserCount := _adminDAO.TotalMembers()
		t.Logf("Admin DAO member count: %d",_postUserCount)

		// DAO MEMBER VOTE TEST

		const _vote1 int8 = 1
		const _vote2 int8 = 0
		const _vote3 int8 = -1

		_values := make([]interface{},1)
		_values[0] = _adminDAOID

		std.TestSetOrigCaller(admin)
		_mm :=  _gnoadminDAO.MemberMeta(_gnoadminID)
		t.Logf("Member Meta: %d Proposed; %d Voted; %d Executed", _mm.proposalCount, _mm.proposalVoteCount, _mm.proposalExecutionCount)
		_propId := _gnoadminDAO.Propose(_gnoadminID, ProposalType("Self"), "federate", _values)
		t.Logf("Proposal %d Created", _propId)		
		_prop := _gnoadminDAO.ProposalAtIndex(_propId)
		_nonce1 := _prop.Nonce()
		_stayed := _prop.Vote(_gnoadminID,int8(0))
		t.Logf("Proposal %d Nonce: %d", _propId, _nonce1)
		t.Logf("Proposal %d Voted", _propId)
		t.Logf("Member Meta: %d Proposed; %d Voted; %d Executed", _mm.proposalCount, _mm.proposalVoteCount, _mm.proposalExecutionCount)

		//TODO: fix poorly implemented Resolve
		_resolved1 := _prop.Resolve()
		t.Logf("Proposal %d Resolved: %d", _propId, _resolved1)		
		_postStayCount := _adminDAO.TotalMembers()
		t.Logf("Admin DAO member count: %d",_postStayCount)
		_nonce2 := _prop.Nonce()
		t.Logf("Proposal %d Nonce: %d", _propId, _nonce2)

		_voted := _prop.Vote(_gnoadminID,int8(1))
		t.Logf("Proposal %d Voted", _propId)
		t.Logf("Member Meta: %d Proposed; %d Voted; %d Executed", _mm.proposalCount, _mm.proposalVoteCount, _mm.proposalExecutionCount)
		
		//TODO: fix poorly implemented Resolve
		_resolved2 := _prop.Resolve()
		t.Logf("Proposal %d Resolved: %d", _propId, _resolved2)		
		_nonce3 := _prop.Nonce()
		t.Logf("Proposal %d Nonce: %d", _propId, _nonce3)
		_postVoteCount := _adminDAO.TotalMembers()
		t.Logf("Admin DAO member count: %d",_postVoteCount)
		t.Logf("Member Meta: %d Proposed; %d Voted; %d Executed", _mm.proposalCount, _mm.proposalVoteCount, _mm.proposalExecutionCount)



		// _adminVoted := _adminDAO.ProposalAtIndex(_propId.(uint64)).Vote(_adminID,_vote1)
		// t.Logf("Admin Voted %d on %d", _vote1, _propId)

		
		// std.TestSetOrigCaller(gnoadmin)
		// _gnoadminVoted := _gnoadminDAO.FederatedVote(_gnoadminID, _adminDAOID, _vote2)
		// // Vote(_propId.(uint64),)
		// t.Logf("Gnoadmin's DAO Voted %d on %d", _vote2, _propId)
		
		// std.TestSetOrigCaller(manfred)
		// _manfredVoted := _manfredDAO.FederatedVote(_manfredID, _adminDAOID, _vote3)
		// t.Logf("Manfred's DAO Voted %d on %d", _vote3, _propId)

		// std.TestSetOrigCaller(admin)
		// finalVote := _adminDAO.ProposalResolve(_adminID,_propId)
		// t.Logf("Final Vote: %d", finalVote)
		t.Errorf("SUCCESS! FAILING NOW!")					
 	}	
 }


 func panicValue(fn func()) (recovered interface{}) {
     defer func() {
         recovered = recover()
     }()
     fn()    
 	return
 }