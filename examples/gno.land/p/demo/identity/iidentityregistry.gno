package identity

import (
	"std"
)

type IIdentityRegistry interface {	
    // Registers an Identity to address
	Identify(address_ std.Address) bool
	
	// Returns Identity registration status for address
	Identified(address_ std.Address) bool
}


// Emitted when `identity` successfully calls `Identify`.
type AccountIdentified struct {
	identity  std.Address
}


