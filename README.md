# CountryApp

CountryApp es una aplicación iOS que permite explorar información sobre países del mundo. Está desarrollada con el patrón arquitectónico **VIPER** y **UIKit** con diseño programático.

Los juegos usan un **look & feel tipo quiz** (tema claro, color primario morado, tarjetas redondeadas con sombra, opciones multicolor y tipografía redondeada del sistema) apoyado en una pequeña **capa de diseño** propia (ver [Diseño (Design System)](#diseño-design-system)).

## Capturas de pantalla

<table>
<tr>
    <td><img src="https://github.com/user-attachments/assets/ba35b182-debf-43f3-ae83-e41ec290234d" width="300"></td>
    <td><img src="https://github.com/user-attachments/assets/5a352054-3159-4025-98af-30e6bad1b6d4" width="300"></td>
    <td><img src="https://github.com/user-attachments/assets/4625574c-4cd1-40f4-9636-22337cd56686" width="300"></td>
</tr>
<tr>
    <td><img src="https://github.com/user-attachments/assets/a6ccb98e-95a0-4853-aa75-7a949eaab2ed" width="300"></td>
    <td><img src="https://github.com/user-attachments/assets/aa88c3b2-6b28-45b9-bf59-6cad9b01cd23" width="300"></td>
    <td><img src="https://github.com/user-attachments/assets/5fd850bb-25b4-4423-84d7-fab9ab35a5ea" width="300"></td>
</tr>
</table>

## Descripción

Pantalla inicial (**Home**) con tres accesos: **listado de países** (búsqueda, detalle con capital, región, fronteras y bandera, mapa) y dos juegos de preguntas — **Adivina la bandera** y **Adivina la capital**. Cada pregunta muestra una **pantalla de resultado a pantalla completa** (¡Correcto! / ¡Incorrecto!) con los puntos ganados, y al terminar hay un **resumen** con la puntuación total, compartible como tarjeta visual.

El listado se guarda en **SwiftData** (`PersistedCountry`) tras la primera descarga desde la API; los juegos leen siempre desde esa base local.

## Arquitectura (VIPER + Coordinator)

El proyecto combina **VIPER** con una capa **Coordinator** para separar la navegación inter-módulo de la intra-módulo:

### VIPER

- **View**: UI y eventos de usuario; no navega por cuenta propia.
- **Presenter**: orquesta casos de uso y actualiza la vista.
- **Interactor**: lógica de negocio y acceso a datos.
- **Router**: composición del módulo (`createModule`) y navegación **intra-módulo** (instrucciones → cuestionario → resumen).
- **Entity**: modelos `Codable` y errores de dominio.

### Coordinator

La capa de coordinators gestiona la navegación **inter-módulo** y el ciclo de vida de cada flujo:

```
AppCoordinator
├── HomeCoordinator          → crea Home; delega apertura de módulos a AppCoordinator
├── FlagGameCoordinator      → gestiona el flujo del juego de banderas
├── CapitalGameCoordinator   → gestiona el flujo del juego de capitales
└── CountryListCoordinator   → gestiona lista de países → detalle
```

- `AppCoordinator` implementa `UINavigationControllerDelegate` para detectar pops con el botón de sistema (< Atrás) y liberar coordinators automáticamente, evitando fugas de memoria.
- Los **Routers** conservan toda la navegación interna; cuando hay coordinator, delegan en él en lugar de hacer el `push` directamente.

Módulos principales: **Home**, **CountryList**, **CountryDetail**, **Map**, **FlagGame** y **CapitalGame**.

### Juego “Adivina la bandera”

- 20 países distintos por partida, orden y opciones **aleatorios** en cada sesión.
- Distractores elegidos por **similitud de nombre** (heurística) para dificultar la respuesta.
- **Deduplicación de bandera idéntica:** países con la misma bandera visual (Francia y sus territorios, Noruega y dependencias, etc.) nunca aparecen juntos como pregunta + distractor en la misma ronda (`FlagSynonymGroups`).
- **Puntuación con bonus por rapidez** (`FlagGameScoring`): **+500** por acierto más un **bonus de hasta +500** que decae linealmente hasta 0 durante los primeros **10 segundos**; **0** al fallar o saltar. El total se muestra en la pantalla de resultado, en el resumen y en la tarjeta para compartir.
- **Pantalla de resultado por pregunta:** tras confirmar, una pantalla completa verde/roja muestra si acertaste, los puntos ganados y la respuesta correcta; el botón continúa a la siguiente pregunta o al resumen.
- **Cabecera de cuestionario** con contador `X / 20`, barra de progreso y menú `···` para terminar la partida antes de tiempo.
- Puedes **terminar antes**; el resumen usa aciertos, fallos, saltos y el tiempo transcurrido hasta ese momento.
- **Botón compartir**: genera una tarjeta visual (@3×) con tu resultado para compartir en redes sociales.
- **Dudas en el resumen:** si tardas **más de 15 segundos** en confirmar, el acierto va a la sección *Dudas*.
- **Sin repetición global (pool):**
  - Mientras queden países por salir en el ciclo, cada nueva partida elige 20 de los **no usados aún**.
  - Cuando ya se usaron **todos**, se reinicia el ciclo con **todos menos los 20 de la última partida**.
  - La ventana de exclusión cubre las **dos últimas partidas** para minimizar la percepción de repetición.

### Juego “Adivina la capital”

- 20 preguntas por partida.
- En cada pregunta ves **bandera + país** y eliges la **capital** correcta entre 4 opciones.
- Misma lógica de **cabecera con progreso**, **pantalla de resultado por pregunta**, **puntuación con bonus por rapidez**, **dudas**, **botón compartir** y **pool sin repetición** que el juego de banderas.

### SwiftData y JSON de listado

Para persistir y mostrar banderas desde **Assets** (`Assets.xcassets/countries`), el JSON de `all` debe incluir **`assetFlag`** y/o **`cca2`** (código ISO de dos letras en minúsculas, coherente con el nombre del imageset). Sin esos campos el país puede omitirse al guardar o no mostrar bandera en el juego.

En cada país, **`name.nameSpanish`** es el nombre usado **en los juegos** (banderas y capitales); si falta, se usa `name.common`. **`capitalSpanish`**: si viene en el JSON, la app lo usa para la **capital en listado** (SwiftData) y en **detalle**; si no, se muestra `capital`.

### Reiniciar datos locales (SwiftData)

Mientras no haya usuarios finales en producción, lo más simple es **desinstalar la app y volver a instalarla** (o borrarla del simulador y ejecutar de nuevo): eso borra el sandbox, elimina el store de SwiftData (`PersistedCountry`) y en el siguiente arranque el listado se vuelve a descargar desde la API al entrar en Home.

## Diseño (Design System)

Capa ligera y centralizada para el nuevo look & feel, en `CountryApp/DesignSystem/`:

- **`AppColor`** — tokens de color semánticos (primario morado, fondo, superficie, texto, paleta de opciones azul/rojo/naranja/verde, verde/rojo de feedback). Solo tema claro por ahora; estructurado para añadir modo oscuro más adelante.
- **`AppFont`** — tipografía **redondeada del sistema** (SF Rounded vía `fontDescriptor.withDesign(.rounded)`) escalada con Dynamic Type. No se incluyen archivos de fuente.
- **`AppMetrics`** — escala de espaciado, radios y sombra de tarjeta.
- **Componentes** (`DesignSystem/Components/`): `PillButton` (botón cápsula), `OptionButton` (opción multicolor con estados: idle / seleccionada / correcta / incorrecta / atenuada), `CardView` (superficie con sombra) y `QuizHeaderView` (contador + barra de progreso + menú `···`).
- **`CountryApp/Common/`**: `QuizFeedbackViewController` (pantalla de resultado a pantalla completa, presentada de forma modal para no tocar la pila de navegación) y `SummaryCardFactory` (tarjetas del resumen).
- `UINavigationController.applyLightAppTheme(to:)` centraliza la apariencia clara de la barra de navegación en las pantallas de juego.

## API y datos

Los datos se obtienen desde un backend de ejemplo alojado en **WireMock Cloud**. La base común es:

`https://d494e.wiremockapi.cloud/v1.0/`

**Consola web WireMock Cloud** (donde se edita y publica el mock; inicio de sesión): [https://app.wiremock.cloud/login](https://app.wiremock.cloud/login). El mock que consume esta app está expuesto en el host `d494e.wiremockapi.cloud` (ajústalo en tu cuenta si usas otro despliegue).

**GET del listado `all` (URL publicada):** [https://d494e.wiremockapi.cloud/v1.0/all](https://d494e.wiremockapi.cloud/v1.0/all)

| Recurso | Path | Uso en la app |
|--------|------|----------------|
| Listado | `all` | Lista de países (`name`, `capital`, etc.). |
| Detalles | `name/all` | JSON con todos los detalles; el **Interactor** selecciona el país por `name.common`. |

En `CountryApp/Resources/` hay JSON de referencia (`countries.json`, `country_details.json`) útiles para publicar o revisar el contrato de la API.

Las banderas en detalle pueden cargarse desde URL remota; en **Assets** (`Assets.xcassets/countries`) hay imágenes por código ISO de dos letras para uso local si lo integras en la UI.

## Tecnologías

- **Lenguaje:** Swift
- **Arquitectura:** VIPER + Coordinator
- **UI:** UIKit (programático, sin Storyboards)
- **Diseño:** capa de tokens y componentes propia (`AppColor` / `AppFont` / `AppMetrics`), SF Rounded + Dynamic Type
- **Red:** `URLSession` + `async`/`await`
- **Persistencia:** SwiftData (`ModelContainer` / `ModelContext`)

## Instalación

```bash
git clone https://github.com/rapser/countryapp.git
cd countryapp
open CountryApp.xcodeproj
```

## Tests

Desde la terminal, usando el simulador disponible (por ejemplo **iPhone 17**):

```bash
xcodebuild -scheme CountryApp -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## Contribuciones

Las contribuciones son bienvenidas. Abre un issue o un pull request si deseas colaborar.

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

**Desarrollado por:** _Miguel Tomairo_
