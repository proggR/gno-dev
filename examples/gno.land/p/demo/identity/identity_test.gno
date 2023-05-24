package identity

 import (
 	"std"
 	"testing"
 )

 func TestIdentities(t *testing.T) {
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
 		//  got := panicValue(func() { 
 		//  	std.TestSetOrigCaller(gnoadmin)
 		//  	ProposeChange(9001)
 		//  })

		//  t.Errorf("%s: have: %t want: %t", tc.name, tr, tc.response)
 		//  err, ok := got.(error)
 		//  if !ok {
 		//  	t.Logf("Panicked: %s", err)
 		//  }

		const _organicType IDType = "organic"
		const _organizationType IDType ="organization"

 		std.TestSetOrigCaller(admin)
		_ir := NewIdentityRegistry(admin)
		
		_adminID := _ir.Identify(_organicType, admin)		
		t.Logf("Admin created Organic Identity: %s", string(_adminID))
		
		_selfAuth := _ir.Authed(admin, _adminID)		
		if _selfAuth {
			t.Logf("Admin authed for organic self")
		} else {
			 t.Errorf("Organic Self Auth Failed")
		}
		
		t.Logf("Admin authed for self")
		_adminOrgID := _ir.Identify(_organizationType, admin)
		t.Logf("Admin created Organizational Identity: %s", string(_adminOrgID))
		
		_selfOrgAuth := _ir.Authed(admin, _adminOrgID)		
		if _selfOrgAuth {
			t.Logf("Admin authed for self org")
		} else {
			 t.Errorf("Self Org Auth Failed")
		}

		std.TestSetOrigCaller(gnoadmin)
		
		_gnoadminID := _ir.Identify(_organicType, gnoadmin)		
		t.Logf("Gnoadmin created Organic Identity: %s", string(_gnoadminID))
		_gnoadminOrgID := _ir.Identify(_organizationType, gnoadmin)
		t.Logf("Gnoadmin created Organizational Identity: %s", string(_gnoadminOrgID))

		std.TestSetOrigCaller(manfred)
		
		_manfredID := _ir.Identify(_organicType, manfred)		
		t.Logf("Manfred created Organic Identity: %s", string(_manfredID))
		_manfredOrgID := _ir.Identify(_organizationType, manfred)
		t.Logf("Manfred created Organizational Identity: %s", string(_manfredOrgID))

		_unAuth := _ir.Authed(manfred, _adminID)		
		if !_unAuth {
			t.Logf("Successfully denied auth")
		} else {
			 t.Errorf("FAIL!: Unathorized access")
		}
		_auth := _ir.Authed(manfred, _manfredOrgID)		
		if !_auth {
			t.Errorf("FAIL!: Demoed access for self org")			
		} else {
			t.Logf("Successfully allowed auth for self org")
		}

		// // only one organic/org id checks
		// _adminFailID := _ir.Identify(_organicType, admin)	
		// _adminOrgFailID := _ir.Identify(_organizationType, admin)	
		


		// _failIDGot := panicValue(func() { 
 		//  	std.TestSetOrigCaller(admin)
		// 	_adminFailID := _ir.Identify(_organicType, admin)	
 		//  })

 		//  _selfErr, _selfOk := _failIDGot.(error)
 		//  if !_selfOk {
 		//  	t.Logf("Panicked: %s", string(_selfErr))
 		//  }

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