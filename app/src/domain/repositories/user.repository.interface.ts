import { IUser } from "../entities/user.entity";
import { IFile } from "../interfaces/file.interface";
import { IRegisterUser } from "../interfaces/register-user.interface";
import { IUpdateUser } from "../interfaces/update-user.interface";

export interface UserRepository {
  save(user: IRegisterUser): Promise<IUser>; // Para el Register
  findByEmail(email: string): Promise<IUser | null>; // Para el Login
  update(uuid: string, data: IUpdateUser): Promise<void>; // Para el Phone y Address
  findById(uuid: string): Promise<IUser | null>; // Para Get Profile
  uploadAndSaveAvatar(uuid: string, data: IFile): Promise<string>; // Para el avatar (aang no, ni tampoco el azul, la imagen we)
}
