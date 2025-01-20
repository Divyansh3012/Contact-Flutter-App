import 'package:business_card/components/bottomNavBar.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  void getPermission() async {
    if (await Permission.contacts.isGranted) {
      await fetchContacts();
    } else {
      await Permission.contacts.request();
      if (await Permission.contacts.isGranted) {
        await fetchContacts();
      }
    }
  }

  Future<void> fetchContacts() async {
    setState(() {
      isLoading = true;
    });
    contacts = await ContactsService.getContacts();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> syncContacts() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing contacts...')),
    );

    try {
      await fetchContacts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts synced successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error syncing contacts: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                child: Text(
                  contacts[index].displayName![0],
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              title: Text(
                contacts[index].displayName!,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              subtitle: Text(
                contacts[index].phones!.isNotEmpty
                    ? contacts[index].phones![0].value!
                    : 'No phone number',
                style: const TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: syncContacts,
        child: const Icon(Icons.sync),
        tooltip: 'Sync Contacts',
      ),
    );
  }
}
