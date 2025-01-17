# CountryApp

CountryApp es una aplicación iOS que permite explorar información detallada sobre países del mundo. Desarrollada utilizando el patrón arquitectónico **VIPER** y **UIKit** con diseño programático.

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

