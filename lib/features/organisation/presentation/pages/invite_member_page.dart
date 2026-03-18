import 'package:auth_shared/widget/cards/user_card.dart';
import 'package:auth_shared/widget/library.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_bloc.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_event.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InviteMemberPage extends StatefulWidget {
  const InviteMemberPage({super.key});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController countryCodeController;
  late TextEditingController phoneNumberController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    emailController = TextEditingController();
    countryCodeController = TextEditingController();
    phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    countryCodeController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void _onSearchRequested() {
    // Basic Validation: Don't search if all fields are empty
    if (fullNameController.text.isEmpty &&
        emailController.text.isEmpty &&
        phoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter at least one search criteria"),
        ),
      );
      return;
    }

    context.read<OrgBloc>().add(
      GetInvitableUsersRequested(
        fullNameController.text.trim(),
        emailController.text.trim(),
        phoneNumberController.text.trim(),
      ),
    );
  }

  void _inviteUser(dynamic item) {
    CustomDialogs.showActionDialog(
      context: context,
      title: "Invite ${item.firstName}",
      text: "Invite ${item.firstName} ${item.lastName} to your organization?",
      confirmText: "Send Invite",
      onConfirm: () {
        context.read<OrgBloc>().add(
          InviteUserToOrganisationRequested(item.profileId!),
        );
      },
    );
  }

  void _clearSearch(bool clearList) {
    if (clearList == false) {
      fullNameController.clear();
      emailController.clear();
      phoneNumberController.clear();
    } else {
      // Also reset the Bloc state so the results list disappears
      context.read<OrgBloc>().add(
        ClearOrgSearchRequested(),
      ); // Assuming this event exists
    }
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<OrgBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invite New Member"),
        actions: [
          // Clear Search Button in the AppBar for easy access
          if(state is OrgLoaded && state.invitableUsers != null)
          TextButton(
            onPressed:() => _clearSearch(true),
            child: const Text("Clear", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // --- SEARCH FORM SECTION ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find User",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Search for a user by name, email, or phone number to add them to your team.",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: fullNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email Address",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PhoneNumberInput(
                    supportedCodes: const ["+266", "+268", "+27"],
                    phoneNumberController: phoneNumberController,
                    countryCodeController: countryCodeController,
                    localCode: "+27",
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<OrgBloc, OrgState>(
                    builder: (context, state) {
                      final isLoading = state is OrgLoading;
                      return CustomIconButton(
                        onPressed: isLoading ? null :(){
                           _onSearchRequested();
                           _clearSearch(false);
                        },
                        icon: const Icon(Icons.search),
                        label: "Search Users",
                        isSubmitting: isLoading,
                      );
                    },
                  ),
                  const Divider(height: 48),
                ],
              ),
            ),
          ),

          // --- RESULTS SECTION ---
          BlocBuilder<OrgBloc, OrgState>(
            builder: (context, state) {
              if (state is OrgLoading) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // if (state is OrgError) {
              //   return SliverToBoxAdapter(
              //     child: Center(
              //       child: Padding(
              //         padding: const EdgeInsets.all(20.0),
              //         child: Text(
              //           state.message,
              //           style: const TextStyle(color: Colors.red),
              //         ),
              //       ),
              //     ),
              //   );
              // }

              if (state is OrgLoaded) {
                final users = state.invitableUsers ?? [];

                if (users.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text("No users found matching your search."),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = users[index];
                      final isDisabled =
                          (item.isDeactivated == true ||
                          item.isDeactivatedByAdmin == true);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: UserCard(
                          firstName: item.firstName ?? "",
                          lastName: item.lastName ?? "",
                          title: item.username,
                          imageUrl: item.profilePictureUrl,
                          onTap: isDisabled ? null : () => _inviteUser(item),
                        ),
                      );
                    }, childCount: users.length),
                  ),
                );
              }

              // Initial State / Waiting for search
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
