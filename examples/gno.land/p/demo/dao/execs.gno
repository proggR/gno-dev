package dao

import (
	"std"
	"math"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/identity"		
)

// EXECUTABLE TOYING

type SubjectParser func(Callable) string
type ValueParser func(Valued) []interface{}
// type ExecutableParser func(SubjectParser, interface{}, ValueParser, interface{}) bool

type Callable interface {
	Call(execIdx_ uint64, values_ []interface{}) bool
	Subject() string
}

type Valued interface {
	Values() []interface{}
}

type PS struct {
	dao  *DAO
	subject interface{}
}

type PV struct {
	values []interface{}
}

func (s *PS) Subject() string { return string(s.subject)}

func (s *PS) DAO() *DAO { return s.dao}

func (v *PV) Values() []interface{} { return v.values }

type SelfSubject struct {
	PS
}


type SelfValue struct {
	PV
}

func (s *SelfSubject) Call(execIdx_ uint64, values_ []interface{}) bool {
	_subject := string(s.subject)
	return s.DAO().Call(execIdx_, _subject, values_)	 
}

func SelfSubjectParser(subject_ Callable) string {
	return subject_.Subject()
}

func SelfValueParser(values_ Valued) []interface{} {
	return values_.Values()	
}
