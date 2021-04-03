# Introduccion
Decorators can be very useful to add actions to functions.

## Simple decorator
```python
from functools import wraps


def decorator(fun):
    @wraps(fun)  # Persist original function name, docstring, arguments list, etc.
    def _wrapper(*args, **kwargs):
        # Do whatever
        result = fun(*args, **kwargs)
        # Do whatever
        return result
    return _wrapper


@decorator
def myfun():
    pass
```

## Decorator with args
```python
from functools import wraps

def decoratorWithArgs(*dargs, **dkwargs):
    '*dargs and *dkwargs can be used to modify the properties of the decorator'
    def actual_decorator(fun):
        @wraps(fun)  # Persist original function name, docstring, arguments list, etc.
        def _wrapper(*args, **kwargs):
            # Do whatever
            result =  fun(*args, **kwargs)
            # Do whatever
            return result
        return _wrapper
    return actual_decorator


@decoratorWithArgs(verbose=True)
def myfun():
    pass
```
