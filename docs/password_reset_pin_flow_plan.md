# Password Reset PIN Flow Implementation Plan

## Overview

Erstatter link-baseret password reset med PIN-baseret flow for bedre sikkerhed. Flowet: Email → PIN-kode → Validering → Password opdatering → Auto login.

## Implementation Steps

### 1. SupabaseService - Nye funktioner (DELVIST IMPLEMENTERET)

**File:** `lib/services/supabase_service_auth.dart`

✅ **FÆRDIG:** `requestPasswordResetPin(String email)` - Implementeret og kalder `auth_request_password_reset_pin` RPC endpoint

**MANGER:**

- `resetPasswordWithPin(String email, String pin, String newPassword)` - Validerer PIN-kode OG opdaterer password med valideret PIN og logger brugeren automatisk ind (ALLE valideringer serverside)

**Note:**

- Alle sikkerhedskrav (rate limiting, PIN udløbstid, one-time use, email validering) håndteres i Supabase funktionerne - Flutter koden kalder kun endpoints og håndterer svarene.
- Alle eksisterende funktioner (`resetPassword()`, `handleResetPasswordFromUrl()`, etc.) beholdes uændret for nem rollback.

### 2. AuthProvider - Nye metoder (DELVIST IMPLEMENTERET)

**File:** `lib/providers/auth_provider.dart`

✅ **FÆRDIG:** `requestPasswordResetPin(String email)` - Implementeret og kalder SupabaseService.requestPasswordResetPin()

**MANGER:**

- `resetPasswordWithPin(String email, String pin, String newPassword)` - Kalder SupabaseService.resetPasswordWithPin() (håndterer al validering serverside)

**Note:** Alle eksisterende metoder (`resetPassword()`, `handleAuthRedirect()`, etc.) beholdes uændret for nem rollback.

### 3. ForgotPasswordForm - Opdateret til PIN flow (FÆRDIG)

**File:** `lib/widgets/auth/forgot_password_form.dart`

✅ **FÆRDIG:**

- Opdateret `_resetPassword()` til at kalde `authNotifier.requestPasswordResetPin()`
- Opdateret success besked til at nævne PIN-kode
- Navigerer til `reset_password` route med email som query parameter efter succes

### 4. ResetPasswordScreen - Modtag email parameter

**File:** `lib/screens/unauthenticated/auth/reset_password.dart`

- Behold eksisterende token/code query parameter logik (for rollback)
- Hent email fra query parameters: `final email = queryParams['email'];`
- Hvis email parameter findes, brug ny `ResetPasswordFormPin` widget
- Hvis token/code parameter findes, brug eksisterende `ResetPasswordForm` widget (gammel flow)
- Opdater backRoutePath til at gå tilbage til forgot_password når email bruges

### 5. ResetPasswordForm - Opret NY widget med to-trins flow

**File:** `lib/widgets/auth/reset_password_form_pin.dart` (NY FIL)

**VIGTIGT:** Opret en NY widget i stedet for at modificere den eksisterende `reset_password_form.dart`. Den gamle widget beholdes for nem rollback.

**Fase 1: PIN Input**

- Tilføj state variabel `_pinVerificationStep` (enum: pinInput, passwordInput)
- Vis PIN input felt først (brug PinCodeTextField ligesom i enter_pincode.dart)
- Valider kun PIN format (6 cifre) på klienten
- Når PIN er indtastet (6 cifre), skift automatisk til password input fase
- Ingen server-side PIN validering på dette tidspunkt - validering sker kun når password opdateres

**Fase 2: Password Input**

