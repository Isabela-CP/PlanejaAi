import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Formulário
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Usuário');
  final _ageController = TextEditingController(text: '25');
  static const String _email = 'usuario@email.com';
  bool _isLoading = false;

  // Preferências
  bool _notificationsEnabled = true;
  bool _shareDataEnabled = false;

  // Tema 
  bool _isDarkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _savePreferences() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferências salvas!'),
          backgroundColor: Colors.green,
        ),
      );
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
            // Header
            Row(
              children: [
                Icon(LucideIcons.user, size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
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
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                      child: Icon(LucideIcons.user, size: 40, color: theme.colorScheme.primary),
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
                  _isDarkMode ? LucideIcons.moon : LucideIcons.sun,
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
                      setState(() => _isDarkMode = !_isDarkMode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isDarkMode ? 'Modo escuro ativado' : 'Modo claro ativado'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(_isDarkMode ? LucideIcons.sun : LucideIcons.moon, size: 15),
                    label: Text(_isDarkMode ? 'Claro' : 'Escuro'),
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
