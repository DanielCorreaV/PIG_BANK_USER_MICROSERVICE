import middy from "@middy/core";
import httpErrorHandler from "@middy/http-error-handler";
import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import { registerUserSchema } from "../schema/register-user.schema";
// Aquí irán tus importaciones de UseCase y Repository más adelante

const registerProcess = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  // El body ya viene validado por el middleware
  const userData = JSON.parse(event.body!);

  return {
    statusCode: 201,
    body: JSON.stringify({
      message: "User registered successfully",
      userId: "generado-por-uuid",
    }),
  };
};

export const handler = middy(registerProcess)
  .use(httpErrorHandler())
  .use(jsonSchemaMiddleware(registerUserSchema));