- Vis password felter (baseret på eksisterende kode fra reset_password_form.dart)
- Når brugeren klikker "Opdater", kald `resetPasswordWithPin(email, pin, newPassword)`
- `resetPasswordWithPin` validerer ALT serverside (PIN, email match, expiry, etc.) i ét trin
- **Ved fejl:** Vis modal med info om at PIN-kode ikke var korrekt. Når modal lukkes (eller knap klikkes), send brugeren til forgot_password skærmen
- **Ved success:** Vis modal med info om at password nu er ændret og brugeren kan logge ind. Når modal lukkes (eller knap klikkes), send brugeren til login skærmen
- **Ingen auto-login:** Brugeren skal logge ind manuelt efter password reset

**UI Flow:**

- Start med PIN input (centreret, ligesom enter_pincode)
- Når PIN er 6 cifre, skift automatisk til password input fase
- Brug Conditional rendering baseret på `_pinVerificationStep`
- Vis fejlbesked hvis password opdatering fejler (inkl. PIN-relaterede fejl)

**Note:** Den gamle `ResetPasswordForm` widget beholdes uændret i `reset_password_form.dart` for nem rollback.

### 6. Routing - Email parameter

**File:** `lib/core/router/app_router.dart`

- ResetPassword route behøver ikke ændringer (bruger allerede query parameters)
- Sikre at email kan sendes via navigation: `context.go('${RoutePaths.resetPassword}?email=${Uri.encodeComponent(email)}')`

### 7. Modaler - Opret nye modaler

**Files:** `lib/widgets/modals/password_reset_error_modal.dart` (NY) og `lib/widgets/modals/password_reset_success_modal.dart` (NY)

**Password Reset Error Modal:**

- Vis besked om at PIN-kode ikke var korrekt eller udløbet
- Knap der sender brugeren til forgot_password (RoutePaths.forgotPassword)
- Når modal lukkes (back button eller swipe), send også til forgot_password
- Brug samme modal pattern som eksisterende modaler (showModalBottomSheet)

**Password Reset Success Modal:**

- Vis besked om at password nu er ændret og brugeren kan logge ind
- Knap der sender brugeren til login skærmen (RoutePaths.login)
- Når modal lukkes (back button eller swipe), send også til login skærmen
- Brug samme modal pattern som eksisterende modaler (showModalBottomSheet)

### 8. I18n - Nye strings

**Files:** `languages/*.json`

Tilføj nye translation keys:

- `screen_login_forgot_password.pin_code_sent` - "PIN code sent to your email"
- `widget_reset_password.enter_pin_code` - "Enter PIN Code"
- `widget_reset_password.pin_code_validation_failed` - "Invalid or expired PIN code" (bruges ved password update fejl)
- `widget_reset_password.email_required` - "Email is required"
- `widget_reset_password.pin_code_must_be_6_digits` - "PIN code must be 6 digits"
- `widget_reset_password.pin_code_required` - "PIN code must be validated first"
- `widget_reset_password.password_updated_successfully` - "Password updated successfully! Redirecting..."
- `widget_reset_password.password_update_failed` - "Password update failed"
- `screen_reset_password.reset_password_header` - "Reset password"
- `modal_password_reset_error.title` - "PIN Code Incorrect"
- `modal_password_reset_error.message` - "The PIN code you entered was incorrect or has expired. Please request a new PIN code."
- `modal_password_reset_error.button` - "Request New PIN Code"
- `modal_password_reset_success.title` - "Password Changed"
- `modal_password_reset_success.message` - "Your password has been successfully changed. You can now log in with your new password."
- `modal_password_reset_success.button` - "Go to Login"

### 9. Sikkerhedsforbedringer

- Log alle PIN valideringsforsøg
- Vis rate limiting fejlbeskeder hvis relevant
- Håndter udløbet PIN-kode gracefully
- Sikre at email parameter valideres på reset_password skærmen

## Supabase RPC Function Specifications

### Function 1: `auth_request_password_reset_pin` ✅ IMPLEMENTERET

**Purpose:** Genererer og sender en 6-cifret PIN-kode til brugerens email for password reset.

**Input Parameters:**

```sql
input_email TEXT -- Email adresse for brugeren der anmoder om password reset
```

**Return Value:**

