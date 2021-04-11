Si alguna vez has pensado en medir los tiempos de ejecución de una función, es posible que:

=== "... partiendo de esto:"


    ```python
    def fun():
        result = '!Hola Mundo!'
        return result  # Yes. I know.
    ```

=== "... hayas intentado esto:"


    ```python
    from time import time


    def fun():
        start = time()
        result = '!Hola Mundo!'
        print(time() - start)
        return result
    ```

Aunque para una única función no esta *taaan* mal, ¿te imaginas tener que modificar varias funciones? ¿Y si fuesen
modificaciones más complejas?

*Nene*, hay que seguir el principio **DRY**: *Don't Repeat Yourself*.

## Getting there
Podemos definir una función que envuelve a otra función:
=== "Código"
    ```python
    from time import time


    def timer(fun, *args, **kwargs):
        start = time()
        result = fun(*args, **kwargs)
        print(f'Function "{fun.__name__}" took: ', time() - start)
        return result


    def add(x, y):
        return x + y


    print(timer(add, 1, 2))
    ```
=== "Output"
    ```
    Function "add" took:  1.6689300537109375e-06
    3
    ```

El problema de este *approach* es que tenemos preceder nuestra `add` con `timer`. Podemos hacerlo mejor.

## Decorador
En su lugar, reescribimos `timer`, tal que dentro se define una función que envuelve nuestra funcion (sea cual sea), con
la funcionalidad propia de `timer` (medir el tiempo). Por convenio llamamos a esa función que envuelve: `wrapper`.
```python
def timer(fun):
    def wrapper(*args, **kwargs):
        start = time()
        result = fun(*args, **kwargs)
        print(f'Function "{fun.__name__}" took: ', time() - start)
        return result
    return wrapper
```
Fíjate: es una función que devuelve la función original, pero anidada en ese *wrapper*. Podríamos, por tanto, hacer así:
```python
add = timer(add)
```
... y, !hemos extendido `add` para que incluya la medición del tiempo!


### Notación compacta
Finalmente el equipo de desarrolladores de Python tuvo la idea de crear una notación más compacta, uniendo definición y
*wrapping*.
=== "Antes"
    ```python
    def add(x, y):
        return x + y

    add = timer(add)
    ```
=== "Después"
    ```python
    @timer
    def add(x, y):
        return x + y
    ```

Y esto, *bois n girls* (o mejor dicho, mi estimado y único lector), son los decoradores. Pero antes de irme...

## Decorador con argumentos

```python
from time import time


def decorator(*dargs, **dkwargs):
    def actual_decorator(fun):
        def wrapper(*args, **kwargs):
            # Do something, you can use "dargs" and "dkwargs"
            result = fun(*args, **kwargs)
            # Do something, you can use "dargs" and "dkwargs"
            return result
        return wrapper
    return actual_decorator
```

Además, te invito a leer sobre `functools.wraps`. Es un decorador que se pone sobre el `wrapper` para mantener los
metadatos de la función originales (i.e docstring) aún tras haberla decorado.
