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

import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvValidationException;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.ScanRequest;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.CopyObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.Hashtable;

public class TestRunner {
    private final DynamoDbClient ddbClient;
    private final S3Client s3Client;
    private final String metadatabaseTable;
    private final String sourceBucket;
    private final String predictionFileKey;
    private final String modelFileKey;
    private final String destinationBucket;

    public TestRunner(DynamoDbClient ddbClient,
                      S3Client s3Client,
                      String metadatabaseTable,
                      String sourceBucket,
                      String predictionFileKey,
                      String modelFileKey,
                      String destinationBucket) {
        this.ddbClient = ddbClient;
        this.s3Client = s3Client;
        this.metadatabaseTable = metadatabaseTable;
        this.sourceBucket = sourceBucket;
        this.predictionFileKey = predictionFileKey;
        this.modelFileKey = modelFileKey;
        this.destinationBucket = destinationBucket;
    }

    public double Run() {
        var getObjectRequest =
                GetObjectRequest.builder()
                        .bucket(sourceBucket)
                        .key(predictionFileKey)
                        .build();
        var predictionsCsv = s3Client.getObject(getObjectRequest);
        var predictionsReader = new CSVReader(new InputStreamReader(predictionsCsv));

        Dictionary<String, Integer> labelDictionary;
        try {
            labelDictionary = GetLabelDictionary(predictionsReader.readNext());
        } catch (IOException e) {
            throw new RuntimeException("IOException! " + e.toString());
        } catch (CsvValidationException e) {
            throw new RuntimeException("CsvValidationException! " + e.toString());
        }
        var fileLabels = GetFileLabels();

        int totalPredictions = 0;
        double totalScore = 0.0;
        String [] nextLine;
        try {
            while ((nextLine = predictionsReader.readNext()) != null)
            {
                String correctLabel = fileLabels.get(nextLine[0]);
                int column = labelDictionary.get(correctLabel);
                totalScore += Double.parseDouble(nextLine[column]);
                totalPredictions += 1;
            }
        } catch (IOException e) {
            throw new RuntimeException("IOException! " + e.toString());
        } catch (CsvValidationException e) {
            throw new RuntimeException("CsvValidationException! " + e.toString());
        }

        double accuracy = totalScore / totalPredictions;

        if (accuracy < 0.8) {
            throw new RuntimeException("Model accuracy of " + accuracy + " was below minimum threshold of 0.8!");
        }

        try {
            AcceptModel();
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException("UnsupportedEncodingException! " + e.toString());
        }

        return accuracy;
    }

    private Dictionary<String, String> GetFileLabels() {
        var attributeValues = new HashMap<String, AttributeValue>();
        attributeValues.put(":dataSet", AttributeValue.builder().s("Test").build());
        var fileLabels = new Hashtable<String, String>();
        var scanRequest =
                ScanRequest.builder()
                        .tableName(metadatabaseTable)
                        .projectionExpression("Filename, Label")
                        .filterExpression("DataSet = :dataSet")
                        .expressionAttributeValues(attributeValues)
                        .build();
        var scanResult = ddbClient.scan(scanRequest);
        for (var item : scanResult.items()) {
            fileLabels.put(item.get("Filename").s(), item.get("Label").s());
        }
        return fileLabels;
    }

    private Dictionary<String, Integer> GetLabelDictionary(String [] header) {
        var labelDictionary = new Hashtable<String, Integer>();

        for (int i = 1; i < header.length; i++) {
            labelDictionary.put(header[i], i);
        }

        return labelDictionary;
    }

    private void AcceptModel() throws UnsupportedEncodingException {
        var copyRequest =
                CopyObjectRequest.builder()
                        .copySource(URLEncoder.encode(sourceBucket + "/" + modelFileKey, StandardCharsets.UTF_8.toString()))
                        .destinationBucket(destinationBucket)
                        .destinationKey(modelFileKey)
                        .build();
        s3Client.copyObject(copyRequest);
    }
}
