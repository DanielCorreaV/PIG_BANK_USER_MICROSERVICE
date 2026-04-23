import middy from "@middy/core";
import { APIGatewayProxyResult } from "aws-lambda";
import httpJsonBodyParser from "@middy/http-json-body-parser";
import { RegisterUserUseCase } from "../../application/user/register-user.useCase";
import { DynamoUserRepository } from "../database/dynamo-user.repository";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import { SqsNotificationService } from "../notifications/sqs-notification.service";
import { registerUserSchema } from "../schema/register-user.schema";
import { corsHeaders } from "../http/cors";
import { httpErrorWithCors } from "../http/http-error-with-cors";

const registerProcess = async (event: any): Promise<APIGatewayProxyResult> => {
  const repository = new DynamoUserRepository();
  const useCase = new RegisterUserUseCase(repository);
  const notificationService = new SqsNotificationService();

  const user = await useCase.execute(event.body);

  try {
    await notificationService.send({
      type: "WELCOME",
      toEmail: user.email,
      source: "user-service",
      occurredAt: new Date().toISOString(),
      data: {
        fullname: `${user.name} ${user.lastName}`.trim(),
      },
    });
  } catch (error) {
    console.error("Failed to publish WELCOME notification", error);
  }

  return {
    statusCode: 201,
    headers: corsHeaders,
    body: JSON.stringify({
      message: "User registered successfully",
      uuid: user.uuid,
      user,
    }),
  };
};

export const handler = middy(registerProcess)
  .use(httpJsonBodyParser())
  .use(jsonSchemaMiddleware(registerUserSchema))
  .use(httpErrorWithCors());
