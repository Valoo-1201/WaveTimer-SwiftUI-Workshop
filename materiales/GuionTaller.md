# Guion del Taller: MindTimer con SwiftUI
## Construye un Timer Pomodoro con Animaciones de Ola

**Duración total:** 30–40 minutos
**Nivel:** Principiante-Intermedio (conoce Swift básico, nunca ha terminado una app completa)
**Herramienta:** Swift Playgrounds 4 en iPad o Xcode en Mac

---

## Objetivos del Taller

Al terminar este taller, los estudiantes habrán:

- Construido una app funcional de timer Pomodoro desde cero
- Comprendido el patrón de arquitectura MVVM y por qué existe
- Implementado una forma personalizada animada usando el protocolo `Shape`
- Conectado un `ViewModel` a una `View` usando `@StateObject` y `@Published`
- Aprendido a usar el timer reactivo de Combine con `Timer.publish`

---

## Lo Que Aprenderás

| Concepto | Herramienta SwiftUI |
|---|---|
| Separar lógica de UI | MVVM + `ObservableObject` |
| Notificar cambios a la vista | `@Published` |
| Crear formas a mano | Protocolo `Shape` + `Path` |
| Animar formas personalizadas | `animatableData` |
| Gestionar estado de la vista | `@StateObject` vs `@ObservedObject` |
| Timer reactivo | `Timer.publish` + Combine |

---

## Desglose de Tiempo

| Sección | Tiempo | Actividad |
|---|---|---|
| 1. Introducción y Demo | 5 min | Mostrar la app terminada, motivar |
| 2. MVVM y el ViewModel | 8 min | `ObservableObject`, `@Published`, timer |
| 3. La Forma de Ola | 10 min | `Shape`, `Path`, función seno |
| 4. La Vista Principal | 10 min | `@StateObject`, conectar todo |
| 5. Demo Final y Cierre | 5 min | Ejecutar la app, preguntas |

---

---

## SECCION 1: Introduccion y Demo (5 minutos)

### Para el Presentador

Abre el proyecto `MindTimerCompleto.swiftpm` en Swift Playgrounds o Xcode y ejecuta la app. Muestra en vivo:

1. El timer contando hacia abajo
2. La ola animada subiendo conforme pasa el tiempo
3. El cambio automatico a "Tiempo de descanso" al llegar a cero
4. El contador de sesiones completadas

### Guion de Introduccion

> "Hoy vamos a construir esta app de principio a fin en 30 minutos. No es un ejercicio de rellena-el-espacio -- vamos a escribir la logica real. Al terminar, tendran una app que funciona en su iPhone."

> "La app tiene tres partes: un ViewModel que maneja toda la logica, una forma de ola personalizada, y una vista que los conecta. Cada parte es independiente y tiene una responsabilidad clara."

### Punto de Discusion

Pregunta al grupo: "Cuantos de ustedes han intentado construir una app con un timer antes? Que fue lo mas dificil?"

---

### Concepto: Por Que MVVM?

Dibuja en la pizarra:

```
+--------------------+     acciones     +--------------------+
|                    | ---------------► |                    |
|       VISTA        |                  |    VIEW MODEL      |
|   (lo que se ve)   | ◄--------------- |  (logica + estado) |
|                    |  notifica cambios|                    |
+--------------------+                  +--------------------+
```

> "La Vista NUNCA calcula nada. Solo muestra. El ViewModel NUNCA dibuja nada. Solo calcula. Este acuerdo hace que el codigo sea facil de leer, de probar y de cambiar."

---

---

## SECCION 2: Arquitectura MVVM y el ViewModel (8 minutos)

### Abre el archivo: `TimerViewModel.swift`

El archivo ya tiene la estructura. Los estudiantes necesitan completar tres TODOs.

---

### TODO 1: Agregar `@Published` (2 minutos)

**Muestra el codigo actual:**
```swift
var timeRemaining: Int = 25 * 60
var isRunning: Bool = false
var isBreakMode: Bool = false
var sessionsCompleted: Int = 0
```

**Explica:**
> "`@Published` es como un altavoz. Cuando el valor cambia, grita 'CAMBIE!' y SwiftUI escucha y redibuja la vista. Sin `@Published`, la vista nunca se entera de los cambios -- el timer correria pero la pantalla quedaria congelada."

