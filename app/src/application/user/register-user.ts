import { IUser } from "../../domain/entities/user.entity";
import { UserRepository } from "../../domain/repositories/user.repository.interface";

export class RegisterUserUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(user: IUser): Promise<void> {
    await this.userRepository.save(user);
  }
}
