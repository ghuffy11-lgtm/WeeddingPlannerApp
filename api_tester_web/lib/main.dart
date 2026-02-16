import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ApiTesterApp());
}

class ApiTesterApp extends StatelessWidget {
  const ApiTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedding Planner API Tester',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE94560),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        cardColor: const Color(0xFF16213E),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0F3460),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const ApiTesterHome(),
    );
  }
}

class ApiTesterHome extends StatefulWidget {
  const ApiTesterHome({super.key});

  @override
  State<ApiTesterHome> createState() => _ApiTesterHomeState();
}

class _ApiTesterHomeState extends State<ApiTesterHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  // Response state
  int? _statusCode;
  String _responseBody = 'Send a request to see the response here...';
  int _responseTime = 0;
  final List<LogEntry> _logs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleResponse(ApiResponse response) {
    setState(() {
      _statusCode = response.statusCode;
      _responseBody = const JsonEncoder.withIndent('  ').convert(response.data);
      _responseTime = response.duration;
      _logs.insert(0, LogEntry(
        method: response.method,
        endpoint: response.endpoint,
        status: response.statusCode,
        time: response.duration,
      ));
      if (_logs.length > 50) _logs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wedding Planner API Tester'),
        backgroundColor: const Color(0xFF16213E),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Token: '),
                Icon(
                  _api.hasToken ? Icons.check_circle : Icons.cancel,
                  color: _api.hasToken ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() => _api.clearToken());
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'AUTH'),
            Tab(text: 'WEDDING'),
            Tab(text: 'TASKS'),
            Tab(text: 'GUESTS'),
            Tab(text: 'BUDGET'),
            Tab(text: 'VENDORS'),
            Tab(text: 'BOOKINGS'),
            Tab(text: 'CUSTOM'),
          ],
        ),
      ),
      body: Row(
        children: [
          // Left panel - Actions
          SizedBox(
            width: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                AuthTab(api: _api, onResponse: _handleResponse),
                WeddingTab(api: _api, onResponse: _handleResponse),
                TasksTab(api: _api, onResponse: _handleResponse),
                GuestsTab(api: _api, onResponse: _handleResponse),
                BudgetTab(api: _api, onResponse: _handleResponse),
                VendorsTab(api: _api, onResponse: _handleResponse),
                BookingsTab(api: _api, onResponse: _handleResponse),
                CustomTab(api: _api, onResponse: _handleResponse),
              ],
            ),
          ),
          // Right panel - Response
          Expanded(
            child: Column(
              children: [
                // Response viewer
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text('Response', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (_statusCode != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(_statusCode!),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('$_statusCode', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Text('${_responseTime}ms'),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: SelectableText(
                              _responseBody,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Log panel
                Container(
                  height: 200,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Request Log', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      log.method,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        color: _getMethodColor(log.method),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      log.endpoint,
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      '${log.status}',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        color: log.status >= 200 && log.status < 300 ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      '${log.time}ms',
                                      style: const TextStyle(fontFamily: 'monospace', color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int status) {
    if (status >= 200 && status < 300) return Colors.green;
    if (status >= 400 && status < 500) return Colors.orange;
    return Colors.red;
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'GET': return Colors.blue;
      case 'POST': return Colors.green;
      case 'PUT': return Colors.orange;
      case 'DELETE': return Colors.red;
      default: return Colors.grey;
    }
  }
}

// ============ API SERVICE ============

class ApiService {
  String baseUrl = 'http://10.1.13.98:3010/api/v1';
  String? _accessToken;
  String? _refreshToken;
  String? userId;
  String? userEmail;
  String? userType;
  String? weddingId;

  bool get hasToken => _accessToken != null;

  void clearToken() {
    _accessToken = null;
    _refreshToken = null;
    userId = null;
    userEmail = null;
    userType = null;
    weddingId = null;
  }

  void storeAuthData(Map<String, dynamic> data) {
    _accessToken = data['accessToken'] ?? data['access_token'] ?? data['token'];
    _refreshToken = data['refreshToken'] ?? data['refresh_token'];
    if (data['user'] != null) {
      userId = data['user']['id'];
      userEmail = data['user']['email'];
      userType = data['user']['userType'];
    }
  }

  Future<ApiResponse> request(String method, String endpoint, {Map<String, dynamic>? body, bool useAuth = true}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (useAuth && _accessToken != null) {
        headers['Authorization'] = 'Bearer $_accessToken';
      }

      http.Response response;
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported method: $method');
      }

      stopwatch.stop();
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return ApiResponse(
        statusCode: response.statusCode,
        data: data,
        duration: stopwatch.elapsedMilliseconds,
        method: method,
        endpoint: endpoint,
      );
    } catch (e) {
      stopwatch.stop();
      return ApiResponse(
        statusCode: 0,
        data: {'error': e.toString()},
        duration: stopwatch.elapsedMilliseconds,
        method: method,
        endpoint: endpoint,
      );
    }
  }
}

class ApiResponse {
  final int statusCode;
  final dynamic data;
  final int duration;
  final String method;
  final String endpoint;

  ApiResponse({
    required this.statusCode,
    required this.data,
    required this.duration,
    required this.method,
    required this.endpoint,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class LogEntry {
  final String method;
  final String endpoint;
  final int status;
  final int time;

  LogEntry({required this.method, required this.endpoint, required this.status, required this.time});
}

// ============ REUSABLE WIDGETS ============

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const ActionButton({super.key, required this.label, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFFE94560),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 44),
      ),
      child: Text(label),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFE94560),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ============ AUTH TAB ============

class AuthTab extends StatefulWidget {
  final ApiService api;
  final Function(ApiResponse) onResponse;

  const AuthTab({super.key, required this.api, required this.onResponse});

  @override
  State<AuthTab> createState() => _AuthTabState();
}

class _AuthTabState extends State<AuthTab> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'Password123');
  final _phoneController = TextEditingController();
  String _userType = 'couple';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stored data display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildInfoRow('User ID', widget.api.userId ?? '-'),
                _buildInfoRow('Email', widget.api.userEmail ?? '-'),
                _buildInfoRow('Type', widget.api.userType ?? '-'),
              ],
            ),
          ),
          const SectionTitle('QUICK ACTIONS'),
          ActionButton(
            label: 'Get My Profile',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/auth/me');
              widget.onResponse(response);
            },
          ),
          const SizedBox(height: 8),
          ActionButton(
            label: 'Refresh Token',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('POST', '/auth/refresh', body: {
                'refreshToken': widget.api._refreshToken,
              }, useAuth: false);
              if (response.isSuccess) {
                widget.api.storeAuthData(response.data['data'] ?? response.data);
              }
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('REGISTER'),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password (min 8, upper+lower+number)'),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _userType,
            decoration: const InputDecoration(labelText: 'User Type'),
            items: const [
              DropdownMenuItem(value: 'couple', child: Text('Couple')),
              DropdownMenuItem(value: 'vendor', child: Text('Vendor')),
              DropdownMenuItem(value: 'guest', child: Text('Guest')),
            ],
            onChanged: (v) => setState(() => _userType = v!),
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Register',
            onPressed: () async {
              final body = {
                'email': _emailController.text,
                'password': _passwordController.text,
                'userType': _userType,
              };
              if (_phoneController.text.isNotEmpty) {
                body['phone'] = _phoneController.text;
              }
              final response = await widget.api.request('POST', '/auth/register', body: body, useAuth: false);
              if (response.isSuccess) {
                widget.api.storeAuthData(response.data['data'] ?? response.data);
                setState(() {});
              }
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('LOGIN'),
          ActionButton(
            label: 'Login',
            onPressed: () async {
              final response = await widget.api.request('POST', '/auth/login', body: {
                'email': _emailController.text,
                'password': _passwordController.text,
              }, useAuth: false);
              if (response.isSuccess) {
                widget.api.storeAuthData(response.data['data'] ?? response.data);
                setState(() {});
              }
              widget.onResponse(response);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Color(0xFFE94560), fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

// ============ WEDDING TAB ============

class WeddingTab extends StatefulWidget {
  final ApiService api;
  final Function(ApiResponse) onResponse;

  const WeddingTab({super.key, required this.api, required this.onResponse});

  @override
  State<WeddingTab> createState() => _WeddingTabState();
}

class _WeddingTabState extends State<WeddingTab> {
  final _partner1Controller = TextEditingController(text: 'John');
  final _partner2Controller = TextEditingController(text: 'Jane');
  final _dateController = TextEditingController(text: '2027-06-15');
  final _budgetController = TextEditingController(text: '50000');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Wedding ID', style: TextStyle(color: Colors.grey)),
                Text(widget.api.weddingId ?? '-', style: const TextStyle(color: Color(0xFFE94560), fontFamily: 'monospace')),
              ],
            ),
          ),
          const SectionTitle('QUICK ACTIONS'),
          ActionButton(
            label: 'Get My Wedding',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/weddings/me');
              if (response.isSuccess && response.data['data'] != null) {
                widget.api.weddingId = response.data['data']['id'];
                setState(() {});
              }
              widget.onResponse(response);
            },
          ),
          const SizedBox(height: 8),
          ActionButton(
            label: 'Get Budget Summary',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/weddings/me/budget/summary');
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('CREATE WEDDING'),
          TextField(
            controller: _partner1Controller,
            decoration: const InputDecoration(labelText: 'Partner 1 Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _partner2Controller,
            decoration: const InputDecoration(labelText: 'Partner 2 Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(labelText: 'Wedding Date (YYYY-MM-DD)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _budgetController,
            decoration: const InputDecoration(labelText: 'Budget'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Create Wedding',
            onPressed: () async {
              final response = await widget.api.request('POST', '/weddings', body: {
                'partner1Name': _partner1Controller.text,
                'partner2Name': _partner2Controller.text,
                'date': _dateController.text,
                'budget': double.tryParse(_budgetController.text) ?? 0,
              });
              if (response.isSuccess && response.data['data'] != null) {
                widget.api.weddingId = response.data['data']['id'];
                setState(() {});
              }
              widget.onResponse(response);
            },
          ),
        ],
      ),
    );
  }
}