**El codigo correcto:**
```swift
@Published var timeRemaining: Int = 25 * 60
@Published var isRunning: Bool = false
@Published var isBreakMode: Bool = false
@Published var sessionsCompleted: Int = 0
```

**Checkpoint:** "Ven como `ObservableObject` en la clase y `@Published` en las propiedades trabajan juntos? `ObservableObject` dice 'esta clase puede ser observada' y `@Published` dice 'este valor especifico importa'."

---

### TODO 2: Implementar `toggleTimer()` (4 minutos)

**Explica primero el concepto de Combine:**
> "En vez de usar un `Timer` clasico con `@objc func`, usamos Combine. `Timer.publish` crea un stream de eventos -- como un rio que manda un evento cada segundo. `.sink` es donde nosotros 'recogemos' esos eventos y ejecutamos codigo."

**El codigo a escribir:**
```swift
func toggleTimer() {
    if isRunning {
        timer?.cancel() // Detiene el flujo del timer y libera el recurso
    } else {
        // Crea un flujo que emite un evento cada segundo en el hilo principal
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect() // Inicia el flujo automáticamente al conectarse
            .sink { [weak self] _ in // Recoge eventos; usa weak self para evitar fugas de memoria
                guard let self = self else { return } // Asegura que la referencia al objeto siga viva
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1 // Descuenta el tiempo si aún queda
                } else {
                    self.handleTimerCompletion() // Ejecuta lógica al finalizar el conteo
                }
            }
    }
    isRunning.toggle() // Cambia el estado de ejecución (Play/Pause)
}
```

**Explica `[weak self]`:**
> "Esta es una referencia debil. Evita un 'retain cycle' -- situacion donde el timer retiene al ViewModel y el ViewModel retiene al timer, y ninguno puede liberarse de memoria. `weak self` rompe ese ciclo."

**Explica `.main`:**
> "El timer dispara en el hilo principal. En iOS, NUNCA actualizamos la UI desde un hilo secundario. `.main` garantiza eso."

---

### TODO 3: Implementar `formatTime()` (2 minutos)

**El codigo a escribir:**
```swift
func formatTime() -> String {
    let minutes = timeRemaining / 60 // Calcula cuántos minutos completos hay
    let seconds = timeRemaining % 60 // Calcula los segundos restantes tras quitar los minutos
    
    // Formatea los valores como texto "MM:SS", asegurando siempre 2 dígitos por campo
    return String(format: "%02d:%02d", minutes, seconds)
}
```

**Explica `%02d`:**
> "El formato `%02d` significa: imprime un entero con minimo 2 digitos. Si tenemos 5 segundos, sin formato tendriamos '25:5' -- que se ve mal. Con `%02d` obtenemos '25:05'."

**Prueba mental para el grupo:**
- `timeRemaining = 1500` → minutos = 25, segundos = 0 → "25:00"
- `timeRemaining = 93` → minutos = 1, segundos = 33 → "01:33"

---

### Checkpoint del ViewModel

> "Abran el archivo. Tienen `@Published` en las cuatro propiedades? `toggleTimer()` tiene el `if isRunning` antes de `isRunning.toggle()`? `formatTime()` retorna algo diferente de '00:00'? Si si a todo, el ViewModel esta listo."

**Para verificar en codigo:**
```swift
let vm = TimerViewModel()
vm.toggleTimer()
print(vm.isRunning)   // true
print(vm.formatTime()) // "25:00"
```

---

### Tips para el Presentador -- Seccion 2

Si alguien pregunta por que usar una `class` y no un `struct` para el ViewModel: los `struct` en Swift son tipos de valor -- se copian al asignarse. `@StateObject` necesita una referencia estable, que solo una `class` puede proveer. Los `struct` se destruirian y recrearian, perdiendo todo el estado.

Si alguien pregunta por `AnyCancellable`: es el "recibo" de una suscripcion de Combine. Mientras exista, la suscripcion esta activa. Al destruirse (o llamar `.cancel()`), la suscripcion se cancela. Guardarlo en una propiedad evita que se destruya inmediatamente.

---

### Preguntas para el Grupo -- Seccion 2

