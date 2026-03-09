import { MiddlewareObj } from "@middy/core";
import { APIGatewayEvent, APIGatewayProxyResult } from "aws-lambda";
import createHttpError from "http-errors";
import joi from "joi";
export const jsonSchemaMiddleware = (
  schema: joi.Schema,
): MiddlewareObj<APIGatewayEvent, APIGatewayProxyResult> => {
  return {
    before(request) {
      const body =
        typeof request.event.body === "string"
          ? JSON.parse(request.event.body)
          : request.event.body;

      const { error } = schema.validate(body || {});

      if (error) {
        throw new createHttpError.BadRequest(
          "Validation Error: " + error.details.map((d) => d.message).join(", "),
        );
      }
    },
  };
};
