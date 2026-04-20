# Contribución

## Commits de Git

Usa **commits atómicos**: un cambio lógico por commit. Si mezclas trabajo no relacionado, divídelo antes de abrir un PR.

### Formato del mensaje (Conventional Commits)

Sigue [Conventional Commits](https://www.conventionalcommits.org/). El **título y el cuerpo del commit** van en **inglés**, en **modo imperativo**, con este prefijo:

```
<type>(<optional-scope>): <short description>
```

(La parte `<short description>` y el cuerpo del mensaje van en **inglés**.)

**Tipos** (habituales):

| Tipo | Cuándo usarlo |
|------|----------------|
| `feat` | Nuevo comportamiento o funcionalidad |
| `fix` | Corrección de un error |
| `refactor` | Cambio interno sin cambio de comportamiento visible |
| `docs` | Solo documentación |
| `test` | Solo tests |
| `chore` | Herramientas, build, dependencias, formato |
| `style` | Solo UI/estilo (sin cambio de lógica) |

**Ejemplos** (mensajes en inglés, como deben ir en el repositorio):

```
feat(game): add final-answer flow before advancing question
fix(list): read countries from SwiftData when cache is warm
docs(readme): document WireMock base URL
refactor(router): extract navigation helper for flag game
```

### Claves de Jira / issues (p. ej. `MT-204`)

Coloca la clave donde lo espere la integración Jira/Git de tu equipo (a menudo basta con que aparezca en algún sitio del mensaje para enlazar el commit con el ticket).

**Recomendado (mantiene el título limpio):** pie del mensaje tras una línea en blanco:

```
feat(game): shorten reveal pause before next question

Refs: MT-204
```

**También válido:** añadir la clave al final del título para verla en logs de una línea:

```
feat(game): shorten reveal pause before next question (MT-204)
```

No uses el ticket como *scope* de Conventional Commits (`feat(MT-204): …`). El scope es el área del código (`game`, `list`, etc.), no el identificador del ticket.

**No uses** `feat(game) MT-204: add final-answer flow…` (clave entre el scope y los dos puntos). En Conventional Commits los dos puntos van **justo después** del `)` del scope (o del tipo si no hay scope): `feat(game): …`. Meter `MT-204` ahí delante de `:` deja de ser un encabezado válido para herramientas que parsean el formato. Los **commits atómicos** no tienen nada que ver con eso: atómico = un cambio lógico por commit; el ticket se añade con `Refs: MT-204` en el pie o con `(MT-204)` al final de la descripción, como arriba.

### Cuerpo del mensaje (opcional)

Úsalo para explicar el **porqué**, notas de migración o seguimientos; el texto sigue en **inglés**. Pies como `Refs: MT-204` van después del cuerpo, separados por una línea en blanco.

### Evita

- Mezclar español e inglés en el **título** del commit (el título va en inglés).
- Meter cambios no relacionados en un mismo commit (complica la revisión y `git bisect`).
