import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const PlatformOwnerDashboardApp());
}

class PlatformOwnerDashboardApp extends StatelessWidget {
  const PlatformOwnerDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Platform Owner Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate login delay
    await Future.delayed(const Duration(seconds: 1));

    final email = _emailController.text.toLowerCase();
    
    // Check if user is platform owner (platform, owner, super, or specific admin emails)
    if (email.contains('platform') || 
        email.contains('owner') || 
        email.contains('super') ||
        email == 'admin@securityplatform.com' ||
        email == 'ceo@securityplatform.com') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlatformOwnerDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access denied. Platform owner credentials required.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 64,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Platform Owner Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Security Guard Management Platform',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Use emails with "platform", "owner", "super" or admin@securityplatform.com',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlatformOwnerDashboardScreen extends StatefulWidget {
  const PlatformOwnerDashboardScreen({super.key});

  @override
  State<PlatformOwnerDashboardScreen> createState() => _PlatformOwnerDashboardScreenState();
}

class _PlatformOwnerDashboardScreenState extends State<PlatformOwnerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<SecurityCompany> _companies = [];
  final List<PlatformUser> _users = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadMockData();
  }

  void _loadMockData() {
    // Mock companies data
    _companies.addAll([
      SecurityCompany(
        id: 'C001',
        name: 'Elite Security Services',
        email: 'admin@elitesecurity.com',
        phone: '+1 (555) 123-4567',
        subscriptionPlan: 'Premium',
        guardCount: 25,
        activeGuards: 22,
        monthlyFee: 299.99,
        status: CompanyStatus.active,
        joinDate: DateTime.now().subtract(const Duration(days: 120)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SecurityCompany(
        id: 'C002',
        name: 'Metro Guard Solutions',
        email: 'boss@metroguard.com',
        phone: '+1 (555) 987-6543',
        subscriptionPlan: 'Professional',
        guardCount: 15,
        activeGuards: 14,
        monthlyFee: 199.99,
        status: CompanyStatus.active,
        joinDate: DateTime.now().subtract(const Duration(days: 85)),
        lastActivity: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      SecurityCompany(
        id: 'C003',
        name: 'Secure Pro Inc.',
        email: 'manager@securepro.com',
        phone: '+1 (555) 456-7890',
        subscriptionPlan: 'Basic',
        guardCount: 8,
        activeGuards: 6,
        monthlyFee: 99.99,
        status: CompanyStatus.trial,
        joinDate: DateTime.now().subtract(const Duration(days: 12)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ]);

    // Mock users data
    _users.addAll([
      PlatformUser(
        id: 'U001',
        name: 'John Smith',
        email: 'john.boss@elitesecurity.com',
        role: UserRole.companyAdmin,
        companyName: 'Elite Security Services',
        status: UserStatus.active,
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PlatformUser(
        id: 'U002',
        name: 'Mike Johnson',
        email: 'mike@elitesecurity.com',
        role: UserRole.guard,
        companyName: 'Elite Security Services',
        status: UserStatus.active,
        lastLogin: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      PlatformUser(
        id: 'U003',
        name: 'Sarah Wilson',
        email: 'sarah.manager@metroguard.com',
        role: UserRole.companyAdmin,
        companyName: 'Metro Guard Solutions',
        status: UserStatus.active,
        lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Owner Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Companies'),
            Tab(text: 'Users'),
            Tab(text: 'Billing'),
            Tab(text: 'Analytics'),
            Tab(text: 'Support'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCompaniesTab(),
          _buildUsersTab(),
          _buildBillingTab(),
          _buildAnalyticsTab(),
          _buildSupportTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final totalCompanies = _companies.length;
    final activeCompanies = _companies.where((c) => c.status == CompanyStatus.active).length;
    final totalGuards = _companies.fold(0, (sum, company) => sum + company.guardCount);
    final activeGuards = _companies.fold(0, (sum, company) => sum + company.activeGuards);
    final monthlyRevenue = _companies.fold(0.0, (sum, company) => sum + company.monthlyFee);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Companies',
                  totalCompanies.toString(),
                  Icons.business,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Companies',
                  activeCompanies.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Guards',
                  totalGuards.toString(),
                  Icons.security,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Monthly Revenue',
                  '\$${monthlyRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Platform Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildRecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    final activities = [
      'Elite Security Services added 3 new guards',
      'Metro Guard Solutions upgraded to Professional plan',
      'Secure Pro Inc. completed trial setup',
      'New company registration: SafeGuard Corp',
      'Monthly billing processed for 15 companies',
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.notifications, color: Colors.blue, size: 20),
            ),
            title: Text(activities[index]),
            subtitle: Text('${index + 1} hour${index == 0 ? '' : 's'} ago'),
          );
        },
      ),
    );
  }

  Widget _buildCompaniesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Security Companies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addNewCompany,
                icon: const Icon(Icons.add),
                label: const Text('Add Company'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _companies.length,
            itemBuilder: (context, index) {
              return _buildCompanyCard(_companies[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(SecurityCompany company) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: company.status == CompanyStatus.active 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.orange.withOpacity(0.1),
                  child: Icon(
                    Icons.business,
                    color: company.status == CompanyStatus.active ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        company.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: company.status == CompanyStatus.active ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    company.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCompanyMetric('Guards', '${company.activeGuards}/${company.guardCount}'),
                ),
                Expanded(
                  child: _buildCompanyMetric('Plan', company.subscriptionPlan),
                ),
                Expanded(
                  child: _buildCompanyMetric('Revenue', '\$${company.monthlyFee}/mo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'User Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addNewUser,
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              return _buildUserCard(_users[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(PlatformUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: user.status == UserStatus.active 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                user.role == UserRole.companyAdmin ? Icons.admin_panel_settings : Icons.security,
                color: user.status == UserStatus.active ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${user.role == UserRole.companyAdmin ? 'Admin' : 'Guard'} • ${user.companyName}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.status == UserStatus.active ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.status.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingTab() {
    final monthlyRevenue = _companies.fold(0.0, (sum, company) => sum + company.monthlyFee);
    final yearlyRevenue = monthlyRevenue * 12;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing & Revenue',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Monthly Revenue',
                  '\$${monthlyRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Yearly Projection',
                  '\$${yearlyRevenue.toStringAsFixed(2)}',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Analytics dashboard coming soon...'),
        ],
      ),
    );
  }

  Widget _buildSupportTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support & Help',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Support dashboard coming soon...'),
        ],
      ),
    );
  }

  void _addNewCompany() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Company feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _addNewUser() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add User feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Data Models
class SecurityCompany {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String subscriptionPlan;
  final int guardCount;
  final int activeGuards;
  final double monthlyFee;
  final CompanyStatus status;
  final DateTime joinDate;
  final DateTime lastActivity;

  SecurityCompany({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subscriptionPlan,
    required this.guardCount,
    required this.activeGuards,
    required this.monthlyFee,
    required this.status,
    required this.joinDate,
    required this.lastActivity,
  });
}

enum CompanyStatus { active, trial, suspended, cancelled }

class PlatformUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String companyName;
  final UserStatus status;
  final DateTime lastLogin;

  PlatformUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.companyName,
    required this.status,
    required this.lastLogin,
  });
}

enum UserRole { companyAdmin, guard }
enum UserStatus { active, inactive }
