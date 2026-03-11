import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";

type UserNotificationPayload =
  | {
      type: "WELCOME";
      toEmail: string;
      source: "user-service";
      occurredAt: string;
      data: { fullname: string };
    }
  | {
      type: "USER.LOGIN" | "USER.UPDATE";
      toEmail: string;
      source: "user-service";
      occurredAt: string;
      data: { date: string };
    };

export class SqsNotificationService {
  private readonly queueUrl = process.env.NOTIFICATION_QUEUE_URL ?? "";
  private readonly sqsClient = new SQSClient({});

  async send(payload: UserNotificationPayload): Promise<void> {
    if (!this.queueUrl) {
      console.warn(
        "NOTIFICATION_QUEUE_URL is not configured. Notification skipped."
      );
      return;
    }

    await this.sqsClient.send(
      new SendMessageCommand({
        QueueUrl: this.queueUrl,
        MessageBody: JSON.stringify(payload),
      })
    );
  }
}