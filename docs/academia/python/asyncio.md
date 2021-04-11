## Async
Podríamos decir que python es secuencial. Con *multithreading* y con *multiprocessing* podemos conseguir una forma de paralelistmo.

Pero bajo esos paradigmas resulta complicado, por ejemplo, implementar un cronómetro. Se puede, pero no es tan apropiado.

*Multiprocessing* no conecta bien entre aplicaciones, y *multithreading* no conecta de forma sencilla entre tasks (quizas requiera aplicar las colas y los semáforos.

Para salir del paradigma secuencial (y sus *tweaks* de "paralelizacion"), tenemos que abandonar las funciones, y aprender la nueva herramienta: las corrutinas.


Las corrutinas son parecias a una función, pero son apenas definiciones de algo que tiene que ocurrir. Para que ocurra, se deben llamar en un

Hasta hace poco, pensaba que los generadores servían como alternativa a secuencias (listas, tuplas) que podian consumir RAM innecesariamente.

El generador, una subclase de un *Iterator*, calcula y devuelve un único valor en cada llamada a su método `__next__`.

Por tanto, es común ver su uso en dos casos:

1. No se necesita reutilizar la secuencia.
2. La secuencia es tan grande que causa excepciones `MemoryError`.

??? note "Ejemplo"
    === "Ejecución"
        ```python
        gen = fun(3)

        # Primer elemento con "next
        print('Usando "next": ', next(gen))

        # El resto con una expresión "for"
        for i in gen:
            print('Usando "for": ', i)
        ```

Sin embargo, al parecer guardan una estrecha relacion con las corutinas.

## La funcionalidad "escondida"
!!! note "Iterable e Iterator"
Se considera *iterable* a cualquier objeto de python que se puede iterar, es decir, recorrer sus elementos. Al pasar un
iterable como argumento de la función `iter`, devuelve un *iterator*.

Bajo el capó, un iterable es aquel objeto que tiene implementado el método `__iter__`; y un *iterator* el que tiene
implementado además el método `__next__`.

Así, un *iterator* ES un *iterable*, pero un *iterable* no es un *iterador*.

Otro ejercicio interesante es analizar a través de la librería *builtin* `typing` las subclases.

Podemos ver como List << MutableSecuence << Sequence << Collection << [Container, Iterable]



Short answer: asynchronous programming allows programs to handle tens of thousands of simultaneous connections instead of thousands. asyncio makes asynchronous programming more accessable.

Long answer:

For arguments sake, let's assume we write a simple chat server/gateway that simply receives data from one party and forwards it to the other, like this:

```python
def handle_chat(sender, receiver):
    done = False
    while not done:
        msg = sender.read()
        receiver.send(msg)
        done = msg == "BYE!"
```

sender and receiver are IO/file-like objects, for example sockets, that are connected to the sender and receiver. In I/O land, read and write typically come in two flavours: synchronous/blocking and asynchronous/nonblocking.

In our example, both methods are blocking: after calling read, the program will halt and wait until some data is received, write will block until all data is sent.

So currently, our program can only handle a single one-way communication between two parties, which isn't very useful for a chat server.

We need to find a way to do something else while waiting for data. One way to do that is using threads. Basically, a program can have multiple threads which are "copies" of the program running in parallel and managed by the OS. All threads share the same data, but while one thread waits, another one can run. We can make our program handle more than one connection by doing something like this:

```python
import threading

for sender, receiver in list_of_sender_and_receiver_pairs:
    thread = threading.Thread(target=handle_chat, args=(sender, receiver))
    thread.start()
```
Now, we will have a thread running for each connection. While one thread is blocking on (for example) read, another thread can run and read data that got available for him. The OS will take care of all the nasty stuff like task scheduling (determing which thread needs to run now (the ones with data available), etc.)

This is a easy and effective way to handle multiple connections. But there's a problem: each thread takes some additional memory (up to a few MB), and also switching from one thread to another one takes time (a few microseconds). This doesn't sound like a lot, but it adds up.

1000 threads that get data once every second? No problem, maybe a GB extra RAM usage and 0.5% (5 millisecond/second) of CPU time spent with context switching

10000 threads? 10 GB RAM and 5% of CPU time spent doing nothing but context switching.

You see that this can lead to problems when handling huge number of connections, especially in the modern world with websockets where clients are continously connected to a server and rarely send data (like every hour or so)

So, while the OS doing the work for us is great, it doesn't scale to huge number of concurrent connections. We have to find another way.

That way is asynchronous programing. Instead of calling read and telling it "Hey, just wait for data to be available, I'll wait", we are going to tell it "please read data from here, and as soon as you have some, call me".

Classic asynchronous programming works with callbacks: you give a method that will be called when data is available. In our example, it could look something like this:

```python
def handle_chat_async(sender, receiver):
    def on_read(data):
        receiver.write(data, callback=on_write)

    def on_write(data):
        if not done:
            sender.read(callback=on_read)
            done = data == "BYE!"

    done = False
    sender.read(callback=on_read)
```

So, read will call our `on_read` method as soon is data available, but the call itself will terminate immediately, so we can handle multiple connections like this:

```python
for sender, receiver in list_of_sender_and_receiver_pairs:
    handle_chat_async(sender, receiver)
```
As you can probably guess, using the callback oriented programming gets incredibly complicated and annoying fast. Have a look at the old style method of using the Twisted library for examples.

Now asyncio makes this programming easier by using Pythons coroutines. Basically, a coroutine is a routine that can halt execution and continued later:

```python
def simple_coro():
    name = yield "What is your name?"
    yield "Nice to meet you, " + name
```

```
>>> foo = simple_coro()
>>> foo.send(None) # Start execution, must be None
"What is your name?"
>>> foo.send("Sir Gallahad")
"Nice to meet you, Sir Gallahad"
```

Asyncio uses this to handle the callback functions for you. It has an event loop that basically waits for all events that the OS is notifying it (like "the read you issued some time ago just got some data") and then calls your coroutine.

```python
import some_async_framework as asyncio

def handle_chat_coro(sender, receiver):
    done = False
    while not done:
        data = yield from asyncio.read(sender)
        yield from asyncio.write(receiver, data)
        done = data == "BYE!"
```
I've used `some_async_framework` as a placeholder, because asyncio works a little differently (curio is closer to what I'm describing here).

