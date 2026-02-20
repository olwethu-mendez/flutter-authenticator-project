import 'package:authentipass/features/auth/presentation/pages/splash_page.dart';
import 'package:authentipass/features/user_details/presentation/bloc/user_details_bloc.dart';
import 'package:authentipass/features/user_details/presentation/bloc/user_details_state.dart';
import 'package:authentipass/features/users_management/domain/entities/users_list_entity.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_bloc.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_event.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_state.dart';
import 'package:authentipass/features/users_management_list_view/presentation/bloc/users_view_bloc.dart';
import 'package:authentipass/features/users_management_list_view/presentation/bloc/users_view_event.dart';
import 'package:authentipass/features/users_management_list_view/presentation/bloc/users_view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:authentipass/app_builder/app.dart';

enum UsersListType {
  all, active, deactivated, banned, unverified, withoutProfile
}

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key, required this.status});
  final UsersListType status;

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> with RouteAware {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe the current context to the observer
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Always unsubscribe
    super.dispose();
  }

  @override
  void didPush() {
    // Called when this screen is pushed onto the stack
    print('Screen is now at the top.');
    _fetchUsers();
    context.read<UsersViewBloc>().add(GetViewsRequested());
  }

  @override
  void didPopNext() {
    // Called when the screen on top of this one is popped
    // This is the "I'm back on top" moment
    print('Back at the top of the stack.');
    _fetchUsers();
  }

  void _fetchUsers() {
    context.read<UsersBloc>().add(GetUsersRequested());
  }

  List<UsersListEntity> _usersList(List<UsersListEntity> users){
    if(widget.status == UsersListType.active) return users.where((x)=>x.isDeactivated == false && x.isDeactivatedByAdmin == false && (x.emailConfirmed == true || x.phoneNumberConfirmed == true) && (x.profileId != null)).toList();
    if(widget.status == UsersListType.banned) return users.where((x)=>x.isDeactivatedByAdmin == true).toList();
    if(widget.status == UsersListType.deactivated) return users.where((x)=>x.isDeactivated == true && x.isDeactivatedByAdmin == false).toList();
    if(widget.status == UsersListType.unverified) return users.where((x)=>x.emailConfirmed == false && x.phoneNumberConfirmed == false).toList();
    if(widget.status == UsersListType.withoutProfile) return users.where((x)=>x.profileId == null).toList();
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          // FIX: If we came back from a SingleUserLoaded state, we need to re-fetch
          if (state is UsersInitial) {
            _fetchUsers();
            return const SplashPage();
          }

          if (state is UsersLoading) return const SplashPage();

          if (state is UsersLoaded) {
            if (state.users.isEmpty) return const Center(child: Text("No users found."));

            return BlocListener<UserDetailsBloc, UserDetailsState>(
              listener: (context, detailsState){
                if (detailsState is UserActivated || detailsState is UserDeactivated) {
                  _fetchUsers();
                }
              },
              child: RefreshIndicator.adaptive(
                onRefresh: () async => _fetchUsers(),
                child: BlocBuilder<UsersViewBloc, UsersViewState>(
                  builder: (context, viewState) {
                    final bool isGridView = viewState is IsGrid;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.status == UsersListType.active ? "Active Users" :widget.status == UsersListType.banned ? "Banned Users" :widget.status == UsersListType.deactivated ? "Deactivated Users"  :widget.status == UsersListType.unverified ? "Unverified Users"  :widget.status == UsersListType.withoutProfile ? "Users without a Profile"  :"All Users", style: Theme.of(context).textTheme.titleLarge,),
                              Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isGridView ? Icons.list : Icons.grid_view,
                                ),
                                onPressed: () {
                                  context.read<UsersViewBloc>().add(SetViewsRequested(isGrid: !isGridView));
                                }
                              ),]),
                            ],
                          ),
                        ),
                        Expanded(
                          child: isGridView
                            ? _buildGrid(_usersList(state.users))
                            : _buildList(_usersList(state.users))
                        ),
                        
                      ],
                    );
                  },
                ),
              ),
            );
          }

          if (state is UsersError) return Center(child: Text(state.message));

          return Column(
            children: [
              const Center(child: Text("No users found")),
              TextButton.icon(
                onPressed: () =>
                    context.read<UsersBloc>().add(GetUsersRequested()),
                label: Text("Retry"),
                icon: Icon(Icons.rotate_left),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- LIST VIEW ---
  Widget _buildList(List users) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) => _buildUserTile(users[index]),
    );
  }

  // --- GRID VIEW ---
  Widget _buildGrid(List users) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) => _buildUserCard(users[index]),
    );
  }

  // Common Tile for List
  Widget _buildUserTile(UsersListEntity user) {
    return ListTile(
      leading: _UserAvatar(user: user),
      title: Text("${user.firstName} ${user.lastName}"),
      subtitle: Text(user.username ?? "no email/phone number"),
      trailing: _StatusIcon(
        isDeactivated: user.isDeactivated == true || user.isDeactivatedByAdmin == true,
        isUnverified: user.emailConfirmed == false && user.phoneNumberConfirmed == false,
      ),
      onTap: () {
        context.push(
          '/user-details/${user.userId}',
        ); // Fixed: profileId
      },
    );
  }

  // Common Card for Grid
  Widget _buildUserCard(UsersListEntity user) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/user-details/${user.userId}'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _UserAvatar(user: user, radius: 35),
            const SizedBox(height: 10),
            Text(
              "${user.firstName}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${user.lastName}"),
            const SizedBox(height: 8),
            _StatusIcon(
              isDeactivated: user.isDeactivated == true || user.isDeactivatedByAdmin == true,
              isUnverified: user.emailConfirmed == false && user.phoneNumberConfirmed == false,
            ),
          ],
        ),
      ),
    );
  }
}

// Sub-widgets for cleaner code
class _UserAvatar extends StatelessWidget {
  final UsersListEntity user;
  final double radius;
  const _UserAvatar({required this.user, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: user.profilePictureUrl != null
          ? NetworkImage(user.profilePictureUrl!)
          : null,
      child: user.profilePictureUrl == null
          ? Text("${user.firstName![0]}${user.lastName![0]}".toUpperCase())
          : null,
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final bool isDeactivated;
  final bool isUnverified;
  const _StatusIcon({required this.isDeactivated, required this.isUnverified});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isDeactivated ? Icons.block : isUnverified ? Icons.warning : Icons.check_circle,
      color: isDeactivated ? Colors.red : isUnverified ? Colors.orange :Colors.green,
    );
  }
}
