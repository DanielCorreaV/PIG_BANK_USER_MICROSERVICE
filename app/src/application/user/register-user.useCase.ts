import { IUser } from "../../domain/entities/user.entity";
import { IRegisterUser } from "../../domain/interfaces/register-user.interface";
import { UserRepository } from "../../domain/repositories/user.repository.interface";

export class RegisterUserUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(userData: IRegisterUser): Promise<IUser> {
    const exists = await this.userRepository.findByEmail(userData.email);
    if (exists) throw new Error("User already exists");

    return await this.userRepository.save(userData);
  }
}
