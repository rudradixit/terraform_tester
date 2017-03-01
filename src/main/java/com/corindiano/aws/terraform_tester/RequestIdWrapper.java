package com.corindiano.aws.terraform_tester;

import com.google.gson.Gson;

public class RequestIdWrapper {
    private String requestId;

    public RequestIdWrapper() {}

    public RequestIdWrapper(String requestId) {
        this.requestId = requestId;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    @Override
    public String toString() {
        return new Gson().toJson(this);
    }
}