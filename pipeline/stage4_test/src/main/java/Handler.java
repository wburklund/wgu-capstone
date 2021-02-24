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

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.s3.S3Client;

import java.util.Map;

public class Handler implements RequestHandler<Object, String>{
    @Override
    public String handleRequest(Object event, Context context)
    {
        final double accuracy_threshold = 0.8;

        var testRunner = new TestRunner(
                DynamoDbClient.create(),
                S3Client.create(),
                System.getenv("metadatabaseTable"),
                System.getenv("sourceBucket"),
                System.getenv("predictionFileKey"),
                System.getenv("modelFileKey"),
                System.getenv("destinationBucket"));

        double accuracy = testRunner.Run(accuracy_threshold);
        double accuracyPercent = accuracy * 100;

        if (accuracy > accuracy_threshold) {
            return String.format("Testing successful. Model accuracy = %.2f%%", accuracyPercent);
        } else {
            return String.format("Model failed testing! Model accuracy = %.2f%%", accuracyPercent);
        }
    }
}