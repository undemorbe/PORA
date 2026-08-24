import 'dart:convert';

import 'package:html/parser.dart'
    as html_parser;
import 'package:http/http.dart' as http;
import 'package:pora/core/features/recipe/data/datasource/ai_recipe_parser.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';

class YouTubeUrl {
  static bool isYouTube(Uri uri) {
    final host =
        uri.host.toLowerCase();

    return host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'youtu.be' ||
        host.endsWith('.youtube.com');
  }

  static String? videoId(
    Uri uri,
  ) {
    final host =
        uri.host.toLowerCase();

    if (host == 'youtu.be') {
      final id =
          uri.pathSegments.isNotEmpty
              ? uri.pathSegments.first
              : null;

      return _normalizeId(id);
    }

    if (uri.path == '/watch' ||
        uri.path.isEmpty) {
      return _normalizeId(
        uri.queryParameters['v'],
      );
    }

    if (uri.pathSegments.length >= 2) {
      final first =
          uri.pathSegments.first;

      if (first == 'shorts' ||
          first == 'embed' ||
          first == 'live') {
        return _normalizeId(
          uri.pathSegments[1],
        );
      }
    }

    return null;
  }

  static String? _normalizeId(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final id =
        value.trim();

    if (id.isEmpty) {
      return null;
    }

    // YouTube video IDs обычно 11 символов,
    // но не делаем слишком жёсткую валидацию.
    if (id.length < 6 ||
        id.length > 32) {
      return null;
    }

    return id;
  }
}

class YouTubeRecipeParser {
  YouTubeRecipeParser({
    http.Client? client,
    this.aiParser,
  }) : _client =
            client ?? http.Client();

  final http.Client _client;
  final AiRecipeParser? aiParser;

