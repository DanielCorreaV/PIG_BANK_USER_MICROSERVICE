import middy from "@middy/core";
import { DynamoUserRepository } from "../database/dynamo-user.repository";
import { GetProfileUseCase } from "../../application/user/get-user-profile.useCase";
import { corsHeaders } from "../http/cors";
import { httpErrorWithCors } from "../http/http-error-with-cors";

const getProcess = async (event: any) => {
  const repository = new DynamoUserRepository();
  const useCase = new GetProfileUseCase(repository);

  const uuid = event.pathParameters?.user_id;
  const user = await useCase.execute(uuid);

  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify(user),
  };
};

export const handler = middy(getProcess).use(httpErrorWithCors());
