import { User } from "../user.model";

export class LoginResult {
    public user: User;
    public token: string;
    public permissions: Array<string>;
}