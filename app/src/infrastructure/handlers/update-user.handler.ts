import middy from "@middy/core";
import httpErrorHandler from "@middy/http-error-handler";
import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import { UpdateUserSchema } from "../schema/update-user.schema";

const updateProcess = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  const userId = event.pathParameters?.user_id;
  const updateData = JSON.parse(event.body!);

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: `Profile ${userId} updated`,
      updatedFields: Object.keys(updateData),
    }),
  };
};

export const handler = middy(updateProcess)
  .use(httpErrorHandler())
  .use(jsonSchemaMiddleware(UpdateUserSchema));
