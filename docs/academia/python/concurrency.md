Decimos que dos o más tareas son **concurrentes** cuando pueden empezar, ejecutarse, y completarse **en períodos de
tiempo superpuestos**.

Si las dos tareas se están ejecutando **literalmente** al mismo tiempo, entonces tenemos paralelismo.

Así, paralelismo implica concurrencia, pero concurrencia no implica paralelismo.

## Threading
En arquitectura de computadores, se define *multithreading* como la capacidad de una CPU de proveer multiples hilos de
ejecución concurrentemente, respaldada por el sistema operativo. En esencia, el prcesador salta de una tarea a otra,
recordando el contexto de cada una y retomando la ejecución.

Así, la concurrencia mediante *threads* es perfecta para operaciones I/O en las cuales el procesador tiene que esperar la
llegada de datos antes de poder trabajar con ellos, pero es mala para tareas que requieran mucho procesamiento.

Para usar *threads* en Python, usaremos dos *builtins*: `threading.Thread`, y `concurrent.futures.ThreadPoolExecutor`.

### `threading.Thread`
Es la forma "vieja" de usar *threads*. No es necesariamente peor, pero hace menos cosas por nosotros.

Su uso se basa en tres partes:

1. Instancializar el *thread* definiendo la función ha ejecutar.
2. Iniciar la ejecución del *thread*.
3. (OPCIONAL) Esperar a que termine.

=== "Sin argumentos"
    ```python
    def foo():
        # do stuff, sin argumentos

    t1 = Thread(target=foo)

    # Iniciamos el thread
    t1.start()

    # (OPCIONAL) Bloqueamos el programa hasta que termine
    t1.join()
    ```

=== "Con argumentos"
    ```python
    def bar(i):
        # do stuff, con un argumento

    def spam(i, j):
        # do stuff, con multiples argumentos

    t1 = Thread(target=bar, args=('something',))
    t2 = Thread(target=spam, args=('something', 'funny'))

    # Iniciamos los threads
    t1.start()
    t2.start()

    # (OPCIONAL) Bloqueamos el programa hasta que terminen
    t1.join()
    t2.join()
    ```

=== "`spam` repetida con distintos argumentos"
    ```python
    threads = []
    spam_args = [(1, 3), (2, 4), (3, 5)]

    for i in spam_args:
        t = Thread(target=spam, args=i)
        t.start()
        threads.append(t))

    for t in threads:
        t.join()
    ```

#### Queues y Semaphores
**¿Dónde están los resultados?**

Los *threads* **no guardan los resultados**. Debemos definir manualmente como recogerlos en una estructura externa.

!!! note "*Queues*"
    La estructuras comunes de Python (listas, tuplas, diccionarios, etc.) **no son _thread safe_**: pueden dar errores
    al escribirse/leerse desde multiples *threads*.

    El *builtin* `queue` nos proporciona las Queues: secuencias sin indexar (solo tienen entrada y salida) que bloquean
    la concurrencia, permitiendo solo una escritura/lectura por vez.

**¿Cómo puedo limitar el número de *threads* concurrentes?**

Con recursos limitados, conviene normalmente limitar el número de *threads concurrentes.

!!! note "*Semaphores*"
    Los *semaphores* del *builtin* threading, son una especie de contadores, cuyo funcionamiento se basa en 3 ideas:

    - El número de *workers*
    - El método `adquire`, que bloquea un *worker*
    - El método `release`, que libera un *worker*

    Estos *semaphores* se puede usar con `with`, tal que al entrar al contexto se hace un `adquire` y al salir un `release`.

??? info "Context manager: `with`"
    La cláusula `with`, ejecuta los *dunder method* `__enter__` y `__exit__` de un objeto al entrar y salir respectivamente.
    Para saber más sobre estos los *double underscore methods*, conviene estudiar el *data model* de Python.


##### Implementacion
Para implementar ambos vamos a *subclasear* `threading.Thread`, y redefinir su método `Thread.run`.

