import 'package:authentipass/features/auth/presentation/pages/splash_page.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_bloc.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_event.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OrganisationDetailsPage extends StatelessWidget {
  final String organisationId;
  const OrganisationDetailsPage({required this.organisationId, super.key});

  @override
  Widget build(BuildContext context) {
    context.read<OrgBloc>().add(GetOrganisationRequested(organisationId));
    return Scaffold(
      body: BlocBuilder<OrgBloc, OrgState>(
        builder: (context, state) {
          // Logic to display organisation details (Header image, name, status, etc.)
          final organisation = (state is OrgLoaded) ? state.organisation : null;
          final activeId = (state is OrgLoaded) ? state.activeOrgId : null;
          if (organisation == null) return SplashPage();
          //if (organisation.status == "Active"){
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl:
                        organisation.organizationHeaderImageUrl ??
                        "https://placehold.co/900x300/png?text=No+Header+Uploaded",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organisation.name ?? "Organisation Name",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(organisation.description ?? ""),
                      const Divider(),
                      if (organisation.isAdmin == true && activeId != null)
                        ElevatedButton(
                          onPressed: () => context.push('/invite-member'),
                          child: Text("Invite Users"),
                        ),
                      // Add members or project lists here
                      //Text(organisation.)
                    ],
                  ),
                ),
              ),
            ],
          );

          //}return
        },
      ),
    );
  }
}
