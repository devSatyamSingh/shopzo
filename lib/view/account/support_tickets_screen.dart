import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/support_ticket_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../viewmodel/support_viewmodel.dart';

class MySupportTicketsScreen extends StatelessWidget {
  const MySupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupportViewModel()..fetchMyTickets(),
      child: const _MySupportTicketsView(),
    );
  }
}

class _MySupportTicketsView extends StatelessWidget {
  const _MySupportTicketsView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(title: const Text('My Tickets')),
      body: Consumer<SupportViewModel>(
        builder: (context, vm, _) {
          // ---------------- SKELETON LOADING ----------------
          if (vm.listStatus == SupportListStatus.loading) {
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              itemCount: 6,
              separatorBuilder: (_, __) => SizedBox(height: size.height * 0.016),
              itemBuilder: (_, __) => const _SkeletonTicketCard(),
            );
          }

          // ---------------- ERROR ----------------
          if (vm.listStatus == SupportListStatus.error) {
            return _CenteredState(
              icon: Icons.wifi_off_rounded,
              title: 'Failed to load tickets',
              subtitle: vm.listErrorMessage,
              actionLabel: 'Retry',
              onAction: () => vm.fetchMyTickets(),
            );
          }

          // ---------------- EMPTY ----------------
          if (vm.listStatus == SupportListStatus.empty) {
            return _CenteredState(
              icon: Icons.forum_outlined,
              title: 'No tickets yet',
              subtitle: 'Jab bhi aap support ko contact karenge, wo ticket yahan dikhega.',
            );
          }

          // ---------------- LOADED ----------------
          return RefreshIndicator(
            color: ColorConstant.primaryColor,
            onRefresh: () => vm.fetchMyTickets(silent: true),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: vm.tickets.length,
              separatorBuilder: (_, __) => SizedBox(height: size.height * 0.016),
              itemBuilder: (context, index) => _TicketCard(ticket: vm.tickets[index]),
            ),
          );
        },
      ),
    );
  }
}

/// ---------------- TICKET CARD ----------------
class _TicketCard extends StatelessWidget {
  final SupportTicketModel ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final status = ticket.status;

    return Container(
      decoration: BoxDecoration(
        color: ColorConstant.cardBgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.blackColor.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left status-color accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: status.color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextContext(
                            text: ticket.title,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextContext(
                      text: ticket.description,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      color: ColorConstant.labelTextColor,
                      height: 1.4,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: ColorConstant.placeholderColor,
                        ),
                        const SizedBox(width: 4),
                        TextContext(
                          text: ticket.formattedCreatedAt,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: ColorConstant.placeholderColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SupportTicketStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 11, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- SKELETON CARD (shimmer pulse) ----------------
class _SkeletonTicketCard extends StatefulWidget {
  const _SkeletonTicketCard();

  @override
  State<_SkeletonTicketCard> createState() => _SkeletonTicketCardState();
}

class _SkeletonTicketCardState extends State<_SkeletonTicketCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar({double width = double.infinity, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: ColorConstant.cardBgColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _bar(width: 140, height: 14)),
                const SizedBox(width: 8),
                _bar(width: 60, height: 20),
              ],
            ),
            const SizedBox(height: 10),
            _bar(height: 11),
            const SizedBox(height: 6),
            _bar(width: 180, height: 11),
            const SizedBox(height: 14),
            _bar(width: 90, height: 10),
          ],
        ),
      ),
    );
  }
}

/// ---------------- EMPTY / ERROR STATE ----------------
class _CenteredState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CenteredState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: ColorConstant.placeholderColor),
            const SizedBox(height: 14),
            TextContext(
              text: title,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              TextContext(
                text: subtitle!,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                color: ColorConstant.labelTextColor,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onAction,
                child: TextContext(
                  text: actionLabel!,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}