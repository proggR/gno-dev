package citizen

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

		_ir := Registry()
 		std.TestSetOrigCaller(admin)	
		_adminID := adminID//:= Naturalize()		
		t.Logf("Admin created Organic Identity: %s", string(_adminID))		
		_selfAuth := _ir.Authed(admin, _adminID)		
		if _selfAuth {
			t.Logf("Admin authed for organic self")
		} else {
			 t.Errorf("Admin Organic Self Auth Failed")
		}

		std.TestSetOrigCaller(gnoadmin)	
		_gnoadminID := Naturalize()		
		t.Logf("Admin created Organic Identity: %s", string(_gnoadminID))		
		_gnoselfAuth := _ir.Authed(gnoadmin, _gnoadminID)		
		if _gnoselfAuth {
			t.Logf("GnoAdmin authed for organic self")
		} else {
			 t.Errorf("GnoAdmin Organic Self Auth Failed")
		}

		std.TestSetOrigCaller(manfred)	
		_manfredID := Naturalize()		
		t.Logf("Admin created Organic Identity: %s", string(_manfredID))		
		_manfredselfAuth := _ir.Authed(manfred, _manfredID)		
		if _manfredselfAuth {
			t.Logf("Manfred authed for organic self")
		} else {
			 t.Errorf("Manfred Organic Self Auth Failed")
		}
		
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