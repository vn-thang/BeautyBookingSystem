import 'package:flutter/material.dart';
import '../models/store_review_model.dart';
import '../services/store_review_api.dart';
import '../widgets/review_filter_widget.dart';
import '../widgets/review_card_widget.dart';
import '../widgets/reply_dialog_widget.dart';
import '../../../core/theme/app_colors.dart';

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
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
        builder: (_) => Center(child: CircularProgressIndicator(color: AppColors.primary)), 
      );

      try {
        await StoreReviewApi.replyReview(id: review.id, replyContent: replyContent);
        
        if (!mounted) return;
        Navigator.pop(context);

        setState(() {
          review.reply = replyContent;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi phản hồi thành công!'), backgroundColor: Colors.green)
        );
        
      } catch (e) {
        if (!mounted) return; 
        
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá của khách', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary, // Màu đỏ chủ đạo
        iconTheme: const IconThemeData(color: Colors.white),
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
              ? Center(child: CircularProgressIndicator(color: AppColors.primary)) // Màu loading
              : _reviews.isEmpty
                  ? const Center(child: Text("Không tìm thấy đánh giá nào."))
                  : RefreshIndicator(
                      color: AppColors.primary, // Màu vòng xoay pull-to-refresh
                      onRefresh: _fetchReviews,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
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