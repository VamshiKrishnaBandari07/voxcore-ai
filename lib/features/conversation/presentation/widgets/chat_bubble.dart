import 'package:flutter/material.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../models/conversation_models.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.friendName,
    this.onTapUser,
  });

  final ChatMessage message;
  final String friendName;
  final VoidCallback? onTapUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFriend = message.isFriend;

    return Align(
      alignment: isFriend ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isFriend) _Avatar(label: friendName[0], color: theme.colorScheme.primary),
            if (isFriend) const SizedBox(width: 8),
            Flexible(
              child: Material(
                color: isFriend
                    ? theme.cardTheme.color
                    : theme.colorScheme.primary.withOpacity(0.18),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isFriend ? 4 : 18),
                  bottomRight: Radius.circular(isFriend ? 18 : 4),
                ),
                child: InkWell(
                  onTap: !isFriend && message.sessionId != null ? onTapUser : null,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isFriend ? theme.dividerColor : theme.colorScheme.primary.withOpacity(0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFriend)
                          Text(
                            friendName,
                            style: AppFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        if (isFriend) const SizedBox(height: 4),
                        Text(
                          message.text,
                          style: AppFonts.inter(
                            fontSize: 15,
                            height: 1.45,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (!isFriend && message.sessionId != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_outline_rounded,
                                  size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to view analysis',
                                style: AppFonts.inter(
                                  fontSize: 11,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!isFriend) const SizedBox(width: 8),
            if (!isFriend)
              _Avatar(label: 'You', color: theme.colorScheme.tertiary, small: true),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.label, required this.color, this.small = false});

  final String label;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 32.0 : 36.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label.length > 1 ? label.substring(0, 1) : label,
        style: AppFonts.inter(
          fontWeight: FontWeight.w800,
          fontSize: small ? 11 : 14,
          color: color,
        ),
      ),
    );
  }
}
