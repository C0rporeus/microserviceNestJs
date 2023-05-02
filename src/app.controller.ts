import {
  Controller,
  Headers,
  HttpCode,
  HttpStatus,
  Post,
  BadRequestException,
  Get,
  Body,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';

@Controller()
export class AppController {
  private readonly apiKey = '2f5ae96c-b558-4c7b-a590-a501ae1c3f6c';
  constructor(private readonly authService: AuthService) {}
  @Get('/generate-token')
  async generateToken() {
    const user = { username: 'example_user', userId: 1 };
    const token = await this.authService.generateToken(user);
    return { token };
  }

  @Post('/DevOps')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'))
  async postDevOps(
    @Headers('X-Parse-REST-API-Key') apiKey: string,
    @Body()
    messageData: {
      message: string;
      to: string;
      from: string;
      timeToLifeSec: number;
    },
  ) {
    if (apiKey !== this.apiKey) {
      throw new BadRequestException('ERROR');
    }

    const { message, to, from, timeToLifeSec } = messageData;

    if (!message || !to || !from || !timeToLifeSec) {
      throw new BadRequestException('ERROR');
    }

    return {
      message: `Hello ${to} your message will be send`,
    };
  }
}
