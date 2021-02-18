import com.opencsv.CSVReader;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.ScanRequest;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.CopyObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;

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

    public void Run() throws Exception {
        var getObjectRequest =
                GetObjectRequest.builder()
                        .bucket(sourceBucket)
                        .key(predictionFileKey)
                        .build();
        var predictionsCsv = s3Client.getObject(getObjectRequest);
        var predictionsReader = new CSVReader(new InputStreamReader(predictionsCsv));

        var labelDictionary = GetLabelDictionary(predictionsReader.readNext());
        var fileLabels = GetFileLabels();

        int totalPredictions = 0;
        double totalScore = 0.0;
        String [] nextLine;
        while ((nextLine = predictionsReader.readNext()) != null)
        {
            String correctLabel = fileLabels.get(nextLine[0]);
            int column = labelDictionary.get(correctLabel);
            totalScore += Double.parseDouble(nextLine[column]);
            totalPredictions += 1;
        }

        double accuracy = totalScore / totalPredictions;

        if (accuracy < 0.8) {
            throw new Exception("Model accuracy of " + accuracy + " was below minimum threshold of 0.8!");
        }

        AcceptModel();
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
