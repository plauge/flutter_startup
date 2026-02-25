# Diagrams

Tip: Brug [svgviewer.dev](https://www.svgviewer.dev/) til at zoome ind på SVG-filer.

Architekturdiagrammer og flow charts for projektet. **Kilde:** `.mmd` filer. SVG genereres manuelt ved behov.

## Opret nyt diagram

1. Opret en `.mmd` fil i denne mappe med Mermaid-kode
2. Tilføj til tabellen nedenfor og til `.cursor/rules/diagrams.mdc`

## Eksporter til SVG (manuelt)

1. Åbn [mermaid.live](https://mermaid.live)
2. Indsæt indholdet fra `.mmd` filen
3. Klik **Actions** → **SVG** for at downloade

Alternativt med Node.js: `npx -p @mermaid-js/mermaid-cli mmdc -i docs/diagrams/foo.mmd -o docs/diagrams/foo.svg`

## Diagrammer


| Fil                             | Beskrivelse                                              |
| ------------------------------- | -------------------------------------------------------- |
| master_key_validation.mmd       | PIN-beskyttet side: masterKeyValidationProvider flow     |
| network_connectivity.mmd        | SupabaseConnectionGuard, NoConnectionScreen              |
| security_key_update_reset.mmd   | Update vs Reset security key                             |
| authenticated_screen_guards.mmd | Rækkefølge: auth, terms, onboarding, master key, face ID |
| delete_account.mmd              | Sletning af konto + lokal storage pr. email              |
| onboarding.mmd                  | _onboardingValidatedPages, terms, onboarding-routes      |


