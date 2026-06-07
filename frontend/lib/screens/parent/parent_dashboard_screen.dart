import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/services/parent_api_service.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _children = [];
  int _selectedIndex = 0;
  Map<String, dynamic>? _activities;
  List<Map<String, dynamic>> _supervisionLogs = [];
  List<Map<String, dynamic>> _pendingUpdates = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() => _isLoading = true);
    final result = await ParentApiService.getChildProfile();
    if (mounted) {
      if (result['success'] == true) {
        final children = List<Map<String, dynamic>>.from(result['children']);
        setState(() {
          _children = children;
          _isLoading = false;
        });
        if (children.isNotEmpty) {
          await _loadActivities(children[0]['id']);
        }
      } else {
        setState(() {
          _error = result['error'];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadActivities(String childId) async {
    final results = await Future.wait([
      ParentApiService.getChildActivities(childId),
      ParentApiService.getSupervisionLogs(childId),
      ParentApiService.getPendingUpdates(childId),
    ]);
    if (mounted) {
      setState(() {
        _activities = results[0]['success'] == true ? results[0]['activities'] : null;
        _supervisionLogs = results[1]['success'] == true
            ? List<Map<String, dynamic>>.from(results[1]['logs'] ?? [])
            : [];
        _pendingUpdates = results[2]['success'] == true
            ? List<Map<String, dynamic>>.from(results[2]['pending_updates'] ?? [])
            : [];
      });
    }
  }

  Future<void> _selectChild(int index) async {
    setState(() {
      _selectedIndex = index;
      _activities = null;
    });
    await _loadActivities(_children[index]['id']);
  }

  Map<String, dynamic>? get _selectedChild =>
      _children.isNotEmpty ? _children[_selectedIndex] : null;

  Future<void> _confirmAndAction(
    String title,
    String message,
    Future<void> Function() action,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await action();
  }

  /*Future<void> _handleRevokeConsent() async {
    final child = _selectedChild;
    if (child == null) return;
    await _confirmAndAction(
      'Révoquer le consentement ?',
      'Le compte de ${child['username']} sera désactivé.',
      () async {
        final result = await ParentApiService.revokeConsent(
          childId: child['id'],
        );
        if (!mounted) return;
        if (result['success'] == true) {
          _showSnack('Consentement révoqué.', isError: false);
          await _loadChildren();
        } else {
          _showSnack(result['error'] ?? 'Erreur', isError: true);
        }
      },
    );
  }*/

  Future<void> _handleTogglePosting(bool currentValue) async {
    final child = _selectedChild;
    if (child == null) return;
    final newValue = !currentValue;
    final result = await ParentApiService.toggleChildPosting(
      childId: child['id'],
      canPost: newValue,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      _showSnack(
        newValue
            ? 'Publications activées pour ${child['username']}.'
            : 'Publications désactivées pour ${child['username']}.',
        isError: false,
      );
      await _loadChildren();
    } else {
      _showSnack(result['error'] ?? 'Erreur', isError: true);
    }
  }

  Future<void> _handleDeleteChild() async {
    final child = _selectedChild;
    if (child == null) return;
    await _confirmAndAction(
      'Supprimer le compte ?',
      'Cette action est irréversible. Toutes les données de ${child['username']} seront supprimées.',
      () async {
        final result = await ParentApiService.deleteChildAccount(child['id']);
        if (!mounted) return;
        if (result['success'] == true) {
          _showSnack('Compte supprimé avec succès.', isError: false);
          await _loadChildren();
        } else {
          _showSnack(result['error'] ?? 'Erreur', isError: true);
        }
      },
    );
  }

  Future<void> _handleDeleteRequest() async {
    final result = await ParentApiService.sendDeleteRequest();
    if (!mounted) return;
    if (result['success'] == true) {
      _showSnack(result['message'] ?? 'Demande envoyée.', isError: false);
    } else {
      _showSnack(result['error'] ?? 'Erreur', isError: true);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.family_restroom_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Espace Parent',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : RefreshIndicator(
              onRefresh: _loadChildren,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildChildSelectorWithAdd(),
                    const SizedBox(height: 16),
                    if (_selectedChild != null) _buildChildCard(),
                    const SizedBox(height: 20),
                    if (_pendingUpdates.isNotEmpty) ...[
                      _buildPendingUpdatesCard(),
                      const SizedBox(height: 20),
                    ],
                    _buildMoodsCard(),
                    const SizedBox(height: 20),
                    _buildSupervisionCard(),
                    const SizedBox(height: 20),
                    _buildActionsCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildChildSelectorWithAdd() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mes enfants',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: _showAddChildForm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Ajouter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_children.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _children.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final child = _children[i];
                final isSelected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => _selectChild(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.child_care_rounded,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          child['username'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _showAddChildForm() {
    final usernameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String selectedAge = '6-12';
    bool obscure = true;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ajouter un enfant',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _formField(
                    usernameCtrl,
                    "Nom d'utilisateur",
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _formField(
                    emailCtrl,
                    "Email",
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  // Tranche d'âge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedAge,
                        isExpanded: true,
                        items: ['6-12', '13-17']
                            .map(
                              (age) => DropdownMenuItem(
                                value: age,
                                child: Text('$age ans'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setModalState(() => selectedAge = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _formField(
                    passwordCtrl,
                    "Mot de passe",
                    Icons.lock_outline_rounded,
                    obscure: obscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setModalState(() => obscure = !obscure),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _formField(
                    confirmCtrl,
                    "Confirmer le mot de passe",
                    Icons.lock_outline_rounded,
                    obscure: obscure,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (usernameCtrl.text.trim().isEmpty ||
                                emailCtrl.text.trim().isEmpty ||
                                passwordCtrl.text.isEmpty) {
                              _showSnack(
                                'Tous les champs sont requis',
                                isError: true,
                              );
                              return;
                            }
                            if (passwordCtrl.text.length < 8) {
                              _showSnack(
                                'Le mot de passe doit faire au moins 8 caractères',
                                isError: true,
                              );
                              return;
                            }
                            if (passwordCtrl.text != confirmCtrl.text) {
                              _showSnack(
                                'Les mots de passe ne correspondent pas',
                                isError: true,
                              );
                              return;
                            }
                            setModalState(() => isLoading = true);
                            final navigator = Navigator.of(ctx);
                            final result = await ParentApiService.addChild(
                              username: usernameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              password: passwordCtrl.text,
                              ageRange: selectedAge,
                            );
                            setModalState(() => isLoading = false);
                            if (!mounted) return;
                            if (result['success'] == true) {
                              navigator.pop();
                              _showSnack(
                                'Compte créé avec succès !',
                                isError: false,
                              );
                              await _loadChildren();
                            } else {
                              _showSnack(
                                result['error'] ?? 'Erreur',
                                isError: true,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Créer le compte',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.child_care_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Aucun enfant lié.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showAddChildForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text(
              'Ajouter un enfant',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard() {
    final child = _selectedChild!;
    final status = child['status'] ?? '';
    final isActive = status == 'ACTIVE';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_care_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child['username'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${child['age_range'] ?? ''} ans',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.red.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? '✅ Actif' : '⏸️ Suspendu',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _pendingChangeLabel(String key) {
    switch (key) {
      case 'pseudo': return 'Pseudo';
      case 'bio': return 'Description';
      case 'avatar_url': return 'Photo de profil';
      default: return key;
    }
  }

  Future<void> _handleApprove(String updateId) async {
    final result = await ParentApiService.approveUpdate(updateId);
    if (!mounted) return;
    if (result['success'] == true) {
      _showSnack('Modification approuvée et appliquée.', isError: false);
      final child = _selectedChild;
      if (child != null) await _loadActivities(child['id']);
    } else {
      _showSnack(result['error'] ?? 'Erreur', isError: true);
    }
  }

  Future<void> _handleReject(String updateId) async {
    final result = await ParentApiService.rejectUpdate(updateId);
    if (!mounted) return;
    if (result['success'] == true) {
      _showSnack('Modification refusée.', isError: false);
      final child = _selectedChild;
      if (child != null) await _loadActivities(child['id']);
    } else {
      _showSnack(result['error'] ?? 'Erreur', isError: true);
    }
  }

  Widget _buildPendingUpdatesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange[300]!, width: 1.5),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending_actions_rounded, color: Colors.orange[700], size: 22),
              const SizedBox(width: 8),
              Text(
                'Modifications en attente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_pendingUpdates.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Votre enfant souhaite modifier son profil. Votre approbation est requise.',
            style: TextStyle(fontSize: 12, color: Colors.orange[800]),
          ),
          const SizedBox(height: 16),
          ..._pendingUpdates.map((update) {
            final changes = update['changes'] as Map<String, dynamic>? ?? {};
            final updateId = update['id'] as String;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...changes.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_pendingChangeLabel(e.key)} : ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.key == 'avatar_url' ? '(nouvelle photo)' : '${e.value}',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleReject(updateId),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text('Refuser'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: BorderSide(color: AppTheme.errorColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleApprove(updateId),
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Approuver'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoodsCard() {
    final moods = (_activities?['moods']?['entries'] as List?) ?? [];
    final avg = _activities?['moods']?['average'];

    final moodLabels = {
      1: 'Très mal 😢',
      2: 'Mal 😟',
      3: 'Pas bien 😕',
      4: 'Neutre 😐',
      5: 'Bien 🙂',
      6: 'Très bien 😊',
      7: 'Excellent 🌟',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mood_rounded, color: AppTheme.primaryColor, size: 22),
              SizedBox(width: 8),
              Text(
                'Humeurs (30 derniers jours)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_activities == null && _children.isEmpty)
            const Center(
              child: Text(
                'Aucun enfant lié.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else if (_activities == null)
            const Center(child: CircularProgressIndicator())
          else ...[
            if (avg != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Moyenne : ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '$avg / 7',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (moods.isEmpty)
              Text(
                'Aucune humeur enregistrée.',
                style: TextStyle(color: AppTheme.textSecondary),
              )
            else ...[
              ...moods.take(3).map((m) => _buildMoodRow(m, moodLabels)),
              if (moods.length > 3) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showAllMoods(moods, moodLabels),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Voir les ${moods.length} humeurs',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  String _formatLogDate(String? isoDate) {
    if (isoDate == null) return '';
    final dt = DateTime.tryParse(isoDate)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day = DateTime(dt.year, dt.month, dt.day);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (day == today) return "Aujourd'hui $h:$m";
    if (day == yesterday) return "Hier $h:$m";
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} $h:$m';
  }

  Widget _buildSupervisionLogRow(Map<String, dynamic> log) {
    final action = log['action'] as String? ?? '';
    final message = log['message'] as String? ?? log['title'] as String? ?? '';
    final date = log['created_at'] as String?;
    final isRead = log['is_read'] as bool? ?? true;

    final IconData icon;
    final Color color;
    switch (action) {
      case 'PROFILE_UPDATE':
        icon = Icons.edit_outlined;
        color = Colors.orange;
        break;
      case 'TESTIMONIAL':
        icon = Icons.rate_review_outlined;
        color = Colors.blue;
        break;
      case 'COMMENT':
        icon = Icons.chat_bubble_outline_rounded;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notifications_outlined;
        color = AppTheme.primaryColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatLogDate(date),
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSupervisionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppTheme.primaryColor, size: 22),
              SizedBox(width: 8),
              Text(
                'Journal de supervision',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_activities == null && _children.isNotEmpty)
            const Center(child: CircularProgressIndicator())
          else if (_supervisionLogs.isEmpty)
            Text(
              'Aucune activité récente.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            )
          else ...[
            ..._supervisionLogs.take(5).map(_buildSupervisionLogRow),
            if (_supervisionLogs.length > 5) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showAllLogs(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Voir les ${_supervisionLogs.length} entrées',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showAllLogs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Journal de supervision',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _supervisionLogs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      _buildSupervisionLogRow(_supervisionLogs[i]),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.settings_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Gestion du compte',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          /*   const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.pause_circle_outline_rounded,
            color: Colors.orange,
            title: 'Révoquer le consentement',
            subtitle: 'Suspend le compte de votre enfant',
            onTap: _handleRevokeConsent,
          )*/
          const Divider(height: 24),
          // Contrôle parental : autoriser les publications communautaires
          Builder(builder: (context) {
            final settings = (_selectedChild?['accessibility_settings']
                as Map<String, dynamic>?) ?? {};
            final canPost = settings['can_post_content'] as bool? ?? false;
            return Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.forum_outlined,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Autoriser les publications',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Témoignages et commentaires communautaires',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: canPost,
                  onChanged: (_) => _handleTogglePosting(canPost),
                  activeThumbColor: AppTheme.primaryColor,
                  activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                ),
              ],
            );
          }),
          const Divider(height: 24),
          _buildActionTile(
            icon: Icons.delete_outline_rounded,
            color: AppTheme.errorColor,
            title: 'Supprimer le compte de mon enfant',
            subtitle:
                'Supprime définitivement toutes les données de mon enfant',
            onTap: _handleDeleteChild,
          ),
          const Divider(height: 24),
          _buildActionTile(
            icon: Icons.mail_outline_rounded,
            color: AppTheme.secondaryColor,
            title: 'Demande de suppression',
            subtitle: 'Envoyer une demande à notre équipe',
            onTap: _handleDeleteRequest,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodRow(Map<String, dynamic> m, Map<int, String> moodLabels) {
    final level = m['mood_level'] as int? ?? 0;
    final note = m['note'] as String?;
    final date = m['timestamp'] != null
        ? DateTime.tryParse(m['timestamp'])
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.getMoodColor(level).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                level.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getMoodColor(level),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moodLabels[level] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
                if (note != null && note.isNotEmpty)
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (date != null)
            Text(
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
        ],
      ),
    );
  }

  void _showAllMoods(List moods, Map<int, String> moodLabels) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.mood_rounded, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Historique des humeurs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: moods.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _buildMoodRow(moods[i], moodLabels),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
