# CountryApp

CountryApp es una aplicación iOS que permite explorar información sobre países del mundo. Está desarrollada con el patrón arquitectónico **VIPER** y **UIKit** con diseño programático.

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

Pantalla inicial (**Home**) con dos accesos: **listado de países** (búsqueda, detalle con capital, región, fronteras y bandera, mapa) y **juego de banderas** (30 preguntas, 4 opciones aleatorias, estilo concurso, resumen con puntuación y tiempo).

El listado se guarda en **SwiftData** (`PersistedCountry`) tras la primera descarga desde la API; el juego lee siempre desde esa base local.

## Arquitectura (VIPER)

El proyecto sigue **VIPER** (View, Interactor, Presenter, Entity, Router) con responsabilidades separadas:

- **View**: UI y eventos de usuario; no navega sola al detalle.
- **Presenter**: orquesta casos de uso y actualiza la vista.
- **Interactor**: lógica de negocio y acceso a datos (por ejemplo, filtrar el detalle por nombre a partir del JSON completo).
- **Router**: composición del módulo (`createModule`) y navegación (`push` / transiciones).
- **Entity**: modelos `Codable` y errores de dominio.

Módulos principales: **Home**, **CountryList**, **CountryDetail**, **Map** y **FlagGame** (instrucciones, cuestionario, resumen).

### Juego “Adivina la bandera”

- 30 países distintos por partida, orden y opciones **aleatorios** en cada sesión.
- Distractores elegidos por **similitud de nombre** (heurística) para dificultar la respuesta.
- Puntuación: **+10** acierto, **−5** error, **0** si saltas la pregunta.
- Puedes **terminar antes**; el resumen usa aciertos, fallos, saltos y el tiempo transcurrido hasta ese momento.

### SwiftData y JSON de listado

Para persistir y mostrar banderas desde **Assets** (`Assets.xcassets/countries`), el JSON de `all` debe incluir **`assetFlag`** y/o **`cca2`** (código ISO de dos letras en minúsculas, coherente con el nombre del imageset). Sin esos campos el país puede omitirse al guardar o no mostrar bandera en el juego.

## API y datos

Los datos se obtienen desde un backend de ejemplo alojado en **WireMock Cloud**. La base común es:

`https://d494e.wiremockapi.cloud/v1.0/`

| Recurso | Path | Uso en la app |
|--------|------|----------------|
| Listado | `all` | Lista de países (`name`, `capital`, etc.). |
| Detalles | `name/all` | JSON con todos los detalles; el **Interactor** selecciona el país por `name.common`. |

En `CountryApp/Resources/` hay JSON de referencia (`countries.json`, `country_details.json`) útiles para publicar o revisar el contrato de la API.

Las banderas en detalle pueden cargarse desde URL remota; en **Assets** (`Assets.xcassets/countries`) hay imágenes por código ISO de dos letras para uso local si lo integras en la UI.

## Tecnologías

- **Lenguaje:** Swift
- **Arquitectura:** VIPER
- **UI:** UIKit (programático)
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
