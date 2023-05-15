package commune

import (
	"std"
	"testing"

	"gno.land/r/demo/citizen"
)

func TestCitizensMembersVoteResolution(t *testing.T) {
	const admin std.Address = "g138j0um48nm4ppcz0tr6az4qu3yjwjl3l6ntqdx"
	const gnoadmin std.Address = "g1us8428u2a5satrlxzagqqa5m6vmuze025anjlj"
	const manfred std.Address = "g1u7y667z64x2h7vc6fmpcprgey4ck233jaww9zq"

	type BooleanTest struct {
		name    string
		response bool
		fn      func() bool
	}

	// // Check that citizenship calls respond as expected. Register 3 Citizens to test 2/3 threshhold.
	// {
	// 	citizenTests := []BooleanTest{
	// 		{"Admin Auto Citizen", true, func() bool { return citizen.Citizenship(admin) }},
	// 		{"Non Citizen Is False", false, func() bool { return citizen.Citizenship(gnoadmin) }},
	// 		{"Non Citizen Naturalizes", true, func() bool { 
	// 			std.TestSetOrigCaller(gnoadmin)
	// 			return citizen.Naturalize() 
	// 		}},
	// 		{"Naturalized Is Citizen", true, func() bool { return citizen.Citizenship(gnoadmin) }},
	// 		{"Naturalized Cannot Naturalize", false, func() bool { 
	// 			std.TestSetOrigCaller(gnoadmin)
	// 			return citizen.Naturalize() 
	// 		}},
	// 		{"Non Citizen Naturalizes", true, func() bool { 
	// 			std.TestSetOrigCaller(manfred)
	// 			return citizen.Naturalize() 
	// 		}},
	// 	}
	// 	for _, tc := range citizenTests {
	// 		tr := tc.fn()
	// 		if tr != tc.response {
	// 			t.Errorf("%s: have: %t want: %t", tc.name, tr, tc.response)
	// 		}
	// 	}
	// }
	

	// Check that DAO membership calls respond as expected. Register 3 Citizens to test 2/3 threshhold.
	{
		std.TestSetOrigCaller(admin)
		membershipTests := []BooleanTest{
			{"Admin Auto Member", true, func() bool { return Member(admin) }},
			{"Non Member Is False", false, func() bool { return Member(gnoadmin) }},
			{"Non Member 1  Joins", true, func() bool { 
				std.TestSetOrigCaller(gnoadmin)
				return Join() 
			}},
			{"Joined Is Member", true, func() bool { return Member(gnoadmin) }},
			{"Joined Cannot Join", false, func() bool { 
				std.TestSetOrigCaller(gnoadmin)
				return Join() 
			}},
			{"Non Member 2 Joins", true, func() bool { 
				std.TestSetOrigCaller(manfred)
				return Join() 
			}},
		}
		for _, tc := range membershipTests {
			tr := tc.fn()
			if tr != tc.response {
				t.Errorf("%s: have: %t want: %t", tc.name, tr, tc.response)
			}else{
				t.Logf("%s: PASSED; have: %t, want %t",tc.name, tr, tc.response)
			}
		}
	}	

	// Check that DAO Proposal/Vote calls respond as expected.
	{

		// got := panicValue(func() { 
		// 	std.TestSetOrigCaller(gnoadmin)
		// 	ProposeChange(9001)
		// })
		// err, ok := got.(error)
		// if !ok {
		// 	t.Logf("Panicked: %s", err)
		// }
		std.TestSetOrigCaller(admin)
		_propId := ProposeChange(9002)
		t.Logf("Proposal %d Created", _propId)
		// Vote(_propId.(uint64),1)
		// t.Logf("Admin Voted %d on %d", 1, _propId)

		// std.TestSetOrigCaller(gnoadmin)
		// Vote(_propId.(uint64),-1)
		// t.Logf("Gnoadmin Voted %d on %d", -1, _propId)
		
		// std.TestSetOrigCaller(manfred)
		// Vote(_propId.(uint64),0)
		// t.Logf("Manfred Voted %d on %d", 0, _propId)

		std.TestSetOrigCaller(admin)
		finalVote := ProposalResolve(_propId)
		t.Logf("Final Vote: %d", finalVote)
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