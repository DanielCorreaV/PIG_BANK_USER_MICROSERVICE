import middy from "@middy/core";
import httpErrorHandler from "@middy/http-error-handler";
import { DynamoUserRepository } from "../database/dynamo-user.repository";
import { GetProfileUseCase } from "../../application/user/get-user-profile.useCase";

const getProcess = async (event: any) => {
  const repository = new DynamoUserRepository();
  const useCase = new GetProfileUseCase(repository);

  const uuid = event.pathParameters?.uuid;
  const user = await useCase.execute(uuid);

  return {
    statusCode: 200,
    body: JSON.stringify(user),
  };
};

export const handler = middy(getProcess).use(httpErrorHandler());
