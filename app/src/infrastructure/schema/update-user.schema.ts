import joi from "joi";
import { IUser } from "../../domain/entities/user.entity";

export const UpdateUserSchema = joi.object<IUser>({
  address: joi.string().required(),
  phone: joi.string().required(),
});
