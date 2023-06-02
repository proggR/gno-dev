package commune

import (
	"std"
	"strings"
	"regexp"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/web"
	"gno.land/p/demo/identity"
	"gno.land/p/demo/dao"
	"gno.land/p/demo/ufmt"
)

func CommuneRouter() *web.Router {
	_r := web.NewRouter()
	_r.SetFallback(NotFound)
	_r.AddRoute("",Home)	
	_r.AddRoute("{communeID}/proposal/{proposalID}",ProposalProfile)
	_r.AddRoute("{communeID}",CommuneProfile)
	return _r
}

func Render(path_ string) string {
	// TODO: catch panic on fake routes/add _matched flag up front? trailing/optional?
	// OR: add an AddFallback() called on router init that avoids needing to care?
	_req, _action := router.Resolve(path_)
	return _action(_req).Render()
}

func (d *dao.DAO) Render() string {
	_id := string(d.ID())
	_account := string(d.Identity.Account())
	_res := "# " + _id + "\n\n"
	_res += "* Admin: " + _account + "\n\n"
	return _res
}


func NotFound(req_ *web.Request) *web.Response {
	return req_.Respond("Are ya lost traveller?", web.Stringer)
}

const viewCommune string = 
`# {communeID}
  
Admin: {admin}

Link: {link}

List: 
  {list}


Link List: 

  {linkList}`

const viewProposal string = 
`# {communeID}

Admin: {admin}

Proposal: {proposalID}

State: {proposalState}

Result: {proposalResult}`	


func Home(req_ *web.Request) *web.Response {
	return req_.Respond("You are home", web.Stringer)
}

// for testing: ogreg1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5
func CommuneProfile(req_ *web.Request) *web.Response {
	_communeStr := req_.Value("communeID")
	_communeID := identity.IDString(_communeStr)
	_exists := daoRegistry.Exists(_communeID)
	if !_exists {
		_res := ufmt.Sprintf("You are on commune: %s. Does not exist.",_communeStr)
		return req_.Respond(_res, web.Stringer)
	}

	_kv := web.NewKV()	
	_d := daoRegistry.DAO(_communeID)
	
	_list := []string{"one","three","two","apple"}
	_link := web.NewLink("google","https://google.com")
	_links := []*web.Link{_link,_link,_link}


	// return req_.Respond(_d, web.Selfer)
	_kv.Add("communeID", _communeID)
	_kv.Add("admin",string(_d.Identity.Account()))
	_kv.Add("link",_link)
	_kv.Add("list",_list)
	_kv.Add("linkList",_links)

	_renderers := avl.Tree{}
	_renderers.Set("link",web.Linker)
	_renderers.Set("list",web.Lister)
	_renderers.Set("linkList",web.LinkLister)

	_template := web.NewTemplate(viewCommune, _kv.Keys(), _kv.Values(), _renderers)	

	return req_.Respond(_template, web.Templater)
}

func ProposalProfile(req_ *web.Request) *web.Response {
	_communeStr := req_.Value("communeID")
	_proposalStr := req_.Value("proposalID")
	_communeID := identity.IDString(_communeStr)
	_propID := web.StrUI64(_proposalStr)

	_exists := daoRegistry.Exists(_communeID)
	if !_exists {
		_res := ufmt.Sprintf("You are on commune: %s. Does not exist.",_communeStr)
		return req_.Respond(_res, web.Stringer)
	}

	_kv := web.NewKV()	
	_d := daoRegistry.DAO(_communeID)
	_p := _d.ProposalAtIndex(_propID) //panics if invalid so no need to handle
	_r := _p.Result()
	_rStr := "UNDECIDED"
	if _r == 1 {
		_rStr = "YAY"
	} else if _r == -1 {
		_rStr = "NAY"
	}


	_kv.Add("communeID", _communeID)
	_kv.Add("admin",string(_d.Identity.Account()))
	_kv.Add("proposalID",_proposalStr)
	_kv.Add("proposalState",string(_p.State()))
	_kv.Add("proposalResult",_rStr)
	_template := web.NewTemplate(viewProposal, _kv.Keys(), _kv.Values(), avl.Tree{})	

	return req_.Respond(_template, web.Templater)

	// _res := ufmt.Sprintf("You are on commune: %s; proposal: %s", _communeID, _proposalID)
	// return req_.Respond(_res, web.Stringer)
}