import middy from "@middy/core";
import httpErrorHandler from "@middy/http-error-handler";
import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import { registerUserSchema } from "../schema/register-user.schema";
import { DynamoUserRepository } from "../database/dynamo-user.repository";
import { RegisterUserUseCase } from "../../application/user/register-user.useCase";
import httpJsonBodyParser from "@middy/http-json-body-parser";

const registerProcess = async (event: any): Promise<APIGatewayProxyResult> => {
  const repository = new DynamoUserRepository();
  const useCase = new RegisterUserUseCase(repository);

  const user = await useCase.execute(event.body);

  return {
    statusCode: 201,
    body: JSON.stringify({
      message: "User registered successfully",
      uuid: user.uuid,
    }),
  };
};

export const handler = middy(registerProcess)
  .use(httpJsonBodyParser())
  .use(jsonSchemaMiddleware(registerUserSchema))
  .use(httpErrorHandler());
