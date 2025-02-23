package main

import (
	"context"
	"fmt"
	"os"
	"strings"

	"github.com/1password/onepassword-sdk-go"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/sts"
)

type AwsVars struct {
	AccessKeyId     string
	SecretAccessKey string
	MfaToken        string
	SerialNumber    string
	Region          string
}

type OpVars struct {
	Token      string
	VaultId    string
	TempItemId string
}

func main() {
	var awsVars AwsVars
	var opVars OpVars
	var missingEnvVars []string
	parseEnv("OP_TOKEN", &missingEnvVars, &opVars.Token)
	parseEnv("OP_VAULT_ID", &missingEnvVars, &opVars.VaultId)
	parseEnv("OP_TEMP_ITEM_ID", &missingEnvVars, &opVars.TempItemId)
	parseEnv("ACCESS_KEY_ID", &missingEnvVars, &awsVars.AccessKeyId)
	parseEnv("SECRET_ACCESS_KEY", &missingEnvVars, &awsVars.SecretAccessKey)
	parseEnv("MFA_TOKEN", &missingEnvVars, &awsVars.MfaToken)
	parseEnv("MFA_SERIAL_NUMBER", &missingEnvVars, &awsVars.SerialNumber)
	parseEnv("AWS_REGION", &missingEnvVars, &awsVars.Region)

	if len(missingEnvVars) > 0 {
		fmt.Println(
			"ERROR: Missing the following env vars:\n" +
				strings.Join(missingEnvVars, "\n") +
				"\n",
		)
		os.Exit(1)
	}

	ctx := context.Background()

	opClient, err := onepassword.NewClient(
		ctx,
		onepassword.WithServiceAccountToken(opVars.Token),
		onepassword.WithIntegrationInfo("OP Integration", "v0.0.1"),
	)
	if err != nil {
		panic(err)
	}

	awsCreds := credentials.NewStaticCredentialsProvider(awsVars.AccessKeyId, awsVars.SecretAccessKey, "")
	awsConfig, err := config.LoadDefaultConfig(context.TODO(),
		config.WithCredentialsProvider(awsCreds),
		config.WithRegion(awsVars.Region),
	)
	if err != nil {
		panic(err)
	}

	stsClient := sts.NewFromConfig(awsConfig)
	stsInput := &sts.GetSessionTokenInput{
		SerialNumber: aws.String(awsVars.SerialNumber),
		TokenCode:    aws.String(awsVars.MfaToken),
	}

	stsOutput, err := stsClient.GetSessionToken(ctx, stsInput)
	if err != nil {
		panic(err)
	}

	tempItem, err := opClient.Items.Get(ctx, opVars.VaultId, opVars.TempItemId)
	if err != nil {
		panic(err)
	}

	for idx, field := range tempItem.Fields {
		switch v := field.Title; v {
		case "access_key":
			tempItem.Fields[idx].Value = *stsOutput.Credentials.AccessKeyId
		case "secret_access_key":
			tempItem.Fields[idx].Value = *stsOutput.Credentials.SecretAccessKey
		case "session_token":
			tempItem.Fields[idx].Value = *stsOutput.Credentials.SessionToken
		case "expiration":
			tempItem.Fields[idx].Value = stsOutput.Credentials.Expiration.String()
		}
	}

	_, err = opClient.Items.Put(ctx, tempItem)
	if err != nil {
		panic(err)
	}

	fmt.Println("AWS credentials have been refreshed")
}

func parseEnv(envVar string, missingList *[]string, field *string) {
	value := os.Getenv(envVar)
	if value == "" {
		*missingList = append(*missingList, envVar)
	} else {
		*field = value
	}
}
