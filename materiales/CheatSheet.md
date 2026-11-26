# CheatSheet: MindTimer Workshop
## Referencia Rapida de SwiftUI

---

## Property Wrappers de SwiftUI

| Wrapper | Uso | Donde | Ejemplo |
|---|---|---|---|
| `@State` | Estado local de la vista | Solo en `View` | `@State var isOn = false` |
| `@StateObject` | Crear y poseer un `ObservableObject` | En la vista duena | `@StateObject var vm = MyVM()` |
| `@ObservedObject` | Observar un objeto creado externamente | En vistas hijas | `@ObservedObject var vm: MyVM` |
| `@Published` | Notificar cambios a observadores | Dentro de una clase | `@Published var count = 0` |
| `@Binding` | Compartir estado entre vistas | Vista hija | `@Binding var isOn: Bool` |
| `@AppStorage` | Leer/escribir UserDefaults | En `View` | `@AppStorage("key") var val = 0` |
| `@Environment` | Leer valores del entorno de SwiftUI | En `View` | `@Environment(\.colorScheme) var cs` |

### Cuando usar cada uno

```
Necesito estado LOCAL de la vista        -->  @State
Necesito CREAR un ViewModel              -->  @StateObject
Mi padre me paso el ViewModel            -->  @ObservedObject
Quiero que la Vista se entere del cambio -->  @Published (en el ViewModel)
```

---

## Diagrama MVVM

```
+------------------+                     +----------------------+
|                  |   vm.toggleTimer()  |                      |
|     TimerView    | ------------------> |   TimerViewModel     |
|                  |                     |                      |
|  @StateObject    |                     |  @Published var      |
|  private var vm  |                     |  timeRemaining: Int  |
|                  |                     |  isRunning: Bool     |
|  Text(           | <------------------ |                      |
|   vm.formatTime()|  notifica @Published|  func toggleTimer()  |
|  )               |                     |  func formatTime()   |
+------------------+                     +----------------------+
         |                                          |
         | .fill(.purple)                           | Timer.publish
         | .clipShape(Circle())                     | .sink { }
         v                                          v
+------------------+                     +----------------------+
|   WaveShape      |                     |   AnyCancellable     |
|   (Shape)        |                     |   (referencia al     |
|                  |                     |    timer activo)     |
|  animatableData  |                     |                      |
|  path(in:)       |                     |  se cancela al       |
+------------------+                     |  llamar .cancel()    |
                                         +----------------------+
```

---

## Protocolo Shape -- Referencia Rapida

```swift
struct MiForma: Shape {

    // 1. Propiedades animables
    var miValor: Double

    // 2. Decirle a SwiftUI que animar
    var animatableData: Double {
        get { miValor }
        set { miValor = newValue }
    }

    // 3. El unico metodo requerido
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: 0))              // Empezar aqui
        path.addLine(to: CGPoint(x: rect.width, y: 0))  // Linea recta
        // path.addCurve(...)                            // Curva Bezier
        path.closeSubpath()                              // Cerrar la forma

        return path
    }
}
```

### CGRect -- Propiedades utiles

| Propiedad | Valor |
|---|---|
| `rect.width` | Ancho disponible |
| `rect.height` | Alto disponible |
| `rect.midX` | Centro horizontal |
| `rect.midY` | Centro vertical |
| `rect.minX` | Borde izquierdo (0) |
| `rect.maxX` | Borde derecho |

---

## Animacion -- Referencia Rapida

### Tipos de animacion

```swift
// Animacion simple
withAnimation {
    miValor = nuevoValor
}

// Con tipo especifico
withAnimation(.linear(duration: 1.0)) {
    miValor = nuevoValor
}

// En loop sin rebote (para la ola)
withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
    waveOffset = .pi * 2
}

// Spring (rebote natural)
withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
    miValor = nuevoValor
}
```

### Tipos de curva

| Curva | Comportamiento |
|---|---|
| `.linear` | Velocidad constante |
| `.easeIn` | Empieza lento, termina rapido |
| `.easeOut` | Empieza rapido, termina lento |
| `.easeInOut` | Lento al inicio y al final |
| `.spring(...)` | Efecto de resorte |

### Animacion en Shape

```swift
// animatableData permite que SwiftUI interpole
// los valores de la forma durante la animacion
var animatableData: Double {
    get { offset }
    set { offset = newValue }
}
```

---

## Modificadores SwiftUI del Proyecto

```swift
// Texto
.font(.system(size: 68, weight: .bold, design: .rounded))
.foregroundStyle(.purple)
.foregroundStyle(.secondary)

// Layout
.padding(24)
.frame(width: 270, height: 270)
VStack(spacing: 36) { }
HStack(spacing: 52) { }
ZStack { }

// Formas
.fill(Color.purple.opacity(0.45))
.stroke(Color.purple.opacity(0.15), lineWidth: 10)
.clipShape(Circle())

// Sombra
.shadow(color: Color.purple.opacity(0.35), radius: 10, x: 0, y: 5)

// Eventos
.onAppear { }

// Botones
Button(action: vm.toggleTimer) { }
Button(action: { /* closure */ }) { }
```

