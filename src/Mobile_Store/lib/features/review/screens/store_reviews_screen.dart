import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../models/store_review_model.dart';
import '../services/store_review_api.dart';
import '../widgets/review_filter_widget.dart';
import '../widgets/review_card_widget.dart';
import '../widgets/reply_dialog_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';


class StoreReviewsScreen extends StatefulWidget {
  const StoreReviewsScreen({super.key});

  @override
  State<StoreReviewsScreen> createState() => _StoreReviewsScreenState();
}

class _StoreReviewsScreenState extends State<StoreReviewsScreen> {
  List<StoreReviewModel> _reviews = [];
  bool _isLoading = true;

  int? _ratingFilter;
  bool? _repliedFilter;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoading = true);
    try {
      final data = await StoreReviewApi.getReviews(
        rating: _ratingFilter, 
        hasReplied: _repliedFilter
      );
      setState(() => _reviews = data);
    } catch (e) {
      if (mounted) SnackBarHelper.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReplyAction(StoreReviewModel review) async {
    final replyContent = await showDialog<String>(
      context: context,
      builder: (context) => ReplyDialogWidget(initialReply: review.reply),
    );

    if (!mounted) return; 

    if (replyContent != null && replyContent.isNotEmpty) {
      showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)), 
      );

      try {
        await StoreReviewApi.replyReview(id: review.id, replyContent: replyContent);
        
        if (!mounted) return;
        Navigator.pop(context);

        setState(() {
          review.reply = replyContent;
        });
        
        SnackBarHelper.showSuccess(context, 'Gửi phản hồi thành công!');
      } catch (e) {
        if (!mounted) return; 
        
        Navigator.pop(context); 
        SnackBarHelper.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: 'Đánh giá của khách',
      ),
      body: Column(
        children: [
          ReviewFilterWidget(
            selectedRating: _ratingFilter,
            selectedHasReplied: _repliedFilter,
            onFilterChanged: (rating, hasReplied) {
              setState(() {
                _ratingFilter = rating;
                _repliedFilter = hasReplied;
              });
              _fetchReviews();
            },
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) 
              : _reviews.isEmpty
                  ? Center(child: Text("Không tìm thấy đánh giá nào.", style: AppTextStyles.bodyText))
                  : RefreshIndicator(
                      color: AppColors.primary, 
                      onRefresh: _fetchReviews,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppDimens.paddingLarge),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          return ReviewCardWidget(
                            review: review,
                            onReplyTap: () => _handleReplyAction(review),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}