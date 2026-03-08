import middy from "@middy/core";
import httpErrorHandler from "@middy/http-error-handler";
import httpJsonBodyParser from "@middy/http-json-body-parser";
import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import { UpdateUserSchema } from "../schema/update-user.schema";
import { DynamoUserRepository } from "../database/dynamo-user.repository";
import { UpdateProfileUseCase } from "../../application/user/update-user.useCase";
import createHttpError from "http-errors";

const updateProcess = async (event: any): Promise<APIGatewayProxyResult> => {
  const repository = new DynamoUserRepository();
  const useCase = new UpdateProfileUseCase(repository);

  const uuid = event.pathParameters?.user_id;
  if (!uuid) throw new createHttpError.BadRequest("User ID is required");

  await useCase.execute(uuid, event.body);

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "User profile updated successfully" }),
  };
};

export const handler = middy(updateProcess)
  .use(httpJsonBodyParser())
  .use(jsonSchemaMiddleware(UpdateUserSchema))
  .use(httpErrorHandler());