  static const _userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) '
      'Version/17.0 Mobile/15E148 Safari/604.1';

  Future<RecipeEntity?> parse(
    Uri uri, {
    String languageCode = 'ru',
  }) async {
    final videoId =
        YouTubeUrl.videoId(uri);

    if (videoId == null) {
      return null;
    }

    final watchUri = Uri.parse(
      'https://www.youtube.com/watch?v=$videoId',
    );

    final response =
        await _client.get(
      watchUri,
      headers: {
        'User-Agent': _userAgent,
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language':
            '$languageCode,en;q=0.8',
      },
    ).timeout(
      const Duration(seconds: 20),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 400) {
      return null;
    }

    final html =
        utf8.decode(
      response.bodyBytes,
      allowMalformed: true,
    );

    final playerResponse =
        _extractPlayerResponse(
      html,
    );

    final document =
        html_parser.parse(html);

    final title =
        _findTitle(
      playerResponse,
      document,
    );

    final description =
        _findDescription(
      playerResponse,
      document,
    );

    final image =
        _findThumbnail(
      playerResponse,
      document,
    );

    final transcript =
        await _fetchTranscript(
      playerResponse,
      languageCode,
    );

    // Сначала пробуем дешёвый deterministic parser.
    final candidates =
        _extractIngredientCandidates(
      description: description,
      transcript: transcript,
    );

    if (candidates.length >= 2) {
      return RecipeEntity(
        title: title ?? 'YouTube рецепт',
        imageUrl: image,
        sourceUrl: uri.toString(),
        ingredients: candidates as List<RecipeIngredient>,
      );
    }

    // Главный путь для свободной речи.
    if (aiParser != null) {
      final input =
          _buildAiText(
        title: title,
        description: description,
        transcript: transcript,
        candidates: candidates,
      );

      if (input.isNotEmpty) {
        final aiResult =
            await aiParser!.parse(
          pageText: input,
          sourceUrl: uri.toString(),
          languageCode: languageCode,
        );

        if (aiResult != null &&
            aiResult.ingredients.isNotEmpty) {
          return RecipeEntity(
            title: aiResult.title.isNotEmpty
                ? aiResult.title
                : (title ?? 'YouTube рецепт'),
            imageUrl:
                aiResult.imageUrl ?? image,
            servings:
                aiResult.servings,
            sourceUrl:
                uri.toString(),
            ingredients:
                aiResult.ingredients,
          );
        }
      }
    }

    if (candidates.isNotEmpty) {
      return RecipeEntity(
        title: title ?? 'YouTube рецепт',
        imageUrl: image,
        sourceUrl: uri.toString(),
        ingredients: candidates as List<RecipeIngredient>,
      );
    }

    return null;
  }

  Map<String, dynamic>?
      _extractPlayerResponse(
    String html,
  ) {
    const marker =
        'ytInitialPlayerResponse';

    final markerIndex =
        html.indexOf(marker);

    if (markerIndex < 0) {
      return null;
    }

    final equalIndex =
        html.indexOf(
      '=',
      markerIndex,
    );

    if (equalIndex < 0) {
      return null;
    }

    var start =
        equalIndex + 1;

    while (start < html.length &&
        html[start].trim().isEmpty) {
      start++;
    }

    if (start >= html.length ||
        html[start] != '{') {
      return null;
    }

    final end =
        _findJsonEnd(
      html,
      start,
    );

    if (end == null) {
      return null;
    }

    final jsonText =
        html.substring(
      start,
      end + 1,
    );

    try {
      final decoded =
          jsonDecode(jsonText);

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }
    } catch (_) {}

    return null;
  }

  int? _findJsonEnd(
    String text,
    int start,
  ) {
    var depth = 0;
    var inString = false;
    var escaped = false;

    for (var i = start;
        i < text.length;
        i++) {
      final char =
          text[i];

      if (inString) {
        if (escaped) {
          escaped = false;
          continue;
        }

        if (char == r'\') {
          escaped = true;
          continue;
        }

        if (char == '"') {
          inString = false;
        }

        continue;
      }

      if (char == '"') {
        inString = true;
        continue;
      }

      if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;

        if (depth == 0) {
          return i;
        }
      }
    }

    return null;
  }

  String? _findTitle(
    Map<String, dynamic>? player,
    dynamic document,
  ) {
    final title =
        player?['videoDetails']?['title'];

    if (title is String &&
        title.trim().isNotEmpty) {
      return title.trim();
    }

    final meta =
        document.querySelector(
      'meta[property="og:title"]',
    );

    return meta?.attributes['content']?.trim() ??
        document
            .querySelector('title')
            ?.text
            .trim();
  }

  String _findDescription(
    Map<String, dynamic>? player,
    dynamic document,
  ) {
    final shortDescription =
        player?['videoDetails']
            ?['shortDescription'];

    if (shortDescription
        is String) {
      return shortDescription.trim();
    }

    final meta =
        document.querySelector(
      'meta[property="og:description"]',
    );

    return meta?.attributes['content']
            ?.trim() ??
        '';
  }

  String? _findThumbnail(
    Map<String, dynamic>? player,
    dynamic document,
  ) {
    final thumbnails =
        player?['videoDetails']
            ?['thumbnail']?['thumbnails'];

    if (thumbnails is List &&
        thumbnails.isNotEmpty) {
      final last =
          thumbnails.last;

      if (last is Map) {
        final url =
            last['url'];

        if (url is String) {
          return url;
        }
      }
    }

    final meta =
        document.querySelector(
      'meta[property="og:image"]',
    );

    return meta?.attributes['content'];
  }

  Future<String> _fetchTranscript(
    Map<String, dynamic>? player,
    String languageCode,
  ) async {
    final tracks =
        player?['captions']
            ?['playerCaptionsTracklistRenderer']
            ?['captionTracks'];

    if (tracks is! List ||
        tracks.isEmpty) {
      return '';
    }

    final selected =
        _selectCaptionTrack(
      tracks,
      languageCode,
    );

    if (selected == null) {
      return '';
    }

    final baseUrl =
        selected['baseUrl'];

    if (baseUrl is! String ||
        baseUrl.isEmpty) {
      return '';
    }

    final transcriptUrl =
        _addFormat(baseUrl);

    try {
      final response =
          await _client.get(
        Uri.parse(transcriptUrl),
        headers: {
          'User-Agent':
              _userAgent,
          'Accept':
              'text/xml, application/xml, */*',
          'Accept-Language':
              '$languageCode,en;q=0.8',
        },
      ).timeout(
        const Duration(seconds: 12),
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 400) {
        return '';
      }

      return _parseTranscript(
        utf8.decode(
          response.bodyBytes,
          allowMalformed: true,
        ),
      );
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic>?
      _selectCaptionTrack(
    List tracks,
    String languageCode,
  ) {
    Map<String, dynamic>?
        fallback;

    for (final value
        in tracks) {
      if (value is! Map) {
        continue;
      }

      final track =
          Map<String, dynamic>.from(
        value,
      );

      fallback ??= track;

      final code =
          track['languageCode'];

      if (code == languageCode) {
        return track;
      }

      if (code is String &&
          code.startsWith(
            '$languageCode-',
          )) {
        fallback = track;
      }
    }

    return fallback;
  }

  String _addFormat(
    String baseUrl,
  ) {
    final separator =
        baseUrl.contains('?')
            ? '&'
            : '?';

    return '$baseUrl${separator}fmt=json3';
  }

  String _parseTranscript(
    String raw,
  ) {
    // json3
    try {
      final decoded =
          jsonDecode(raw);

      final events =
          decoded['events'];

      if (events is List) {
        final buffer =
            StringBuffer();

        for (final event
            in events) {
          final segs =
              event['segs'];

          if (segs is! List) {
            continue;
          }

          for (final seg
              in segs) {
            final text =
                seg['utf8'];

            if (text is String) {
              buffer.write(
                ' $text',
              );
            }
          }
        }

        return _cleanTranscript(
          buffer.toString(),
        );
      }
    } catch (_) {}

    // XML fallback.
    final document =
        html_parser.parse(
      raw,
    );

    final buffer =
        StringBuffer();

    for (final element
        in document.querySelectorAll(
      'text',
    )) {
      final text =
          element.text;

      if (text.isNotEmpty) {
        buffer.write(
          ' $text',
        );
      }
    }

    return _cleanTranscript(
      buffer.toString(),
    );
  }

  String _cleanTranscript(
    String value,
  ) {
    return value
        .replaceAll(
          RegExp(r'\[[^\]]+\]'),
          ' ',
        )
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        )
        .trim();
  }

  List<dynamic> _extractIngredientCandidates({
    required String description,
    required String transcript,
  }) {
    final lines = <String>[];

    // Description.
    lines.addAll(
      description.split(
        RegExp(r'\r?\n'),
      ),
    );

    // Если description свернут в одну строку.
    lines.addAll(
      description.split(
        RegExp(
          r'(?<=[.!?])\s+',
        ),
      ),
    );

    // Transcript очень шумный.
    // Пока только ищем явные количественные конструкции.
    if (transcript.isNotEmpty) {
      final matches =
          RegExp(
        r'(\d+(?:[.,]\d+)?)\s*'
        r'(г|кг|мл|л|шт\.?|'
        r'ст\.?\s*л\.?|ч\.?\s*л\.?|g|kg|ml|l|'
        r'tsp|tbsp|cup|cups)\s+'
        r'[^.!?]{2,100}',
        caseSensitive: false,
        unicode: true,
      ).allMatches(
        transcript,
      );

      for (final match in matches) {
        lines.add(
          match.group(0)!,
        );
      }
    }

    final result = <RecipeIngredient>[];

    for (final line in lines) {
      final cleaned =
          line.replaceAll(
        RegExp(r'\s+'),
        ' ',
      ).trim();

      if (cleaned.isEmpty) {
        continue;
      }

      final lower =
          cleaned.toLowerCase();

      if (!_looksLikeIngredientText(
        lower,
      )) {
        continue;
      }

      result.add(
        _parseIngredient(
          cleaned,
        ),
      );
    }

    final unique =
        <String, RecipeIngredient>{};

    for (final item in result) {
      unique[
        '${item.name}|${item.quantity}|${item.unit}'
      ] ??= item;
    }

    return unique.values.toList();
  }

  bool _looksLikeIngredientText(
    String text,
  ) {
    if (text.length < 3 ||
        text.length > 180) {
      return false;
    }

    if (text.contains(
          'https://',
        ) ||
        text.contains(
          'www.',
        )) {
      return false;
    }

    return RegExp(
      r'\d',
      unicode: true,
    ).hasMatch(text);
  }

  RecipeIngredient _parseIngredient(
    String raw,
  ) {
    final match =
        RegExp(
      r'^\s*'
      r'(?<quantity>\d+(?:[.,]\d+)?)'
      r'\s*'
      r'(?<unit>г|кг|мл|л|шт\.?|'
      r'ст\.?\s*л\.?|ч\.?\s*л\.?|'
      r'g|kg|ml|l|tsp|tbsp|cup|cups)?'
      r'\s+'
      r'(?<name>.+)$',
      caseSensitive: false,
      unicode: true,
    ).firstMatch(raw);

    if (match == null) {
      return RecipeIngredient(
        name: raw,
        raw: raw,
      );
    }

    return RecipeIngredient(
      name:
          match.namedGroup(
            'name',
          )?.trim() ??
              raw,
      quantity:
          match.namedGroup(
            'quantity',
          ),
      unit:
          _normalizeUnit(
        match.namedGroup(
          'unit',
        ),
      ),
      raw: raw,
    );
  }

  String? _normalizeUnit(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final normalized =
        value
            .toLowerCase()
            .replaceAll(
              '.',
              '',
            )
            .replaceAll(
              ' ',
              '',
            );

    const units = {
      'г': 'g',
      'кг': 'kg',
      'мл': 'ml',
      'л': 'l',
      'шт': 'pcs',
      'стл': 'tbsp',
      'чл': 'tsp',
      'g': 'g',
      'kg': 'kg',
      'ml': 'ml',
      'l': 'l',
      'tsp': 'tsp',
      'tbsp': 'tbsp',
      'cup': 'cup',
      'cups': 'cup',
    };

    return units[normalized];
  }

  String _buildAiText({
    required String? title,
    required String description,
    required String transcript,
    required List candidates,
  }) {
    final buffer =
        StringBuffer();

    buffer.writeln(
      'SOURCE TYPE: YOUTUBE',
    );

    if (title != null &&
        title.isNotEmpty) {
      buffer.writeln(
        '\nVIDEO TITLE:\n$title',
      );
    }

    if (description.isNotEmpty) {
      buffer.writeln(
        '\nVIDEO DESCRIPTION:\n'
        '$description',
      );
    }

    if (candidates.isNotEmpty) {
      buffer.writeln(
        '\nCANDIDATE INGREDIENTS:',
      );

      for (final item in candidates) {
        buffer.writeln(
          '- ${item.raw}',
        );
      }
    }

    if (transcript.isNotEmpty) {
      buffer.writeln(
        '\nTRANSCRIPT:\n'
        '${_limit(
          transcript,
          30_000,
        )}',
      );
    }

    return buffer.toString();
  }

  String _limit(
    String value,
    int max,
  ) {
    if (value.length <= max) {
      return value;
    }

    return value.substring(
      0,
      max,
    );
  }
}