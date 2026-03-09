import httpErrorHandler from "@middy/http-error-handler";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import middy from "@middy/core";
import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { loginUserSchema } from "../schema/login-user.schema";
import { DynamoUserRepository } from "../database/dynamo-user.repository";
import { LoginUserUseCase } from "../../application/user/login-user.useCase";
import httpJsonBodyParser from "@middy/http-json-body-parser";

const loginProcess = async (event: any): Promise<APIGatewayProxyResult> => {
  const repository = new DynamoUserRepository();
  const useCase = new LoginUserUseCase(repository);

  const { email, password } = event.body;

  const token = await useCase.execute(email, password);

  return {
    statusCode: 200,
    body: JSON.stringify({ token }),
  };
};

export const handler = middy(loginProcess)
  .use(httpJsonBodyParser())
  .use(jsonSchemaMiddleware(loginUserSchema))
  .use(httpErrorHandler());
