import 'package:auth_shared/widget/library.dart';
import 'package:authentipass/features/organisation/data/models/get_organisations_model.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_bloc.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_event.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OrganisationDashboardPage extends StatefulWidget {
  const OrganisationDashboardPage({super.key});

  @override
  State<OrganisationDashboardPage> createState() =>
      _OrganisationDashboardPageState();
}

class _OrganisationDashboardPageState extends State<OrganisationDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // Make sure vsync is correct
    // Fetch everything on load
    context.read<OrgBloc>().add(GetAllOrganisationsRequested());
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController, // Set the controller here
            //labelColor: Colors.white,
            tabs: [
              Tab(text: "My Memberships"),
              Tab(text: "Managed By Me"),
              Tab(text: "Explore Public"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController, // Set the controller here as well
              children: [
                OrganisationListWidget(type: OrgFetchType.joined),
                OrganisationListWidget(type: OrgFetchType.managed),
                OrganisationListWidget(type: OrgFetchType.public),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrganisationListWidget extends StatelessWidget {
  const OrganisationListWidget({super.key, required this.type});
  final OrgFetchType type;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrgBloc, OrgState>(
      builder: (context, state) {
        if (state is OrgLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OrgLoaded) {
          List<dynamic> displayList = [];
          final activeOrgId = state.activeOrgId;

          if (type == OrgFetchType.managed) {
            displayList = state.myOrganisations?.toList() ?? [];
          } else if (type == OrgFetchType.joined) {
            displayList = state.organisations?.toList() ?? [];
          } else {
            displayList = state.publicOrganisations ?? [];
          }
          // Debug Print: Check if the list actually has items before the empty check
          print("Display List Length for $type: ${displayList.length}");

          if (type == OrgFetchType.managed) {
            if (displayList.isEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      Text("No organisations found in ${type.name}"),
                      TextButton(
                        onPressed: () => context.read<OrgBloc>().add(
                          GetMyOrganisationsRequested(),
                        ),
                        child: Text("Refresh"),
                      ),
                    ],
                  ),
                ),
              );
            }
          } else if (type == OrgFetchType.joined) {
            if (displayList.isEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      Text("No organisations found in ${type.name}"),
                      TextButton(
                        onPressed: () => context.read<OrgBloc>().add(
                          GetOrganisationsRequested(),
                        ),
                        child: Text("Refresh"),
                      ),
                    ],
                  ),
                ),
              );
            }
          } else {
            if (displayList.isEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      Text("No organisations found in ${type.name}"),
                      TextButton(
                        onPressed: () => context.read<OrgBloc>().add(
                          GetPublicOrganisationsRequested(),
                        ),
                        child: Text("Refresh"),
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: displayList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final org = displayList[index];
              return _buildOrgCard(context, org, activeOrgId);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrgCard(BuildContext context, dynamic org, String? activeOrgId) {
    //final bool isPublicTab = type == OrgFetchType.public;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            org.organizationImageUrl ?? 'https://placehold.co/100',
          ),
        ),
        title: Text(
          org.name ?? "Unknown Org",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(org.subdomain ?? ""),
        trailing: _buildTrailing(context, org, activeOrgId),
        onTap: () {
          final orgId = org.organizationId;
          if (orgId != null && orgId.isNotEmpty) {
            context.push('/organisation-details/$orgId');
          } else {
            // Handle error: missing organization ID
            print('No valid organization ID');
          }
        },
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    dynamic org,
    String? activeOrgId,
  ) {
    if (type == OrgFetchType.joined && org is GetOrganisationsModel) {
      if (org.invitationAccepted == null) {
        return ElevatedButton(
          onPressed: () {
            context.read<OrgBloc>().add(
              AcceptInvitationRequested(org.organizationId!, true),
            );
          },
          child: const Text("Accept"),
        );
      }
      return InkWell(
        onTap: (activeOrgId == null || activeOrgId != org.organizationId)
            ? () {
                List<Widget> items = [
                  ListTile(
                    leading: Icon(Icons.repeat_rounded),
                    title: Text("Switch to ${org.name ?? "this Organisation"}"),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<OrgBloc>().add(
                        SwitchOrganisationRequested(org.organizationId!),
                      );
                    },
                    trailing: Icon(Icons.chevron_right),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.open_in_new),
                    title: Text("Open ${org.name ?? "this Organisation"}"),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(
                        '/organisation-details/${org.organizationId}',
                      );
                    },
                    trailing: Icon(Icons.chevron_right),
                  ),
                ];
                CustomModalBottomSheet.show(
                  context: context,
                  title: "Choose action for ${org.name ?? "this organisation"}",
                  child: SingleChildScrollView(child: Column(children: items)),
                  isScrollControlled: true,
                );
              }
            : null,
        child: Icon(Icons.chevron_right),
      );
    } else {
      return Icon(Icons.chevron_right);
    }
  }
}

enum OrgFetchType { joined, managed, public }
