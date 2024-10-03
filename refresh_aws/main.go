package main

import (
	"context"
	"fmt"
	"os"

	"github.com/1password/onepassword-sdk-go"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/sts"
)

type AdminCreds struct {
	AccessKeyId     string
	SecretAccessKey string
	MfaToken        string
	SerialNumber    string
}

func main() {
	opToken := os.Getenv("OP_TOKEN")
	vaultID := os.Getenv("OP_VAULT_ID")
	adminItemID := os.Getenv("OP_ADMIN_ITEM_ID")
	tempItemID := os.Getenv("OP_TEMP_ITEM_ID")
	region := os.Getenv("AWS_REGION")

	ctx := context.Background()

	opClient, err := onepassword.NewClient(
		ctx,
		onepassword.WithServiceAccountToken(opToken),
		onepassword.WithIntegrationInfo("OP Integration", "v0.0.1"),
	)
	if err != nil {
		panic(err)
	}

	adminItem, err := opClient.Items.Get(ctx, vaultID, adminItemID)
	if err != nil {
		panic(err)
	}

	var adminCreds AdminCreds
	for _, field := range adminItem.Fields {
		switch v := field.Title; v {
		case "one-time password":
			adminCreds.MfaToken = *field.Details.OTP().Code
		case "access_key":
			adminCreds.AccessKeyId = field.Value
		case "secret_access_key":
			adminCreds.SecretAccessKey = field.Value
		case "otp_arn":
			adminCreds.SerialNumber = field.Value
		}
	}

	awsCreds := credentials.NewStaticCredentialsProvider(adminCreds.AccessKeyId, adminCreds.SecretAccessKey, "")
	awsConfig, err := config.LoadDefaultConfig(context.TODO(),
		config.WithCredentialsProvider(awsCreds),
		config.WithRegion(region),
	)
	if err != nil {
		panic(err)
	}

	stsClient := sts.NewFromConfig(awsConfig)
	stsInput := &sts.GetSessionTokenInput{
		SerialNumber: aws.String(adminCreds.SerialNumber),
		TokenCode:    aws.String(adminCreds.MfaToken),
	}

	stsOutput, err := stsClient.GetSessionToken(ctx, stsInput)
	if err != nil {
		panic(err)
	}

	tempItem, err := opClient.Items.Get(ctx, vaultID, tempItemID)
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
