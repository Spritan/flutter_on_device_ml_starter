//
//  Generated code. Do not modify.
//  source: clip_tf/tokenized_prompts.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class TokenizedPrompts extends $pb.GeneratedMessage {
  factory TokenizedPrompts({
    $core.Iterable<TokenizedPrompt>? prompts,
  }) {
    final $result = create();
    if (prompts != null) {
      $result.prompts.addAll(prompts);
    }
    return $result;
  }
  TokenizedPrompts._() : super();
  factory TokenizedPrompts.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TokenizedPrompts.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TokenizedPrompts', package: const $pb.PackageName(_omitMessageNames ? '' : 'clip_tf'), createEmptyInstance: create)
    ..pc<TokenizedPrompt>(1, _omitFieldNames ? '' : 'prompts', $pb.PbFieldType.PM, subBuilder: TokenizedPrompt.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TokenizedPrompts clone() => TokenizedPrompts()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TokenizedPrompts copyWith(void Function(TokenizedPrompts) updates) => super.copyWith((message) => updates(message as TokenizedPrompts)) as TokenizedPrompts;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenizedPrompts create() => TokenizedPrompts._();
  TokenizedPrompts createEmptyInstance() => create();
  static $pb.PbList<TokenizedPrompts> createRepeated() => $pb.PbList<TokenizedPrompts>();
  @$core.pragma('dart2js:noInline')
  static TokenizedPrompts getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenizedPrompts>(create);
  static TokenizedPrompts? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TokenizedPrompt> get prompts => $_getList(0);
}

class TokenizedPrompt extends $pb.GeneratedMessage {
  factory TokenizedPrompt({
    $core.Iterable<$fixnum.Int64>? inputIds,
  }) {
    final $result = create();
    if (inputIds != null) {
      $result.inputIds.addAll(inputIds);
    }
    return $result;
  }
  TokenizedPrompt._() : super();
  factory TokenizedPrompt.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TokenizedPrompt.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TokenizedPrompt', package: const $pb.PackageName(_omitMessageNames ? '' : 'clip_tf'), createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'inputIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TokenizedPrompt clone() => TokenizedPrompt()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TokenizedPrompt copyWith(void Function(TokenizedPrompt) updates) => super.copyWith((message) => updates(message as TokenizedPrompt)) as TokenizedPrompt;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenizedPrompt create() => TokenizedPrompt._();
  TokenizedPrompt createEmptyInstance() => create();
  static $pb.PbList<TokenizedPrompt> createRepeated() => $pb.PbList<TokenizedPrompt>();
  @$core.pragma('dart2js:noInline')
  static TokenizedPrompt getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenizedPrompt>(create);
  static TokenizedPrompt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$fixnum.Int64> get inputIds => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
