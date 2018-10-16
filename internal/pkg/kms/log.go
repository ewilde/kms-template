package kms

import (
	"os"

	"github.com/Sirupsen/logrus"
)

func Logger() *logrus.Logger {
	return logrus.StandardLogger()
}

func init() {
	logrus.SetFormatter(&logrus.TextFormatter{FullTimestamp: true})

	logLevel := os.Getenv("LOGLEVEL")
	if level, err := logrus.ParseLevel(logLevel); err == nil {
		logrus.SetLevel(level)
	}

}