```json
[
  {
    "status_code": 200,
    "data": {
      "message": "PIN code generated successfully",
      "payload": null,
      "success": true
    },
    "log_id": null
  }
]
```

---

### Function 2: `auth_reset_password_with_pin` ⏳ MANGER

**Purpose:** Validerer PIN-kode OG opdaterer brugerens password i ét trin, derefter logger brugeren automatisk ind.

**Input Parameters:**

```sql
input_email TEXT,        -- Email adresse
input_pin TEXT,          -- 6-cifret PIN-kode modtaget via email
input_new_password TEXT  -- Nyt password (minimum 10 karakterer)
```

**Funktionalitet (ALLE valideringer serverside i ét trin):**

1. Find PIN-kode record i databasen baseret på email
2. Valider at PIN-kode matcher den gemte PIN-kode
3. Valider at PIN-kode ikke er udløbet (expiry timestamp skal være i fremtiden)
4. Valider at PIN-kode ikke allerede er brugt (status != 'used')
5. Valider at email matcher PIN-kode record
6. Valider at nyt password opfylder krav (minimum 6 karakterer, evt. kompleksitet hvis relevant)
7. Hvis ALLE valideringer passerer:
   - Opdater brugerens password i Supabase Auth
   - Marker PIN-kode som "used" (så den ikke kan bruges igen)
   - Log password reset for sikkerhed
   - Opret en session/token så brugeren automatisk er logget ind
   - Returner session information eller token
8. Hvis NOGEN validering fejler → returner fejlbesked

**Return Value:**

```sql
JSONB med struktur:
{
  "success": BOOLEAN,
  "message": TEXT,
  "session_token": TEXT (optional), -- Token eller session info til auto-login - KRITISK!
  "user_id": UUID (optional),       -- User ID hvis succesfuldt
  "error_code": TEXT (optional)      -- "pin_invalid", "pin_expired", "pin_already_used", "password_weak", etc.
}
```

**Success case (200):**

```json
{
  "status_code": 200,
  "data": {
    "success": true,
    "message": "Password reset successfully",
    "session_token": "...", // VIGTIGT: Session token til auto-login
    "user_id": "..."
  },
  "log_id": null
}
```

**Error cases (500):**

- PIN ikke fundet → {"success": false, "message": "...", "error_code": "pin_not_found"}
- PIN udløbet → {"success": false, "message": "...", "error_code": "pin_expired"}
- PIN allerede brugt → {"success": false, "message": "...", "error_code": "pin_already_used"}
- PIN forkert → {"success": false, "message": "...", "error_code": "pin_invalid"}
- Email matcher ikke → {"success": false, "message": "...", "error_code": "email_mismatch"}
- Password for svagt → {"success": false, "message": "...", "error_code": "password_weak"}
- Password update fejlede → {"success": false, "message": "...", "error_code": "password_update_failed"}

**Sikkerhedskrav:**

- PIN-kode kan kun bruges én gang (marker som "used" efter brug)
- PIN-kode udløber efter 5 minutter
- Valider password styrke (minimum 6 karakterer)
- Sikre at email matcher PIN-kode record
- Log alle password reset forsøg for sikkerhedsanalyse
- **ALLE valideringer skal ske serverside** - ingen klient-side validering er tilstrækkelig
- **INGEN auto-login:** Funktionen returnerer IKKE session_token. Brugeren skal logge ind manuelt efter password reset

## Implementation Status

### ✅ FÆRDIGE STEPS:

- **Step 1 (del 1):** SupabaseService.requestPasswordResetPin() - Implementeret og testet
- **Step 1 (del 2):** SupabaseService.resetPasswordWithPin() - ✅ IMPLEMENTERET
- **Step 2 (del 1):** AuthProvider.requestPasswordResetPin() - Implementeret og testet
- **Step 2 (del 2):** AuthProvider.resetPasswordWithPin() - ✅ IMPLEMENTERET
- **Step 3:** ForgotPasswordForm - Opdateret til at bruge PIN flow, navigerer til reset_password med email parameter

