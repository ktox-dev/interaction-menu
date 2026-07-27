# interactionMenu Exports

Exports for building and controlling diegetic interaction menus. Each entry lists the signature plus parameter and return types. See `lua/examples/*` for usage patterns mirroring these signatures.

## interactionMenu.create

Registers and shows a menu bound to an entity, player, model, position, zone, bone, netId, or opened manually.

Signature: `exports.interactionMenu:create(data)`

Parameters:
- `data: table`
	- Targeting:
		- `entity: number` Entity handle to attach to.
		- `model: string|number` Model name or joaat hash for model-wide menus.
		- `player: number` Server id; binds to a specific player ped.
		- `netId: number` Network id for remote entities.
		- `vehicle: number` Alias for `entity` when working with vehicles.
		- `bone: string` GTA V bone name (e.g., `bonnet`, `SKEL_R_Hand`).
		- `position: vector3|vector4` World hotspot; required for position or zone menus.
		- `zone: table` Trigger zone. Supports:
			- Sphere: `{ type='sphere', position=vec3, radius=number, useZ?:boolean, debugPoly?:boolean }`
			- Box: `{ type='box', position=vec3, length=number, width=number, heading?:number, minZ?:number, maxZ?:number, debugPoly?:boolean }`
			- Poly: `{ type='poly', points=vec3[], minZ?:number, maxZ?:number, debugPoly?:boolean }`
			- Combo (PolyZone): `{ type='combo', zones=table[] }`
		- `type: 'manual'|string` Force behaviour. Use `'manual'` to control via events.
		- `triggers?: { open: string, close: string }` Events to open/close when `type='manual'`.
		- `tracker?: 'raycast'|'boundingBox'|'hit'|'collision'` Detection strategy override.
		- `dimensions?: { vec3, vec3 }` Custom AABB when `tracker='boundingBox'`.
		- `offset?: vector3` Positional offset relative to entity.
		- `rotation?: vector3` Enables 3D rotation mode for attached/position menus.
		- `scale?: number` Scale multiplier for 3D-attached menus.
		- `maxDistance?: number` Interaction distance (default 2.0).
	- Presentation:
		- `id?: string|number` Custom id; default is auto-generated.
		- `theme?: string` CSS theme key (see DUI assets/examples).
		- `width?: string|number` e.g., `'fit-content'`, `'90%'`, `500`.
		- `glow?: boolean` Enable glow beneath the menu.
		- `indicator?: boolean|string|table` Eye/prompt indicator. String shows text; table allows `{ prompt, style, fill, icon }`.
		- `icon?: string` Sprite or icon to render above target.
		- `schemaType?: 'normal'|'qbtarget'|'ox_target'` Callback payload shape.
		- `suppressGlobals?: boolean` Exclude global menus while this menu is active.
		- `static?: boolean` Keep menu fixed to entity position.
		- `skip_animation?: boolean` Skip entry animation (builders use this).
	- Hooks:
		- `extra?: { onTrigger?: function(meta), onSeen?: function(meta), onExit?: function(meta) }`
			- `meta: { entity?:number, coords?:vector3, distance?:number, name?:string|number, bone?:string }`
	- Options:
		- `options: table[]` Array of option objects:
			- `label: string`
			- `description?: string`
			- `icon?: string`
			- `badge?: { type: string, label: string }`
			- `style?: string`
			- `template?: string`
			- `picture?: { url: string, opacity?: number, width?: number, height?: number }`
			- `video?: { url: string, autoplay?: boolean, loop?: boolean, volume?: number, opacity?: number }`
			- `audio?: { url: string, volume?: number }`
			- `progress?: { type?: 'info'|'success'|'warning'|'error', value: number, percent?: boolean }`
			- `dialogue?: boolean`
			- `subMenu?: table[]` For nested trees (see `nestedMenu`).
			- `action?: function` Called on select (payload depends on `schemaType`).
			- `event?: { name: string, type?: 'client'|'server'|'command', payload?: table }`
			- `command?: string`
			- `bind?: function` Returns dynamic `string|table` for label/template.
			- `canInteract?: function` Visibility gate; return truthy to show.
			- `update?: function` Advanced update hook.
			- `item?: string`, `items?: string[]`, `has_any?: boolean`
			- `groups?: string|string[]|table<string, number>` Gruppen-Gatter (ox_core). Schreibweisen wie bei ox_target: `'police'`, `{'police','ambulance'}` oder `{ police = 2 }`.
			- `job?: table`, `gang?: table` ESX/QBCore. Unter ox_core wirkungslos -- dort `groups` verwenden.
			- `tts_api?: string`, `tts_voice?: string`

Returns:
- `string|number` Menu id.

## interactionMenu.createGlobal

Registers a global menu that merges into compatible detections across the world (entities, players, vehicles, objects, bones, zones).

Signature: `exports.interactionMenu:createGlobal(data)`

Parameters:
- `data: table` Same structure as `create`, plus:
	- `type: 'entities'|'peds'|'vehicles'|'objects'|'players'|'bones'|'zones'`

Returns:
- `string|number` Menu id.

## interactionMenu.remove

Removes a menu and schedules internal cleanup.

Signature: `exports.interactionMenu:remove(menuId)`

Parameters:
- `menuId: string|number`

Returns:
- `nil`

## interactionMenu.refresh

Forces re-evaluation of binds/visibility and UI sync for the active menu, or a specific menu.

