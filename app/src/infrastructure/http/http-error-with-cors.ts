import { MiddlewareObj } from "@middy/core";
import { APIGatewayProxyResult } from "aws-lambda";
import { corsHeaders } from "./cors";

type HttpLikeError = Error & {
  statusCode?: number;
  status?: number;
  expose?: boolean;
};

export const httpErrorWithCors = (): MiddlewareObj<any, APIGatewayProxyResult> => ({
  onError(request) {
    const error = request.error as HttpLikeError;
    const statusCode = error.statusCode || error.status || 500;
    const message =
      statusCode < 500 || error.expose
        ? error.message
        : "Internal server error";

    console.error("Request failed", error);

    request.response = {
      statusCode,
      headers: corsHeaders,
      body: JSON.stringify({
        message,
        error: message,
      }),
    };
  },
});
