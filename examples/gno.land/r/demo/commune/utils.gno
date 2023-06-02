package commune

import (
	"std"
	"strings"

	"gno.land/p/demo/identity"
	"gno.land/p/demo/dao"
	"gno.land/p/demo/ufmt"
	"gno.land/r/demo/citizen"
)

//NOTE: needs identityRegistry() for actual use as realm. 
// both it and testInit() called from init() in commune.gno (manually change for now)

// func identityRegistry() *identity.IdentityRegistry{
// 	return citizen.Registry()
// }

func identifierCallback(type_ identity.IDType, account_ std.Address) identity.IDString {
	return identity.IDString("")
	//return citizen.ID(type_, account_)
}

func revealerCallback(type_ identity.IDType, identifier_ identity.IDString) std.Address {
	return std.Address("")
	//return citizen.Reveal(type_, identifier_)
}

func testInit() *identity.IdentityRegistry{
	_ir := identity.NewIdentityRegistry(admin)
	_ir.Identify(identity.IDType("organic"),admin)	
	return _ir
}

func organicCaller() identity.IDString {
	_caller := std.GetOrigCaller()
	return organicID(_caller)
}

func organicID(account_ std.Address) identity.IDString {
	return citizen.ID(identity.IDType("organic"), account_)
}

func idAccount(identifier_ identity.IDString) std.Address {
	return citizen.Reveal(identity.IDType("organic"), identifier_)
}

//TODO: expand to not just account == account check, but allow delegation in identity
func enforceCallerID(identifier_ identity.IDString) {
	_caller := std.GetOrigCaller()
	_match := _caller == citizen.Reveal(identity.IDType("organic"), identifier_)
	if !_match {
		panic("Must be ID owner")
	}
}

func enforceAdmin(orgIdentifier_ identity.IDString) identity.IDString {
	_caller := std.GetOrigCaller()
	_orgAccount := citizen.Reveal(identity.IDType("organization"),orgIdentifier_)
	_callerOrgID := citizen.ID(identity.IDType("organization"),_caller)
	_callerID := citizen.ID(identity.IDType("organic"),_caller)

	if _orgAccount != _caller || _callerOrgID != orgIdentifier_ {
		panic("Must be admin")
	}	

	return _callerID
}

//... all of these id things should be considered more
func enforceAdminID(orgIdentifier_ identity.IDString, identifier_ identity.IDString) {
	_caller := std.GetOrigCaller()

	_orgAccount := citizen.Reveal(identity.IDType("organization"),orgIdentifier_)
	_idAccount := citizen.Reveal(identity.IDType("organic"),identifier_)

	_match := _caller == _orgAccount && _caller == _idAccount

	if !_match {
		panic("Must be admin")
	}	
}