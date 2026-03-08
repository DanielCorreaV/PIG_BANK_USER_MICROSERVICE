import createHttpError from "http-errors";
import { IUser } from "../../domain/entities/user.entity";
import { IRegisterUser } from "../../domain/interfaces/register-user.interface";
import { UserRepository } from "../../domain/repositories/user.repository.interface";

export class RegisterUserUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(userData: IRegisterUser): Promise<IUser> {
    const exists = await this.userRepository.findByEmail(userData.email);
    if (exists) throw new createHttpError.Conflict("User already Exist");

    return await this.userRepository.save(userData);
  }
}