Signature: `exports.interactionMenu:refresh(menuId?)`

Parameters:
- `menuId?: string|number` If omitted, refreshes the currently open menu (builders pass theirs automatically).

Returns:
- `nil`

## interactionMenu.set

Mutates menu state (hide/show, label, progress, position).

Signature: `exports.interactionMenu:set(change)`

Parameters:
- `change: table`
	- `menuId: string|number`
	- `type: 'hide'|'label'|'progress'|'position'`
	- `option?: number` Target option index (omit to affect whole menu where applicable).
	- `value: any` Depends on `type`:
		- `'hide'`: `boolean`
		- `'label'`: `string`
		- `'progress'`: `number` (progress value)
		- `'position'`: `vector3|vector4`

Returns:
- `nil`

## interactionMenu.pause

Suspends or resumes detection/rendering.

Signature: `exports.interactionMenu:pause(state?)`

Parameters:
- `state?: boolean` `true` to pause; `false|nil` to resume.

Returns:
- `nil`

## interactionMenu.DrawOutlineEntity

Toggles white outline rendering for an entity (requires `Config.indicator.outline_enabled`).

Signature: `exports.interactionMenu:DrawOutlineEntity(entity, enabled)`

Parameters:
- `entity: number`
- `enabled: boolean`

Returns:
- `nil`

## interactionMenu.paginatedMenu

Builder that wraps a long `options` list with pages and Prev/Next controls.

Signature: `exports.interactionMenu:paginatedMenu(config)`

Parameters:
- `config: table`
	- `itemsPerPage?: number` Default 6.
	- `options: table[]` Original options array (same shape as `Create.options`).
	- Any compatible fields from `Create` (e.g., `entity`, `position`, `zone`, `theme`, etc.).

Returns:
- `number` Menu id.

## interactionMenu.nestedMenu

Builder that flattens a nested `options` tree with automatic breadcrumbs and a Back header.

Signature: `exports.interactionMenu:nestedMenu(config)`

Parameters:
- `config: table`
	- `options: table[]` Options where entries may contain `subMenu: table[]`.
	- Any compatible fields from `Create` (e.g., `entity`, `position`, `theme`).

Returns:
- `number` Menu id.

## interactionMenu.dialogue

Conversation builder that returns a controller for branching NPC/player dialogue.

Signature: `exports.interactionMenu:dialogue(config)`

Parameters:
- `config: table`
	- `entity: number` Ped entity to animate/speak (optional but typical).
	- `position?: vector3|vector4`, `rotation?: vector3`, `indicator?: any`, `theme?: string` Presentation fields.
	- `conversations: table[]` Array of dialogue blocks:
		- `name: string`
		- `icon?: string`
		- `message: string|string[]`
		- `tts_api?: string`, `tts_voice?: string`
		- `responses: table[]` Each response:
			- `label: string`
			- `icon?: string`, `description?: string`, `badge?: { type, label }`
			- `next?: string` Jump to named conversation
			- `action?: function` Execute custom logic
			- `requirement?: { check?: function, hint?: string, notify?: function(state), type?: string }`
			- `animation?: { dict: string, anim: string, blendIn?: number, blendOut?: number, flags?: number }`
			- `voice?: { speech: string, params?: string }`
	- `onSeen?: { animation?:..., voice?:..., action?: function }`
	- `onExit?: { animation?:..., voice?:..., action?: function }`

Returns:
- `table` Dialogue instance with:
	- `menu_id: number`
	- `refresh(): void`
	- `destroy(): void`
	- `close(): void` (alias of `destroy`)

---

Notes:
- Callback payloads depend on `schemaType`:
	- `'normal'` (default) passes `entity, distance, coords, id, bone` to `action`.
	- `'qbtarget'` passes just `entity` (and merges metadata into `event.payload`).
	- `'ox_target'` passes a single table `{ entity, coords, distance, zone, bone }`.
- Examples in `lua/examples/*` mirror these signatures: see `onEntities.lua`, `onBones.lua`, `onPosition.lua`, `onZone.lua`, `manual_menu.lua`, `globals.lua`, `nested_menus.lua`, `paginated_menu.lua`, and `dialogue.lua`.
```
- **Dialogue System**: `lua/examples/dialogue.lua` builds NPC conversations with branching logic, animations, and TTS.

---

## Gatter am Eintrag -- was wirkt wovon ab

`item`, `items`, `groups`, `job` und `gang` werden nicht vom Menue selbst beantwortet, sondern von
einer **Bruecke** in `lua/bridge/`. Geladen wird sie danach, welches Framework laeuft:

| laeuft | Bruecke | liefert |
|---|---|---|
| `ox_core` | `ox.lua` | `hasItem`, `hasGroup` |
| `es_extended` | `esx.lua` | `hasItem`, `getJob` |
| `qb-core` | `qb.lua` | `hasItem`, `getJob`, `getGang` |

**Kann ein gesetztes Gatter niemand beantworten, wird der Eintrag ausgeblendet** und einmalig eine
Meldung ausgegeben. Upstream war das umgekehrt: ohne Bruecke blieb der Eintrag sichtbar, die
Absicherung fiel also lautlos aus.

ox_core kennt keine Jobs, sondern Gruppen -- ein Spieler kann in mehreren gleichzeitig sein. `job`
und `gang` bleiben dort deshalb leer; das passende Feld ist `groups`.
