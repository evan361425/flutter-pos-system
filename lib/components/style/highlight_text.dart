import 'package:flutter/material.dart';

/// A widget that highlights matching text patterns within a string.
///
/// This is useful for search results where you want to visually emphasize
/// the parts of the text that match the search query.
class HighlightText extends StatelessWidget {
  final String text;
  final String pattern;
  final String? prefix;

  const HighlightText({
    super.key,
    required this.text,
    required this.pattern,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalStyle = theme.textTheme.bodyMedium;
    final highlightStyle = normalStyle?.copyWith(
      backgroundColor: theme.highlightColor,
      fontWeight: FontWeight.bold,
    );

    final spans = _buildHighlightedSpans(normalStyle, highlightStyle);

    return Text.rich(TextSpan(children: spans));
  }

  /// Builds a list of TextSpan objects with highlighted matches
  List<TextSpan> _buildHighlightedSpans(
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  ) {
    final spans = <TextSpan>[
      if (prefix != null)
        TextSpan(
          text: prefix,
          style: normalStyle?.copyWith(fontWeight: FontWeight.bold),
        ),
    ];
    final textLower = text.toLowerCase();
    final patternWords = pattern.toLowerCase().split(' ').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (patternWords.isEmpty) {
      spans.add(TextSpan(text: text, style: normalStyle));
      return spans;
    }

    // Find all matches for each pattern word
    final allMatches = <_Match>[];
    for (final word in patternWords) {
      int startIndex = 0;
      while (true) {
        final index = textLower.indexOf(word, startIndex);
        if (index == -1) break;

        allMatches.add(_Match(index, index + word.length));
        startIndex = index + 1;
      }
    }

    // Sort matches by start position and merge overlapping ones
    allMatches.sort((a, b) => a.start.compareTo(b.start));
    final mergedMatches = _mergeOverlappingMatches(allMatches);

    // Build spans based on merged matches
    int currentIndex = 0;
    for (final match in mergedMatches) {
      // Add text before the match
      if (currentIndex < match.start) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: normalStyle,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: highlightStyle,
      ));

      currentIndex = match.end;
    }

    // Add remaining text after the last match
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: normalStyle,
      ));
    }

    return spans;
  }

  /// Merges overlapping matches to avoid double highlighting
  List<_Match> _mergeOverlappingMatches(List<_Match> matches) {
    if (matches.isEmpty) return [];

    final merged = <_Match>[];
    _Match current = matches.first;

    for (int i = 1; i < matches.length; i++) {
      final next = matches[i];
      if (current.end >= next.start) {
        // Overlapping or adjacent matches, merge them
        current = _Match(current.start, next.end > current.end ? next.end : current.end);
      } else {
        // Non-overlapping, add current and move to next
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);
    return merged;
  }
}

/// Represents a match position in the text
class _Match {
  final int start;
  final int end;

  _Match(this.start, this.end);
}
