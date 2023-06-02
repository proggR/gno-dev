package commune

import (
	"std"
	"strings"

	"gno.land/p/demo/web"
	"gno.land/p/demo/identity"
	"gno.land/p/demo/dao"
	"gno.land/p/demo/ufmt"	
)

var (	
	admin std.Address = "g138j0um48nm4ppcz0tr6az4qu3yjwjl3l6ntqdx" // TODO: helper to change admin
	// identityRegistry *identity.IdentityRegistry
	daoRegistry *dao.DAORegistry
	communeID identity.IDString
	commune *dao.DAO 
	router *web.Router
)

func init() {
	// identityRegistry = testInit() // test mode
	// identityRegistry = identityRegistry() // actual mode	
	daoRegistry = dao.NewDAORegistry(admin)
	//TODO: decide if this should be enforced? 
	// Seems to make sense: if admin of a DAORegistry, it should use the account to form a DAO for it
	// Maybe add functions to expose it/make it easier to find the daoRegistry's DAO
	// communeID = daoRegistry.Form(admin, identityRegistry)
	// commune = daoRegistry.DAO(communeID)
	router = CommuneRouter()
}
