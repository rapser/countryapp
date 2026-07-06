# Changelog

Todos los cambios notables de este proyecto se documentan aquí.  
Formato basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/) y versionado según [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Añadido
- **Capa Coordinator** sobre VIPER: `AppCoordinator`, `HomeCoordinator`, `FlagGameCoordinator`, `CapitalGameCoordinator` y `CountryListCoordinator` centralizan la navegación inter-módulo.
- `CoordinatorTrackable`: protocolo que permite a `AppCoordinator` detectar pops del botón de sistema (< Atrás) mediante `UINavigationControllerDelegate` y liberar coordinators automáticamente, evitando fugas de memoria entre sesiones de juego.
- `GameCoordinatorExitDelegate`: protocolo compartido por `FlagGameRouter` y `CapitalGameRouter` para delegar el "Volver al principio" al coordinator sin acoplar el Router a un tipo concreto.
- **Botón de compartir** en el resumen de ambos juegos: genera una tarjeta visual de 1080 × 1260 px (@3×) con gradiente, puntuación, estadísticas y un call-to-action, lista para compartir nativa (`UIActivityViewController`).
- `FlagSynonymGroups`: agrupa países con banderas visualmente idénticas (Francia y territorios, Noruega y dependencias, Australia/HM, Nueva Zelanda/CK/NZ) para evitar que aparezcan juntos en la misma ronda o como distractor.
- **Anti-repetición de dos rondas**: el estado del pool ahora recuerda la penúltima y la última ronda, ampliando la ventana de exclusión y reduciendo la percepción de repetición.
- **Barra de progreso** en las pantallas de cuestionario de ambos juegos (amarilla, 6 pt de alto, actualizada pregunta a pregunta).
- Botón de respuesta renombrado: `"Confirmar"` al ver la pregunta → `"Siguiente →"` tras confirmar, para reflejar mejor el estado de la interacción.

### Cambiado
- `FlagGameRouter.exitToHome` y `CapitalGameRouter.exitToHome` delegan al coordinator cuando está disponible; mantienen fallback directo a `popToRootViewController` para compatibilidad con callsites sin coordinator.
- `CountryListRouter.navigateToCountryDetail` delega a `CountryListCoordinatorProtocol` cuando hay coordinator; fallback al push directo anterior.
- `HomeRouter`: añadido `coordinator: HomeCoordinatorProtocol?`; las tres acciones de navegación inter-módulo delegan al coordinator.
- `SceneDelegate`: ya no construye el módulo Home directamente; arranca `AppCoordinator.start()`.
- Pausa de revelación de respuesta aumentada de 0,32 s a 1,0 s para dar tiempo a leer el feedback antes de avanzar.
- Texto de instrucciones actualizado: sustituye "Siguiente" por "Confirmar" en ambos juegos.

---

## [1.0.0] — 2025-01

### Añadido
- **Home**: pantalla inicial con acceso a lista de países y juegos.
- **CountryList**: listado con búsqueda, persistido en SwiftData (`PersistedCountry`) tras la primera descarga.
- **CountryDetail**: detalle con capital, región, fronteras y bandera; enlaza al mapa.
- **Map**: vista de mapa con pin en la capital del país seleccionado.
- **FlagGame** ("Adivina la bandera"): 20 preguntas por partida, 4 opciones, puntuación (+10 / −5 / 0), resumen con aciertos dudosos, pool sin repetición global.
- **CapitalGame** ("Adivina la capital"): bandera + país → elige la capital entre 4 opciones; misma lógica de pool y resumen que FlagGame.
- Soporte de campos en español (`nameSpanish`, `capitalSpanish`) en el JSON de la API.
- Persistencia con **SwiftData** (`ModelContainer` / `ModelContext`).
- Detección de **dudas en el resumen**: aciertos que tardaron más de 15 s se marcan aparte para repaso.
- Guías de contribución (`CONTRIBUTING.md`) con formato Conventional Commits.

### Corregido
- Título de navegación blanco en pantallas oscuras de juego.
- Eliminado spinner innecesario en pantalla de instrucciones.
- Reducida pausa de revelación inicial para respuesta más ágil.
