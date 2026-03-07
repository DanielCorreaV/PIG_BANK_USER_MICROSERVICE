export interface IUser {
  uuid: string;
  name: string;
  lastName: string;
  email: string;
  documentNumber: string;
  password?: string;
  avatarUrl?: string;
}
