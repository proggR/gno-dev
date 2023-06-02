package commune

import (
	"std"
	"strings"

	"gno.land/p/demo/identity"
	"gno.land/p/demo/dao"
	"gno.land/p/demo/ufmt"
	"gno.land/r/demo/citizen"
)

// Commands using Caller to get ID

// Joins the DAO (must be a valid `identity`)
func Form() identity.IDString {
	_caller := std.GetOrigCaller()	
	_id := citizen.Organize()	
	_org := citizen.Organization(_id)	
	return daoRegistry.Form(_caller, _org)
}

// Joins the DAO (must be a valid `identity`)
func Join(orgIdentifier_ identity.IDString) bool {
	_id := organicCaller()
	return daoRegistry.DAO(orgIdentifier_).Join(_id)
}


// Commands with ID passed as first param

// Joins the DAO (must be a valid `identity`)
func IDJoin(identifier_ identity.IDString, orgIdentifier_ identity.IDString) bool {
	enforceCallerID(identifier_)
	return daoRegistry.DAO(orgIdentifier_).Join(identifier_)
}
