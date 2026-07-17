import 'package:flutter/material.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';

/// Shopzo — Help & Support screen.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _sending = false;

  static const List<_IssueData> _issues = [
    _IssueData(icon: Icons.card_giftcard, title: 'Orders & Tracking'),
    _IssueData(icon: Icons.credit_card_rounded, title: 'Payments & Refunds'),
    _IssueData(icon: Icons.assignment_return_rounded, title: 'Returns & Exchanges'),
    _IssueData(icon: Icons.shield_rounded, title: 'Account Security'),
  ];

  void _onIssueTap(_IssueData issue) {
    // 👉 navigate to FAQ / article list for this issue category
  }

  void _onSend() {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      return;
    }
    setState(() => _sending = true);

    // 👉 call your support-ticket API here
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _sending = false);
      _titleController.clear();
      _descriptionController.clear();
    });
  }

  void _onCall() {}
  void _onChat() {}
  void _onEmail() {}

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(title: const Text('Help & Support')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- SEARCH BAR ----------------
              // _SearchField(controller: _searchController),
              // ---------------- COMMON ISSUES ----------------
              TextContext(
                text: 'Common Issues',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: ColorConstant.headlineTextColor,
              ),
              SizedBox(height: size.height * 0.02),
              _IssuesGrid(issues: _issues, onTap: _onIssueTap),

              SizedBox(height: size.height * 0.03),

              // ---------------- STILL NEED HELP CARD ----------------
              _SupportFormCard(
                titleController: _titleController,
                descriptionController: _descriptionController,
                sending: _sending,
                onSend: _onSend,
              ),

              SizedBox(height: size.height * 0.035),

              // ---------------- QUICK CONTACT ----------------
              Center(
                child: TextContext(
                  text: 'QUICK CONTACT',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.labelTextColor,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: size.height * 0.018),
              _QuickContactRow(
                onCall: _onCall,
                onChat: _onChat,
                onEmail: _onEmail,
              ),

              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- SEARCH FIELD ----------------
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.058,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: ColorConstant.placeholderColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: ColorConstant.headlineTextColor,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search for help, FAQs, or topics',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: ColorConstant.placeholderColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- ISSUE MODEL ----------------
class _IssueData {
  final IconData icon;
  final String title;
  const _IssueData({required this.icon, required this.title});
}

/// ---------------- COMMON ISSUES GRID (staggered, first cell empty) ----------------
class _IssuesGrid extends StatelessWidget {
  final List<_IssueData> issues;
  final ValueChanged<_IssueData> onTap;

  const _IssuesGrid({required this.issues, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardHeight = size.height * 0.135;
    final gap = size.width * 0.04;

    return Column(
      children: [
        // top row — empty left slot, "Payments & Refunds" on the right
        Row(
          children: [
            Expanded(
              child: _IssueCard(
                data: issues[0],
                height: cardHeight,
                onTap: () => onTap(issues[0]),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _IssueCard(
                data: issues[1],
                height: cardHeight,
                onTap: () => onTap(issues[1]),
              ),
            ),
          ],
        ),
        SizedBox(height: gap),
        // bottom row — "Returns & Exchanges" + "Account Security"
        Row(
          children: [
            Expanded(
              child: _IssueCard(
                data: issues[2],
                height: cardHeight,
                onTap: () => onTap(issues[2]),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _IssueCard(
                data: issues[3],
                height: cardHeight,
                onTap: () => onTap(issues[3]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IssueCard extends StatelessWidget {
  final _IssueData data;
  final double height;
  final VoidCallback onTap;

  const _IssueCard({required this.data, required this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: ColorConstant.fieldFillColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(data.icon, size: 19, color: ColorConstant.headlineTextColor),
            ),
            const SizedBox(height: 10),
            TextContext(
              text: data.title,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              color: ColorConstant.bodyTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- "STILL NEED HELP?" FORM CARD ----------------
class _SupportFormCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool sending;
  final VoidCallback onSend;

  const _SupportFormCard({
    required this.titleController,
    required this.descriptionController,
    required this.sending,
    required this.onSend,
  });

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      isCollapsed: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: ColorConstant.fieldFillColor,
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13.5,
        color: ColorConstant.placeholderColor,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: ColorConstant.cardBgColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.blackColor.withOpacity(.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextContext(
            text: 'Still need help?',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorConstant.headlineTextColor,
          ),
          SizedBox(height: size.height * 0.008),
          TextContext(
            text:
            'Describe your issue and our team will get back to you within 24 hours.',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: ColorConstant.labelTextColor,
          ),
          SizedBox(height: size.height * 0.022),

          TextField(
            controller: titleController,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              color: ColorConstant.headlineTextColor,
            ),
            decoration: _decoration('Issue Title'),
          ),

          SizedBox(height: size.height * 0.016),

          TextField(
            controller: descriptionController,
            minLines: 4,
            maxLines: 6,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              color: ColorConstant.headlineTextColor,
            ),
            decoration: _decoration('Write your problem here...'),
          ),

          SizedBox(height: size.height * 0.022),

          CustomButton(
            text: 'Send Now',
            onTap: onSend,
            loading: sending,
            color: ColorConstant.primaryColor,
            icon: Icons.send_rounded,
            iconColor: ColorConstant.whiteColor,
          ),
        ],
      ),
    );
  }
}

/// ---------------- QUICK CONTACT ROW ----------------
class _QuickContactRow extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onEmail;

  const _QuickContactRow({
    required this.onCall,
    required this.onChat,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final items = [
      (Icons.call_rounded, 'Call', onCall),
      (Icons.chat_bubble_rounded, 'Chat', onChat),
      (Icons.email_rounded, 'Email', onEmail),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
          child: GestureDetector(
            onTap: item.$3,
            child: Column(
              children: [
                Container(
                  height: size.width * 0.14,
                  width: size.width * 0.14,
                  decoration: BoxDecoration(
                    color: ColorConstant.whiteColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorConstant.borderColor),
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.$1, size: 20, color: ColorConstant.primaryColor),
                ),
                SizedBox(height: size.height * 0.006),
                TextContext(
                  text: item.$2,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.bodyTextColor,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}