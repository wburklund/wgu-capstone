import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.s3.S3Client;

import java.util.Map;

public class Handler implements RequestHandler<Map<String,String>, String>{
    @Override
    public String handleRequest(Map<String,String> event, Context context)
    {
        var testRunner = new TestRunner(
                DynamoDbClient.create(),
                S3Client.create(),
                System.getenv("metadatabaseTable"),
                System.getenv("sourceBucket"),
                System.getenv("predictionFileKey"),
                System.getenv("modelFileKey"),
                System.getenv("destinationBucket"));
        try {
            testRunner.Run();
        }
        catch(Exception e) {
            return "Exception: " + e.toString();
        }
        return "Testing successful.";
    }
}