# Fork-Hinweise

Abzweig von [swkeep/interaction-menu](https://github.com/swkeep/interaction-menu) für
`project_rp`. Branch: **`project-rp`**. Grundlage ist `fee7a7d` (13.09.2025) — upstream ruht
seitdem.

Alles hier ist eine **Ergänzung**, kein Umbau. Wer den Fork gegen upstream diffed, sieht genau
diese Punkte.

## 1. ox_core-Brücke — `lua/bridge/ox.lua` *(neu)*

Ohne geladene Brücke stieg `apply_framework_restrictions` bei `Bridge.active == false` sofort aus.
Upstream gibt es nur Brücken für ESX und QBCore. Unter ox_core waren `item`, `items`, `job` und
`gang` am Eintrag damit **wirkungslos** — der Eintrag war nicht gesperrt, sondern immer sichtbar.

Die neue Brücke liefert `hasItem` (über ox_inventory) und `hasGroup`.

ox_core kennt keine Jobs, sondern **Gruppen**: ein Spieler kann in mehreren gleichzeitig sein, mit
je eigenem Grad. Das lässt sich nicht auf ein einzelnes `job`-Feld abbilden, deshalb geben `getJob`
und `getGang` hier nichts zurück.

Die Gruppen werden lokal mitgeführt und über `ox:setActiveCharacter` und `ox:setGroup` aktuell
gehalten; geleert wird bei `ox:startCharacterSelect`, weil ox_core dort dasselbe tut. Der Vergleich
läuft **in Lua**, nicht über ox_cores `getGroup` — das prüft `if (grade && requiredGrade <= grade)`,
und in JavaScript ist die 0 unwahr, ein Mitglied mit Grad 0 fiele dort durch.

## 2. Neues Feld `groups` am Eintrag

Dieselben Schreibweisen wie bei ox_target: `'police'`, `{'police','ambulance'}` oder
`{ police = 2 }`.

## 3. Gatter blenden aus statt durchzulassen

`apply_framework_restrictions` hängt nicht mehr an `Bridge.active`. Ist ein Gatter gesetzt, das
niemand beantworten kann, wird der Eintrag **ausgeblendet** und einmalig gewarnt. Vorher blieb er
sichtbar — eine Absicherung, die wie eine aussieht und keine ist.

## 4. `convert_options` verlor jeden Eintrag

Im ox_target-Nachbau stand:

```lua
local opt = table.clone and table.clone(option) or {}
```

`table.clone` kommt aus ox_lib, und `@ox_lib/init.lua` ist im fxmanifest **auskommentiert**. Der
Ausdruck fiel damit auf eine leere Tabelle zurück: Label, Symbol, `onSelect` — alles weg. Ersetzt
durch eine eigene flache Kopie. Damit kommt auch `groups` durch.

## 5. Fünf fehlende ox_target-Exporte

Gegen `overextended/ox_target`, `client/api.lua` abgeglichen — dort waren 19 von 24 nachgebildet.

| Export | jetzt |
|---|---|
| `isActive` | umgesetzt |
| `zoneExists` | umgesetzt |
| `addGlobalOption` / `removeGlobalOption` | auf das globale `entities`-Menü abgebildet |
| `getTargetOptions` | absichtlich mit `nil` registriert — meldet sich laut, statt still nichts zu liefern |

## 6. `indicator.png` unter Enhanced

Die beiden Symbole sind im fxmanifest zusätzlich **namentlich** deklariert; der Glob `icons/*.*`
scheint unter Enhanced nicht mehr zu greifen. **Der Fix ist nicht bestätigt** — der Fehler trat
danach erneut auf und ist weiter offen.

## 7. Gebaute DUI liegt bei

`interactionDUI/dui` ist upstream ignoriert, das Manifest zeigt aber darauf (`ui_page
"dui/index.html"`). Damit das Submodul ohne Bauschritt läuft, ist das gebaute Ergebnis hier
eingecheckt. Die Quelle bleibt daneben in `dui_source`.

## 8. Konfiguration

`config.shared.lua` ist unsere: `ox_target = true`, `eye_enabled`, `outline_enabled`.

`devMode` und `debugPoly` stehen auf **`true`** — das lädt die Beispielmenüs aus `lua/examples/`.
Vor dem Livegang ausschalten.

Der Schalter `provide.ox_target` **muss** an bleiben, solange das fxmanifest `provide 'ox_target'`
meldet: sonst kehrt der Nachbau beim Laden sofort zurück und registriert seine Exporte nie,
während alle anderen Ressourcen ox_target für gestartet halten. ox_doorlock lief so in
*„No such export addGlobalObject in resource ox_target"*.
