import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/wordle_providers.dart';

/// Paste-back sheet: the return half of the Wordle round trip (§6).
Future<void> showWordleImportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: RitualColors.bg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _WordleImportSheet(),
  );
}

class _WordleImportSheet extends ConsumerStatefulWidget {
  const _WordleImportSheet();

  @override
  ConsumerState<_WordleImportSheet> createState() => _WordleImportSheetState();
}

class _WordleImportSheetState extends ConsumerState<_WordleImportSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Nine times out of ten the share is already on the clipboard, so offer it
    // rather than making the user paste manually.
    _prefillFromClipboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _prefillFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted) return;
    if (!text.contains(RegExp('Wordle', caseSensitive: false))) return;
    if (_controller.text.isEmpty) _controller.text = text;
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final outcome = await importWordleShare(ref, _controller.text);
    if (!mounted) return;

    switch (outcome) {
      case ImportRejected(:final reason):
        setState(() {
          _saving = false;
          _error = reason;
        });
      case ImportedResult(:final share, :final isToday):
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isToday
                  ? 'Saved — Wordle ${share.number}, ${share.scoreLabel}.'
                  : 'Saved under ${share.date} — that was Wordle ${share.number}.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RitualColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Eyebrow('Import result'),
              const SizedBox(height: 8),
              Text(
                "Tap Share in Wordle, then paste it here. Your result is read "
                "from the text you paste — the app never touches the NYT page.",
                style: RitualText.bodySmall,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                maxLines: 6,
                minLines: 4,
                style: outfit(size: 13, height: 1.4),
                decoration: InputDecoration(
                  hintText: 'Wordle 1,234 4/6\n⬛⬛🟨⬛⬛\n…',
                  hintStyle: outfit(
                    size: 13,
                    color: RitualColors.textTertiary,
                    height: 1.4,
                  ),
                  filled: true,
                  fillColor: RitualColors.surface,
                  contentPadding: const EdgeInsets.all(12),
                  border: _border(RitualColors.borderStrong),
                  enabledBorder: _border(RitualColors.borderStrong),
                  focusedBorder: _border(RitualColors.accent),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: outfit(
                    size: 12,
                    color: RitualColors.error,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: _saving ? 'Saving…' : 'Save result',
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      RitualShape.buttonRadius,
                    ),
                    child: InkWell(
                      onTap: () async {
                        final data = await Clipboard.getData(
                          Clipboard.kTextPlain,
                        );
                        if (data?.text != null) {
                          _controller.text = data!.text!;
                          setState(() => _error = null);
                        }
                      },
                      borderRadius: BorderRadius.circular(
                        RitualShape.buttonRadius,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: RitualColors.borderStrong,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            RitualShape.buttonRadius,
                          ),
                        ),
                        child: const Icon(
                          Icons.content_paste_rounded,
                          size: 18,
                          color: RitualColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(RitualShape.inputRadius),
    borderSide: BorderSide(color: color, width: 1.5),
  );
}
