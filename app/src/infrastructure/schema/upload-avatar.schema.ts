import joi from "joi";
import { IFile } from "../../domain/interfaces/file.interface";

export const uploadAvatarSchema = joi.object<IFile>({
  image: joi.string().required(),
  fileType: joi.string().required(),
});
