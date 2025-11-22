import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_logging_service.dart';
import 'dart:async';

/// Wrapper around SupabaseClient that logs all API calls for test generation
/// All functionality is delegated to the wrapped client - only logging is added
class LoggedSupabaseClient {
  final SupabaseClient _client;
  final ApiLoggingService _loggingService = ApiLoggingService();

  LoggedSupabaseClient(this._client);

  /// Get the wrapped client (for direct access if needed)
  SupabaseClient get client => _client;

  /// Wrapped auth object that logs auth calls
  LoggedGoAuthClient get auth => LoggedGoAuthClient(_client.auth, _loggingService);

  /// Wrapped rpc method that logs RPC calls
  LoggedPostgrestFilterBuilder rpc(String fn, {Map<String, dynamic>? params}) {
    return LoggedPostgrestFilterBuilder(
      _client.rpc(fn, params: params),
      fn,
      params ?? {},
      _loggingService,
    );
  }

  // Delegate all other properties and methods to the wrapped client
  PostgrestClient get rest => _client.rest;
  RealtimeClient get realtime => _client.realtime;
  dynamic get storage => _client.storage;
  FunctionsClient get functions => _client.functions;
  String get supabaseUrl => _client.supabaseUrl;
  String get supabaseKey => _client.supabaseKey;

  // Delegate from() method for table queries
  dynamic from(String table) => _client.from(table);
}

/// Wrapper around auth client that logs auth calls
class LoggedGoAuthClient {
  final dynamic _auth;
  final ApiLoggingService _loggingService;

  LoggedGoAuthClient(this._auth, this._loggingService);

  /// Get current user (no logging needed for getters)
  User? get currentUser => _auth.currentUser;

  /// Get current session (no logging needed for getters)
  Session? get currentSession => _auth.currentSession;

