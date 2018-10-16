package kms

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	"os"
	"testing"
)

var testSecrets = map[string]string {
		"db": "my-database-password",
		"api-key": "b9a2d7b6-0529-46f0-b857-1f489dd3cd06",
}


func TestMain(m *testing.M) {
	log := Logger()
	if err := testPreCheck(); err != nil {
		log.Fatalf("Error initializing test run: %+v", err)
		os.Exit(-1)
	}

	log.Info("Pre-test sweep")
	err := preSweep(); if err != nil {
		log.Errorf("Error executing pre-test sweep. %v", err)
	}

	log.Info("Starting tests")

	code := m.Run()

	log.Info("Stopping tests")

	log.Info("Post-test sweep")
	err = postSweep(); if err != nil {
		log.Errorf("Error executing post-test sweep. %v", err)
	}

	os.Exit(code)
}

func preSweep() error {
	sm := secretsmanager.New(session.Must(session.NewSession()))

	for k, v := range testSecrets {
		_, err := sm.CreateSecret(&secretsmanager.CreateSecretInput{
			Name: aws.String(k),
			SecretString: aws.String(v),
		})

		if err != nil {
			return err
		}
	}

	return nil
}

func postSweep() error {
	sm := secretsmanager.New(session.Must(session.NewSession()))

	for k := range testSecrets {
		_, err := sm.DeleteSecret(&secretsmanager.DeleteSecretInput{
			SecretId: aws.String(k),
			ForceDeleteWithoutRecovery: aws.Bool(true),
		})

		if err != nil {
			rErr, ok := err.(awserr.Error)
			if ok && rErr.Code() == secretsmanager.ErrCodeResourceNotFoundException {
				continue
			}

			return err
		}
	}

	return nil
}

func testPreCheck() error {

	return nil
}
