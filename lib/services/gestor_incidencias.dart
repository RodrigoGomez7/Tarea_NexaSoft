
import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];

  Future<void> iniciar() async {
    incidencias = await datos.leer();
  }

  // BUG-002: busca en título y descripción,
  // ignorando mayúsculas y espacios exteriores.
  List<Incidencia> buscar(String texto) {
    final consulta = texto.trim().toLowerCase();

    if (consulta.isEmpty) {
      return incidencias;
    }

    return incidencias.where((x) {
      final titulo = x.titulo.toLowerCase();
      final descripcion = x.descripcion.toLowerCase();

      return titulo.contains(consulta) ||
          descripcion.contains(consulta);
    }).toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) {
        return x;
      }
    }
    return null;
  }

  // BUG-003: calcula el contador con los estados actuales.
  int contar(String estado) {
    return incidencias.where((x) => x.estado == estado).length;
  }

  // BUG-001: guarda los cambios de estado en almacenamiento local.
  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        await datos.guardar(incidencias);
        return;
      }
    }
  }
  
  // FEAT-001: actualiza y guarda la prioridad de una incidencia.
  Future<void> cambiarPrioridad(String id, String prioridad) async {
    const prioridadesValidas = ['Baja', 'Media', 'Alta'];

    if (!prioridadesValidas.contains(prioridad)) {
      throw ArgumentError('La prioridad seleccionada no es válida.');
    }

    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].prioridad = prioridad;
        await datos.guardar(incidencias);
        return;
      }
    }

    throw StateError('No se encontró la incidencia con ID $id.');
  }



  Future<void> crear(
    String titulo,
    String descripcion,
    String cliente,
    String categoria,
    String prioridad,
  ) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      prioridad: prioridad,
      fecha: DateTime.now().toIso8601String().split('T').first,
    );

    incidencias.insert(0, nuevo);
    await datos.guardar(incidencias);
  }


  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}