/*
  WGU Capstone Project
  Copyright (C) 2021 Will Burklund

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package main

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (string, error) {
	sourceBucket := os.Getenv("source_bucket")
	key := os.Getenv("model_key")
	destinationBucket := os.Getenv("destination_bucket")

	apiKey := os.Getenv("api_key")
	refreshUrl := os.Getenv("refresh_url")

	sess, err := session.NewSession()
	svc := s3.New(sess)
	_, err = svc.CopyObject(&s3.CopyObjectInput{Bucket: aws.String(destinationBucket),
		CopySource: aws.String(url.PathEscape(sourceBucket + "/" + key)), Key: aws.String(key)})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to copy item from bucket %q to bucket %q, %v\n", sourceBucket, destinationBucket, err)
		os.Exit(1)
	}

	err = svc.WaitUntilObjectExists(&s3.HeadObjectInput{Bucket: aws.String(destinationBucket), Key: aws.String(key)})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error occurred while waiting for item %q to be copied to bucket %q, %v\n", key, destinationBucket, err)
		os.Exit(1)
	}

	client := &http.Client{}
	req, _ := http.NewRequest("PUT", refreshUrl, nil)
	req.Header.Set("X-API-KEY", apiKey)	
	_, _ := client.Do(req)

	return fmt.Sprintf("Deploy successful."), nil
}

func main() {
	lambda.Start(HandleRequest)
}

