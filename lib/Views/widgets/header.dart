import 'package:flutter/material.dart';
import '../styles/AppTextStyles.dart';
import '../styles/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback onLogout;

  const AppHeader({
    super.key,
    required this.userName,
    required this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.borderColor),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBrand(context),
            _buildUserSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/LOGO.png',
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'FinanceManager',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserSection() {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Hola, ',
                style: AppTextStyles.bodySmall,
              ),
              TextSpan(
                text: userName,
                style: AppTextStyles.label,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        _LogoutButton(onLogout: onLogout),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onLogout,
      icon: const Icon(
        Icons.logout_outlined,
        size: 15,
        color: AppColors.mutedText,
      ),
      label: const Text(
        'Salir',
        style: TextStyle(
          color: AppColors.mutedText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: AppColors.inputFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderColor),
        ),
      ),
    );
  }
}