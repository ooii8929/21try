import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/isar_service.dart';
import '../models/isar_models.dart';

class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({Key? key}) : super(key: key);

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  final TextEditingController _goalController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildGoalInput(),
            const Spacer(),
            _buildNextButton(),
            Container(
              height: 20,
              color: AppColors.background,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: AppColors.background,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.textPrimary,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 48),
              child: Text(
                'New goal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _goalController,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: const InputDecoration(
            hintText: 'What  do you want to achieve?',
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: () async {
          if (_goalController.text.trim().isNotEmpty) {
            final goal = Goal()..title = _goalController.text.trim();
            await IsarService.saveGoal(goal);
          }
          if (!mounted) return;
          Navigator.pop(context);
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'Next',
              style: TextStyle(
                color: AppColors.background,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
