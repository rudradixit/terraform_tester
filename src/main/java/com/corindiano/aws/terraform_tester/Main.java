package com.corindiano.aws.terraform_tester;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.log4j.Logger;

import java.util.UUID;

public class Main implements RequestHandler<RequestIdWrapper, String> {
    private static final Logger LOGGER = Logger.getLogger(Main.class);

    @Override
    public String handleRequest(RequestIdWrapper input, Context context) {
        String correlationId = RandomStringUtils.randomAlphanumeric(29).toLowerCase();
        LOGGER.info(String.format("[CID=%s] Received input: %s", correlationId, input));

        String uuid = UUID.randomUUID().toString();
        LOGGER.info(String.format("[CID=%s]  Generated UUID: %s", correlationId, uuid));

        return uuid;
    }
}