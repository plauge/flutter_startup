# Diagrams

Tip: Brug [svgviewer.dev](https://www.svgviewer.dev/) til at zoome ind på SVG-filer.

Architekturdiagrammer og flow charts for projektet. **Kilde:** `.mmd` filer. SVG genereres manuelt ved behov.

## Retningslinjer for nye diagrammer

Gør diagrammerne forståelige for en der kun læser dem — uden at kende koden.

1. **Beskrivelsesboks øverst**  
   Tilføj en `Desc`-boks med forklaring i almindeligt sprog:
   ```mermaid
   Desc["🔒 Kort overskrift\nForklaring af hvad diagrammet viser og hvorfor det sker."]
   style Desc fill:#e8f4fd,stroke:#b8d4e8
   ```

2. **Selvforklarende bokse**  
   Skriv hvad der sker, ikke hvordan det kaldes i koden.  
   - ❌ `ref.watch masterKeyValidationProvider`  
   - ✅ `Tjek om bruger har en gyldig security key`  
   - ❌ `networkOfflineProvider = true`  
   - ✅ `Gem at vi er offline og gem nuværende side til senere`

3. **Konkrete konsekvenser**  
   På beslutningspunkter: forklar både betingelse og hvad resultatet betyder.  
   - ❌ `|fail|`  
   - ✅ `|"Nej — send til login"|`

4. **Ét fokus pr. diagram**  
   Ét flow, ét emne. Undgå at blande flere flows i samme diagram.

## Opret nyt diagram

1. Opret en `.mmd` fil i denne mappe med Mermaid-kode (følg retningslinjerne ovenfor)
2. Tilføj til tabellen nedenfor og til `.cursor/rules/diagrams.mdc`

## Eksporter til SVG

**Med Node.js (anbefalet):**
```bash
npx -y -p @mermaid-js/mermaid-cli mmdc -i docs/diagrams/foo.mmd -o docs/diagrams/foo.svg
```

**Manuelt via mermaid.live:**
1. Åbn [mermaid.live](https://mermaid.live)
2. Indsæt indholdet fra `.mmd` filen
3. Klik **Actions** → **SVG** for at downloade og gem som `foo.svg`

## Diagrammer


| Fil                             | Beskrivelse                                              |
| ------------------------------- | -------------------------------------------------------- |
| master_key_validation.mmd       | PIN-beskyttet side: masterKeyValidationProvider flow     |
| network_connectivity.mmd        | SupabaseConnectionGuard, NoConnectionScreen              |
| security_key_update_reset.mmd   | Update vs Reset security key                             |
| authenticated_screen_guards.mmd | Rækkefølge: auth, terms, onboarding, master key, face ID |
| delete_account.mmd              | Sletning af konto + lokal storage pr. email              |
| onboarding.mmd                  | _onboardingValidatedPages, terms, onboarding-routes      |


