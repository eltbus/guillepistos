Junto con mis compañeros de piso estamos valorando tener nuestras propias gallinas. Las ventajas son innumerables. Bueno, *not really*:

1. Nos permite tener huevos de forma económica[^1].
2. Garantizamos las condiciones de vida de estas.
3. Damos uso a restos de comida.

No hay más ventajas. *Big brain time.*

## Cuidados
Como cualquier ser vivo necesitamos cubrir 3 apartados principales: agua, comida, y alojamiento.

### Agua
Lo más importante. Deben estar siempre bien hidratadas.

En épocas de calor pueden tomar hasta medio litro al día (!casi una cuarta parte de su peso!).

Debe ser agua limpia y fresca. El bebedero debe tener una construcción que dificulte que las propias gallinas contaminen su agua.

### Comida

- [Ajo](https://www.gallinaponedora.com/los-beneficios-del-ajo/): mezclar un poco con el agua, o picado con el resto de la comida. 3-4 veces por semana debe de estar bien.
- Gravilla. Como lo oyes. La necesitan para facilitar su digestión.
- Alimentos con calcio: sobretodo en verano, ya que comen menos. Sin él pondrán huevos de cascara fina, e incentivarán a estas a "reciclar los huevos".

!!! danger "Alimentos peligrosos"
    En general, evitar sobras grasientas, mohosas o pasadas, huevos, lácteos, sal, azucar, y cebollas.

### Alojamiento
Aunque queremos que campen a sus anchas, necesitamos darles un refugio para protegerlas de las inclemencias del tiempo y depredadores. Además será su zona tranquila donde poner huevos a gusto.

[Esta vivienda sencilla para dos gallinas](https://www.youtube.com/watch?v=VRqRuwYad4g&t=1s), nos puede dar una idea del tamaño. Me gustaría, sin embargo, que tuviesen más espacio.

##  Gallinas: bueno, bonito, barato
Aunque es indudable que *coger prestadas* las gallinas es la alternativa más competitiva en cuanto a precios, tanto el carácter leal y noble de estas, así como los posibles problemas legales derivados del *préstamo*, nos alejan de esta magnífica opción. En su lugar, nos decantamos por la [Granja Santa Isabel](https://www.granjasantaisabel.com/gallinas-ponedoras.php)[^2].

De su catálogo nos gustan la [roja](https://www.granjasantaisabel.com/gallinas-ponedoras/ponedora-roja.php), y la [negra](https://www.granjasantaisabel.com/gallinas-ponedoras/ponedora-negra.php). Ambas ponen más de 250 huevos al año, de unos 63 gramos, pero destacamos la negra: tiene un sistema inmunológico muy fuerte.

#### Gallina
El precio de la gallina en si depende de la edad del pollito. [Es el mismo para las dos variedades que nos interesan](https://www.granjasantaisabel.com/tienda.php#!/Ponedora-Negra/p/13758104/category=4237113).

#### Mantenimiento
Tenemos la suerte de tener un terreno disponible y, además, conocer a un chaval que podría encargase de cuidarlas. El problema es: ¿qué incentivo podría tener para cuidarlas?

Hemos pensado pagarle tanto por hora como por huevo.

Ahora bien, seamos razonables. Esta tarea no va a darle un salario digno. No vamos a comprar 900€ de huevos.

### Pero, ¿esto es rentable?
A parte de la inversión inicial en gallinas y gallineros, ¿cuánto cuesta cada huevo?

Se puede hacer un pequeño programita de Python para pensar en los costes asociados variando distintas dimensiones, tal que podamos elegir una combinacion interesante. Como no suelo usar clases, voy a practicar un poquito, pero no esperes un programa super limpio  y perfecto. Estoy cansado ya de pensar en gallinas.

=== "Trabajador"
    ```python
    class Trabajador:
        def __init__(self, salario_por_hora: float, duracion_jornada: float):
            self.salario_por_hora = salario_por_hora
            self.duracion_jornada = duracion_jornada

        def salario_turno(self):
            return self.duracion_jornada * self.salario_por_hora
    ```

=== "Gallina"
    ```python
    class Gallina:
        def __init__(self, huevos_por_dia: float, gasto_manutencion: float):
            self.huevos_por_dia = huevos_por_dia
            self.gasto_manutencion = gasto_manutencion
    ```

=== "Granja"
    ```python
    from typing import List

    class Granja:
        def __init__(
                self,
                gallinas: List[Gallina],
                trabajadores: List[Trabajador],
                bonus_por_huevo: float):
            'La granja define un bonus_por_huevo por huevo recogido'
            self.gallinas = gallinas
            self.trabajadores = trabajadores
            self.bonus_por_huevo = bonus_por_huevo

        def produccionDeHuevosPorDia(self):
            return sum(i.huevos_por_dia for i in self.gallinas)

        def gastoGranjaPorDia(self):
            gasto_gallinas_por_dia = sum(i.gasto_manutencion for i in self.gallinas)
            gasto_trabajadores_por_dia = sum(i.salario_turno() for i in self.trabajadores)
            bonus = self.bonus_por_huevo * self.produccionDeHuevosPorDia()
            return gasto_gallinas_por_dia + gasto_trabajadores_por_dia + bonus
    ```


=== "Fábrica de granjas"
    ```python
    def poblarGranja(
            numero_gallinas: int,
            salario_por_hora: float,
            bonus_por_huevo: float,
            duracion_jornada: float,
            huevos_por_dia: float = 250/365,
            gasto_manutencion: float = .05):
        gallinas = [Gallina(huevos_por_dia, gasto_manutencion) for i in range(numero_gallinas)]
        trabajadores = [Trabajador(salario_por_hora, duracion_jornada)]
        return Granja(gallinas, trabajadores, bonus_por_huevo)


    def genParams():
        for numero_gallinas in range(5, 10):
            for salario_por_hora in range(5, 10):
                for bonus_por_huevo in range(1, 11):
                    for duracion_jornada in range(2, 10):
                        yield numero_gallinas, salario_por_hora, bonus_por_huevo/20, duracion_jornada/10


    def generarStatsMultiplesGranjas():
        for numero_gallinas, salario_por_hora, bonus_por_huevo, duracion_jornada in genParams():
            granja = poblarGranja(numero_gallinas, salario_por_hora, bonus_por_huevo, duracion_jornada)
            coste_huevo = round(granja.gastoGranjaPorDia() / granja.produccionDeHuevosPorDia(), 2)
            yield numero_gallinas, salario_por_hora, bonus_por_huevo, duracion_jornada, coste_huevo
    ```

=== "Filtros"
    ```python
    def granjasConHuevosBaratos(precio_huevo_maximo, granjas):
        return filter(lambda x: x[4] < precio_huevo_maximo, granjas)


    def granjasConMejorSalarioHora(granjas):
        return max(granjas, key=lambda x: x[1])
    ```



=== "Ejecucion"
    ```python
    if __name__ == '__main__':
        granjas = generarStatsMultiplesGranjas()
        granjas_con_huevos_baratos = granjasConHuevosBaratos(precio_huevo_maximo=.4, granjas=granjas)
        granjas_con_huevos_baratos_con_mejores_condiciones = granjasConMejorSalarioHora(granjas_con_huevos_baratos)
        cols = [
            'numero de gallinas: ',
            'salario por hora (€/h): ',
            'bonus por huevo (€/huevo): ',
            'duracion jornada (h): ',
            'coste_huevo (€): '
        ]
        for i, j in zip(cols, granjas_con_huevos_baratos_con_mejores_condiciones):
            print(i, j)
    ```

=== "Resultado"
    ```
    numero de gallinas 7
    salario por hora (€/h) 6
    bonus por huevo (€/huevo) 0.05
    duracion jornada (h) 0.2
    coste_huevo (€) 0.37
    ```

Vaya, que para poder subirle el salario por hora necesitamos más gallinas.

[^1]: *económica* en el sentido de "relativo a la economía", pues es bastante más caro.
[^2]: [Granja Santa Isabel](https://www.granjasantaisabel.com), ¿me pagas publicidad o cómo hacemos?
