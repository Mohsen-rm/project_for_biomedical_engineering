import 'package:flutter/material.dart';
import 'db/db_helper_sites.dart';
import 'qr_scanner.dart'; // استيراد QRScanner

class OcdScreen extends StatefulWidget {
  @override
  _OcdScreenState createState() => _OcdScreenState();
}

class _OcdScreenState extends State<OcdScreen> {
  List<Map<String, dynamic>> locations = [];
  final dbHelper = DbHelperSites();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final data = await dbHelper.getLocations();
    setState(() {
      locations = data;
    });
  }

  Future<void> _addItem(int locationId) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController detailsController = TextEditingController();

    String? qrCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScanner()), // فتح الماسح
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة عنصر'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'أدخل اسم العنصر'),
              ),
              TextField(
                controller: detailsController,
                decoration: InputDecoration(hintText: 'أدخل التفاصيل'),
              ),
              if (qrCode != null) ...[
                SizedBox(height: 10),
                Text('QR Code: $qrCode'),
              ],
            ],
          ),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('إضافة'),
              onPressed: () async {
                await dbHelper.insertItem({
                  'name': nameController.text,
                  'details': detailsController.text,
                  'qr_code': qrCode,
                  'location_id': locationId,
                });
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _searchByQRCode() async {
    String? qrCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScanner()), // فتح الماسح
    );

    if (qrCode != null) {
      final item = await dbHelper.getItemByQRCode(qrCode);
      if (item != null) {
        _showItemDetails(item);
      } else {
        _showNotFoundDialog();
      }
    }
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تفاصيل العنصر'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الاسم: ${item['name']}'),
              SizedBox(height: 10),
              Text('التفاصيل: ${item['details'] ?? 'لا توجد تفاصيل'}'),
              SizedBox(height: 10),
              Text('QR Code: ${item['qr_code']}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('إغلاق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('العنصر غير موجود'),
          content: Text('لم يتم العثور على عنصر بهذا الرمز.'),
          actions: [
            TextButton(
              child: Text('إغلاق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('المواقع والأشياء')),
      body: ListView(
        children: locations.map((location) {
          return ExpansionTile(
            title: Text(location['name']),
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getItemsByLocation(location['id']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: snapshot.data!.map((item) {
                      return ListTile(
                        title: Text(item['name']),
                        subtitle: Text(item['details'] ?? 'لا توجد تفاصيل'),
                        trailing: Text(item['qr_code'] ?? 'لا يوجد QR'),
                      );
                    }).toList(),
                  );
                },
              ),
              ListTile(
                title: Text('إضافة عنصر جديد'),
                trailing: Icon(Icons.add),
                onTap: () {
                  _addItem(location['id']);
                },
              ),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: _searchByQRCode,
      ),
    );
  }
}
