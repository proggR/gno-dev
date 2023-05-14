package reg

import (
	"std"
	"strings"

	"gno.land/p/demo/registrar"
	"gno.land/p/demo/ufmt"
)

var (
	registry   *registrar.Registrar
	admin std.Address = "g138j0um48nm4ppcz0tr6az4qu3yjwjl3l6ntqdx" // TODO: helper to change admin
)

func init() {
	registry = registrar.Init()
}

func Register(name string, dest string) bool {
	return registry.Register(name, dest)
}

func Resolve(name string) string {
	return registry.Resolve(name)
}

func Render(path string) string {
	parts := strings.Split(path, "/")
	c := len(parts)

	switch {
	case path == "":
		return registry.RenderHome()
	case c == 2 && parts[0] == "resolve":
		dest := registry.Resolve(parts[1])
		return ufmt.Sprintf("%s\n", dest)
	default:
		return "404\n"
	}
}

func assertIsAdmin(address std.Address) {
	if address != admin {
		panic("restricted access")
	}
}
