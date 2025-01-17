# CountryApp

CountryApp es una aplicación iOS que permite explorar información detallada sobre países del mundo. Desarrollada utilizando el patrón arquitectónico **VIPER** y **UIKit** con diseño programático.

## Capturas de pantalla

_Agrega aquí tus tres capturas de pantalla_

## Descripción

La aplicación consume datos desde la API pública de REST Countries y proporciona información como:
- Nombre del país
- Capital
- Bandera
- Región
- Idiomas
- Ubicación geográfica

## Arquitectura

CountryApp está desarrollada siguiendo el patrón **VIPER** (View, Interactor, Presenter, Entity, Router), lo que permite una separación clara de responsabilidades y facilita la escalabilidad y mantenimiento del código.

## Servicios Web Utilizados

CountryApp utiliza los siguientes servicios RESTful de [REST Countries](https://restcountries.com/#endpoints-all):
- **Listado de todos los países:** `https://restcountries.com/v3.1/all`
- **Búsqueda por nombre:** `https://restcountries.com/v3.1/name/{name}`

## Tecnologías Utilizadas

- **Lenguaje:** Swift 5
- **Arquitectura:** VIPER
- **Framework:** UIKit (programático)
- **Xcode 15.4**

## Instalación

```bash
git clone <URL_DEL_REPOSITORIO>
cd CountryApp
open CountryApp.xcodeproj
```

## Contribuciones

¡Las contribuciones son bienvenidas! Por favor, abre un issue o un pull request si deseas colaborar.

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

**Desarrollado por:** _Miguel Tomairo_

