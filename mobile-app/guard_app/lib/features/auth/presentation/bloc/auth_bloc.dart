import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatusRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String token;

  AuthAuthenticated({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final StorageService storageService;

  AuthBloc({
    required this.apiService,
    required this.storageService,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthCheckStatusRequested>(_onCheckStatus);
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    print('🏗️ AuthBloc._onLogin called with email: ${event.email}');
    emit(AuthLoading());
    
    try {
      print('📞 Calling apiService.login...');
      final response = await apiService.login(event.email, event.password);
      final token = response['token'] as String;
      final userMap = response['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);

      print('💾 Saving auth data...');
      // Save token and user data
      await storageService.saveAuthToken(token);
      await storageService.saveUserData(userMap);
      
      // Set token for future API calls
      apiService.setAuthToken(token);

      print('✅ Login successful, emitting AuthAuthenticated');
      emit(AuthAuthenticated(user: user, token: token));
    } catch (e) {
      print('❌ Login error in AuthBloc: ${e.toString()}');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // Clear stored data
      await storageService.removeAuthToken();
      await storageService.removeUserData();
      
      // Remove token from API service
      apiService.removeAuthToken();

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onCheckStatus(AuthCheckStatusRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final token = storageService.getAuthToken();
      final userData = storageService.getUserData();

      if (token != null && userData != null) {
        // Set token for API calls
        apiService.setAuthToken(token);
        
        try {
          // Verify token is still valid by fetching current user
          final user = await apiService.getCurrentUser();
          emit(AuthAuthenticated(user: user, token: token));
        } catch (e) {
          // Token is invalid, clear stored data
          await storageService.removeAuthToken();
          await storageService.removeUserData();
          apiService.removeAuthToken();
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