??? info "Método `Thread.run`"
    `Thread.run` detona la instrucción de nuestro callable con sus argumentos.
    ```python
    def run(self):
        try:
            if self._target:
                self._target(*self._args, **self._kwargs)
        finally:
            del self._target, self._args, self._kwargs
    ```
    Podemos ver el *source code* [aquí](https://hg.python.org/cpython/file/3.4/Lib/threading.py) o
    [aquí](https://github.com/python/cpython/blob/0729694246174a5c2f0ae197f2e0dbea61b90c9f/Lib/threading.py).


=== "`PipedToQueueThread`"
    ```python
    from queue import Queue
    from threading import Thread
    from typing import Callable, Iterable

    class PipedToQueueThread(Thread):
        def __init__(
                self,
                queue: Queue,
                target: Callable,
                args: Iterable[Any] = (),
                **kwargs):
            super().__init__(target=target, args=args, **kwargs)
            self._queue = queue

    def run(self):
        try:
            if self._target is not None:
                result = self._target(*self._args, **self._kwargs)
                self._queue.put(result)

        finally:
            # Avoid a refcycle if the thread is running a function with
            # an argument that has a member that points to the thread.
            del self._target, self._args, self._kwargs, result
    ```

=== "`SemaphoredThread`"
    ```python
    from threading import Thread, Semaphore, BoundedSemaphore
    from typing import Union, Callable, Iterable, Any

    class SemaphoredThread(Thread):
        def __init__(
                self,
                semaphore: Union[Semaphore, BoundedSemaphore],
                target: Callable,
                args: Iterable[Any] = (),
                **kwargs):
            super().__init__(target=target, args=args, **kwargs)
            self._semaphore = semaphore

        def run(self):
            "Nest original run within our semaphore's context"
            with self._semaphore:
                super().run()
    ```

=== "*Why not both?*"
    ```python
    from threading import Thread, Semaphore, BoundedSemaphore
    from typing import Union, Callable, Iterable, Any

    class SemaphoredPipedToQueueThread(PipedToQueueThread):
        def __init__(
                self,
                queue: Queue,
                semaphore: Union[Semaphore, BoundedSemaphore],
                target: Callable,
                args: Iterable[Any] = (),
                **kwargs):
            super().__init__(target=target, args=args, queue=queue, **kwargs)
            self._queue = queue
            self._semaphore = semaphore

        def run(self):
            "Nest original run within our semaphore's context"
            with self._semaphore:
                super().run()
    ```

### `concurrent.futures.ThreadPoolExecutor`
El *PoolExecutor* incluye el semáforo y, además, podemos nos permite recoger los resultados cómodamente en forma de
`concurrent.futures.Futures`. Cuidado con este último punto.

No he querido empezar por aquí por dos razones:

1. Creo conveniente conocer un poco las bases (es Python, no C, podemos con ello).
2. He tenido problemas de memoria al usar los `Futures`. Tengo pendiente aprender como resolverlo.

=== "ThreadPoolExecutor"
    ```python
    from concurrent.futures import ThreadPoolExecutor

    futures = []
    executor = ThreadPoolExecutor(max_workers=2)
    for _ in range(2):
        futures.append(executor.submit(fun))
    executor.shutdown(wait=False)
    ```

    `ThreadPoolExecutor.submit` también acepta *args como argumentos para fun.

    El parámetro `wait` de `ThreadPoolExecutor.shutdown` nos permite continuar con la ejecución del programa sin esperar
    a que terminen de ejecutarse los threads añadidos a nuestro ejecutor, o continuar sin preocuparnos.

=== "ThreadPoolExecutor"
    ```python
    from concurrent.futures import ThreadPoolExecutor

    futures = []
    with ThreadPoolExecutor(max_workers=2) as executor:
        for _ in range(2):
            futures.append(executor.submit(fun))
    ```

    `ThreadPoolExecutor.submit` también acepta *args como argumentos para fun.

    El parámetro `wait` de `ThreadPoolExecutor.shutdown` nos permite continuar con la ejecución del programa sin esperar
    a que terminen de ejecutarse los threads añadidos a nuestro ejecutor, o continuar sin preocuparnos.

!!! warning "Problemas de memoria"
    El problema de este approach son los Futures. Los futures no son resultados hasta que terminan, pero si que tienen un
    metodo `result` que devuelve el resultado. Y claro... este se almacena dentro de cada Future.

    Esto no me gusta nada, pues aunque nos ha facilitado las cosas nos obliga a pensar cómo gestionar el exceso de RAM, ya
    sea creando varios ThreadPoolExecutor sucesivos.
