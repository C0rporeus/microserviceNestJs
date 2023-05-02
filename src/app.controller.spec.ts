import { Test, TestingModule } from '@nestjs/testing';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtService } from '@nestjs/jwt';
import { JwtStrategy } from './jwt.strategy';
import { AppController } from './app.controller';

describe('AuthService', () => {
  let authService: AuthService;
  let jwtService: JwtService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: JwtService,
          useValue: {
            sign: jest.fn().mockImplementation(() => 'test_token'),
          },
        },
      ],
    }).compile();

    authService = module.get<AuthService>(AuthService);
    jwtService = module.get<JwtService>(JwtService);
  });

  it('should be defined', () => {
    expect(authService).toBeDefined();
  });

  describe('generateToken', () => {
    it('should return a token', async () => {
      const user = { username: 'example_user', userId: 1 };
      const result = await authService.generateToken(user);

      expect(result).toBe('test_token');
      expect(jwtService.sign).toHaveBeenCalledWith({
        username: user.username,
        sub: user.userId,
      });
    });
  });
});

describe('JwtStrategy', () => {
  let jwtStrategy: JwtStrategy;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [JwtStrategy],
    }).compile();

    jwtStrategy = module.get<JwtStrategy>(JwtStrategy);
  });

  it('should be defined', () => {
    expect(jwtStrategy).toBeDefined();
  });

  describe('validate', () => {
    it('should return payload if it exists', async () => {
      const payload = { username: 'example_user', sub: 1 };
      const result = await jwtStrategy.validate(payload);

      expect(result).toBe(payload);
    });

    it('should throw an UnauthorizedException if no payload', async () => {
      try {
        await jwtStrategy.validate(null);
      } catch (error) {
        expect(error).toBeInstanceOf(UnauthorizedException);
      }
    });
  });
});

describe('AppController', () => {
  let appController: AppController;
  let authService: AuthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [
        {
          provide: AuthService,
          useValue: {
            generateToken: jest.fn().mockImplementation(() => 'test_token'),
          },
        },
      ],
    }).compile();

    appController = module.get<AppController>(AppController);
    authService = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(appController).toBeDefined();
  });

  describe('generateToken', () => {
    it('should return a token', async () => {
      const result = await appController.generateToken();

      expect(result).toEqual({ token: 'test_token' });
      expect(authService.generateToken).toHaveBeenCalled();
    });
  });

  describe('postDevOps', () => {
    const messageData = {
      message: 'test_message',
      to: 'test_to',
      from: 'test_from',
      timeToLifeSec: 123,
    };

    it('should return a success message if apiKey and messageData are valid', async () => {
      const result = await appController.postDevOps(
        '2f5ae96c-b558-4c7b-a590-a501ae1c3f6c',
        messageData,
      );

      expect(result).toEqual({
        message: `Hello ${messageData.to} your message will be send`,
      });
    });

    it('should throw BadRequestException if apiKey is invalid', async () => {
      try {
        await appController.postDevOps('invalid_api_key', messageData);
      } catch (error) {
        expect(error).toBeInstanceOf(BadRequestException);
        expect(error.message).toBe('ERROR');
      }
    });

    it('should throw BadRequestException if messageData is incomplete', async () => {
      const incompleteMessageData = {
        ...messageData,
        message: null,
      };

      try {
        await appController.postDevOps(
          '2f5ae96c-b558-4c7b-a590-a501ae1c3f6c',
          incompleteMessageData,
        );
      } catch (error) {
        expect(error).toBeInstanceOf(BadRequestException);
        expect(error.message).toBe('ERROR');
      }
    });
  });
});