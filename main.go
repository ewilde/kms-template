package main

import (
	"os"
	"strings"

	"github.com/ewilde/kms-template/internal/pkg/kms"
)

func main() {
	os.Exit(realMain())
}

func realMain() int {
	log := kms.Logger()
	keys, ok := os.LookupEnv("SECRETS")
	if !ok {
		log.Errorf("Please specify SECRETS environment variable")
	}


	w := kms.NewFileWriter()
	w.CreateSecrets(strings.Split(keys, ","))
	return 0
}
