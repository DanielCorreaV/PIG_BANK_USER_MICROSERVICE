import middy from "@middy/core";
import httpJsonBodyParser from "@middy/http-json-body-parser";
import { APIGatewayProxyResult } from "aws-lambda";
import createHttpError from "http-errors";
import { UpdateProfileUseCase } from "../../application/user/update-user.useCase";
import { DynamoUserRepository } from "../database/dynamo-user.repository";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import { SqsNotificationService } from "../notifications/sqs-notification.service";
import { UpdateUserSchema } from "../schema/update-user.schema";
import { corsHeaders } from "../http/cors";
import { httpErrorWithCors } from "../http/http-error-with-cors";

const updateProcess = async (event: any): Promise<APIGatewayProxyResult> => {
  const repository = new DynamoUserRepository();
  const useCase = new UpdateProfileUseCase(repository);
  const notificationService = new SqsNotificationService();

  const uuid = event.pathParameters?.user_id;
  if (!uuid) throw new createHttpError.BadRequest("User ID is required");

  const existingUser = await repository.findById(uuid);
  if (!existingUser) throw new createHttpError.NotFound("User not found");

  await useCase.execute(uuid, event.body);

  try {
    await notificationService.send({
      type: "USER.UPDATE",
      toEmail: existingUser.email,
      source: "user-service",
      occurredAt: new Date().toISOString(),
      data: {
        date: new Date().toISOString(),
      },
    });
  } catch (error) {
    console.error("Failed to publish USER.UPDATE notification", error);
  }

  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({ message: "User profile updated successfully" }),
  };
};

export const handler = middy(updateProcess)
  .use(httpJsonBodyParser())
  .use(jsonSchemaMiddleware(UpdateUserSchema))
  .use(httpErrorWithCors());
