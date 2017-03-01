package com.corindiano.aws.terraform_tester;

import com.google.gson.Gson;

import java.util.Map;

public class Request<D> {
    private D body;
    private String method;
    private String principalId;
    private String stage;
    private Map<String, String> headers;
    private Map<String, String> query;
    private Map<String, String> path;
    private Map<String,String> identity;

    public Request() {}

    public D getBody() {
        return body;
    }

    public void setBody(D body) {
        this.body = body;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public String getPrincipalId() {
        return principalId;
    }

    public void setPrincipalId(String principalId) {
        this.principalId = principalId;
    }

    public String getStage() {
        return stage;
    }

    public void setStage(String stage) {
        this.stage = stage;
    }

    public Map<String, String> getHeaders() {
        return headers;
    }

    public void setHeaders(Map<String, String> headers) {
        this.headers = headers;
    }

    public Map<String, String> getQuery() {
        return query;
    }

    public void setQuery(Map<String, String> query) {
        this.query = query;
    }

    public Map<String, String> getPath() {
        return path;
    }

    public void setPath(Map<String, String> path) {
        this.path = path;
    }

    public Map<String, String> getIdentity() {
        return identity;
    }

    public void setIdentity(Map<String, String> identity) {
        this.identity = identity;
    }

    @Override
    public String toString() {
        return new Gson().toJson(this);
    }
}