- "Si sacamos `isRunning.toggle()` del final de `toggleTimer()`, que pasaria?"
  - El estado de running no cambiaria; el icono del boton siempre mostraria "play"
- "Por que necesitamos `timer?.cancel()` antes de crear uno nuevo?"
  - Sin cancelarlo, tendriamos dos timers corriendo a la vez, decrementando el tiempo el doble de rapido

---

---

## SECCION 3: La Forma de Ola con Shape (10 minutos)

### Concepto: El Protocolo `Shape`

**Explica en la pizarra:**
```
+----------------------------+
|    CGRect (area disponible)|
|                            |
|   ~~~~~~~~~                |  <- Path de la ola
|  /         \               |
| /           \~~~~~~~~~~/   |
|                            |
|############################|  <- Area rellena
+----------------------------+
```

> "SwiftUI no sabe dibujar olas. Pero nos da una herramienta: el protocolo `Shape`. Solo necesitas implementar un metodo: `path(in rect: CGRect) -> Path`. Dentro de ese metodo, tu decides donde va cada punto."

```swift
struct MiForma: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // ... agrega puntos y lineas
        return path
    }
}
```

---

### La Matematica de la Ola

**Explica la funcion seno:**
> "La funcion `sin(x)` produce valores entre -1 y +1 de forma suave y continua. Si tomamos valores de x de 0 a 2π (un ciclo completo) y los multiplicamos por 12, obtenemos una ola de ±12 pixeles de altura."

**Dibuja en la pizarra:**
```
  sin(x) * 12
     +12 |    *     *
         |  *   * *   *
      0  |*---------*---*-->
         |               *
    -12  |                 *
         +----+----+----+---
          0   pi/2  pi  3pi/2  2pi
```

> "El parametro `offset` desplaza esa ola hacia la derecha. Si animamos `offset` de 0 a 2π en un loop, la ola 'camina' sin fin -- exactamente lo que queremos."

**Formula completa:**
```
y = baseHeight + sin(relativeX * 2 * pi + offset) * 12
              ^                             ^
    posicion vertical             desplazamiento horizontal
```

---

### Abre el archivo: `WaveShape.swift`

---

### TODO 4: Implementar `animatableData` (2 minutos)

**Explica:**
> "Cuando SwiftUI anima entre dos valores, necesita saber QUE propiedad interpolar. `animatableData` es ese 'puente' entre SwiftUI y tu struct. Sin el, SwiftUI animaria el contenedor pero la forma saltaria instantaneamente."

**El codigo a escribir:**
```swift
var animatableData: Double {
    get { offset }
    set { offset = newValue }
}
```

> "Piensalo como decirle a SwiftUI: 'Cuando quieras animar esta forma, el valor que cambia es `offset`.'"

---

### TODO 5: La Funcion Seno en el Loop (5 minutos)

**Muestra el codigo actual:**
```swift
let y = baseHeight   // <- Reemplaza esto con la formula
```

**El codigo correcto (reemplaza la linea de `let y`):**
```swift
// Calculamos el valor de la onda basándonos en la posición horizontal (relativeX) y el offset (animación)
let seno = sin(relativeX * 2 * .pi + offset) 

// Definimos la altura final sumando la base (progreso del timer) + la amplitud de la onda (12px)
let y = baseHeight + (seno * 12)
```

**Desglose para el grupo:**

| Variable | Valor ejemplo | Significado |
|---|---|---|
| `relativeX` | 0.5 | Mitad del ancho del circulo |
| `sin(0.5 * 2π + 0)` | 0.0 | Cruce por cero |
| `baseHeight + 0 * 12` | `baseHeight` | Sin desviacion |
| `sin(0.25 * 2π)` | 1.0 | Cresta maxima |
| `baseHeight + 12` | `baseHeight + 12` | +12px arriba |

**Pregunta al grupo:** "Que pasaria si cambiamos el `12` por `30`? Y si lo cambiamos por `2`?"
> "Mas alto = olas mas dramaticas. Mas bajo = olas mas suaves. En una app real, podrias conectar esta amplitud al nivel de estres del usuario o al modo de la sesion."

---

### Concepto: `baseHeight` y `percent`

