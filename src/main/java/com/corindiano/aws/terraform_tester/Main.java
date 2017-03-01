package com.corindiano.aws.terraform_tester;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.UUID;

public class Main implements RequestHandler<String, String> {
    @Override
    public String handleRequest(String s, Context context) {
        final LambdaLogger LOGGER = context.getLogger();

        String uuid = UUID.randomUUID().toString();
        LOGGER.log("Generated UUID: " + uuid);

        return uuid;
    }
}