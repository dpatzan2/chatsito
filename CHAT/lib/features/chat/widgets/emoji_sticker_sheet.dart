import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/seed_data.dart';
import '../chat_controller.dart';

class EmojiStickerSheet extends StatelessWidget {
  const EmojiStickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ChatController>();
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: C.line)),
          boxShadow: [BoxShadow(color: Color(0x1F140E2D), blurRadius: 40, offset: Offset(0, -14))],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(children: [
              _tab('Emojis', !c.stickerTab, () => c.setStickerTab(false)),
              const SizedBox(width: 6),
              _tab('Stickers', c.stickerTab, () => c.setStickerTab(true)),
              const Spacer(),
              GestureDetector(
                onTap: c.closeSheets,
                child: Container(
                  width: 32, height: 32, alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0xFFF1F1F4), shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 16, color: C.muted),
                ),
              ),
            ]),
          ),
          Expanded(
            child: c.stickerTab
                ? GridView.count(
                    crossAxisCount: 3, padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
                    mainAxisSpacing: 10, crossAxisSpacing: 10,
                    children: [for (final g in SeedData.stickers) GestureDetector(
                      onTap: () => c.sendSticker(g),
                      child: Container(
                        decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(14)),
                        alignment: Alignment.center,
                        child: Text(g, style: const TextStyle(fontSize: 46)),
                      ),
                    )],
                  )
                : GridView.count(
                    crossAxisCount: 7, padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
                    mainAxisSpacing: 4, crossAxisSpacing: 4,
                    children: [for (final g in SeedData.emojis) GestureDetector(
                      onTap: () => c.addEmoji(g),
                      child: Center(child: Text(g, style: const TextStyle(fontSize: 28))),
                    )],
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(color: active ? C.accent : const Color(0xFFF1F1F4), borderRadius: BorderRadius.circular(10)),
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : C.sub)),
        ),
      );
}
