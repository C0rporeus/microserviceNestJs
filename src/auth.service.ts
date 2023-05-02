import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(private readonly jwtService: JwtService) {}

  async generateToken(user: any): Promise<string> {
    const payload = { username: user.username, sub: user.userId };
    return this.jwtService.sign(payload);
  }
}
