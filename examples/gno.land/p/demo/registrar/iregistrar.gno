package registrar

import(
	"std"
	"strings"
)	

type IRegistrar interface{
	Register(string,string) bool
	Resolve(string) string
}