---

## Funciones Matematicas Usadas

```swift
// Funcion seno -- produce valores entre -1.0 y 1.0
sin(x)           // x en RADIANES (no en grados)
sin(0)           // = 0.0
sin(.pi / 2)     // = 1.0  (cresta maxima)
sin(.pi)         // = 0.0
sin(3 * .pi / 2) // = -1.0 (valle minimo)
sin(2 * .pi)     // = 0.0  (ciclo completo, igual que sin(0))

// Constante pi
Double.pi        // 3.14159...
.pi              // Shorthand dentro de contexto Double

// Stride -- loop con paso personalizado (para Double)
stride(from: 0.0, through: 270.0, by: 1.0)
// Produce: 0.0, 1.0, 2.0, ..., 270.0
// (a diferencia de 0...270 que solo funciona con Int)

// Formato de strings con ceros
String(format: "%02d:%02d", minutos, segundos)
// %d   = entero
// %02d = entero con minimo 2 digitos (rellena con 0 a la izquierda)
// Ejemplo: String(format: "%02d", 5) = "05"
// Ejemplo: String(format: "%02d:%02d", 1, 3) = "01:03"
```

---

## Combine -- Timer Reactivo

```swift
import Combine

// Tipo de la propiedad
private var timer: AnyCancellable?

// Crear un timer que dispara cada segundo en el hilo principal
timer = Timer.publish(every: 1, on: .main, in: .common)
    .autoconnect()               // Empieza inmediatamente
    .sink { [weak self] _ in     // Cada segundo ejecuta esto
        guard let self = self else { return }
        // Tu logica aqui
        self.timeRemaining -= 1
    }

// Cancelar el timer
timer?.cancel()
```

### Por que [weak self]

```
Sin [weak self]:  timer --> ViewModel --> timer  (ciclo, nunca se libera)
Con [weak self]:  timer --> ViewModel (debil)    (se puede liberar)
```

---

## Patrones Comunes en el Proyecto

### Operador ternario

```swift
// condicion ? valorSiTrue : valorSiFalse
vm.isRunning ? "pause.fill" : "play.fill"
vm.isBreakMode ? Color.green : Color.purple
```

### Referencia de funcion vs llamada

```swift
Button(action: vm.toggleTimer)       // REFERENCIA (sin parentesis) -- correcto
Button(action: vm.toggleTimer())     // LLAMADA INMEDIATA -- incorrecto!
Button(action: { vm.toggleTimer() }) // Closure equivalente -- tambien valido
```

### Progreso del timer (0.0 a 1.0)

```swift
// Convierte segundos restantes a porcentaje
// 0.0 = inicio (ola abajo), 1.0 = fin (ola arriba)
let total = Double(vm.focusTime)
let progress = 1.0 - (Double(vm.timeRemaining) / total)
```

---

## Errores Comunes

| Error | Causa | Solucion |
|---|---|---|
| Vista no se actualiza | Falta `@Published` | Agrega `@Published` a la propiedad en el ViewModel |
| Ola no se anima | Falta `animatableData` | Implementa el computed property en `WaveShape` |
| Timer no inicia | `action` del boton vacio | Conecta `Button(action: vm.toggleTimer)` |
| Tiempo siempre "00:00" | `formatTime()` no implementado | Reemplaza el `return "00:00"` con la formula real |
| Ola sale del circulo | Falta `clipShape` | Agrega `.clipShape(Circle())` a la ola |
| Retain cycle | Referencia fuerte en closure | Usa `[weak self]` en el `.sink {}` |

---

## Atajos de Teclado

### Xcode

| Atajo | Accion |
|---|---|
| `Cmd + R` | Ejecutar app |
| `Cmd + B` | Compilar |
| `Cmd + .` | Detener app |
| `Cmd + /` | Comentar/descomentar linea |
| `Cmd + Shift + O` | Abrir archivo rapido |
| `Cmd + Option + Enter` | Mostrar Canvas (Preview) |
| `Cmd + Option + P` | Refrescar Preview |
| `Ctrl + I` | Auto-indentar seleccion |
| `Cmd + [` / `Cmd + ]` | Disminuir/aumentar indentacion |
| `Cmd + Shift + K` | Limpiar proyecto |

### Swift Playgrounds (iPad)

| Atajo | Accion |
|---|---|
| `Cmd + R` | Ejecutar |
| `Cmd + .` | Detener |
| `Cmd + /` | Comentar linea |
| `Cmd + Z` | Deshacer |
| `Cmd + Shift + Z` | Rehacer |

---

*MindTides Workshop -- Referencia rapida para el taller*
