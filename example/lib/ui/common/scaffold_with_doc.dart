import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:septeo_design_system/septeo_design_system.dart';

class ScaffoldWithDoc extends StatelessWidget {
  final String title;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final bool isLoading;

  const ScaffoldWithDoc({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> leftActions = [];
    if (context.canPop()) {
      leftActions.add(
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("dio_oidc_interceptor: $title"),
        backgroundColor: SepteoColors.orange.shade100,
        elevation: 9,
        shadowColor: SepteoColors.grey[900],
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: leftActions,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: SepteoColors.blue,
              ),
              onPressed: isLoading ? null : onButtonPressed,
              icon: isLoading
                  ? SizedBox(
                      width: 12,
                      height: 12,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : null,
              label: Text(
                buttonLabel,
                style: SepteoTextStyles.bodySmallInter.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: SepteoSpacings.xl,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MarkdownWithHighlight.fromAsset(
                    "assets/markdown/${title}_en.md"),
              ),
              Expanded(
                child: MarkdownWithHighlight.fromAsset(
                    "assets/markdown/${title}_fr.md"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
