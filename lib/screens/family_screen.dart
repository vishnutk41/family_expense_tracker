import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/family_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/constants.dart';
import '../providers/ui_state_providers.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  final TextEditingController nameC = TextEditingController();
  final TextEditingController joinC = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final familyState = ref.watch(familyViewModelProvider);
    final familyViewModel = ref.read(familyViewModelProvider.notifier);
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final isLoading = ref.watch(familyLoadingProvider);

    return authState.when(
      data: (user) {
        if (user == null) return Scaffold(body: Center(child: Text('Not authenticated')));
        
        return Scaffold(
          appBar: AppBar(title: Text('Family Setup')),
          body: familyState.when(
            data: (familyId) {
              if (familyId != null) {
                return Center(child: Text('Family selected: $familyId'));
              }
              
              return Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: nameC, 
                      decoration: InputDecoration(labelText: 'Create Family Name'),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isLoading ? null : () async {
                        if (nameC.text.isNotEmpty) {
                          ref.read(familyLoadingProvider.notifier).state = true;
                          try {
                            final familyId = await familyViewModel.createFamily(nameC.text);
                            await familyViewModel.joinFamily(user.uid, familyId);
                            nameC.clear();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          } finally {
                            ref.read(familyLoadingProvider.notifier).state = false;
                          }
                        }
                      }, 
                      child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Create Family')
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                    TextField(
                      controller: joinC, 
                      decoration: InputDecoration(labelText: 'Join Family by ID'),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isLoading ? null : () async {
                        if (joinC.text.isNotEmpty) {
                          ref.read(familyLoadingProvider.notifier).state = true;
                          try {
                            await familyViewModel.joinFamily(user.uid, joinC.text);
                            joinC.clear();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          } finally {
                            ref.read(familyLoadingProvider.notifier).state = false;
                          }
                        }
                      }, 
                      child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Join Family')
                    ),
                  ],
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text('Error loading family data')),
          ),
        );
      },
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(body: Center(child: Text('Error'))),
    );
  }
}
