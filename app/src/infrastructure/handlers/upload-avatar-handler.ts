import middy from "@middy/core";
import httpErrorHandler from "@middy/http-error-handler";
import httpJsonBodyParser from "@middy/http-json-body-parser";
import { DynamoUserRepository } from "../database/dynamo-user.repository";
import { UploadAvatarUseCase } from "../../application/user/upload-avatar.useCase";
import { jsonSchemaMiddleware } from "../middleware/json.schema.middleware";
import { uploadAvatarSchema } from "../schema/upload-avatar.schema";

const avatarProcess = async (event: any) => {
  const repository = new DynamoUserRepository();
  const useCase = new UploadAvatarUseCase(repository);

  const uuid = event.pathParameters.user_id;

  const { image, fileType } = event.body;

  const imageUrl = await useCase.execute(uuid, { image, fileType });

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Imagen subida con éxito",
      url: imageUrl,
    }),
  };
};

export const handler = middy(avatarProcess)
  .use(httpJsonBodyParser())
  .use(jsonSchemaMiddleware(uploadAvatarSchema))
  .use(httpErrorHandler());
