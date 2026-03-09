import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  PutCommand,
  UpdateCommand,
  GetCommand,
  QueryCommand,
} from "@aws-sdk/lib-dynamodb";
import {
  GetSecretValueCommand,
  SecretsManagerClient,
} from "@aws-sdk/client-secrets-manager";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { IUser } from "../../domain/entities/user.entity";
import { UserRepository } from "../../domain/repositories/user.repository.interface";
import { IRegisterUser } from "../../domain/interfaces/register-user.interface";
import { IUpdateUser } from "../../domain/interfaces/update-user.interface";
import { IFile } from "../../domain/interfaces/file.interface";

export class DynamoUserRepository implements UserRepository {
  private readonly dynamoClient = DynamoDBDocumentClient.from(
    new DynamoDBClient({
      region: process.env.region || "us-east-1",
    }),
  );
  private readonly s3Client = new S3Client({});

  private readonly tableName = process.env.USER_TABLE || "user-table";
  private readonly bucketName =
    process.env.USER_AVATARS_BUCKET || "my-banking-avatars";

  async save(user: IUser): Promise<IUser> {
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

  async uploadAndSaveAvatar(
    uuid: string,
    name: string,
    data: IFile,
  ): Promise<string> {
    const buffer = Buffer.from(
      data.image.replace(/^data:image\/\w+;base64,/, ""),
      "base64",
    );

    await this.s3Client.send(
      new PutObjectCommand({
        Bucket: this.bucketName,
        Key: name,
        Body: buffer,
        ContentType: data.fileType,
      }),
    );

    const imageUrl = `https://${this.bucketName}.s3.amazonaws.com/${name}`;

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

  async findById(uuid: string): Promise<IUser | null> {
    const result = await this.dynamoClient.send(
      new GetCommand({
        TableName: this.tableName,
        Key: { uuid: uuid },
      }),
    );

    return (result.Item as IUser) || null;
  }

  async findByEmail(email: string): Promise<IUser | null> {
    const result = await this.dynamoClient.send(
      new QueryCommand({
        TableName: this.tableName,
        IndexName: "EmailIndex",
        KeyConditionExpression: "email = :e",
        ExpressionAttributeValues: {
          ":e": email,
        },
      }),
    );

    if (result.Items && result.Items.length > 0) {
      return result.Items[0] as IUser;
    }

    return null;
  }

  private readonly secretsClient = new SecretsManagerClient({});

  async getSecret(secretName: string): Promise<string> {
    const response = await this.secretsClient.send(
      new GetSecretValueCommand({
        SecretId: secretName,
      }),
    );
    return response.SecretString || "";
  }
}
