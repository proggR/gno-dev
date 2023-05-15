package citizen

import (
	"std"
	"strings"

	"gno.land/p/demo/identity"
	"gno.land/p/demo/ufmt"
)

var (
	identityRegistry   *identity.IdentityRegistry
	admin std.Address = "g138j0um48nm4ppcz0tr6az4qu3yjwjl3l6ntqdx" // TODO: helper to change admin
)

func init() {
	identityRegistry = identity.NewIdentityRegistry(admin)
	identityRegistry.Identify(admin)
}

// Returns the identityRegistry. Feels janky and wrong. Circle back
func Registry() *identity.IdentityRegistry { return identityRegistry }

// Returns Citizen Identity registration status for address
func Citizenship(account_ std.Address) bool { return identityRegistry.Identified(account_) }

// Registers an Citizen Identity to address
func Naturalize() bool {
	_caller := std.GetOrigCaller()
	return identityRegistry.Identify(_caller)
}
	


