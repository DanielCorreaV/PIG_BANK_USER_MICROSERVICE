import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  PutCommand,
  UpdateCommand,
  GetCommand,
} from "@aws-sdk/lib-dynamodb";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { IUser } from "../../domain/entities/user.entity";
import { UserRepository } from "../../domain/repositories/user.repository.interface";
import { IRegisterUser } from "../../domain/interfaces/register-user.interface";
import { IUpdateUser } from "../../domain/interfaces/update-user.interface";
import { IFile } from "../../domain/interfaces/file.interface";

export class DynamoUserRepository implements UserRepository {
  private readonly dynamoClient = DynamoDBDocumentClient.from(
    new DynamoDBClient({}),
  );
  private readonly s3Client = new S3Client({});

  private readonly tableName = process.env.USER_TABLE || "user-table";
  private readonly bucketName =
    process.env.USER_AVATARS_BUCKET || "my-banking-avatars";

  async save(user: IRegisterUser): Promise<IUser> {
    await this.dynamoClient.send(
      new PutCommand({
        TableName: this.tableName,
        Item: user,
      }),
    );
    return user as IUser;
  }

  async update(uuid: string, data: IUpdateUser): Promise<void> {
    await this.dynamoClient.send(
      new UpdateCommand({
        TableName: this.tableName,
        Key: { uuid: uuid },
        UpdateExpression: "set address = :a, phone = :p",
        ExpressionAttributeValues: {
          ":a": data.address,
          ":p": data.phone,
        },
      }),
    );
  }

  async uploadAndSaveAvatar(uuid: string, data: IFile): Promise<string> {
    // Usamos el objeto IFile (data.name, data.base64, etc.)
    const buffer = Buffer.from(
      data.image.replace(/^data:image\/\w+;base64,/, ""),
      "base64",
    );

    await this.s3Client.send(
      new PutObjectCommand({
        Bucket: this.bucketName,
        Key: data.name,
        Body: buffer,
        ContentType: data.type,
      }),
    );

    const imageUrl = `https://${this.bucketName}.s3.amazonaws.com/${data.name}`;

    await this.dynamoClient.send(
      new UpdateCommand({
        TableName: this.tableName,
        Key: { uuid: uuid },
        UpdateExpression: "set image = :img",
        ExpressionAttributeValues: { ":img": imageUrl },
      }),
    );

    return imageUrl;
  }
}
