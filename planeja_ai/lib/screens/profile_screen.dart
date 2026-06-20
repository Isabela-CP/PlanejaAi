import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // Formulário
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _email = '';
  String? _avatarUrl;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  bool _isInit = false;

  // Preferências
  bool _notificationsEnabled = true;
  bool _shareDataEnabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final authData = context.read<AuthProvider>().userData;
      if (authData != null) {
        _nameController.text = authData['name'] ?? '';
        _email = authData['email'] ?? '';
        _ageController.text = authData['age']?.toString() ?? '';
        _notificationsEnabled = authData['notifications_push'] ?? true;
        _shareDataEnabled = authData['share_anonymous_data'] ?? false;
        _avatarUrl = authData['avatar_url'];
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().updateProfile({
        'name': _nameController.text,
        'age': _ageController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _savePreferences() async {
    setState(() => _isLoading = true);
    try {
      final themeProvider = context.read<ThemeProvider>();
      final isDark = themeProvider.themeMode == ThemeMode.dark;
      
      await context.read<AuthProvider>().updateProfile({
        'notifications_push': _notificationsEnabled,
        'share_anonymous_data': _shareDataEnabled,
        'theme_dark': isDark,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferências salvas!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      
      setState(() => _isLoading = true);
      final bytes = await image.readAsBytes();
      await context.read<AuthProvider>().uploadAvatar(bytes, image.name);
      
      if (mounted) {
        setState(() {
           _avatarUrl = context.read<AuthProvider>().userData?['avatar_url'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto atualizada!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar foto: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPreferenceRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      {'label': 'Membro desde', 'value': 'Janeiro 2024'},
      {'label': 'Total de Transações', 'value': '47'},
      {'label': 'Metas Ativas', 'value': '3'},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, LucideIcons.info, 'Informações da Conta'),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth > 500 ? 3 : 1;
              if (cols == 3) {
                return Row(
                  children: items.map((item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: item != items.last ? 12 : 0),
                      child: _buildAccountInfoItem(context, item['label']!, item['value']!),
                    ),
                  )).toList(),
                );
              }
              return Column(
                children: items.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: item != items.last ? 12 : 0),
                  child: _buildAccountInfoItem(context, item['label']!, item['value']!),
                )).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              )),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Icon(LucideIcons.user, size: 28, color: theme.colorScheme.primary),
                const Text(
                  'Configurações do Perfil',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ).animate().fade(duration: 300.ms).slideX(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),
            const SizedBox(height: 24),

            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final personalCard = _buildPersonalInfoCard(context);
              final preferencesCard = _buildPreferencesCard(context);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: personalCard),
                    const SizedBox(width: 24),
                    Expanded(child: preferencesCard),
                  ],
                );
              }
              return Column(children: [
                personalCard,
                const SizedBox(height: 24),
                preferencesCard,
              ]);
            }),
            const SizedBox(height: 24),

            _buildAccountInfoCard(context)
                .animate()
                .fade(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // Logout button for mobile screens
            if (MediaQuery.of(context).size.width < 768)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<FinanceProvider>().clear();
                    context.read<AuthProvider>().logout();
                  },
                  icon: const Icon(LucideIcons.logOut),
                  label: const Text('Sair da Conta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ).animate()
               .fade(duration: 400.ms, delay: 400.ms)
               .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, LucideIcons.user, 'Informações Pessoais'),
              const SizedBox(height: 20),

              // Avatar
              Center(
                child: InkWell(
                  onTap: _pickAndUploadImage,
                  borderRadius: BorderRadius.circular(40),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                        backgroundImage: _avatarUrl != null 
                            ? NetworkImage('${() {
                                String url = dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ?? 'http://localhost:8000';
                                if (!kIsWeb && Platform.isAndroid) {
                                  url = url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
                                }
                                return url;
                              }()}$_avatarUrl') 
                            : null,
                        child: _avatarUrl == null 
                            ? Icon(LucideIcons.user, size: 40, color: theme.colorScheme.primary) 
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(LucideIcons.camera, size: 14, color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nome
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text('Nome Completo', style: theme.textTheme.titleSmall),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Digite seu nome completo'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nome é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text('Endereço de Email', style: theme.textTheme.titleSmall),
              ),
              TextFormField(
                initialValue: _email,
                enabled: false,
                decoration: const InputDecoration(hintText: 'email@exemplo.com'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Text(
                  'O endereço de email não pode ser alterado',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),
              const SizedBox(height: 16),

              // Idade
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text('Idade', style: theme.textTheme.titleSmall),
              ),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Ex: 25'),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Idade é obrigatória';
                  final age = int.tryParse(val);
                  if (age == null || age < 13 || age > 120) {
                    return 'Insira uma idade válida entre 13 e 120';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(_isLoading ? 'Salvando...' : 'Salvar Alterações'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms, delay: 50.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildPreferencesCard(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, LucideIcons.settings, 'Preferências'),
            const SizedBox(height: 20),

            // Aparência 
            Row(
              children: [
                Icon(
                  isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                  size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text('Aparência', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Modo Escuro', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          'Alternar entre temas claro e escuro',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      final newMode = !isDarkMode;
                      context.read<ThemeProvider>().toggleTheme(newMode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(newMode ? 'Modo escuro ativado' : 'Modo claro ativado'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(isDarkMode ? LucideIcons.sun : LucideIcons.moon, size: 15),
                    label: Text(isDarkMode ? 'Claro' : 'Escuro'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 16),

            // Notificações 
            Row(
              children: [
                Icon(LucideIcons.bell, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text('Notificações', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            _buildPreferenceRow(
              context: context,
              title: 'Notificações de Orçamento',
              subtitle: 'Receba alertas ao exceder limites ou atingir metas financeiras',
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            const SizedBox(height: 20),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 16),

            // Privacidade 
            Row(
              children: [
                Icon(LucideIcons.shield, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text('Privacidade', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            _buildPreferenceRow(
              context: context,
              title: 'Compartilhar Dados Anônimos',
              subtitle: 'Ajude a melhorar nossos serviços compartilhando dados de uso anônimos',
              value: _shareDataEnabled,
              onChanged: (val) => setState(() => _shareDataEnabled = val),
            ),
            const SizedBox(height: 24),

            // Botão Salvar Preferências
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _savePreferences,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Salvar Preferências'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms, delay: 150.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
