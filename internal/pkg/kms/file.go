package kms

import (
	"fmt"
	"os"
	"path"

	"github.com/Sirupsen/logrus"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
)

type FileWriter struct {
	client *secretsmanager.SecretsManager
	log    *logrus.Logger
	Path   string
}

func NewFileWriter() *FileWriter {
	return &FileWriter{
		client: secretsmanager.New(session.Must(session.NewSession())),
		log:    Logger(),
		Path:   "/run/secrets",
	}
}

func (fw *FileWriter) CreateSecrets(keys []string) error {
	for _, v := range keys {
		err := fw.createSecret(v)
		if err != nil {
			return err
		}
	}

	return nil
}

func (fw *FileWriter) createSecret(v string) error {
	secret, err := fw.client.GetSecretValue(&secretsmanager.GetSecretValueInput{
		SecretId: aws.String(v),
	})

	if err != nil {
		return fmt.Errorf("error retreiving secret: %s. %v", v, err)
	}

	fileName := path.Join(fw.Path, v)
	f, err := os.Create(fileName)
	if err != nil {
		return fmt.Errorf("error creating file %s. %v", fileName, err)
	}

	defer f.Close()

	_, err = f.Write([]byte(aws.StringValue(secret.SecretString)))
	if err != nil {
		return fmt.Errorf("error writing to file %s. %v", fileName, err)
	}

	return nil
}