Now, `some_async_framework` provides a read method that handles all the nasty internal stuff like registering callbacks, and yields some management information to the caller, which our method also directly yields to it's caller, and then waits. The trick is that the caller in this case is an event loop:

```python
for sender, receiver in list_of_sender_and_receiver_pairs:
    asyncio.start(handle_chat_coro, sender, receiver)

asyncio.start_loop()
```

From now on, only `start_loop` is running, and its implementation is something like this:

```python
stuff_to_do = []

def start(func, *params):
    stuff_to_do.append("call " + func + "with the parameters " + params)

def read(source):
    task_id = generate_taskid()
    def my_callback(data):
        stuff_to_do.append("notify " + task_id + "that the follwing data is available: " + data)

    source.read(callback=my_callback)
    yield "I am now task " + task_id + "that is waiting for data"

 def start_loop():
    while True:
        stuff = stuff_to_do.pop()  # lets assume pop will always return something, even if the list is empty
        if stuff.startswith("call"):
            func, params = get_func_and_params(stuff)
            coro = func(*params)
            result = coro.send(None)
            if result.startswith("I am now task "):
                store_coro_as_task(coro, result)

        if stuff.startswith("notify"):
            task_id, data = get_task_id_and_data_from_stuff(stuff)
            coro = get_coro_from_task_id(task_id)
            stuff_to_do.append(coro.send(data))
```

So what happens in our example is basically this:

`async.start(handle_chat_coro, sender,receiver)` is called, this adds it to the list of stuff to do (for each connection we want, but let's just assume it's only one connection)

once the loop runs, it will get the next stuff to do which is "call `handle_chat_coro` with ...". It does this

the `handle_chat_coro` coroutine will now call our readmethod, which will call the low level "read" function with a callback that, when it is called, will add "notify TASK\_ID that the following data..." to the list of stuff to do. It then yields "I am now task TASK\_ID...", which our `handle_chat_coro` coroutine will yield to its caller (which is the event loop) unchanged.

our event loop will then store the cororoutine (which is halted, but can continue once it is awoken again with send(data) in it's task structure and then do other stuff

Once the OS read calls the `my_callback` routine because data is available, "notify TASK\_ID..." is appended to the `stuff_to_do` list, and eventually will be reached by our event loop, in which case it will call coro.send(data), and our original coroutine can continue.

The advantage is that you don't have to know about all those nasty details how the event loop works, you just write `handle_chat_coro` and stuff just works. Notice how `handle_chat_coro` and `handle_chat` look very similar.

With Python 3.5, instead of yield from you can also use await which basically does the same thing. It's just easier to read and handles some corner cases better, so it could be written as:

```python
async def handle_chat_coro(sender, receiver):
    done = False
    while not done:
        data = await asyncio.read(sender)
        await asyncio.write(receiver, data)
        done = data == "BYE!"
```

