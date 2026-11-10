import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://klbqlbhhdgqzvodukjzw.supabase.co',
    publishableKey: 'sb_publishable_d1FyJ8GoFJ-_ha87ZUPq2g_B7Td-Bom',
  );

  runApp(const DirectoDelCampoApp());
}

class DirectoDelCampoApp extends StatelessWidget {
  const DirectoDelCampoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Directo del Campo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          'Directo del Campo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.agriculture,
                size: 90,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Del campo a tu negocio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF245C29),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Conectamos productores agrícolas '
                'con compradores comerciales.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Ingresar'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistroPage(),
                      ),
                    );
                  },
                  child: const Text('Registrarse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _iniciarSesion() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _cargando = true;
  });

  try {
    // 1. Autenticar al usuario
    final respuesta = await Supabase.instance.client.auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    final usuario = respuesta.user;

    if (usuario == null) {
      throw Exception('No se pudo identificar al usuario.');
    }

    // 2. Consultar su perfil y su rol
    final perfil = await Supabase.instance.client
        .from('profiles')
        .select('full_name, role')
        .eq('id', usuario.id)
        .single();

    if (!mounted) return;

    final nombre = perfil['full_name'] as String;
    final rol = perfil['role'] as String;

    // 3. Abrir el panel correspondiente
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(
          fullName: nombre,
          role: rol,
        ),
      ),
    );
  } on AuthException catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error de inicio de sesión: ${error.message}'),
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No se pudo cargar tu perfil: $error'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.agriculture,
                  size: 75,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu correo electrónico';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _iniciarSesion,
                    child: _cargando
                        ? const CircularProgressIndicator()
                        : const Text('Ingresar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _rol = 'Productor';
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
    });

    try {
      final respuesta = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'full_name': _nombreController.text.trim(),
          'role': _rol.toLowerCase(),
        },
      );

      if (!mounted) return;

      if (respuesta.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registro exitoso. Revisa tu correo si se solicita confirmación.',
            ),
          ),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de registro: ${error.message}')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.person_add,
                  size: 75,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Regístrate en Directo del Campo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu nombre';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  initialValue: _rol,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de usuario',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Productor',
                      child: Text('Productor'),
                    ),
                    DropdownMenuItem(
                      value: 'Comprador',
                      child: Text('Comprador'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _rol = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una contraseña';
                    }
                    if (value.length < 8) {
                      return 'Debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _registrarUsuario,
                    child: _cargando
                        ? const CircularProgressIndicator()
                        : const Text('Crear cuenta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final String fullName;
  final String role;

  const DashboardPage({
    super.key,
    required this.fullName,
    required this.role,
  });

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const InicioPage(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $error'),
        ),
      );
    }
  }

  void _mostrarPendiente(BuildContext context, String modulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$modulo estará disponible en el siguiente módulo.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esProductor = role == 'productor';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      appBar: AppBar(
        title: const Text('Directo del Campo'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.agriculture,
              size: 65,
              color: Color(0xFF2E7D32),
            ),

            const SizedBox(height: 15),

            Text(
              '¡Bienvenido, $fullName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              esProductor
                  ? 'Panel de Productor'
                  : 'Panel de Comprador',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              '¿Qué deseas hacer?',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            if (esProductor) ...[
              _crearOpcion(
                context,
                icono: Icons.add_box,
                titulo: 'Publicar producto',
                descripcion: 'Ofrece tus productos agrícolas.',
                modulo: 'Publicar producto',
              ),

              _crearOpcion(
                context,
                icono: Icons.inventory,
                titulo: 'Mis productos',
                descripcion: 'Consulta tus productos publicados.',
                modulo: 'Mis productos',
              ),

              _crearOpcion(
                context,
                icono: Icons.assignment,
                titulo: 'Solicitudes de pedidos',
                descripcion: 'Revisa las solicitudes de los compradores.',
                modulo: 'Solicitudes de pedidos',
              ),
            ] else ...[
              _crearOpcion(
                context,
                icono: Icons.store,
                titulo: 'Consultar productos',
                descripcion: 'Explora los productos agrícolas disponibles.',
                modulo: 'Consultar productos',
              ),

              _crearOpcion(
                context,
                icono: Icons.shopping_cart,
                titulo: 'Mis pedidos',
                descripcion: 'Consulta el estado de tus solicitudes.',
                modulo: 'Mis pedidos',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _crearOpcion(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String descripcion,
    required String modulo,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),

        leading: Icon(
          icono,
          color: const Color(0xFF2E7D32),
          size: 35,
        ),

        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(descripcion),
        ),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: () => _mostrarPendiente(context, modulo),
      ),
    );
  }
}