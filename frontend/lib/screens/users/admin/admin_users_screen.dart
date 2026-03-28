import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/services/admin_api_service.dart';
import 'package:sakinah_app/widgets/custom_wigdet.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Onglet utilisateurs
  List<dynamic> _users = [];
  bool _isLoadingUsers = true;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String _statusFilter = '';
  final _searchController = TextEditingController();

  // Onglet professionnels
  List<dynamic> _pendingProfessionals = [];
  bool _isLoadingPro = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    _loadPendingProfessionals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({int page = 1}) async {
    setState(() => _isLoadingUsers = true);
    final result = await AdminApiService.listUsers(
      page: page,
      limit: 20,
      status: _statusFilter,
      search: _searchQuery,
    );
    if (!mounted) return;
    setState(() {
      _isLoadingUsers = false;
      if (result['success'] == true) {
        _users = result['users'] ?? [];
        _currentPage = result['pagination']?['page'] ?? 1;
        _totalPages = result['pagination']?['pages'] ?? 1;
      }
    });
  }

  Future<void> _loadPendingProfessionals() async {
    setState(() => _isLoadingPro = true);
    final result = await AdminApiService.listPendingProfessionals();
    if (!mounted) return;
    setState(() {
      _isLoadingPro = false;
      if (result['success'] == true) {
        _pendingProfessionals = result['professionals'] ?? [];
      }
    });
  }

  Future<void> _updateStatus(String userId, String status) async {
    final result = await AdminApiService.updateUserStatus(
      userId: userId,
      status: status,
    );
    if (!mounted) return;
    _showSnack(
      result['success'] == true
          ? 'Statut mis à jour : $status'
          : result['error'] ?? 'Erreur',
      isError: result['success'] != true,
    );
    if (result['success'] == true) _loadUsers(page: _currentPage);
  }

  Future<void> _deleteUser(String userId, String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'utilisateur'),
        content: Text('Supprimer définitivement "$username" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final result = await AdminApiService.deleteUser(userId);
    if (!mounted) return;
    _showSnack(
      result['success'] == true
          ? 'Utilisateur supprimé'
          : result['error'] ?? 'Erreur',
      isError: result['success'] != true,
    );
    if (result['success'] == true) _loadUsers(page: _currentPage);
  }

  Future<void> _verifyProfessional(String userId, String decision) async {
    final result = await AdminApiService.verifyProfessional(
      userId: userId,
      decision: decision,
    );
    if (!mounted) return;
    _showSnack(
      result['success'] == true
          ? decision == 'VERIFIED' ? 'Professionnel approuvé' : 'Demande rejetée'
          : result['error'] ?? 'Erreur',
      isError: result['success'] != true,
    );
    if (result['success'] == true) _loadPendingProfessionals();
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showUserActions(Map<String, dynamic> user) {
    final userId = user['id'] as String;
    final username = user['username'] as String? ?? 'Inconnu';
    final status = user['status'] as String? ?? '';
    final role = user['role'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              '$role · $status',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const Divider(height: 24),
            if (status != 'ACTIVE')
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppTheme.success),
                title: const Text('Activer'),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateStatus(userId, 'ACTIVE');
                },
              ),
            if (status != 'SUSPENDED')
              ListTile(
                leading: Icon(Icons.pause_circle_outline, color: AppTheme.warning),
                title: const Text('Suspendre'),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateStatus(userId, 'SUSPENDED');
                },
              ),
            if (role != 'ADMIN')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined, color: AppTheme.info),
                title: const Text('Promouvoir en Admin'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await AdminApiService.promoteToAdmin(userId);
                  if (!mounted) return;
                  _showSnack(
                    result['success'] == true
                        ? '$username promu en Admin'
                        : result['error'] ?? 'Erreur',
                    isError: result['success'] != true,
                  );
                  if (result['success'] == true) _loadUsers(page: _currentPage);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: AppTheme.error),
              title: Text('Supprimer $username', style: const TextStyle(color: AppTheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteUser(userId, username);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Utilisateurs'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Professionnels'),
                  if (_pendingProfessionals.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_pendingProfessionals.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildProfessionalsTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        // Barre de recherche + filtres
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher par pseudo, email...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _loadUsers();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onSubmitted: (value) {
                  setState(() => _searchQuery = value.trim());
                  _loadUsers();
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  children: [
                    _filterChip('Tous', ''),
                    _filterChip('Actifs', 'ACTIVE'),
                    _filterChip('En attente', 'PENDING'),
                    _filterChip('Suspendus', 'SUSPENDED'),
                    _filterChip('Rejetés', 'REJECTED'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: _isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                  ? const Center(child: Text('Aucun utilisateur trouvé'))
                  : RefreshIndicator(
                      onRefresh: () => _loadUsers(page: _currentPage),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildUserCard(_users[index]),
                        ),
                      ),
                    ),
        ),

        // Pagination
        if (_totalPages > 1)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () => _loadUsers(page: _currentPage - 1)
                      : null,
                ),
                Text(
                  'Page $_currentPage / $_totalPages',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < _totalPages
                      ? () => _loadUsers(page: _currentPage + 1)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final status = user['status'] as String? ?? '';
    final role = user['role'] as String? ?? '';
    final isMinor = user['is_minor'] == true;

    Color statusColor;
    switch (status) {
      case 'ACTIVE':
        statusColor = AppTheme.success;
        break;
      case 'SUSPENDED':
        statusColor = AppTheme.error;
        break;
      case 'PENDING':
        statusColor = AppTheme.warning;
        break;
      default:
        statusColor = AppTheme.textSecondary;
    }

    return SoftCard(
      onTap: () => _showUserActions(user),
      child: Row(
        children: [
          // Avatar initiale
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                (user['pseudo'] ?? user['username'] ?? '?')[0].toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user['pseudo'] ?? user['username'] ?? 'Inconnu',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (isMinor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.info.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Mineur',
                          style: TextStyle(fontSize: 10, color: AppTheme.info),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  user['email'] ?? '',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _roleBadge(role),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildProfessionalsTab() {
    return _isLoadingPro
        ? const Center(child: CircularProgressIndicator())
        : _pendingProfessionals.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_outlined, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun professionnel en attente',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadPendingProfessionals,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingProfessionals.length,
                  itemBuilder: (context, index) =>
                      _buildProCard(_pendingProfessionals[index]),
                ),
              );
  }

  Widget _buildProCard(Map<String, dynamic> pro) {
    final role = pro['role'] as String? ?? '';
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline, color: AppTheme.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pro['username'] ?? 'Inconnu',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      pro['email'] ?? '',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _roleBadge(role),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _verifyProfessional(pro['id'], 'REJECTED'),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Rejeter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _verifyProfessional(pro['id'], 'VERIFIED'),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approuver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _statusFilter = value);
          _loadUsers();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleBadge(String role) {
    Color color;
    switch (role) {
      case 'ADMIN':
        color = Colors.purple;
        break;
      case 'PSYCHOLOGUE':
        color = AppTheme.info;
        break;
      case 'EDUCATEUR':
        color = AppTheme.moodCalm;
        break;
      case 'INTERVENANT':
        color = AppTheme.warning;
        break;
      case 'PARENT':
        color = Colors.green;
        break;
      default:
        color = AppTheme.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
