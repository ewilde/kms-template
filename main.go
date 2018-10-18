package main

import (
	"github.com/ewilde/kms-template/internal/pkg/kms"
	"os"
	"os/signal"
	"strings"
	"syscall"
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
	err := w.CreateSecrets(strings.Split(keys, ",")); if err !=nil {
		log.Error(err)
		return 1
	}

	log.Info("Completed templating secrets")
	var gracefulStop = make(chan os.Signal)
	signal.Notify(gracefulStop, syscall.SIGTERM)
	signal.Notify(gracefulStop, syscall.SIGINT)
	_ = <-gracefulStop
	return 0
}