### ⏳ VENTER PÅ SUPABASE FUNKTIONER:

- **Step 1 (del 2):** SupabaseService.resetPasswordWithPin() - ✅ IMPLEMENTERET
- **Step 2 (del 2):** AuthProvider.resetPasswordWithPin() - ✅ IMPLEMENTERET

### ⏳ VENTER PÅ FLUTTER IMPLEMENTERING:

- **Step 4:** ResetPasswordScreen - Skal opdateres til at bruge ny widget når email parameter findes, beholde gammel widget for token/code
- **Step 5:** ResetPasswordFormPin - NY widget skal oprettes med to-trins flow (PIN input → password input). Gammel ResetPasswordForm beholdes uændret.
- **Step 6:** Routing - Allerede understøtter query parameters, ingen ændringer nødvendige
- **Step 7:** Modaler - Opret PasswordResetErrorModal og PasswordResetSuccessModal med navigation til forgot_password/login
- **Step 8:** I18n - Nye strings skal tilføjes til alle sprogfiler
- **Step 9:** Sikkerhedsforbedringer - Logging og error handling

**Nuværende status:**

- ✅ Begge Supabase endpoints er implementeret (`auth_request_password_reset_pin` og `auth_reset_password_with_pin`)
- ✅ Service og Provider lag er implementeret for begge endpoints
- ⏳ Vent på Flutter implementering af ResetPasswordFormPin widget med modaler

**Sikkerhedsforbedring:** Flowet bruger kun 2 endpoints. Alle valideringer (PIN, expiry, email match) sker serverside i ét trin når password opdateres, hvilket eliminerer sikkerhedshuller og gør flowet mere robust.

**Opdateret krav:**

- Ingen auto-login efter password reset - brugeren skal logge ind manuelt
- Ved fejl: Vis modal → Naviger til forgot_password
- Ved success: Vis modal → Naviger til login

## Technical Notes

- PIN-kode: 10 cifre, udløber efter 5 minutter, kan kun bruges én gang
- Rate limiting håndteres på Supabase backend
- **INGEN auto-login:** Brugeren skal logge ind manuelt efter password reset
- Brug eksisterende PinCodeTextField widget fra enter_pincode.dart som reference
- Behold eksisterende error handling patterns
- **ALLE eksisterende funktioner og widgets beholdes uændret for nem rollback:**
  - `resetPassword()` i SupabaseService og AuthProvider
  - `handleResetPasswordFromUrl()` i SupabaseService
  - `ResetPasswordForm` widget (gammel link-baserede flow)
  - Token/code parameter logik i ResetPasswordScreen

## GUI Flow

### Nyt PIN-baseret flow:

```
ForgotPasswordScreen
  └─> ForgotPasswordForm (widget)
       └─> CustomButton ("Reset password" knap)
            └─> onPressed: _resetPassword()
                 └─> authNotifier.requestPasswordResetPin(email)
                      └─> AuthProvider.requestPasswordResetPin()
                           └─> SupabaseService.requestPasswordResetPin()
                                └─> RPC: auth_request_password_reset_pin
                 └─> Naviger til ResetPasswordScreen?email=...
                      └─> ResetPasswordScreen (detekterer email parameter)
                           └─> ResetPasswordFormPin (NY widget)
                                └─> Fase 1: PIN Input
                                     └─> validatePasswordResetPin()
                                └─> Fase 2: Password Input
                                     └─> resetPasswordWithPin()
                                          └─> Auto login
```

### Gammel link-baseret flow (beholdes):

```
Email link med token/code
  └─> ResetPasswordScreen (detekterer token/code parameter)
       └─> ResetPasswordForm (gammel widget)
            └─> handleResetPasswordFromUrl()
```

---

**Plan oprettet:** 2024-12-28 **Sidst opdateret:** 2024-12-28
