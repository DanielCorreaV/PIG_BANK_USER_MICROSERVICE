import middy from "@middy/core";
import { APIGatewayProxyResult } from "aws-lambda";
import httpJsonBodyParser from "@middy/http-json-body-parser";
import { LoginUserUseCase } from "../../application/user/login-user.useCase";
import { DynamoUserRepository } from "../database/dynamo-user.repository";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import { SqsNotificationService } from "../notifications/sqs-notification.service";
import { loginUserSchema } from "../schema/login-user.schema";
import { corsHeaders } from "../http/cors";
import { httpErrorWithCors } from "../http/http-error-with-cors";

const loginProcess = async (event: any): Promise<APIGatewayProxyResult> => {
  const repository = new DynamoUserRepository();
  const useCase = new LoginUserUseCase(repository);
  const notificationService = new SqsNotificationService();

  const { email, password } = event.body;
  const token = await useCase.execute(email, password);
  const user = await repository.findByEmail(email);

  if (user) {
    try {
      await notificationService.send({
        type: "USER.LOGIN",
        toEmail: user.email,
        source: "user-service",
        occurredAt: new Date().toISOString(),
        data: {
          date: new Date().toISOString(),
        },
      });
    } catch (error) {
      console.error("Failed to publish USER.LOGIN notification", error);
    }
  }

  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({ token, user }),
  };
};

export const handler = middy(loginProcess)
  .use(httpJsonBodyParser())
  .use(jsonSchemaMiddleware(loginUserSchema))
  .use(httpErrorWithCors());