**Explica como funciona el llenado:**
> "`percent` va de 0.0 (timer recien iniciado) a 1.0 (timer completado). `baseHeight` es la altura desde donde empieza la ola. Cuando `percent = 0`, `baseHeight = rect.height` -- la ola esta en el fondo. Cuando `percent = 1`, `baseHeight = 0` -- la ola esta arriba. La ola sube conforme el timer avanza."

```
percent = 0.0         percent = 0.5         percent = 1.0
+----------+          +----------+          +----------+
|          |          |          |          |~~~~~~~~~~|
|          |          |~~~~~~~~~~|          |##########|
|          |          |##########|          |##########|
|          |          |##########|          |##########|
+----------+          +----------+          +----------+
(timer lleno)       (mitad del tiempo)    (tiempo agotado)
```

---

### Checkpoint de WaveShape

> "Tienen `animatableData` implementado? Tienen la formula del seno en el loop? El `let y = baseHeight` original debe estar reemplazado completamente."

**Para probar en un Preview temporal:**
```swift
#Preview {
    WaveShape(offset: 0, percent: 0.5)
        .fill(.purple.opacity(0.4))
        .frame(width: 300, height: 200)
}
```

Deben ver una ola estatica al 50% de altura.

---

### Tips para el Presentador -- Seccion 3

Si alguien tiene dudas sobre `stride(from:through:by:)`: es como un `for` loop pero para valores de punto flotante. `stride(from: 0.0, through: 270.0, by: 1.0)` produce los valores 0.0, 1.0, 2.0, ..., 270.0. Usamos esto en vez de `for x in 0...270` porque necesitamos `Double`, no `Int`.

Si alguien pregunta por que el loop va pixel a pixel y no usa curvas Bezier: las curvas Bezier son mas eficientes pero mas complejas de parametrizar con seno. Para tamaños de pantalla normales (~270px), el loop es imperceptible en rendimiento y mucho mas claro para aprender.

---

### Preguntas para el Grupo -- Seccion 3

- "Por que usamos `.pi * 2` (2π) para el loop de animacion y no simplemente `360`?"
  - La funcion `sin` en Swift trabaja en radianes, no en grados. Un ciclo completo son 2π radianes.
- "Que pasa si `offset` empieza en 0 y termina en π (la mitad de un ciclo)?"
  - La ola se movia hasta la mitad y rebotaria -- por eso usamos `autoreverses: false` y 2π completo.

---

---

## SECCION 4: La Vista Principal (10 minutos)

### Concepto: `@StateObject` vs `@ObservedObject`

**Explica la diferencia critica:**
> "`@StateObject` le dice a SwiftUI: 'crea esta instancia UNA VEZ y guardala'. `@ObservedObject` dice: 'alguien mas creo esto, solo observalo'. Si usaramos `@ObservedObject` para el ViewModel aqui, SwiftUI recrearia el ViewModel cada vez que la vista se redibuja -- el timer se resetearia solo!"

| Wrapper | Quien crea el objeto | Cuando se destruye |
|---|---|---|
| `@StateObject` | La vista misma | Cuando la vista desaparece |
| `@ObservedObject` | Alguien externo | Cuando el dueno lo destruye |

---

### Abre el archivo: `TimerView.swift`

---

### TODO 6: Agregar `WaveShape` al ZStack (3 minutos)

**Muestra la estructura actual del ZStack:**
```swift
ZStack {
    Circle()
        .stroke(Color.purple.opacity(0.15), lineWidth: 10)

    // <- WaveShape va aqui

    VStack(spacing: 6) {  // texto del tiempo
        Text("00:00")
        Text(vm.isRunning ? "En curso..." : "Listo")
    }
}
```

**El codigo a agregar (entre el Circle y el VStack):**
```swift
WaveShape(offset: waveOffset, percent: calculateProgress())
    .fill(Color.purple.opacity(0.45))
    .clipShape(Circle())
```

**Explica el orden del ZStack:**
> "En un `ZStack`, las vistas se apilan de atras hacia adelante. Primero el borde del circulo (mas atras), luego la ola, luego el texto del tiempo (al frente). Si pusieramos la ola despues del texto, taparia los numeros."

**Explica `clipShape(Circle())`:**
> "Sin `clipShape`, la ola sobresaldria del circulo -- veerian una ola rectangular fea. `clipShape(Circle())` recorta todo lo que este fuera del circulo, como una mascara."

---

