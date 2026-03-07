import middy from "@middy/core";
import httpErrorHandler from "@middy/http-error-handler";
import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import { userSchema } from "../schema/user.schema";

const processRequest = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  return {
    statusCode: 201,
    body: JSON.stringify({
      message: "Usuario recibido correctamente",
      data: event.body,
    }),
  };
};

export const handler = middy(processRequest)
  .use(httpErrorHandler())
  .use(jsonSchemaMiddleware(userSchema));
