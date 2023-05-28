package dao

import (
	"std"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/identity"		
)

type DAORegistry struct {	
	admin std.Address
    daos avl.Tree
}

// Forms a new DAO
func (dr *DAORegistry) Form(address_ std.Address, registry_ *identity.IdentityRegistry) identity.IDString {
	_dao := NewDAO(address_, registry_, dr)
	_identifier := _dao.Identity.Get()
	dr.daos.Set(string(_identifier),_dao)
	
	return _identifier	
}


// Returns authorization for an address to call on behalf of identity
func (dr *DAORegistry) Authed(identifier_ identity.IDString, orgIdentifier_ identity.IDString ) bool {
	// _identity := ir.Identity(identifier_)
	// return _identity.Account() == account_ 
	return true //TODO implement
}

// Identifies an address as an `Identity`
func (dr *DAORegistry) DAO(identifier_ identity.IDString) *DAO {
	 _dao, _exists := dr.daos.Get(string(identifier_)) 
	 
	if !_exists {
		panic("Identity does not exist")
	}
	
	return _dao.(*DAO)
}
