import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import { IUser } from "../../domain/entities/user.entity";
import { UserRepository } from "../../domain/repositories/user.repository.interface";

export class DynamoUserRepository implements UserRepository {
  private client = DynamoDBDocumentClient.from(new DynamoDBClient({}));
  private tableName = process.env.USER_TABLE || "user-table";

  async save(user: IUser): Promise<void> {
    const command = new PutCommand({
      TableName: this.tableName,
      Item: user,
    });

    await this.client.send(command);
  }
}