### TODO 7: Conectar `vm.formatTime()` (1 minuto)

**Reemplaza:**
```swift
Text("00:00")
```

**Por:**
```swift
Text(vm.formatTime())
```

> "Una linea, pero crucial. Ahora el texto esta conectado al ViewModel -- cuando `timeRemaining` cambia, `@Published` notifica a SwiftUI, SwiftUI llama a `body` de nuevo, y `vm.formatTime()` devuelve el nuevo tiempo."

El ciclo de actualización automática:
Este pequeño cambio cierra el círculo de la reactividad:

Cambio: El Timer dentro del ViewModel modifica timeRemaining.

Notificación: Gracias a @Published, el ViewModel grita "¡Cambié!".

Redibujado: SwiftUI escucha el aviso y ejecuta nuevamente la función body de la vista.

Actualización: Al llamar a vm.formatTime(), la interfaz obtiene el valor más reciente y lo muestra al instante.

---

### TODO 8: Conectar el Boton Play/Pause (2 minutos)

Para lograr que el agua tenga movimiento constante, utilizaremos el modificador .onAppear. Este disparará una animación lineal que modificará el waveOffset de forma continua. Al trabajar con los límites de la función seno ($0$ a $2\pi$), garantizamos una transición imperceptible entre el final y el principio de la animación.

**Muestra el codigo actual del boton:**
```swift
Button(action: { }) {
    Image(systemName: "play.fill")
    ...
}
```

**El codigo correcto:**
```swift
Button(action: vm.toggleTimer) {
    Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
    ...
}
```

**Explica la referencia de funcion:**
> "`vm.toggleTimer` sin parentesis es una referencia a la funcion, no una llamada. Es como darle a `Button` el numero de telefono de `toggleTimer` para que lo llame cuando el usuario toca el boton."

**Explica el operador ternario:**
> "`vm.isRunning ? "pause.fill" : "play.fill"` -- si esta corriendo, muestra pausa; si no, muestra play. El icono cambia en tiempo real porque `isRunning` es `@Published`."

---

### Concepto: La Animacion de la Ola

**Senala el bloque `.onAppear`:**
```swift
.onAppear {
    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
        waveOffset = .pi * 2
    }
}
```

**Explica:**
> "`withAnimation` le dice a SwiftUI que anime el cambio de `waveOffset`. `.linear(duration: 3)` hace la animacion en 3 segundos a velocidad constante. `.repeatForever(autoreverses: false)` lo reinicia desde el principio en lugar de regresar -- eso es lo que hace que la ola camine siempre en la misma direccion."

> "Por que `0` a `2π`? Porque `sin(0) == sin(2π)` -- el valor del seno es identico al inicio y al final de un ciclo. El loop es invisible, la ola parece continua."

---

### Checkpoint Final

Pide al grupo que revisen este checklist antes de ejecutar:

- [ ] `TimerViewModel.swift`: `@Published` en las 4 propiedades
- [ ] `TimerViewModel.swift`: `toggleTimer()` con logica if/else
- [ ] `TimerViewModel.swift`: `formatTime()` con la formula real (no "00:00")
- [ ] `WaveShape.swift`: `animatableData` implementado
- [ ] `WaveShape.swift`: formula `seno * 12` en el loop (no `let y = baseHeight`)
- [ ] `TimerView.swift`: `WaveShape` presente en el ZStack
- [ ] `TimerView.swift`: `Text(vm.formatTime())` (no `Text("00:00")`)
- [ ] `TimerView.swift`: `Button(action: vm.toggleTimer)` con icono dinamico

---

### Tips para el Presentador -- Seccion 4

Si alguien pregunta sobre `calculateProgress()`: esta funcion ya estaba implementada en el starter. Convierte `timeRemaining` (en segundos) a un valor de 0.0 a 1.0 dividiendo sobre el tiempo total. El `1.0 -` invierte la direccion: al inicio el timer esta "lleno" de tiempo, asi que la ola empieza abajo y sube conforme el tiempo se acaba.

Si alguien pregunta por que `waveOffset` es `@State` y no `@Published`: `@State` es para estado LOCAL de la vista (solo la animacion visual). No necesita estar en el ViewModel porque no es logica de negocio -- es puramente visual.

---

### Preguntas para el Grupo -- Seccion 4

