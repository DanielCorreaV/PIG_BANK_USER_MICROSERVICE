import createHttpError from "http-errors";
import { IUser } from "../../domain/entities/user.entity";
import { UserRepository } from "../../domain/repositories/user.repository.interface";

export class GetProfileUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(uuid: string): Promise<IUser> {
    const user = await this.userRepository.findById(uuid);

    if (!user) throw new createHttpError.NotFound("user not found");

    return user;
  }
}
