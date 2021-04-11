# Pytest
El TDD (Test Driven Developement) es un tipo de filosofía de desarrollo que propone:

1. Definir los resultados esperados para distintas condiciones
2. A continuación, construir la primera versión que resuelve esos resultados para esas condiciones.

El *test*, una vez creado, garantiza que futuras modificaciones no rompan el comportamiento esperado.

¿Suena a trabajo extra? Imagina salir a producción y tener que corregir algo después de cagarla. No gracias.

Por ahora: créeme. Es mucho más útil (y adictivo) de lo que puedas imaginar.


## Unit Testing
Se entiende por test unitario a aquel que comprueba el correcto funcionamiento de una unidad básica de nuestro proyecto,
como por ejemplo, una función.

!!! note "Importante"
    Es una buena práctica hacer funciones pequeñas con tareas especfíficas, tal que sea lo más fácil entender las partes
    que la componen.

Para poder realizar nuestros *tests* haremos uso de la librería `pytest`. Podríamos definirla (casi) como un *wrapper*
sobre `unittest`, el *builtin* para... bueno, hacer *unit tests*, claro.

## Pytest
Pytest nos permite, en muy pocas líneas, definir esas condiciones que deben superarse.

Aunque podría hacerse todo en el mismo archivo, lo más recomendable es separar el *script* actual de los *tests*.

=== "sample.py"
    ```python
    def divide(x, y):
        try:
            result = x / y
        except ZeroDivisionError as e:
            raise e
        else:
            return result
    ```

=== "test\_sample.py"
    ```python
    import pytest

    from sample import divide


    def test_divide_5_by_5_is_1():
        expected = 1
        assert divide(5, 5) == expected

    def test_divide_5_by_0_raises_exception():
        'Capturamos el error esperado ZeroDivisionError'
        with pytest.raises(ZeroDivisionError):
            divide(5, 0)
    ```

=== "Ejecucion"
    ```bash
    $ python -m pytest test_sample.py
    ```
    NOTA: Pytest ejecutará las funciones y clases que empiecen por "test".

=== "Output"
    ```
    ============================ test session starts =============================
    platform linux -- Python 3.9.5, pytest-6.2.2, py-1.10.0, pluggy-0.13.1
    rootdir: /home/eltbus/workspace/python/using-pytest
    collected 2 items

    test_sample.py ..                                                             [100%]

    ============================ 2 passed in 0.01s ===============================
    ```

Así, en dos patadas ya hemos visto los dos casos más comunes:

- Probar un resultado esperado
- Probar un error esperado

## Mocking
No siempre querremos comprobar que TODO funciona. Quizás algunas funciones tarden mucho en ejecutarse, impliquen gastos,
o escriban en la base de datos de producción porque te ha dado pereza crear una para el entorno de pruebas.

Es aqui donde entra el *mocking*, tal que nos permite sobrescribir una función *durante un test*. Así que recuerda el
principio **FTPC**.

??? note "FTPC"
    **Fragmenta Tu Puto Código**.

    No, este principio no existe. Pero hazlo, cabrón. No importa lo claro que te parezca tu función de 15 líneas. Lo que
    es importante es encapsular los distintos elementos de tu función.

    DISCLAIMER: tampoco te pases. Llamar a una función crea un *overhead*, y si buscas velocidad te puede perjudicar. O
    no uses Python, *notis*. No seas como yo y aprende otra cosa (i.e Haskell? Rust?).

Para poder usarlo, es necesario instalar el *plugin* `pytest-mock`.

Supongamos por ejemplo el siguiente caso:

=== "expensive.py"
    ```python
    from time import sleep


    def api_call():
        'Call an expensive external API'
        sleep(60)
        return True
    ```

=== "main.py"
    ```python
    def main():
        if api_call():
            return 'foo'
        else:
            return 'bar'
    ```
    No nos interesa ejecutar `api_call`, pues tendríamos que esperar un moooontón.

=== "tests.py"
    ```python
    from time import sleep

    from sample import main


    def test_main_returns_foo_if_api_call_is_succesful(mocker):
        mocker.patch('sample.api_call', return_value=True)

        expected = 'foo'
        assert main() == expected
    ```

!!! warning "Importante"
    Si repasas atentamente el ejemplo anterior verás que estamos mockeando `api_call` en el script en el que se define
    `main`, la función que la llama, y no en el script origen donde se ha definido `api_call`.

    Esto puede parecer algo confuso al principio.

Por último, mencionar que mocker es un parámetro algo confuso, pues aparece de la nada, y tiene que aparecer... Si lo
quitamos fallará la ejecución.
