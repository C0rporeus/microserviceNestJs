import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, ExtractJwt } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromHeader('x-jwt-kwy'),
      ignoreExpiration: false,
      secretOrKey: '1927813982u13jjk12hk31jk',
    });
    console.log('JwtStrategy constructor');
  }

  async validate(payload: any) {
    console.log('Payload', payload);
    if (!payload) {
      console.log('No payload');
      throw new UnauthorizedException();
    }
    return payload;
  }
}
