import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';

class PlatformOwnerDashboardScreen extends StatefulWidget {
  const PlatformOwnerDashboardScreen({super.key});

  @override
  State<PlatformOwnerDashboardScreen> createState() => _PlatformOwnerDashboardScreenState();
}

class _PlatformOwnerDashboardScreenState extends State<PlatformOwnerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample data for demonstration
  final List<SecurityCompany> _companies = [
    SecurityCompany(
      id: 'C001',
      name: 'Elite Security Services',
      email: 'admin@elitesecurity.com',
      phone: '+1 (555) 123-4567',
      subscriptionPlan: 'Premium',
      guardCount: 25,
      activeGuards: 22,
      totalGuards: 25,
      monthlyFee: 299.99,
      status: CompanyStatus.active,
      joinDate: DateTime.now().subtract(const Duration(days: 120)),
      lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    SecurityCompany(
      id: 'C002',
      name: 'Metro Guard Solutions',
      email: 'boss@metroguard.com',
      phone: '+1 (555) 987-6543',
      subscriptionPlan: 'Professional',
      guardCount: 15,
      activeGuards: 14,
      totalGuards: 15,
      monthlyFee: 199.99,
      status: CompanyStatus.active,
      joinDate: DateTime.now().subtract(const Duration(days: 85)),
      lastActivity: DateTime.now().subtract(const Duration(minutes: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
    ),
    SecurityCompany(
      id: 'C003',
      name: 'Secure Pro Inc.',
      email: 'manager@securepro.com',
      phone: '+1 (555) 456-7890',
      subscriptionPlan: 'Basic',
      guardCount: 8,
      activeGuards: 6,
      totalGuards: 8,
      monthlyFee: 99.99,
      status: CompanyStatus.trial,
      joinDate: DateTime.now().subtract(const Duration(days: 12)),
      lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

  // Sample users data
  final List<PlatformUser> _users = [
    PlatformUser(
      id: 'U001',
      name: 'John Smith',
      email: 'john.boss@elitesecurity.com',
      role: UserRole.companyAdmin,
      companyId: 'C001',
      companyName: 'Elite Security Services',
      status: UserStatus.active,
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      createdDate: DateTime.now().subtract(const Duration(days: 120)),
      permissions: ['view_patrols', 'create_incidents', 'manage_guards'],
    ),
    PlatformUser(
      id: 'U002',
      name: 'Mike Johnson',
      email: 'mike@elitesecurity.com',
      role: UserRole.guard,
      companyId: 'C001',
      companyName: 'Elite Security Services',
      status: UserStatus.active,
      lastLogin: DateTime.now().subtract(const Duration(minutes: 30)),
      createdDate: DateTime.now().subtract(const Duration(days: 45)),
      permissions: ['view_patrols', 'create_incidents'],
    ),
    PlatformUser(
      id: 'U003',
      name: 'Sarah Wilson',
      email: 'sarah.manager@metroguard.com',
      role: UserRole.companyAdmin,
      companyId: 'C002',
      companyName: 'Metro Guard Solutions',
      status: UserStatus.active,
      lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
      createdDate: DateTime.now().subtract(const Duration(days: 85)),
      permissions: ['view_patrols', 'create_incidents', 'manage_guards'],
    ),
    PlatformUser(
      id: 'U004',
      name: 'Tom Brown',
      email: 'tom.guard@metroguard.com',
      role: UserRole.guard,
      companyId: 'C002',
      companyName: 'Metro Guard Solutions',
      status: UserStatus.inactive,
      lastLogin: DateTime.now().subtract(const Duration(days: 5)),
      createdDate: DateTime.now().subtract(const Duration(days: 60)),
      permissions: ['view_patrols', 'create_incidents'],
    ),
    PlatformUser(
      id: 'U005',
      name: 'Lisa Davis',
      email: 'lisa.admin@securepro.com',
      role: UserRole.companyAdmin,
      companyId: 'C003',
      companyName: 'Secure Pro Inc.',
      status: UserStatus.active,
      lastLogin: DateTime.now().subtract(const Duration(hours: 3)),
      createdDate: DateTime.now().subtract(const Duration(days: 12)),
      permissions: ['view_patrols', 'create_incidents', 'manage_guards'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showPlatformSettings,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
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
                  'Active Guards',
                  activeGuards.toString(),
                  Icons.person,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Monthly Revenue',
            '\$${monthlyRevenue.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
          const SizedBox(height: 24),
          
          // Recent Activity
          const Text(
            'Recent Platform Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildRecentActivityList(),
          
          const SizedBox(height: 24),
          
          // Platform Health
          const Text(
            'Platform Health',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPlatformHealthCard(),
        ],
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
                  backgroundColor: const Color(AppConstants.primaryColor),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Companies List
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
                  backgroundColor: const Color(AppConstants.primaryColor),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // User Statistics
          Row(
            children: [
              Expanded(
                child: _buildUserStatCard(
                  'Total Users',
                  _users.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserStatCard(
                  'Company Admins',
                  _users.where((u) => u.role == UserRole.companyAdmin).length.toString(),
                  Icons.admin_panel_settings,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildUserStatCard(
                  'Guards',
                  _users.where((u) => u.role == UserRole.guard).length.toString(),
                  Icons.security,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserStatCard(
                  'Active Users',
                  _users.where((u) => u.status == UserStatus.active).length.toString(),
                  Icons.check_circle,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Filter Options
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filter by Company',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Companies')),
                    ..._companies.map((company) => DropdownMenuItem(
                      value: company.id,
                      child: Text(company.name),
                    )),
                  ],
                  value: 'all',
                  onChanged: (value) {
                    // TODO: Implement filter functionality
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filter by Role',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Roles')),
                    DropdownMenuItem(value: 'admin', child: Text('Company Admins')),
                    DropdownMenuItem(value: 'guard', child: Text('Guards')),
                  ],
                  value: 'all',
                  onChanged: (value) {
                    // TODO: Implement filter functionality
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Users List
          const Text(
            'All Users',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
          
          // Revenue Cards
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
          const SizedBox(height: 24),
          
          // Subscription Plans
          const Text(
            'Subscription Plans',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildSubscriptionPlansCard(),
          
          const SizedBox(height: 24),
          
          // Recent Transactions
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildRecentTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Usage Stats
          _buildUsageStatsCard(),
          const SizedBox(height: 24),
          
          // Growth Metrics
          const Text(
            'Growth Metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildGrowthMetricsCard(),
          
          const SizedBox(height: 24),
          
          // Feature Usage
          const Text(
            'Feature Usage',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildFeatureUsageCard(),
        ],
      ),
    );
  }

  Widget _buildSupportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support & Help',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Support Tickets
          _buildSupportTicketsCard(),
          const SizedBox(height: 24),
          
          // System Status
          const Text(
            'System Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildSystemStatusCard(),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildQuickActionsCard(),
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
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: company.status == CompanyStatus.active 
                        ? Colors.blue.withOpacity(0.1) 
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.business,
                    color: company.status == CompanyStatus.active ? Colors.blue : Colors.grey,
                    size: 24,
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
                    color: company.status == CompanyStatus.active ? Colors.green : Colors.red,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  company.phone,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  company.subscriptionPlan,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Guards',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${company.activeGuards}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Guards',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${company.totalGuards}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        DateFormat('MMM yyyy').format(company.createdAt),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editCompany(company),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _manageCompanyGuards(company),
                    icon: const Icon(Icons.group, size: 16),
                    label: const Text('Manage Guards'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: company.status == CompanyStatus.active 
                        ? () => _deactivateCompany(company)
                        : () => _activateCompany(company),
                    icon: Icon(
                      company.status == CompanyStatus.active ? Icons.block : Icons.check,
                      size: 16,
                    ),
                    label: Text(company.status == CompanyStatus.active ? 'Deactivate' : 'Activate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: company.status == CompanyStatus.active ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editCompany(SecurityCompany company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Company'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: company.name),
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: company.email),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: company.phone),
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: company.subscriptionPlan,
              decoration: const InputDecoration(labelText: 'Subscription Plan'),
              items: ['Basic', 'Premium', 'Enterprise'].map((plan) => DropdownMenuItem(
                value: plan,
                child: Text(plan),
              )).toList(),
              onChanged: (value) {
                // Handle subscription plan change
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Company updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _manageCompanyGuards(SecurityCompany company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Guards - ${company.name}'),
        content: const Text('Guard management functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _activateCompany(SecurityCompany company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Company'),
        content: Text('Are you sure you want to activate ${company.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                company.status = CompanyStatus.active;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${company.name} has been activated')),
              );
            },
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _deactivateCompany(SecurityCompany company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Company'),
        content: Text('Are you sure you want to deactivate ${company.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                company.status = CompanyStatus.inactive;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${company.name} has been deactivated')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildUserCard(PlatformUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: user.status == UserStatus.active 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                user.role == UserRole.companyAdmin ? Icons.admin_panel_settings : Icons.security,
                color: user.role == UserRole.companyAdmin ? Colors.green : Colors.red,
                size: 24,
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

  Widget _buildPlatformHealthCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Platform Health',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildHealthMetric('Server Status', 'Operational', Colors.green),
            _buildHealthMetric('Database', 'Healthy', Colors.green),
            _buildHealthMetric('API Response', '99.9% uptime', Colors.green),
            _buildHealthMetric('Mobile App', 'Latest version', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String title, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlansCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPlanRow('Basic', '\$99.99/month', 'Up to 10 guards'),
            _buildPlanRow('Professional', '\$199.99/month', 'Up to 25 guards'),
            _buildPlanRow('Premium', '\$299.99/month', 'Unlimited guards'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanRow(String name, String price, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.payment, color: Colors.white, size: 20),
            ),
            title: Text('Payment from ${_companies[index % _companies.length].name}'),
            subtitle: Text('${DateFormat('MMM dd, yyyy').format(DateTime.now().subtract(Duration(days: index)))}'),
            trailing: Text(
              '+\$${_companies[index % _companies.length].monthlyFee}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsageStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usage Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildUsageMetric('Daily Active Guards', '245', '+12%'),
            _buildUsageMetric('Patrols Completed', '1,234', '+8%'),
            _buildUsageMetric('Incidents Reported', '45', '-3%'),
            _buildUsageMetric('QR Scans', '2,456', '+15%'),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageMetric(String title, String value, String change) {
    final isPositive = change.startsWith('+');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthMetricsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildGrowthMetric('New Companies', '+2', 'This month'),
                ),
                Expanded(
                  child: _buildGrowthMetric('Revenue Growth', '+15%', 'vs last month'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGrowthMetric('User Retention', '94%', 'Monthly'),
                ),
                Expanded(
                  child: _buildGrowthMetric('Churn Rate', '2.1%', 'Monthly'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthMetric(String title, String value, String period) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          period,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureUsageCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureUsageBar('Patrol Tracking', 0.95),
            _buildFeatureUsageBar('Photo Submissions', 0.87),
            _buildFeatureUsageBar('Incident Reports', 0.64),
            _buildFeatureUsageBar('QR Scanning', 0.78),
            _buildFeatureUsageBar('GPS Tracking', 0.92),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureUsageBar(String feature, double usage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(feature)),
              Text('${(usage * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: usage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              usage > 0.8 ? Colors.green : usage > 0.6 ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTicketsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support Tickets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSupportStat('Open', '12', Colors.orange),
                ),
                Expanded(
                  child: _buildSupportStat('Resolved', '48', Colors.green),
                ),
                Expanded(
                  child: _buildSupportStat('Pending', '3', Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportStat(String label, String count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSystemStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildSystemStatusItem('API Service', 'Operational', Colors.green),
            _buildSystemStatusItem('Database', 'Operational', Colors.green),
            _buildSystemStatusItem('File Storage', 'Operational', Colors.green),
            _buildSystemStatusItem('Push Notifications', 'Operational', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusItem(String service, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(service)),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendBroadcast,
                    icon: const Icon(Icons.campaign),
                    label: const Text('Send Broadcast'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportData,
                    icon: const Icon(Icons.download),
                    label: const Text('Export Data'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _manageApiKeys,
                    icon: const Icon(Icons.key),
                    label: const Text('API Keys'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _viewSystemLogs,
                    icon: const Icon(Icons.list_alt),
                    label: const Text('System Logs'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _showNotifications() {
    // TODO: Implement notifications
  }

  void _showPlatformSettings() {
    // TODO: Implement platform settings
  }

  void _logout() {
    Navigator.pop(context);
  }

  void _addNewCompany() {
    // TODO: Implement add new company
  }

  void _viewCompanyDetails(SecurityCompany company) {
    // TODO: Implement company details view
  }

  void _manageCompany(SecurityCompany company) {
    // TODO: Implement company management
  }

  // User Management Actions
  void _addNewUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'User Role',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Company Admin')),
                  DropdownMenuItem(value: 'guard', child: Text('Security Guard')),
                ],
                onChanged: (value) {
                  // TODO: Handle role selection
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Assign to Company',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _companies.map((company) => DropdownMenuItem(
                  value: company.id,
                  child: Text(company.name),
                )).toList(),
                onChanged: (value) {
                  // TODO: Handle company selection
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New user added successfully! Invitation email sent.'),
                  backgroundColor: Colors.green,
                ),
              );
              // TODO: Implement actual user creation
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  void _editUser(PlatformUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: user.name),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: user.email),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: user.role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: UserRole.values.map((role) => DropdownMenuItem(
                value: role,
                child: Text(role == UserRole.companyAdmin ? 'Company Admin' : 'Security Guard'),
              )).toList(),
              onChanged: (value) {
                // Handle role change
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: user.companyName,
              decoration: const InputDecoration(labelText: 'Company'),
              items: _companies.map((company) => DropdownMenuItem(
                value: company.name,
                child: Text(company.name),
              )).toList(),
              onChanged: (value) {
                // Handle company change
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save user changes
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _manageUserPermissions(PlatformUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Permissions - ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('View Patrols'),
              value: user.permissions.contains('view_patrols'),
              onChanged: (bool? value) {
                // Handle permission change
              },
            ),
            CheckboxListTile(
              title: const Text('Create Incident Reports'),
              value: user.permissions.contains('create_incidents'),
              onChanged: (bool? value) {
                // Handle permission change
              },
            ),
            CheckboxListTile(
              title: const Text('Manage Guards'),
              value: user.permissions.contains('manage_guards'),
              onChanged: (bool? value) {
                // Handle permission change
              },
            ),
            CheckboxListTile(
              title: const Text('View Analytics'),
              value: user.permissions.contains('view_analytics'),
              onChanged: (bool? value) {
                // Handle permission change
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permissions updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _activateUser(PlatformUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate User'),
        content: Text('Are you sure you want to activate ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                user.status = UserStatus.active;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} has been activated')),
              );
            },
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _deactivateUser(PlatformUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text('Are you sure you want to deactivate ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                user.status = UserStatus.inactive;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} has been deactivated')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _sendBroadcast() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Broadcast Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Send to',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Companies')),
                DropdownMenuItem(value: 'admins', child: Text('Company Admins Only')),
                DropdownMenuItem(value: 'guards', child: Text('Guards Only')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Enter your broadcast message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Broadcast message sent successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Platform Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Company Data'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('User Data'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Billing Data'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Analytics Data'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export started. Download link will be sent to your email.'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _manageApiKeys() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active API Keys:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'pk_live_abcd1234...5678',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Generate New Key'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewSystemLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Logs'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              _buildLogEntry('INFO', '2025-07-04 14:30:15', 'User login: john.boss@elitesecurity.com'),
              _buildLogEntry('INFO', '2025-07-04 14:28:42', 'Patrol submitted: Guard Mike Johnson'),
              _buildLogEntry('WARN', '2025-07-04 14:25:10', 'Failed login attempt: invalid@test.com'),
              _buildLogEntry('INFO', '2025-07-04 14:20:33', 'Company subscription updated: Metro Guard Solutions'),
              _buildLogEntry('ERROR', '2025-07-04 14:15:22', 'Database connection timeout - recovered'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Download Full Logs'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(String level, String timestamp, String message) {
    Color levelColor;
    switch (level) {
      case 'ERROR':
        levelColor = Colors.red;
        break;
      case 'WARN':
        levelColor = Colors.orange;
        break;
      default:
        levelColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              level,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timestamp,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                Text(
                  message,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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
  final int totalGuards;
  final double monthlyFee;
  CompanyStatus status;
  final DateTime joinDate;
  final DateTime lastActivity;
  final DateTime createdAt;

  SecurityCompany({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subscriptionPlan,
    required this.guardCount,
    required this.activeGuards,
    required this.totalGuards,
    required this.monthlyFee,
    required this.status,
    required this.joinDate,
    required this.lastActivity,
    required this.createdAt,
  });
}

enum CompanyStatus {
  active,
  trial,
  suspended,
  cancelled,
  inactive,
}

class PlatformUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String companyId;
  final String companyName;
  UserStatus status;
  final DateTime lastLogin;
  final DateTime createdDate;
  final String? phoneNumber;
  final List<String> permissions;

  PlatformUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.companyId,
    required this.companyName,
    required this.status,
    required this.lastLogin,
    required this.createdDate,
    this.phoneNumber,
    this.permissions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'companyId': companyId,
      'companyName': companyName,
      'status': status.name,
      'lastLogin': lastLogin.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'phoneNumber': phoneNumber,
    };
  }

  factory PlatformUser.fromJson(Map<String, dynamic> json) {
    return PlatformUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere((r) => r.name == json['role']),
      companyId: json['companyId'],
      companyName: json['companyName'],
      status: UserStatus.values.firstWhere((s) => s.name == json['status']),
      lastLogin: DateTime.parse(json['lastLogin']),
      createdDate: DateTime.parse(json['createdDate']),
      phoneNumber: json['phoneNumber'],
    );
  }
}

enum UserRole {
  platformOwner,
  companyAdmin,
  guard,
}

enum UserStatus {
  active,
  inactive,
  pending,
  suspended,
}
