import { IFile } from "../../domain/interfaces/file.interface";
import { UserRepository } from "../../domain/repositories/user.repository.interface";

export class UploadAvatarUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(uuid: string, data: IFile): Promise<string> {
    const extension = data.fileType.split("/")[1] || "jpg";
    const fileName = `avatars/${uuid}-${Date.now()}.${extension}`;

    const imageUrl = await this.userRepository.uploadAndSaveAvatar(
      uuid,
      fileName,
      data,
    );

    return imageUrl;
  }
}