// ============ TASKS TAB ============

class TasksTab extends StatefulWidget {
  final ApiService api;
  final Function(ApiResponse) onResponse;

  const TasksTab({super.key, required this.api, required this.onResponse});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final _titleController = TextEditingController(text: 'Book photographer');
  final _descController = TextEditingController(text: 'Find and book a wedding photographer');
  final _dueDateController = TextEditingController(text: '2027-01-15');
  final _taskIdController = TextEditingController();
  String _category = 'photography';
  String _priority = 'medium';
  String _status = 'pending';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('QUICK ACTIONS'),
          ActionButton(
            label: 'List All Tasks',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/weddings/me/tasks');
              widget.onResponse(response);
            },
          ),
          const SizedBox(height: 8),
          ActionButton(
            label: 'Get Task Stats',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/weddings/me/tasks/stats');
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('CREATE TASK'),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dueDateController,
            decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'venue', child: Text('Venue')),
                    DropdownMenuItem(value: 'catering', child: Text('Catering')),
                    DropdownMenuItem(value: 'photography', child: Text('Photography')),
                    DropdownMenuItem(value: 'music', child: Text('Music')),
                    DropdownMenuItem(value: 'flowers', child: Text('Flowers')),
                    DropdownMenuItem(value: 'attire', child: Text('Attire')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _category = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (v) => setState(() => _priority = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
            ],
            onChanged: (v) => setState(() => _status = v!),
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Create Task',
            onPressed: () async {
              final response = await widget.api.request('POST', '/weddings/me/tasks', body: {
                'title': _titleController.text,
                'description': _descController.text,
                'dueDate': _dueDateController.text,
                'category': _category,
                'priority': _priority,
                'status': _status,
              });
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('GET/UPDATE/DELETE TASK'),
          TextField(
            controller: _taskIdController,
            decoration: const InputDecoration(labelText: 'Task ID'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Get',
                  color: const Color(0xFF0F3460),
                  onPressed: () async {
                    if (_taskIdController.text.isEmpty) return;
                    final response = await widget.api.request('GET', '/weddings/me/tasks/${_taskIdController.text}');
                    widget.onResponse(response);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionButton(
                  label: 'Delete',
                  color: Colors.red,
                  onPressed: () async {
                    if (_taskIdController.text.isEmpty) return;
                    final response = await widget.api.request('DELETE', '/weddings/me/tasks/${_taskIdController.text}');
                    widget.onResponse(response);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ GUESTS TAB ============

class GuestsTab extends StatefulWidget {
  final ApiService api;
  final Function(ApiResponse) onResponse;

  const GuestsTab({super.key, required this.api, required this.onResponse});

  @override
  State<GuestsTab> createState() => _GuestsTabState();
}

class _GuestsTabState extends State<GuestsTab> {
  final _nameController = TextEditingController(text: 'John Smith');
  final _emailController = TextEditingController(text: 'john.smith@example.com');
  final _phoneController = TextEditingController(text: '+1234567890');
  final _guestIdController = TextEditingController();
  String _rsvpStatus = 'pending';
  int _plusOnes = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('QUICK ACTIONS'),
          ActionButton(
            label: 'List All Guests',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final weddingId = widget.api.weddingId;
              if (weddingId == null) {
                widget.onResponse(ApiResponse(statusCode: 0, data: {'error': 'No wedding ID. Get your wedding first.'}, duration: 0, method: 'GET', endpoint: '/weddings/:id/guests'));
                return;
              }
              final response = await widget.api.request('GET', '/weddings/$weddingId/guests');
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('ADD GUEST'),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _rsvpStatus,
                  decoration: const InputDecoration(labelText: 'RSVP Status'),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(value: 'declined', child: Text('Declined')),
                  ],
                  onChanged: (v) => setState(() => _rsvpStatus = v!),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Plus Ones'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _plusOnes = int.tryParse(v) ?? 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Add Guest',
            onPressed: () async {
              final weddingId = widget.api.weddingId;
              if (weddingId == null) {
                widget.onResponse(ApiResponse(statusCode: 0, data: {'error': 'No wedding ID. Get your wedding first.'}, duration: 0, method: 'POST', endpoint: '/weddings/:id/guests'));
                return;
              }
              final response = await widget.api.request('POST', '/weddings/$weddingId/guests', body: {
                'name': _nameController.text,
                'email': _emailController.text,
                'phone': _phoneController.text,
                'rsvpStatus': _rsvpStatus,
                'plusOnes': _plusOnes,
              });
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('GET/DELETE GUEST'),
          TextField(
            controller: _guestIdController,
            decoration: const InputDecoration(labelText: 'Guest ID'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Get',
                  color: const Color(0xFF0F3460),
                  onPressed: () async {
                    final weddingId = widget.api.weddingId;
                    if (weddingId == null || _guestIdController.text.isEmpty) return;
                    final response = await widget.api.request('GET', '/weddings/$weddingId/guests/${_guestIdController.text}');
                    widget.onResponse(response);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionButton(
                  label: 'Delete',
                  color: Colors.red,
                  onPressed: () async {
                    final weddingId = widget.api.weddingId;
                    if (weddingId == null || _guestIdController.text.isEmpty) return;
                    final response = await widget.api.request('DELETE', '/weddings/$weddingId/guests/${_guestIdController.text}');
                    widget.onResponse(response);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ BUDGET TAB ============

class BudgetTab extends StatefulWidget {
  final ApiService api;
  final Function(ApiResponse) onResponse;

  const BudgetTab({super.key, required this.api, required this.onResponse});

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  final _categoryController = TextEditingController(text: 'Photography');
  final _descController = TextEditingController(text: 'Wedding photographer deposit');
  final _estimatedController = TextEditingController(text: '2000');
  final _actualController = TextEditingController(text: '1800');
  final _itemIdController = TextEditingController();
  bool _paid = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('QUICK ACTIONS'),
          ActionButton(
            label: 'Get Budget',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final weddingId = widget.api.weddingId;
              if (weddingId == null) {
                widget.onResponse(ApiResponse(statusCode: 0, data: {'error': 'No wedding ID'}, duration: 0, method: 'GET', endpoint: '/weddings/:id/budget'));
                return;
              }
              final response = await widget.api.request('GET', '/weddings/$weddingId/budget');
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('ADD EXPENSE'),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _estimatedController,
                  decoration: const InputDecoration(labelText: 'Estimated Cost'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _actualController,
                  decoration: const InputDecoration(labelText: 'Actual Cost'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Paid'),
            value: _paid,
            onChanged: (v) => setState(() => _paid = v ?? false),
            contentPadding: EdgeInsets.zero,
          ),
          ActionButton(
            label: 'Add Expense',
            onPressed: () async {
              final weddingId = widget.api.weddingId;
              if (weddingId == null) {
                widget.onResponse(ApiResponse(statusCode: 0, data: {'error': 'No wedding ID'}, duration: 0, method: 'POST', endpoint: '/weddings/:id/budget'));
                return;
              }
              final response = await widget.api.request('POST', '/weddings/$weddingId/budget', body: {
                'category': _categoryController.text,
                'description': _descController.text,
                'estimatedCost': double.tryParse(_estimatedController.text) ?? 0,
                'actualCost': double.tryParse(_actualController.text) ?? 0,
                'paid': _paid,
              });
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('DELETE EXPENSE'),
          TextField(
            controller: _itemIdController,
            decoration: const InputDecoration(labelText: 'Budget Item ID'),
          ),
          const SizedBox(height: 8),
          ActionButton(
            label: 'Delete Expense',
            color: Colors.red,
            onPressed: () async {
              final weddingId = widget.api.weddingId;
              if (weddingId == null || _itemIdController.text.isEmpty) return;
              final response = await widget.api.request('DELETE', '/weddings/$weddingId/budget/${_itemIdController.text}');
              widget.onResponse(response);
            },
          ),
        ],
      ),
    );
  }
}

// ============ VENDORS TAB ============

class VendorsTab extends StatefulWidget {
  final ApiService api;
  final Function(ApiResponse) onResponse;

  const VendorsTab({super.key, required this.api, required this.onResponse});

  @override
  State<VendorsTab> createState() => _VendorsTabState();
}

class _VendorsTabState extends State<VendorsTab> {
  final _searchController = TextEditingController();
  final _vendorIdController = TextEditingController();
  final _businessNameController = TextEditingController(text: 'Amazing Photo Studio');
  final _categoryIdController = TextEditingController();
  final _descriptionController = TextEditingController(text: 'Professional wedding photography');
  final _basePriceController = TextEditingController(text: '2500');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('PUBLIC DISCOVERY'),
          ActionButton(
            label: 'List Categories',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/categories', useAuth: false);
              widget.onResponse(response);
            },
          ),
          const SizedBox(height: 8),
          ActionButton(
            label: 'List All Vendors',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/vendors', useAuth: false);
              widget.onResponse(response);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(labelText: 'Search Query'),
          ),
          const SizedBox(height: 8),
          ActionButton(
            label: 'Search Vendors',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/vendors?search=${_searchController.text}', useAuth: false);
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('VENDOR DETAILS'),
          TextField(
            controller: _vendorIdController,
            decoration: const InputDecoration(labelText: 'Vendor ID'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Get Details',
                  color: const Color(0xFF0F3460),
                  onPressed: () async {
                    if (_vendorIdController.text.isEmpty) return;
                    final response = await widget.api.request('GET', '/vendors/${_vendorIdController.text}', useAuth: false);
                    widget.onResponse(response);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionButton(
                  label: 'Get Packages',
                  color: const Color(0xFF0F3460),
                  onPressed: () async {
                    if (_vendorIdController.text.isEmpty) return;
                    final response = await widget.api.request('GET', '/vendors/${_vendorIdController.text}/packages', useAuth: false);
                    widget.onResponse(response);
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          const SectionTitle('VENDOR REGISTRATION (as vendor user)'),
          TextField(
            controller: _businessNameController,
            decoration: const InputDecoration(labelText: 'Business Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _categoryIdController,
            decoration: const InputDecoration(labelText: 'Category ID'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _basePriceController,
            decoration: const InputDecoration(labelText: 'Base Price'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Register as Vendor',
            onPressed: () async {
              final response = await widget.api.request('POST', '/vendors/register', body: {
                'businessName': _businessNameController.text,
                'categoryId': _categoryIdController.text,
                'description': _descriptionController.text,
                'basePrice': double.tryParse(_basePriceController.text) ?? 0,
              });
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('VENDOR DASHBOARD (logged in as vendor)'),
          ActionButton(
            label: 'Get My Vendor Profile',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/vendors/me');
              widget.onResponse(response);
            },
          ),
          const SizedBox(height: 8),
          ActionButton(
            label: 'Get Dashboard',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/vendors/me/dashboard');
              widget.onResponse(response);
            },
          ),
        ],
      ),
    );
  }
}

// ============ BOOKINGS TAB ============

class BookingsTab extends StatefulWidget {
  final ApiService api;
  final Function(ApiResponse) onResponse;

  const BookingsTab({super.key, required this.api, required this.onResponse});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  final _vendorIdController = TextEditingController();
  final _packageIdController = TextEditingController();
  final _bookingDateController = TextEditingController(text: '2027-06-15');
  final _notesController = TextEditingController(text: 'Looking forward to working with you');
  final _bookingIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('QUICK ACTIONS'),
          ActionButton(
            label: 'List My Bookings',
            color: const Color(0xFF0F3460),
            onPressed: () async {
              final response = await widget.api.request('GET', '/bookings/my-bookings');
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('CREATE BOOKING (as couple)'),
          TextField(
            controller: _vendorIdController,
            decoration: const InputDecoration(labelText: 'Vendor ID'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _packageIdController,
            decoration: const InputDecoration(labelText: 'Package ID (optional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bookingDateController,
            decoration: const InputDecoration(labelText: 'Booking Date (YYYY-MM-DD)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Create Booking',
            onPressed: () async {
              final body = <String, dynamic>{
                'vendorId': _vendorIdController.text,
                'bookingDate': _bookingDateController.text,
                'notes': _notesController.text,
              };
              if (_packageIdController.text.isNotEmpty) {
                body['packageId'] = _packageIdController.text;
              }
              final response = await widget.api.request('POST', '/bookings', body: body);
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('BOOKING ACTIONS'),
          TextField(
            controller: _bookingIdController,
            decoration: const InputDecoration(labelText: 'Booking ID'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Get Details',
                  color: const Color(0xFF0F3460),
                  onPressed: () async {
                    if (_bookingIdController.text.isEmpty) return;
                    final response = await widget.api.request('GET', '/bookings/${_bookingIdController.text}');
                    widget.onResponse(response);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionButton(
                  label: 'Cancel',
                  color: Colors.red,
                  onPressed: () async {
                    if (_bookingIdController.text.isEmpty) return;
                    final response = await widget.api.request('DELETE', '/bookings/${_bookingIdController.text}');
                    widget.onResponse(response);
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          const SectionTitle('VENDOR BOOKING ACTIONS'),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Accept',
                  color: Colors.green,
                  onPressed: () async {
                    if (_bookingIdController.text.isEmpty) return;
                    final response = await widget.api.request('POST', '/bookings/${_bookingIdController.text}/accept');
                    widget.onResponse(response);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionButton(
                  label: 'Decline',
                  color: Colors.orange,
                  onPressed: () async {
                    if (_bookingIdController.text.isEmpty) return;
                    final response = await widget.api.request('POST', '/bookings/${_bookingIdController.text}/decline');
                    widget.onResponse(response);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ActionButton(
            label: 'Complete Booking',
            color: Colors.green,
            onPressed: () async {
              if (_bookingIdController.text.isEmpty) return;
              final response = await widget.api.request('POST', '/bookings/${_bookingIdController.text}/complete');
              widget.onResponse(response);
            },
          ),
        ],
      ),
    );
  }
}

// ============ CUSTOM TAB ============

class CustomTab extends StatefulWidget {
  final ApiService api;
  final Function(ApiResponse) onResponse;

  const CustomTab({super.key, required this.api, required this.onResponse});

  @override
  State<CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {
  final _endpointController = TextEditingController(text: '/auth/me');
  final _bodyController = TextEditingController();
  String _method = 'GET';
  bool _useAuth = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('CUSTOM REQUEST'),
          DropdownButtonFormField<String>(
            value: _method,
            decoration: const InputDecoration(labelText: 'Method'),
            items: const [
              DropdownMenuItem(value: 'GET', child: Text('GET')),
              DropdownMenuItem(value: 'POST', child: Text('POST')),
              DropdownMenuItem(value: 'PUT', child: Text('PUT')),
              DropdownMenuItem(value: 'DELETE', child: Text('DELETE')),
            ],
            onChanged: (v) => setState(() => _method = v!),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _endpointController,
            decoration: const InputDecoration(labelText: 'Endpoint (e.g., /auth/me)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(labelText: 'Request Body (JSON)'),
            maxLines: 5,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Include Auth Token'),
            value: _useAuth,
            onChanged: (v) => setState(() => _useAuth = v ?? true),
            contentPadding: EdgeInsets.zero,
          ),
          ActionButton(
            label: 'Send Request',
            onPressed: () async {
              Map<String, dynamic>? body;
              if (_bodyController.text.isNotEmpty && _method != 'GET') {
                try {
                  body = jsonDecode(_bodyController.text);
                } catch (e) {
                  widget.onResponse(ApiResponse(
                    statusCode: 0,
                    data: {'error': 'Invalid JSON: $e'},
                    duration: 0,
                    method: _method,
                    endpoint: _endpointController.text,
                  ));
                  return;
                }
              }
              final response = await widget.api.request(
                _method,
                _endpointController.text,
                body: body,
                useAuth: _useAuth,
              );
              widget.onResponse(response);
            },
          ),
          const Divider(height: 32),
          const SectionTitle('BASE URL'),
          TextField(
            decoration: const InputDecoration(labelText: 'API Base URL'),
            controller: TextEditingController(text: widget.api.baseUrl),
            onChanged: (v) => widget.api.baseUrl = v,
          ),
        ],
      ),
    );
  }
}
