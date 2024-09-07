# Dev Container Features

## Contents

### `flyway-cli`

Installs `flyway` into the newly built container (full version with the included JRE).

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/Pato05/devcontainer-features/flyway:1": {
            "version": "10.17.3" // any version found on https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/
        }
    }
}
```