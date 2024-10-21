import 'package:biomedical_engineering_app/db/db_helper_sites.dart';
import 'package:flutter/material.dart';

class LocationsPage extends StatefulWidget {
  @override
  _LocationsPageState createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  List<Map<String, dynamic>> locations = [];
  final dbHelper = DbHelperSites();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  // تحميل المواقع من قاعدة البيانات
  Future<void> _loadLocations() async {
    final data = await dbHelper.getLocations();
    setState(() {
      locations = data;
    });
  }

  // عرض مربع حوار لإضافة أو تعديل الموقع
  void _showLocationDialog({Map<String, dynamic>? location}) {
    TextEditingController nameController = TextEditingController(
      text: location != null ? location['name'] : '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(location != null ? 'تعديل الموقع' : 'إضافة موقع جديد'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'اسم الموقع',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                String locationName = nameController.text.trim();
                if (locationName.isNotEmpty) {
                  if (location != null) {
                    // تعديل الموقع
                    await dbHelper.updateLocation({
                      'id': location['id'],
                      'name': locationName,
                    });
                  } else {
                    // إضافة موقع جديد
                    await dbHelper.insertLocation({
                      'name': locationName,
                    });
                  }
                  Navigator.of(context).pop();
                  _loadLocations();
                }
              },
              child: Text(location != null ? 'تعديل' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  // حذف الموقع
  void _deleteLocation(int id) async {
    await dbHelper.deleteLocation(id);
    _loadLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المواقع'),
      ),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          var location = locations[index];
          return ListTile(
            title: Text(location['name']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showLocationDialog(location: location);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteLocation(location['id']);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLocationDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
