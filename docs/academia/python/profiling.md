Una parte importante durante el desarrollo de cualquier aplicación es ser consciente de los cuellos de botella.

Aunque toda optimización es, en principio, buena, nuestro tiempo es limitado, y no merece la pena reducir a la mitad el tiempo de ejecución de una función, si este tiempo de ejecución representa una fracción pequeña del programa.

Así, para medir el tiempo de de ejecución de un programa, usamos el *builtin* `cProfile`.

## cProfile
Para analizar nuestro programa usaremos un decorador sobre nuestra función *entrypoint*:

```python
from cProfile import Profile
from pstats import Stats
from io import StringIO

def profile(fun):
    def wrapper(*args, **kwargs):
        # Start profiling
        pr = Profile()
        pr.enable()

        # Run fun
        result = fun(*args, **kwargs)

        # Disable profiling
        pr.disable()

        # Print profiling stats
        s = StringIO()
        ps = Stats(pr, stream=s).sort_stats('cumulative')
        ps.print_stats()
        print(s.getValue())
        return result
    return wrapper
```

Así, decoramos y ejecutamos el programa:
```python

@profile
def main():
    # do stuff

if __name__ == '__main__':
    main()
```

La clave ahora es analizar los resultados. Para ello hay que centrarse en la columna *cumulative*. Aquellas filas en las cuales aumenta notoriamente nos indican la sección del programa con los cuellos de botella a revisar.

## Timeit
Una vez hemos localizado el(los) cuello(s) de botella en una ejecución real, no es necesario seguir usando el profile y ejecutar todo el programa (aunque sea lo más cómodo). En su lugar, usamos `timeit` de forma externa al programa.

??? note "¿Ejecución 100% real vs `mocks`?"
    Es posible que no nos interese probar ciertas funciones. Por ejemplo, quizás no sea deseable hacer pruebas que escriban resultados a una base de datos **real**.
    Quizás lo ideal sería montar una BBDD de *testing*, pero está bien plantear otra opción: usar *mocks*!
    Podríamos simular su tiempo de ejecución con `time.sleep` y, si tiene *return value*, mockearlo.

Esto nos permite, sin tener que modificar el programa más que para crear las funciones alterantivas, comparar distintas implementaciones de una función.

=== "*Script* ejemplo"
    ```python
    # myprogram.py

    def funA():
        pass

    def funB():
        pass

    def main():
        'A complex function that could potentially take a long time to run'
        # Do stuff, including calling "funA" or "funB"
        pass

    if __name__ == '__main__':
        main()
    ```

=== "Timeit"
    ```bash
    $ python -m timeit -s 'from myprogram import funA' -n 100 'funA()'
    $ python -m timeit -s 'from myprogram import funB' -n 100 'funB()'
    ```

=== "Output"
    ```python
    # funA
    This will be run on import
    100 loops, best of 5: 66.6 nsec per loop

    # funB
    This will be run on import
    100 loops, best of 5: 66.6 nsec per loop
    ```
