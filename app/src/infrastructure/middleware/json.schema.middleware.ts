import { MiddlewareObj } from "@middy/core";
import { APIGatewayEvent, APIGatewayProxyResult } from "aws-lambda";
import createHttpError from "http-errors";
import joi from "joi";

export const jsonSchemaMiddleware = (
  schema: joi.Schema,
): MiddlewareObj<APIGatewayEvent, APIGatewayProxyResult> => {
  return {
    before(request) {
      const body = JSON.parse(request?.event?.body || "{}");
      const { error } = schema.validate(body);
      if (error)
        throw new createHttpError.BadRequest(
          "All data must be set" + JSON.stringify(error),
        );
      return;
    },
  };
};