- "Que pasaria si cambiamos `@StateObject` por `@ObservedObject` en la vista?"
  - El ViewModel se recrearia en cada redibujado; el timer se resetearia solo al cambiar cualquier estado
- "Por que el `onAppear` esta en el ZStack y no en el VStack exterior?"
  - Podria estar en cualquier lugar de la jerarquia; esta en el ZStack porque semanticamente pertenece al circulo animado

---

---

## SECCION 5: Demo Final y Cierre (5 minutos)

### Ejecutar la App

1. Pide a todos que ejecuten su app en Swift Playgrounds o el simulador
2. Da 2 minutos para que prueben el timer
3. Pide a alguien voluntario que muestre su pantalla

**Verificacion rapida:**
- La ola se mueve horizontalmente sin parar
- Al presionar play, el contador baja y la ola sube
- Al presionar pause, todo se congela
- Al llegar a 00:00, cambia a verde (modo descanso)
- El contador de sesiones sube

---

### Conexion con MindTides

La app completa MindTides usa este mismo patron en su timer, pero agrega:

- Un selector de tiempo (15, 20, 25, 30 min)
- Una tarjeta de sugerencia segun la hora del dia
- Integracion con el sistema de tareas y el diario de animo
- Persistencia de sesiones con SwiftData

---

### Ideas de Extension (para llevar a casa)

1. **Segundo layer de ola** -- Agrega un segundo `WaveShape` con `offset: waveOffset + 1.5` para profundidad
2. **Sonido de notificacion** -- Usar `AVFoundation` para reproducir un tono en `handleTimerCompletion()`
3. **Haptic feedback** -- Agregar `UIImpactFeedbackGenerator` al presionar los botones
4. **Persistencia** -- Guardar `sessionsCompleted` con `@AppStorage`
5. **Personalizacion** -- Agregar un `Slider` para ajustar la duracion del foco

---

### Preguntas Frecuentes del Cierre

**P: Por que usar Combine y no un simple `Timer.scheduledTimer`?**
R: `Timer.scheduledTimer` funciona, pero `Timer.publish` de Combine se integra mejor con el sistema reactivo de SwiftUI, maneja la gestion de memoria automaticamente, y es mas facil de cancelar limpiamente.

**P: El `for` que dibuja la ola es lento? Itera pixel a pixel.**
R: Para tamaños de pantalla normales (300-400px de ancho) son ~400 iteraciones de matematica simple. En la practica es imperceptible. SwiftUI tambien optimiza el redibujado con sus propios caches.

**P: Puedo usar una imagen o GIF en lugar de calcular la ola?**
R: Si, pero pierde la capacidad de responder al progreso real. Con `Shape`, la ola sube exactamente al ritmo del timer. Con una imagen, tendrias que hacer un loop fijo desconectado de la logica.

---

### Cierre

> "Construyeron una app funcional con arquitectura real. El patron que usaron hoy -- ViewModel separado, vistas tontas, `@Published` para reactividad -- es exactamente lo que usan los equipos de iOS en produccion."

> "La diferencia entre un proyecto de tutorial y una app real no es la cantidad de codigo. Es la claridad de responsabilidades. Hoy aprendieron a separar lo que se muestra de como funciona."

---

## Recursos para Seguir Aprendiendo

- Apple SwiftUI Tutorials: developer.apple.com/tutorials/swiftui
- Hacking with Swift -- 100 Days of SwiftUI: hackingwithswift.com/100/swiftui
- Combine Framework Documentation: developer.apple.com/documentation/combine
- Swift Playgrounds App (gratis en Mac/iPad)

---

## Notas del Presentador

- Lleva el proyecto `MindTimerCompleto.swiftpm` listo en tu dispositivo antes de empezar
- Si alguien se queda atras, recuerdales que el codigo completo esta en la carpeta `completed/`
- Los TODOs tienen numeros del 1 al 8 -- ve en orden, no saltes
- Si Swift Playgrounds tiene lag al animar, es normal en simuladores lentos -- en dispositivo real va fluido
- El archivo `CheatSheet.md` en la carpeta del workshop es para que los estudiantes lo tengan abierto como referencia durante todo el taller

---

*Taller basado en MindTides -- app de productividad para estudiantes universitarios*
