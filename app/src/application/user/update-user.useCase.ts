import createHttpError from "http-errors";
import { IUpdateUser } from "../../domain/interfaces/update-user.interface";
import { UserRepository } from "../../domain/repositories/user.repository.interface";

export class UpdateProfileUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(uuid: string, dataToUpdate: IUpdateUser): Promise<void> {
    // El caso de uso solo dice que solo el address y el phone por eso lo dejo asi no mas XD,
    // no me pagan lo suficiente para esto (no me pagan)
    const exist = this.userRepository.findById(uuid);
    if (!exist) throw new createHttpError.NotFound("User not found");
    await this.userRepository.update(uuid, dataToUpdate);
  }
}
