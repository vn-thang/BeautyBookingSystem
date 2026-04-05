// customer_favorite_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_customer/features/customer_favorite/domain/usecases/favorite_service_usecase.dart';
import 'package:mobile_customer/features/customer_favorite/domain/usecases/favorite_store_usecase.dart';
import 'package:mobile_customer/features/customer_favorite/domain/usecases/unfavorite_service_usecase.dart';
import 'package:mobile_customer/features/customer_favorite/domain/usecases/unfavorite_store_usecase.dart';

import '../bloc/customer_favorite_bloc.dart';
import '../../../../injection/service_locator.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

// chỉnh lại path theme cho đúng project của bạn
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

class CustomerFavoriteButton extends StatefulWidget {
  final CustomerFavoriteType type;
  final int targetId;
  final bool initialIsFavorite;
  final String removeConfirmTitle;
  final String removeConfirmMessage;
  final VoidCallback? onChanged;

  const CustomerFavoriteButton({
    super.key,
    required this.type,
    required this.targetId,
    required this.initialIsFavorite,
    required this.removeConfirmTitle,
    required this.removeConfirmMessage,
    this.onChanged,
  });

  @override
  State<CustomerFavoriteButton> createState() => _CustomerFavoriteButtonState();
}

class _CustomerFavoriteButtonState extends State<CustomerFavoriteButton> {
  late final CustomerFavoriteBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = CustomerFavoriteBloc(
      type: widget.type,
      targetId: widget.targetId,
      favoriteStoreUseCase: di.sl<FavoriteStoreUseCase>(),
      unfavoriteStoreUseCase: di.sl<UnfavoriteStoreUseCase>(),
      favoriteServiceUseCase: di.sl<FavoriteServiceUseCase>(),
      unfavoriteServiceUseCase: di.sl<UnfavoriteServiceUseCase>(),
      initialIsFavorite: widget.initialIsFavorite,
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _handleTap(CustomerFavoriteState state) async {
    final isLoggedIn = context.read<AuthBloc>().state is AuthAuthenticated;

    if (!isLoggedIn) {
      context.push('/login');
      return;
    }

    if (!state.isFavorite) {
      context
          .read<CustomerFavoriteBloc>()
          .add(CustomerFavoriteFavoritePressed());
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          title: Text(
            widget.removeConfirmTitle,
            style: AppTextStyles.sectionTitle,
          ),
          content: Text(
            widget.removeConfirmMessage,
            style: AppTextStyles.bodyMuted,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Bỏ yêu thích'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      context
          .read<CustomerFavoriteBloc>()
          .add(CustomerFavoriteUnfavoritePressed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<CustomerFavoriteBloc, CustomerFavoriteState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppColors.danger,
                ),
              );
          }

          if (state.successMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppColors.success,
                ),
              );

            widget.onChanged?.call();
          }
        },
        builder: (context, state) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: state.isLoading ? null : () => _handleTap(state),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSoft),
                  boxShadow: AppDecorations.softShadow,
                ),
                child: state.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        state.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: state.isFavorite
                            ? AppColors.danger
                            : AppColors.primary,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
