## EDOs de 1er orden

### Independientes de y
```math
y' = f(x) \longrightarrow y(x) = \int f(x)dx + C
```
### Variables separadas
```math
y' = \frac{f(x)}{g(y)} \longrightarrow \int g(y)dy = \int f(x)dx
```

### Homogéneas
Son ecs tal que $`y' = f(x, y) = f(\lambda x, \lambda y)`$.

Se resuelven con el cambio $`y = xu`$, que la transforma en una de variables separadas.

??? example "$`y' = \frac{2xy - y^2}{x^2}`$"
    Comprobamos que es homogénea: $`f(\lambda x, \lambda y) = f(x, y)`$
    ``` math
    f(\lambda x, \lambda y) = \frac{\lambda^2(2xy - y^2)}{\lambda^2 x^2} = \frac{2xy - y^2}{x^2} = f(x, y)

    y = xu \longrightarrow y' = u'x + u = \frac{2x^2 u - x^2 u^2}{x^2} = 2u - u^2
    ```


### Lineales
Son del tipo $`y' = a(x) y + b(x)`$.

Si $`b(x) = 0`$ (homogéneas) se resuelve por variables separadas.

En caso contrario (inhomogéneas) se resuelve por el método de variación de constantes:

1. Resolver la homogénea asociada $`\longrightarrow y_h`$
2. La solución particular, $`y_p`$, se obtiene a partir de la homogénea, considerando que la constante de integración depende de x. Resolvemos C(x) tras introducirla en la diferencial.

La solución general es la suma de ambas soluciones $`\longrightarrow y = y_p + y_h`$


### Exactas
```math
y' = \frac{- P(x, y)}{Q(x, y)} \longrightarrow P(x, y)dx + Q(x, y)dy = 0
P(x, y) = F_x(x, y)
Q(x, y) = F_y(x, y)
\longrightarrow P_y = Q_x = F_xy = F_yx \longrightarrow Ec. Exacta
```
La solución es de la forma $`F(x, y) = C`$


### Reducibles a exactas
Si $`P(x, y)dx + Q(x, y)dy = 0`$ quizás podemos encontrar una función $`\mu`$ no idénticamente nula tal que $`\mu P(x, y) + \mu Q(x, y) y' = 0`$
donde $`(\mu P)_y = (\mu Q)_x \longrightarrow P_y \mu + P \mu_y = Q_x \mu + Q \mu_x`$

$`\mu`$ se denomina factor integrante, y los casos más sencillos son $`\mu = \mu(x)`$ o $`\mu = \mu(y)`$

Continuara...


### De la forma y' = f(ax + by)
Hacemos el cambio $`z = ax + by`$ que la transforma en una de variables separadas


### Reducibles a homogéneas
Son de la forma $`y' = f(\frac{a_1 x + b_1 y + c}{a x + by + c})`$. Cada miembro de la fracción parece una recta. Tenemos por tanto dos formas de resolverlas:
=== "Las rectas se cortan"
    Encontramos el punto de corte de las rectas, $`(x_0, y_0)`$, y hacemos el cambio de variable
    $`X = x - x_0`$
    $`Y = y - y_0`$
    Reduce el problema a una homogénea

=== "Las rectas son paralelas"
    El cambio $`z = ax + by`$ que la reduce a una de variables separadas


### Bernuilli
Son del tipo $`y' = a(x) y + b(x) y^r`$. Se hace el cambio $`\mu = y^{1-r}`$ tal que:
```math
\mu' = (1-r)y^r y' = (1-r)(a(x)\mu + b(x)
```
Obtenemos una ecuacion lineal que resolvemos por el método de variación de constantes


### Ricatti
Son del tipo $`y' = a(x) y + b(x) y^2 + c(x)`$. El método require encontrar previamente una solución particular al tanteo.
Una vez hallada, se hace el cambio $`y = y_p + z`$, que reduce la ec a una de Bernuilli.


## EDOs de orden n
### Homogéneas Lu = 0
Son ecuaciones de la forma $`\mu^{(n)} + a_{n-1}(x)\mu^{(n-1)} + ... + a_1(x)\mu' + a_0(x)\mu = 0`$


#### Reduccion de orden 2
El método requiere conocer una solución previa. Una vez obtenida, calculamos la segunda solución
$`\mu_2(x) = \mu_1(x) \int \frac{exp[-\int a_1(x)dx]}{\mu_1^2(x)}dx`$


#### Coeficientes constantes

### Inhomogéneas Lu = b
Son ecuaciones de la forma $`\mu^{(n)} + a_{n-1}(x)\mu^{(n-1)} + ... + a_1(x)\mu' + a_0(x)\mu = b`$


#### Variacion de constantes de Lagrange
#### Coeficientes indeterminados
