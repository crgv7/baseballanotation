import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:baseballanotation/services/database_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  Future<String?> _getExportDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Solicitar permisos
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();

        // Obtener el directorio de almacenamiento externo
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          print('No se pudo obtener el directorio de almacenamiento externo');
          return null;
        }

        // Convertir la ruta a la carpeta Android/data a la raíz del almacenamiento
        final List<String> paths = directory.path.split('/');
        int androidIndex = paths.indexOf('Android');
        if (androidIndex == -1) {
          return directory.path;
        }

        // Construir la ruta a la carpeta Download
        final String rootPath = paths.sublist(0, androidIndex).join('/');
        final downloadPath = '$rootPath/Download';
        
        // Crear el directorio si no existe
        final downloadDir = Directory(downloadPath);
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        print('Directorio de exportación: ${downloadDir.path}');
        return downloadDir.path;
      }

      // Para iOS
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      print('Error detallado al obtener directorio: $e');
      return null;
    }
  }

  Future<void> _exportDatabase(BuildContext context) async {
    try {
      // Mostrar diálogo de progreso
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Obtener la ruta de la base de datos actual
      String databasePath = await getDatabasesPath();
      String currentDbPath = join(databasePath, 'baseball_stats.db');

      // Verificar si la base de datos existe
      if (!await File(currentDbPath).exists()) {
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay base de datos para exportar'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Obtener directorio de exportación
      final exportDir = await _getExportDirectory();
      print('Directorio de exportación obtenido: $exportDir');
      
      if (exportDir == null) {
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo acceder al directorio de almacenamiento. Por favor, verifica los permisos de la aplicación en la configuración del dispositivo.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp('[:]'), '-');
      final backupPath = join(exportDir, 'baseball_backup_$timestamp.db');
      print('Intentando copiar a: $backupPath');

      // Copiar la base de datos
      await File(currentDbPath).copy(backupPath);
      print('Archivo copiado exitosamente');

      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Base de datos exportada exitosamente'),
              const SizedBox(height: 4),
              Text(
                'Ubicación: Carpeta Descargas/baseball_backup_$timestamp.db',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      print('Error detallado al exportar: $e');
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar la base de datos: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _importDatabase(BuildContext context) async {
    try {
      // Seleccionar archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final String filePath = result.files.single.path!;
        final String extension = filePath.split('.').last.toLowerCase();

        // Verificar que sea un archivo .db
        if (extension != 'db') {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor selecciona un archivo de base de datos (.db)'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Mostrar diálogo de confirmación
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Confirmar Importación'),
              content: const Text(
                  '¿Estás seguro que deseas importar esta base de datos? La base de datos actual será reemplazada.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Importar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          String databasePath = await getDatabasesPath();
          String targetPath = join(databasePath, 'baseball_stats.db');

          // Cerrar la base de datos actual
          await DatabaseServices.instance.closeDatabase();

          // Copiar el archivo seleccionado
          await File(filePath).copy(targetPath);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Base de datos importada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );

          // Reiniciar la aplicación
          if (!context.mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al importar la base de datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showResetConfirmationDialog(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Reinicio'),
          content: const Text(
              '¿Estás seguro que deseas reiniciar la base de datos? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Reiniciar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DatabaseServices.instance.resetDatabase();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base de datos reiniciada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          // Sección de Tema
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  title: const Text('Tema Oscuro'),
                  subtitle: Text(themeProvider.isDarkMode ? 'Activado' : 'Desactivado'),
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ),
          // Sección de Base de Datos
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Base de Datos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Crear Copia de Seguridad'),
                  subtitle: const Text('Crear una copia de seguridad de la base de datos'),
                  onTap: () => _exportDatabase(context),
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restaurar desde Copia de Seguridad'),
                  subtitle: const Text('Restaurar la base de datos desde una copia de seguridad'),
                  onTap: () => _importDatabase(context),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Eliminar Todos los Datos'),
                  subtitle: const Text('Eliminar todos los datos de la base de datos'),
                  onTap: () => _showResetConfirmationDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
