import httpErrorHandler from "@middy/http-error-handler";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import middy from "@middy/core";
import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { loginUserSchema } from "../schema/login-user.schema";

const loginProcess = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  const credentials = JSON.parse(event.body!);

  return {
    statusCode: 200,
    body: JSON.stringify({
      token: "ey...tu-jwt-aqui",
    }),
  };
};

export const handler = middy(loginProcess)
  .use(httpErrorHandler())
  .use(jsonSchemaMiddleware(loginUserSchema));
