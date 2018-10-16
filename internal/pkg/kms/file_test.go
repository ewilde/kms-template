package kms

import (
	"io/ioutil"
	"path"
	"testing"
)

func TestFileWriter_CreateSecrets(t *testing.T) {
	fw := NewFileWriter()
	fw.Path = "/tmp"
	err := fw.CreateSecrets(keys(testSecrets))

	if err != nil {
		t.Error(err)
	}

	dat, err := ioutil.ReadFile(path.Join(fw.Path, "db"))
	if err != nil {
		t.Error(err)
	}

	v := string(dat)
	if string(v) != "my-database-password" {
		t.Errorf("Wanted my-database-password got %s.", string(v))
	}
}

func keys(strings map[string]string) []string {
	var result []string

	for k := range strings {
		result = append(result, k)
	}

	return result
}
