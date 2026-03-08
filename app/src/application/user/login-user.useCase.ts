import { UserRepository } from "../../domain/repositories/user.repository.interface";

export class LoginUserUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(email: string, password: string): Promise<string> {
    const user = await this.userRepository.findByEmail(email);

    if (!user || user.password !== password) {
      throw new Error("Invalid credentials");
    }

    return "fake-jwt-token-for-" + user.uuid;
  }
}
