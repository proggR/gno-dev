package commune

 import (
 	"std"
 	"testing"
	 "gno.land/p/demo/ufmt"	
	 "gno.land/p/demo/identity"	
	 "gno.land/p/demo/dao"	
	 "gno.land/r/demo/citizen"	
 )

 func TestCommune(t *testing.T) {
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


 		std.TestSetOrigCaller(admin)
				
		// _adminID := identityRegistry.OrganicID(admin) //citizen.Naturalize()		
		_adminID := citizen.ID(_organicType, admin)		
		t.Logf("Admin created Organic Identity: %s", string(_adminID))		
		
		// _selfAuth := identityRegistry.Authed(admin, _adminID)		
		// if _selfAuth {
		// 	t.Logf("Admin authed for organic self")
		// } else {
		// 	 t.Errorf("Organic Self Auth Failed")
		// }
		
		_adminDAOID := Form()
		t.Logf("Admin created DAO: %s", string(_adminDAOID))
		
		_adminDAO := daoRegistry.DAO(_adminDAOID)
		// _admin := identityRegistry.Organized(_adminID)
		_adminDAOMembership := Member(_adminDAOID, _adminID)		
		// _adminMemberOf := identityRegistry.MemberOf(_adminID, _adminDAOID)		
		
		if _adminDAOMembership {
			t.Logf("Admin self DAO membership")
		} else {
			 t.Errorf("Self DAO Membership Failed")
		}
		
		// if _adminMemberOf {
		// 	t.Logf("Admin member of their self DAO")
		// } else {
		// 	 t.Errorf("Self DAO Member of Failed")
		// }
		_preCount := TotalMembers(_adminDAOID)
		t.Logf("Admin DAO member count: %d",_preCount)

		std.TestSetOrigCaller(gnoadmin)		
		_gnoadminID := citizen.Naturalize()
		// _gnoadminID := citizen.Naturalize()		
		t.Logf("Gnoadmin created Organic Identity: %s", string(_gnoadminID))
				
		_gnoadminDAOID := Form()
		t.Logf("Gnoadmin formed Commune: %s", string(_gnoadminDAOID))
		// _gnoadminDAO := daoRegistry.DAO(_gnoadminDAOID)


		std.TestSetOrigCaller(manfred)
		_manfredID := citizen.Naturalize()
		// _manfredID := citizen.Naturalize()
		t.Logf("Manfred created Organic Identity: %s", string(_manfredID))

		_manfredDAOID := Form()
		t.Logf("Manfred formed Commune: %s", string(_manfredDAOID))
		// _manfredDAO := daoRegistry.DAO(_manfredDAOID)

		// // DAO JOINS
		
		// _manfredJoined := _manfredDAO.Federate(_manfredID, _adminDAOID)
		_manfredJoined := Federate(_manfredDAOID, _adminDAOID)
		t.Logf("Manfred DAO Admin-Federated With Admin DAO: %t", _manfredJoined)
		

		_postUserCount := TotalMembers(_adminDAOID)
		t.Logf("Admin DAO member count: %d",_postUserCount)

		// DAO MEMBER VOTE TEST

		const _vote1 int8 = 1
		const _vote2 int8 = 0
		const _vote3 int8 = -1

		_values := make([]interface{},1)
		_values[0] = _adminDAOID

		
		// _mm :=  _gnoadminDAO.MemberMeta(_gnoadminID)
		// t.Logf("Member Meta: %d Proposed; %d Voted; %d Executed", _mm.proposalCount, _mm.proposalVoteCount, _mm.proposalExecutionCount)
		
		std.TestSetOrigCaller(gnoadmin)		
		_propId := ProposeChange(_gnoadminDAOID, dao.ProposalType("Self"), "federate", _values)		
		
		t.Logf("Proposal %d Created", _propId)		
		
		_prop := Proposal(_gnoadminDAOID, _propId)

		_nonce1 := _prop.Nonce()
		
		_stayed := Vote(_gnoadminDAOID,_propId,int8(0))		
		t.Logf("Proposal %d Nonce: %d", _propId, _nonce1)
		t.Logf("Proposal %d Voted", _propId)
		
		// t.Logf("Member Meta: %d Proposed; %d Voted; %d Executed", _mm.proposalCount, _mm.proposalVoteCount, _mm.proposalExecutionCount)

		//TODO: fix poorly implemented Resolve
		_resolved1 := ProposalResolve(_gnoadminDAOID, _propId)
		t.Logf("Proposal %d Resolved: %d", _propId, _resolved1)		
		_postStayCount := TotalMembers(_adminDAOID)
		t.Logf("Admin DAO member count: %d",_postStayCount)
		_nonce2 := _prop.Nonce()
		t.Logf("Proposal %d Nonce: %d", _propId, _nonce2)

		_voted := Vote(_gnoadminDAOID,_propId,int8(1))
		t.Logf("Proposal %d Voted", _propId)
		// t.Logf("Member Meta: %d Proposed; %d Voted; %d Executed", _mm.proposalCount, _mm.proposalVoteCount, _mm.proposalExecutionCount)
		
		//TODO: fix poorly implemented Resolve
		_resolved2 := ProposalResolve(_gnoadminDAOID, _propId)
		t.Logf("Proposal %d Resolved: %d", _propId, _resolved2)
		_nonce3 := _prop.Nonce()
		t.Logf("Proposal %d Nonce: %d", _propId, _nonce3)
		_postVoteCount := TotalMembers(_adminDAOID)
		t.Logf("Admin DAO member count: %d",_postVoteCount)
		// t.Logf("Member Meta: %d Proposed; %d Voted; %d Executed", _mm.proposalCount, _mm.proposalVoteCount, _mm.proposalExecutionCount)


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