import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(DashboardRefreshRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading dashboard',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(DashboardLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(DashboardRefreshRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickStats(context, state.stats),
                    const SizedBox(height: 24),
                    _buildShiftStatus(context, state.isOnShift),
                    const SizedBox(height: 24),
                    _buildRecentActivity(context, state.recentActivities),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              context,
              'Active Shifts',
              stats.activeShifts.toString(),
              Icons.work,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              'Check-ins Today',
              stats.todayCheckIns.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              context,
              'Pending Incidents',
              stats.pendingIncidents.toString(),
              Icons.warning,
              Colors.orange,
            ),
            _buildStatCard(
              context,
              'Total Sites',
              stats.totalSites.toString(),
              Icons.location_on,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftStatus(BuildContext context, bool isOnShift) {
    return Card(
      color: isOnShift ? Colors.green.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isOnShift ? Icons.work : Icons.work_off,
              size: 32,
              color: isOnShift ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnShift ? 'On Shift' : 'Off Shift',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOnShift ? Colors.green : Colors.grey,
                    ),
                  ),
                  Text(
                    isOnShift 
                        ? 'You are currently on duty'
                        : 'You are currently off duty',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement shift toggle
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isOnShift ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(isOnShift ? 'End Shift' : 'Start Shift'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, List<ActivityItem> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (activities.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No recent activity'),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getActivityColor(activity.type),
                    child: Icon(
                      _getActivityIcon(activity.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(activity.title),
                  subtitle: Text(activity.subtitle),
                  trailing: Text(
                    _formatTime(activity.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'patrol':
        return Icons.route;
      case 'incident':
        return Icons.warning;
      case 'checkin':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'patrol':
        return Colors.blue;
      case 'incident':
        return Colors.red;
      case 'checkin':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
