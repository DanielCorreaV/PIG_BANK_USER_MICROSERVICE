import httpErrorHandler from "@middy/http-error-handler";
import { UserRepository } from "../../domain/repositories/user.repository.interface";
import createHttpError from "http-errors";
import * as jwt from "jsonwebtoken";

export class LoginUserUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(email: string, password: string): Promise<string> {
    const user = await this.userRepository.findByEmail(email);
    if (!user) throw new createHttpError.Unauthorized("User not found");

    const secretKey = await this.userRepository.getSecret(
      "banking/password-secret",
    );

    if (user.password !== password) {
      throw new createHttpError.Unauthorized("Email or Password is incorrect");
    }

    const token = jwt.sign({ uuid: user.uuid, email: user.email }, secretKey, {
      expiresIn: "1h",
    });

    return token;
  }
}
