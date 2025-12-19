import 'package:flutter/material.dart';
import '../models/game_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late GameSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = GameSettings();
    _nameController = TextEditingController(text: _settings.playerName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.purple.shade700,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Player Name Section
          _buildSectionTitle('Player Profile'),
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Player Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      _settings.setPlayerName(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Audio & Vibration Section
          _buildSectionTitle('Audio & Haptics'),
          Card(
            elevation: 2,
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text('Sound Effects'),
                  subtitle: Text('Play game sounds'),
                  value: _settings.soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _settings.setSoundEnabled(value ?? true);
                    });
                  },
                  secondary: Icon(Icons.volume_up),
                ),
                Divider(height: 0),
                CheckboxListTile(
                  title: Text('Vibration'),
                  subtitle: Text('Haptic feedback on actions'),
                  value: _settings.vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _settings.setVibrationEnabled(value ?? true);
                    });
                  },
                  secondary: Icon(Icons.vibration),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Display Section
          _buildSectionTitle('Display'),
          Card(
            elevation: 2,
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text('Dark Mode'),
                  subtitle: Text('Enable dark theme'),
                  value: _settings.darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _settings.setDarkModeEnabled(value ?? false);
                    });
                  },
                  secondary: Icon(Icons.dark_mode),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Game Speed Section
          _buildSectionTitle('Game Speed'),
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Speed: ${_settings.gameSpeed.toStringAsFixed(1)}x',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _settings.gameSpeed < 1
                            ? 'Slow'
                            : _settings.gameSpeed > 1
                            ? 'Fast'
                            : 'Normal',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Slider(
                    value: _settings.gameSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 6,
                    label: '${_settings.gameSpeed.toStringAsFixed(1)}x',
                    onChanged: (value) {
                      setState(() {
                        _settings.setGameSpeed(value);
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0.5x', style: TextStyle(fontSize: 12)),
                      Text('1.0x', style: TextStyle(fontSize: 12)),
                      Text('2.0x', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Reset Button
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Reset Settings'),
                  content: Text(
                    'Are you sure you want to reset all settings to default?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _settings.resetToDefaults();
                          _nameController.text = _settings.playerName;
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Reset to Default Settings',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple.shade700,
        ),
      ),
    );
  }
}