  /// Sign in with password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      _loggingService.logApiCall(
        type: 'auth',
        method: 'signInWithPassword',
        params: {'email': email, 'password': '***'}, // Don't log password
        success: response.user != null,
        response: response.user != null ? {'user_id': response.user?.id, 'email': response.user?.email} : null,
      );
      return response;
    } catch (e) {
      _loggingService.logApiCall(
        type: 'auth',
        method: 'signInWithPassword',
        params: {'email': email, 'password': '***'},
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? emailRedirectTo,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: emailRedirectTo,
        data: data,
      );
      _loggingService.logApiCall(
        type: 'auth',
        method: 'signUp',
        params: {'email': email, 'password': '***', 'emailRedirectTo': emailRedirectTo},
        success: response.user != null,
        response: response.user != null ? {'user_id': response.user?.id, 'email': response.user?.email} : null,
      );
      return response;
    } catch (e) {
      _loggingService.logApiCall(
        type: 'auth',
        method: 'signUp',
        params: {'email': email, 'password': '***', 'emailRedirectTo': emailRedirectTo},
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _loggingService.logApiCall(
        type: 'auth',
        method: 'signOut',
        params: {},
        success: true,
      );
    } catch (e) {
      _loggingService.logApiCall(
        type: 'auth',
        method: 'signOut',
        params: {},
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Reset password for email
  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
  }) async {
    try {
      await _auth.resetPasswordForEmail(email, redirectTo: redirectTo);
      _loggingService.logApiCall(
        type: 'auth',
        method: 'resetPasswordForEmail',
        params: {'email': email, 'redirectTo': redirectTo},
        success: true,
      );
    } catch (e) {
      _loggingService.logApiCall(
        type: 'auth',
        method: 'resetPasswordForEmail',
        params: {'email': email, 'redirectTo': redirectTo},
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update user
  Future<AuthResponse> updateUser(UserAttributes attributes) async {
    try {
      final response = await _auth.updateUser(attributes);
      final params = <String, dynamic>{};
      if (attributes.password != null) params['password'] = '***';
      if (attributes.email != null) params['email'] = attributes.email;
      if (attributes.data != null) params['data'] = attributes.data;

      _loggingService.logApiCall(
        type: 'auth',
        method: 'updateUser',
        params: params,
        success: response.user != null,
        response: response.user != null ? {'user_id': response.user?.id} : null,
      );
      return response;
    } catch (e) {
      final params = <String, dynamic>{};
      if (attributes.password != null) params['password'] = '***';
      if (attributes.email != null) params['email'] = attributes.email;

      _loggingService.logApiCall(
        type: 'auth',
        method: 'updateUser',
        params: params,
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign in with OTP
  Future<void> signInWithOtp({
    required String email,
    String? emailRedirectTo,
    bool? shouldCreateUser,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _auth.signInWithOtp(
        email: email,
        emailRedirectTo: emailRedirectTo,
        shouldCreateUser: shouldCreateUser,
        data: data,
      );
      _loggingService.logApiCall(
        type: 'auth',
        method: 'signInWithOtp',
        params: {'email': email, 'emailRedirectTo': emailRedirectTo, 'shouldCreateUser': shouldCreateUser},
        success: true,
      );
    } catch (e) {
      _loggingService.logApiCall(
        type: 'auth',
        method: 'signInWithOtp',
        params: {'email': email, 'emailRedirectTo': emailRedirectTo, 'shouldCreateUser': shouldCreateUser},
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Get session from URL
  Future<AuthSessionUrlResponse> getSessionFromUrl(Uri uri, {bool storeSession = false}) async {
    try {
      final response = await _auth.getSessionFromUrl(uri, storeSession: storeSession);
      _loggingService.logApiCall(
        type: 'auth',
        method: 'getSessionFromUrl',
        params: {'uri': uri.toString(), 'storeSession': storeSession},
        success: response.session != null,
        response: response.session != null ? {'user_id': response.session?.user.id} : null,
      );
      return response;
    } catch (e) {
      _loggingService.logApiCall(
        type: 'auth',
        method: 'getSessionFromUrl',
        params: {'uri': uri.toString(), 'storeSession': storeSession},
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Delegate auth state changes
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;
}

/// Wrapper around PostgrestFilterBuilder that logs RPC calls when executed
class LoggedPostgrestFilterBuilder implements Future<dynamic> {
  final PostgrestFilterBuilder _builder;
  final String _fn;
  final Map<String, dynamic> _params;
  final ApiLoggingService _loggingService;
  Future<dynamic>? _cachedFuture;

  LoggedPostgrestFilterBuilder(
    this._builder,
    this._fn,
    this._params,
    this._loggingService,
  );

  /// Make it awaitable - when awaited, it executes and logs
  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic value) onValue, {
    Function? onError,
  }) {
    _cachedFuture ??= _executeAndLog();
    return _cachedFuture!.then(onValue, onError: onError);
  }

  Future<dynamic> _executeAndLog() async {
    try {
      final response = await _builder.execute();
      final success = response.status >= 200 && response.status < 300;

      _loggingService.logApiCall(
        type: 'rpc',
        method: _fn,
        params: _params,
        success: success,
        response: response.data,
        error: success ? null : 'HTTP ${response.status}',
      );

      return response.data;
    } catch (e) {
      _loggingService.logApiCall(
        type: 'rpc',
        method: _fn,
        params: _params,
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  @override
  Stream<dynamic> asStream() {
    _cachedFuture ??= _executeAndLog();
    return _cachedFuture!.asStream();
  }

  @override
  Future<dynamic> catchError(Function onError, {bool Function(Object)? test}) {
    _cachedFuture ??= _executeAndLog();
    return _cachedFuture!.catchError(onError, test: test);
  }

  @override
  Future<dynamic> timeout(Duration timeLimit, {FutureOr<dynamic> Function()? onTimeout}) {
    _cachedFuture ??= _executeAndLog();
    return _cachedFuture!.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<dynamic> whenComplete(FutureOr<void> Function() action) {
    _cachedFuture ??= _executeAndLog();
    return _cachedFuture!.whenComplete(action);
  }

  /// Execute the RPC call and log it (returns PostgrestResponse)
  Future<PostgrestResponse> execute() async {
    final response = await _builder.execute();
    final success = response.status >= 200 && response.status < 300;

    _loggingService.logApiCall(
      type: 'rpc',
      method: _fn,
      params: _params,
      success: success,
      response: response.data,
      error: success ? null : 'HTTP ${response.status}',
    );

    return response;
  }

  // Delegate select and other filter methods
  // Note: select() on RPC calls returns PostgrestTransformBuilder, not PostgrestFilterBuilder
  // So we wrap it to ensure logging when single() or maybeSingle() is called
  dynamic select([String? columns]) {
    final transformBuilder = columns != null ? _builder.select(columns) : _builder.select();
    return LoggedPostgrestTransformBuilder(
      transformBuilder,
      _fn,
      _params,
      _loggingService,
    );
  }

  // Delegate other transform methods - these should not be called directly on RPC
  // but if they are, we need to execute and log
  dynamic single() {
    _cachedFuture ??= _executeAndLog();
    return _cachedFuture!.then((data) {
      if (data is List && data.isNotEmpty) {
        return data.first;
      }
      return data;
    });
  }

  dynamic maybeSingle() {
    _cachedFuture ??= _executeAndLog();
    return _cachedFuture!.then((data) {
      if (data is List) {
        return data.isEmpty ? null : data.first;
      }
      return data;
    });
  }
}

/// Wrapper around PostgrestTransformBuilder that logs RPC calls when single() or maybeSingle() is called
class LoggedPostgrestTransformBuilder {
  final dynamic _transformBuilder; // PostgrestTransformBuilder
  final String _fn;
  final Map<String, dynamic> _params;
  final ApiLoggingService _loggingService;

  LoggedPostgrestTransformBuilder(
    this._transformBuilder,
    this._fn,
    this._params,
    this._loggingService,
  );

  /// Execute and log when single() is called
  Future<dynamic> single() async {
    try {
      // Call the underlying transform builder's single() method
      final data = await _transformBuilder.single();

      // Log the successful call
      _loggingService.logApiCall(
        type: 'rpc',
        method: _fn,
        params: _params,
        success: true,
        response: data,
      );

      return data;
    } catch (e) {
      // Log the failed call
      _loggingService.logApiCall(
        type: 'rpc',
        method: _fn,
        params: _params,
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Execute and log when maybeSingle() is called
  Future<dynamic> maybeSingle() async {
    try {
      // Call the underlying transform builder's maybeSingle() method
      final data = await _transformBuilder.maybeSingle();

      // Log the successful call
      _loggingService.logApiCall(
        type: 'rpc',
        method: _fn,
        params: _params,
        success: true,
        response: data,
      );

      return data;
    } catch (e) {
      // Log the failed call
      _loggingService.logApiCall(
        type: 'rpc',
        method: _fn,
        params: _params,
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

// Created: 2025-01-15 14:30:00
