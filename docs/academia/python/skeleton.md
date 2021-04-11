A la hora de desarrollar aplicaciones medias-grandes es conveniente fragmentarlas en distintos modulos.

De forma general, podríamos estructurar un proyecto de la siguiente forma:

```
project-repository
├── README.md
├── app/
│   ├── main.py
│   └── project/
│      ├── __init__.py
│      ├── utils.py
│      ├── models/
│      │   ├── __init__.py
│      │   └── ...
│      └── services/
│          ├── __init__.py
│          └── ...
├── k8s/
├── docs/
├── Dockerfile
├── build.sh
├── deploy.sh
├── Pipfile
└── ...
```
Donde:

- `main.py` es el *entrypoint* de la aplicación.
- `project` es nuestro *módulo* principal, formado por el resto de componentes.

La clave de esta estructura reside en los archivos `__init__.py`, que cumple dos funciones:

1. Hace visibles los módulos y submódulos dentro de los *scripts* (siempre y cuando el directorio este incluido en el PYTHONPATH).
2. Actua como *el script propio de una carpeta*.

El primero es evidente. El segundo lo vemos con un ejemplo:

=== "`app/main.py`"
    Empezamos por el final: `main.py`. Con esta estructura (y los scripts ejemplo en las siguientes pestañas), hacemos los siguientes *imports*:
    ```python
    from project import foo
    from project.utils import bar
    from project.models import spam
    from project.models.utils import eggs
    ```
=== "`app/project/__init__.py`"
    ```python
    def foo():
        return 'You have been "foo"led!'

    def bar():
        return 'Impossible! How?'
    ```

=== "`app/project/utils.py`"
    Este no nos sorprendería si no fuese por `bar`. ¿Cómo es posible?
    ```python
    from project import bar

    def spam():
        for i in range(2):
            yield bar()
    ```
    La estructura de proyecto permite a todo su contenido ser conscientes del *origen*: `project`.
    Así, evitamos complicados `imports` relativos entre distintos componentes.
